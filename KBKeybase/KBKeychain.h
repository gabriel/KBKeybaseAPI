//
//  KBKeychain.h
//  Keybase
//
//  Created by Gabriel on 7/10/14.
//  Copyright (c) 2014 Gabriel Handford. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "KBPrivateKey.h"

/*!
 Keychain wrapper. Don't store anything in here unencrypted. We don't trust anything not even the keychain.
 */
@interface KBKeychain : NSObject

+ (BOOL)saveInKeychain:(id)obj name:(NSString *)name;
+ (id)loadFromKeychainForName:(NSString *)name ofClass:(Class)ofClass;

+ (BOOL)hasPasswordHash;
+ (void)setPasswordHashForPassword:(NSData *)password salt:(NSData *)salt success:(dispatch_block_t)success failure:(void (^)(NSError *error))failure;
+ (void)checkPasswordHashForPassword:(NSData *)password completion:(void (^)(BOOL match))completion;

+ (void)passwordHashForPassword:(NSData *)password salt:(NSData *)salt completion:(void (^)(NSData *hashed))completion;

@end
