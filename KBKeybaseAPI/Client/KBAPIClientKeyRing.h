//
//  KBClientKeyRing.h
//  KBKeybaseAPI
//
//  Created by Gabriel on 7/23/14.
//  Copyright (c) 2014 Gabriel Handford. All rights reserved.
//

#import "KBAPIClient.h"
#import "KBKeyRing.h"

@interface KBAPIClientKeyRing : NSObject <KBKeyRing>

- (instancetype)initWithClient:(KBAPIClient *)client;

@end
