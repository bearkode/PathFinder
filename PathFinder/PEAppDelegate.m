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
    [self performSelector:@selector(run) withObject:nil afterDelay:1.0];
}


@end
