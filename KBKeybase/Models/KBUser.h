//
//  KBUser.h
//  Keybase
//
//  Created by Gabriel on 6/18/14.
//  Copyright (c) 2014 Gabriel Handford. All rights reserved.
//

#import "KBImage.h"
#import "KBProof.h"
#import "KBBitcoinAddress.h"
#import "KBPublicKey.h"
#import <Mantle/Mantle.h>


@interface KBUser : MTLModel <MTLJSONSerializing>

@property (readonly) NSString *identifier;
@property (readonly) NSString *userName;
@property (readonly) NSString *displayUserName;
@property (readonly) KBImage *image;

@property (readonly) NSString *bio;
@property (readonly) NSString *fullName;
@property (readonly) NSString *location;

@property (readonly) NSDate *dateCreated;
@property (readonly) NSDate *dateModified;

@property (readonly) NSArray */*of KBProof*/proofs;
@property (readonly) NSArray */*of KBBitcoinAdddress*/bitcoinAddresses;

@property (readonly) NSString *KID;
@property (readonly) KBPublicKey *key;

@property (readonly) NSString *lastSignatureId;

/*!
 Find proofs.
 */
- (NSArray *)proofsForType:(KBProofType)type;

- (NSString *)displayDescription;

@end
