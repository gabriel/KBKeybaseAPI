//
//  KBPublicKey.h
//  Keybase
//
//  Created by Gabriel on 6/26/14.
//  Copyright (c) 2014 Gabriel Handford. All rights reserved.
//

#import "KBKey.h"
#import <Mantle/Mantle.h>

@interface KBPublicKey : MTLModel <KBKey, MTLJSONSerializing>

@property (readonly) NSString *keyId;
@property (readonly) NSString *bundle;
@property (readonly) NSString *userName;
@property (readonly) NSString *fingerprint;
@property (readonly) KBKeyCapabilities capabilities;
- (BOOL)isPasswordProtected;

@end
