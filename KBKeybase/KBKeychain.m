//
//  KBKeychain.m
//  Keybase
//
//  Created by Gabriel on 7/10/14.
//  Copyright (c) 2014 Gabriel Handford. All rights reserved.
//

#import "KBKeychain.h"

#import <SSKeychain/SSKeychain.h>
#import <GHKit/GHKit.h>
#import <ObjectiveSugar/ObjectiveSugar.h>

#import "KBPrivateKey.h"

@implementation KBKeychain

+ (BOOL)saveInKeychain:(id)obj name:(NSString *)name {
  SSKeychainQuery *query = [[SSKeychainQuery alloc] init];
  query.service = @"Keybase";
  query.synchronizationMode = SSKeychainQuerySynchronizationModeNo; // Don't synchronize the cloud
  query.account = name;
  if ([obj isKindOfClass:[NSString class]]) {
    query.password = obj;
  } else {
    query.passwordData = [NSKeyedArchiver archivedDataWithRootObject:obj];
  }
  NSError *error = nil;
  if (![query save:&error]) {
    GHDebug(@"Failed to save in keychain: %@; %@", name, error);
    return NO;
  }
  return YES;
}

+ (id)loadFromKeychainForName:(NSString *)name ofClass:(Class)ofClass {
  SSKeychainQuery *query = [[SSKeychainQuery alloc] init];
  query.service = @"Keybase";
  query.account = name;
  if ([query fetch:nil]) {
    if (query.password && (!ofClass || [ofClass isEqual:NSString.class])) return query.password;
    if (!query.passwordData) return nil;
    @try {
      id obj = [NSKeyedUnarchiver unarchiveObjectWithData:query.passwordData];
      if (ofClass && ![[obj class] isEqual:ofClass]) return nil;
      return obj;
    } @catch (NSException *e) {
      return nil;
    }
  }
  return nil;
}

+ (void)savePrivateKey:(KBPrivateKey *)privateKey {
  NSAssert([privateKey fingerprint], @"Missing fingerprint");
  [self saveInKeychain:privateKey name:NSStringWithFormat(@"sk-%@", [privateKey fingerprint])];
}

+ (KBPrivateKey *)loadPrivateKeyWithFingerprint:(NSString *)fingerprint {
  if (!fingerprint) return nil;
  return [self loadFromKeychainForName:NSStringWithFormat(@"sk-%@", fingerprint) ofClass:KBPrivateKey.class];
}

+ (KBSession *)loadSession {
  return [KBKeychain loadFromKeychainForName:@"session-v2" ofClass:KBSession.class];
}

+ (void)saveSession:(KBSession *)session {
  [KBKeychain saveInKeychain:session name:@"session-v2"];
}

@end
