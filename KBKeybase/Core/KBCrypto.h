//
//  KBCrypto.h
//  KBKeybase
//
//  Created by Gabriel on 1/7/15.
//  Copyright (c) 2015 Gabriel Handford. All rights reserved.
//

#import "KBKey.h"
#import "KBPGPMessage.h"
#import "KBKeyRing.h"

typedef void (^KBCyptoCompletionBlock)(NSError *error);
typedef void (^KBCyptoErrorBlock)(NSError *error);
typedef void (^KBCryptoUnboxBlock)(KBPGPMessage *message);

@protocol KBCrypto
- (void)verifyArmored:(NSString *)armored success:(KBCryptoUnboxBlock)success failure:(KBCyptoErrorBlock)failure;
@end