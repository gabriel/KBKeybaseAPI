//
//  KBUser.h
//  Keybase
//
//  Created by Gabriel on 6/18/14.
//  Copyright (c) 2014 Gabriel Handford. All rights reserved.
//

#import "KBImage.h"
#import "KBKey.h"
#import "KBProof.h"
#import "KBBitcoinAddress.h"
#import <Mantle/Mantle.h>


@interface KBUser : MTLModel <MTLJSONSerializing>

@property (readonly) NSString *identifier;
@property (readonly) NSString *userName;
@property (readonly) KBImage *primaryImage;

@property (readonly) NSString *primaryEmail;

@property (readonly) NSString *bio;
@property (readonly) NSString *fullName;
@property (readonly) NSString *location;

@property (readonly) NSArray */*of KBProof*/proofs;
@property (readonly) NSArray */*of KBBitcoinAdddress*/bitcoinAddresses;

/*!
 Verify the key belongs to this user.
 */
- (BOOL)verifyKey:(id<KBKey>)key;

/*!
 Find proofs.
 */
- (NSArray *)proofsForType:(KBProofType)type;

@end