//
//  RDRPasteBoardMonitor.h
//  WechatReader
//
//  Created by WanZheng on 4/1/14.
//  Copyright (c) 2014 cos. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RDRPasteBoardMonitor : NSObject
+ (RDRPasteBoardMonitor *)instance;

- (void)start;
- (void)stop;
- (void)checkImmediately;

@end
