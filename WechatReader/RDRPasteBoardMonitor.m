//
//  RDRPasteBoardMonitor.m
//  WechatReader
//
//  Created by WanZheng on 4/1/14.
//  Copyright (c) 2014 cos. All rights reserved.
//

#import "RDRPasteBoardMonitor.h"
#import "RDRArticle.h"

@interface RDRPasteBoardMonitor()
@property (nonatomic) UIPasteboard *pasteboard;
@property (nonatomic) NSTimer *timer;
@property (nonatomic) NSString *lastUrl;
@end

@implementation RDRPasteBoardMonitor

- (UIPasteboard *)pasteboard {
    if (_pasteboard == nil) {
        _pasteboard = [UIPasteboard generalPasteboard];
    }
    return _pasteboard;
}

- (void)startBgMonitor {
    NSLog(@"start monitor");

    [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        [self stopBgMonitor];
    }];

    self.timer = [NSTimer scheduledTimerWithTimeInterval:1
                                                  target:self
                                                selector:@selector(onTimer:)
                                                userInfo:nil
                                                 repeats:YES];
}

- (void)stopBgMonitor {
    NSLog(@"stop monitor");

    [self.timer invalidate];
    self.timer = nil;
}

- (RDRArticle *)findArticleByUrl:(NSString *)url {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];

    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Article" inManagedObjectContext:self.managedObjectContext];
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

- (void)checkImmediately {
    //Check what is on the paste board
    if (! [self.pasteboard containsPasteboardTypes:[NSArray arrayWithObjects:@"public.utf8-plain-text", @"public.text", nil]]){
        return;
    }
    
    NSString *url = self.pasteboard.string;
    if ([url isEqualToString:self.lastUrl]) {
        return;
    }
    
    NSLog(@"message: %@", url);

    if ([self isValidUrl:url]) {
        RDRArticle *article = [self findArticleByUrl:url];

        if (article == nil) {
            article = (RDRArticle *)[NSEntityDescription insertNewObjectForEntityForName:@"Article"
                                                                  inManagedObjectContext:self.managedObjectContext];
            article.url = url;
        }

        article.ctime = [NSDate date];

        NSError *error;
        if (! [self.managedObjectContext save:&error]) {
            /*
               Replace this implementation with code to handle the error appropriately.

               abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
             */
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
    
    self.lastUrl = url;
}

- (void)onTimer:(NSTimer *)timer {
    NSLog(@"on timer");

    [self checkImmediately];
    
    if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateBackground){
        NSTimeInterval timeLeft = [UIApplication sharedApplication].backgroundTimeRemaining;
        NSLog(@"Background time remaining: %.0f seconds (~%d mins)", timeLeft, (int)timeLeft / 60);
    }
}

- (BOOL)isValidUrl:(NSString *)url {
    if (![url hasPrefix:@"http://"] && ![url hasPrefix:@"https://"]) {
        return NO;
    }
    
#if 1
    if ([url rangeOfString:@"mp.weixin.qq.com/"].length > 0) {
        return YES;
    }
    
    return NO;
#else
    return YES;
#endif
}

@end
