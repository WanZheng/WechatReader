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
    NSCachedURLResponse *response = [self.oldSharedCache cachedResponseForRequest:request];
    NSLog(@"cache response for request(%@) = %@", request.URL.absoluteString, response);
    return response;
}

@end