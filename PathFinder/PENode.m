/*
 *  PENode.m
 *  PathFinder
 *
 *  Created by bearkode on 13. 5. 20..
 *  Copyright (c) 2013 bearkode. All rights reserved.
 *
 */

#import "PENode.h"


@implementation PENode
{
    CGPoint mPosition;
    BOOL    mWalkable;
    
    CGFloat mGValue;
    CGFloat mFValue;
    CGFloat mHValue;
    BOOL    mOpened;
    PENode *mParent;
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
        
        mHValue = NAN;
        mOpened = NO;
        mClosed = NO;
    }
    
    return self;
}


- (void)dealloc
{
    [super dealloc];
}


- (NSString *)description
{
    return [NSString stringWithFormat:@"Node (%d, %d) %@", (int)mPosition.x, (int)mPosition.y, (mWalkable) ? @"Walkable" : @"Nonwalkable"];
}


- (BOOL)isEqualTo:(id)aObject
{
    if (self == aObject)
    {
        return YES;
    }
    else
    {
        return NO;
    }
}


@end
