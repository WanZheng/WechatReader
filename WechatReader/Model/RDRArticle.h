//
//  RDRArticle.h
//  WechatReader
//
//  Created by WanZheng on 4/1/14.
//  Copyright (c) 2014 cos. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RDRArticle : NSObject
@property (nonatomic) NSString *url;
@property (nonatomic) NSString *title;
@property (nonatomic) NSString *author;
@property (nonatomic) NSString *imageUrl;

- (id)initWithUrl:(NSString *)url;

@end
