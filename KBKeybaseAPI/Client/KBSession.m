//
//  KBSession.m
//  KBKeybaseAPI
//
//  Created by Gabriel on 7/10/14.
//  Copyright (c) 2014 Gabriel Handford. All rights reserved.
//

#import "KBSession.h"

NSString *const KBSessionDidChangeNotification = @"KBSessionDidChangeNotification";

@implementation KBSession

- (instancetype)initWithSessionUser:(KBSessionUser *)sessionUser user:(KBUser *)user {
  if ((self = [super init])) {
    _sessionUser = sessionUser;
    _user = user;
  }
  return self;
}

- (NSString *)userNameOrEmail {
  if (_sessionUser.userName) return _sessionUser.userName;
  return _sessionUser.primaryEmail;
}

#pragma mark NSCoding

+ (BOOL)supportsSecureCoding { return YES; }

- (id)initWithCoder:(NSCoder *)decoder {
  if ((self = [self init])) {
    _sessionUser = [decoder decodeObjectOfClass:KBSessionUser.class forKey:@"sessionUser"];
    _user = [decoder decodeObjectOfClass:KBUser.class forKey:@"user"];
  }
  return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
  [encoder encodeObject:_sessionUser forKey:@"sessionUser"];
  [encoder encodeObject:_user forKey:@"user"];
}

@end
