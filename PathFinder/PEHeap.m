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
}


- (PENode *)pop  /*  pop the node which has the minimum `f` value.  */
{
#if (1)
    
    PENode *sResult = nil;
    CGFloat sMinF   = CGFLOAT_MAX;
    
    for (PENode *sNode in mArray)
    {
        CGFloat sFValue = [sNode fValue];
        
        if (sFValue < sMinF)
        {
            sMinF   = sFValue;
            sResult = sNode;
        }
    }
    
    [mArray removeObject:sResult];
    
    return sResult;
    
#else
    NSInteger sCount = [mArray count];
    
    if (sCount == 0)
    {
        return nil;
    }
    
    else if ([mArray count] > 1)
    {
        [self sort];
    }

    PENode *sResult = [[mArray lastObject] retain];
    [mArray removeLastObject];
    
    return [sResult autorelease];
#endif
}


//- (BOOL)isEmpty
//{
//    return ([mArray count]) ? NO : YES;
//}


- (void)updateItem:(id)aItem
{
    if ([mArray count] > 1)
    {
        [self sort];
    }
};


@end
