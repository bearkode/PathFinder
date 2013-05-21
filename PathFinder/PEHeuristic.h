//
//  PEHeuristic.h
//  PathFinder
//
//  Created by cgkim on 13. 5. 20..
//  Copyright (c) 2013년 cgkim. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PEHeuristic : NSObject


+ (CGFloat)manhattan:(CGPoint)aDiff;
+ (CGFloat)euclidean:(CGPoint)aDiff;


@end
