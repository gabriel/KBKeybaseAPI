//
//  KBPrivateKey.m
//  Keybase
//
//  Created by Gabriel on 7/3/14.
//  Copyright (c) 2014 Gabriel Handford. All rights reserved.
//

#import "KBPrivateKey.h"

#import <TSTripleSec/TSTripleSec.h>

@interface KBPrivateKey ()
@property P3SKB *secretKey;
@end

@interface P3SKBValueTransformer : NSValueTransformer
@end

@implementation KBPrivateKey

- (NSString *)keyId {
  return KBKeyIdFromFingerprint(_fingerprint);
}

- (NSString *)displayDescription {
  return KBKeyDisplayDescription(_fingerprint);
}

- (NSData *)publicKey {
  return _secretKey.publicKey;
}

- (NSData *)decryptPrivateKeyWithPassword:(NSString *)password error:(NSError * __autoreleasing *)error {
  return [_secretKey decryptPrivateKeyWithPassword:password error:error];
}

- (BOOL)isPasswordProtected {
  return YES;
}

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
  return @{
           @"bundle": @"bundle", // Store the original bundle value
           @"secretKey": @"bundle", // Unserialized bundle into p3skb
           @"fingerprint": @"key_fingerprint",
           @"userName": @"username",
           };
}

+ (NSValueTransformer *)secretKeyJSONTransformer {
  return [[P3SKBValueTransformer alloc] init];
}

@end


@implementation P3SKBValueTransformer
          
+ (Class)transformedValueClass {
  return [P3SKB class];
}

+ (BOOL)allowsReverseTransformation {
  return YES;
}

- (id)transformedValue:(id)value {
  NSData *data = [[NSData alloc] initWithBase64EncodedData:value options:0];
  return [P3SKB P3SKBFromData:data error:nil];
}

- (id)reverseTransformedValue:(id)value {
  return [[value data] base64EncodedStringWithOptions:0];
}

@end
