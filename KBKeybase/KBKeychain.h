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

+ (void)savePrivateKey:(KBPrivateKey *)privateKey;
+ (KBPrivateKey *)loadPrivateKeyWithFingerprint:(NSString *)fingerprint;

@end
