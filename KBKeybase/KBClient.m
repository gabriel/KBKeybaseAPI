//
//  KBAPIClient.m
//  Keybase
//
//  Created by Gabriel on 6/18/14.
//  Copyright (c) 2014 Gabriel Handford. All rights reserved.
//

#import "KBClient.h"

#import <TSTripleSec/TSTripleSec.h>
#import <GHKit/GHKit.h>
#import <ObjectiveSugar/ObjectiveSugar.h>

#import "KBPublicKey.h"
#import "KBPrivateKey.h"
#import "KBSession.h"
#import "KBKeychain.h"
#import "KBError.h"
#import "KBSearchResult.h"

NSString *const KBAPILocalHost = @"http://localhost:3000/_/api/1.0/";
NSString *const KBAPIKeybaseIOHost = @"https://keybase.io/_/api/1.0/";

NSString *KBServerURLString(NSString *APIHost, NSString *path) {
  if (!path) return APIHost;
  return [NSString stringWithFormat:@"%@%@", APIHost, path];
}

NSURL *KBServerURL(NSString *APIHost, NSString *path) {
  return [NSURL URLWithString:KBServerURLString(APIHost, path)];
}

NSMutableDictionary *KBURLParameters(NSDictionary *params) {
  NSMutableDictionary *parameters = [NSMutableDictionary gh_dictionaryWithKeysAndObjectsMaybeNil:nil];
  if (params) [parameters addEntriesFromDictionary:params];
  [parameters addEntriesFromDictionary:parameters];
  [parameters gh_mutableCompact];
  return parameters;
}

@interface KBClient ()
@property NSString *APIHost;
@property KBCrypto *crypto;
@property NSString *CSRFToken;
@end

@implementation KBClient

- (instancetype)init {
  [NSException raise:NSInvalidArgumentException format:@"Use initWithAPIHost:"];
  return nil;
}

- (instancetype)initWithAPIHost:(NSString *)APIHost crypto:(KBCrypto *)crypto {
  if ((self = [super init])) {
    _APIHost = APIHost;
    _crypto = crypto;
  }
  return self;
}

- (AFHTTPSessionManager *)httpManager {
  static AFHTTPSessionManager *gHttpManager = NULL;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    configuration.HTTPCookieAcceptPolicy = NSHTTPCookieAcceptPolicyOnlyFromMainDocumentDomain;
    configuration.HTTPShouldSetCookies = YES;
    
    NSURL *URL = KBServerURL(_APIHost, nil);
    
    if ([[URL host] isEqual:@"localhost"]) {
      configuration.URLCache = nil;
      NSDictionary *proxyDict = @{
                                  (NSString *)kCFStreamPropertyHTTPProxyHost : @"localhost",
                                  (NSString *)kCFStreamPropertyHTTPProxyPort : @(8888),
                                  };    
      configuration.connectionProxyDictionary = proxyDict;
    }

    gHttpManager = [[AFHTTPSessionManager alloc] initWithBaseURL:URL sessionConfiguration:configuration];
    KBResponseSerializer *responseSerializer = [[KBResponseSerializer alloc] init];
    responseSerializer.delegate = self;
    gHttpManager.responseSerializer = responseSerializer;
  });
  return gHttpManager;
}

- (NSHTTPCookieStorage *)cookieStorage {
  return self.httpManager.session.configuration.HTTPCookieStorage;
}

- (void)clearCookies {
  NSHTTPCookieStorage *cookieStorage = [self cookieStorage];
  NSArray *cookies = [cookieStorage cookiesForURL:[NSURL URLWithString:_APIHost]];
  for (NSHTTPCookie *cookie in cookies) {
    //GHDebug(@"Removing cookie: %@", cookie);
    [cookieStorage deleteCookie:cookie];
  }
}

+ (NSData *)passwordHashForPassword:(NSString *)password salt:(NSData *)salt {
  NSData *passwordData = [password dataUsingEncoding:NSUTF8StringEncoding];
  NSData *scrypt = [NAScrypt scrypt:passwordData salt:salt N:32768U r:8 p:1 length:224 error:nil];
  NSData *pwh = [NSData dataWithBytes:([scrypt bytes] + 192) length:32];
  NSAssert([pwh length] == 32, @"Invalid pwh length");
  return pwh;
}

