//
//  RDRArticle.m
//  WechatReader
//
//  Created by WanZheng on 4/1/14.
//  Copyright (c) 2014 cos. All rights reserved.
//

#import "RDRArticle.h"

@implementation RDRArticle

@dynamic url, title, author, imageUrl, ctime;

- (NSString *)description {
    NSMutableString *description = [NSMutableString stringWithFormat:@"<%@: ", NSStringFromClass([self class])];
    [description appendFormat:@"title=%@", self.title];
    [description appendString:@">"];
    return description;
}

@end
