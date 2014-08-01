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

+ (id)loadFromKeychainForName:(NSString *)name ofClass:(Class)clazz {
  SSKeychainQuery *query = [[SSKeychainQuery alloc] init];
  query.service = @"Keybase";
  query.account = name;
  if ([query fetch:nil]) {
    if (query.password && [query.password isKindOfClass:clazz]) return query.password;
    if (!query.passwordData) return nil;
    @try {
      id obj = [NSKeyedUnarchiver unarchiveObjectWithData:query.passwordData];
      if ([obj isKindOfClass:clazz]) {
        return obj;
      }
    } @catch (NSException *e) {
      return nil;
    }
  }
  return nil;
}

@end
