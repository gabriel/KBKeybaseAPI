//
//  KBMe.m
//  Keybase
//
//  Created by Gabriel on 7/14/14.
//  Copyright (c) 2014 Gabriel Handford. All rights reserved.
//

#import "KBSessionUser.h"
#import "KBKey.h"

#import <ObjectiveSugar/ObjectiveSugar.h>
#import <GHKit/GHKit.h>

@interface KBSessionUser ()
@property NSArray *followees;
@end

@implementation KBSessionUser

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
  return @{
           @"identifier": @"basics.uid",
           @"userName": @"basics.username",
           @"signatures": @"sigs.all",
           @"followees": @"followees",
           @"keyFingerprint": @"private_keys.primary.key_fingerprint",
           };
}

+ (NSValueTransformer *)signaturesJSONTransformer {
  return [NSValueTransformer mtl_JSONArrayTransformerWithModelClass:KBSignature.class];
}

- (NSString *)keyId {
  return KBKeyIdFromFingerprint(_keyFingerprint);
}

- (KBSignature *)signatureForIdentifier:(NSString *)identifier {
  return [_signatures detect:^BOOL(KBSignature *signature) { return [signature.identifier isEqual:identifier]; }];
}

- (NSArray *)followeeUserNames {
  return [[_followees map:^(NSDictionary *followees) {
    return [[self signatureForIdentifier:followees[@"sig_id"]] trackUserName];
  }] gh_compact];
}

- (NSUInteger)hash {
  return [_identifier hash];
}

- (BOOL)isEqual:(id)object {
  return ([object isKindOfClass:KBSessionUser.class] && [[object identifier] isEqualToString:_identifier]);
}

@end
