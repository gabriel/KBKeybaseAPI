//
//  KBError.m
//  Keybase
//
//  Created by Gabriel on 6/19/14.
//  Copyright (c) 2014 Gabriel Handford. All rights reserved.
//

#import "KBError.h"

NSString *const KBErrorTypeKey = @"KBErrorTypeKey";

@implementation KBError

+ (KBError *)errorWithCode:(KBAPIErrorCode)code localizedDescription:(NSString *)localizedDescription type:(KBErrorType)type {
  return [KBError errorWithDomain:@"KBError" code:code userInfo:@{NSLocalizedDescriptionKey: localizedDescription, KBErrorTypeKey: @(type)}];
}

@end