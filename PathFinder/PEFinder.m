/*
 *  PEFinder.m
 *  PathFinder
 *
 *  Created by bearkode on 13. 5. 20..
 *  Copyright (c) 2013 bearkode. All rights reserved.
 *
 */

#import "PEFinder.h"
#import "PEGrid.h"
#import "PENode.h"
#import "PEHeap.h"
#import "PEUtil.h"
#import "PEHeuristic.h"
#import "NSValue+Compatibility.h"
#import "PECommonUtil.h"


#define IS_WALKABLE(a)  PEIsWalkableAtPosition(sWalkable, sMapSize, a)


PENode *PEJumpNode(PEGrid *aGrid, PENode *aEndNode, CGFloat aX, CGFloat aY, CGFloat aPX, CGFloat aPY)
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
//        if (sNormalizedX != 0 && sNormalizedY != 0)
//        {
            PENode *sJumpNodeX = PEJumpNode(aGrid, aEndNode, (aX + sNormalizedX), aY, aX, aY);
            PENode *sJumpNodeY = PEJumpNode(aGrid, aEndNode, aX, (aY + sNormalizedY), aX, aY);
            
            if (sJumpNodeX || sJumpNodeY)
            {
                return PENodeAtPosition(sNodes, sMapSize, sCurruntPoint);
            }
//        }
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
        return PEJumpNode(aGrid, aEndNode, (aX + sNormalizedX), (aY + sNormalizedY), aX, aY);
    }
    else
    {
        return nil;
    }
}


@implementation PEFinder
{
    PEHeap *mOpenList;
    PEGrid *mGrid;
    PENode *mStartNode;
    PENode *mEndNode;
}


- (void)dealloc
{
    [mOpenList release];
    [mGrid release];
    [mStartNode release];
    [mEndNode release];
    
    [super dealloc];
}


- (void)setOpenList:(PEHeap *)aOpenList
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


- (void)setStartNode:(PENode *)aNode
{
    [mStartNode autorelease];
    mStartNode = [aNode retain];
}


- (void)setEndNode:(PENode *)aNode
{
    [mEndNode autorelease];
    mEndNode = [aNode retain];
}


- (PENode *)endNode
{
    return mEndNode;
}


