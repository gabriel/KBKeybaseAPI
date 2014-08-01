//
//  KBPublicKey.m
//  Keybase
//
//  Created by Gabriel on 6/26/14.
//  Copyright (c) 2014 Gabriel Handford. All rights reserved.
//

#import "KBPublicKey.h"

@implementation KBPublicKey

- (NSString *)keyId {
  return KBKeyIdFromFingerprint(_fingerprint);
}

- (NSString *)displayDescription {
  return KBKeyDisplayDescription(_fingerprint);
}

- (BOOL)isPasswordProtected {
  return NO;
}

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
  return @{
           @"bundle": @"bundle",
           @"fingerprint": @"key_fingerprint",
           @"userName": @"username",
           };
}

@end
