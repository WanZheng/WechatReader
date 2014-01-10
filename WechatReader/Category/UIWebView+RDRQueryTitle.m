//
// Created by wilsonwan on 14-1-10.
//
// Copyright (c) 2013年 Tencent. All rights reserved.
//


#import "UIWebView+RDRQueryTitle.h"


@implementation UIWebView (RDRQueryTitle)
- (NSString *)htmlTitle {
    return [self stringByEvaluatingJavaScriptFromString:@"document.title"];
}

@end