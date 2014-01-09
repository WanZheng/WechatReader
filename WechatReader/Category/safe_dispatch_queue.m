//
// Created by wilsonwan on 14-1-9.
//
// Copyright (c) 2013年 Tencent. All rights reserved.
//


#import "safe_dispatch_queue.h"

static const char *QUEUE_KEY = "QUEUE_KEY";

dispatch_queue_t dispatch_create_safe_queue(const char *label, dispatch_queue_attr_t attr) {
    dispatch_queue_t queue = dispatch_queue_create(label, attr);
    void *context = (__bridge void *)queue;
    dispatch_queue_set_specific(queue, QUEUE_KEY, context, nil);
    return queue;
}

void dispatch_safe_sync(dispatch_queue_t queue, dispatch_block_t block) {
    void *context = (__bridge void *)queue;
    if (dispatch_get_specific(QUEUE_KEY) == context) {
        block();
    }else{
        dispatch_sync(queue, block);
    }
}
