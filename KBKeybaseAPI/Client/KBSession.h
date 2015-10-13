//
//  KBSession.h
//  KBKeybaseAPI
//
//  Created by Gabriel on 7/10/14.
//  Copyright (c) 2014 Gabriel Handford. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "KBUser.h"
#import "KBSessionUser.h"

extern NSString *const KBSessionDidChangeNotification;

@class KBSession;

typedef void (^KBSessionAddBlock)(KBSession *session, NSString *password);

@interface KBSession : NSObject

@property (readonly) KBUser *user;
@property (readonly) KBSessionUser *sessionUser;

- (instancetype)initWithSessionUser:(KBSessionUser *)sessionUser user:(KBUser *)user;

- (NSString *)userNameOrEmail;

@end
