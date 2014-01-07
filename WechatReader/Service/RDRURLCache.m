//
// Created by wilsonwan on 14-1-7.
//
// Copyright (c) 2013年 Tencent. All rights reserved.
//


#import "RDRURLCache.h"


@implementation RDRURLCache
- (NSUInteger)memoryCapacity {
    NSUInteger memoryCapacity = [self.oldSharedCache memoryCapacity];
    NSLog(@"memoryCapacity = %u", memoryCapacity);
    return memoryCapacity;
}

- (NSUInteger)diskCapacity {
    NSUInteger diskCapacity = [self.oldSharedCache diskCapacity];
    NSLog(@"diskCapacity = %u", diskCapacity);
    return diskCapacity;
}

- (NSCachedURLResponse *)cachedResponseForRequest:(NSURLRequest *)request {
    if ([request.URL.absoluteString isEqualToString:@"http://mp.weixin.qq.com/mp/appmsg/show?__biz=MjM5Njg4NzY2MQ==&appmsgid=10013662&itemidx=2&sign=e02e06baf2534a24eb383faeae3add44#wechat_redirect"]) {
        NSData *data = [@"<html>Hello</html>" dataUsingEncoding:NSUTF8StringEncoding];
        NSURLResponse *urlResponse = [[NSURLResponse alloc] initWithURL:request.URL
                                                               MIMEType:@"text/html"
                                                  expectedContentLength:data.length
                                                       textEncodingName:nil];
        NSCachedURLResponse *cachedURLResponse = [[NSCachedURLResponse alloc] initWithResponse:urlResponse data:data];
        return cachedURLResponse;
    }

    NSCachedURLResponse *response = [self.oldSharedCache cachedResponseForRequest:request];
    NSLog(@"cache response for request(%@) = %@", request.URL.absoluteString, response);
    return response;
}

@end