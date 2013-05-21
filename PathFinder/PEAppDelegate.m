//
//  PEAppDelegate.m
//  PathFinder
//
//  Created by cgkim on 13. 5. 20..
//  Copyright (c) 2013년 cgkim. All rights reserved.
//

#import "PEAppDelegate.h"
#import "PEGrid.h"
#import "PEFinder.h"


@implementation PEAppDelegate


- (void)dealloc
{
    [super dealloc];
}


- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    unsigned char sMatrix[25] = { 0x00, 0x01, 0x00, 0x00, 0x00,
                                  0x00, 0x01, 0x00, 0x00, 0x00,
                                  0x00, 0x00, 0x00, 0x00, 0x00,
                                  0x00, 0x00, 0x00, 0x00, 0x00,
                                  0x00, 0x00, 0x00, 0x00, 0x00 };
    
    PEGrid         *sGrid   = [[[PEGrid alloc] initWithSize:CGSizeMake(5, 5) matrix:sMatrix] autorelease];
    PEFinder       *sFinder = [[[PEFinder alloc] init] autorelease];
    NSMutableArray *sPath   = [sFinder findPathWithStartPosition:CGPointMake(0, 0) endPosition:CGPointMake(3, 0) grid:sGrid];
    
    NSLog(@"sPath = %@", sPath);
}


@end
