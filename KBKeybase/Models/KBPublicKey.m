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

@synthesize publicKeyBundle=_publicKeyBundle, secretKey=_secretKey;

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
  return @{
           @"publicKeyBundle": @"bundle",
           @"fingerprint": @"key_fingerprint",
           @"dateModified": @"mtime",
           };
}

+ (NSValueTransformer *)dateModifiedJSONTransformer {
  return [MTLValueTransformer transformerWithBlock:^(id date) {
    return [NSDate gh_parseTimeSinceEpoch:date];
  }];
}

@end
