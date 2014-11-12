//
//  KBDNSQuery.h
//  KBKeybase
//
//  Created by Gabriel on 11/11/14.
//  Copyright (c) 2014 Gabriel Handford. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^KBDNSCompletionHandler)(NSError *error, NSArray *records);

@interface KBDNSQuery : NSObject

- (void)TXTRecordsWithName:(NSString *)name completion:(KBDNSCompletionHandler)completion;

@end
