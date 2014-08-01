//
//  KBAPIKeyRing.h
//  Keybase
//
//  Created by Gabriel on 7/23/14.
//  Copyright (c) 2014 Gabriel Handford. All rights reserved.
//

#import "KBClient.h"
#import "KBKeyRing.h"

@interface KBClientKeyRing : NSObject <KBKeyRing>

- (instancetype)initWithClient:(KBClient *)client;

@end
