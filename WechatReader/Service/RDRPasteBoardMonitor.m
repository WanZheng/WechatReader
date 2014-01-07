//
//  RDRPasteBoardMonitor.m
//  WechatReader
//
//  Created by WanZheng on 4/1/14.
//  Copyright (c) 2014 cos. All rights reserved.
//

#import "RDRPasteBoardMonitor.h"
#import "RDRConfig.h"
#import "RDRArticle.h"
#import "RDRAppDelegate.h"
#import "RDRArticleParser.h"

@interface RDRPasteBoardMonitor()
@property (nonatomic) UIPasteboard *pasteboard;
@property (nonatomic) NSTimer *timer;
@property (nonatomic) NSInteger changeCount;
@property (nonatomic) UIBackgroundTaskIdentifier bgTaskId;
@end

@implementation RDRPasteBoardMonitor

- (UIPasteboard *)pasteboard {
    if (_pasteboard == nil) {
        _pasteboard = [UIPasteboard generalPasteboard];
        _changeCount = -1;
    }
    return _pasteboard;
}

- (void)startBgMonitor {
    NSLog(@"start monitor");

    self.bgTaskId = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        [self stopTimer];
    }];

    self.timer = [NSTimer scheduledTimerWithTimeInterval:1
                                                  target:self
                                                selector:@selector(onTimer:)
                                                userInfo:nil
                                                 repeats:YES];
}

- (void)stopTimer {
    [self.timer invalidate];
    self.timer = nil;
}

- (void)stopBgMonitor {
    NSLog(@"stop monitor");

    [self stopTimer];

    [[UIApplication sharedApplication] endBackgroundTask:self.bgTaskId];
    self.bgTaskId = UIBackgroundTaskInvalid;
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

- (RDRArticle *)insertNewArticleWithUrl:(NSString *)url {
    RDRArticle *article = (RDRArticle *)[NSEntityDescription insertNewObjectForEntityForName:@"Article"
                                                          inManagedObjectContext:self.managedObjectContext];
    article.url = url;

    NSData *data = [NSURLConnection sendSynchronousRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url relativeToURL:nil]] returningResponse:nil error:nil];
    NSLog(@"data = %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
    return article;
}

- (BOOL)checkImmediately {
    if (self.pasteboard.changeCount == self.changeCount) {
        return NO;
    }
    self.changeCount = self.pasteboard.changeCount;

    //Check what is on the paste board
    if (! [self.pasteboard containsPasteboardTypes:[NSArray arrayWithObjects:@"public.utf8-plain-text", @"public.text", nil]]){
        return NO;
    }
    
    NSString *url = self.pasteboard.string;

    NSLog(@"message: %@", url);

    BOOL saved = NO;
    if ([self isValidUrl:url]) {
        RDRArticle *article = [self findArticleByUrl:url];

        if (article == nil) {
            article = [self insertNewArticleWithUrl:url];
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

        saved = YES;

        [[RDRAppDelegate sharedInstance].articleParser parseArticle:article];
    }
    
    return saved;
}

- (void)onTimer:(NSTimer *)timer {
    NSLog(@"on timer");

    BOOL saved = [self checkImmediately];
    if (saved) {
        [[RDRAppDelegate sharedInstance] showBanner:@"文章已收藏"];
    }
    
    if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateBackground){
        NSTimeInterval timeLeft = [UIApplication sharedApplication].backgroundTimeRemaining;
        NSLog(@"Background time remaining: %.0f seconds (~%d mins)", timeLeft, (int)timeLeft / 60);

        if (timeLeft < 5) {
            [[RDRAppDelegate sharedInstance] showBanner:@"即将退出，如需要请重新打开程序。"];
            [self stopBgMonitor];
        }
    }
}

- (BOOL)isValidUrl:(NSString *)url {
    if (![url hasPrefix:@"http://"] && ![url hasPrefix:@"https://"]) {
        return NO;
    }
    
#ifndef CONFIG_NOT_WEIXIN_ONLY
    if ([url rangeOfString:@"mp.weixin.qq.com/"].length > 0) {
        return YES;
    }
    
    return NO;
#else
    return YES;
#endif
}

@end
