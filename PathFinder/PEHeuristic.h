/*
 *  PEHeuristic.h
 *  PathFinder
 *
 *  Created by bearkode on 13. 5. 20..
 *  Copyright (c) 2013 bearkode. All rights reserved.
 *
 */

#import <Foundation/Foundation.h>


@interface PEHeuristic : NSObject


+ (CGFloat)manhattan:(CGPoint)aDiff;
+ (CGFloat)euclidean:(CGPoint)aDiff;
+ (CGFloat)chebyshev:(CGPoint)aDiff;


@end
