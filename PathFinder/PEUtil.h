/*
 *  PEUtil.h
 *  PathFinder
 *
 *  Created by bearkode on 13. 5. 20..
 *  Copyright (c) 2013 bearkode. All rights reserved.
 *
 */

#import <Foundation/Foundation.h>


@class PEPathNode;


@interface PEUtil : NSObject


+ (NSMutableArray *)backtrace:(PEPathNode *)aNode;


@end
