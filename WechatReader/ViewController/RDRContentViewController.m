//
//  RDRContentViewController.m
//  WechatReader
//
//  Created by WanZheng on 4/1/14.
//  Copyright (c) 2014 cos. All rights reserved.
//

#import "RDRContentViewController.h"
#import "UIWebView+RDRQueryTitle.h"

@interface RDRContentViewController () <UIWebViewDelegate>
@property (nonatomic) UIWebView *webView;
@end

@implementation RDRContentViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.webView = [[UIWebView alloc] init];
    self.webView.delegate = self;
    self.webView.frame = self.view.bounds;
    [self.view addSubview:self.webView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:self.article.url]];
    request.cachePolicy = NSURLRequestReturnCacheDataElseLoad;
    [self.webView loadRequest:request];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - webview delegate
- (void)webViewDidStartLoad:(UIWebView *)webView {
    self.title = @"loading";
    NSLog(@"loading %@", self.article.url);
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    self.title = webView.htmlTitle;

    if (self.article.title.length <= 0) {
        self.article.title = self.title;

        NSError *error;
        if (! [self.article.managedObjectContext save:&error]) {
            /*
               Replace this implementation with code to handle the error appropriately.

               abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
             */
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    // TODO:
    NSLog(@"load error: %@", error);
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    NSLog(@"webview|start load:%@, navigationType=%d", request.URL.absoluteString, navigationType);
    return YES;
}

@end
