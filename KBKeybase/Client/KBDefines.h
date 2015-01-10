//
//  KBDefines.h
//  KBKeybase
//
//  Created by Gabriel on 11/25/14.
//  Copyright (c) 2014 Gabriel Handford. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^KBCompletionHandler)(NSError *error);
typedef void (^KBAPIErrorHandler)(NSError *error);

typedef NS_ENUM (NSInteger, KBActionType) {
  KBActionTypeEmail = 1,
  KBActionTypeEncrypt,
  KBActionTypeSign,
  KBActionTypeDecrypt,
  KBActionTypeVerify,
};

typedef NS_ENUM (NSInteger, KBComposeType) {
  KBComposeTypeEmail = 0,
  KBComposeTypeEncrypt = 1,
  KBComposeTypeSign
};
