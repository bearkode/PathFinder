/*
 *  PEGrid.m
 *  PathFinder
 *
 *  Created by bearkode on 13. 5. 20..
 *  Copyright (c) 2013 bearkode. All rights reserved.
 *
 */

#import "PEGrid.h"
#import "PEPathNode.h"


@implementation PEGrid


- (void)buildNodes
{
    for (NSInteger y = 0; y < mSize.height; y++)
    {
        for (NSInteger x = 0; x < mSize.width; x++)
        {
            NSInteger   sIndex = mSize.width * y + x;
            PEPathNode *sNode  = [[PEPathNode alloc] initWithPosition:CGPointMake(x, y) walkable:YES];
            
            mNodes[sIndex] = sNode;
        }
    }
}


- (void)clearNodes
{
    for (NSInteger i = 0; i < mSize.width * mSize.height; i++)
    {
        if (mNodes[i])
        {
            [mNodes[i] release];
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
        
        memset(mNodes, 0, aSize.width * aSize.height * sizeof(id));
        memset(mWalkable, 0, aSize.width * aSize.height * sizeof(unsigned char));
        
        [self buildNodes];
        
        if (aMatrix)
        {
            [self setMatrix:aMatrix];
        }
    }
    
    return self;
}


- (void)dealloc
{
    [self clearNodes];
    
    if (mNodes)
    {
        free(mNodes);
    }
    
    if (mWalkable)
    {
        free(mWalkable);
    }
    
    [super dealloc];
}


- (void)setMatrix:(unsigned char *)aMatrix
{
    [self reset];
    
    for (NSInteger y = 0; y < mSize.height; y++)
    {
        for (NSInteger x = 0; x < mSize.width; x++)
        {
            NSInteger   sIndex      = mSize.width * y + x;
            BOOL        sIsWalkable = (aMatrix[sIndex] == 0) ? YES : NO;
            PEPathNode *sNode       = mNodes[sIndex];
            
            [sNode setWalkable:sIsWalkable];
            mWalkable[sIndex] = sIsWalkable;
        }
    }
}


- (void)reset
{
    for (NSInteger i = 0; i < mSize.width * mSize.height; i++)
    {
        PEPathNode *sPathNode = mNodes[i];
        
        sPathNode->mGValue   = 0;
        sPathNode->mFValue   = 0;
        sPathNode->mHValue   = 0;
        sPathNode->mOpened   = NO;
        sPathNode->mClosed   = NO;
        sPathNode->mParent   = nil;
        sPathNode->mPrevNode = nil;
        sPathNode->mNextNode = nil;
    }
}


- (PEPathNode *)nodeAtPosition:(CGPoint)aPosition
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
    PEPathNode *sNode = PENodeAtPosition(mNodes, mSize, aPosition);

    [sNode setWalkable:aWalkable];
};


#define INSERT_NODE(a)  if (a) { aResult[sIndex++] = a; }


