/*
 *  PEHeuristic.h
 *  PathFinder
 *
 *  Created by bearkode on 13. 5. 20..
 *  Copyright (c) 2013 bearkode. All rights reserved.
 *
 */

#import <Foundation/Foundation.h>


static inline CGFloat PEHeuristicManhattan(CGFloat x, CGFloat y)
{
    return x + y;
}


static inline CGFloat PEHeuristicEuclidean(CGFloat x, CGFloat y)
{
    return sqrtf(x * x + y * y);
}


@interface PEHeuristic : NSObject


+ (CGFloat)manhattan:(CGPoint)aDiff;
+ (CGFloat)euclidean:(CGPoint)aDiff;
+ (CGFloat)chebyshev:(CGPoint)aDiff;


@end
