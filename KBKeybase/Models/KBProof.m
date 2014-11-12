//
//  KBTwitter.m
//  Keybase
//
//  Created by Gabriel on 7/10/14.
//  Copyright (c) 2014 Gabriel Handford. All rights reserved.
//

#import "KBProof.h"

#import <GHKit/GHKit.h>
#import <ObjectiveSugar/ObjectiveSugar.h>

@implementation KBProof

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
  return @{
           @"identifier": @"proof_id",
           @"signatureId": @"sig_id",
           @"nameTag": @"nametag",
           @"proofType": @"proof_type",
           @"humanURLString": @"human_url",
           @"dateVerified": NSNull.null,
           @"verifyError": NSNull.null,
           };
}

+ (NSValueTransformer *)proofTypeJSONTransformer {
  NSDictionary *mapping = @{
                            @"github": @(KBProofTypeGithub),
                            @"twitter": @(KBProofTypeTwitter),
                            @"reddit": @(KBProofTypeReddit),
                            @"coinbase": @(KBProofTypeCoinbase),
                            @"hackernews": @(KBProofTypeHackerNews),
                            @"dns": @(KBProofTypeDNS),
                            @"generic_web_site": @(KBProofTypeGenericWebSite),
                            };
  return [NSValueTransformer mtl_valueMappingTransformerWithDictionary:mapping defaultValue:@(KBProofTypeUnknown) reverseDefaultValue:nil];
}

- (NSString *)displayDescription {
  return _nameTag;
}

- (NSString *)URLString {
  if (!_nameTag) return nil;
  
  switch (_proofType) {
    case KBProofTypeTwitter:
      return [NSString stringWithFormat:@"https://twitter.com/%@", _nameTag];
    case KBProofTypeGithub:
      return [NSString stringWithFormat:@"https://github.com/%@", _nameTag];
    case KBProofTypeReddit:
      return [NSString stringWithFormat:@"https://www.reddit.com/user/%@", _nameTag];
    case KBProofTypeDNS:
      return _nameTag;
    case KBProofTypeGenericWebSite:
      return _nameTag;
    default:
      return nil;
  }
}

- (NSString *)proofHost {
  switch (_proofType) {
    case KBProofTypeTwitter: return @"twitter.com";
    case KBProofTypeGithub: return @"github.com";
    case KBProofTypeReddit: return @"reddit.com";
    case KBProofTypeCoinbase: return @"coinbase.com";
    case KBProofTypeHackerNews: return @"news.ycombinator.com";
    case KBProofTypeGenericWebSite: return _nameTag;
    case KBProofTypeDNS: return _nameTag;
    default:
      return nil;
  }
}

- (BOOL)isURLStringValid {
  NSString *validHost = [self proofHost];
  
  NSURL *URL = [NSURL URLWithString:_humanURLString];
  //if (![[URL.scheme lowercaseString] isEqualToString:@"https"]) return NO;
  
  if (!([[URL.host lowercaseString] isEqualToString:validHost] ||
        [[URL.host lowercaseString] gh_endsWith:NSStringWithFormat(@".%@", validHost) options:0])) return NO;
  
  return YES;
}

- (NSUInteger)hash {
  return [_identifier hash];
}

- (BOOL)isEqual:(id)object {
  return ([object isKindOfClass:KBProof.class] && [[object identifier] isEqualToString:_identifier]);
}

@end
