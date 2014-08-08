//
//  KBPublicKey.h
//  Keybase
//
//  Created by Gabriel on 6/26/14.
//  Copyright (c) 2014 Gabriel Handford. All rights reserved.
//

#import "KBKey.h"
#import <Mantle/Mantle.h>

@interface KBPublicKey : MTLModel <KBKey, MTLJSONSerializing>

@property (readonly) NSString *bundle;
@property (readonly) NSString *userName;
@property (readonly) NSString *fingerprint;
- (BOOL)isSecret;

- (instancetype)initWithBundle:(NSString *)bundle fingerprint:(NSString *)fingerprint userName:(NSString *)userName;

@end