+ (NSString *)HMACPasswordHashForPassword:(NSString *)password salt:(NSData *)salt loginSession:(NSString *)loginSession {
  NSData *pwh = [self passwordHashForPassword:password salt:salt];
  
  NSData *loginSessionData = [[NSData alloc] initWithBase64EncodedString:loginSession options:0];
  NSData *HMACpwh = [NAHMAC HMACForKey:pwh data:loginSessionData algorithm:NAHMACAlgorithmSHA2_512];
  
  return [HMACpwh na_hexString];
}

- (void)getSaltWithEmailOrUserName:(NSString *)emailOrUserName success:(void (^)(NSData *salt, NSString *loginSession))success failure:(KBClientErrorHandler)failure {
  
  NSParameterAssert(emailOrUserName);
  
  NSDictionary *params = @{@"email_or_username": emailOrUserName};
  
  //GHWeakSelf blockSelf = self;
  [self.httpManager GET:@"getsalt.json" parameters:KBURLParameters(params) success:^(NSURLSessionDataTask *task, id responseObject) {
    NSString *loginSession = [responseObject gh_objectMaybeNilForKey:@"login_session" ofClass:[NSString class]];
    NSString *salt = [responseObject gh_objectMaybeNilForKey:@"salt" ofClass:[NSString class]];
    NSData *saltData = [salt na_dataFromHexString];
    success(saltData, loginSession);
    
  } failure:^(NSURLSessionDataTask *task, NSError *error) {
    failure(error);
  }];
}

- (void)logInWithEmailOrUserName:(NSString *)emailOrUserName password:(NSString *)password success:(void (^)(KBSession *session))success failure:(KBClientErrorHandler)failure {
  
  NSParameterAssert(emailOrUserName);
  NSParameterAssert(password);
  
  GHWeakSelf blockSelf = self;
  [self getSaltWithEmailOrUserName:emailOrUserName success:^(NSData *salt, NSString *loginSession) {
    NSString *HMACPasswordHash = [KBClient HMACPasswordHashForPassword:password salt:salt loginSession:loginSession];
    NSDictionary *params = @{@"email_or_username": emailOrUserName, @"hmac_pwh": HMACPasswordHash, @"login_session": loginSession, @"csrf_token": blockSelf.CSRFToken};
    
    dispatch_async(dispatch_get_main_queue(), ^{
      NSAssert(self.CSRFToken, @"Missing CSRF");
      [blockSelf.httpManager POST:@"login.json" parameters:KBURLParameters(params) success:^(NSURLSessionDataTask *task, id responseObject) {
        
        NSDictionary *userDict = [responseObject gh_objectMaybeNilForKey:@"me" ofClass:[NSDictionary class]];
        
        NSError *error = nil;
        KBUser *user = [MTLJSONAdapter modelOfClass:KBUser.class fromJSONDictionary:userDict error:&error];
        if (!user) {
          failure(error);
          return;
        }
        
        [blockSelf sessionUser:^(KBSessionUser *sessionUser) {
          KBSession *session = [[KBSession alloc] initWithSessionUser:sessionUser user:user];
          success(session);
        } failure:failure];
        
      } failure:^(NSURLSessionDataTask *task, NSError *error) {
        failure(error);
      }];
    });
  } failure:^(NSError *error) {
    failure(error);
  }];
}

- (void)signUpWithEmail:(NSString *)email userName:(NSString *)userName password:(NSString *)password invitationId:(NSString *)invitationId success:(void (^)(KBSession *session))success failure:(KBClientErrorHandler)failure {
  NSParameterAssert(email);
  NSParameterAssert(userName);
  NSParameterAssert(password);
  NSParameterAssert(invitationId);
  NSAssert(self.CSRFToken, @"Missing CSRF");
  
  NSError *error = nil;
  NSData *salt = [NARandom randomData:16 error:&error];
  if (!salt) {
    dispatch_async(dispatch_get_main_queue(), ^{ failure(error); });
    return;
  }

  NSString *pwh = [[KBClient passwordHashForPassword:password salt:salt] na_hexString];
  NSDictionary *params = @{@"email": email, @"username": userName, @"pwh": pwh, @"salt": [salt na_hexString], @"invitation_id": invitationId, @"pwh_version": @(3)};
  
  GHWeakSelf blockSelf = self;
  [self.httpManager POST:@"signup.json" parameters:KBURLParameters(params) success:^(NSURLSessionDataTask *task, id responseObject) {
    [blockSelf logInWithEmailOrUserName:userName password:password success:success failure:failure];
  } failure:^(NSURLSessionDataTask *task, NSError *error) {
    failure(error);
  }];
}

