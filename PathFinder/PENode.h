//
//  PENode.h
//  PathFinder
//
//  Created by cgkim on 13. 5. 20..
//  Copyright (c) 2013년 cgkim. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface PENode : NSObject


@property (nonatomic, readonly)            CGPoint position;
@property (nonatomic, getter = isWalkable) BOOL    walkable;

@property (nonatomic, assign)              CGFloat gValue;
@property (nonatomic, assign)              CGFloat fValue;
@property (nonatomic, assign)              CGFloat hValue;
@property (nonatomic, getter = isOpened)   BOOL    opened;
@property (nonatomic, getter = isClosed)   BOOL    closed;
@property (nonatomic, assign)              PENode *parent;


- (id)initWithPosition:(CGPoint)aPosition walkable:(BOOL)aWalkable;


- (BOOL)isEqualTo:(id)aObject;


@end
