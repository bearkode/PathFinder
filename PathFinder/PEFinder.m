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
    NSMutableArray *sNeighbors = [NSMutableArray array];
    PENode         *sParent    = [aNode parent];
    
    CGFloat x = [aNode position].x;
    CGFloat y = [aNode position].y;
    
    CGFloat px;
    CGFloat py;
    CGFloat dx;
    CGFloat dy;

    // directed pruning: can ignore most neighbors, unless forced.
    if (sParent)
    {
        px = [sParent position].x;
        py = [sParent position].y;

        // get the normalized direction of travel
        dx = (x - px) / MAX(abs(x - px), 1);
        dy = (y - py) / MAX(abs(y - py), 1);
        
        // search diagonally
        if (dx != 0 && dy != 0)
        {
            if ([mGrid isWalkableAtPosition:CGPointMake(x, y + dy)])
            {
                [sNeighbors addObject:[NSValue valueWithCGPoint:CGPointMake(x, y + dy)]];
            }
            
            if ([mGrid isWalkableAtPosition:CGPointMake(x + dx, y)])
            {
                [sNeighbors addObject:[NSValue valueWithCGPoint:CGPointMake(x + dx, y)]];
            }
            
            if ([mGrid isWalkableAtPosition:CGPointMake(x, y + dy)] || [mGrid isWalkableAtPosition:CGPointMake(x + dx, y)])
            {
                [sNeighbors addObject:[NSValue valueWithCGPoint:CGPointMake(x + dx, y + dy)]];
            }
            
            if (![mGrid isWalkableAtPosition:CGPointMake(x - dx, y)] && [mGrid isWalkableAtPosition:CGPointMake(x, y + dy)])
            {
                [sNeighbors addObject:[NSValue valueWithCGPoint:CGPointMake(x - dx, y + dy)]];
            }
            
            if (![mGrid isWalkableAtPosition:CGPointMake(x, y - dy)] && [mGrid isWalkableAtPosition:CGPointMake(x + dx, y)])
            {
                [sNeighbors addObject:[NSValue valueWithCGPoint:CGPointMake(x + dx, y - dy)]];
            }
        }
        else    // search horizontally/vertically
        {
            if (dx == 0)
            {
                if ([mGrid isWalkableAtPosition:CGPointMake(x, y + dy)])
                {
                    if ([mGrid isWalkableAtPosition:CGPointMake(x, y + dy)])
                    {
                        [sNeighbors addObject:[NSValue valueWithCGPoint:CGPointMake(x, y + dy)]];
                    }
                    
                    if (![mGrid isWalkableAtPosition:CGPointMake(x + 1, y)])
                    {
                        [sNeighbors addObject:[NSValue valueWithCGPoint:CGPointMake(x + 1, y + dy)]];
                    }
                    
                    if (![mGrid isWalkableAtPosition:CGPointMake(x - 1, y)])
                    {
                        [sNeighbors addObject:[NSValue valueWithCGPoint:CGPointMake(x - 1, y + dy)]];
                    }
                }
            }
            else
            {
                if ([mGrid isWalkableAtPosition:CGPointMake(x + dx, y)])
                {
                    if ([mGrid isWalkableAtPosition:CGPointMake(x + dx, y)])
                    {
                        [sNeighbors addObject:[NSValue valueWithCGPoint:CGPointMake(x + dx, y)]];
                    }
                    
                    if (![mGrid isWalkableAtPosition:CGPointMake(x, y + 1)])
                    {
                        [sNeighbors addObject:[NSValue valueWithCGPoint:CGPointMake(x + dx, y + 1)]];
                    }
                    
                    if (![mGrid isWalkableAtPosition:CGPointMake(x, y - 1)])
                    {
                        [sNeighbors addObject:[NSValue valueWithCGPoint:CGPointMake(x + dx, y - 1)]];
                    }
                }
            }
        }
    }
    else
    {
        /*  return all neighbors  */
        NSArray *sNeighborNodes;
        
        sNeighborNodes = [mGrid neighborsWith:aNode allowDiagonal:YES dontCrossCorners:NO];
        
        for (PENode *sNode in sNeighborNodes)
        {
            CGPoint sPosition = [sNode position];
            [sNeighbors addObject:[NSValue valueWithCGPoint:CGPointMake(sPosition.x, sPosition.y)]];
        }
    }
    
    return sNeighbors;
}


