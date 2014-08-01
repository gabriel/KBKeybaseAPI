//
//  KBProof.h
//  Keybase
//
//  Created by Gabriel on 7/10/14.
//  Copyright (c) 2014 Gabriel Handford. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Mantle/Mantle.h>

typedef NS_ENUM (NSUInteger, KBProofType) {
  KBProofTypeUnkown = 0,
  KBProofTypeTwitter = 1,
  KBProofTypeGithub = 2,
  KBProofTypeDNS = 3,
  KBProofTypeGenericWebSite = 4,
};


@interface KBProof : MTLModel <MTLJSONSerializing>

@property (readonly) NSString *nameTag;
@property (readonly) KBProofType proofType;

- (NSString *)displayDescription;

@end
