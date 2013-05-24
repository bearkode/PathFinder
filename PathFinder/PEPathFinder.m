/*
 *  PEPathFinder.m
 *  PathFinder
 *
 *  Created by bearkode on 13. 5. 20..
 *  Copyright (c) 2013 bearkode. All rights reserved.
 *
 */

#import "PEPathFinder.h"
#import "PEGrid.h"
#import "PEPathNode.h"
#import "PEOpenList.h"
#import "NSValue+Compatibility.h"
#import "PECommonUtil.h"


#define IS_WALKABLE(a)  PEIsWalkableAtPosition(sWalkable, sMapSize, a)


static inline CGFloat PEHeuristicManhattan(CGFloat x, CGFloat y)
{
    return x + y;
}


static inline CGFloat PEHeuristicEuclidean(CGFloat x, CGFloat y)
{
    return sqrtf(x * x + y * y);
}


PEPathNode *PEFindJumpNode(PEGrid *aGrid, PEPathNode *aEndNode, CGFloat aX, CGFloat aY, CGFloat aPX, CGFloat aPY)
{
    unsigned char *sWalkable = [aGrid walkableBytes];
    id            *sNodes    = [aGrid nodesBytes];
    CGSize         sMapSize  = [aGrid mapSize];
    
    CGFloat sNormalizedX     = aX - aPX;
    CGFloat sNormalizedY     = aY - aPY;
    CGPoint sCurruntPoint    = CGPointMake(aX, aY);
    
    if (!PEIsWalkableAtPosition(sWalkable, sMapSize, sCurruntPoint))
    {
        return nil;
    }
    else if (PENodeAtPosition(sNodes, sMapSize, sCurruntPoint) == aEndNode)
    {
        return PENodeAtPosition(sNodes, sMapSize, sCurruntPoint);
    }
    
    /*  check for forced neighbors along the diagonal  */
    if (sNormalizedX != 0 && sNormalizedY != 0)
    {
        if ((IS_WALKABLE(CGPointMake(aX - sNormalizedX, aY + sNormalizedY)) && !IS_WALKABLE(CGPointMake(aX - sNormalizedX, aY))) ||
            (IS_WALKABLE(CGPointMake(aX + sNormalizedX, aY - sNormalizedY)) && !IS_WALKABLE(CGPointMake(aX, aY - sNormalizedY))))
        {
            return PENodeAtPosition(sNodes, sMapSize, sCurruntPoint);
        }
        
        /*  when moving diagonally, must check for vertical/horizontal jump points  */
        PEPathNode *sJumpNodeX = PEFindJumpNode(aGrid, aEndNode, (aX + sNormalizedX), aY, aX, aY);
        PEPathNode *sJumpNodeY = PEFindJumpNode(aGrid, aEndNode, aX, (aY + sNormalizedY), aX, aY);
        
        if (sJumpNodeX || sJumpNodeY)
        {
            return PENodeAtPosition(sNodes, sMapSize, sCurruntPoint);
        }
    }
    else  /*  horizontally/vertically  */
    {
        if (sNormalizedX != 0 )  /*  moving along x  */
        {
            if ((IS_WALKABLE(CGPointMake(aX + sNormalizedX, aY + 1)) && !IS_WALKABLE(CGPointMake(aX, aY + 1))) ||
                (IS_WALKABLE(CGPointMake(aX + sNormalizedX, aY - 1)) && !IS_WALKABLE(CGPointMake(aX, aY - 1))))
            {
                return PENodeAtPosition(sNodes, sMapSize, sCurruntPoint);
            }
        }
        else
        {
            if ((IS_WALKABLE(CGPointMake(aX + 1, aY + sNormalizedY)) && !IS_WALKABLE(CGPointMake(aX + 1, aY))) ||
                (IS_WALKABLE(CGPointMake(aX - 1, aY + sNormalizedY)) && !IS_WALKABLE(CGPointMake(aX - 1, aY))))
            {
                return PENodeAtPosition(sNodes, sMapSize, sCurruntPoint);
            }
        }
    }
    
    /*  moving diagonally, must make sure one of the vertical/horizontal neighbors is open to allow the path  */
    if (IS_WALKABLE(CGPointMake(aX + sNormalizedX, aY)) || IS_WALKABLE(CGPointMake(aX, aY + sNormalizedY)))
    {
        return PEFindJumpNode(aGrid, aEndNode, (aX + sNormalizedX), (aY + sNormalizedY), aX, aY);
    }
    else
    {
        return nil;
    }
}


