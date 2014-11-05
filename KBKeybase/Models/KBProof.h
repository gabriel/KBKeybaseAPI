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


@interface KBProof : MTLModel <MTLJSONSerializing>

@property (readonly) NSString *identifier;
@property (readonly) NSString *nameTag;
@property (readonly) KBProofType proofType;
@property (readonly) NSString *signatureId;
@property (readonly) NSString *proofURLString;
@property (readonly) NSString *humanURLString;

- (NSString *)displayDescription;

- (NSString *)URLString;

@end
