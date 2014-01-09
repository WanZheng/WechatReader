//
// Created by wilsonwan on 14-1-9.
//
// Copyright (c) 2013年 Tencent. All rights reserved.
//


#import "RDRPrefetchService.h"
#import "RDRPasteBoardMonitor.h"


@interface RDRPrefetchService()
@property (nonatomic) UIWebView *webView;
@end

@implementation RDRPrefetchService
- (id)init {
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(didAddArticle:)
                                                     name:kNotificationDidInsertArticle
                                                   object:nil];
    }

    return self;
}

- (void)didAddArticle:(NSNotification *)notification {
    NSString *url = [notification.userInfo objectForKey:kKeyUrl];
    assert([url isKindOfClass:[NSString class]]);

    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[[NSURL alloc] initWithString:url]];
    request.cachePolicy = NSURLRequestReturnCacheDataElseLoad;

    self.webView = [[UIWebView alloc] init];
    [self.webView loadRequest:request];
}

@end