//
// Created by wilsonwan on 14-1-7.
//
// Copyright (c) 2013年 Tencent. All rights reserved.
//


#import "UIImageView+RDRAsyncDownload.h"


@implementation UIImageView (RDRAsyncDownload)

- (void)setImageWithURL:(NSURL *)url {
    __weak UIImageView *refSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSData *imageData = [NSData dataWithContentsOfURL:url];
        dispatch_async(dispatch_get_main_queue(), ^{
            refSelf.contentMode = UIViewContentModeScaleAspectFill;
            [refSelf setImage:[UIImage imageWithData:imageData]];
        });
    });
}

@end