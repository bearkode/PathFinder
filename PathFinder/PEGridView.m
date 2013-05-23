/*
 *  PEGridView.m
 *  PathFinder
 *
 *  Created by bearkode on 13. 5. 22..
 *  Copyright (c) 2013 bearkode. All rights reserved.
 *
 */

#import "PEGridView.h"


#define kGridWidth  50
#define kGridHeight 50


#define kOpen  0
#define kBlock 1
#define kStart 2
#define kEnd   3


@implementation PEGridView
{
    NSSize        mSize;
    NSPoint       mStartPoint;
    NSPoint       mEndPoint;
    
    NSColor      *mStartPointColor;
    NSColor      *mEndPointColor;
    NSColor      *mBlockColor;
    NSColor      *mOpenColor;
    
    NSInteger     mGrid[kGridWidth * kGridHeight];
    unsigned char mMatrix[kGridWidth * kGridHeight];
    
    PEEditMode    mEditMode;
    NSPoint       mPrevPoint;
    
    NSArray      *mPath;
}


- (void)setup
{
    mSize       = NSMakeSize(50, 50);
    mStartPoint = NSMakePoint(10, 10);
    mEndPoint   = NSMakePoint(40, 40);
    
    for (NSInteger i = 0; i < kGridWidth * kGridHeight; i++)
    {
        mGrid[i] = 0;
    }
    
    [self setValue:kStart atPosition:mStartPoint];
    [self setValue:kEnd atPosition:mEndPoint];
    
    mStartPointColor = [[NSColor greenColor] retain];
    mEndPointColor   = [[NSColor orangeColor] retain];
    mBlockColor      = [[NSColor grayColor] retain];
    mOpenColor       = [[NSColor whiteColor] retain];
}


- (id)initWithFrame:(NSRect)aFrame
{
    self = [super initWithFrame:aFrame];
    
    if (self)
    {
        [self setup];
    }
    
    return self;
}


- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if (self)
    {
        [self setup];
    }
    
    return self;
}


- (void)dealloc
{
    [mStartPointColor release];
    [mEndPointColor release];
    [mBlockColor release];
    [mOpenColor release];
    
    [super dealloc];
}


- (void)reset
{
    for (NSInteger i = 0; i < kGridWidth * kGridHeight; i++)
    {
        mGrid[i] = 0;
    }
    
    [self setValue:kStart atPosition:mStartPoint];
    [self setValue:kEnd atPosition:mEndPoint];

    [self setNeedsDisplay:YES];
}


- (void)setValue:(NSInteger)aValue atPosition:(NSPoint)aPoint
{
    mGrid[(int)(kGridWidth * aPoint.y + aPoint.x)] = aValue;
    [self setNeedsDisplay:YES];
}


- (NSInteger)valueAtPosition:(NSPoint)aPoint
{
    return mGrid[(int)(kGridWidth * aPoint.y + aPoint.x)];
}


- (BOOL)isOpenAtPosition:(NSPoint)aPoint
{
    if (mGrid[(int)(mSize.width * aPoint.y + aPoint.x)])
    {
        return NO;
    }
    else
    {
        return YES;
    }
}


- (void)drawRect:(NSRect)aRect
{
    [[NSColor lightGrayColor] setStroke];
    
    for (NSInteger y = 0; y < mSize.height; y++)
    {
        for (NSInteger x = 0; x < mSize.width; x++)
        {
            NSRect    sGridRect = NSMakeRect(x * 10, y * 10, 10, 10);
            NSInteger sValue    = [self valueAtPosition:NSMakePoint(x, y)];
            
            if (sValue == kStart)
            {
                [mStartPointColor setFill];
            }
            else if (sValue == kEnd)
            {
                [mEndPointColor setFill];
            }
            else if (sValue == kOpen)
            {
                [mOpenColor setFill];
            }
            else if (sValue == kBlock)
            {
                [mBlockColor setFill];
            }
            
            [NSBezierPath fillRect:sGridRect];
            [NSBezierPath strokeRect:sGridRect];
        }
    }
    
    if ([mPath count])
    {
        [[NSColor blueColor] set];
        
        NSBezierPath *sPath  = [NSBezierPath bezierPath];
        NSValue      *sValue = [mPath objectAtIndex:0];
        NSPoint       sPoint = [sValue pointValue];
        
        [sPath moveToPoint:NSMakePoint(sPoint.x * 10 + 5, sPoint.y * 10 + 5)];
        
        for (sValue in mPath)
        {
            sPoint = [sValue pointValue];
            [sPath lineToPoint:NSMakePoint(sPoint.x * 10 + 5, sPoint.y * 10 + 5)];
        }
        
        [sPath stroke];
    }
}


