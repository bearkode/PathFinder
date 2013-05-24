/*
 *  PEOpenList
 *  PathFinder
 *
 *  Created by bearkode on 13. 5. 20..
 *  Copyright (c) 2013 bearkode. All rights reserved.
 *
 */

#import <Foundation/Foundation.h>


@class PEPathNode;


@interface PEOpenList : NSObject


- (void)push:(PEPathNode *)aNode;
- (PEPathNode *)pop;
- (void)updateItem:(id)aItem;


@end
