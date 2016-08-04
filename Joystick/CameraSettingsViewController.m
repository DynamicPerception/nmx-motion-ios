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
#import "CameraSettingsTimelineView.h"


//------------------------------------------------------------------------------

#pragma mark - Private Interface

NSString	static	*kSetSecondsForFocus		= @"kSetSecondsForFocus";
NSString	static	*kSetSecondsForTrigger		= @"kSetSecondsForTrigger";
NSString	static	*kSetSecondsForDelay		= @"kSetSecondsForDelay";

@interface CameraSettingsViewController () {

	UIAlertView *	triggerAlert;
	UIAlertView *	delayAlert;
	UIAlertView *	focusAlert;
	UIAlertView *	intervalAlert;
    
    BOOL           _isVisible;
}

@property (nonatomic, strong)				AppExecutive *		appExecutive;
@property (nonatomic, strong)	IBOutlet	UIView *			controlBackground;
@property (nonatomic, strong)	IBOutlet	UILabel *			focusValueLabel;
@property (nonatomic, strong)	IBOutlet	UILabel *			triggerValueLabel;
@property (nonatomic, strong)	IBOutlet	UILabel *			delayValueLabel;
@property (nonatomic, strong)	IBOutlet	UILabel *			intervalValueLabel;
@property (nonatomic, strong)	IBOutlet	UILabel *			bufferValueLabel;
@property (nonatomic, strong)	IBOutlet	JoyButton *			okButton;

@property (nonatomic, assign) NSString *settingValueFor;

@property (strong, nonatomic) IBOutlet UIView *delayColorBarView;
@property (strong, nonatomic) IBOutlet UIView *bufferColorBarView;
@property (strong, nonatomic) IBOutlet UIView *intervalColorBarView;
@property (strong, nonatomic) IBOutlet UIView *focusColorBarView;
@property (strong, nonatomic) IBOutlet UIView *triggerColorBarView;
@property (strong, nonatomic) IBOutlet CameraSettingsTimelineView *cameraSettingsTimelineView;

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
    
    self.delayColorBarView.backgroundColor = [CameraSettingsTimelineView delayColor];
    self.bufferColorBarView.backgroundColor = [CameraSettingsTimelineView bufferColor];
    self.intervalColorBarView.backgroundColor = [CameraSettingsTimelineView intervalColor];
    self.focusColorBarView.backgroundColor = [CameraSettingsTimelineView focusColor];
    self.triggerColorBarView.backgroundColor = [CameraSettingsTimelineView triggerColor];
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

- (void) viewDidAppear:(BOOL)animated
{
    _isVisible = YES;
    [self.cameraSettingsTimelineView startPlayheadAnimation];
}

- (void) viewDidDisappear:(BOOL)animated
{
    _isVisible = NO;
    [self.cameraSettingsTimelineView stopPlayheadAnimation];
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

- (void) viewDidLayoutSubviews
{
    [self.cameraSettingsTimelineView setCameraTimesForFocus:[self.appExecutive.focusNumber integerValue]
                                                    trigger:[self.appExecutive.triggerNumber integerValue]
                                                      delay:[self.appExecutive.delayNumber integerValue]
                                                     buffer:[self.appExecutive.bufferNumber integerValue]
                                                   animated:NO];
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
    
    [self.cameraSettingsTimelineView stopPlayheadAnimation];
    [self.cameraSettingsTimelineView setCameraTimesForFocus:[self.appExecutive.focusNumber integerValue]
                                                    trigger:[self.appExecutive.triggerNumber integerValue]
                                                      delay:[self.appExecutive.delayNumber integerValue]
                                                     buffer:[self.appExecutive.bufferNumber integerValue]
                                                   animated:_isVisible];
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

#pragma mark SecondsViewDelegate


- (NSInteger) getIntegerValueForSecondsView {
    
    if ([self.settingValueFor isEqualToString:kSetSecondsForFocus]) {
        return [self.appExecutive.focusNumber integerValue];
    }
    else if ([self.settingValueFor isEqualToString:kSetSecondsForTrigger]) {
        return [self.appExecutive.triggerNumber integerValue];
    }
    else if ([self.settingValueFor isEqualToString:kSetSecondsForDelay]) {
        return [self.appExecutive.delayNumber integerValue];
    }
    
    return 0;
}

- (void) intervalChangedAlert {
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Interval Setting"
                                                    message: @"Interval has been changed to maintain minimum buffer time."
                                                   delegate: self
                                          cancelButtonTitle: @"OK"
                                          otherButtonTitles: nil];
    [alert show];
}

- (void) setNumberValueForSecondsView : (NSNumber *)number {

    BOOL numberIsValid = YES;
    
    if ([self.settingValueFor isEqualToString:kSetSecondsForFocus]) {
        numberIsValid = [self.appExecutive validFocusNumber: number];
        if (numberIsValid)
        {
            self.appExecutive.focusNumber = number;
        }
    }
    else if ([self.settingValueFor isEqualToString:kSetSecondsForTrigger]) {
        numberIsValid = [self.appExecutive validTriggerNumber: number];
        if (numberIsValid)
        {
            self.appExecutive.triggerNumber = number;
        }
    }
    else if ([self.settingValueFor isEqualToString:kSetSecondsForDelay]) {

        numberIsValid = [self.appExecutive validDelayNumber: number];
        if (numberIsValid)
        {
            self.appExecutive.delayNumber = number;
        }
    }
    
    if (numberIsValid)
    {
        // Recalculate the new exposure based on the updated delay value
        NSInteger focus		= [self.appExecutive.focusNumber integerValue];
        NSInteger trigger	= [self.appExecutive.triggerNumber integerValue];
        NSInteger delay		= [self.appExecutive.delayNumber integerValue];
        NSInteger exposure	= focus + trigger + delay;
        self.appExecutive.exposureNumber = [NSNumber numberWithInteger: exposure];
        
        // Recalculate the new buffer value based on the updated delay value
        NSInteger interval = [self.appExecutive.intervalNumber integerValue];
        NSInteger buffer = interval - exposure;
        if (buffer < 100)
        {
            buffer = 100;
            interval = exposure + buffer;
            self.appExecutive.intervalNumber = [NSNumber numberWithInteger: interval];
            [self intervalChangedAlert];
        }
        self.appExecutive.bufferNumber = [NSNumber numberWithInteger: buffer];
    }
    else
    {
        NSString *valueName = [self getTitleTextForSecondsView];
        NSString *alertMessage = [NSString stringWithFormat:@"The selected %@ is not allowed.", valueName];
        
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:@""
                              message:alertMessage
                              delegate:nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil];
        [alert show];
    }
}

