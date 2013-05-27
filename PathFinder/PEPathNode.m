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
    CGPoint         sPrevPoint;
    CGPoint         sCurrPoint;
    
    [sPath addObject:[sNode positionValue]];
    sPrevPoint = [sNode position];
    
    while ((sNode = [sNode parent]))
    {
        sCurrPoint = [sNode position];
        
//        CGPoint sDelta = CGPointMake(sPrevPoint.x - sCurrPoint.x, sPrevPoint.y - sCurrPoint.y);
//        NSLog(@"sDelta = %@", NSStringFromCGPoint(sDelta));
        
        [sPath insertObject:[sNode positionValue] atIndex:0];
    }
    
    return sPath;
}


@end
