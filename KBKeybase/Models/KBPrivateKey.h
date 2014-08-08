//
//  KBPrivateKey.h
//  Keybase
//
//  Created by Gabriel on 7/3/14.
//  Copyright (c) 2014 Gabriel Handford. All rights reserved.
//

#import "KBKey.h"
#import <Mantle/Mantle.h>
#import <TSTripleSec/P3SKB.h>

@interface KBPrivateKey : MTLModel <KBKey, MTLJSONSerializing>

@property (readonly) NSString *bundle;
@property (readonly) P3SKB *secret;
@property (readonly) NSString *userName;
@property (readonly) NSString *fingerprint;
- (BOOL)isSecret;

- (instancetype)initWithBundle:(NSData *)bundle fingerprint:(NSString *)fingerprint userName:(NSString *)userName;

@end
