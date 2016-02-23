//
//  CameraTestViewController.m
//  Joystick
//
//  Created by Mark Zykin on 12/3/14.
//  Copyright (c) 2014 Dynamic Perception. All rights reserved.
//

#import <CocoaLumberjack/CocoaLumberjack.h>

#import "CameraTestViewController.h"
#import "JoyButton.h"
#import "AppExecutive.h"
#import "NMXDevice.h"
#import "CameraSettingsTimelineView.h"


//------------------------------------------------------------------------------

#pragma mark - Private Interface


@interface CameraTestViewController ()

@property (nonatomic, strong)	IBOutlet	JoyButton *		stopCameraTestButton;
@property (strong, nonatomic) IBOutlet CameraSettingsTimelineView *cameraTimelineView;

@end


//------------------------------------------------------------------------------

#pragma mark - Implementation


@implementation CameraTestViewController

#pragma mark Public Propery Synthesis

#pragma mark Private Propery Synthesis

#pragma mark Public Propery Methods

#pragma mark Private Propery Methods


//------------------------------------------------------------------------------

#pragma mark - Object Management


- (void) viewDidLoad {
	[super viewDidLoad];
    
    AppExecutive *appExec = [AppExecutive sharedInstance];
    [self.cameraTimelineView setCameraTimesForFocus:[appExec.focusNumber integerValue]
                                            trigger:[appExec.triggerNumber integerValue]
                                              delay:[appExec.delayNumber integerValue]
                                             buffer:[appExec.bufferNumber integerValue]
                                           animated:NO];

}

- (void) viewDidLayoutSubviews
{
    AppExecutive *appExec = [AppExecutive sharedInstance];
    
    [self.cameraTimelineView setCameraTimesForFocus:[appExec.focusNumber integerValue]
                                            trigger:[appExec.triggerNumber integerValue]
                                              delay:[appExec.delayNumber integerValue]
                                             buffer:[appExec.bufferNumber integerValue]
                                           animated:NO];
}

- (void) viewWillAppear:(BOOL)animated {

    [super viewWillAppear: animated];
    
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(deviceDisconnect:)
                                                 name: kDeviceDisconnectedNotification
                                               object: nil];
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear: animated];
    
    [self.cameraTimelineView startPlayheadAnimation];
}


- (void) viewWillDisappear:(BOOL)animated {

    [super viewWillDisappear: animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver: self];
}

- (void) deviceDisconnect: (id) object {
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        [self dismissViewControllerAnimated: YES completion: nil];
    });
}


//------------------------------------------------------------------------------

#pragma mark - IBAction Methods


- (IBAction) handleStopCameraTestButton: (id) sender {

	DDLogDebug(@"Stop Camera Test Button");
    [[AppExecutive sharedInstance].device cameraSetTestMode: false];

	[self dismissViewControllerAnimated: YES completion: nil];
}


@end
