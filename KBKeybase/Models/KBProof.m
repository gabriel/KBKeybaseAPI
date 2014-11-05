//
//  KBTwitter.m
//  Keybase
//
//  Created by Gabriel on 7/10/14.
//  Copyright (c) 2014 Gabriel Handford. All rights reserved.
//

#import "KBProof.h"

@implementation KBProof

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
  return @{
           @"identifier": @"proof_id",
           @"nameTag": @"nametag",
           @"proofType": @"proof_type",
           @"humanURLString": @"human_url",
           @"proofURLString": @"proof_url"
           };
}

+ (NSValueTransformer *)proofTypeJSONTransformer {
  NSDictionary *mapping = @{
                            @"github": @(KBProofTypeGithub),
                            @"twitter": @(KBProofTypeTwitter),
                            @"reddit": @(KBProofTypeReddit),
                            @"coinbase": @(KBProofTypeCoinbase),
                            @"hacker_news": @(KBProofTypeHackerNews),
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

@end
