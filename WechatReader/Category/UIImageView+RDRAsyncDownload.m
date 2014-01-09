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
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url
                                                                    cachePolicy:NSURLRequestReturnCacheDataElseLoad
                                                                timeoutInterval:15]; // TODO: retry when fails

        [NSURLConnection sendAsynchronousRequest:request
                                           queue:[NSOperationQueue mainQueue]
                               completionHandler:^(NSURLResponse* response, NSData* data, NSError* connectionError){
                                   refSelf.contentMode = UIViewContentModeScaleAspectFill;
                                   [refSelf setImage:[UIImage imageWithData:data]];
                               }];
    });
}

@end