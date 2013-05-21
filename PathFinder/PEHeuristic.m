//
//  PEHeuristic.m
//  PathFinder
//
//  Created by cgkim on 13. 5. 20..
//  Copyright (c) 2013년 cgkim. All rights reserved.
//

#import "PEHeuristic.h"


@implementation PEHeuristic


+ (CGFloat)manhattan:(CGPoint)aDiff
{
    return aDiff.x + aDiff.y;
}


+ (CGFloat)euclidean:(CGPoint)aDiff
{
    return sqrtf(aDiff.x * aDiff.x + aDiff.y * aDiff. y);
}


+ (CGFloat)chebyshev:(CGPoint)aDiff
{
    return MAX(aDiff.x, aDiff.y);
}


@end
