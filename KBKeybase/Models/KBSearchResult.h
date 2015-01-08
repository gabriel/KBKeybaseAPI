//
//  KBUserQueryResult.h
//  KBKeybase
//
//  Created by Gabriel on 8/28/14.
//  Copyright (c) 2014 Gabriel Handford. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Mantle/Mantle.h>

@interface KBSearchResult : MTLModel <MTLJSONSerializing>

// Username
@property (readonly) NSString *userName;
@property (readonly) float userNameScore;

// Key
@property (readonly) NSString *keyFingerprint;
@property (readonly) float keyFingerprintScore;
// The API can return null for these
//@property (readonly) KBKeyAlgorithm keyAlgorithm;
//@property (readonly) NSInteger keyNumBits;

// Fullname
@property (readonly) NSString *fullName;
@property (readonly) float fullNameScore;

// Twitter
@property (readonly) NSString *twitter;
@property (readonly) float twitterScore;

// Github
@property (readonly) NSString *github;
@property (readonly) float githubScore;


@property (readonly) float totalScore;
@property (readonly) NSString *userId;
@property (readonly) NSString *thumbnailURLString;
@property (readonly, getter=isFollowee) BOOL followee;

@end