- (void)addPublicKeyBundle:(NSString *)publicKeyBundle success:(dispatch_block_t)success failure:(KBClientErrorHandler)failure {
  NSDictionary *params = @{@"public_key": publicKeyBundle, @"csrf_token": self.CSRFToken, @"is_primary": @(YES)};
  [self.httpManager POST:@"key/add.json" parameters:KBURLParameters(params) success:^(NSURLSessionDataTask *task, id responseObject) {
    success();
  } failure:^(NSURLSessionDataTask *task, NSError *error) {
    failure(error);
  }];
}

- (void)addPrivateKey:(P3SKB *)privateKey publicKeyBundle:(NSString *)publicKeyBundle success:(dispatch_block_t)success failure:(KBClientErrorHandler)failure {
  NSAssert(self.CSRFToken, @"Missing CSRF");
  
  NSDictionary *params = @{@"private_key": [[privateKey data] base64EncodedStringWithOptions:0], @"public_key": publicKeyBundle, @"csrf_token": self.CSRFToken, @"is_primary": @(YES)};
  
  [self.httpManager POST:@"key/add.json" parameters:KBURLParameters(params) success:^(NSURLSessionDataTask *task, id responseObject) {
    success();
  } failure:^(NSURLSessionDataTask *task, NSError *error) {
    failure(error);
  }];
}

- (void)sessionUser:(void (^)(KBSessionUser *sessionUser))success failure:(KBClientErrorHandler)failure {
  [self.httpManager GET:@"me.json" parameters:KBURLParameters(nil) success:^(NSURLSessionDataTask *task, id responseObject) {
    
    NSDictionary *meDict = [responseObject gh_objectMaybeNilForKey:@"me" ofClass:[NSDictionary class]];
    
    NSError *error = nil;
    KBSessionUser *sessionUser = [MTLJSONAdapter modelOfClass:KBSessionUser.class fromJSONDictionary:meDict error:&error];
    if (!sessionUser) {
      failure(error);
      return;
    }

    success(sessionUser);
  } failure:^(NSURLSessionDataTask *task, NSError *error) {
    failure(error);
  }];
}

- (void)checkForUserName:(NSString *)userName success:(void (^)(BOOL exists))success failure:(KBClientErrorHandler)failure {
  NSParameterAssert(userName);
  [self.httpManager GET:@"user/lookup.json" parameters:KBURLParameters(@{@"username": userName, @"fields": @"basics"}) success:^(NSURLSessionDataTask *task, id responseObject) {
    success(YES);
  } failure:^(NSURLSessionDataTask *task, NSError *error) {
    if (error.code == KBErrorCodeNotFound) {
      success(NO);
      return;
    }
    
    failure(error);
  }];
}

- (void)userForUserName:(NSString *)userName success:(void (^)(KBUser *user))success failure:(KBClientErrorHandler)failure {
  [self userForKey:@"usernames" value:userName fields:nil success:success failure:failure];
}

- (void)userForKey:(NSString *)key value:(NSString *)value fields:(NSString *)fields success:(void (^)(KBUser *user))success failure:(KBClientErrorHandler)failure {
  [self usersForKey:key value:value fields:fields success:^(NSArray *users) {
    success([users count] > 0 ? users[0]: nil);
  } failure:failure];
}

- (void)usersForKey:(NSString *)key value:(NSString *)value fields:(NSString *)fields success:(void (^)(NSArray *users))success failure:(KBClientErrorHandler)failure {
  
  if (!fields) {
    fields = @"basics,pictures,profile,proofs_summary,cryptocurrency_addresses,public_keys,sigs";
  }
  
  [self.httpManager GET:@"user/lookup.json" parameters:KBURLParameters(@{key: value, @"fields": fields}) success:^(NSURLSessionDataTask *task, id responseObject) {
    
    NSArray *themDicts = [responseObject gh_objectMaybeNilForKey:@"them" ofClass:[NSArray class]];
    
    NSError *error = nil;
    
    NSMutableArray *users = [NSMutableArray arrayWithCapacity:[themDicts count]];
    for (NSDictionary *themDict in themDicts) {
      if (![themDict isEqual:NSNull.null]) {
        KBUser *user = [MTLJSONAdapter modelOfClass:KBUser.class fromJSONDictionary:themDict error:&error];
        [users addObject:user];
      }
    }
    
    //[self verifySignatureChainForUsers:users index:0 completion:^{
    success(users);
    //}];
  } failure:^(NSURLSessionDataTask *task, NSError *error) {
    failure(error);
  }];
}

