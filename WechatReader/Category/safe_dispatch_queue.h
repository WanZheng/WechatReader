//
// Created by wilsonwan on 14-1-9.
//
// Copyright (c) 2013年 Tencent. All rights reserved.
//


#import <Foundation/Foundation.h>

extern dispatch_queue_t dispatch_create_safe_queue(const char *label, dispatch_queue_attr_t attr);

extern void dispatch_safe_sync(dispatch_queue_t queue, dispatch_block_t block);

