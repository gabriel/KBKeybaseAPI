//
//  KBSignature.m
//  Keybase
//
//  Created by Gabriel on 7/14/14.
//  Copyright (c) 2014 Gabriel Handford. All rights reserved.
//

#import "KBSignature.h"

#import <GHKit/GHKit.h>

@interface KBSignature ()
@property NSDictionary *payload;
@property NSString *signatureArmored;
@end

@implementation KBSignature

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
  return @{
           @"identifier": @"sig_id",
           @"payload": @"payload_json",
           @"signatureArmored": @"sig",
           };
}

- (KBSignatureType)signatureType {
  NSString *typeString = [[_payload gh_objectMaybeNilForKey:@"body"] gh_objectMaybeNilForKey:@"type"];
  NSInteger typeVersion = [[_payload gh_objectMaybeNilForKey:@"body"] gh_integerForKey:@"version"];
  if ([typeString isEqualToString:@"track"] && typeVersion == 1) return KBSignatureTypeTrack;
  return KBSignatureTypeUnkown;
}

+ (NSValueTransformer *)payloadJSONTransformer {
  return [MTLValueTransformer transformerWithBlock:^id(NSString *payloadJSON) {
    NSData *data = [payloadJSON dataUsingEncoding:NSUTF8StringEncoding];
    return [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
  }];
}

#pragma mark Track

- (NSString *)trackUserName {
  return [[[[_payload gh_objectMaybeNilForKey:@"body"] gh_objectMaybeNilForKey:@"track"] gh_objectMaybeNilForKey:@"basics"] gh_objectMaybeNilForKey:@"username"];
}

#pragma mark -

@end
