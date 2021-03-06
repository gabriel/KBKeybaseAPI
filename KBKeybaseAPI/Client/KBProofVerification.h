//
//  KBProofVerification.h
//  KBKeybaseAPI
//
//  Created by Gabriel on 11/10/14.
//  Copyright (c) 2014 Gabriel Handford. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "KBProof.h"
#import "KBSignature.h"

typedef void (^KBProofCompletionHandler)(NSError *error, KBProof *proof);

@interface KBProofVerification : NSObject

+ (void)verifyProof:(KBProof *)proof signature:(KBSignature *)signature completion:(KBProofCompletionHandler)completion;

@end
