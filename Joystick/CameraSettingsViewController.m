//
//  CameraSettingsViewController.m
//  Joystick
//
//  Created by Mark Zykin on 11/24/14.
//  Copyright (c) 2014 Dynamic Perception. All rights reserved.
//

#import <CocoaLumberjack/CocoaLumberjack.h>

#import "CameraSettingsViewController.h"
#import "SetSecondsViewController.h"
#import "IntervalViewController.h"
#import "AppExecutive.h"
#import "JoyButton.h"


//------------------------------------------------------------------------------

#pragma mark - Private Interface


@interface CameraSettingsViewController () {

	UIAlertView *	triggerAlert;
	UIAlertView *	delayAlert;
	UIAlertView *	focusAlert;
	UIAlertView *	intervalAlert;
}

@property (nonatomic, strong)				AppExecutive *		appExecutive;
@property (nonatomic, strong)	IBOutlet	UIView *			controlBackground;
@property (nonatomic, strong)	IBOutlet	UILabel *			focusValueLabel;
@property (nonatomic, strong)	IBOutlet	UILabel *			triggerValueLabel;
@property (nonatomic, strong)	IBOutlet	UILabel *			delayValueLabel;
@property (nonatomic, strong)	IBOutlet	UILabel *			intervalValueLabel;
@property (nonatomic, strong)	IBOutlet	UILabel *			bufferValueLabel;
@property (nonatomic, strong)	IBOutlet	JoyButton *			okButton;

@end


//------------------------------------------------------------------------------

#pragma mark - Implementation


@implementation CameraSettingsViewController

#pragma mark Static Variables

NSString	static	*kSegueForCameraSettingsFocusInput		= @"SegueForCameraSettingsFocusInput";
NSString	static	*kSegueForCameraSettingsTriggerInput	= @"SegueForCameraSettingsTriggerInput";
NSString	static	*kSegueForCameraSettingsDelayInput		= @"SegueForCameraSettingsDelayInput";
NSString	static	*kSegueForCameraSettingsIntervalInput	= @"SegueForCameraSettingsIntervalInput";


#pragma mark Public Propery Synthesis

#pragma mark Private Propery Synthesis

@synthesize appExecutive;
@synthesize controlBackground;
@synthesize focusValueLabel;
@synthesize triggerValueLabel;
@synthesize delayValueLabel;
@synthesize intervalValueLabel;
@synthesize bufferValueLabel;
@synthesize okButton;


#pragma mark Public Propery Methods

#pragma mark Private Property Methods

- (AppExecutive *) appExecutive {

	if (appExecutive == nil)
		appExecutive = [AppExecutive sharedInstance];

	return appExecutive;
}


//------------------------------------------------------------------------------

#pragma mark - Class Utilities


+ (NSString *) stringForTime: (NSInteger) milliseconds {

	NSInteger	wholeSeconds	= milliseconds / 1000;
	NSInteger	thousandths		= milliseconds % 1000;
	NSInteger	tenths			= thousandths / 100;

	if (thousandths == 0)
		return [NSString stringWithFormat: @"%ld", (long) wholeSeconds];
	else
		return [NSString stringWithFormat: @"%ld.%ld", (long)wholeSeconds, (long)tenths];
}


+ (NSString *) stringForTimeDisplay: (NSInteger) milliseconds {

	NSString *	string	= [CameraSettingsViewController stringForTime: milliseconds];

	return [NSString stringWithFormat: @"%@ s", string];
}


+ (UIColor *) colorWithRed: (int) red green: (int) green blue: (int) blue {

	CGFloat	uiRed	= ((CGFloat) red   / 256.0) ;
	CGFloat	uiGreen	= ((CGFloat) green / 256.0) ;
	CGFloat	uiBlue	= ((CGFloat) blue  / 256.0) ;

	UIColor *color = [UIColor colorWithRed: uiRed green: uiGreen blue: uiBlue alpha: 1.0];

	return color;
}


//------------------------------------------------------------------------------

