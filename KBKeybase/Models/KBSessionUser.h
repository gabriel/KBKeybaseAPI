//
//  KBMe.h
//  Keybase
//
//  Created by Gabriel on 7/14/14.
//  Copyright (c) 2014 Gabriel Handford. All rights reserved.
//

#import "KBSignature.h"
#import <Mantle/Mantle.h>

/*!
 Logged in user.
 */
@interface KBSessionUser : MTLModel <MTLJSONSerializing>

@property (readonly) NSString *identifier;
@property (readonly) NSString *userName;
@property (readonly) NSArray */*of KBSignature*/signatures;
@property (readonly) NSString *keyFingerprint;

- (KBSignature *)signatureForIdentifier:(NSString *)identifier;

- (NSArray *)followeeUserNames;

- (NSString *)keyId;

@end
