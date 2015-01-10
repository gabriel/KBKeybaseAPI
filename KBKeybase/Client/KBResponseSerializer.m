//
//  KBResponseSerializer.m
//  Keybase
//
//  Created by Gabriel on 6/19/14.
//  Copyright (c) 2014 Gabriel Handford. All rights reserved.
//

#import "KBResponseSerializer.h"

#import "KBAPIError.h"

#import <GHKit/GHKit.h>

@implementation KBResponseSerializer

- (id)responseObjectForResponse:(NSURLResponse *)response data:(NSData *)data error:(NSError *__autoreleasing *)error {
  id JSONObject = [super responseObjectForResponse:response data:data error:error];
  
  //GHDebug(@"Response: %@", JSONObject);
  if (!JSONObject) return nil;
  
  NSDictionary *status = [JSONObject gh_objectForKeyOrNSNull:@"status"];
  NSNumber *statusCode = [status gh_objectForKeyOrNSNull:@"code"];
  if (!statusCode || [statusCode integerValue] != 0) {
    KBAPIErrorCode errorCode = KBAPIErrorCodeDefault;
    
    NSString *localizedDescription = status[@"desc"];
    
    NSString *errorCodeString = status[@"name"];
    KBAPIErrorType errorType = KBAPIErrorTypeDefault;
    if ([errorCodeString isEqualToString:@"INPUT_ERROR"]) {
      errorCode = KBAPIErrorCodeInputError;
    } else if ([errorCodeString isEqualToString:@"NOT_FOUND"]) {
      errorCode = KBAPIErrorCodeNotFound;
    } else if ([errorCodeString isEqualToString:@"KEY_NOT_FOUND"]) {
      errorCode = KBAPIErrorCodeKeyNotFound;
    } else if ([errorCodeString isEqualToString:@"MISSING_PARAMETER"]) {
      errorCode = KBAPIErrorCodeMissingParameter;
    } else if ([errorCodeString isEqualToString:@"BAD_SESSION"]) {
      errorCode = KBAPIErrorCodeBadSession;
    } else if ([errorCodeString isEqualToString:@"BAD_SIGNUP_USERNAME_TAKEN"]) {
      errorCode = KBAPIErrorCodeBadSignupUsernameTaken;
      errorType = KBAPIErrorTypeAlert;
    } else if ([errorCodeString isEqualToString:@"BAD_SIGNUP_EMAIL_TAKEN"]) {
      errorCode = KBAPIErrorCodeBadSignupEmailTaken;
      errorType = KBAPIErrorTypeAlert;
    } else if ([errorCodeString isEqualToString:@"BAD_LOGIN_PASSWORD"]) {
      errorCode = KBAPIErrorCodeBadLoginPassword;
      errorType = KBAPIErrorTypeAlert;
    } else if ([errorCodeString isEqualToString:@"BAD_LOGIN_USER_NOT_FOUND"]) {
      errorCode = KBAPIErrorCodeBadLoginUserNotFound;
      errorType = KBAPIErrorTypeAlert;
    }
    
    if (!localizedDescription) localizedDescription = @"Unknown error";
      
    KBAPIError *APIError = [KBAPIError errorWithCode:errorCode localizedDescription:localizedDescription type:errorType];
    (*error) = APIError;
  }
  
  NSString *CSRFToken = [JSONObject gh_objectMaybeNilForKey:@"csrf_token" ofClass:[NSString class]];
  if (CSRFToken) {
    [self.delegate responseSerializer:self didUpdateCSRFToken:CSRFToken];
  }

  return JSONObject;
}

@end
