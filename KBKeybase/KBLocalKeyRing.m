//
//  KBLocalKeyRing.m
//  Keybase
//
//  Created by Gabriel on 7/31/14.
//  Copyright (c) 2014 Gabriel Handford. All rights reserved.
//

#import "KBLocalKeyRing.h"

#import "KBKeychain.h"
#import "KBSigner.h"

#import <ObjectiveSugar/ObjectiveSugar.h>

@implementation KBLocalKeyRing

- (void)addPrivateKey:(KBPrivateKey *)privateKey {
  [KBKeychain saveInKeychain:privateKey name:NSStringWithFormat(@"key-%@", privateKey.keyId)];
}

- (void)lookupKeyIds:(NSArray *)keyIds capabilities:(KBKeyCapabilities)capabilities success:(void (^)(NSArray */*of id<KBKey>*/keys))success failure:(void (^)(NSError *error))failure {
  if ((capabilities & KBKeyCapabilitiesDecrypt) == 0 && (capabilities & KBKeyCapabilitiesSign) == 0) {
    success(@[]);
    return;
  }
  
  NSArray *keys = [keyIds map:^id(id keyId) {
    KBPrivateKey *privateKey = [KBKeychain loadFromKeychainForName:NSStringWithFormat(@"key-%@", keyId) ofClass:KBPrivateKey.class];
    if (!privateKey) return NSNull.null;
    return privateKey;
  }];
  success(keys);
}

- (void)verifySigners:(NSArray *)signers success:(void (^)(NSArray *verified, NSArray *failed))success failure:(void (^)(NSError *error))failure {
  // We don't verify private keys here (having them and password is verification enough)
  success(@[], signers);
}

@end
