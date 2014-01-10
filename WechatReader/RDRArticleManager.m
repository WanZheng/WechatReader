//
// Created by WanZheng on 10/1/14.
// Copyright (c) 2014 cos. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "RDRArticleManager.h"
#import "RDRNotifications.h"
#import "RDRArticle.h"


@interface RDRArticleManager()
@property (nonatomic) NSManagedObjectContext *managedObjectContext;
@end

@implementation RDRArticleManager
- (id)initWithManagedObjectContext:(NSManagedObjectContext *)managedObjectContext {
    self = [super init];
    if (self) {
        _managedObjectContext = managedObjectContext;
        [self observerNotifications];
    }

    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)observerNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(urlDidFetchTitle:)
                                                 name:kNotificationDidPrefetchArticle
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didParseArticle:)
                                                 name:kNotificationDidParseArticle
                                               object:nil];
}

- (void)urlDidFetchTitle:(NSNotification *)notification {
    NSDictionary *userInfo = notification.userInfo;
    RDRArticle *article = [self getArticleFromNotificationInfo:userInfo];

    if (article.title.length > 0) {
        return;
    }

    article.title = [userInfo objectForKey:kKeyTitle];

    [self saveArticle:article];
}

- (void)didParseArticle:(NSNotification *)notification {
    NSDictionary *userInfo = notification.userInfo;
    RDRArticle *article = [self getArticleFromNotificationInfo:userInfo];

    article.title = [userInfo objectForKey:kKeyTitle];
    article.imageUrl = [userInfo objectForKey:kKeyImageUrl];

    [self saveArticle:article];
}

#pragma mark - Utils
- (RDRArticle *)getArticleFromNotificationInfo:(NSDictionary *)userInfo {
    NSManagedObjectID *objectID = [userInfo objectForKey:kKeyObjectID];
    assert([objectID isKindOfClass:[NSManagedObjectID class]]);

    RDRArticle *article = (RDRArticle *) [self.managedObjectContext objectRegisteredForID:objectID];
    assert(article);

    return article;
}

- (NSError *)saveArticle:(RDRArticle *)article {
    NSError *error;
    if (! [article.managedObjectContext save:&error]) {
        NSLog(@"Failed to save article: %@, error=%@", article, error);
        return error;
    }
    return nil;
}

@end