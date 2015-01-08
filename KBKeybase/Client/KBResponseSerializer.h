//
//  KBResponseSerializer.h
//  Keybase
//
//  Created by Gabriel on 6/19/14.
//  Copyright (c) 2014 Gabriel Handford. All rights reserved.
//

#import <AFNetworking/AFNetworking.h>

@class KBResponseSerializer;

@protocol KBResponseSerializerDelegate
- (void)responseSerializer:(KBResponseSerializer *)responseSerializer didUpdateCSRFToken:(NSString *)CSRFToken;
@end

@interface KBResponseSerializer : AFJSONResponseSerializer

@property (weak) id<KBResponseSerializerDelegate> delegate;

@end
