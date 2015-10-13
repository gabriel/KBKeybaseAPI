//
//  KBImage.h
//  KBKeybaseAPI
//
//  Created by Gabriel on 6/26/14.
//  Copyright (c) 2014 Gabriel Handford. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Mantle/Mantle.h>

//struct KBCGSize {
//  float width;
//  float height;
//};
//typedef struct KBSize KBSize;


@interface KBImage : MTLModel <MTLJSONSerializing>

@property (readonly) NSString *URLString;
//@property (readonly) KBSize size;
@property (readonly) float width;
@property (readonly) float height;

- (instancetype)initWithURLString:(NSString *)URLString;

@end


//@interface KBSizeValueTransformer : NSValueTransformer
//@end
