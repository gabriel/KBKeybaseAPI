//
//  KBClientKeyRing.m
//  Keybase
//
//  Created by Gabriel on 7/23/14.
//  Copyright (c) 2014 Gabriel Handford. All rights reserved.
//

#import "KBClientKeyRing.h"
#import "KBKey.h"

#import <KBCrypto/KBCrypto.h>
#import <ObjectiveSugar/ObjectiveSugar.h>

@interface KBClientKeyRing ()
@property KBClient *client;
@property NSMutableDictionary *keys;
@end

@implementation KBClientKeyRing

- (instancetype)initWithClient:(KBClient *)client {
  if ((self = [super init])) {
    _client = client;
    _keys = [NSMutableDictionary dictionary];
  }
  return self;
}

- (void)lookupPGPKeyIds:(NSArray *)PGPKeyIds capabilities:(KBKeyCapabilities)capabilities success:(void (^)(NSArray *keys))success failure:(void (^)(NSError *error))failure {
  [_client keysForPGPKeyIds:PGPKeyIds capabilities:capabilities success:^(NSArray *keys) {
    
    // Cache keys for verification step
    for (id<KBKey> key in keys) {
      _keys[[[key fingerprint] lowercaseString]] = key;
    }
    
    success(keys);
  } failure:failure];
}

- (void)verifyKeyFingerprints:(NSArray *)keyFingerprints success:(void (^)(NSArray *))success failure:(void (^)(NSError *))failure {
  for (NSString *keyFingerprint in keyFingerprints) {
    id<KBKey> key = _keys[keyFingerprint];
    if (key) {
      
    }
  }
  
  NSArray *signers = [keyFingerprints map:^id(NSString *keyFingerprint) {
    return [[KBSigner alloc] initWithKeyFingerprint:keyFingerprint verified:NO];
  }];
  success(signers);
}

@end
