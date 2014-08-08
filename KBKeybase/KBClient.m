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

NSString *const KBAPILocalHost = @"http://localhost:3000/_/api/1.0/";
NSString *const KBAPIKeybaseIOHost = @"https://keybase.io/_/api/1.0/";

NSString *KBServerURLString(NSString *APIHost, NSString *path) {
  if (!path) return APIHost;
  return [NSString stringWithFormat:@"%@%@", APIHost, path];
}

NSURL *KBServerURL(NSString *APIHost, NSString *path) {
  return [NSURL URLWithString:KBServerURLString(APIHost, path)];
}

NSDictionary *KBURLParameters(NSDictionary *params) {
  NSMutableDictionary *parameters = [NSMutableDictionary gh_dictionaryWithKeysAndObjectsMaybeNil:nil];
  if (params) [parameters addEntriesFromDictionary:params];
  [parameters addEntriesFromDictionary:parameters];
  [parameters gh_mutableCompact];
  return parameters;
}

@interface KBClient ()
@property NSString *APIHost;
@property NSString *CSRFToken;
@end

@implementation KBClient

- (instancetype)init {
  [NSException raise:NSInvalidArgumentException format:@"Use initWithAPIHost:"];
  return nil;
}

- (instancetype)initWithAPIHost:(NSString *)APIHost {
  if ((self = [super init])) {
    _APIHost = APIHost;
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
    GHDebug(@"Removing cookie: %@", cookie);
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
  NSData *HMACpwh = [NAHMAC HMACForKey:pwh data:loginSessionData algorithm:NAHMACAlgorithmSHA512];
  
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

- (void)signUpWithName:(NSString *)name email:(NSString *)email userName:(NSString *)userName password:(NSString *)password invitationId:(NSString *)invitationId success:(void (^)(KBSession *session))success failure:(KBClientErrorHandler)failure {
  NSParameterAssert(name);
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
  NSDictionary *params = @{@"name": name, @"email": email, @"username": userName, @"pwh": pwh, @"salt": [salt na_hexString], @"invitation_id": invitationId, @"pwh_version": @(3)};
  
  GHWeakSelf blockSelf = self;
  [self.httpManager POST:@"signup.json" parameters:KBURLParameters(params) success:^(NSURLSessionDataTask *task, id responseObject) {
    [blockSelf logInWithEmailOrUserName:userName password:password success:success failure:failure];
  } failure:^(NSURLSessionDataTask *task, NSError *error) {
    failure(error);
  }];
}

- (void)pushPrivateKey:(P3SKB *)privateKey success:(dispatch_block_t)success failure:(KBClientErrorHandler)failure {
  NSAssert(self.CSRFToken, @"Missing CSRF");
  
  NSDictionary *params = @{@"private_key": [[privateKey data] base64EncodedStringWithOptions:0], @"csrf_token": self.CSRFToken, @"is_primary": @(YES)};
  
  GHWeakSelf blockSelf = self;
  [self.httpManager POST:@"key/add.json" parameters:KBURLParameters(params) success:^(NSURLSessionDataTask *task, id responseObject) {    
    
    [blockSelf sessionUser:^(KBSessionUser *sessionUser) {
      success();
    } failure:failure];
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

- (void)userForUserName:(NSString *)userName success:(void (^)(KBUser *user))success failure:(KBClientErrorHandler)failure {
  NSParameterAssert(userName);
  [self.httpManager GET:@"user/lookup.json" parameters:KBURLParameters(@{@"username": userName}) success:^(NSURLSessionDataTask *task, id responseObject) {
    
    NSDictionary *themDict = [responseObject gh_objectMaybeNilForKey:@"them" ofClass:[NSDictionary class]];
    
    NSError *error = nil;
    KBUser *user = [MTLJSONAdapter modelOfClass:KBUser.class fromJSONDictionary:themDict error:&error];
    if (!user) {
      failure(error);
      return;
    }

    success(user);
  } failure:^(NSURLSessionDataTask *task, NSError *error) {
    failure(error);
  }];
}

- (void)usersPaginatedForUserNames:(NSArray *)userNames success:(void (^)(NSArray *users, BOOL completed))success failure:(KBClientErrorHandler)failure {
  NSInteger length = 10;
  for (NSInteger offset = 0, count = [userNames count]; offset < count; offset += length) {
    BOOL completed = NO;
    if ((offset + length) >= count) {
      length = count - offset;
      completed = YES;
    }
    NSValue *range = [NSValue valueWithRange:NSMakeRange(offset, length)];
    NSArray *userNamesChunk = userNames[range];
    
    [self usersForUserNames:userNamesChunk success:^(NSArray *users) {
      success(users, completed);
    } failure:failure];
    
    if (completed) break;
  }
}

- (void)usersForUserNames:(NSArray *)userNames success:(void (^)(NSArray *users))success failure:(KBClientErrorHandler)failure {
  [self.httpManager GET:@"user/lookup.json" parameters:KBURLParameters(@{@"usernames": [userNames join:@","]}) success:^(NSURLSessionDataTask *task, id responseObject) {
    
    NSArray *themDicts = [[responseObject gh_objectMaybeNilForKey:@"them" ofClass:[NSArray class]] gh_compact];
    
    NSError *error = nil;
    NSArray *users = [MTLJSONAdapter modelsOfClass:KBUser.class fromJSONArray:themDicts error:&error];
    if (!users) {
      failure(error);
      return;
    }
    
    success(users);
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

- (void)keysForKIDs:(NSArray *)KIDs capabilities:(KBKeyCapabilities)capabilites success:(void (^)(NSArray */*of id<KBKey>*/keys))success failure:(KBClientErrorHandler)failure {
  GHWeakSelf blockSelf = self;
  [self.httpManager GET:@"key/fetch.json" parameters:KBURLParameters(@{@"kids": [KIDs join:@","], @"ops": @(capabilites)}) success:^(NSURLSessionDataTask *task, id responseObject) {
    [blockSelf _keysForResponseObject:responseObject success:success failure:failure];
  } failure:^(NSURLSessionDataTask *task, NSError *error) {
    failure(error);
  }];
}

- (void)keysForPGPKeyIds:(NSArray *)PGPKeyIds capabilities:(KBKeyCapabilities)capabilites success:(void (^)(NSArray */*of id<KBKey>*/keys))success failure:(KBClientErrorHandler)failure {
  GHWeakSelf blockSelf = self;
  [self.httpManager GET:@"key/fetch.json" parameters:KBURLParameters(@{@"pgp_key_ids": [PGPKeyIds join:@","], @"ops": @(capabilites)}) success:^(NSURLSessionDataTask *task, id responseObject) {
    [blockSelf _keysForResponseObject:responseObject success:success failure:failure];
  } failure:^(NSURLSessionDataTask *task, NSError *error) {
    failure(error);
  }];
}

#pragma mark KBResponseSerializerDelegate

- (void)responseSerializer:(KBResponseSerializer *)responseSerializer didUpdateCSRFToken:(NSString *)CSRFToken {
  self.CSRFToken = CSRFToken;
}

@end
