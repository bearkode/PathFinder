//
//  PEUtil.m
//  PathFinder
//
//  Created by cgkim on 13. 5. 20..
//  Copyright (c) 2013년 cgkim. All rights reserved.
//

#import "PEUtil.h"
#import "PENode.h"


@implementation PEUtil


+ (NSMutableArray *)backtrace:(PENode *)aNode
{
    NSMutableArray *sPath = [NSMutableArray array];
    
    NSValue *sValue = [NSValue valueWithPoint:NSPointFromCGPoint([aNode position])];
    [sPath addObject:sValue];
    
    PENode *sNode = aNode;
    
    while ([sNode parent])
    {
        sNode = [sNode parent];
        sValue = [NSValue valueWithPoint:NSPointFromCGPoint([sNode position])];
        [sPath addObject:sValue];
    }
    
    return [NSMutableArray arrayWithArray:[[sPath reverseObjectEnumerator] allObjects]];
}


@end
