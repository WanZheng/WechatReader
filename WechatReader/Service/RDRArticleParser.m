//
// Created by WanZheng on 6/1/14.
// Copyright (c) 2014 cos. All rights reserved.
//

#import "RDRArticleParser.h"
#import "RDRArticle.h"
#import "RDRNotifications.h"


@interface RDRArticleParser()
@end

@implementation RDRArticleParser
- (id)init {
    self = [super init];
    if (self) {
        [self observerNotifications];
    }

    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)observerNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didInsertArticle:)
                                                 name:kNotificationDidInsertArticle
                                               object:nil];
}

- (void)didInsertArticle:(NSNotification *)notification {
    NSDictionary *userInfo = notification.userInfo;
    NSManagedObjectID *objectID = [userInfo objectForKey:kKeyObjectID];
    assert([objectID isKindOfClass:[NSManagedObjectID class]]);
    NSString *url = [userInfo objectForKey:kKeyUrl];
    assert([url isKindOfClass:[NSString class]]);

    NSURL *serverUrl;
#ifdef CONFIG_PARSING_SERVER_URL
    serverUrl = [[NSURL alloc] initWithString:CONFIG_PARSING_SERVER_URL];
#else
    return;
#endif
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:serverUrl];
    request.HTTPMethod = @"POST";

    NSDictionary *params = [NSDictionary dictionaryWithObject:url forKey:@"url"];
    NSError *error;
    NSData *json = [NSJSONSerialization dataWithJSONObject:params
                                                   options:0
                                                     error:&error];
    if (json.length <= 0 || error != nil) {
        NSLog(@"failed to setup post params: %@", url);
        abort();
    }
    [request setHTTPBody:json];


    void (^completionHandler)(NSURLResponse*, NSData*, NSError*) = ^(NSURLResponse* response, NSData* data, NSError* connectionError){
        if (connectionError) {
            NSLog(@"connection error: %@", connectionError);
            return;
        }

        NSError *error1;
        NSDictionary *result = [NSJSONSerialization JSONObjectWithData:data
                                                               options:0
                                                                 error:&error1];
        if (! [result isKindOfClass:[NSDictionary class]]) {
            NSLog(@"Failed to decode, data='%@', error=%@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding], error1);
            return;
        }

        NSString *title = [result objectForKey:@"Title"];
        NSString *imageUrl = [result objectForKey:@"ImageUrl"];

        NSMutableDictionary *articleInfo = [NSMutableDictionary dictionaryWithDictionary:userInfo];
        [articleInfo setObject:title forKey:kKeyTitle];
        [articleInfo setObject:imageUrl forKey:kKeyImageUrl];
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationDidParseArticle
                                                            object:nil
                                                          userInfo:articleInfo];
    };

    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:completionHandler];
}

@end