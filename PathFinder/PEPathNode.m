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


@implementation PEPathNode
{
    CGPoint     mPosition;
    BOOL        mWalkable;
    CGFloat     mGValue;
    CGFloat     mFValue;
    CGFloat     mHValue;
    BOOL        mOpened;
    PEPathNode *mParent;    /*  assign  */
}


@synthesize position = mPosition;
@synthesize walkable = mWalkable;
@synthesize gValue   = mGValue;
@synthesize fValue   = mFValue;
@synthesize hValue   = mHValue;
@synthesize opened   = mOpened;
@synthesize closed   = mClosed;
@synthesize parent   = mParent;


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
    }
    
    return self;
}


- (void)dealloc
{
    [super dealloc];
}


- (void)reset
{
    mGValue = 0;
    mFValue = 0;
    mHValue = 0;
    mOpened = NO;
    mClosed = NO;
    mParent = nil;
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
    NSValue        *sValue = nil;
    PEPathNode     *sNode  = self;
    
    sValue = [NSValue valueWithCGPoint:[sNode position]];
    [sPath addObject:sValue];
    
    while ((sNode = [sNode parent]))
    {
        sValue = [NSValue valueWithCGPoint:[sNode position]];
        [sPath insertObject:sValue atIndex:0];
    }
    
    return sPath;
}


@end
