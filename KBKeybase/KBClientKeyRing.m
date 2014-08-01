//
//  KBAPIKeyRing.m
//  Keybase
//
//  Created by Gabriel on 7/23/14.
//  Copyright (c) 2014 Gabriel Handford. All rights reserved.
//

#import "KBClientKeyRing.h"
#import "KBKeychain.h"
#import "KBSigner.h"

#import <ObjectiveSugar/ObjectiveSugar.h>

@interface KBClientKeyRing ()
@property KBClient *client;
@end


@implementation KBClientKeyRing

- (instancetype)initWithClient:(KBClient *)client {
  if ((self = [super init])) {
    _client = client;
  }
  return self;
}

- (void)lookupKeyIds:(NSArray *)keyIds capabilities:(KBKeyCapabilities)capabilities success:(void (^)(NSArray *keys))success failure:(void (^)(NSError *error))failure {
  [_client keysForKeyIds:keyIds capabilities:capabilities success:success failure:failure];
}

- (void)verifySigners:(NSArray *)signers success:(void (^)(NSArray *verified, NSArray *failed))success failure:(void (^)(NSError *error))failure {
  NSArray *userNames = [signers valueForKeyPath:@"userName"];
  NSArray *keyIds = [signers valueForKey:@"keyId"];
  
  [_client usersForUserNames:userNames success:^(NSArray *users) {
    [_client keysForKeyIds:keyIds capabilities:KBKeyCapabilitiesVerify success:^(NSArray *keys) {
      NSMutableArray *verified = [NSMutableArray array];
      NSMutableArray *failed = [NSMutableArray array];
      
      for (KBSigner *signer in signers) {
        KBUser *user = [users detect:^BOOL(KBUser *user) { return [user.userName isEqual:signer.userName]; }];
        id<KBKey> key = [keys detect:^BOOL(id<KBKey> key) { return [key.keyId isEqual:signer.keyId]; }];
        
        if ([user verifyKey:key]) {
          [verified addObject:signer];
        } else {
          [failed addObject:signer];
        }
      }
      
      success(verified, failed);
    } failure:failure];
  } failure:failure];
}

@end
