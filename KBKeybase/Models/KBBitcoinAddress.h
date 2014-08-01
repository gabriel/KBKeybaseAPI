//
//  KBBitcoinAddress.h
//  Keybase
//
//  Created by Gabriel on 7/10/14.
//  Copyright (c) 2014 Gabriel Handford. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Mantle/Mantle.h>

@interface KBBitcoinAddress : MTLModel <MTLJSONSerializing>

@property (readonly) NSString *address;
@property (readonly) NSString *signatureId;

@end