@implementation PEPathFinder
{
    PEOpenList *mOpenList;
    PEGrid     *mGrid;
    PEPathNode *mStartNode;
    PEPathNode *mEndNode;
}


- (void)dealloc
{
    [mOpenList release];
    [mGrid release];
    [mStartNode release];
    [mEndNode release];
    
    [super dealloc];
}


- (void)setOpenList:(PEOpenList *)aOpenList
{
    [mOpenList autorelease];
    mOpenList = [aOpenList retain];
}


- (void)setGrid:(PEGrid *)aGrid
{
    [mGrid autorelease];
    mGrid = [aGrid retain];
}


- (PEGrid *)grid
{
    return mGrid;
}


- (void)setStartNode:(PEPathNode *)aNode
{
    [mStartNode autorelease];
    mStartNode = [aNode retain];
}


- (void)setEndNode:(PEPathNode *)aNode
{
    [mEndNode autorelease];
    mEndNode = [aNode retain];
}


- (PEPathNode *)endNode
{
    return mEndNode;
}


#pragma mark -


- (NSMutableArray *)findPathWithStartPosition:(CGPoint)aStartPosition endPosition:(CGPoint)aEndPosition grid:(PEGrid *)aGrid
{
    [self setGrid:aGrid];
    [self setOpenList:[[[PEOpenList alloc] init] autorelease]];
    [self setStartNode:[aGrid nodeAtPosition:aStartPosition]];
    [self setEndNode:[aGrid nodeAtPosition:aEndPosition]];
    
    [mStartNode setGValue:0];
    [mStartNode setFValue:0];
    
    [mOpenList push:mStartNode];
    [mStartNode setOpened:YES];
    
    PEPathNode *sNode = nil;

    while ((sNode = [mOpenList pop]))
    {
        [sNode setClosed:YES];

        if (sNode == mEndNode)
        {
            return [mEndNode backtrace];
        }

        CGPoint   sNodePosition = [sNode position];
        NSInteger sCount        = 0;
        id        sNeighbors[10];

        [mGrid getNeighborsOfNode:sNode result:sNeighbors count:&sCount];
        
        for (NSInteger i = 0; i < sCount; i++)
        {
            PEPathNode *sNeighbor = sNeighbors[i];
            
            if (sNeighbor)
            {
                CGPoint     sNeighborPoint = [sNeighbor position];
                PEPathNode *sJumpNode      = PEFindJumpNode(mGrid, mEndNode, sNeighborPoint.x, sNeighborPoint.y, sNodePosition.x, sNodePosition.y);
                
                if (sJumpNode && ![sJumpNode isClosed])
                {
                    CGPoint sJumpPoint = [sJumpNode position];
                    CGFloat sNewG      = [sNode gValue] + PEHeuristicEuclidean(abs((int)(sJumpPoint.x - sNodePosition.x)), abs((int)(sJumpPoint.y - sNodePosition.y)));
                    
                    if (![sJumpNode isOpened] || sNewG < [sJumpNode gValue])
                    {
                        [sJumpNode setGValue:sNewG];
                        if ([sJumpNode hValue] == 0)
                        {
                            CGPoint sEndPoint = [mEndNode position];
                            [sJumpNode setHValue:PEHeuristicManhattan(abs((int)(sJumpPoint.x - sEndPoint.x)), abs((int)(sJumpPoint.y - sEndPoint.y)))];
                        }
                        [sJumpNode updateFValue];  /*  [sJumpNode setFValue:[sJumpNode gValue] + [sJumpNode hValue]];  */
                        [sJumpNode setParent:sNode];
                        
                        if (![sJumpNode isOpened])
                        {
                            [mOpenList push:sJumpNode];
                            [sJumpNode setOpened:YES];
                        }
                        else
                        {
                            [mOpenList updateItem:sJumpNode];
                        }
                    }
                }
            }
        }
    }
    
    return [NSMutableArray array];
};


@end
