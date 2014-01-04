//
//  RDRArticle.m
//  WechatReader
//
//  Created by WanZheng on 4/1/14.
//  Copyright (c) 2014 cos. All rights reserved.
//

#import "RDRArticle.h"

@implementation RDRArticle

- (id)initWithUrl:(NSString *)url {
    self = [super init];
    if (self) {
        _url = url;
    }
    return self;
}

- (NSString *)description {
    NSMutableString *description = [NSMutableString stringWithFormat:@"<%@: ", NSStringFromClass([self class])];
    [description appendFormat:@"title=%@", self.title];
    [description appendString:@">"];
    return description;
}


- (NSString *)title {
    // TODO:
    return _url;
}

@end
