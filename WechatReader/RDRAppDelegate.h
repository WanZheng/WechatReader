//
//  RDRAppDelegate.h
//  WechatReader
//
//  Created by WanZheng on 4/1/14.
//  Copyright (c) 2014 cos. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RDRAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

+ (RDRAppDelegate *)sharedInstance;
+ (NSURL *)applicationDocumentsDirectory;

- (void)showBanner:(NSString *)text;

@end
