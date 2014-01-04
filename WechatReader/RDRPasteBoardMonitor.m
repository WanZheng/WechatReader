//
//  RDRPasteBoardMonitor.m
//  WechatReader
//
//  Created by WanZheng on 4/1/14.
//  Copyright (c) 2014 cos. All rights reserved.
//

#import "RDRPasteBoardMonitor.h"
#import "RDRArticleManager.h"

@interface RDRPasteBoardMonitor()
@property (nonatomic) UIPasteboard *pasteboard;
@property (nonatomic) NSTimer *timer;
@property (nonatomic) NSString *lastUrl;
@end

@implementation RDRPasteBoardMonitor

+ (RDRPasteBoardMonitor *)instance {
    static dispatch_once_t s_token;
    static RDRPasteBoardMonitor *s_instance;
    dispatch_once(&s_token, ^{
        s_instance = [[RDRPasteBoardMonitor alloc] init];
    });

    return s_instance;
}

- (UIPasteboard *)pasteboard {
    if (_pasteboard == nil) {
        _pasteboard = [UIPasteboard generalPasteboard];
    }
    return _pasteboard;
}

- (void)start {
    NSLog(@"start monitor");

    [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        [self stop];
    }];

    self.timer = [NSTimer scheduledTimerWithTimeInterval:1
                                                  target:self
                                                selector:@selector(onTimer:)
                                                userInfo:nil
                                                 repeats:YES];
}

- (void)stop {
    NSLog(@"stop monitor");

    [self.timer invalidate];
    self.timer = nil;
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
        [[RDRArticleManager instance] addArticleWithUrl:url];
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
