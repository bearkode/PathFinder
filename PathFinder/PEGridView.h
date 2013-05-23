/*
 *  PEGridView.h
 *  PathFinder
 *
 *  Created by bearkode on 13. 5. 22..
 *  Copyright (c) 2013 bearkode. All rights reserved.
 *
 */

#import <Cocoa/Cocoa.h>


typedef enum
{
    kPEStartPointEditMode = 0,
    kPEEndPointEditMode,
    kPEOpenEditMode,
    kPEBlockEditMode,
} PEEditMode;


@interface PEGridView : NSView


- (void)reset;


- (void)setEditMode:(PEEditMode)aEditMode;


- (void)setStartPoint:(NSPoint)aStartPoint;
- (NSPoint)startPoint;
- (void)setEndPoint:(NSPoint)aEndPoint;
- (NSPoint)endPoint;
- (void)setMapSize:(NSSize)aMapSize;
- (NSSize)mapSize;

- (void)setMatrix:(unsigned char *)aMatrix;
- (unsigned char *)matrix;


- (void)setPath:(NSArray *)aPath;


@end
