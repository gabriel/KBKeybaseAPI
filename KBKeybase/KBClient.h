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
#import "KBSignatureProof.h"

#import "KBResponseSerializer.h"

#import <KBCrypto/KBCrypto.h>
#import <TSTripleSec/P3SKB.h>

extern NSString *const KBAPILocalHost;
extern NSString *const KBAPIKeybaseIOHost;

typedef void (^KBClientErrorHandler)(NSError *error);

@interface KBClient : NSObject <KBResponseSerializerDelegate>

- (instancetype)initWithAPIHost:(NSString *)APIHost crypto:(KBCrypto *)crypto;

// For debugging when cookies are invalid or expired
- (void)clearCookies;

- (void)logInWithEmailOrUserName:(NSString *)emailOrUserName password:(NSString *)password success:(void (^)(KBSession *session))success failure:(KBClientErrorHandler)failure;

- (void)signUpWithEmail:(NSString *)email userName:(NSString *)userName password:(NSString *)password invitationId:(NSString *)invitationId success:(void (^)(KBSession *session))success failure:(KBClientErrorHandler)failure;

- (void)sessionUser:(void (^)(KBSessionUser *sessionUser))success failure:(KBClientErrorHandler)failure;

- (void)checkSession:(KBSession *)session success:(void (^)(KBSession *session))success failure:(KBClientErrorHandler)failure;

#pragma mark Keys

- (void)addPublicKeyBundle:(NSString *)publicKeyBundle success:(dispatch_block_t)success failure:(KBClientErrorHandler)failure;

- (void)keysForPGPKeyIds:(NSArray *)PGPKeyIds capabilities:(KBKeyCapabilities)capabilites success:(void (^)(NSArray */*of id<KBKey>*/keys))success failure:(KBClientErrorHandler)failure;

- (void)addPrivateKey:(P3SKB *)privateKey publicKeyBundle:(NSString *)publicKeyBundle success:(dispatch_block_t)success failure:(KBClientErrorHandler)failure;

#pragma mark Lookup

- (void)checkForUserName:(NSString *)userName success:(void (^)(BOOL exists))success failure:(KBClientErrorHandler)failure;

- (void)userForUserName:(NSString *)userName success:(void (^)(KBUser *user))success failure:(KBClientErrorHandler)failure;

- (void)userForKey:(NSString *)key value:(NSString *)value fields:(NSString *)fields success:(void (^)(KBUser *user))success failure:(KBClientErrorHandler)failure;

- (void)usersForKey:(NSString *)key value:(NSString *)value fields:(NSString *)fields success:(void (^)(NSArray *users))success failure:(KBClientErrorHandler)failure;

- (void)usersPaginatedForKey:(NSString *)key values:(NSArray *)values fields:(NSString *)fields limit:(NSInteger)limit success:(void (^)(NSArray *users, BOOL completed))success failure:(KBClientErrorHandler)failure;

- (void)searchWithQuery:(NSString *)query success:(void (^)(NSArray *searchResults))success failure:(KBClientErrorHandler)failure;

- (void)usersForPGPKeyIds:(NSArray *)PGPKeyIds success:(void (^)(NSArray */*of KBUser*/users))success failure:(KBClientErrorHandler)failure;

#pragma mark Profile

- (void)updateProfileForSession:(KBSession *)session params:(NSDictionary *)params success:(void (^)(KBUser *user))success failure:(KBClientErrorHandler)failure;

#pragma mark Signature

- (void)signaturesForUserId:(NSString *)userId sequenceNumber:(NSInteger)sequenceNumber success:(void (^)(NSArray *signatures))success failure:(KBClientErrorHandler)failure;

- (void)createSignature:(NSString *)signature type:(NSString *)type remoteUserName:(NSString *)remoteUserName success:(void (^)(KBSignatureProof *signatureProof))success failure:(KBClientErrorHandler)failure;

- (void)nextSequence:(void (^)(NSNumber *sequenceNumber, NSString *previousBlockHash))success failure:(KBClientErrorHandler)failure;

- (void)postedWithProofId:(NSString *)proofId success:(dispatch_block_t)success failure:(KBClientErrorHandler)failure;

- (void)verifySignatures:(NSArray *)signatures user:(KBUser *)user completion:(void (^)(NSError *error))completion;

@end
