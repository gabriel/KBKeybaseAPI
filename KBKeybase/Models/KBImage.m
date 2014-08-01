//
//  KBImage.m
//  Keybase
//
//  Created by Gabriel on 6/26/14.
//  Copyright (c) 2014 Gabriel Handford. All rights reserved.
//

#import "KBImage.h"

@implementation KBImage

- (instancetype)initWithURLString:(NSString *)URLString {
  if ((self = [super init])) {
    _URLString = URLString;
  }
  return self;
}

- (NSString *)URLStringForWidth:(float)width {
  return _URLString;
}

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
  return @{
           @"URLString": @"url",
           //@"size": @[@"width", @"height"],
           @"width": @"width",
           @"height": @"height",
           };
}

//+ (NSValueTransformer *)sizeJSONTransformer {
//  return [MTLValueTransformer transformerUsingForwardBlock:^(NSDictionary *size, BOOL *success, NSError **error) {
//    KBSize result = {
//      .width = [size[@"width"] floatValue],
//      .height = [size[@"height"] floatValue]
//    };
//    
//    return [NSValue valueWithCGSize:result];
//  }];
//}

@end
