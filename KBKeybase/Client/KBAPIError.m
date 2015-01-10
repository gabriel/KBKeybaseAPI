//
//  KBAPIError.m
//  Keybase
//
//  Created by Gabriel on 6/19/14.
//  Copyright (c) 2014 Gabriel Handford. All rights reserved.
//

#import "KBAPIError.h"

NSString *const KBAPIErrorTypeKey = @"KBAPIErrorTypeKey";

@implementation KBAPIError

+ (KBAPIError *)errorWithCode:(KBAPIErrorCode)code localizedDescription:(NSString *)localizedDescription type:(KBAPIErrorType)type {
  return [KBAPIError errorWithDomain:@"KBAPIError" code:code userInfo:@{NSLocalizedDescriptionKey: localizedDescription, KBAPIErrorTypeKey: @(type)}];
}

@end