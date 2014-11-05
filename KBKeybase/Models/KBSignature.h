//
//  KBSignature.h
//  Keybase
//
//  Created by Gabriel on 7/14/14.
//  Copyright (c) 2014 Gabriel Handford. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Mantle/Mantle.h>

typedef NS_ENUM (NSInteger, KBSignatureType) {
  KBSignatureTypeUnkown = 0,
  KBSignatureTypeTrack,
  KBSignatureTypeRevoke,
  KBSignatureTypeWebServiceBinding,
  KBSignatureTypeCryptocurrency,
};

typedef NS_ENUM (NSInteger, KBSignatureError) {
  KBSignatureErrorUnknown = 0,
  KBSignatureErrorInvalidSequenceNumber = -1,
  KBSignatureErrorInvalidSignature = -2,
  KBSignatureErrorInvalidPayloadHash = -3,
  KBSignatureErrorInvalidPreviousPayloadHash = -4,
  KBSignatureErrorInvalidKeyFingerprint = -5,
};

#define KBSignatureError(CODE, MESSAGE) [NSError errorWithDomain:@"KBSignature" code:CODE userInfo:@{NSLocalizedDescriptionKey:MESSAGE}]

@interface KBSignature : MTLModel <MTLJSONSerializing>

@property (readonly) NSString *identifier;
@property (readonly) NSNumber *sequenceNumber;
@property (readonly) NSDictionary *payload;
@property (readonly) NSString *payloadJSONString;
@property (readonly) NSString *signatureArmored;
@property (readonly) NSString *payloadHash;
@property (readonly) NSString *previousPayloadHash;

- (KBSignatureType)signatureType;

- (NSString *)keyUserName;
- (NSString *)keyFingerprint;

- (NSString *)descriptionForType;

- (NSString *)trackUserName;
- (NSString *)revokeSignatureId;
- (NSDictionary *)service;
- (NSDictionary *)cryptocurrency;

@end
