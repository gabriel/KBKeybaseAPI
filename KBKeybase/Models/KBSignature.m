//
//  KBSignature.m
//  Keybase
//
//  Created by Gabriel on 7/14/14.
//  Copyright (c) 2014 Gabriel Handford. All rights reserved.
//

#import "KBSignature.h"

#import <GHKit/GHKit.h>
#import <ObjectiveSugar/ObjectiveSugar.h>

@implementation KBSignature

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
  return @{
           @"sequenceNumber": @"seqno",
           @"identifier": @"sig_id",
           @"payload": @"payload_json",
           @"payloadJSONString": @"payload_json",
           @"signatureArmored": @"sig",
           @"payloadHash": @"payload_hash",
           @"previousPayloadHash": @"prev",
           };
}

- (KBSignatureType)signatureType {
  NSString *typeString = [[_payload gh_objectMaybeNilForKey:@"body"] gh_objectMaybeNilForKey:@"type"];
  if ([typeString isEqualToString:@"track"]) return KBSignatureTypeTrack;
  if ([typeString isEqualToString:@"revoke"]) return KBSignatureTypeRevoke;
  if ([typeString isEqualToString:@"web_service_binding"]) return KBSignatureTypeWebServiceBinding;
  if ([typeString isEqualToString:@"cryptocurrency"]) return KBSignatureTypeCryptocurrency;
  
  return KBSignatureTypeUnkown;
}

+ (NSValueTransformer *)payloadJSONTransformer {
  return [MTLValueTransformer transformerWithBlock:^id(NSString *payloadJSON) {
    NSData *data = [payloadJSON dataUsingEncoding:NSUTF8StringEncoding];
    return [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
  }];
}

- (NSString *)keyUserName {
  return [[[_payload gh_objectMaybeNilForKey:@"body"] gh_objectMaybeNilForKey:@"key"] gh_objectMaybeNilForKey:@"username"];
}

- (NSString *)keyFingerprint {
  return [[[_payload gh_objectMaybeNilForKey:@"body"] gh_objectMaybeNilForKey:@"key"] gh_objectMaybeNilForKey:@"fingerprint"];
}

#pragma mark -

- (NSString *)descriptionForType {
  switch (self.signatureType) {
    case KBSignatureTypeTrack: return NSStringWithFormat(@"Track %@", self.trackUserName);
    case KBSignatureTypeRevoke: return NSStringWithFormat(@"Revoke %@", self.revokeSignatureId);
    case KBSignatureTypeWebServiceBinding: return NSStringWithFormat(@"Service %@", self.service);
      case KBSignatureTypeCryptocurrency: return NSStringWithFormat(@"Cryptocurrency %@", self.cryptocurrency);
    default:
      return @"Unknown";
  }
}

- (NSString *)trackUserName {
  return [[[[_payload gh_objectMaybeNilForKey:@"body"] gh_objectMaybeNilForKey:@"track"] gh_objectMaybeNilForKey:@"basics"] gh_objectMaybeNilForKey:@"username"];
}

- (NSString *)revokeSignatureId {
  return [[[_payload gh_objectMaybeNilForKey:@"body"] gh_objectMaybeNilForKey:@"revoke"] gh_objectMaybeNilForKey:@"sig_id"];
}

- (NSDictionary *)service {
  return [[_payload gh_objectMaybeNilForKey:@"body"] gh_objectMaybeNilForKey:@"service"];
}

- (NSDictionary *)cryptocurrency {
  return [[_payload gh_objectMaybeNilForKey:@"body"] gh_objectMaybeNilForKey:@"cryptocurrency"];
}

@end
