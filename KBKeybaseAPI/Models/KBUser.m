//
//  KBUser.m
//  KBKeybaseAPI
//
//  Created by Gabriel on 6/18/14.
//  Copyright (c) 2014 Gabriel Handford. All rights reserved.
//

#import "KBUser.h"
#import "KBPublicKey.h"
#import "KBProof.h"
#import "KBSignature.h"
#import "KBBitcoinAddress.h"

#import <ObjectiveSugar/ObjectiveSugar.h>
#import <GHKit/GHNSDate+Formatters.h>

@implementation KBUser

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
  return @{
           @"identifier": @"id",
           @"userName": @"basics.username",
           @"displayUserName": @"basics.username", // Duplicating for test scaffolding
           @"image": @"pictures.primary",
           @"fullName": @"profile.full_name",
           @"bio": @"profile.bio",
           @"location": @"profile.location",
           @"dateCreated": @"basics.ctime",
           //@"dateModified": NSNull.null,
           
           @"bitcoinAddresses": @"cryptocurrency_addresses.bitcoin",
           @"proofs": @"proofs_summary.all",
           
           @"KID": @"public_keys.primary.kid",
           @"key": @"public_keys.primary",
           @"lastSignatureId": @"sigs.last.sig_id",
           };
}

+ (NSValueTransformer *)imageJSONTransformer {
  return [MTLJSONAdapter dictionaryTransformerWithModelClass:KBImage.class];
}

+ (NSValueTransformer *)keyJSONTransformer {
  return [MTLJSONAdapter dictionaryTransformerWithModelClass:KBPublicKey.class];
}

+ (NSValueTransformer *)proofsJSONTransformer {
  return [MTLJSONAdapter arrayTransformerWithModelClass:KBProof.class];
}

+ (NSValueTransformer *)bitcoinAddressesJSONTransformer {
  return [MTLJSONAdapter arrayTransformerWithModelClass:KBBitcoinAddress.class];
}

+ (NSValueTransformer *)dateCreatedJSONTransformer {
  return [MTLValueTransformer transformerUsingForwardBlock:^(NSDate *date, BOOL *success, NSError **error) {
    return [NSDate gh_parseTimeSinceEpoch:date];
  }];
}

//+ (NSValueTransformer *)dateModifiedJSONTransformer {
//  return [MTLValueTransformer transformerWithBlock:^(id date) {
//    return [NSDate gh_parseTimeSinceEpoch:date];
//  }];
//}

- (NSArray *)proofsForType:(KBProofType)type {
  return [_proofs select:^BOOL(KBProof *proof) { return (proof.proofType == type); }];
}

- (NSString *)displayDescription {
  if (_fullName) return _fullName;
  if (_userName) return _userName;
  return @"Unknown"; // Shouldn't ever reach here
}

- (NSUInteger)hash {
  return [_identifier hash];
}

- (BOOL)isEqual:(id)object {
  return ([object isKindOfClass:KBUser.class] && [[object identifier] isEqualToString:_identifier]);
}

@end
