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


//------------------------------------------------------------------------------

#pragma mark - Private Interface


@interface CameraTestViewController ()

@property (nonatomic, strong)	IBOutlet	JoyButton *		stopCameraTestButton;

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
}

- (void) viewWillAppear:(BOOL)animated {

    [super viewWillAppear: animated];
    
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(deviceDisconnect:)
                                                 name: kDeviceDisconnectedNotification
                                               object: nil];
}

- (void) viewWillDisappear:(BOOL)animated {

    [super viewWillDisappear: animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver: self];
}

- (void) deviceDisconnect: (id) object {

    [self dismissViewControllerAnimated: YES completion: nil];
}


//------------------------------------------------------------------------------

#pragma mark - IBAction Methods


- (IBAction) handleStopCameraTestButton: (id) sender {

	DDLogDebug(@"Stop Camera Test Button");
    [[AppExecutive sharedInstance].device cameraSetTestMode: false];

	[self dismissViewControllerAnimated: YES completion: nil];
}


@end