- (NSString *) getTitleTextForSecondsView {
    
    if ([self.settingValueFor isEqualToString:kSetSecondsForFocus]) {
        return @"Focus";
    }
    else if ([self.settingValueFor isEqualToString:kSetSecondsForTrigger]) {
        return @"Trigger";
    }
    else if ([self.settingValueFor isEqualToString:kSetSecondsForDelay]) {
        return @"Delay";
    }

    return nil;
}

- (int) getTensLimitForSecondsView {
    if ([self.settingValueFor isEqualToString:kSetSecondsForFocus]) {
        return 0;
    }
    else if ([self.settingValueFor isEqualToString:kSetSecondsForTrigger]) {
        return 9;
    }
    else if ([self.settingValueFor isEqualToString:kSetSecondsForDelay]) {
        return 6;
    }

    return 0;
}

- (int) getOnesLimitForSecondsView {
    if ([self.settingValueFor isEqualToString:kSetSecondsForFocus]) {
        return 9;
    }
    else if ([self.settingValueFor isEqualToString:kSetSecondsForTrigger]) {
        return 9;
    }
    else if ([self.settingValueFor isEqualToString:kSetSecondsForDelay]) {
        return 9;
    }
    
    return 0;
}


- (int)  getMaximumMillisecondsForSecondsView
{
    if ([self.settingValueFor isEqualToString:kSetSecondsForFocus]) {
        return 10 * 1000;
    }
    else if ([self.settingValueFor isEqualToString:kSetSecondsForTrigger]) {
        return 100 * 1000;
    }
    else if ([self.settingValueFor isEqualToString:kSetSecondsForDelay]) {
        return 60 * 1000;
    }
    
    return 1000000;
}




//------------------------------------------------------------------------------

#pragma mark - Navigation


- (void) prepareForSegue: (UIStoryboardSegue *) segue sender: (id) sender {

	if ([segue.identifier isEqualToString: kSegueForCameraSettingsFocusInput])
	{
		SetSecondsViewController *ssvc = segue.destinationViewController;
        ssvc.delegate = self;
        self.settingValueFor = kSetSecondsForFocus;
	}

	else if ([segue.identifier isEqualToString: kSegueForCameraSettingsTriggerInput])
	{
		SetSecondsViewController *ssvc = segue.destinationViewController;
        ssvc.delegate = self;
		self.settingValueFor = kSetSecondsForTrigger;
	}

	else if ([segue.identifier isEqualToString: kSegueForCameraSettingsDelayInput])
	{
		SetSecondsViewController *ssvc = segue.destinationViewController;
        ssvc.delegate = self;
		self.settingValueFor = kSetSecondsForDelay;
	}

	else if ([segue.identifier isEqualToString: kSegueForCameraSettingsIntervalInput])
	{
		// setup if needed for view controller
	}
}


//------------------------------------------------------------------------------

#pragma mark - IBAction Methods

- (IBAction)handleTestCameraSettings:(id)sender {
    DDLogDebug(@"Test Camera Button");
    // go to modal view
    
    for (NMXDevice *device in [AppExecutive sharedInstance].deviceList)
    {
        [device cameraSetEnable: true];
        [device cameraSetTriggerTime: (UInt32)[self.appExecutive.triggerNumber unsignedIntegerValue]];
        [device cameraSetFocusTime: (UInt16)[self.appExecutive.focusNumber unsignedIntegerValue]];
        [device cameraSetExposureDelay: (UInt16)[self.appExecutive.delayNumber unsignedIntegerValue]];
        [device cameraSetInterval: (UInt32)[self.appExecutive.intervalNumber unsignedIntegerValue]];
    
        [device cameraSetTestMode: true];
    }
}

- (IBAction) handleFocusButton: (id) sender {

    //DDLogDebug(@"Focus Button");

	[self performSegueWithIdentifier: kSegueForCameraSettingsFocusInput sender: self];
}

- (IBAction) handleTriggerButton: (id) sender {

    //DDLogDebug(@"Trigger Button");

	[self performSegueWithIdentifier: kSegueForCameraSettingsTriggerInput sender: self];
}

- (IBAction) handleDelayButton: (id) sender {

    //DDLogDebug(@"Delay Button");

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