- (void)usersPaginatedForKey:(NSString *)key values:(NSArray *)values fields:(NSString *)fields limit:(NSInteger)limit success:(void (^)(NSArray *users, BOOL completed))success failure:(KBClientErrorHandler)failure {
  __block NSError *pageError = nil;
  for (NSInteger offset = 0, count = [values count]; offset < count; offset += limit) {
    BOOL completed = NO;
    if ((offset + limit) >= count) {
      limit = count - offset;
      completed = YES;
    }
    NSValue *range = [NSValue valueWithRange:NSMakeRange(offset, limit)];
    NSArray *valuesChunk = values[range];
    
    if ([valuesChunk count] == 0) {
      success(@[], YES);
      return;
    }
    
    [self usersForKey:key value:[valuesChunk join:@","] fields:fields success:^(NSArray *users) {
      success(users, completed);
    } failure:^(NSError *error) {
      pageError = error;
      failure(error);
    }];
    
    if (completed) break;
    if (pageError) break;
  }
}

- (void)searchWithQuery:(NSString *)query success:(void (^)(NSArray *searchResults))success failure:(KBClientErrorHandler)failure {
  if ([NSString gh_isBlank:query]) {
    dispatch_async(dispatch_get_main_queue(), ^{ success(@[]); });
    return;
  }
  
  [self.httpManager GET:@"user/autocomplete.json" parameters:KBURLParameters(@{@"q": query}) success:^(NSURLSessionDataTask *task, id responseObject) {
    
    NSArray *completions = [responseObject gh_objectMaybeNilForKey:@"completions" ofClass:[NSArray class]];
    
    NSError *error = nil;
    NSArray *searchResults = [MTLJSONAdapter modelsOfClass:KBSearchResult.class fromJSONArray:completions error:&error];
    if (!searchResults) {
      failure(error);
      return;
    }
    
    success(searchResults);
    
  } failure:^(NSURLSessionDataTask *task, NSError *error) {
    failure(error);
  }];
}

- (void)checkSession:(KBSession *)session success:(void (^)(KBSession *session))success failure:(KBClientErrorHandler)failure {
  NSString *userName = session.sessionUser.userName;
  NSAssert(userName, @"No user name");
  
  GHWeakSelf blockSelf = self;
  [self sessionUser:^(KBSessionUser *sessionUser) {
    [blockSelf userForUserName:userName success:^(KBUser *user) {
      KBSession *session = [[KBSession alloc] initWithSessionUser:sessionUser user:user];
      success(session);
    } failure:failure];
  } failure:failure];
}

- (void)_keysForResponseObject:(NSDictionary *)responseObject success:(void (^)(NSArray */*of id<KBKey>*/keys))success failure:(KBClientErrorHandler)failure {
  NSArray *keyDicts = [responseObject gh_objectMaybeNilForKey:@"keys" ofClass:[NSArray class]];
  NSError *error = nil;
  NSMutableArray *keys = [NSMutableArray arrayWithCapacity:[keyDicts count]];
  for (NSDictionary *keyDict in keyDicts) {
    if ([keyDict[@"key_type"] integerValue] == 1) {
      KBPublicKey *publicKey = [MTLJSONAdapter modelOfClass:KBPublicKey.class fromJSONDictionary:keyDict error:&error];
      if (publicKey) [keys addObject:publicKey];
    } else if ([keyDict[@"key_type"] integerValue] == 2) {
      KBPrivateKey *keyPair = [MTLJSONAdapter modelOfClass:KBPrivateKey.class fromJSONDictionary:keyDict error:&error];
      if (keyPair) [keys addObject:keyPair];
    }
  }
  
  if (error) {
    failure(error);
    return;
  }
  
  success(keys);
}

- (void)keysForPGPKeyIds:(NSArray *)PGPKeyIds capabilities:(KBKeyCapabilities)capabilites success:(void (^)(NSArray */*of id<KBKey>*/keys))success failure:(KBClientErrorHandler)failure {
  GHWeakSelf blockSelf = self;
  [self.httpManager GET:@"key/fetch.json" parameters:KBURLParameters(@{@"pgp_key_ids": [PGPKeyIds join:@","], @"ops": @(capabilites)}) success:^(NSURLSessionDataTask *task, id responseObject) {
    [blockSelf _keysForResponseObject:responseObject success:success failure:failure];
  } failure:^(NSURLSessionDataTask *task, NSError *error) {
    if (error.code == KBErrorCodeKeyNotFound) {
      success(@[]);
    } else {
      failure(error);
    }
  }];
}

