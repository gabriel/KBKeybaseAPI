//
//  KBPrivateKey.m
//  Keybase
//
//  Created by Gabriel on 7/3/14.
//  Copyright (c) 2014 Gabriel Handford. All rights reserved.
//

#import "KBPrivateKey.h"

#import <TSTripleSec/TSTripleSec.h>

@interface P3SKBValueTransformer : NSValueTransformer
@end

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
