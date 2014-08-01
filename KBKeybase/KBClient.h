//
//  KBAPIClient.h
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


@interface KBClient : NSObject <KBResponseSerializerDelegate>

- (instancetype)initWithAPIHost:(NSString *)APIHost;

// For debugging when cookies are invalid or expired
- (void)clearCookies;

- (void)logInWithEmailOrUserName:(NSString *)emailOrUserName password:(NSString *)password success:(void (^)(KBSession *session))success failure:(void (^)(NSError *error))failure;

- (void)signUpWithName:(NSString *)name email:(NSString *)email userName:(NSString *)userName password:(NSString *)password invitationId:(NSString *)invitationId success:(void (^)(KBSession *session))success failure:(void (^)(NSError *error))failure;

- (void)sessionUser:(void (^)(KBSessionUser *sessionUser))success failure:(void (^)(NSError *error))failure;

- (void)checkSession:(KBSession *)session success:(void (^)(KBSession *session))success failure:(void (^)(NSError *error))failure;

#pragma mark Keys

- (void)setPrivateKey:(P3SKB *)privateKey success:(dispatch_block_t)success failure:(void (^)(NSError *error))failure;

- (void)keysForKeyIds:(NSArray *)keyIds capabilities:(KBKeyCapabilities)capabilites success:(void (^)(NSArray */*of id<KBKey>*/keys))success failure:(void (^)(NSError *error))failure;

#pragma mark Lookup

- (void)userForUserName:(NSString *)userName success:(void (^)(KBUser *user))success failure:(void (^)(NSError *error))failure;

- (void)usersForUserNames:(NSArray *)userNames success:(void (^)(NSArray *users))success failure:(void (^)(NSError *error))failure;

- (void)usersPaginatedForUserNames:(NSArray *)userNames success:(void (^)(NSArray *users, BOOL completed))success failure:(void (^)(NSError *error))failure;

@end
