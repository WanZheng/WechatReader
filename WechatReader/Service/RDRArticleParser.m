//
// Created by WanZheng on 6/1/14.
// Copyright (c) 2014 cos. All rights reserved.
//

#import "RDRArticleParser.h"
#import "RDRArticle.h"
#import "RDRConfig.h"


@interface RDRArticleParser()
@end

@implementation RDRArticleParser

- (void)parseArticle:(RDRArticle *)article {
    assert(article.url);

    NSURL *url = [[NSURL alloc] initWithString:CONFIG_PARSING_SERVER_URL];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"POST";

    NSDictionary *params = [NSDictionary dictionaryWithObject:article.url forKey:@"url"];
    NSError *error;
    NSData *json = [NSJSONSerialization dataWithJSONObject:params
                                                   options:0
                                                     error:&error];
    if (json.length <= 0 || error != nil) {
        NSLog(@"failed to setup post params: %@", article.url);
        abort();
    }
    [request setHTTPBody:json];

    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse* response, NSData* data, NSError* connectionError){
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
                               if (title.length > 0) {
                                   article.title = title;
                               }
                               if (imageUrl.length > 0) {
                                   article.imageUrl = imageUrl;
                               }

                               error1 = nil;
                               if (! [article.managedObjectContext save:&error1]) {
                                   NSLog(@"Failed to save article=%@, error=%@", article, error1);
                                   abort();
                               }
                           }];
}

@end