/*
 *  PEPathNode.m
 *  PathFinder
 *
 *  Created by bearkode on 13. 5. 20..
 *  Copyright (c) 2013 bearkode. All rights reserved.
 *
 */

#import "PEPathNode.h"
#import "NSValue+Compatibility.h"
#import "PECommonUtil.h"


@interface NSMutableArray (PathNodeAddition)


- (void)addPositionsTo:(PEPathNode *)aNode;


@end


@implementation NSMutableArray (PathNodeAddition)


- (void)addPositionsTo:(PEPathNode *)aNode
{
    PEPathNode *sParent = [aNode parent];

    [self addObject:[aNode positionValue]];
    
    if (sParent)
    {
        CGPoint sPoint1 = [aNode position];
        CGPoint sPoint2 = [sParent position];
        CGPoint sVector = CGPointMake(sPoint1.x - sPoint2.x, sPoint1.y - sPoint2.y);
        CGPoint sPoint  = sPoint1;
        
        sVector.x = (sVector.x == 0) ? 0 : (sVector.x > 0 ) ? -1 : 1;
        sVector.y = (sVector.y == 0) ? 0 : (sVector.y > 0 ) ? -1 : 1;

        for (NSInteger sIndex = 0; sIndex < MAX(sPoint1.x - sPoint2.x, sPoint1.y - sPoint2.y); sIndex++)
        {
            sPoint.x += sVector.x;
            sPoint.y += sVector.y;
            
            if (CGPointEqualToPoint(sPoint, sPoint2))
            {
                break;
            }
            else
            {
                [self addObject:[NSValue valueWithCGPoint:sPoint]];
            }
        }
    }
    
    
#if (0)
    if ([aNode parent])
    {
        PEPathNode *sParent = [aNode parent];
        CGPoint     sPoint1 = [aNode position];
        CGPoint     sPoint2 = [sParent position];
        NSInteger   sXDelta = sPoint1.x - sPoint2.x;
        NSInteger   sYDelta = sPoint1.y - sPoint2.y;
        NSInteger   sXAbs   = abs((int)sXDelta);
        NSInteger   sYAbs   = abs((int)sYDelta);
        
        if (sXAbs == 1 && sYAbs == 1)
        {
            [self addObject:[aNode positionValue]];
        }
        else
        {
            if (sXAbs > 1 && sYAbs > 1)
            {
                for (NSInteger x = 0; x < sXAbs; x++)
                {
                    NSInteger sX = (sXDelta > 0) ? -x : x;
                    NSInteger sY = (sYDelta > 0) ? -x : x;
                    
                    CGPoint sPoint = CGPointMake(sPoint1.x + sX, sPoint1.y + sY);
                    [self addObject:[NSValue valueWithCGPoint:sPoint]];
                }
            }
            else if (sXAbs >= 1 && sYAbs == 0)
            {
                for (NSInteger x = 0; x < sXAbs; x++)
                {
                    NSInteger sX = (sXDelta > 0) ? -x : x;
                    CGPoint sPoint = CGPointMake(sPoint1.x + sX, sPoint1.y);
                    [self addObject:[NSValue valueWithCGPoint:sPoint]];
                }
            }
            else if (sYAbs >= 1 && sXAbs == 0)
            {
                for (NSInteger y = 0; y < sYAbs; y++)
                {
                    NSInteger sY = (sYDelta > 0) ? -y : y;
                    CGPoint sPoint = CGPointMake(sPoint1.x, sPoint1.y + sY);
                    [self addObject:[NSValue valueWithCGPoint:sPoint]];
                }
            }
        }
    }
    else
    {
        [self addObject:[aNode positionValue]];
    }
#endif
}


@end


@implementation PEPathNode
{
    CGPoint     mPosition;
    NSValue    *mPositionValue;
    BOOL        mWalkable;
    CGFloat     mGValue;
    CGFloat     mFValue;
    CGFloat     mHValue;
    BOOL        mOpened;
    PEPathNode *mParent;    /*  assign  */
}


@synthesize position      = mPosition;
@synthesize positionValue = mPositionValue;
@synthesize walkable      = mWalkable;
@synthesize gValue        = mGValue;
@synthesize fValue        = mFValue;
@synthesize hValue        = mHValue;
@synthesize opened        = mOpened;
@synthesize closed        = mClosed;
@synthesize parent        = mParent;


- (id)initWithPosition:(CGPoint)aPosition walkable:(BOOL)aWalkable
{
    self = [super init];
    
    if (self)
    {
        mPosition = aPosition;
        mWalkable = aWalkable;
        
        mFValue = 0;
        mHValue = 0;
        mOpened = NO;
        mClosed = NO;
        
        mPositionValue = [[NSValue valueWithCGPoint:mPosition] retain];
    }
    
    return self;
}


- (void)dealloc
{
    [mPositionValue release];
    
    [super dealloc];
}


- (void)reset
{
    mGValue   = 0;
    mFValue   = 0;
    mHValue   = 0;
    mOpened   = NO;
    mClosed   = NO;
    mParent   = nil;
    mPrevNode = nil;
    mNextNode = nil;
}


- (NSString *)description
{
    return [NSString stringWithFormat:@"Node (%d, %d) %@", (int)mPosition.x, (int)mPosition.y, (mWalkable) ? @"Walkable" : @"Nonwalkable"];
}


- (BOOL)isEqualTo:(id)aObject
{
    return (self == aObject) ? YES : NO;
}


- (void)updateFValue
{
    mFValue = mGValue + mHValue;
}


- (NSMutableArray *)backtrace
{
    NSMutableArray *sPath  = [NSMutableArray array];
    PEPathNode     *sNode  = self;
    
    [sPath addPositionsTo:sNode];
    
    while ((sNode = [sNode parent]))
    {
        [sPath addPositionsTo:sNode];
    }
    
    return sPath;
}


@end
