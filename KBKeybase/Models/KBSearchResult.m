//
//  KBUserQueryResult.m
//  KBKeybase
//
//  Created by Gabriel on 8/28/14.
//  Copyright (c) 2014 Gabriel Handford. All rights reserved.
//

#import "KBSearchResult.h"

@implementation KBSearchResult

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
  return @{
           @"userName": @"components.username.val",
           @"userNameScore": @"components.username.score",
           
           @"fullName": @"components.full_name.val",
           @"fullNameScore": @"components.full_name.score",
           
           @"github": @"components.github.val",
           @"githubScore": @"components.github.score",
           
           @"twitter": @"components.twitter.val",
           @"twitterScore": @"components.twitter.score",
           
           @"keyFingerprint": @"components.key_fingerprint.val",
           @"keyFingerprintScore": @"components.key_fingerprint.score",
           @"keyAlgorithm": @"components.key_fingerprint.algo",
           @"keyNumBits": @"components.key_fingerprint.nbits",
           
           @"totalScore": @"total_score",
           @"userId": @"uid",
           @"thumbnailURLString": @"thumbnail",
           @"followee": @"is_followee",
           };
}

- (NSString *)twitterUserName {
  if (!_twitter) return nil;
  return [NSString stringWithFormat:@"@%@", _twitter];
}

@end

//{
//  "total_score": 0.013750000000000002,
//  "components": {
//    "username": {
//      "val": "gabriel",
//      "score": 0.013750000000000002
//    },
//    "key_fingerprint": {
//      "val": "1587c87f32c763aff8100585b4666e9197186322",
//      "score": 0,
//      "algo": 1,
//      "nbits": 4096
//    }
//  },
//  "uid": "79939dbb343f5687c2718f7b5d3bd600",
//  "thumbnail": null,
//  "is_followee": false
//},

