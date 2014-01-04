//
//  RDRArticleManager.h
//  WechatReader
//
//  Created by WanZheng on 4/1/14.
//  Copyright (c) 2014 cos. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RDRArticle.h"

@interface RDRArticleManager : NSObject
@property (nonatomic) NSMutableArray *articles;

+ (RDRArticleManager *)instance;

- (void)addArticleWithUrl:(NSString *)url;
@end
