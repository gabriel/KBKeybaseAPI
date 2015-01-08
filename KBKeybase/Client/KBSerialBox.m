//
//  KBSerialBox.m
//  KBKeybase
//
//  Created by Gabriel on 11/18/14.
//  Copyright (c) 2014 Gabriel Handford. All rights reserved.
//

#import "KBSerialBox.h"

#import <GHKit/GHKit.h>

@interface KBSerialBox ()
@property NSInteger index;
@end

@implementation KBSerialBox

- (void)next {
  GHWeakSelf blockSelf = self;
  BOOL isLast = (_index + 1) == [_objects count];
  self.runBlock(_objects[_index++], isLast, ^(NSError *error) {
    if (blockSelf.index < [blockSelf.objects count]) {
      // Maybe dispatch_async so we don't blow the stack?
      [self next];
    } else {
      self.completionBlock(blockSelf.objects);
    }
  });
}

- (void)run {
  if ([_objects count] == 0) {
    self.completionBlock(@[]);
    return;
  }
  
  [self next];
}

@end