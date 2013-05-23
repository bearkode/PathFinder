/*
 *  PEHeap.m
 *  PathFinder
 *
 *  Created by bearkode on 13. 5. 20..
 *  Copyright (c) 2013 bearkode. All rights reserved.
 *
 */

#import "PEHeap.h"
#import "PENode.h"


@implementation PEHeap
{
    NSMutableArray *mArray;
}


- (id)init
{
    self = [super init];
    
    if (self)
    {
        mArray = [[NSMutableArray alloc] init];
    }
    
    return self;
}


- (void)dealloc
{
    [mArray release];
    
    [super dealloc];
}


- (void)sort
{
    [mArray sortUsingComparator:^NSComparisonResult(id aObj1, id aObj2) {
        
        CGFloat sValue1 = [aObj1 fValue];
        CGFloat sValue2 = [aObj2 fValue];
        
        if (sValue1 < sValue2)
        {
            return NSOrderedDescending;
        }
        else if (sValue1 > sValue2)
        {
            return NSOrderedAscending;
        }
        else
        {
            return NSOrderedSame;
        }
    }];
}


- (void)push:(PENode *)aNode
{
    [mArray addObject:aNode];

    if ([mArray count] > 1)
    {
        [self sort];
    }
}


// pop the position of node which has the minimum `f` value.
- (PENode *)pop
{
    PENode *sResult = [[mArray lastObject] retain];
    [mArray removeLastObject];
    
    return [sResult autorelease];
}


- (BOOL)isEmpty
{
    return ([mArray count]) ? NO : YES;
}


- (void)updateItem:(id)aItem
{
    if ([mArray count] > 1)
    {
        [self sort];
    }
};


@end
