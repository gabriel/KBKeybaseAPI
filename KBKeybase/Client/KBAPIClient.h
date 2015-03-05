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
#import "KBSignatureProof.h"

#import "KBResponseSerializer.h"
#import "KBCrypto.h"

#import <TSTripleSec/P3SKB.h>

extern NSString *const KBAPILocalHost;
extern NSString *const KBAPIKeybaseIOHost;
extern NSString *const KBAPIPath;

typedef void (^KBAPIClientErrorHandler)(NSError *error);

@interface KBAPIClient : NSObject <KBResponseSerializerDelegate>

@property NSString *APIHost;
@property NSTimeInterval cacheInterval;

- (instancetype)initWithAPIHost:(NSString *)APIHost;

- (instancetype)initWithAPIHost:(NSString *)APIHost crypto:(id<KBCrypto>)crypto;

// For debugging when cookies are invalid or expired
- (void)clearCookies;

- (void)logInWithEmailOrUserName:(NSString *)emailOrUserName password:(NSString *)password success:(void (^)(KBSession *session))success failure:(KBAPIClientErrorHandler)failure;

- (void)signUpWithEmail:(NSString *)email userName:(NSString *)userName password:(NSString *)password invitationId:(NSString *)invitationId success:(void (^)(KBSession *session))success failure:(KBAPIClientErrorHandler)failure;

- (void)sessionUser:(void (^)(KBSessionUser *sessionUser))success failure:(KBAPIClientErrorHandler)failure;

- (void)checkSession:(KBSession *)session success:(void (^)(KBSession *session))success failure:(KBAPIClientErrorHandler)failure;

#pragma mark Keys

- (void)addPublicKeyBundle:(NSString *)publicKeyBundle success:(dispatch_block_t)success failure:(KBAPIClientErrorHandler)failure;

- (void)keysForPGPKeyIds:(NSArray *)PGPKeyIds capabilities:(KBKeyCapabilities)capabilites success:(void (^)(NSArray */*of id<KBKey>*/keys))success failure:(KBAPIClientErrorHandler)failure;

- (void)addPrivateKey:(P3SKB *)privateKey publicKeyBundle:(NSString *)publicKeyBundle success:(dispatch_block_t)success failure:(KBAPIClientErrorHandler)failure;

#pragma mark Lookup

- (void)checkForUserName:(NSString *)userName success:(void (^)(BOOL exists))success failure:(KBAPIClientErrorHandler)failure;

- (void)userForUserName:(NSString *)userName success:(void (^)(KBUser *user))success failure:(KBAPIClientErrorHandler)failure;

- (void)userForKey:(NSString *)key value:(NSString *)value fields:(NSString *)fields success:(void (^)(KBUser *user))success failure:(KBAPIClientErrorHandler)failure;

/*!
 Key can be:
 - usernames
 - twitter
 */
- (void)usersForKey:(NSString *)key value:(NSString *)value fields:(NSString *)fields success:(void (^)(NSArray *users))success failure:(KBAPIClientErrorHandler)failure;

- (void)usersPaginatedForKey:(NSString *)key values:(NSArray *)values fields:(NSString *)fields limit:(NSInteger)limit success:(void (^)(NSArray *users, BOOL completed))success failure:(KBAPIClientErrorHandler)failure;

- (void)usersForKey:(NSString *)key values:(NSArray *)values completion:(void (^)(NSError *error, NSArray *users))completion;

- (void)usersForPGPKeyIds:(NSArray *)PGPKeyIds success:(void (^)(NSArray */*of KBUser*/users))success failure:(KBAPIClientErrorHandler)failure;

- (void)searchUsersWithQuery:(NSString *)query success:(void (^)(NSArray *searchResults))success failure:(KBAPIClientErrorHandler)failure;

#pragma mark Profile

- (void)updateProfileForSession:(KBSession *)session params:(NSDictionary *)params success:(void (^)(KBUser *user))success failure:(KBAPIClientErrorHandler)failure;

#pragma mark Signature

- (void)signaturesForUserId:(NSString *)userId sequenceNumber:(NSInteger)sequenceNumber success:(void (^)(NSArray *signatures))success failure:(KBAPIClientErrorHandler)failure;

- (void)createSignature:(NSString *)signature type:(NSString *)type remoteUserName:(NSString *)remoteUserName success:(void (^)(KBSignatureProof *signatureProof))success failure:(KBAPIClientErrorHandler)failure;

- (void)nextSequence:(void (^)(NSNumber *sequenceNumber, NSString *previousBlockHash))success failure:(KBAPIClientErrorHandler)failure;

- (void)postedWithProofId:(NSString *)proofId success:(dispatch_block_t)success failure:(KBAPIClientErrorHandler)failure;

- (void)verifySignatures:(NSArray *)signatures user:(KBUser *)user completion:(void (^)(NSError *error))completion;

#pragma mark -

- (NSString *)URLStringWithPath:(NSString *)path;

@end
