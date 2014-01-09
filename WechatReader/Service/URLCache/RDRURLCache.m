//
// Created by wilsonwan on 14-1-7.
//
// Copyright (c) 2013年 Tencent. All rights reserved.
//


#import <CommonCrypto/CommonDigest.h>
#import "RDRURLCache.h"
#import "RDRCacheEntity.h"
#import "RDRAppDelegate.h"
#import "safe_dispatch_queue.h"


@interface RDRURLCache()
@property (nonatomic) NSManagedObjectModel *managedObjectModel;
@property (nonatomic) NSManagedObjectContext *managedObjectContext;
@property (nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (nonatomic) dispatch_queue_t coreDataQueue;
@end

@implementation RDRURLCache
- (id)init {
    self = [super init];
    if (self) {
        _coreDataQueue = dispatch_create_safe_queue("URLCache", DISPATCH_QUEUE_SERIAL);
    }

    return self;
}

- (void)storeCachedResponse:(NSCachedURLResponse *)cachedResponse forRequest:(NSURLRequest *)request {
    if (! [request.HTTPMethod isEqualToString:@"GET"]) {
        NSLog(@"Ignore storing request: %@", request);
        return;
    }
    NSString *url = request.URL.absoluteString;

    NSLog(@"storing cache: %@", url);
    dispatch_async(self.coreDataQueue, ^{
        RDRCacheEntity *cache = (RDRCacheEntity *) [NSEntityDescription insertNewObjectForEntityForName:@"CacheEntity"
                                                                                 inManagedObjectContext:self.managedObjectContext];
        cache.url = url;
        cache.ctime = [NSDate date];
        cache.textEncodingName = cachedResponse.response.textEncodingName;
        cache.expectedContentLength = [NSNumber numberWithLongLong:cachedResponse.response.expectedContentLength];
        cache.mimeType = cachedResponse.response.MIMEType;

        [self writeCache:cachedResponse.data withUrl:url];

        NSError *error;
        if (! [cache.managedObjectContext save:&error]) {
            NSLog(@"Failed to save cache|request=%@, error=%@", url, error);
        }
    });
}

- (NSCachedURLResponse *)cachedResponseForRequest:(NSURLRequest *)request {
    if (! [request.HTTPMethod isEqualToString:@"GET"]) {
        return nil;
    }
    NSString *url = request.URL.absoluteString;

    __block NSURLResponse *response = nil;
    dispatch_safe_sync(self.coreDataQueue, ^{
        RDRCacheEntity *entity = [self findCacheEntityByUrl:url];
        if (entity == nil) {
            return;
        }

        response = [[NSURLResponse alloc] initWithURL:request.URL
                                                            MIMEType:entity.mimeType
                                               expectedContentLength:[entity.expectedContentLength integerValue]
                                                    textEncodingName:entity.textEncodingName];
    });
    if (response == nil) {
        NSLog(@"cache not found: %@", url);
        return nil;
    }

    NSData *data = [self readCacheWithUrl:url];
    if (data == nil) {
        NSLog(@"data not found, remove it: %@", url);

        [self removeCacheWithUrl:url];
        return nil;
    }
    NSCachedURLResponse *cachedURLResponse = [[NSCachedURLResponse alloc] initWithResponse:response data:data];

    NSLog(@"found cache for: %@", url);
    return cachedURLResponse;
}

- (void)removeCachedResponseForRequest:(NSURLRequest *)request {
    NSLog(@"remove cache: %@", request.URL.absoluteString);
    [super removeCachedResponseForRequest:request];
}

- (void)removeAllCachedResponses {
    NSLog(@"remove all cache");
    [super removeAllCachedResponses];
}

- (void)removeCacheWithUrl:(NSString *)url {
    dispatch_async(self.coreDataQueue, ^{
        // TODO:
    });
}

#pragma mark - disk files
- (NSURL *)urlCacheDirectory {
    NSURL *cacheDirectory = [[[NSFileManager defaultManager] URLsForDirectory:NSCachesDirectory inDomains:NSUserDomainMask] lastObject];
    return [cacheDirectory URLByAppendingPathComponent:@"URLCache"];
}

- (NSURL *)pathForCacheOfUrl:(NSString *)url {
    const char *cstr = url.UTF8String;
    unsigned char md5[16];
    CC_MD5(cstr, strlen(cstr), md5);

    char cstrMd5[2*sizeof(md5)+1];
    for (size_t i=0; i<sizeof(md5); i++) {
        cstrMd5[2*i] = (md5[i] / 16) + 'a';
        cstrMd5[2*i+1] = (md5[i] % 16) + 'a';
    }
    cstrMd5[2*sizeof(md5)] = 0;

    NSString *strMd5 = [NSString stringWithCString:cstrMd5 encoding:NSASCIIStringEncoding];

    NSURL *ret = [[[self urlCacheDirectory]
            URLByAppendingPathComponent:[strMd5 substringToIndex:2]]
            URLByAppendingPathComponent:strMd5];
    return ret;
}

- (void)writeCache:(NSData *)data withUrl:(NSString *)url {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        NSURL *filePath = [self pathForCacheOfUrl:url];
        NSURL *parent = [filePath URLByDeletingLastPathComponent];
        NSError *error;
        if (! [[NSFileManager defaultManager] createDirectoryAtURL:parent
                                       withIntermediateDirectories:YES
                                                        attributes:nil
                                                             error:&error]){
            NSLog(@"Failed to create path:'%@', error=%@", parent, error);
            return;
        }

        [[NSFileManager defaultManager] removeItemAtURL:filePath error:nil];
        if (![data writeToURL:filePath options:NSDataWritingWithoutOverwriting error:&error])
        if (![data writeToURL:filePath atomically:YES]) {
            NSLog(@"Failed to write file:'%@', error=%@", filePath, error);
            return;
        }
    });
}

