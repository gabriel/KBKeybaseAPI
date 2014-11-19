//
//  KBSerialBox.h
//  KBKeybase
//
//  Created by Gabriel on 11/18/14.
//  Copyright (c) 2014 Gabriel Handford. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^KBSerialBoxRunBlock)(id obj, BOOL finished, dispatch_block_t completion);
typedef void (^KBSerialBoxCompletionBlock)(NSArray *objs);

@interface KBSerialBox : NSObject

@property NSArray *objects;
@property (copy) KBSerialBoxRunBlock runBlock;
@property (copy) KBSerialBoxCompletionBlock completionBlock;

- (void)run;

@end
