/*
 *  PECommonUtil.h
 *  PathFinder
 *
 *  Created by bearkode on 13. 5. 21..
 *  Copyright (c) 2013 bearkode. All rights reserved.
 *
 */

#import <Foundation/Foundation.h>


#define PEBeginTimeCheck()           double __sCurrentTime = CACurrentMediaTime()
#define PEEndTimeCheck()             NSLog(@"time = %f", CACurrentMediaTime() - __sCurrentTime)


#if TARGET_OS_IPHONE

#else

static inline NSString *NSStringFromCGPoint(CGPoint aPoint)
{
    return [NSString stringWithFormat:@"{%f, %f}", aPoint.x, aPoint.y];
}

#endif


@interface PECommonUtil : NSObject

@end
