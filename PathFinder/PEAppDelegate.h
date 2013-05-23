/*
 *  PEAppDelegate.h
 *  PathFinder
 *
 *  Created by bearkode on 13. 5. 20..
 *  Copyright (c) 2013 bearkode. All rights reserved.
 *
 */

#import <Cocoa/Cocoa.h>
#import "PEGridView.h"


@interface PEAppDelegate : NSObject <NSApplicationDelegate>


@property (assign) IBOutlet PEGridView *gridView;
@property (assign) IBOutlet NSWindow   *window;


- (IBAction)startButtonClicked:(id)aSender;
- (IBAction)endButtonClicked:(id)aSender;
- (IBAction)openButtonClicked:(id)aSender;
- (IBAction)blockButtonClicked:(id)aSender;

- (IBAction)clearButtonClicked:(id)aSender;
- (IBAction)saveButtonClicked:(id)aSender;

- (IBAction)findButtonClicked:(id)aSender;


@end
