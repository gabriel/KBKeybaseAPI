//
//  KBPrivateKey.h
//  Keybase
//
//  Created by Gabriel on 7/3/14.
//  Copyright (c) 2014 Gabriel Handford. All rights reserved.
//

#import "KBKey.h"
#import <Mantle/Mantle.h>

@interface KBPrivateKey : MTLModel <KBKey, MTLJSONSerializing>

@property (readonly) NSString *keyId;
@property (readonly) NSString *bundle;
@property (readonly) NSString *userName;
@property (readonly) NSString *fingerprint;
@property (readonly) KBKeyCapabilities capabilities;
- (BOOL)isPasswordProtected;

- (NSData *)publicKey;
- (NSData *)decryptPrivateKeyWithPassword:(NSString *)password error:(NSError * __autoreleasing *)error;

@end