#pragma mark - Object Management


- (void) viewDidLoad {

	[super viewDidLoad];
}

- (void) viewWillAppear: (BOOL) animated {

	[super viewWillAppear: animated];
	
	[self.view sendSubviewToBack: self.controlBackground];
	
	[self setFieldColors];
	[self updateViewFields];

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
    
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        [self dismissViewControllerAnimated: YES completion: nil];
    });
}

- (void) updateViewFields {

	NSInteger trigger = [self.appExecutive.triggerNumber integerValue];
	self.triggerValueLabel.text	= [CameraSettingsViewController stringForTimeDisplay: trigger];

	NSInteger delay = [self.appExecutive.delayNumber integerValue];
	self.delayValueLabel.text = [CameraSettingsViewController stringForTimeDisplay: delay];

	NSInteger focus = [self.appExecutive.focusNumber floatValue];
	self.focusValueLabel.text = [CameraSettingsViewController stringForTimeDisplay: focus];

	NSInteger interval = [self.appExecutive.intervalNumber integerValue];
	self.intervalValueLabel.text = [CameraSettingsViewController stringForTimeDisplay: interval];

	NSInteger buffer = [self.appExecutive.bufferNumber integerValue];
	self.bufferValueLabel.text = [CameraSettingsViewController stringForTimeDisplay: buffer];
}

- (void) setFieldColors {

	UIColor	*color = [CameraSettingsViewController colorWithRed: 22 green: 22 blue: 22];

	// background color of labels are not settable in interface builder

	self.focusValueLabel.backgroundColor	= color;
	self.triggerValueLabel.backgroundColor	= color;
	self.delayValueLabel.backgroundColor	= color;
	self.bufferValueLabel.backgroundColor	= [UIColor clearColor]; // not editable
	self.intervalValueLabel.backgroundColor	= color;
}

- (void) didReceiveMemoryWarning {

	[super didReceiveMemoryWarning];	
}


//------------------------------------------------------------------------------

#pragma mark - Navigation


- (void) prepareForSegue: (UIStoryboardSegue *) segue sender: (id) sender {

	if ([segue.identifier isEqualToString: kSegueForCameraSettingsFocusInput])
	{
		SetSecondsViewController *ssvc = segue.destinationViewController;

		ssvc.variableToSet = kSetSecondsForFocus;
	}

	else if ([segue.identifier isEqualToString: kSegueForCameraSettingsTriggerInput])
	{
		SetSecondsViewController *ssvc = segue.destinationViewController;

		ssvc.variableToSet = kSetSecondsForTrigger;
	}

	else if ([segue.identifier isEqualToString: kSegueForCameraSettingsDelayInput])
	{
		SetSecondsViewController *ssvc = segue.destinationViewController;

		ssvc.variableToSet = kSetSecondsForDelay;
	}

	else if ([segue.identifier isEqualToString: kSegueForCameraSettingsIntervalInput])
	{
		// setup if needed for view controller
	}
}


//------------------------------------------------------------------------------

#pragma mark - IBAction Methods


- (IBAction) handleFocusButton: (id) sender {

	DDLogDebug(@"Focus Button");

	[self performSegueWithIdentifier: kSegueForCameraSettingsFocusInput sender: self];
}

- (IBAction) handleTriggerButton: (id) sender {

	DDLogDebug(@"Trigger Button");

	[self performSegueWithIdentifier: kSegueForCameraSettingsTriggerInput sender: self];
}

- (IBAction) handleDelayButton: (id) sender {

	DDLogDebug(@"Delay Button");

	[self performSegueWithIdentifier: kSegueForCameraSettingsDelayInput sender: self];
}

- (IBAction) handleIntervalButton: (id) sender {

	DDLogDebug(@"Interval Button");

	[self performSegueWithIdentifier: kSegueForCameraSettingsIntervalInput sender: self];
}

- (IBAction) handleOkButton:(id)sender {
   
	[self dismissViewControllerAnimated: YES completion: nil];
}


@end
