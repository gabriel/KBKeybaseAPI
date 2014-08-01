//
//  KBLocalKeyRing.h
//  Keybase
//
//  Created by Gabriel on 7/31/14.
//  Copyright (c) 2014 Gabriel Handford. All rights reserved.
//

#import "KBKeyRing.h"
#import "KBPrivateKey.h"

@interface KBLocalKeyRing : NSObject <KBKeyRing>

- (void)addPrivateKey:(KBPrivateKey *)privateKey;

@end
