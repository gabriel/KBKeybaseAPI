//
//  KBUser.m
//  Keybase
//
//  Created by Gabriel on 6/18/14.
//  Copyright (c) 2014 Gabriel Handford. All rights reserved.
//

#import "KBUser.h"
#import "KBPublicKey.h"
#import "KBProof.h"
#import "KBBitcoinAddress.h"

#import <ObjectiveSugar/ObjectiveSugar.h>

@implementation KBUser

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
  return @{
           @"identifier": @"id",
           @"userName": @"basics.username",
           @"primaryImage": @"pictures.primary",
           @"fullName": @"profile.full_name",
           @"bio": @"profile.bio",
           @"location": @"profile.location",
           
           @"primaryEmail": @"emails.primary.email",
           @"bitcoinAddresses": @"cryptocurrency_addresses.bitcoin",
           @"proofs": @"proofs_summary.all",
           };
}

+ (NSValueTransformer *)primaryImageJSONTransformer {
  return [NSValueTransformer mtl_JSONDictionaryTransformerWithModelClass:KBImage.class];
}

+ (NSValueTransformer *)proofsJSONTransformer {
  return [NSValueTransformer mtl_JSONArrayTransformerWithModelClass:KBProof.class];
}

+ (NSValueTransformer *)bitcoinAddressesJSONTransformer {
  return [NSValueTransformer mtl_JSONArrayTransformerWithModelClass:KBBitcoinAddress.class];
}

- (NSArray *)proofsForType:(KBProofType)type {  
  return [_proofs select:^BOOL(KBProof *proof) { return (proof.proofType == type); }];
}

- (BOOL)verifyKey:(id<KBKey>)key {
  // TODO: Key verification
  return YES;
}

- (NSUInteger)hash {
  return [_identifier hash];
}

- (BOOL)isEqual:(id)object {
  return ([object isKindOfClass:KBUser.class] && [[object identifier] isEqualToString:_identifier]);
}

@end