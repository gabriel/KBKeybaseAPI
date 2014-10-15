//
//  KBPrivateKey.m
//  Keybase
//
//  Created by Gabriel on 7/3/14.
//  Copyright (c) 2014 Gabriel Handford. All rights reserved.
//

#import "KBPrivateKey.h"

#import <TSTripleSec/TSTripleSec.h>

@implementation KBPrivateKey

@synthesize secretKey=_secretKey;

- (NSData *)decryptKeyWithPassword:(NSString *)password error:(NSError * __autoreleasing *)error {
  return [_secretKey decryptPrivateKeyWithPassword:password error:error];
}

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
  return @{

           @"secretKey": @"bundle", // Unserialized bundle into p3skb
           @"fingerprint": @"key_fingerprint",
           @"userName": @"username",
           };
}

+ (NSValueTransformer *)secretKeyJSONTransformer {
  return [[P3SKBValueTransformer alloc] init];
}

//- (instancetype)initWithDictionary:(NSDictionary *)dictionary error:(NSError **)error {
//  self = [super initWithDictionary:dictionary error:error];
//  if (self == nil) return nil;
//
//  return self;
//}

@end