- (NSValue *)jumpWithX:(CGFloat)aX y:(CGFloat)aY px:(CGFloat)aPX py:(CGFloat)aPY
{
    PEGrid *sGrid = [self grid];
    
    CGFloat dx = aX - aPX;
    CGFloat dy = aY - aPY;
    NSValue *jx;
    NSValue *jy;
    
    if (![sGrid isWalkableAtPosition:CGPointMake(aX, aY)])
    {
        return nil;
    }
    else if ([[sGrid nodeAtPosition:CGPointMake(aX, aY)] isEqualTo:[self endNode]])
    {
        return [NSValue valueWithCGPoint:CGPointMake(aX, aY)];
    }
    
    // check for forced neighbors
    // along the diagonal
    if (dx != 0 && dy != 0)
    {
        if (([sGrid isWalkableAtPosition:CGPointMake(aX - dx, aY + dy)] && ![sGrid isWalkableAtPosition:CGPointMake(aX - dx, aY)]) ||
            ([sGrid isWalkableAtPosition:CGPointMake(aX + dx, aY - dy)] && ![sGrid isWalkableAtPosition:CGPointMake(aX, aY - dy)]))
        {
            return [NSValue valueWithCGPoint:CGPointMake(aX, aY)];
        }
    }
    else// horizontally/vertically
    {
        if (dx != 0 )
        { // moving along x
            if (([sGrid isWalkableAtPosition:CGPointMake(aX + dx, aY + 1)] && ![sGrid isWalkableAtPosition:CGPointMake(aX, aY + 1)]) ||
                ([sGrid isWalkableAtPosition:CGPointMake(aX + dx, aY - 1)] && ![sGrid isWalkableAtPosition:CGPointMake(aX, aY - 1)]))
            {
                return [NSValue valueWithCGPoint:CGPointMake(aX, aY)];
            }
        }
        else
        {
            if (([sGrid isWalkableAtPosition:CGPointMake(aX + 1, aY + dy)] && ![sGrid isWalkableAtPosition:CGPointMake(aX + 1, aY)]) ||
                ([sGrid isWalkableAtPosition:CGPointMake(aX - 1, aY + dy)] && ![sGrid isWalkableAtPosition:CGPointMake(aX - 1, aY)]))
            {
                return [NSValue valueWithCGPoint:CGPointMake(aX, aY)];
            }
        }
    }
    
    // when moving diagonally, must check for vertical/horizontal jump points
    if (dx != 0 && dy != 0)
    {
        jx = [self jumpWithX:aX + dx y:aY px:aX py:aY];
        jy = [self jumpWithX:aX y:aY + dy px:aX py:aY];

        if (jx || jy)
        {
            return [NSValue valueWithCGPoint:CGPointMake(aX, aY)];
        }
    }
    
    // moving diagonally, must make sure one of the vertical/horizontal
    // neighbors is open to allow the path
    if ([sGrid isWalkableAtPosition:CGPointMake(aX + dx, aY)] || [sGrid isWalkableAtPosition:CGPointMake(aX, aY + dy)])
    {
        return [self jumpWithX:aX + dx y:aY + dy px:aX py:aY];
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
    
    for (NSValue *sNeighbor in sNeighbors)
    {
        CGPoint  sNeighborPoint  = [sNeighbor CGPointValue];
        NSValue *sJumpPointValue = [self jumpWithX:sNeighborPoint.x y:sNeighborPoint.y px:x py:y];
        
        if (sJumpPointValue)
        {
            CGPoint sJumpPoint = [sJumpPointValue CGPointValue];
            PENode *sJumpNode  = [mGrid nodeAtPosition:sJumpPoint];
            
            if ([sJumpNode isClosed])
            {
                continue;
            }
            
            CGFloat sNewG = [aNode gValue] + [PEHeuristic euclidean:CGPointMake(abs(sJumpPoint.x - x), abs(sJumpPoint.y - y))];
            
            if (![sJumpNode isOpened] || sNewG < [sJumpNode gValue])
            {
                [sJumpNode setGValue:sNewG];
                if ([sJumpNode hValue] == 0)
                {
                    [sJumpNode setHValue:[PEHeuristic manhattan:CGPointMake(abs(sJumpPoint.x - sEndX), abs(sJumpPoint.y - sEndY))]];
                }
                [sJumpNode setFValue:[sJumpNode gValue] + [sJumpNode hValue]];
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
    
    PEHeap *sOpenList = [[[PEHeap alloc] init] autorelease];
    [self setOpenList:sOpenList];

    PENode *sStartNode = [aGrid nodeAtPosition:aStartPosition];
    [self setStartNode:sStartNode];
    
    PENode *sEndNode = [aGrid nodeAtPosition:aEndPosition];
    [self setEndNode:sEndNode];
    
    [sStartNode setGValue:0];
    [sStartNode setFValue:0];
    
    [sOpenList push:sStartNode];
    [sStartNode setOpened:YES];
    
    while (![sOpenList isEmpty])
    {
        PENode *sNode = [sOpenList pop];
        [sNode setClosed:YES];
        
        if ([sNode isEqualTo:sEndNode])
        {
            return [PEUtil backtrace:sEndNode];
        }
        
        [self identifySuccessors:sNode];
    }
    
    return [NSMutableArray array];
};


@end
