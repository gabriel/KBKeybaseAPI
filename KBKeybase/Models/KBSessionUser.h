//
//  KBMe.h
//  Keybase
//
//  Created by Gabriel on 7/14/14.
//  Copyright (c) 2014 Gabriel Handford. All rights reserved.
//

#import "KBSignature.h"
#import <Mantle/Mantle.h>
#import <TSTripleSec/TSTripleSec.h>

/*!
 Logged in user.
 */
@interface KBSessionUser : MTLModel <MTLJSONSerializing>

@property (readonly) NSString *identifier;
@property (readonly) NSString *userName;
@property (readonly) NSDictionary */*sig_id -> dict*/signatures;
@property (readonly) NSArray *followees;
@property (readonly) NSString *primaryEmail;

// Primary private key
@property (readonly) NSString *KID;
@property (readonly) NSString *keyFingerprint;
@property (readonly) P3SKB *secretKey;

//- (KBSignature *)signatureForIdentifier:(NSString *)identifier;

- (NSArray *)followeeUserNames;

@end