//- (NSMutableArray *)findNeighbors:(PENode *)aNode
//{
//    static NSMutableArray *sNeighbors = nil;
//    
//    if (sNeighbors)
//    {
//        [sNeighbors removeAllObjects];
//    }
//    else
//    {
//        sNeighbors = [[NSMutableArray alloc] init];
//    }
//
//    PENode *sParent = [aNode parent];
//
//    /*  directed pruning: can ignore most neighbors, unless forced.  */
//    if (sParent)
//    {
//        CGPoint sNodePoint   = [aNode position];
//        CGPoint sParentPoint = [sParent position];
//        CGPoint sDirVector;
//        PENode *sNode;
//        
//        /*  get the normalized direction of travel  */
//        sDirVector.x = (sNodePoint.x - sParentPoint.x) / MAX(abs(sNodePoint.x - sParentPoint.x), 1);
//        sDirVector.y = (sNodePoint.y - sParentPoint.y) / MAX(abs(sNodePoint.y - sParentPoint.y), 1);
//        
//        /*  search diagonally  */
//        if (sDirVector.x != 0 && sDirVector.y != 0)
//        {
//            sNode = [mGrid nodeAtPosition:CGPointMake(sNodePoint.x, sNodePoint.y + sDirVector.y)];
//            if ([sNode isWalkable])
//            {
//                [sNeighbors addObject:sNode];
//            }
//            
//            sNode = [mGrid nodeAtPosition:CGPointMake(sNodePoint.x + sDirVector.x, sNodePoint.y)];
//            if ([sNode isWalkable])
//            {
//                [sNeighbors addObject:sNode];
//            }
//            
//            if ([mGrid isWalkableAtPosition:CGPointMake(sNodePoint.x, sNodePoint.y + sDirVector.y)] ||
//                [mGrid isWalkableAtPosition:CGPointMake(sNodePoint.x + sDirVector.x, sNodePoint.y)])
//            {
//                PEAddObjectIfNotNil(sNeighbors, [mGrid nodeAtPosition:CGPointMake(sNodePoint.x + sDirVector.x, sNodePoint.y + sDirVector.y)]);
//            }
//            
//            if (![mGrid isWalkableAtPosition:CGPointMake(sNodePoint.x - sDirVector.x, sNodePoint.y)] &&
//                 [mGrid isWalkableAtPosition:CGPointMake(sNodePoint.x, sNodePoint.y + sDirVector.y)])
//            {
//                PEAddObjectIfNotNil(sNeighbors, [mGrid nodeAtPosition:CGPointMake(sNodePoint.x - sDirVector.x, sNodePoint.y + sDirVector.y)]);
//            }
//            
//            if (![mGrid isWalkableAtPosition:CGPointMake(sNodePoint.x, sNodePoint.y - sDirVector.y)] &&
//                 [mGrid isWalkableAtPosition:CGPointMake(sNodePoint.x + sDirVector.x, sNodePoint.y)])
//            {
//                PEAddObjectIfNotNil(sNeighbors, [mGrid nodeAtPosition:CGPointMake(sNodePoint.x + sDirVector.x, sNodePoint.y - sDirVector.y)]);
//            }
//        }
//        else  /*  search horizontally/vertically  */
//        {
//            if (sDirVector.x == 0)
//            {
//                if ([mGrid isWalkableAtPosition:CGPointMake(sNodePoint.x, sNodePoint.y + sDirVector.y)])
//                {
//                    PEAddObjectIfNotNil(sNeighbors, [mGrid nodeAtPosition:CGPointMake(sNodePoint.x, sNodePoint.y + sDirVector.y)]);
//                    
//                    if (![mGrid isWalkableAtPosition:CGPointMake(sNodePoint.x + 1, sNodePoint.y)])
//                    {
//                        PEAddObjectIfNotNil(sNeighbors, [mGrid nodeAtPosition:CGPointMake(sNodePoint.x + 1, sNodePoint.y + sDirVector.y)]);
//                    }
//                    
//                    if (![mGrid isWalkableAtPosition:CGPointMake(sNodePoint.x - 1, sNodePoint.y)])
//                    {
//                        PEAddObjectIfNotNil(sNeighbors, [mGrid nodeAtPosition:CGPointMake(sNodePoint.x - 1, sNodePoint.y + sDirVector.y)]);
//                    }
//                }
//            }
//            else
//            {
//                if ([mGrid isWalkableAtPosition:CGPointMake(sNodePoint.x + sDirVector.x, sNodePoint.y)])
//                {
//                    PEAddObjectIfNotNil(sNeighbors, [mGrid nodeAtPosition:CGPointMake(sNodePoint.x + sDirVector.x, sNodePoint.y)]);
//                    
//                    if (![mGrid isWalkableAtPosition:CGPointMake(sNodePoint.x, sNodePoint.y + 1)])
//                    {
//                        PEAddObjectIfNotNil(sNeighbors, [mGrid nodeAtPosition:CGPointMake(sNodePoint.x + sDirVector.x, sNodePoint.y + 1)]);
//                    }
//                    
//                    if (![mGrid isWalkableAtPosition:CGPointMake(sNodePoint.x, sNodePoint.y - 1)])
//                    {
//                        PEAddObjectIfNotNil(sNeighbors, [mGrid nodeAtPosition:CGPointMake(sNodePoint.x + sDirVector.x, sNodePoint.y - 1)]);
//                    }
//                }
//            }
//        }
//    }
//    else
//    {
//        /*  return all neighbors  */
//        return [mGrid neighborsWith:aNode allowDiagonal:YES dontCrossCorners:NO];
//    }
//    
//    return sNeighbors;
//}


#if (0)
- (PENode *)jumpNodeWithX:(CGFloat)aX y:(CGFloat)aY px:(CGFloat)aPX py:(CGFloat)aPY
{
    CGFloat dx = aX - aPX;
    CGFloat dy = aY - aPY;
    
    if (![mGrid isWalkableAtPosition:CGPointMake(aX, aY)])
    {
        return nil;
    }
    else if ([[mGrid nodeAtPosition:CGPointMake(aX, aY)] isEqualTo:[self endNode]])
    {
        return [mGrid nodeAtPosition:CGPointMake(aX, aY)];
    }
    
    /*  check for forced neighbors along the diagonal  */
    if (dx != 0 && dy != 0)
    {
        if (([mGrid isWalkableAtPosition:CGPointMake(aX - dx, aY + dy)] && ![mGrid isWalkableAtPosition:CGPointMake(aX - dx, aY)]) ||
            ([mGrid isWalkableAtPosition:CGPointMake(aX + dx, aY - dy)] && ![mGrid isWalkableAtPosition:CGPointMake(aX, aY - dy)]))
        {
            return [mGrid nodeAtPosition:CGPointMake(aX, aY)];
        }
    }
    else  /*  horizontally/vertically  */
    {
        if (dx != 0 )  /*  moving along x  */
        {
            if (([mGrid isWalkableAtPosition:CGPointMake(aX + dx, aY + 1)] && ![mGrid isWalkableAtPosition:CGPointMake(aX, aY + 1)]) ||
                ([mGrid isWalkableAtPosition:CGPointMake(aX + dx, aY - 1)] && ![mGrid isWalkableAtPosition:CGPointMake(aX, aY - 1)]))
            {
                return [mGrid nodeAtPosition:CGPointMake(aX, aY)];
            }
        }
        else
        {
            if (([mGrid isWalkableAtPosition:CGPointMake(aX + 1, aY + dy)] && ![mGrid isWalkableAtPosition:CGPointMake(aX + 1, aY)]) ||
                ([mGrid isWalkableAtPosition:CGPointMake(aX - 1, aY + dy)] && ![mGrid isWalkableAtPosition:CGPointMake(aX - 1, aY)]))
            {
                return [mGrid nodeAtPosition:CGPointMake(aX, aY)];
            }
        }
    }
    
    /*  when moving diagonally, must check for vertical/horizontal jump points  */
    if (dx != 0 && dy != 0)
    {
        PENode *sJumpNodeX = [self jumpNodeWithX:aX + dx y:aY px:aX py:aY];
        PENode *sJumpNodeY = [self jumpNodeWithX:aX y:aY + dy px:aX py:aY];

        if (sJumpNodeX || sJumpNodeY)
        {
            return [mGrid nodeAtPosition:CGPointMake(aX, aY)];
        }
    }
    
    /*  moving diagonally, must make sure one of the vertical/horizontal neighbors is open to allow the path  */
    if ([mGrid isWalkableAtPosition:CGPointMake(aX + dx, aY)] || [mGrid isWalkableAtPosition:CGPointMake(aX, aY + dy)])
    {
        return [self jumpNodeWithX:aX + dx y:aY + dy px:aX py:aY];
    }
    else
    {
        return nil;
    }
}
#endif


