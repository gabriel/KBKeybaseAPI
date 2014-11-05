//
//  KBSignatureProof.h
//  KBKeybase
//
//  Created by Gabriel on 11/3/14.
//  Copyright (c) 2014 Gabriel Handford. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <Mantle/Mantle.h>

@interface KBSignatureProof : MTLModel <MTLJSONSerializing>

@property (readonly) NSString *signatureId;
@property (readonly) NSString *proofId;
@property (readonly) NSString *proofText;

@end
