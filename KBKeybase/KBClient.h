//
//  KBClient.h
//  Keybase
//
//  Created by Gabriel on 6/18/14.
//  Copyright (c) 2014 Gabriel Handford. All rights reserved.
//

#import "KBUser.h"
#import "KBSessionUser.h"
#import "KBSession.h"
#import "KBKey.h"

#import "KBResponseSerializer.h"

#import <TSTripleSec/P3SKB.h>

extern NSString *const KBAPILocalHost;
extern NSString *const KBAPIKeybaseIOHost;

typedef void (^KBClientErrorHandler)(NSError *error);

@interface KBClient : NSObject <KBResponseSerializerDelegate>

- (instancetype)initWithAPIHost:(NSString *)APIHost;

// For debugging when cookies are invalid or expired
- (void)clearCookies;

- (void)logInWithEmailOrUserName:(NSString *)emailOrUserName password:(NSString *)password success:(void (^)(KBSession *session))success failure:(KBClientErrorHandler)failure;

- (void)signUpWithName:(NSString *)name email:(NSString *)email userName:(NSString *)userName password:(NSString *)password invitationId:(NSString *)invitationId success:(void (^)(KBSession *session))success failure:(KBClientErrorHandler)failure;

- (void)sessionUser:(void (^)(KBSessionUser *sessionUser))success failure:(KBClientErrorHandler)failure;

- (void)checkSession:(KBSession *)session success:(void (^)(KBSession *session))success failure:(KBClientErrorHandler)failure;

#pragma mark Keys

- (void)addPublicKeyBundle:(NSString *)publicKeyBundle success:(void (^)(NSString *kid))success failure:(KBClientErrorHandler)failure;

- (void)keysForPGPKeyIds:(NSArray *)PGPKeyIds capabilities:(KBKeyCapabilities)capabilites success:(void (^)(NSArray */*of id<KBKey>*/keys))success failure:(KBClientErrorHandler)failure;

- (void)keysForKIDs:(NSArray *)KIDs capabilities:(KBKeyCapabilities)capabilites success:(void (^)(NSArray */*of id<KBKey>*/keys))success failure:(KBClientErrorHandler)failure;

#pragma mark Lookup

- (void)checkForUserName:(NSString *)userName success:(void (^)(BOOL exists))success failure:(KBClientErrorHandler)failure;

- (void)userForUserName:(NSString *)userName success:(void (^)(KBUser *user))success failure:(KBClientErrorHandler)failure;

- (void)usersForUserNames:(NSArray *)userNames success:(void (^)(NSArray *users))success failure:(KBClientErrorHandler)failure;

- (void)usersPaginatedForUserNames:(NSArray *)userNames success:(void (^)(NSArray *users, BOOL completed))success failure:(KBClientErrorHandler)failure;

- (void)searchWithQuery:(NSString *)query success:(void (^)(NSArray *searchResults))success failure:(KBClientErrorHandler)failure;

#pragma mark Signature Announcement

- (void)createSignature:(NSString *)signature userName:(NSString *)userName success:(void (^)(NSString *signatureId))success failure:(KBClientErrorHandler)failure;

- (void)nextSequence:(void (^)(NSNumber *sequenceNumber, NSString *previousBlockHash))success failure:(KBClientErrorHandler)failure;

@end
