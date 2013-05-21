//
//  PEHeap.m
//  PathFinder
//
//  Created by cgkim on 13. 5. 20..
//  Copyright (c) 2013년 cgkim. All rights reserved.
//

#import "PEHeap.h"


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


- (void)push:(PENode *)aNode
{
    [mArray addObject:aNode];
}


- (PENode *)pop
{
    PENode *sResult = [mArray objectAtIndex:0];
    [mArray removeObjectAtIndex:0];
    
    return sResult;
}


- (BOOL)isEmpty
{
    if ([mArray count])
    {
        return NO;
    }
    
    return YES;
}


- (void)updateItem:(id)aItem
{
    NSUInteger sPos = [mArray indexOfObject:aItem];

//    if (cmp == null) {
//        cmp = defaultCmp;
//    }

    [self shiftDownWithStartPos:0 pos:sPos];
    [self shiftUpWithPos:sPos];
};


- (void)shiftDownWithStartPos:(NSUInteger)aStartPos pos:(NSUInteger)aPos
{
//    var newitem, parent, parentpos;
    
//    if (cmp == null) {
//        cmp = defaultCmp;
//    }
    
//    id sNewItem = [mArray objectAtIndex:aPos];
//
//    while (aPos > aStartPos)
//    {
//        NSUInteger sParentpos = (pos - 1) >> 1;
//        
//        id sParent = [mArray objectAtIndex:sParentpos];
//        
//        if (cmp(sNewitem, sParent) < 0)
//        {
//            [mArray insert
//            mArray[pos] = parent;
//            aPos = sParentpos;
//            continue;
//        }
//        break;
//    }
//
//    [mArray replaceObjectAtIndex:aPos withObject:sNewItem];
};


- (void)shiftUpWithPos:(NSUInteger)aPos
{
//    var childpos, endpos, newitem, rightpos, startpos;

//    if (cmp == null) {
//        cmp = defaultCmp;
//    }
    
//    endpos = array.length;
//    startpos = pos;
//    newitem = array[pos];
//    childpos = 2 * pos + 1;
//    
//    while (childpos < endpos)
//    {
//        rightpos = childpos + 1;
//        
//        if (rightpos < endpos && !(cmp(array[childpos], array[rightpos]) < 0))
//        {
//            childpos = rightpos;
//        }
//        
//        array[pos] = array[childpos];
//        pos = childpos;
//        childpos = 2 * pos + 1;
//    }
//    array[pos] = newitem;
//    [self shiftDownWithStartPos:startpos pos:pos];
};


@end
