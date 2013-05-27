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
#import "PECommonUtil.h"


@implementation PEOpenList
{
    PEPathNode *mHeadNode;  /* assign */
    PEPathNode *mTailNode;  /* assign */
}


- (id)init
{
    self = [super init];
    
    if (self)
    {
        mHeadNode = nil;
        mTailNode = nil;
    }
    
    return self;
}


- (void)dealloc
{
    [super dealloc];
}


- (void)push:(PEPathNode *)aNode
{
    CGFloat sFValue = [aNode fValue];
    
    if (mHeadNode)
    {
        if (sFValue < [mHeadNode fValue])
        {
            mHeadNode->mPrevNode = aNode;
            aNode->mNextNode = mHeadNode;
            mHeadNode = aNode;
        }
        else if (sFValue > [mTailNode fValue])
        {
            if (mTailNode)
            {
                mTailNode->mNextNode = aNode;
                aNode->mPrevNode = mTailNode;
                aNode->mNextNode = nil;
                mTailNode = aNode;
            }
        }
        else
        {
            PEPathNode *sNode     = mHeadNode;
            PEPathNode *sPrevNode = nil;
            
            while (1)
            {
                sPrevNode = sNode;
                sNode     = sNode->mNextNode;
                
                if (sNode)
                {
                    if (sFValue < [sNode fValue])
                    {
                        sPrevNode->mNextNode = aNode;
                        aNode->mNextNode = sNode;
                        sNode->mPrevNode = aNode;
                        aNode->mPrevNode = sPrevNode;
                        break;
                    }
                }
                else
                {
                    sPrevNode->mNextNode = aNode;
                    aNode->mPrevNode = sPrevNode;
                    break;
                }
            }
        }
    }
    else
    {
        mHeadNode = aNode;
        mTailNode = aNode;
    }
}


- (PEPathNode *)pop  /*  pop the node which has the minimum `f` value.  */
{
    PEPathNode *sResult = mHeadNode;

    if (mHeadNode)
    {
        mHeadNode = mHeadNode->mNextNode;
        
        sResult->mPrevNode = nil;
        sResult->mNextNode = nil;
    }
    
    return sResult;
}


- (void)updateItem:(id)aItem
{
    PEPathNode *sNode     = (PEPathNode *)aItem;
    PEPathNode *sPrevNode = sNode->mPrevNode;
    PEPathNode *sNextNode = sNode->mNextNode;
    
    if (aItem == mHeadNode)
    {
        mHeadNode = sNextNode;
        mHeadNode->mPrevNode = nil;
    }
    else if (aItem == mTailNode)
    {
        mTailNode = mTailNode->mPrevNode;
        mTailNode->mNextNode = nil;
    }
    else
    {
        if (sPrevNode)
        {
            sPrevNode->mNextNode = sNextNode;
        }
        
        if (sNextNode)
        {
            sNextNode->mPrevNode = sPrevNode;
        }
    }

    [self push:aItem];
};


- (void)printOpenList
{
    NSLog(@"==================================== BEGIN");
    PEPathNode *sNode = mHeadNode;
    
    NSLog(@"fValue = %f", [sNode fValue]);
    
    while ((sNode = sNode->mNextNode))
    {
        NSLog(@"fValue = %f", [sNode fValue]);
        
        if (sNode == mTailNode)
        {
            break;
        }
    }
    
    NSLog(@"==================================== END");
}


@end
