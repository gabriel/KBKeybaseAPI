//
//  KBMe.m
//  KBKeybaseAPI
//
//  Created by Gabriel on 7/14/14.
//  Copyright (c) 2014 Gabriel Handford. All rights reserved.
//

#import "KBSessionUser.h"

#import <ObjectiveSugar/ObjectiveSugar.h>
#import <GHKit/GHKit.h>

@implementation KBSessionUser

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
  return @{
           @"identifier": @"basics.uid",
           @"userName": @"basics.username",
           @"signatures": @"sigs.lookup",
           @"followees": @"followees",
           @"KID": @"private_keys.primary.kid",
           @"keyFingerprint": @"private_keys.primary.key_fingerprint",
           @"secretKey": @"private_keys.primary.bundle",
           @"primaryEmail": @"emails.primary.email",
           };
}

+ (NSValueTransformer *)secretKeyJSONTransformer {
  return [[P3SKBValueTransformer alloc] init];
}

- (KBSignature *)signatureForIdentifier:(NSString *)identifier {
  NSDictionary *dict = _signatures[identifier];
  if (!dict) return nil;  
  return [MTLJSONAdapter modelOfClass:KBSignature.class fromJSONDictionary:dict error:nil];
}

- (NSArray *)followeeUserNames {
  return [[_followees map:^(NSDictionary *followees) {
    return [[self signatureForIdentifier:followees[@"sig_id"]] trackUserName];
  }] gh_compact];
}

//- (instancetype)initWithDictionary:(NSDictionary *)dictionaryValue error:(NSError **)error {
//  if ((self = [super initWithDictionary:dictionaryValue error:error])) {
//    
//  }
//  return self;
//}


- (NSUInteger)hash {
  return [_identifier hash];
}

- (BOOL)isEqual:(id)object {
  return ([object isKindOfClass:KBSessionUser.class] && [[object identifier] isEqualToString:_identifier]);
}

@end