- (void)usersForPGPKeyIds:(NSArray *)PGPKeyIds success:(void (^)(NSArray */*of KBUser*/users))success failure:(KBClientErrorHandler)failure {
  [self.httpManager GET:@"key/fetch.json" parameters:KBURLParameters(@{@"pgp_key_ids": [PGPKeyIds join:@","]}) success:^(NSURLSessionDataTask *task, id responseObject) {
    
    NSArray *userNames = [responseObject[@"keys"] map:^id(NSDictionary *keyDict) { return keyDict[@"username"]; }];
    [self usersForKey:@"usernames" value:[userNames join:@","] fields:nil success:success failure:failure];
    
  } failure:^(NSURLSessionDataTask *task, NSError *error) {
    if (error.code == KBErrorCodeKeyNotFound) {
      success(@[]);
    } else {
      failure(error);
    }
  }];
}

- (void)updateProfileForSession:(KBSession *)session params:(NSDictionary *)params success:(void (^)(KBUser *user))success failure:(KBClientErrorHandler)failure {
  [self checkSession:session success:^(KBSession *session) {
    NSMutableDictionary *updates = [params mutableCopy];
    if (!updates[@"full_name"]) updates[@"full_name"] = GHOrNull(session.user.fullName);
    if (!updates[@"bio"]) updates[@"bio"] = GHOrNull(session.user.bio);
    if (!updates[@"location"]) updates[@"location"] = GHOrNull(session.user.location);
    updates[@"csrf_token"] = self.CSRFToken;

    [self.httpManager POST:@"profile-edit.json" parameters:KBURLParameters(updates) success:^(NSURLSessionDataTask *task, id responseObject) {
      [self userForKey:@"username" value:session.sessionUser.userName fields:nil success:^(KBUser *user) {
        success(user);
      } failure:failure];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
      failure(error);
    }];
  } failure:failure];
}

#pragma mark Signature

- (void)signaturesForUserId:(NSString *)userId sequenceNumber:(NSInteger)sequenceNumber success:(void (^)(NSArray *signatures))success failure:(KBClientErrorHandler)failure {
  [self.httpManager GET:@"sig/get.json" parameters:KBURLParameters(@{@"uid": userId, @"low": @(sequenceNumber)}) success:^(NSURLSessionDataTask *task, id responseObject) {
    
    NSError *error = nil;
    NSArray *signatures = [MTLJSONAdapter modelsOfClass:KBSignature.class fromJSONArray:responseObject[@"sigs"] error:&error];
    if (!signatures) {
      failure(error);
      return;
    }
    success(signatures);
    
  } failure:^(NSURLSessionDataTask *task, NSError *error) {
    failure(error);
  }];
}

- (void)nextSequence:(void (^)(NSNumber *sequenceNumber, NSString *previousBlockHash))success failure:(KBClientErrorHandler)failure {
  [self.httpManager GET:@"sig/next_seqno.json" parameters:KBURLParameters(@{@"type": @"PUBLIC"}) success:^(NSURLSessionDataTask *task, id responseObject) {
    NSNumber *sequenceNumber = responseObject[@"seqno"];
    NSString *previousBlockHash = responseObject[@"prev"];
    success(sequenceNumber, previousBlockHash);
  } failure:^(NSURLSessionDataTask *task, NSError *error) {
    failure(error);
  }];
}

- (void)createSignature:(NSString *)signature type:(NSString *)type remoteUserName:(NSString *)remoteUserName success:(void (^)(KBSignatureProof *signatureProof))success failure:(KBClientErrorHandler)failure {
  NSDictionary *params =
    @{
      @"csrf_token": self.CSRFToken,
      @"type": type,
      @"remote_username": remoteUserName,
      @"sig": signature,
      };
    
  [self.httpManager POST:@"sig/post.json" parameters:KBURLParameters(params) success:^(NSURLSessionDataTask *task, id responseObject) {
    NSError *error = nil;
    KBSignatureProof *signatureProof = [MTLJSONAdapter modelOfClass:KBSignatureProof.class fromJSONDictionary:responseObject error:&error];
    if (!signatureProof) {
      failure(error);
      return;
    }
    success(signatureProof);
  } failure:^(NSURLSessionDataTask *task, NSError *error) {
    failure(error);
  }];
}

