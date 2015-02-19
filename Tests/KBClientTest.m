//
//  MyTest.m
//
#import <GRUnit/GRUnit.h>

#import "KBKeybase.h"

@interface KBClientTest : GRTestCase
@end

@implementation KBClientTest

- (void)test:(dispatch_block_t)completion {
  KBAPIClient *client = [[KBAPIClient alloc] initWithAPIHost:KBAPIKeybaseIOHost crypto:nil];
  [client logInWithEmailOrUserName:@"gbrl24" password:@"toomanysecrets" success:^(KBSession *session) {
    GRAssertEqualObjects(client.session, session);
    [client nextSequence:^(NSNumber *sequenceNumber, NSString *previousBlockHash) {
      completion();
    } failure:GRErrorHandler];
  } failure:GRErrorHandler];
}

@end
