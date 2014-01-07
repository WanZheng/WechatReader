//
//  WechatReaderTests.m
//  WechatReaderTests
//
//  Created by WanZheng on 4/1/14.
//  Copyright (c) 2014 cos. All rights reserved.
//

#import <XCTest/XCTest.h>

@interface WechatReaderTests : XCTestCase

@end

@implementation WechatReaderTests

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

- (void)testJson {
    NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                @"this is the title", @"Title",
                                @"http://www.img.com", @"ImageUrl",
            nil];
    NSData *data = [NSJSONSerialization dataWithJSONObject:dictionary options:0 error:nil];
    NSString *s = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"json=%@", s);

    s = @"{\"Title\":\"Dhara Dhevi （原泰国清迈文华东方酒店）冲冠促销\",\"ImageUrl\":\"http://mmbiz.qpic.cn/mmbiz/icBHicicdZObIPSSGEfZ7Gmcg1IUoUT4zarP5GWeVAesGzcj8ZScpP2Wc8WMpPPfg97icPicQmL0dvHz9wQaBLvqDlw/0\"}";
    data = [s dataUsingEncoding:NSUTF8StringEncoding];

    dictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    NSLog(@"dict = %@", dictionary);
}

//- (void)testExample
//{
//    XCTFail(@"No implementation for \"%s\"", __PRETTY_FUNCTION__);
//}

@end
