//
//  KBProofVerification.m
//  KBKeybase
//
//  Created by Gabriel on 11/10/14.
//  Copyright (c) 2014 Gabriel Handford. All rights reserved.
//

#import "KBProofVerification.h"

#import <AFNetworking/AFNetworking.h>
#import <GHKit/GHKit.h>
#import <ObjectiveSugar/ObjectiveSugar.h>

#import "KBDNSQuery.h"

@implementation KBProofVerification

+ (void)verifyProof:(KBProof *)proof signature:(KBSignature *)signature completion:(KBProofCompletionHandler)completion {
  if (!signature) {
    completion(GHNSError(KBProofErrorNoSignature, @"No signature associated with proof."), proof);
    return;
  }
  if (!proof.isURLStringValid) {
    completion(GHNSError(KBProofErrorInvalidProofURL, @"Invalid proof URL."), proof);
    return;
  }
  
  if (proof.proofType == KBProofTypeUnknown) {
    completion(GHNSError(KBProofErrorUnrecognized, @"We don't know how to verify this proof."), proof);
    return;
  }
  
  NSURL *URL = [NSURL URLWithString:proof.humanURLString];
  
  if ([URL.scheme isEqualToString:@"dns"]) {
    [self verifyDNSProof:proof host:URL.host signature:signature completion:completion];
  } else if ([URL.scheme isEqualToString:@"https"] || [URL.scheme isEqualToString:@"http"]) {
    [self verifyURLForProof:proof signature:signature completion:completion];
  } else {
    completion(GHNSError(KBProofErrorInvalidProofURL, @"Invalid scheme."), proof);
  }
}

+ (NSString *)stringByStrippingHTML:(NSString *)document {
  NSRange r;
  while ((r = [document rangeOfString:@"<[^>]+>" options:NSRegularExpressionSearch]).location != NSNotFound)
    document = [document stringByReplacingCharactersInRange:r withString:@""];
  return document;
}

+ (void)verifyURLForProof:(KBProof *)proof signature:(KBSignature *)signature completion:(KBProofCompletionHandler)completion {
  AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
  AFHTTPRequestSerializer *requestSerializer = [[AFHTTPRequestSerializer alloc] init];
  [requestSerializer setValue:@"Keybase" forHTTPHeaderField:@"User-Agent"];
  manager.requestSerializer = requestSerializer;
  AFHTTPResponseSerializer *responseSerializer = [[AFHTTPResponseSerializer alloc] init];
  responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html", @"text/plain", nil];
  manager.responseSerializer = responseSerializer;
  [manager GET:proof.humanURLString parameters:nil success:^(AFHTTPRequestOperation *operation, NSData *responseObject) {
    NSString *document = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
    if (!document) {
      completion(GHNSError(KBProofErrorInvalidResponseData, @"Couldn't parse response data."), proof);
      return;
    }

    // Remove whitespace for proof text check
    document = [document stringByReplacingOccurrencesOfString:@"\\s" withString:@"" options:NSRegularExpressionSearch range:NSMakeRange(0, document.length)];
    NSString *proofTextCheck = [signature.proofTextCheck stringByReplacingOccurrencesOfString:@"\\s" withString:@"" options:NSRegularExpressionSearch range:NSMakeRange(0, signature.proofTextCheck.length)];
    
    if ([document rangeOfString:proofTextCheck options:NSLiteralSearch].location == NSNotFound) {

      // Try again after stripping HTML
      if ([[self stringByStrippingHTML:document] rangeOfString:proofTextCheck options:NSLiteralSearch].location == NSNotFound) {
        completion(GHNSError(KBProofErrorMissingProofText, @"Missing proof text in response."), proof);
        return;
      }
    }
    
    // Verfied ok
    completion(nil, proof);
    
  } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
    completion(error, proof);
  }];
}

+ (void)verifyDNSProof:(KBProof *)proof host:(NSString *)host signature:(KBSignature *)signature completion:(KBProofCompletionHandler)completion {
  // Try the domain name and then try _keybase.domain if that failed
  [self _verifyDNSProof:proof host:host signature:signature completion:^(NSError *error, KBProof *proof) {
    if (!error) {
      completion(nil, proof);
      return;
    }
    [self _verifyDNSProof:proof host:NSStringWithFormat(@"_keybase.%@", host) signature:signature completion:completion];
  }];
}

+ (void)_verifyDNSProof:(KBProof *)proof host:(NSString *)host signature:(KBSignature *)signature completion:(KBProofCompletionHandler)completion {
  KBDNSQuery *query = [[KBDNSQuery alloc] init];
  [query TXTRecordsWithName:host progress:^(NSString *record, BOOL *stop) {
    if ([record rangeOfString:signature.proofTextCheck options:NSLiteralSearch].location != NSNotFound) {
      *stop = YES;
    }
  } completion:^(NSError *error, NSArray *records) {
    GHDebug(@"Finished DNS: %@, %@", host, error);
    for (NSString *record in records) {
      if ([record rangeOfString:signature.proofTextCheck options:NSLiteralSearch].location != NSNotFound) {
        completion(nil, proof);
        return;
      }
    }
    if (error) {
      completion(error, proof);
    } else {
      completion(GHNSError(KBProofErrorMissingProofText, @"Missing proof text in response."), proof);
    }
  }];  
}

@end
