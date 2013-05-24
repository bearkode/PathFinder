/*
 *  PEPathNode.h
 *  PathFinder
 *
 *  Created by bearkode on 13. 5. 20..
 *  Copyright (c) 2013 bearkode. All rights reserved.
 *
 */

#import <Foundation/Foundation.h>


@interface PEPathNode : NSObject
{
@public
    PEPathNode *mPrevNode;  /*  assign  */
    PEPathNode *mNextNode;  /*  assign  */
}

@property (nonatomic, readonly)            CGPoint     position;
@property (nonatomic, readonly)            NSValue    *positionValue;
@property (nonatomic, getter = isWalkable) BOOL        walkable;
@property (nonatomic, assign)              CGFloat     gValue;
@property (nonatomic, assign)              CGFloat     fValue;
@property (nonatomic, assign)              CGFloat     hValue;
@property (nonatomic, getter = isOpened)   BOOL        opened;
@property (nonatomic, getter = isClosed)   BOOL        closed;
@property (nonatomic, assign)              PEPathNode *parent;


- (id)initWithPosition:(CGPoint)aPosition walkable:(BOOL)aWalkable;

- (void)reset;
- (void)updateFValue;
- (BOOL)isEqualTo:(id)aObject;

- (NSMutableArray *)backtrace;

@end
