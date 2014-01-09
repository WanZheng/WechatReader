//
// Created by wilsonwan on 14-1-7.
//
// Copyright (c) 2013年 Tencent. All rights reserved.
//


#import "RDRURLCache.h"
#import "RDRCacheEntity.h"
#import "RDRAppDelegate.h"
#import "safe_dispatch_queue.h"


@interface RDRURLCache()
@property (nonatomic) NSMutableDictionary *dataMap; // 临时记录到内存

@property (nonatomic) NSManagedObjectModel *managedObjectModel;
@property (nonatomic) NSManagedObjectContext *managedObjectContext;
@property (nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (nonatomic) dispatch_queue_t coreDataQueue;
@end

@implementation RDRURLCache
- (id)init {
    self = [super init];
    if (self) {
        _dataMap = [NSMutableDictionary dictionary];
        _coreDataQueue = dispatch_create_safe_queue("URLCache", DISPATCH_QUEUE_SERIAL);
    }

    return self;
}

- (void)storeCachedResponse:(NSCachedURLResponse *)cachedResponse forRequest:(NSURLRequest *)request {
    if (! [request.HTTPMethod isEqualToString:@"GET"]) {
        NSLog(@"Ignore storing request: %@", request);
        return;
    }

    NSLog(@"storing cache: %@", request.URL.absoluteString);
    dispatch_async(self.coreDataQueue, ^{
        RDRCacheEntity *cache = (RDRCacheEntity *) [NSEntityDescription insertNewObjectForEntityForName:@"CacheEntity"
                                                                                 inManagedObjectContext:self.managedObjectContext];
        cache.url = request.URL.absoluteString;
        cache.ctime = [NSDate date];
        cache.textEncodingName = cachedResponse.response.textEncodingName;
        cache.expectedContentLength = [NSNumber numberWithLongLong:cachedResponse.response.expectedContentLength];
        cache.mimeType = cachedResponse.response.MIMEType;

        [self.dataMap setObject:cachedResponse.data forKey:request.URL.absoluteString];

        NSError *error;
        if (! [cache.managedObjectContext save:&error]) {
            NSLog(@"Failed to save cache|request=%@, error=%@", request.URL.absoluteString, error);
        }
    });
}

- (NSCachedURLResponse *)cachedResponseForRequest:(NSURLRequest *)request {
    if (! [request.HTTPMethod isEqualToString:@"GET"]) {
        return nil;
    }

    __block NSURLResponse *response = nil;
    dispatch_safe_sync(self.coreDataQueue, ^{
        RDRCacheEntity *entity = [self findCacheEntityByUrl:request.URL.absoluteString];
        if (entity == nil) {
            return;
        }

        response = [[NSURLResponse alloc] initWithURL:request.URL
                                                            MIMEType:entity.mimeType
                                               expectedContentLength:[entity.expectedContentLength integerValue]
                                                    textEncodingName:entity.textEncodingName];
    });
    if (response == nil) {
        NSLog(@"cache not found: %@", request.URL.absoluteString);
        return nil;
    }

    NSData *data = [self.dataMap objectForKey:request.URL.absoluteString];
    if (data == nil) {
        NSLog(@"data not found: %@", request.URL.absoluteString);
        return nil;
    }
    NSCachedURLResponse *cachedURLResponse = [[NSCachedURLResponse alloc] initWithResponse:response data:data];

    NSLog(@"found cache for: %@", request.URL.absoluteString);
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