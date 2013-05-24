/*
 *  PEUtil.m
 *  PathFinder
 *
 *  Created by bearkode on 13. 5. 20..
 *  Copyright (c) 2013 bearkode. All rights reserved.
 *
 */

#import "PEUtil.h"
#import "PEPathNode.h"
#import "NSValue+Compatibility.h"


@implementation PEUtil


+ (NSMutableArray *)backtrace:(PEPathNode *)aNode
{
    NSMutableArray *sPath  = [NSMutableArray array];
    NSValue        *sValue = nil;
    PEPathNode         *sNode  = aNode;
    
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
