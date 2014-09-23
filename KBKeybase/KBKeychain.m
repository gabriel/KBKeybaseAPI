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
#import <NAChloride/NAChloride.h>

#define SERVICE (@"co.tihkal.KBKeychain")

@implementation KBKeychain

+ (BOOL)saveInKeychain:(id)obj name:(NSString *)name {
  SSKeychainQuery *query = [[SSKeychainQuery alloc] init];
  query.service = SERVICE;
  query.synchronizationMode = SSKeychainQuerySynchronizationModeNo; // Don't synchronize the cloud
  query.account = name;
  
  NSError *error = nil;
  if (!obj) {
    if (![query deleteItem:&error]) {
      if (error.code != errSecItemNotFound) {
        GHDebug(@"Failed to delete keychain: %@; %@", name, error);
      }
      return NO;
    }
    return YES;
  }
  
  if ([obj isKindOfClass:[NSString class]]) {
    query.password = obj;
  } else {
    query.passwordData = [NSKeyedArchiver archivedDataWithRootObject:obj];
  }
  if (![query save:&error]) {
    GHDebug(@"Failed to save in keychain: %@; %@", name, error);
    return NO;
  }
  return YES;
}

+ (id)loadFromKeychainForName:(NSString *)name ofClass:(Class)ofClass {
  SSKeychainQuery *query = [[SSKeychainQuery alloc] init];
  query.service = SERVICE;
  query.account = name;
  if ([query fetch:nil]) {
    if (query.password && (!ofClass || [ofClass isEqual:NSString.class])) return query.password;
    if (!query.passwordData) return nil;
    @try {
      id obj = [NSKeyedUnarchiver unarchiveObjectWithData:query.passwordData];
      if (ofClass && ![obj isKindOfClass:ofClass]) return nil;
      return obj;
    } @catch (NSException *e) {
      return nil;
    }
  }
  return nil;
}

+ (BOOL)hasPasswordHash {
  return !![self loadFromKeychainForName:@"passwordHash" ofClass:NSData.class];
}

+ (void)setPasswordHashForPassword:(NSData *)password salt:(NSData *)salt success:(dispatch_block_t)success failure:(void (^)(NSError *error))failure {
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    if (!salt) {
      failure(GHNSError(-1, @"No salt value"));
      return;
    }
    NSError *error = nil;
    NSData *scrypted = [NAScrypt scrypt:password salt:salt N:32768U r:8 p:1 length:64 error:&error];
    if (!scrypted) {
      failure(error);
      return;
    }
    [self saveInKeychain:salt name:@"salt"];
    [self saveInKeychain:scrypted name:@"passwordHash"];
    if (success) {
      dispatch_async(dispatch_get_main_queue(), ^{
        success();
      });
    }
  });
}

+ (void)passwordHashForPassword:(NSData *)password salt:(NSData *)salt completion:(void (^)(NSData *hashed))completion {
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    NSData *scrypted = [NAScrypt scrypt:password salt:salt N:32768U r:8 p:1 length:64 error:nil];
    dispatch_async(dispatch_get_main_queue(), ^{
      completion(scrypted);
    });
  });
}

+ (void)checkPasswordHashForPassword:(NSData *)password completion:(void (^)(BOOL match))completion {
  NSData *salt = [self loadFromKeychainForName:@"salt" ofClass:NSData.class];
  if (!salt) {
    completion(NO);
    return;
  }
  NSData *existingHash = [self loadFromKeychainForName:@"passwordHash" ofClass:NSData.class];
  if (!existingHash) {
    completion(NO);
    return;
  }
  
  [self passwordHashForPassword:password salt:salt completion:^(NSData *hashed) {
    BOOL match = [existingHash isEqualToData:hashed];
    completion(match);
  }];
}

@end