- (void)postedWithProofId:(NSString *)proofId success:(dispatch_block_t)success failure:(KBClientErrorHandler)failure {
  NSDictionary *params = @{@"proof_id": proofId, @"csrf_token": self.CSRFToken};
  [self.httpManager POST:@"sig/posted.json" parameters:KBURLParameters(params) success:^(NSURLSessionDataTask *task, id responseObject) {
    success();
  } failure:^(NSURLSessionDataTask *task, NSError *error) {
    failure(error);
  }];
}

#pragma mark Verification

/*!
 Verify signature chain.
 
 For each link in the chain, check that SHA256(payload_json) == payload_hash.
 Check that the payload_hash of a link is equal to "prev" in the next link.
 For the last (tail), verify the signature, and verify that payload_json is actually what's been signed.
 
 We apply revocations, so the chain is compressed.
 We stop checking signatures if we reach a different key (we check from the tail to the start).
 
 */
- (void)verifySignatures:(NSArray *)signatures user:(KBUser *)user completion:(void (^)(NSError *error))completion {
  if ([signatures count] == 0) {
    completion(nil);
    return;
  }

  [self _verifySignatures:signatures user:user index:[signatures count]-1 completion:^(NSError *error) {
    if (error) {
      user.signatures = nil;
      completion(error);
      return;
    }
    
    // Apply the signatures to the user
    NSMutableArray *signaturesJoined = [user.signatures mutableCopy];
    if (!signaturesJoined) signaturesJoined = [NSMutableArray array];
    [signaturesJoined addObjectsFromArray:signatures];
    
    user.signatures = signaturesJoined;
    user.dateSignaturesVerified = [NSDate date];
    completion(nil);
  }];
  
}

- (void)_verifySignatures:(NSArray *)signatures user:(KBUser *)user index:(NSInteger)index completion:(void (^)(NSError *error))completion {
  if (index == -1) {
    completion(nil);
    return;
  }

  KBSignature *signature = signatures[index];
  KBSignature *previousSignature = index > 0 ? signatures[index-1] : nil;
  
  //GHDebug(@"Checking sig (%d): %@", (int)index, signature.identifier);

  // If we reach a signature with a different key, lets stop
  if (![signature.keyFingerprint isEqualToString:user.key.fingerprint]) {
    completion(nil);
    return;
  }
  
  NSString *payloadHash = [[NADigest digestForData:GHStringData(signature.payloadJSONString) algorithm:NADigestAlgorithmSHA2_256] na_hexString];
  if (![signature.payloadHash isEqualToString:payloadHash]) {
    completion(KBSignatureError(KBSignatureErrorInvalidPayloadHash, @"Invalid payload hash"));
    return;
  }
  
  if (previousSignature) {
    if (![signature.previousPayloadHash isEqualToString:previousSignature.payloadHash]) {
      completion(KBSignatureError(KBSignatureErrorInvalidPreviousPayloadHash, @"Invalid previous payload hash"));
      return;
    }
  }

  // Only need to verify signature on last item
  if (index == [signatures count]-1) {
    NSAssert(_crypto, @"No crypto set, can't verify");
  
    [_crypto verifyMessageArmored:signature.signatureArmored success:^(KBPGPMessage *message) {
      if (![[message.signers valueForKey:@"keyFingerprint"] containsObject:signature.keyFingerprint]) {
        completion(KBSignatureError(KBSignatureErrorInvalidSignature, @"Not signed by specified key fingerprint"));
        return;
      }
      
      if (![message.text isEqualToString:signature.payloadJSONString]) {
        completion(KBSignatureError(KBSignatureErrorInvalidSignature, @"Invalid signature; data not equal"));
        return;
      }
      
      [self _verifySignatures:signatures user:user index:index-1 completion:completion];
    } failure:completion];
  } else {
    [self _verifySignatures:signatures user:user index:index-1 completion:completion];
  }
}

#pragma mark KBResponseSerializerDelegate

- (void)responseSerializer:(KBResponseSerializer *)responseSerializer didUpdateCSRFToken:(NSString *)CSRFToken {
  self.CSRFToken = CSRFToken;
}

@end
