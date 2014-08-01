//
//  KBSession.h
//  Keybase
//
//  Created by Gabriel on 7/10/14.
//  Copyright (c) 2014 Gabriel Handford. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "KBUser.h"
#import "KBSessionUser.h"

@interface KBSession : NSObject

@property (readonly, nonatomic) KBUser *user;
@property (readonly, nonatomic) KBSessionUser *sessionUser;

- (instancetype)initWithSessionUser:(KBSessionUser *)sessionUser user:(KBUser *)user;

+ (KBSession *)loadSession;
- (void)saveSession;

@end