- (void)getNeighborsOfNode:(PEPathNode *)aNode result:(id *)aResult count:(NSInteger *)aCount
{
    NSInteger   sIndex  = 0;
    PEPathNode *sParent = [aNode parent];
    
    /*  directed pruning: can ignore most neighbors, unless forced.  */
    if (sParent)
    {
        CGPoint     sNodePoint   = [aNode position];
        CGPoint     sParentPoint = [sParent position];
        CGPoint     sDirVector;
        PEPathNode *sNode;
        
        /*  get the normalized direction of travel  */
        sDirVector.x = (sNodePoint.x - sParentPoint.x) / MAX(fabs(sNodePoint.x - sParentPoint.x), 1);
        sDirVector.y = (sNodePoint.y - sParentPoint.y) / MAX(fabs(sNodePoint.y - sParentPoint.y), 1);
        
        /*  search diagonally  */
        if (sDirVector.x != 0 && sDirVector.y != 0)
        {
            sNode = PENodeAtPosition(mNodes, mSize, CGPointMake(sNodePoint.x, sNodePoint.y + sDirVector.y));
            if ([sNode isWalkable])
            {
                INSERT_NODE(sNode);
            }
            
            sNode = PENodeAtPosition(mNodes, mSize, CGPointMake(sNodePoint.x + sDirVector.x, sNodePoint.y));
            if ([sNode isWalkable])
            {
                INSERT_NODE(sNode)
            }
            
            if (PEIsWalkableAtPosition(mWalkable, mSize, CGPointMake(sNodePoint.x, sNodePoint.y + sDirVector.y)) ||
                PEIsWalkableAtPosition(mWalkable, mSize, CGPointMake(sNodePoint.x + sDirVector.x, sNodePoint.y)))
            {
                sNode = PENodeAtPosition(mNodes, mSize, CGPointMake(sNodePoint.x + sDirVector.x, sNodePoint.y + sDirVector.y));
                INSERT_NODE(sNode)
            }
            
            if (!PEIsWalkableAtPosition(mWalkable, mSize, CGPointMake(sNodePoint.x - sDirVector.x, sNodePoint.y)) &&
                 PEIsWalkableAtPosition(mWalkable, mSize, CGPointMake(sNodePoint.x, sNodePoint.y + sDirVector.y)))
            {
                sNode = PENodeAtPosition(mNodes, mSize, CGPointMake(sNodePoint.x - sDirVector.x, sNodePoint.y + sDirVector.y));
                INSERT_NODE(sNode)
            }
            
            if (!PEIsWalkableAtPosition(mWalkable, mSize, CGPointMake(sNodePoint.x, sNodePoint.y - sDirVector.y)) &&
                 PEIsWalkableAtPosition(mWalkable, mSize, CGPointMake(sNodePoint.x + sDirVector.x, sNodePoint.y)))
            {
                sNode = PENodeAtPosition(mNodes, mSize, CGPointMake(sNodePoint.x + sDirVector.x, sNodePoint.y - sDirVector.y));
                INSERT_NODE(sNode)
            }
        }
        else  /*  search horizontally/vertically  */
        {
            if (sDirVector.x == 0)
            {
                if (PEIsWalkableAtPosition(mWalkable, mSize, CGPointMake(sNodePoint.x, sNodePoint.y + sDirVector.y)))
                {
                    sNode = PENodeAtPosition(mNodes, mSize, CGPointMake(sNodePoint.x, sNodePoint.y + sDirVector.y));
                    INSERT_NODE(sNode)
                    
                    if (!PEIsWalkableAtPosition(mWalkable, mSize, CGPointMake(sNodePoint.x + 1, sNodePoint.y)))
                    {
                        sNode = PENodeAtPosition(mNodes, mSize, CGPointMake(sNodePoint.x + 1, sNodePoint.y + sDirVector.y));
                        INSERT_NODE(sNode)
                    }
                    
                    if (!PEIsWalkableAtPosition(mWalkable, mSize, CGPointMake(sNodePoint.x - 1, sNodePoint.y)))
                    {
                        sNode = PENodeAtPosition(mNodes, mSize, CGPointMake(sNodePoint.x - 1, sNodePoint.y + sDirVector.y));
                        INSERT_NODE(sNode)
                    }
                }
            }
            else
            {
                if (PEIsWalkableAtPosition(mWalkable, mSize, CGPointMake(sNodePoint.x + sDirVector.x, sNodePoint.y)))
                {
                    sNode = PENodeAtPosition(mNodes, mSize, CGPointMake(sNodePoint.x + sDirVector.x, sNodePoint.y));
                    INSERT_NODE(sNode)
                    
                    if (!PEIsWalkableAtPosition(mWalkable, mSize, CGPointMake(sNodePoint.x, sNodePoint.y + 1)))
                    {
                        sNode = PENodeAtPosition(mNodes, mSize, CGPointMake(sNodePoint.x + sDirVector.x, sNodePoint.y + 1));
                        INSERT_NODE(sNode)
                    }
                    
                    if (!PEIsWalkableAtPosition(mWalkable, mSize, CGPointMake(sNodePoint.x, sNodePoint.y - 1)))
                    {
                        sNode = PENodeAtPosition(mNodes, mSize, CGPointMake(sNodePoint.x + sDirVector.x, sNodePoint.y - 1));
                        INSERT_NODE(sNode)
                    }
                }
            }
        }
    }
    else
    {
        /*  return all neighbors  */
        NSArray *sNeihbors = [self neighborsWith:aNode allowDiagonal:YES dontCrossCorners:NO];
        for (PEPathNode *sNode in sNeihbors)
        {
            aResult[sIndex++] = sNode;
        }
    }
    
    *aCount = sIndex;
}


- (NSMutableArray *)neighborsWith:(PEPathNode *)aNode allowDiagonal:(BOOL)aAllowDiagonal dontCrossCorners:(BOOL)aDontCrossCorners
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

    PEPathNode *sNode = nil;
    
    /*  Up  */
    sNode = PENodeAtPosition(mNodes, mSize, CGPointMake(x, y - 1));
    if ([sNode isWalkable])
    {
        [sNeighbors addObject:sNode];
        sS0 = YES;
    }
    
    /*  Right  */
    sNode = PENodeAtPosition(mNodes, mSize, CGPointMake(x + 1, y));
    if ([sNode isWalkable])
    {
        [sNeighbors addObject:sNode];
        sS1 = YES;
    }
    
    /*  Bottom  */
    sNode = PENodeAtPosition(mNodes, mSize, CGPointMake(x, y + 1));
    if ([sNode isWalkable])
    {
        [sNeighbors addObject:sNode];
        sS2 = YES;
    }
    
    /*  Left  */
    sNode = PENodeAtPosition(mNodes, mSize, CGPointMake(x - 1, y));
    if ([sNode isWalkable])
    {
        [sNeighbors addObject:sNode];
        sS3 = YES;
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
