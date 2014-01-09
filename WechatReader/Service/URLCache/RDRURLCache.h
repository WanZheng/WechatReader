//
// Created by wilsonwan on 14-1-7.
//
// Copyright (c) 2013年 Tencent. All rights reserved.
//


#import <Foundation/Foundation.h>


@interface RDRURLCache : NSURLCache
@property (nonatomic) NSURLCache *oldSharedCache;
@end