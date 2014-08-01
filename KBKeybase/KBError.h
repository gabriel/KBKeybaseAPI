//
//  KBAPIError.h
//  Keybase
//
//  Created by Gabriel on 6/19/14.
//  Copyright (c) 2014 Gabriel Handford. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM (NSUInteger, KBAPIErrorCode) {
  KBErrorCodeDefault = -1,
  KBErrorCodeParameterError = -2,
  
  // Server reported errors
  KBErrorCodeBadSession = -99, // BAD_SESSION
  KBErrorCodeInputError = -100, // INPUT_ERROR
  KBErrorCodeMissingParameter = -101, // MISSING_PARAMETER
  KBErrorCodeBadSignupUsernameTaken = -201, // BAD_SIGNUP_USERNAME_TAKEN
  KBErrorCodeBadSignupEmailTaken = -202, // BAD_SIGNUP_EMAIL_TAKEN
  
  KBErrorCodeBadLoginPassword = -300, // BAD_LOGIN_PASSWORD
  KBErrorCodeBadLoginUserNotFound = -301, // BAD_LOGIN_USER_NOT_FOUND
};

extern NSString *const KBErrorTypeKey;

typedef NS_ENUM (NSUInteger, KBErrorType) {
  KBErrorTypeDefault,
  KBErrorTypeAlert
};

@interface KBError : NSError

+ (KBError *)errorWithCode:(KBAPIErrorCode)code localizedDescription:(NSString *)localizedDescription type:(KBErrorType)type;

@end

#define KBErrorDefault(__DESC__) [KBError errorWithCode:KBErrorCodeDefault localizedDescription:(__DESC__) type:KBErrorTypeDefault]
#define KBErrorAlert(__DESC__) [KBError errorWithCode:KBErrorCodeDefault localizedDescription:(__DESC__) type:KBErrorTypeAlert]