- (NSData *)readCacheWithUrl:(NSString *)url {
    NSURL *filePath = [self pathForCacheOfUrl:url];
    return [NSData dataWithContentsOfURL:filePath];
}

#pragma mark - core data

- (RDRCacheEntity *)findCacheEntityByUrl:(NSString *)url {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];

    NSEntityDescription *entity = [NSEntityDescription entityForName:@"CacheEntity" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];

    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"url == %@", url];
    fetchRequest.fetchLimit = 1;

    NSError *error = nil;
    NSArray *result = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];

    if (error != nil) {
        NSLog(@"Failed to fetch url: %@", error);
    }

    if (result.count >= 1) {
        return result[0];
    }
    return nil;
}

- (NSManagedObjectModel *)managedObjectModel {
    if (_managedObjectModel == nil) {
        dispatch_safe_sync(self.coreDataQueue, ^{
            NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"URLCache" withExtension:@"momd"];
            _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
        });
    }
    return _managedObjectModel;
}

- (NSManagedObjectContext *)managedObjectContext {
    if (_managedObjectContext == nil) {
        dispatch_safe_sync(self.coreDataQueue, ^{
            NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
            if (coordinator != nil) {
                _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
                [_managedObjectContext setPersistentStoreCoordinator: coordinator];
            }
        });
    }
    return _managedObjectContext;

}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {

    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }

    dispatch_safe_sync(self.coreDataQueue, ^{
        NSURL *storeURL = [[RDRAppDelegate applicationDocumentsDirectory] URLByAppendingPathComponent:@"URLCache.CDBStore"];

        NSDictionary *options = @{NSMigratePersistentStoresAutomaticallyOption: @YES, NSInferMappingModelAutomaticallyOption: @YES};
        _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:self.managedObjectModel];

        NSError *error;
        if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error]) {
            /*
             Replace this implementation with code to handle the error appropriately.

             abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.

             Typical reasons for an error here include:
             * The persistent store is not accessible;
             * The schema for the persistent store is incompatible with current managed object model.
             Check the error message to determine what the actual problem was.


             If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.

             If you encounter schema incompatibility errors during development, you can reduce their frequency by:
             * Simply deleting the existing store:
             [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]

             * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
             @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}

             Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.

             */
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    });

    return _persistentStoreCoordinator;
}

@end