//
// Created by wilsonwan on 14-1-9.
//
// Copyright (c) 2013年 Tencent. All rights reserved.
//


#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface RDRCacheEntity : NSManagedObject

@property (nonatomic) NSString *url;
@property (nonatomic) NSDate *ctime;
@property (nonatomic) NSString *mimeType;
@property (nonatomic) NSString *textEncodingName;
@property (nonatomic) NSNumber *expectedContentLength;

@end