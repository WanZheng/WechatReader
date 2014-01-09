//
//  PrefetchTests.m
//  WechatReader
//
//  Created by WilsonWan on 14-1-9.
//  Copyright (c) 2014年 cos. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "RDRPasteBoardMonitor.h"

@interface PrefetchTests : XCTestCase

@end

@implementation PrefetchTests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testMultiTasks
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationDidInsertArticle
                                                        object:nil
                                                      userInfo:@{kKeyUrl: @"http://www.baidu.com"}];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationDidInsertArticle
                                                        object:nil
                                                      userInfo:@{kKeyUrl: @"http://www.google.com"}];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationDidInsertArticle
                                                        object:nil
                                                      userInfo:@{kKeyUrl: @"http://www.sina.com"}];

    [[NSRunLoop currentRunLoop] run]; // TODO: 如何检查测试结果?

}

@end
