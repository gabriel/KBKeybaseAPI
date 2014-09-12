//
//  KBPublicKey.m
//  Keybase
//
//  Created by Gabriel on 6/26/14.
//  Copyright (c) 2014 Gabriel Handford. All rights reserved.
//

#import "KBPublicKey.h"

#import <GHKit/GHKit.h>

@implementation KBPublicKey

//- (instancetype)initWithBundle:(NSString *)bundle fingerprint:(NSString *)fingerprint userName:(NSString *)userName {
//  if ((self = [super init])) {
//    _bundle = bundle;
//    _fingerprint = fingerprint;
//    _userName = userName;
//  }
//  return self;
//}

- (NSString *)displayDescription {
  return NSStringFromKBKeyFingerprint(_fingerprint);
}

- (BOOL)isSecret {
  return NO;
}

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
  return @{
           @"bundle": @"bundle",
           @"fingerprint": @"key_fingerprint",
           @"dateCreated": @"ctime",
           };
}

+ (NSValueTransformer *)dateCreatedJSONTransformer {
  return [MTLValueTransformer transformerWithBlock:^(id date) {
    return [NSDate gh_parseTimeSinceEpoch:date];
  }];
}


//- (BOOL)verifyUserName:(NSString *)userName {
//  @try {
//    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:[_signatureJSON dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
//    NSString *keyFingerprint = dict[@"body"][@"key"][@"fingerprint"];
//    NSString *userName = dict[@"body"][@"key"][@"username"];
//    return [keyFingerprint isEqual:_fingerprint] && [userName isEqual:_userName];
//  } @catch(NSException *e) {
//    return NO;
//  }
//}

@end
