/*
 *  PEGrid.h
 *  PathFinder
 *
 *  Created by bearkode on 13. 5. 20..
 *  Copyright (c) 2013 bearkode. All rights reserved.
 *
 */

#import <Foundation/Foundation.h>


@class PEPathNode;


static inline void PEAddObjectIfNotNil(NSMutableArray *aArray, id aObject)
{
    if (aObject)
    {
        [aArray addObject:aObject];
    }
}


static inline PEPathNode *PENodeAtPosition(id *aNodes, CGSize aSize, CGPoint aPoint)
{
    if ((aPoint.x >= 0 && aPoint.x < aSize.width) && (aPoint.y >= 0 && aPoint.y < aSize.height))
    {
        return aNodes[(int)(aSize.width * aPoint.y + aPoint.x)];
    }
    else
    {
        return nil;
    }
}


static inline BOOL PEIsWalkableAtPosition(unsigned char *aWalkables, CGSize aSize, CGPoint aPoint)
{
    if ((aPoint.x >= 0 && aPoint.x < aSize.width) && (aPoint.y >= 0 && aPoint.y < aSize.height))
    {
        return aWalkables[(int)(aSize.width * aPoint.y + aPoint.x)];
    }
    else
    {
        return NO;
    }
}


@interface PEGrid : NSObject
{
@public
    CGSize         mSize;
    id            *mNodes;
    unsigned char *mWalkable;
}


- (id)initWithSize:(CGSize)aSize matrix:(unsigned char *)aMatrix;

- (void)setMatrix:(unsigned char *)aMatrix;
- (void)reset;

- (PEPathNode *)nodeAtPosition:(CGPoint)aPosition;

- (void)getNeighborsOfNode:(PEPathNode *)aNode result:(id *)aResult count:(NSInteger *)aCount;
- (NSMutableArray *)neighborsWith:(PEPathNode *)aNode allowDiagonal:(BOOL)aAllowDiagonal dontCrossCorners:(BOOL)aDontCrossCorners;

- (BOOL)isWalkableAtPosition:(CGPoint)aPosition;


- (unsigned char *)walkableBytes;
- (id *)nodesBytes;
- (CGSize)mapSize;


@end
