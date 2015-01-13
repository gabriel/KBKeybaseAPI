//
//  KBAPIError.h
//  Keybase
//
//  Created by Gabriel on 6/19/14.
//  Copyright (c) 2014 Gabriel Handford. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM (NSInteger, KBAPIErrorCode) {
  KBAPIErrorCodeDefault = -1,
  KBAPIErrorCodeParameterError = -2,
  
  KBAPIErrorCodeNotFound = -205, // NOT_FOUND
  
  // Server reported errors
  KBAPIErrorCodeBadSession = -99, // BAD_SESSION
  KBAPIErrorCodeInputError = -100, // INPUT_ERROR
  KBAPIErrorCodeMissingParameter = -101, // MISSING_PARAMETER
  KBAPIErrorCodeBadSignupUsernameTaken = -201, // BAD_SIGNUP_USERNAME_TAKEN
  KBAPIErrorCodeBadSignupEmailTaken = -202, // BAD_SIGNUP_EMAIL_TAKEN
  
  KBAPIErrorCodeBadLoginPassword = -300, // BAD_LOGIN_PASSWORD
  KBAPIErrorCodeBadLoginUserNotFound = -301, // BAD_LOGIN_USER_NOT_FOUND
  
  KBAPIErrorCodeKeyNotFound = -901,
};

extern NSString *const KBAPIErrorTypeKey;

typedef NS_ENUM (NSUInteger, KBAPIErrorType) {
  KBAPIErrorTypeDefault,
  KBAPIErrorTypeAlert
};

@interface KBAPIError : NSError

+ (KBAPIError *)errorWithCode:(KBAPIErrorCode)code localizedDescription:(NSString *)localizedDescription type:(KBAPIErrorType)type;

@end

#define KBErrorDefault(fmt, ...) [KBAPIError errorWithCode:KBAPIErrorCodeDefault localizedDescription:[NSString stringWithFormat:fmt, ##__VA_ARGS__] type:KBAPIErrorTypeDefault]
#define KBErrorAlert(fmt, ...) [KBAPIError errorWithCode:KBAPIErrorCodeDefault localizedDescription:[NSString stringWithFormat:fmt, ##__VA_ARGS__] type:KBAPIErrorTypeAlert]
