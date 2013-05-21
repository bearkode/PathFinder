//
//  PEHeap.h
//  PathFinder
//
//  Created by cgkim on 13. 5. 20..
//  Copyright (c) 2013년 cgkim. All rights reserved.
//

#import <Foundation/Foundation.h>


@class PENode;


@interface PEHeap : NSObject


- (void)push:(PENode *)aNode;
- (PENode *)pop;
- (void)updateItem:(id)aItem;

- (BOOL)isEmpty;

@end
