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
           @"nameTag": @"nametag",
           @"proofType": @"proof_type",
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

@end
