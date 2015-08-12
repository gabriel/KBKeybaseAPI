//
//  KBPGPKeyTest.m
//  KBKeybase
//
//  Created by Gabriel on 8/12/15.
//  Copyright (c) 2015 Gabriel Handford. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

#import <KBKeybase/KBKeybase.h>
#import <KBKeybase/KBPGPKey.h>

@interface KBPGPKeyTest : XCTestCase
@end

@implementation KBPGPKeyTest

- (void)testDict {
  NSError *error = nil;
  NSDictionary *dict = @{
                         @"fingerprint": @"afb10f6a5895f5b1d67851861296617a289d5c6b",
                         @"flags": @(47),
                         @"is_locked": @NO,
                         @"nbits": @(4096),
                         @"pgp_key_id": @"1296617a289d5c6b",
                         @"self_signed": @YES,
                         @"subkeys": @[@{
                                         @"flags": @(2),
                                         @"nbits": @(2048),
                                         @"pgp_key_id": @"89ae977e1bc670e5",
                                         @"timestamp": @(1406742667),
                                         @"type": @(1),
                                         }, @{
                                         @"flags": @(12),
                                         @"nbits": @(2048),
                                         @"pgp_key_id": @"d53374f55303d0ea",
                                         @"timestamp": @(1406742667),
                                         @"type": @(1),
                                       }],
                         @"timestamp": @(1406742667),
                         @"type": @(1),
                         @"userids": @[@{
                                         @"email": @"gabrielhlocal2@keybase.io",
                                         @"is_primary": @NO,
                                         @"username": @"keybase.io/gabrielhlocal2",
                                         }]
                         };

  KBPGPKey *key = [KBPGPKey PGPKeyFromDictionary:dict error:&error];

  XCTAssertNotNil(key);
}

@end
