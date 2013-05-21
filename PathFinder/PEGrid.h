//
//  PEGrid.h
//  PathFinder
//
//  Created by cgkim on 13. 5. 20..
//  Copyright (c) 2013년 cgkim. All rights reserved.
//

#import <Foundation/Foundation.h>


@class PENode;


@interface PEGrid : NSObject


- (id)initWithSize:(CGSize)aSize matrix:(unsigned char *)aMatrix;

- (PENode *)nodeAtPosition:(CGPoint)aPosition;
- (NSMutableArray *)neighborsWith:(PENode *)aNode allowDiagonal:(BOOL)aAllowDiagonal dontCrossCorners:(BOOL)aDontCrossCorners;
- (BOOL)isWalkableAtPosition:(CGPoint)aPosition;

@end
