//
//  KBPublicKey.h
//  KBKeybaseAPI
//
//  Created by Gabriel on 6/26/14.
//  Copyright (c) 2014 Gabriel Handford. All rights reserved.
//

#import <Mantle/Mantle.h>

#import "KBKey.h"

@interface KBPublicKey : MTLModel <KBKey, MTLJSONSerializing>

@property (readonly) NSString *publicKeyBundle;
@property (readonly) NSString *fingerprint;
@property (readonly) NSDate *dateModified;

@end
