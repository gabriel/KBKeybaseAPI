//
//  KBResponseSerializer.m
//  Keybase
//
//  Created by Gabriel on 6/19/14.
//  Copyright (c) 2014 Gabriel Handford. All rights reserved.
//

#import "KBResponseSerializer.h"

#import "KBError.h"

#import <GHKit/GHKit.h>

@implementation KBResponseSerializer

- (id)responseObjectForResponse:(NSURLResponse *)response data:(NSData *)data error:(NSError *__autoreleasing *)error {
  id JSONObject = [super responseObjectForResponse:response data:data error:error];
  
  //GHDebug(@"Response: %@", JSONObject);
  if (!JSONObject) return nil;
  
  NSDictionary *status = [JSONObject gh_objectForKeyOrNSNull:@"status"];
  NSNumber *statusCode = [status gh_objectForKeyOrNSNull:@"code"];
  if (!statusCode || [statusCode integerValue] != 0) {
    KBAPIErrorCode errorCode = KBErrorCodeDefault;
    
    NSString *localizedDescription = status[@"desc"];
    
    NSString *errorCodeString = status[@"name"];
    KBErrorType errorType = KBErrorTypeDefault;
    if ([errorCodeString isEqualToString:@"INPUT_ERROR"]) {
      errorCode = KBErrorCodeInputError;
    } else if ([errorCodeString isEqualToString:@"NOT_FOUND"]) {
      errorCode = KBErrorCodeNotFound;
    } else if ([errorCodeString isEqualToString:@"MISSING_PARAMETER"]) {
      errorCode = KBErrorCodeMissingParameter;
    } else if ([errorCodeString isEqualToString:@"BAD_SESSION"]) {
      errorCode = KBErrorCodeBadSession;
    } else if ([errorCodeString isEqualToString:@"BAD_SIGNUP_USERNAME_TAKEN"]) {
      errorCode = KBErrorCodeBadSignupUsernameTaken;
      errorType = KBErrorTypeAlert;
    } else if ([errorCodeString isEqualToString:@"BAD_SIGNUP_EMAIL_TAKEN"]) {
      errorCode = KBErrorCodeBadSignupEmailTaken;
      errorType = KBErrorTypeAlert;
    } else if ([errorCodeString isEqualToString:@"BAD_LOGIN_PASSWORD"]) {
      errorCode = KBErrorCodeBadLoginPassword;
      errorType = KBErrorTypeAlert;
    } else if ([errorCodeString isEqualToString:@"BAD_LOGIN_USER_NOT_FOUND"]) {
      errorCode = KBErrorCodeBadLoginUserNotFound;
      errorType = KBErrorTypeAlert;
    }
    
    if (!localizedDescription) localizedDescription = @"Unknown error";
      
    NSError *kbError = [KBError errorWithCode:errorCode localizedDescription:localizedDescription type:errorType];
    (*error) = kbError;
  }
  
  NSString *CSRFToken = [JSONObject gh_objectMaybeNilForKey:@"csrf_token" ofClass:[NSString class]];
  if (CSRFToken) {
    [self.delegate responseSerializer:self didUpdateCSRFToken:CSRFToken];
  }

  return JSONObject;
}

@end
