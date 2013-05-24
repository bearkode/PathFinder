/*
 *  PEOpenList.m
 *  PathFinder
 *
 *  Created by bearkode on 13. 5. 20..
 *  Copyright (c) 2013 bearkode. All rights reserved.
 *
 */

#import "PEOpenList.h"
#import "PEPathNode.h"


@implementation PEOpenList
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


- (void)push:(PEPathNode *)aNode
{
    [mArray addObject:aNode];
//    NSLog(@"mArray size = %d", (int)[mArray count]);
}


- (PEPathNode *)pop  /*  pop the node which has the minimum `f` value.  */
{
    PEPathNode *sResult = nil;
    CGFloat     sMinF   = CGFLOAT_MAX;
    
    for (PEPathNode *sNode in mArray)
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
}


- (void)updateItem:(id)aItem
{
    /* DO NOTHING */
};


@end
