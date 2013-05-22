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


static inline void PEAddObjectIfNotNil(NSMutableArray *aArray, id aObject)
{
    if (aObject)
    {
        [aArray addObject:aObject];
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


- (NSMutableArray *)findNeighbors:(PENode *)aNode
{
    static NSMutableArray *sNeighbors = nil;
    
    if (!sNeighbors)
    {
        sNeighbors = [[NSMutableArray alloc] initWithCapacity:100];
    }
    
    [sNeighbors removeAllObjects];
    
    PENode *sParent = [aNode parent];
    PENode *sNode;
    
    CGFloat x = [aNode position].x;
    CGFloat y = [aNode position].y;
    
    CGFloat px;
    CGFloat py;
    CGFloat dx;
    CGFloat dy;

    /*  directed pruning: can ignore most neighbors, unless forced.  */
    if (sParent)
    {
        px = [sParent position].x;
        py = [sParent position].y;

        /*  get the normalized direction of travel  */
        dx = (x - px) / MAX(abs(x - px), 1);
        dy = (y - py) / MAX(abs(y - py), 1);
        
        /*  search diagonally  */
        if (dx != 0 && dy != 0)
        {
            sNode = [mGrid nodeAtPosition:CGPointMake(x, y + dy)];
            if ([sNode isWalkable])
            {
                [sNeighbors addObject:sNode];
            }
            
            sNode = [mGrid nodeAtPosition:CGPointMake(x + dx, y)];
            if ([sNode isWalkable])
            {
                [sNeighbors addObject:sNode];
            }
            
            if ([mGrid isWalkableAtPosition:CGPointMake(x, y + dy)] || [mGrid isWalkableAtPosition:CGPointMake(x + dx, y)])
            {
                PEAddObjectIfNotNil(sNeighbors, [mGrid nodeAtPosition:CGPointMake(x + dx, y + dy)]);
            }
            
            if (![mGrid isWalkableAtPosition:CGPointMake(x - dx, y)] && [mGrid isWalkableAtPosition:CGPointMake(x, y + dy)])
            {
                PEAddObjectIfNotNil(sNeighbors, [mGrid nodeAtPosition:CGPointMake(x - dx, y + dy)]);
            }
            
            if (![mGrid isWalkableAtPosition:CGPointMake(x, y - dy)] && [mGrid isWalkableAtPosition:CGPointMake(x + dx, y)])
            {
                PEAddObjectIfNotNil(sNeighbors, [mGrid nodeAtPosition:CGPointMake(x + dx, y - dy)]);
            }
        }
        else  /*  search horizontally/vertically  */
        {
            if (dx == 0)
            {
                if ([mGrid isWalkableAtPosition:CGPointMake(x, y + dy)])
                {
                    if ([mGrid isWalkableAtPosition:CGPointMake(x, y + dy)])
                    {
                        PEAddObjectIfNotNil(sNeighbors, [mGrid nodeAtPosition:CGPointMake(x, y + dy)]);
                    }
                    
                    if (![mGrid isWalkableAtPosition:CGPointMake(x + 1, y)])
                    {
                        PEAddObjectIfNotNil(sNeighbors, [mGrid nodeAtPosition:CGPointMake(x + 1, y + dy)]);
                    }
                    
                    if (![mGrid isWalkableAtPosition:CGPointMake(x - 1, y)])
                    {
                        PEAddObjectIfNotNil(sNeighbors, [mGrid nodeAtPosition:CGPointMake(x - 1, y + dy)]);
                    }
                }
            }
            else
            {
                if ([mGrid isWalkableAtPosition:CGPointMake(x + dx, y)])
                {
                    if ([mGrid isWalkableAtPosition:CGPointMake(x + dx, y)])
                    {
                        PEAddObjectIfNotNil(sNeighbors, [mGrid nodeAtPosition:CGPointMake(x + dx, y)]);
                    }
                    
                    if (![mGrid isWalkableAtPosition:CGPointMake(x, y + 1)])
                    {
                        PEAddObjectIfNotNil(sNeighbors, [mGrid nodeAtPosition:CGPointMake(x + dx, y + 1)]);
                    }
                    
                    if (![mGrid isWalkableAtPosition:CGPointMake(x, y - 1)])
                    {
                        PEAddObjectIfNotNil(sNeighbors, [mGrid nodeAtPosition:CGPointMake(x + dx, y - 1)]);
                    }
                }
            }
        }
    }
    else
    {
        /*  return all neighbors  */
        return [mGrid neighborsWith:aNode allowDiagonal:YES dontCrossCorners:NO];
    }
    
    return sNeighbors;
}


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


- (void)identifySuccessors:(PENode *)aNode
{
    CGFloat sEndX = [[self endNode] position].x;
    CGFloat sEndY = [[self endNode] position].y;
    CGFloat x     = [aNode position].x;
    CGFloat y     = [aNode position].y;

    NSMutableArray *sNeighbors = [self findNeighbors:aNode];

    for (PENode *sNeighbor in sNeighbors)
    {
        CGPoint sNeighborPoint = [sNeighbor position];
        PENode *sJumpNode      = [self jumpNodeWithX:sNeighborPoint.x y:sNeighborPoint.y px:x py:y];
        
        if (sJumpNode)
        {
            if ([sJumpNode isClosed])
            {
                continue;
            }
            
            CGPoint sJumpPoint = [sJumpNode position];
            CGFloat sNewG      = [aNode gValue] + PEHeuristicEuclidean(abs((int)(sJumpPoint.x - x)), abs((int)(sJumpPoint.y - y)));
            
            if (![sJumpNode isOpened] || sNewG < [sJumpNode gValue])
            {
                [sJumpNode setGValue:sNewG];
                if ([sJumpNode hValue] == 0)
                {
                    [sJumpNode setHValue:PEHeuristicManhattan(abs((int)(sJumpPoint.x - sEndX)), abs((int)(sJumpPoint.y - sEndY)))];
                }
                [sJumpNode updateFValue];  /*  [sJumpNode setFValue:[sJumpNode gValue] + [sJumpNode hValue]];  */
                [sJumpNode setParent:aNode];
                
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
    
    while (![mOpenList isEmpty])
    {
        PENode *sNode = [mOpenList pop];
        [sNode setClosed:YES];
        
        if ([sNode isEqualTo:mEndNode])
        {
            return [PEUtil backtrace:mEndNode];
        }
        
        [self identifySuccessors:sNode];
    }
    
    return [NSMutableArray array];
};


@end
