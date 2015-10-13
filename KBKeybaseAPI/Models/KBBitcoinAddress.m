//
//  KBBitcoinAddress.m
//  KBKeybaseAPI
//
//  Created by Gabriel on 7/10/14.
//  Copyright (c) 2014 Gabriel Handford. All rights reserved.
//

#import "KBBitcoinAddress.h"

@implementation KBBitcoinAddress

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
  return @{
           @"address": @"address",
           @"signatureId": @"sig_id",
           };
}

- (NSString *)displayDescription {
  return _address;
}

@end
