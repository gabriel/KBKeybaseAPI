//
//  KBPrivateKey.h
//  KBKeybaseAPI
//
//  Created by Gabriel on 7/3/14.
//  Copyright (c) 2014 Gabriel Handford. All rights reserved.
//

#import <Mantle/Mantle.h>
#import <TSTripleSec/P3SKB.h>
#import "KBKey.h"

@interface KBPrivateKey : MTLModel <KBKey, MTLJSONSerializing>

@property (readonly) NSString *publicKeyBundle;
@property (readonly) NSString *fingerprint;
@property (nonatomic) P3SKB *secretKey;
@property (readonly) NSString *userName;

@end
