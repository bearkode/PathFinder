/*
 *  PEGrid.m
 *  PathFinder
 *
 *  Created by bearkode on 13. 5. 20..
 *  Copyright (c) 2013 bearkode. All rights reserved.
 *
 */

#import "PEGrid.h"
#import "PENode.h"


static inline PENode *PENodeAtPosition(id *aNodes, CGSize aSize, CGPoint aPoint)
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


@implementation PEGrid
{
    CGSize mSize;
    id    *mNodes;
}


- (void)buildNodes:(unsigned char *)aMatrix
{
    for (NSInteger y = 0; y < mSize.height; y++)
    {
        for (NSInteger x = 0; x < mSize.width; x++)
        {
            BOOL    sIsWalkable = (aMatrix[y * (int)mSize.width + x] == 0) ? YES : NO;
            PENode *sNode       = [[PENode alloc] initWithPosition:CGPointMake(x, y) walkable:sIsWalkable];

            mNodes[(int)(mSize.width * y + x)] = sNode;
        }
    }
}


- (id)initWithSize:(CGSize)aSize matrix:(unsigned char *)aMatrix
{
    self = [super init];
    
    if (self)
    {
        mSize  = aSize;
        mNodes = malloc(aSize.width * aSize.height * sizeof(id));
        [self buildNodes:aMatrix];
    }
    
    return self;
}


- (void)dealloc
{
    for (NSInteger i = 0; i < mSize.width * mSize.height; i++)
    {
        [mNodes[i] release];
    }
    
    free(mNodes);

    [super dealloc];
}


- (void)reset
{
    for (NSInteger i = 0; i < mSize.width * mSize.height; i++)
    {
        [mNodes[i] reset];
    }
}


- (PENode *)nodeAtPosition:(CGPoint)aPosition
{
    return PENodeAtPosition(mNodes, mSize, aPosition);
}


- (BOOL)isWalkableAtPosition:(CGPoint)aPosition
{
    return [PENodeAtPosition(mNodes, mSize, aPosition) isWalkable];
};


- (void)setWalkable:(BOOL)aWalkable atPosition:(CGPoint)aPosition
{
    PENode *sNode = PENodeAtPosition(mNodes, mSize, aPosition);

    [sNode setWalkable:aWalkable];
};


- (NSMutableArray *)neighborsWith:(PENode *)aNode allowDiagonal:(BOOL)aAllowDiagonal dontCrossCorners:(BOOL)aDontCrossCorners
{
    NSMutableArray *sNeighbors = [NSMutableArray array];
    
    CGFloat x   = [aNode position].x;
    CGFloat y   = [aNode position].y;
    BOOL    sS0 = NO;
    BOOL    sS1 = NO;
    BOOL    sS2 = NO;
    BOOL    sS3 = NO;
    BOOL    sD0 = NO;
    BOOL    sD1 = NO;
    BOOL    sD2 = NO;
    BOOL    sD3 = NO;

    PENode *sNode = nil;
    
    /*  Up  */
    sNode = PENodeAtPosition(mNodes, mSize, CGPointMake(x, y - 1));
    if ([sNode isWalkable])
    {
        [sNeighbors addObject:sNode];
        sS0 = true;
    }
    
    /*  Right  */
    sNode = PENodeAtPosition(mNodes, mSize, CGPointMake(x + 1, y));
    if ([sNode isWalkable])
    {
        [sNeighbors addObject:sNode];
        sS1 = true;
    }
    
    /*  Bottom  */
    sNode = PENodeAtPosition(mNodes, mSize, CGPointMake(x, y + 1));
    if ([sNode isWalkable])
    {
        [sNeighbors addObject:sNode];
        sS2 = true;
    }
    
    /*  Left  */
    sNode = PENodeAtPosition(mNodes, mSize, CGPointMake(x - 1, y));
    if ([sNode isWalkable])
    {
        [sNeighbors addObject:sNode];
        sS3 = true;
    }
    
    if (!aAllowDiagonal)
    {
        return sNeighbors;
    }
    
    if (aDontCrossCorners)
    {
        sD0 = sS3 && sS0;
        sD1 = sS0 && sS1;
        sD2 = sS1 && sS2;
        sD3 = sS2 && sS3;
    }
    else
    {
        sD0 = sS3 || sS0;
        sD1 = sS0 || sS1;
        sD2 = sS1 || sS2;
        sD3 = sS2 || sS3;
    }
    
    /*  Up Left  */
    sNode = PENodeAtPosition(mNodes, mSize, CGPointMake(x - 1, y - 1));
    if (sD0 && [sNode isWalkable])
    {
        [sNeighbors addObject:sNode];
    }
    
    /*  Up Right  */
    sNode = PENodeAtPosition(mNodes, mSize, CGPointMake(x + 1, y - 1));
    if (sD1 && [sNode isWalkable])
    {
        [sNeighbors addObject:sNode];
    }
    
    /*  Down Right  */
    sNode = PENodeAtPosition(mNodes, mSize, CGPointMake(x + 1, y + 1));
    if (sD2 && [sNode isWalkable])
    {
        [sNeighbors addObject:sNode];
    }
    
    /*  Down Left  */
    sNode = PENodeAtPosition(mNodes, mSize, CGPointMake(x - 1, y + 1));
    if (sD3 && [sNode isWalkable])
    {
        [sNeighbors addObject:sNode];
    }
    
    return sNeighbors;
};


@end