#if (0)
- (void)identifySuccessors:(PENode *)aNode
{
//    PEBeginTimeCheck();
    CGPoint sNodePosition = [aNode position];

//    PEBeginTimeCheck();
    NSMutableArray *sNeighbors = [mGrid findNeighbors:aNode];
//    PEEndTimeCheck();
    
//    PEBeginTimeCheck();
    for (PENode *sNeighbor in sNeighbors)
    {
        CGPoint sNeighborPoint = [sNeighbor position];
//        PEBeginTimeCheck();
        PENode *sJumpNode      = PEJumpNode(mGrid, mEndNode, sNeighborPoint.x, sNeighborPoint.y, sNodePosition.x, sNodePosition.y);
//        PEEndTimeCheck();
        
        if (sJumpNode && ![sJumpNode isClosed])
        {
//            PEBeginTimeCheck();
            
            CGPoint sJumpPoint = [sJumpNode position];
            CGFloat sNewG      = [aNode gValue] + PEHeuristicEuclidean(abs((int)(sJumpPoint.x - sNodePosition.x)), abs((int)(sJumpPoint.y - sNodePosition.y)));
            
            if (![sJumpNode isOpened] || sNewG < [sJumpNode gValue])
            {
                [sJumpNode setGValue:sNewG];
                if ([sJumpNode hValue] == 0)
                {
                    CGPoint sEndPoint = [mEndNode position];
                    [sJumpNode setHValue:PEHeuristicManhattan(abs((int)(sJumpPoint.x - sEndPoint.x)), abs((int)(sJumpPoint.y - sEndPoint.y)))];
                }
                [sJumpNode updateFValue];  /*  [sJumpNode setFValue:[sJumpNode gValue] + [sJumpNode hValue]];  */
                [sJumpNode setParent:aNode];
                
                if (![sJumpNode isOpened])
                {
//                    PEBeginTimeCheck();
                    [mOpenList push:sJumpNode];
//                    PEEndTimeCheck();
                    [sJumpNode setOpened:YES];
                }
                else
                {
                    [mOpenList updateItem:sJumpNode];
                }
            }
            
//            PEEndTimeCheck();
        }
    }
//    PEEndTimeCheck();
}
#endif


#pragma mark -


- (NSMutableArray *)findPathWithStartPosition:(CGPoint)aStartPosition endPosition:(CGPoint)aEndPosition grid:(PEGrid *)aGrid
{
    [self setGrid:aGrid];
    [self setOpenList:[[[PEHeap alloc] init] autorelease]];
    [self setStartNode:[aGrid nodeAtPosition:aStartPosition]];
    [self setEndNode:[aGrid nodeAtPosition:aEndPosition]];
    
    [mStartNode setGValue:0];
    [mStartNode setFValue:0];
    
    [mOpenList push:mStartNode];
    [mStartNode setOpened:YES];
    
    PENode *sNode = nil;

    while ((sNode = [mOpenList pop]))
    {
        [sNode setClosed:YES];

        if (sNode == mEndNode)
        {
            return [PEUtil backtrace:mEndNode];
        }

        CGPoint         sNodePosition = [sNode position];
        NSMutableArray *sNeighbors    = [mGrid findNeighbors:sNode];
        
        for (PENode *sNeighbor in sNeighbors)
        {
            CGPoint sNeighborPoint = [sNeighbor position];
            PENode *sJumpNode      = PEJumpNode(mGrid, mEndNode, sNeighborPoint.x, sNeighborPoint.y, sNodePosition.x, sNodePosition.y);
            
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
    
    return [NSMutableArray array];
};


@end