- (void)mouseDragged:(NSEvent *)aEvent
{
    NSPoint   sLocation  = [self convertPoint:[aEvent locationInWindow] fromView:nil];
    NSPoint   sGridPoint = NSMakePoint((int)(sLocation.x / 10), (int)(sLocation.y / 10));
    NSInteger sValue;
    
    if (!NSEqualPoints(mPrevPoint, sGridPoint))
    {
        sValue = [self valueAtPosition:sGridPoint];;
        
        if (mEditMode == kPEStartPointEditMode)
        {
            if (sValue == kOpen)
            {
                [self setValue:kOpen atPosition:mStartPoint];
                mStartPoint = sGridPoint;
                [self setValue:kStart atPosition:mStartPoint];
            }
        }
        else if (mEditMode == kPEEndPointEditMode)
        {
            if (sValue == kOpen)
            {
                [self setValue:kOpen atPosition:mEndPoint];
                mEndPoint = sGridPoint;
                [self setValue:kEnd atPosition:mEndPoint];
            }
        }
        else if (mEditMode == kPEOpenEditMode)
        {
            if (sValue == kBlock)
            {
                [self setValue:kOpen atPosition:sGridPoint];
            }
        }
        else if (mEditMode == kPEBlockEditMode)
        {
            if (sValue == kOpen)
            {
                [self setValue:kBlock atPosition:sGridPoint];
            }
        }
    }
}


- (void)mouseUp:(NSEvent *)aEvent
{
    mPrevPoint = NSMakePoint(-1, -1);
}


- (void)setEditMode:(PEEditMode)aEditMode
{
    mEditMode  = aEditMode;
    mPrevPoint = NSMakePoint(-1, -1);
}


- (void)setStartPoint:(NSPoint)aStartPoint
{
    [self setValue:kOpen atPosition:mStartPoint];
    mStartPoint = aStartPoint;
    [self setValue:kStart atPosition:mStartPoint];

    [self setNeedsDisplay:YES];
}


- (NSPoint)startPoint
{
    return mStartPoint;
}


- (void)setEndPoint:(NSPoint)aEndPoint
{
    [self setValue:kOpen atPosition:mEndPoint];
    mEndPoint = aEndPoint;
    [self setValue:kEnd atPosition:mEndPoint];
    
    [self setNeedsDisplay:YES];
}


- (NSPoint)endPoint
{
    return mEndPoint;
}


- (void)setMapSize:(NSSize)aMapSize
{
    mSize = aMapSize;
}


- (NSSize)mapSize
{
    return mSize;
}


- (void)setMatrix:(unsigned char *)aMatrix
{
    for (NSInteger i = 0; i < kGridWidth * kGridHeight; i++)
    {
        if (aMatrix[i] == 1)
        {
            mGrid[i] = kBlock;
        }
    }
    
    [self setNeedsDisplay:YES];
}


- (unsigned char *)matrix
{
    for (NSInteger i = 0; i < kGridWidth * kGridHeight; i++)
    {
        mMatrix[i] = (mGrid[i] == kBlock) ? 1 : 0;
    }
    
    return mMatrix;
}


- (void)setPath:(NSArray *)aPath
{
    [mPath autorelease];
    mPath = [aPath retain];
    
    [self setNeedsDisplay:YES];
}


@end
