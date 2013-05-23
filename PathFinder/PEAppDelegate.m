/*
 *  PEAppDelegate.m
 *  PathFinder
 *
 *  Created by bearkode on 13. 5. 20..
 *  Copyright (c) 2013 bearkode. All rights reserved.
 *
 */

#import "PEAppDelegate.h"
#import "PECommonUtil.h"
#import "PEGrid.h"
#import "PEFinder.h"
#import "NSValue+Compatibility.h"


@implementation PEAppDelegate
{
    PEGridView *mGridView;
}


@synthesize gridView = mGridView;


- (void)dealloc
{
    [super dealloc];
}


- (void)run
{
    unsigned char sMatrix[49] = { 0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00,
                                  0x00, 0x01, 0x01, 0x00, 0x00, 0x00, 0x00,
                                  0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00,
                                  0x00, 0x00, 0x01, 0x01, 0x00, 0x01, 0x00,
                                  0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x00,
                                  0x00, 0x00, 0x01, 0x01, 0x01, 0x01, 0x00,
                                  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
        
    };
    
    PEGrid         *sGrid   = [[[PEGrid alloc] initWithSize:CGSizeMake(7, 7) matrix:sMatrix] autorelease];
    PEFinder       *sFinder = [[[PEFinder alloc] init] autorelease];
    NSMutableArray *sPath   = nil;

    for (NSInteger i = 0; i < 100; i++)
    {
        [sGrid reset];
        PEBeginTimeCheck();
        sPath = [sFinder findPathWithStartPosition:CGPointMake(0, 0) endPosition:CGPointMake(6, 2) grid:sGrid];
        PEEndTimeCheck();
    }
    NSLog(@"sPath = %@", sPath);
}


- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
//    [self performSelector:@selector(run) withObject:nil afterDelay:1.0];

    NSDictionary *sLoadDict = [NSDictionary dictionaryWithContentsOfFile:@"/Users/cgkim/Desktop/PathFinder.test"];
    if (sLoadDict)
    {
        NSPoint sStartPoint = NSPointFromString([sLoadDict objectForKey:@"start_point"]);
        NSPoint sEndPoint   = NSPointFromString([sLoadDict objectForKey:@"end_point"]);
        NSSize  sMapSize    = NSSizeFromString([sLoadDict objectForKey:@"map_size"]);
        NSData *sMatrix     = [sLoadDict objectForKey:@"matrix"];

        [mGridView setStartPoint:sStartPoint];
        [mGridView setEndPoint:sEndPoint];
        [mGridView setMapSize:sMapSize];
        [mGridView setMatrix:(unsigned char *)[sMatrix bytes]];
    }
}


- (IBAction)startButtonClicked:(id)aSender
{
    [mGridView setEditMode:kPEStartPointEditMode];
}


- (IBAction)endButtonClicked:(id)aSender
{
    [mGridView setEditMode:kPEEndPointEditMode];
}


- (IBAction)openButtonClicked:(id)aSender
{
    [mGridView setEditMode:kPEOpenEditMode];
}


- (IBAction)blockButtonClicked:(id)aSender
{
    [mGridView setEditMode:kPEBlockEditMode];
}


- (IBAction)clearButtonClicked:(id)aSender
{
    [mGridView reset];
}


- (IBAction)saveButtonClicked:(id)aSender
{
    NSPoint        sStartPoint = [mGridView startPoint];
    NSPoint        sEndPoint   = [mGridView endPoint];
    NSSize         sMapSize    = [mGridView mapSize];
    unsigned char *sMatrix     = [mGridView matrix];
    NSData        *sMatrixData = [NSData dataWithBytes:sMatrix length:(sMapSize.width * sMapSize.height)];
    
    NSMutableDictionary *sSaveDict = [NSMutableDictionary dictionary];
    [sSaveDict setObject:NSStringFromPoint(sStartPoint) forKey:@"start_point"];
    [sSaveDict setObject:NSStringFromPoint(sEndPoint) forKey:@"end_point"];
    [sSaveDict setObject:NSStringFromSize(sMapSize) forKey:@"map_size"];
    [sSaveDict setObject:sMatrixData forKey:@"matrix"];
    
    [sSaveDict writeToFile:@"/Users/cgkim/Desktop/PathFinder.test" atomically:YES];
}


- (IBAction)findButtonClicked:(id)aSender
{
    NSPoint        sStartPoint = [mGridView startPoint];
    NSPoint        sEndPoint   = [mGridView endPoint];
    NSSize         sMapSize    = [mGridView mapSize];
    unsigned char *sMatrix     = [mGridView matrix];
    
    PEGrid         *sGrid      = [[[PEGrid alloc] initWithSize:CGSizeMake(sMapSize.width, sMapSize.height) matrix:sMatrix] autorelease];
    PEFinder       *sFinder    = [[[PEFinder alloc] init] autorelease];
    NSMutableArray *sPath      = nil;

#if (1)
    PEBeginTimeCheck();
    sPath = [sFinder findPathWithStartPosition:CGPointMake(sStartPoint.x, sStartPoint.y) endPosition:CGPointMake(sEndPoint.x, sEndPoint.y) grid:sGrid];
    PEEndTimeCheck();
#else
    
    for (NSInteger i = 0; i < 1000; i++)
    {
        [sGrid reset];
        sPath = [sFinder findPathWithStartPosition:CGPointMake(sStartPoint.x, sStartPoint.y) endPosition:CGPointMake(sEndPoint.x, sEndPoint.y) grid:sGrid];
    }
    
#endif
    
    [mGridView setPath:sPath];
}


@end
