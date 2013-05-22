/*
 *  NSValue+Compatibility.m
 *  PathFinder
 *
 *  Created by bearkode on 13. 5. 22..
 *  Copyright (c) 2013 bearkode. All rights reserved.
 *
 */

#import "NSValue+Compatibility.h"


@implementation NSValue (Compatibility)


#if TARGET_OS_IPHONE

#else


+ (NSValue *)valueWithCGPoint:(CGPoint)aPoint
{
    return [NSValue valueWithBytes:&aPoint objCType:@encode(CGPoint)];
}


- (CGPoint)CGPointValue
{
    CGPoint sResult;

    [self getValue:&sResult];
    
    return sResult;
}


#endif

@end
