//
//  RDRAppDelegate.h
//  WechatReader
//
//  Created by WanZheng on 4/1/14.
//  Copyright (c) 2014 cos. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RDRArticleParser;

@interface RDRAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (nonatomic) RDRArticleParser *articleParser;

+ (RDRAppDelegate *)sharedInstance;

- (void)showBanner:(NSString *)text;

@end
