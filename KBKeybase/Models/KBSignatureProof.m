//
//  KBSignatureProof.m
//  KBKeybase
//
//  Created by Gabriel on 11/3/14.
//  Copyright (c) 2014 Gabriel Handford. All rights reserved.
//

#import "KBSignatureProof.h"

@implementation KBSignatureProof

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
  return @{
           @"signatureId": @"sig_id",
           @"proofId": @"proof_id",
           @"proofText": @"proof_text",
           };
}

@end
