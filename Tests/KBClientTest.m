//
//  MyTest.m
//
#import <GRUnit/GRUnit.h>

#import "KBKeybase.h"
#import <KBCrypto/KBCrypto.h>

@interface KBClientTest : GRTestCase
@end

@implementation KBClientTest

- (void)testLogIn:(dispatch_block_t)completion {
  KBClient *client = [[KBClient alloc] initWithAPIHost:KBAPILocalHost];
  [client logInWithEmailOrUserName:@"gabrielhlocal2" password:@"toomanysecrets" success:^(KBSession *session) {
    completion();
  } failure:GRUErrorHandler(self)];
}

@end