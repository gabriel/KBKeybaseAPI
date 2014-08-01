//
//  KBSignature.h
//  Keybase
//
//  Created by Gabriel on 7/14/14.
//  Copyright (c) 2014 Gabriel Handford. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Mantle/Mantle.h>

typedef NS_ENUM (NSUInteger, KBSignatureType) {
  KBSignatureTypeUnkown,
  KBSignatureTypeTrack = 1,
};

@interface KBSignature : MTLModel <MTLJSONSerializing>

@property (readonly) NSString *identifier;

- (KBSignatureType)signatureType;

#pragma mark Track

- (NSString *)trackUserName;

@end
