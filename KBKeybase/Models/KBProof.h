//
//  KBProof.h
//  Keybase
//
//  Created by Gabriel on 7/10/14.
//  Copyright (c) 2014 Gabriel Handford. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Mantle/Mantle.h>

typedef NS_ENUM (NSInteger, KBProofType) {
  KBProofTypeUnknown,
  KBProofTypeTwitter,
  KBProofTypeGithub,
  KBProofTypeReddit,
  KBProofTypeCoinbase,
  KBProofTypeHackerNews,
  KBProofTypeDNS,
  KBProofTypeGenericWebSite,
};

typedef NS_ENUM (NSInteger, KBProofError) {
  KBProofErrorUnknown = 0,
  KBProofErrorNoSignature = -1,
  KBProofErrorInvalidProofURL = -2,
  KBProofErrorInvalidResponseData = -3,
  KBProofErrorMissingProofText = -4,
  KBProofErrorUnrecognized = -5,
  KBProofErrorDNSLookup = -6,
};

@interface KBProof : MTLModel <MTLJSONSerializing>

@property (readonly) NSString *identifier;
@property (readonly) NSString *nameTag;
@property (readonly) NSString *displayName;
@property (readonly) KBProofType proofType;
@property (readonly) NSString *signatureId;
@property (readonly) NSString *humanURLString;
@property (readonly) NSString *serviceURLString;

@property NSDate *dateVerified;
@property NSError *verifyError;

- (NSString *)proofName;

- (BOOL)isURLStringValid;

- (NSString *)statusDescription;

@end
