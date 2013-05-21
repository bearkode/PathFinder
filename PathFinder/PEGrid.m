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


@implementation PEGrid
{
    CGSize          mSize;
    NSMutableArray *mNodes;
}


- (NSMutableArray *)buildNodes:(unsigned char *)aMatrix
{
    NSMutableArray *sNodes = [NSMutableArray arrayWithCapacity:mSize.width * mSize.height];

    for (NSInteger y = 0; y < mSize.height; y++)
    {
        for (NSInteger x = 0; x < mSize.width; x++)
        {
            PENode *sNode = [[PENode alloc] initWithPosition:CGPointMake(x, y) walkable:YES];
            [sNodes addObject:sNode];
            [sNode release];
        }
    }
    
    for (NSInteger y = 0; y < mSize.height; y++)
    {
        for (NSInteger x = 0; x < mSize.width; x++)
        {
            if (aMatrix[y * (int)mSize.width + x] != 0)
            {
                PENode *sNode = [sNodes objectAtIndex:(y * (int)mSize.width + x)];
                [sNode setWalkable:NO];
            }
        }
    }
    
    return sNodes;
}


- (id)initWithSize:(CGSize)aSize matrix:(unsigned char *)aMatrix
{
    self = [super init];
    
    if (self)
    {
        mSize  = aSize;
        mNodes = [[self buildNodes:aMatrix] retain];
        
        NSLog(@"mNodes = %@", mNodes);
    }
    
    return self;
}


- (void)dealloc
{
    [super dealloc];
}


- (PENode *)nodeAtPosition:(CGPoint)aPosition
{
    return [mNodes objectAtIndex:(aPosition.y * mSize.width + aPosition.x)];
}


- (BOOL)isWalkableAtPosition:(CGPoint)aPosition
{
    if ([self isInside:aPosition])
    {
        return [[self nodeAtPosition:aPosition] isWalkable];
    }
    
    return NO;
};


- (BOOL)isInside:(CGPoint)aPosition
{
    return (aPosition.x >= 0 && aPosition.x < mSize.width) && (aPosition.y >= 0 && aPosition.y < mSize.height);
};


- (void)setWalkable:(BOOL)aWalkable atPosition:(CGPoint)aPosition
{
    PENode *sNode = [self nodeAtPosition:aPosition];

    [sNode setWalkable:aWalkable];
};


- (NSMutableArray *)neighborsWith:(PENode *)aNode allowDiagonal:(BOOL)aAllowDiagonal dontCrossCorners:(BOOL)aDontCrossCorners
{
    CGFloat         x          = [aNode position].x;
    CGFloat         y          = [aNode position].y;
    NSMutableArray *sNeighbors = [NSMutableArray array];

    BOOL            s0 = false;
    BOOL            d0 = false;
    BOOL            s1 = false;
    BOOL            d1 = false;
    BOOL            s2 = false;
    BOOL            d2 = false;
    BOOL            s3 = false;
    BOOL            d3 = false;
    
//    nodes = this.nodes;
    
    /*  Up  */
    if ([self isWalkableAtPosition:CGPointMake(x, y - 1)])
    {
        [sNeighbors addObject:[self nodeAtPosition:CGPointMake(x, y - 1)]];
        s0 = true;
    }
    
    /*  Right  */
    if ([self isWalkableAtPosition:CGPointMake(x + 1, y)])
    {
        [sNeighbors addObject:[self nodeAtPosition:CGPointMake(x + 1, y)]];
        s1 = true;
    }
    
    /*  Bottom  */
    if ([self isWalkableAtPosition:CGPointMake(x, y + 1)])
    {
        [sNeighbors addObject:[self nodeAtPosition:CGPointMake(x, y + 1)]];
        s2 = true;
    }
    
    /*  Left  */
    if ([self isWalkableAtPosition:CGPointMake(x - 1, y)])
    {
        [sNeighbors addObject:[self nodeAtPosition:CGPointMake(x - 1, y)]];
        s3 = true;
    }
    
    if (!aAllowDiagonal)
    {
        return sNeighbors;
    }
    
    if (aDontCrossCorners)
    {
        d0 = s3 && s0;
        d1 = s0 && s1;
        d2 = s1 && s2;
        d3 = s2 && s3;
    }
    else
    {
        d0 = s3 || s0;
        d1 = s0 || s1;
        d2 = s1 || s2;
        d3 = s2 || s3;
    }
    
    /*  Up Left  */
    if (d0 && [self isWalkableAtPosition:CGPointMake(x - 1, y - 1)])
    {
        [sNeighbors addObject:[self nodeAtPosition:CGPointMake(x - 1, y - 1)]];
    }
    
    /*  Up Right  */
    if (d1 && [self isWalkableAtPosition:CGPointMake(x + 1, y - 1)])
    {
        [sNeighbors addObject:[self nodeAtPosition:CGPointMake(x + 1, y - 1)]];
    }
    
    /*  Down Right  */
    if (d2 && [self isWalkableAtPosition:CGPointMake(x + 1, y + 1)])
    {
        [sNeighbors addObject:[self nodeAtPosition:CGPointMake(x + 1, y + 1)]];
    }
    
    /*  Down Left  */
    if (d3 && [self isWalkableAtPosition:CGPointMake(x - 1, y + 1)])
    {
        [sNeighbors addObject:[self nodeAtPosition:CGPointMake(x - 1, y + 1)]];
    }
    
    return sNeighbors;
};


@end
