//
// Created by wilsonwan on 14-1-9.
//
// Copyright (c) 2013年 Tencent. All rights reserved.
//


#import "RDRPrefetchService.h"
#import "UIWebView+RDRQueryTitle.h"
#import "RDRNotifications.h"


@interface RDRPrefetchService() <UIWebViewDelegate>
@property (nonatomic) UIWebView *webView;
@property (nonatomic) NSMutableArray *urlList;
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

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (NSMutableArray *)urlList {
    if (_urlList == nil) {
        _urlList = [NSMutableArray array];
    }
    return _urlList;
}

- (UIWebView *)webView {
    if (_webView == nil) {
        _webView = [[UIWebView alloc] init];
        _webView.delegate = self;
    }
    return _webView;
}

- (void)didAddArticle:(NSNotification *)notification {
    [self.urlList addObject:notification.userInfo];

    if (self.urlList.count <= 1) {
        [self prefetchUrl:notification.userInfo];
    }
}

- (void)prefetchUrl:(NSDictionary *)userInfo {
    NSLog(@"start prefetch: %@", userInfo);
    NSString *url = [userInfo objectForKey:kKeyUrl];
    assert([url isKindOfClass:[NSString class]]);

    dispatch_async(dispatch_get_main_queue(), ^{
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[[NSURL alloc] initWithString:url]];
        request.cachePolicy = NSURLRequestReturnCacheDataElseLoad;

        [self.webView loadRequest:request];
    });
}

- (void)prefetchNextUrl {
    if (self.urlList.count <= 0) {
        return;
    }
    [self.urlList removeObjectAtIndex:0];

    if (self.urlList.count <= 0) {
        return;
    }
    [self prefetchUrl:self.urlList.firstObject];
}

#pragma mark - UIWebViewDelegate
//- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
//    return YES;
//}
//
//- (void)webViewDidStartLoad:(UIWebView *)webView {
//    NSLog(@"start prefetch");
//}
//
- (void)webViewDidFinishLoad:(UIWebView *)webView {
    NSLog(@"prefetch finished");

    if (self.urlList.count >= 1) {
        NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithDictionary:self.urlList.firstObject];
        [userInfo setObject:webView.htmlTitle forKey:kKeyTitle];

        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationDidPrefetchArticle
                                                                object:nil
                                                              userInfo:userInfo];
        });
    }

    [self prefetchNextUrl];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    NSLog(@"prefetch failed: %@", error);

    [self prefetchNextUrl];
}

@end