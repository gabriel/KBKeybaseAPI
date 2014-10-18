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

#define SERVICE (@"me.rel.KeyPop")
#define SALT_NAME (@"salt-20141017")
#define PASSWORD_HASH_NAME (@"passwordHash-20141017")

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

+ (void)clear {
  NSArray *secItemClasses = @[(__bridge id)kSecClassGenericPassword,
                              (__bridge id)kSecClassInternetPassword,
                              (__bridge id)kSecClassCertificate,
                              (__bridge id)kSecClassKey,
                              (__bridge id)kSecClassIdentity];
  for (id secItemClass in secItemClasses) {
    NSDictionary *spec = @{(__bridge id)kSecClass: secItemClass};
    SecItemDelete((__bridge CFDictionaryRef)spec);
  }
}

+ (BOOL)hasPasswordHash {
  return !![self loadFromKeychainForName:PASSWORD_HASH_NAME ofClass:NSData.class];
}

+ (void)derivePasswordFromPassword:(NSString *)password salt:(NSData *)salt completion:(void (^)(NSString *derivedPassword))completion {
  [KBKeychain passwordHashForPassword:password salt:salt completion:^(NSData *hashed) {
    NSString *derivedPassword = [[hashed base64EncodedStringWithOptions:0] substringToIndex:20];
    completion(derivedPassword);
  }];
}

+ (void)setPasswordHashForPassword:(NSString *)password salt:(NSData *)salt success:(void (^)(NSData *hashed))success failure:(void (^)(NSError *error))failure {
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    if (!salt) {
      failure(GHNSError(-1, @"No salt value"));
      return;
    }
    NSError *error = nil;
    NSData *scrypted = [NAScrypt scrypt:[password dataUsingEncoding:NSUTF8StringEncoding] salt:salt N:32768U r:8 p:1 length:64 error:&error];
    if (!scrypted) {
      failure(error);
      return;
    }
    [self saveInKeychain:salt name:SALT_NAME];
    [self saveInKeychain:scrypted name:PASSWORD_HASH_NAME];
    if (success) {
      dispatch_async(dispatch_get_main_queue(), ^{
        success(scrypted);
      });
    }
  });
}

+ (void)passwordHashForPassword:(NSString *)password salt:(NSData *)salt completion:(void (^)(NSData *hashed))completion {
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    NSData *scrypted = [NAScrypt scrypt:[password dataUsingEncoding:NSUTF8StringEncoding] salt:salt N:32768U r:8 p:1 length:64 error:nil];
    dispatch_async(dispatch_get_main_queue(), ^{
      completion(scrypted);
    });
  });
}

+ (void)checkPasswordHashForPassword:(NSString *)password completion:(void (^)(BOOL match, NSData *hashed))completion {
  NSData *salt = [self loadFromKeychainForName:SALT_NAME ofClass:NSData.class];
  if (!salt) {
    completion(NO, nil);
    return;
  }
  NSData *existingHash = [self loadFromKeychainForName:PASSWORD_HASH_NAME ofClass:NSData.class];
  if (!existingHash) {
    completion(NO, nil);
    return;
  }
  
  [self passwordHashForPassword:password salt:salt completion:^(NSData *hashed) {
    BOOL match = [existingHash isEqualToData:hashed];
    completion(match, hashed);
  }];
}

@end
