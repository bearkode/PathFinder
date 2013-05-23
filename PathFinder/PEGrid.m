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
    CGSize         mSize;
    id            *mNodes;
    unsigned char *mWalkable;
}


- (void)buildNodes:(unsigned char *)aMatrix
{
    for (NSInteger y = 0; y < mSize.height; y++)
    {
        for (NSInteger x = 0; x < mSize.width; x++)
        {
            BOOL      sIsWalkable = (aMatrix[y * (int)mSize.width + x] == 0) ? YES : NO;
            PENode   *sNode       = [[PENode alloc] initWithPosition:CGPointMake(x, y) walkable:sIsWalkable];
            NSInteger sIndex      = mSize.width * y + x;

            mNodes[sIndex]    = sNode;
            mWalkable[sIndex] = sIsWalkable;
        }
    }
}


- (id)initWithSize:(CGSize)aSize matrix:(unsigned char *)aMatrix
{
    self = [super init];
    
    if (self)
    {
        mSize     = aSize;
        mNodes    = malloc(aSize.width * aSize.height * sizeof(id));
        mWalkable = malloc(aSize.width * aSize.height * sizeof(unsigned char));
        
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
    free(mWalkable);

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
    if ((aPosition.x >= 0 && aPosition.x < mSize.width) && (aPosition.y >= 0 && aPosition.y < mSize.height))
    {
        return mWalkable[(int)(mSize.width * aPosition.y + aPosition.x)];
    }
    else
    {
        return NO;
    }
};


- (unsigned char *)walkableBytes
{
    return mWalkable;
}


- (id *)nodesBytes
{
    return mNodes;
}


- (CGSize)mapSize
{
    return mSize;
}


- (void)setWalkable:(BOOL)aWalkable atPosition:(CGPoint)aPosition
{
    PENode *sNode = PENodeAtPosition(mNodes, mSize, aPosition);

    [sNode setWalkable:aWalkable];
};


- (NSMutableArray *)findNeighbors:(PENode *)aNode
{
    static NSMutableArray *sNeighbors = nil;
    
    if (sNeighbors)
    {
        [sNeighbors removeAllObjects];
    }
    else
    {
        sNeighbors = [[NSMutableArray alloc] init];
    }
    
    PENode *sParent = [aNode parent];
    
    /*  directed pruning: can ignore most neighbors, unless forced.  */
    if (sParent)
    {
        CGPoint sNodePoint   = [aNode position];
        CGPoint sParentPoint = [sParent position];
        CGPoint sDirVector;
        PENode *sNode;
        
        /*  get the normalized direction of travel  */
        sDirVector.x = (sNodePoint.x - sParentPoint.x) / MAX(abs(sNodePoint.x - sParentPoint.x), 1);
        sDirVector.y = (sNodePoint.y - sParentPoint.y) / MAX(abs(sNodePoint.y - sParentPoint.y), 1);
        
        /*  search diagonally  */
        if (sDirVector.x != 0 && sDirVector.y != 0)
        {
            sNode = PENodeAtPosition(mNodes, mSize, CGPointMake(sNodePoint.x, sNodePoint.y + sDirVector.y));
            if ([sNode isWalkable])
            {
                [sNeighbors addObject:sNode];
            }
            
            sNode = PENodeAtPosition(mNodes, mSize, CGPointMake(sNodePoint.x + sDirVector.x, sNodePoint.y));
            if ([sNode isWalkable])
            {
                [sNeighbors addObject:sNode];
            }
            
            if (PEIsWalkableAtPosition(mWalkable, mSize, CGPointMake(sNodePoint.x, sNodePoint.y + sDirVector.y)) ||
                PEIsWalkableAtPosition(mWalkable, mSize, CGPointMake(sNodePoint.x + sDirVector.x, sNodePoint.y)))
            {
                PEAddObjectIfNotNil(sNeighbors, PENodeAtPosition(mNodes, mSize, CGPointMake(sNodePoint.x + sDirVector.x, sNodePoint.y + sDirVector.y)));
            }
            
            if (!PEIsWalkableAtPosition(mWalkable, mSize, CGPointMake(sNodePoint.x - sDirVector.x, sNodePoint.y)) &&
                 PEIsWalkableAtPosition(mWalkable, mSize, CGPointMake(sNodePoint.x, sNodePoint.y + sDirVector.y)))
            {
                PEAddObjectIfNotNil(sNeighbors, PENodeAtPosition(mNodes, mSize, CGPointMake(sNodePoint.x - sDirVector.x, sNodePoint.y + sDirVector.y)));
            }
            
            if (!PEIsWalkableAtPosition(mWalkable, mSize, CGPointMake(sNodePoint.x, sNodePoint.y - sDirVector.y)) &&
                 PEIsWalkableAtPosition(mWalkable, mSize, CGPointMake(sNodePoint.x + sDirVector.x, sNodePoint.y)))
            {
                PEAddObjectIfNotNil(sNeighbors, PENodeAtPosition(mNodes, mSize, CGPointMake(sNodePoint.x + sDirVector.x, sNodePoint.y - sDirVector.y)));
            }
        }
        else  /*  search horizontally/vertically  */
        {
            if (sDirVector.x == 0)
            {
                if (PEIsWalkableAtPosition(mWalkable, mSize, CGPointMake(sNodePoint.x, sNodePoint.y + sDirVector.y)))
                {
                    PEAddObjectIfNotNil(sNeighbors, PENodeAtPosition(mNodes, mSize, CGPointMake(sNodePoint.x, sNodePoint.y + sDirVector.y)));
                    
                    if (!PEIsWalkableAtPosition(mWalkable, mSize, CGPointMake(sNodePoint.x + 1, sNodePoint.y)))
                    {
                        PEAddObjectIfNotNil(sNeighbors, PENodeAtPosition(mNodes, mSize, CGPointMake(sNodePoint.x + 1, sNodePoint.y + sDirVector.y)));
                    }
                    
                    if (!PEIsWalkableAtPosition(mWalkable, mSize, CGPointMake(sNodePoint.x - 1, sNodePoint.y)))
                    {
                        PEAddObjectIfNotNil(sNeighbors, PENodeAtPosition(mNodes, mSize, CGPointMake(sNodePoint.x - 1, sNodePoint.y + sDirVector.y)));
                    }
                }
            }
            else
            {
                if (PEIsWalkableAtPosition(mWalkable, mSize, CGPointMake(sNodePoint.x + sDirVector.x, sNodePoint.y)))
                {
                    PEAddObjectIfNotNil(sNeighbors, PENodeAtPosition(mNodes, mSize, CGPointMake(sNodePoint.x + sDirVector.x, sNodePoint.y)));
                    
                    if (!PEIsWalkableAtPosition(mWalkable, mSize, CGPointMake(sNodePoint.x, sNodePoint.y + 1)))
                    {
                        PEAddObjectIfNotNil(sNeighbors, PENodeAtPosition(mNodes, mSize, CGPointMake(sNodePoint.x + sDirVector.x, sNodePoint.y + 1)));
                    }
                    
                    if (!PEIsWalkableAtPosition(mWalkable, mSize, CGPointMake(sNodePoint.x, sNodePoint.y - 1)))
                    {
                        PEAddObjectIfNotNil(sNeighbors, PENodeAtPosition(mNodes, mSize, CGPointMake(sNodePoint.x + sDirVector.x, sNodePoint.y - 1)));
                    }
                }
            }
        }
    }
    else
    {
        /*  return all neighbors  */
        return [self neighborsWith:aNode allowDiagonal:YES dontCrossCorners:NO];
    }
    
    return sNeighbors;
}


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
