//
//  PEFinder.h
//  PathFinder
//
//  Created by cgkim on 13. 5. 20..
//  Copyright (c) 2013년 cgkim. All rights reserved.
//

#import <Foundation/Foundation.h>


@class PEGrid;


@interface PEFinder : NSObject

- (NSMutableArray *)findPathWithStartPosition:(CGPoint)aStartPosition endPosition:(CGPoint)aEndPosition grid:(PEGrid *)aGrid;

@end
