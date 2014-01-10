//
//  RDRPasteBoardMonitor.h
//  WechatReader
//
//  Created by WanZheng on 4/1/14.
//  Copyright (c) 2014 cos. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface RDRPasteBoardMonitor : NSObject
@property (nonatomic) NSManagedObjectContext *managedObjectContext;

- (void)startBgMonitor;
- (void)stopBgMonitor;
- (BOOL)checkImmediately;

@end
