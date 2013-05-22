/*
 *  NSValue+Compatibility.h
 *  PathFinder
 *
 *  Created by bearkode on 13. 5. 22..
 *  Copyright (c) 2013 bearkode. All rights reserved.
 *
 */

#import <Foundation/Foundation.h>


@interface NSValue (Compatibility)


#if TARGET_OS_IPHONE

#else

+ (NSValue *)valueWithCGPoint:(CGPoint)aPoint;
- (CGPoint)CGPointValue;

#endif


@end
