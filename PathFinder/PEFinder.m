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


@implementation PEFinder
{
    PEHeap      *mOpenList;
    PEGrid      *mGrid;
    PENode      *mStartNode;
    PENode      *mEndNode;
    PEHeuristic *mHeuristic;
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


- (PEHeuristic *)heuristic
{
    return mHeuristic;
}


- (NSMutableArray *)findNeighbors:(PENode *)aNode
{
    PENode *sParent = [aNode parent];
    
    CGFloat x = [aNode position].x;
    CGFloat y = [aNode position].y;
    
    PEGrid *sGrid = [self grid];

    CGFloat px;
    CGFloat py;
    
//    nx, ny,
    
    CGFloat dx;
    CGFloat dy;
    
    NSMutableArray *sNeighbors = [NSMutableArray array];
    
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
            if ([sGrid isWalkableAtPosition:CGPointMake(x, y + dy)])
            {
                [sNeighbors addObject:[NSValue valueWithPoint:NSMakePoint(x, y + dy)]];
            }
            
            if ([sGrid isWalkableAtPosition:CGPointMake(x + dx, y)])
            {
                [sNeighbors addObject:[NSValue valueWithPoint:NSMakePoint(x + dx, y)]];
            }
            
            if ([sGrid isWalkableAtPosition:CGPointMake(x, y + dy)] || [sGrid isWalkableAtPosition:CGPointMake(x + dx, y)])
            {
                [sNeighbors addObject:[NSValue valueWithPoint:NSMakePoint(x + dx, y + dy)]];
            }
            
            if (![sGrid isWalkableAtPosition:CGPointMake(x - dx, y)] && [sGrid isWalkableAtPosition:CGPointMake(x, y + dy)])
            {
                [sNeighbors addObject:[NSValue valueWithPoint:NSMakePoint(x - dx, y + dy)]];
            }
            
            if (![sGrid isWalkableAtPosition:CGPointMake(x, y - dy)] && [sGrid isWalkableAtPosition:CGPointMake(x + dx, y)])
            {
                [sNeighbors addObject:[NSValue valueWithPoint:NSMakePoint(x + dx, y - dy)]];
            }
        }
        else    // search horizontally/vertically
        {
            if (dx == 0)
            {
                if ([sGrid isWalkableAtPosition:CGPointMake(x, y + dy)])
                {
                    if ([sGrid isWalkableAtPosition:CGPointMake(x, y + dy)])
                    {
                        [sNeighbors addObject:[NSValue valueWithPoint:NSMakePoint(x, y + dy)]];
                    }
                    
                    if (![sGrid isWalkableAtPosition:CGPointMake(x + 1, y)])
                    {
                        [sNeighbors addObject:[NSValue valueWithPoint:NSMakePoint(x + 1, y + dy)]];
                    }
                    
                    if (![sGrid isWalkableAtPosition:CGPointMake(x - 1, y)])
                    {
                        [sNeighbors addObject:[NSValue valueWithPoint:NSMakePoint(x - 1, y + dy)]];
                    }
                }
            }
            else
            {
                if ([sGrid isWalkableAtPosition:CGPointMake(x + dx, y)])
                {
                    if ([sGrid isWalkableAtPosition:CGPointMake(x + dx, y)])
                    {
                        [sNeighbors addObject:[NSValue valueWithPoint:NSMakePoint(x + dx, y)]];
                    }
                    
                    if (![sGrid isWalkableAtPosition:CGPointMake(x, y + 1)])
                    {
                        [sNeighbors addObject:[NSValue valueWithPoint:NSMakePoint(x + dx, y + 1)]];
                    }
                    
                    if (![sGrid isWalkableAtPosition:CGPointMake(x, y - 1)])
                    {
                        [sNeighbors addObject:[NSValue valueWithPoint:NSMakePoint(x + dx, y - 1)]];
                    }
                }
            }
        }
    }
    else    // return all neighbors
    {
        NSArray *sNeighborNodes;
        
        sNeighborNodes = [sGrid neighborsWith:aNode allowDiagonal:YES dontCrossCorners:NO]; //  마지막 파라메터 확인
        
        for (PENode *sNode in sNeighborNodes)
        {
            CGPoint sPosition = [sNode position];
            [sNeighbors addObject:[NSValue valueWithPoint:NSMakePoint(sPosition.x, sPosition.y)]];
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
        return [NSValue valueWithPoint:NSMakePoint(aX, aY)];
    }
    
    // check for forced neighbors
    // along the diagonal
    if (dx != 0 && dy != 0)
    {
        if (([sGrid isWalkableAtPosition:CGPointMake(aX - dx, aY + dy)] && ![sGrid isWalkableAtPosition:CGPointMake(aX - dx, aY)]) ||
            ([sGrid isWalkableAtPosition:CGPointMake(aX + dx, aY - dy)] && ![sGrid isWalkableAtPosition:CGPointMake(aX, aY - dy)]))
        {
            return [NSValue valueWithPoint:NSMakePoint(aX, aY)];
        }
    }
    else// horizontally/vertically
    {
        if (dx != 0 )
        { // moving along x
            if (([sGrid isWalkableAtPosition:CGPointMake(aX + dx, aY + 1)] && ![sGrid isWalkableAtPosition:CGPointMake(aX, aY + 1)]) ||
                ([sGrid isWalkableAtPosition:CGPointMake(aX + dx, aY - 1)] && ![sGrid isWalkableAtPosition:CGPointMake(aX, aY - 1)]))
            {
                return [NSValue valueWithPoint:NSMakePoint(aX, aY)];
            }
        }
        else
        {
            if (([sGrid isWalkableAtPosition:CGPointMake(aX + 1, aY + dy)] && ![sGrid isWalkableAtPosition:CGPointMake(aX + 1, aY)]) ||
                ([sGrid isWalkableAtPosition:CGPointMake(aX - 1, aY + dy)] && ![sGrid isWalkableAtPosition:CGPointMake(aX - 1, aY)]))
            {
                return [NSValue valueWithPoint:NSMakePoint(aX, aY)];
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
            return [NSValue valueWithPoint:NSMakePoint(aX, aY)];
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
    PEGrid      *sGrid      = [self grid];
//    PEHeuristic *sHeuristic = [self heuristic];

    CGFloat sEndX = [[self endNode] position].x;
    CGFloat sEndY = [[self endNode] position].y;
    
    NSMutableArray *sNeighbors;
    CGPoint sJumpPoint;
//    , i, l,
    CGFloat x = [aNode position].x;
    CGFloat y = [aNode position].y;
//    dx, dy, 
    
    CGFloat d;
    CGFloat ng;
    
    PENode *sJumpNode = nil;

//    abs = Math.abs, max = Math.max;
    
    sNeighbors = [self findNeighbors:aNode];
    for(NSValue *sNeighbor in sNeighbors)
    {
//        neighbor = neighbors[i];
        
        NSPoint sNeighborNSPoint = [sNeighbor pointValue];
        CGPoint sNeighborPoint    = CGPointMake(sNeighborNSPoint.x, sNeighborNSPoint.y);
        
        NSValue *sJumpPointValue = [self jumpWithX:sNeighborPoint.x y:sNeighborPoint.y px:x py:y];
        
        if (sJumpPointValue)
        {
            sJumpPoint = CGPointMake([sJumpPointValue pointValue].x, [sJumpPointValue pointValue].y);
            CGFloat jx = sJumpPoint.x;
            CGFloat jy = sJumpPoint.y;
            
            sJumpNode = [sGrid nodeAtPosition:CGPointMake(jx, jy)];
            
            if ([sJumpNode isClosed])
            {
                continue;
            }
            
            // include distance, as parent may not be immediately adjacent:
            d = [PEHeuristic euclidean:CGPointMake(abs(jx - x), abs(jy - y))];
            ng = [aNode gValue] + d; // next `g` value
            
            if (![sJumpNode isOpened] || ng < [sJumpNode gValue])
            {
                [sJumpNode setGValue:ng];
                [sJumpNode setHValue:([sJumpNode hValue] == NAN) ? [PEHeuristic manhattan:CGPointMake(abs(jx - sEndX), abs(jy - sEndY))]: [sJumpNode hValue]];
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
//    var openList = this.openList = new Heap(function(nodeA, nodeB) {
//        return nodeA.f - nodeB.f;
//    }),
    
    PEHeap *sOpenList = [[[PEHeap alloc] init] autorelease];
    [self setOpenList:sOpenList];

    PENode *sStartNode = [aGrid nodeAtPosition:aStartPosition];
    [self setStartNode:sStartNode];
    
    PENode *sEndNode = [aGrid nodeAtPosition:aEndPosition];
    [self setEndNode:sEndNode];
    
    [self setGrid:aGrid];
    
    // set the `g` and `f` value of the start node to be 0
    [sStartNode setGValue:0];
    [sStartNode setFValue:0];
    
    // push the start node into the open list
    [sOpenList push:sStartNode];
    [sStartNode setOpened:YES];
    
    // while the open list is not empty
    while (![sOpenList isEmpty])
    {
        // pop the position of node which has the minimum `f` value.
        PENode *sNode = [sOpenList pop];
        [sNode setClosed:YES];
        
        if ([sNode isEqualTo:sEndNode])
        {
            return [PEUtil backtrace:sEndNode];
        }
        
        [self identifySuccessors:sNode];
    }
    
    // fail to find the path
    return [NSMutableArray array];
};


@end
