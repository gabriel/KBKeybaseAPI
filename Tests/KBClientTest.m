//
//  KBClientTest.m
//  KBKeybase
//
//  Created by Gabriel on 7/15/15.
//  Copyright (c) 2015 Gabriel Handford. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

#import <KBKeybase/KBKeybase.h>

@interface KBClientTest : XCTestCase
@end

@implementation KBClientTest

- (void)testLogin {
  XCTestExpectation *expectation = [self expectationWithDescription:@"Login"];

  KBAPIClient *client = [[KBAPIClient alloc] initWithAPIHost:KBAPIKeybaseIOHost crypto:nil];
  [client logInWithEmailOrUserName:@"gbrl24" password:@"toomanysecrets" success:^(KBSession *session) {
    [client nextSequence:^(NSNumber *sequenceNumber, NSString *previousBlockHash) {

      [expectation fulfill];

    } failure:^(NSError *error) {
      XCTFail(@"%@", error);
    }];
  } failure:^(NSError *error) {
    XCTFail(@"%@", error);
  }];

  [self waitForExpectationsWithTimeout:10.0 handler:^(NSError *error) {
    if (error) XCTFail();
  }];
}

@end
