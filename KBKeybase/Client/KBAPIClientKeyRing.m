//
//  KBClientKeyRing.m
//  Keybase
//
//  Created by Gabriel on 7/23/14.
//  Copyright (c) 2014 Gabriel Handford. All rights reserved.
//

#import "KBAPIClientKeyRing.h"
#import "KBKey.h"
#import "KBKeyRing.h"

#import <ObjectiveSugar/ObjectiveSugar.h>

@interface KBAPIClientKeyRing ()
@property KBAPIClient *client;
@end

@implementation KBAPIClientKeyRing

- (instancetype)initWithClient:(KBAPIClient *)client {
  if ((self = [super init])) {
    _client = client;
  }
  return self;
}

- (void)lookupPGPKeyIds:(NSArray *)PGPKeyIds capabilities:(KBKeyCapabilities)capabilities success:(void (^)(NSArray *keyBundles))success failure:(void (^)(NSError *error))failure {
    [_client keysForPGPKeyIds:PGPKeyIds capabilities:capabilities success:^(NSArray *keys) {
    success(keys);
  } failure:failure];
}

@end
