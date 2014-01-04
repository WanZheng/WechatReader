//
//  RDRArticleManager.m
//  WechatReader
//
//  Created by WanZheng on 4/1/14.
//  Copyright (c) 2014 cos. All rights reserved.
//

#import "RDRArticleManager.h"

@interface RDRArticleManager()
@end

@implementation RDRArticleManager
- (id)init {
    self = [super init];
    if (self) {
        _articles = [NSMutableArray array];
    }
    return self;
}

+ (RDRArticleManager *)instance {
    static dispatch_once_t s_token;
    static RDRArticleManager *s_instance;
    dispatch_once(&s_token, ^{
        s_instance = [[RDRArticleManager alloc] init];
    });
    
    return s_instance;
}

- (void)addArticleWithUrl:(NSString *)url {
    RDRArticle *article = [[RDRArticle alloc] initWithUrl:url];
    [self addArticle:article];
}

- (void)addArticle:(RDRArticle *)article {
    NSLog(@"add article: %@", article);
    
    NSIndexSet *iset = [NSIndexSet indexSetWithIndex:[self.articles count]];
    
    NSString *key = @"articles";
    
    // TODO: 可以自动发出KVO吗?
    [self willChange:NSKeyValueChangeInsertion valuesAtIndexes:iset forKey:key];
    [self.articles addObject:article];
    [self didChange:NSKeyValueChangeInsertion valuesAtIndexes:iset forKey:key];
}

@end
