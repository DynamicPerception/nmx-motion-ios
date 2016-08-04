//
//  ProgramSetupViewController.m
//  Joystick
//
//  Created by Mark Zykin on 10/7/14.
//  Copyright (c) 2014 Dynamic Perception. All rights reserved.
//

#import <CocoaLumberjack/CocoaLumberjack.h>

#import "SetupViewController.h"
#import "SetupModeKeys.h"
#import "ReviewStatusViewController.h"
#import "MotorRampingViewController.h"
#import "AppExecutive.h"
#import "JoyButton.h"
#import "NMXDevice.h"
#import "MBProgressHUD.h"
#import "CameraSettingsTimelineView.h"


//------------------------------------------------------------------------------

#pragma mark - Private Interface


@interface SetupViewController () {

	UIAlertView *		intervalAlert;
	UIAlertView *		frameCountAlert;
    BOOL                isVisible;
}

@property (nonatomic, strong)				AppExecutive *				appExecutive;

@property (nonatomic, strong)				UIAlertController *			inputAlert;

// Setup view container

@property (nonatomic, strong)	IBOutlet	UISegmentedControl *		recordModeControl;
@property (nonatomic, strong)	IBOutlet	JoyButton *					joystickButton;
@property (nonatomic, strong)	IBOutlet	JoyButton *					nextButton;

@property (strong, nonatomic)   IBOutlet    CameraSettingsTimelineView *cameraSettingsTimelineView;

// Timelapse view container

@property (nonatomic, strong)	IBOutlet	UIView *					timelapseView;

@property (nonatomic, strong)	IBOutlet	UISegmentedControl *		timelapseModeControl;

@property (nonatomic, strong)	IBOutlet	UILabel *					exposureValue;
@property (nonatomic, strong)	IBOutlet	UILabel *					bufferValue;
@property (nonatomic, strong)	IBOutlet	UILabel *					intervalValue;
@property (nonatomic, strong)	IBOutlet	UILabel *					shotDurationValue;
@property (nonatomic, strong)	IBOutlet	UILabel *					frameCountValue;
@property (nonatomic, strong)	IBOutlet	UILabel *					videoLengthValue;
@property (nonatomic, strong)	IBOutlet	UILabel *					frameRateValue;

@property (nonatomic, strong)	IBOutlet	JoyButton *					advancedCameraSettingsButton;

@property (nonatomic, strong)	IBOutlet	UIButton *					settingsButton;


// Video view container

@property (nonatomic, strong)	IBOutlet	UIView *					videoView;

@property (nonatomic, strong)	IBOutlet	UISegmentedControl *		videoModeControl;

@property (nonatomic, strong)	IBOutlet	UILabel *					videoShotDurationValue;	// same value as videoLengthValue

@property (strong, nonatomic) IBOutlet UIView *exposureColorBarView;
@property (strong, nonatomic) IBOutlet UIView *bufferColorBarView;
@property (strong, nonatomic) IBOutlet UIView *intervalColorBarView;


@end


//------------------------------------------------------------------------------

#pragma mark - Implementation


@implementation SetupViewController

#pragma mark Static Variables

NSString	static	*kSegueForExposureViewController	= @"SegueForExposureViewController";
NSString	static	*kSegueForShotDurationInput			= @"SegueForShotDurationInput";
NSString	static	*kSegueForIntervalInput				= @"SegueForIntervalInput";
NSString	static	*kSegueForFrameCountInput			= @"SegueForFrameCountInput";
NSString	static	*kSegueForVideoLengthInput			= @"SegueForVideoLengthInput";
NSString	static	*kSegueForVideoShotDurationInput	= @"SegueForVideoShotDurationInput";
NSString	static	*kSegueForFrameRateInput			= @"SegueForFrameRateInput";
NSString	static	*kSegueForTestCameraModalView		= @"SegueForTestCameraModalView";
NSString	static	*kSegueForAboutView					= @"SegueForAboutView";
NSString    static  *kSequeForCameraSettingsView        = @"SegueToCameraSettingsViewController";

NSString	static	*kShotDurationName		= @"kShotDurationName";
NSString	static	*kVideoLengthName		= @"kVideoLengthName";
NSString	static	*kVideoShotDurationName	= @"kVideoShotDurationName";


#pragma mark Public Property Synthesis

#pragma mark Private Property Synthesis

@synthesize appExecutive;
@synthesize inputAlert;

// Setup view container

@synthesize joystickButton;
@synthesize nextButton;
@synthesize recordModeControl;

// Timelapse view container

@synthesize timelapseView;
@synthesize timelapseModeControl;

@synthesize exposureValue;
@synthesize bufferValue;	// not editable, no field
@synthesize intervalValue;
@synthesize shotDurationValue;
@synthesize frameCountValue;
@synthesize videoLengthValue;
@synthesize frameRateValue;

@synthesize advancedCameraSettingsButton;

@synthesize settingsButton;

// Video view container

@synthesize videoView;

@synthesize videoModeControl;

@synthesize videoShotDurationValue, restoreDefaultsBtn, buttonView, minimuDurationLbl, minimumDurationHeaderLbl,minimumDurationSubHeaderLbl,batteryIcon;

#pragma mark Public Property Methods

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
    {
		return [NSString stringWithFormat: @"%ld", (long) wholeSeconds];
    }
	else
    {
		return [NSString stringWithFormat: @"%ld.%ld", (long)wholeSeconds, (long)tenths];
    }
}

+ (NSString *) stringForTime2: (NSInteger) milliseconds {

    NSInteger	wholeSeconds	= milliseconds / 1000;
    NSInteger	thousandths		= milliseconds % 1000;
    NSInteger	tenths			= thousandths / 100;
    
    //NSLog(@"stringForTime2: %li",(long)milliseconds);
    
    return [NSString stringWithFormat: @"%ld.%ld", (long)wholeSeconds, (long)tenths];
}

+ (NSString *) stringForTimeDisplay: (NSInteger) milliseconds {

	NSString *	string	= [SetupViewController stringForTime: milliseconds]; //+1000

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

    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    buttonView.hidden = YES;
    
    self.exposureColorBarView.backgroundColor = [CameraSettingsTimelineView exposureColor];
    self.bufferColorBarView.backgroundColor = [CameraSettingsTimelineView bufferColor];
    self.intervalColorBarView.backgroundColor = [CameraSettingsTimelineView intervalColor];
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(handleNotificationLoadPreset:)
     name:@"loadPreset" object:nil];
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(handleNotificationSavePreset:)
     name:@"savePreset" object:nil];
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(handleNotificationRestoreDefaults:)
     name:@"restoreDefaults" object:nil];
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(handleNotificationRemoveSubviews:)
     name:@"removeSubviews" object:nil];
    
    if (self.appExecutive.isVideo == YES) {
        
        NSLog(@"isVideo");
        
        self.recordModeControl.selectedSegmentIndex = 1;
    }
    
    if (self.appExecutive.is3P == YES)
    {
        minimumDurationHeaderLbl.hidden = YES;
        minimumDurationSubHeaderLbl.hidden = YES;
        minimuDurationLbl.hidden = YES;
    }
        
//    NSLog(@"ms1: %i",self.appExecutive.microstep1);
//    NSLog(@"ms2: %i",self.appExecutive.microstep2);
//    NSLog(@"ms3: %i",self.appExecutive.microstep3);
    
    [self.cameraSettingsTimelineView addTarget:self action:@selector(touchedTimeline:) forControlEvents:UIControlEventTouchUpInside];
    
    [super viewDidLoad];
}

- (void) showVoltage {
    
    [NSTimer scheduledTimerWithTimeInterval:.500 target:self selector:@selector(showVoltageTimer) userInfo:nil repeats:NO];
}

- (void) showVoltageTimer {
    
    float voltagePercent = [self.appExecutive calculateVoltage: NO];

    if (voltagePercent > 0)
    {
        float offset = 1 - (batteryIcon.frame.size.height * voltagePercent) - .5;
    
        UIView *v = [[UIView alloc] initWithFrame:CGRectMake(batteryIcon.frame.origin.x + 8,
                                                             batteryIcon.frame.origin.y + (batteryIcon.frame.size.height + offset),
                                                             batteryIcon.frame.size.width * .47,
                                                             batteryIcon.frame.size.height * voltagePercent)];
    
        v.backgroundColor = [UIColor colorWithRed:230.0/255 green:234.0/255 blue:239.0/255 alpha:.8];
    
        [self.view addSubview:v];
    }
}

- (int) convert: (int)val : (int)setting {
    
    //NSLog(@"convert function: val: %i setting: %i",val,setting);
    
    int i;
    
    if (setting == 8 * 200)
    {
        i = val/2;
    }
    else if (setting == 16 * 200)
    {
        i = val/4;
    }
    else
    {
        i = val;
    }

    return i;
}

- (void) viewWillAppear: (BOOL) animated {

	[super viewWillAppear: animated];
    
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(deviceDisconnect:)
                                                 name: kDeviceDisconnectedNotification
                                               object: nil];
    //NSLog(@"viewwillappear setup");

    if (NMXRunStatusRunning & [[AppExecutive sharedInstance].device mainQueryRunStatus] ||
        NMXRunStatusRunning & [[AppExecutive sharedInstance].device queryKeyFrameProgramRunState])
    {
        //NSLog(@"randall load status not stopped setupVC: %i",[[AppExecutive sharedInstance].device queryKeyFrameProgramRunState]);
        
        //NSLog(@"gotoramping");
        
        [self showVoltage];
        
        [self performSegueWithIdentifier: kSegueToMotorRampingViewController sender: self];
    }
    else
    {
        [self showVoltage];
    }

	[self setFieldColors];
    [self updateViewFields];
	[self setSegmentedControllerAttributes];
    [self popMinSeconds];
    
	// gear icon for button

	[self.settingsButton setTitle: @"\u2699" forState: UIControlStateNormal];
}

- (void) deviceDisconnect: (id) object {
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"showNotificationHost" object:self.restorationIdentifier];
    
    NSLog(@"deviceDisconnect setupview");
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.navigationController popToRootViewControllerAnimated: true];
    });
}

- (void) setSegmentedControllerAttributes {

	NSDictionary *	attributes = @{ NSForegroundColorAttributeName: [UIColor whiteColor] };

	[self.recordModeControl setTitleTextAttributes: attributes forState: UIControlStateNormal];
	[self.recordModeControl setTitleTextAttributes: attributes forState: UIControlStateSelected];

	[self.timelapseModeControl setTitleTextAttributes: attributes forState: UIControlStateNormal];
	[self.timelapseModeControl setTitleTextAttributes: attributes forState: UIControlStateSelected];

	[self.videoModeControl setTitleTextAttributes: attributes forState: UIControlStateNormal];
	[self.videoModeControl setTitleTextAttributes: attributes forState: UIControlStateSelected];
}

- (void) popMinSeconds {

    float max = -FLT_MAX;
    
    for (NMXDevice *device in self.appExecutive.deviceList)
    {
        JSDeviceSettings *settings = device.settings;
    
        int microstepSetting1 = settings.microstep1 * 200;
        int microstepSetting2 = settings.microstep2 * 200;
        int microstepSetting3 = settings.microstep3 * 200;
        
        int start1 = settings.startPoint1;
        int end1 = settings.endPoint1;
        int distance1 = start1 - end1;
        
        int start2 = settings.startPoint2;
        int end2 = settings.endPoint2;
        int distance2 = start2 - end2;
        
        int start3 = settings.startPoint3;
        int end3 = settings.endPoint3;
        int distance3 = start3 - end3;
        
        int con1 = abs([self convert:distance1:microstepSetting1]);
        int con2 = abs([self convert:distance2:microstepSetting2]);
        int con3 = abs([self convert:distance3:microstepSetting3]);
        
        max = MAX(max, MAX(MAX(con1, con2), con3));
    }
    
    float minSeconds = max/3300;
    
    minimuDurationLbl.text = [SetupViewController stringForTime2:minSeconds * 1000];
}

- (void) setFieldColors {
    
	UIColor	*color = [SetupViewController colorWithRed: 22 green: 22 blue: 22];

	// background color of labels are not settable in interface builder

	self.exposureValue.backgroundColor			= color;
	self.bufferValue.backgroundColor			= [UIColor clearColor];	// not editable
	self.intervalValue.backgroundColor			= color;
	self.shotDurationValue.backgroundColor		= color;
	self.frameCountValue.backgroundColor		= color;
	self.videoLengthValue.backgroundColor		= color;
	self.frameRateValue.backgroundColor			= color;
	self.videoShotDurationValue.backgroundColor	= color;
}

- (void) updateViewFields {
    
    //NSLog(@"updateViewFields");
    
	NSInteger exposure = [self.appExecutive.exposureNumber integerValue];
	self.exposureValue.text = [NSString stringWithFormat: @"%@ s", [ExposureViewController stringForExposure: exposure]];

	NSInteger buffer = [self.appExecutive.bufferNumber integerValue];
	self.bufferValue.text = [SetupViewController stringForTimeDisplay: buffer];

	NSInteger interval = [self.appExecutive.intervalNumber integerValue];
	self.intervalValue.text	= [SetupViewController stringForTimeDisplay: interval];

	NSInteger shotDuration = [self.appExecutive.shotDurationNumber integerValue];
	self.shotDurationValue.text = [DurationViewController stringForDuration: shotDuration];

	NSInteger frameCount = [self.appExecutive.frameCountNumber integerValue];
	self.frameCountValue.text = [NSString stringWithFormat: @"%ld", (long)frameCount];

	NSInteger videoLength = [self.appExecutive.videoLengthNumber integerValue];
	self.videoLengthValue.text	= [ShortDurationViewController stringForShortDuration: videoLength];
	self.videoShotDurationValue.text= [ShortDurationViewController stringForShortDuration: videoLength]; // same info in videoView

	NSInteger frameRate = [self.appExecutive.frameRateNumber integerValue];
	self.frameRateValue.text = [NSString stringWithFormat: @"%ld", (long)frameRate];
    
    [self.cameraSettingsTimelineView stopPlayheadAnimation];
    [self.cameraSettingsTimelineView setCameraTimesForFocus:[self.appExecutive.focusNumber integerValue]
                                                    trigger:[self.appExecutive.triggerNumber integerValue]
                                                      delay:[self.appExecutive.delayNumber integerValue]
                                                     buffer:[self.appExecutive.bufferNumber integerValue]
                                                   animated:isVisible];
}

- (void) viewDidLayoutSubviews
{
    [self.cameraSettingsTimelineView setCameraTimesForFocus:[self.appExecutive.focusNumber integerValue]
                                                    trigger:[self.appExecutive.triggerNumber integerValue]
                                                      delay:[self.appExecutive.delayNumber integerValue]
                                                     buffer:[self.appExecutive.bufferNumber integerValue]
                                                   animated:NO];
}

- (void) viewDidDisappear:(BOOL)animated
{
    isVisible = NO;
    [self.cameraSettingsTimelineView stopPlayheadAnimation];
}

- (void) viewDidAppear: (BOOL) animated {
    
	[super viewDidAppear: animated];
    isVisible = YES;

	[self handleRecordModeControl: self.recordModeControl];

    [self.cameraSettingsTimelineView startPlayheadAnimation];
    
	if (getenv("GOTO_ABOUT"))
	{
		[self performSegueWithIdentifier: kSegueForAboutView sender: self];
	}
	else if (getenv("GOTO_RAMPING"))
	{
		[self performSegueWithIdentifier: kSegueToMotorRampingViewController sender: self];
	}
    
    
}

//------------------------------------------------------------------------------

#pragma mark - Navigation

- (void) prepareForSegue: (UIStoryboardSegue *) segue sender: (id) sender {

	//DDLogDebug(@"Prepare for segue: %@", segue.identifier);

	if ([segue.identifier isEqualToString: kSegueToReviewStatusViewController])
	{
        // No setup needed
        
        [[NSNotificationCenter defaultCenter] removeObserver: self];
	}
	else if ([segue.identifier isEqualToString: kSegueToMotorRampingViewController])
	{
		// No setup needed?
        
        [[NSNotificationCenter defaultCenter] removeObserver: self];
	}
	else if ([segue.identifier isEqualToString: kSegueForExposureViewController])
	{
		ExposureViewController *pvc = segue.destinationViewController;

		pvc.delegate = self;
		pvc.exposure = self.appExecutive.exposureNumber;
	}
	else if ([segue.identifier isEqualToString: kSegueForShotDurationInput])
	{
		DurationViewController *dvc = segue.destinationViewController;

		NSString *		title	= @"Shot Duration";
		NSArray *		keys	= @[kDurationInfoKeyTitle, kDurationInfoKeyName, kDurationInfoKeyNumber];
		NSArray *		objects	= @[title, kShotDurationName, self.appExecutive.shotDurationNumber];
		NSDictionary *	info	= [NSDictionary dictionaryWithObjects: objects forKeys: keys];

		dvc.delegate = self;
		dvc.userInfo = info;
	}
	else if ([segue.identifier isEqualToString: kSegueForIntervalInput])
	{
		// any setup for interval selector
	}
	else if ([segue.identifier isEqualToString: kSegueForFrameCountInput])
	{
		// any setup for frame count scroll selector
	}
	else if ([segue.identifier isEqualToString: kSegueForVideoLengthInput])
	{
		ShortDurationViewController *sdvc = segue.destinationViewController;

		NSString *		title	= @"Video Length";
		NSArray *		keys	= @[kShortDurationInfoKeyTitle, kShortDurationInfoKeyName, kShortDurationInfoKeyNumber];
		NSArray *		objects	= @[title, kVideoLengthName, self.appExecutive.videoLengthNumber];
		NSDictionary *	info	= [NSDictionary dictionaryWithObjects: objects forKeys: keys];

		sdvc.delegate = self;
		sdvc.userInfo = info;
	}
	else if ([segue.identifier isEqualToString: kSegueForVideoShotDurationInput])
	{
		ShortDurationViewController *dvc = segue.destinationViewController;

		NSString *		title	= @"Shot Duration";
		NSArray *		keys	= @[kShortDurationInfoKeyTitle, kShortDurationInfoKeyName, kShortDurationInfoKeyNumber];
		NSArray *		objects	= @[title, kVideoShotDurationName, self.appExecutive.videoLengthNumber];
		NSDictionary *	info	= [NSDictionary dictionaryWithObjects: objects forKeys: keys];

		dvc.delegate = self;
		dvc.userInfo = info;
	}
	else if ([segue.identifier isEqualToString: kSegueForFrameRateInput])
	{
		FrameRateViewController *frvc = segue.destinationViewController;

		frvc.delegate = self;
		frvc.frameRate = self.appExecutive.frameRateNumber;
	}
    else if ([segue.identifier isEqualToString: @"HelpSetup"])
    {
        NSLog(@"HelpSetup");
        
        HelpViewController *msvc = segue.destinationViewController;
        
        [msvc setScreenInd:3];
    }
}

- (IBAction) unwindFromMotorRampingViewController: (UIStoryboardSegue *) segue {

	return;
}

//------------------------------------------------------------------------------

#pragma mark - IBAction Methods

- (void) touchedTimeline: (id)control
{
    [self performSegueWithIdentifier: kSequeForCameraSettingsView sender: self];
}



- (IBAction) handleRecordModeControl: (UISegmentedControl *) sender {

	NSInteger	index = sender.selectedSegmentIndex;
	NSString *	title = [sender titleForSegmentAtIndex: index];
    
    if (index == 1) {
        self.appExecutive.isVideo = YES;
    }
    else
    {
    self.appExecutive.isVideo = NO;
    }

	if ([title isEqualToString: kRecordModeTimelapse])
	{
		self.timelapseView.hidden = NO;
		self.videoView.hidden = YES;
	}
	else if ([title isEqualToString: kRecordModeVideo])
	{
		self.timelapseView.hidden = YES;
		self.videoView.hidden = NO;
    }

	DDLogDebug(@"Record Mode Control: %@", title);
}

- (IBAction) handleTimelapseModeControl: (UISegmentedControl *) sender {

	NSInteger	index = sender.selectedSegmentIndex;
	NSString *	title = [sender titleForSegmentAtIndex: index];
    
    

	if ([title isEqualToString: kTimelapseModeSMS])
	{
		// anything else to be done?
        self.appExecutive.isContinuous = NO;
	}
	else if ([title isEqualToString: kTimelapseModeContinuous])
	{
		// anything else to be done?
        self.appExecutive.isContinuous = YES;
	}

	DDLogDebug(@"Timelapse Mode Control: %@", title);
}

- (IBAction) handleVideoModeControl: (UISegmentedControl *) sender {
    
    NSLog(@"handleVideoModeControl");

	NSInteger	index = sender.selectedSegmentIndex;
	NSString *	title = [sender titleForSegmentAtIndex: index];
    
    

	if ([title isEqualToString: kVideoModeOneShot])
	{
		// anything else to be done?
	}
	else if ([title isEqualToString: kVideoModePingPong])
	{
		// anything else to be done?
	}
	
	DDLogDebug(@"Video Mode Control: %@", title);
}

- (IBAction) handleExposureButton: (UIButton *) sender {

	DDLogDebug(@"Exposure Button");

	[self performSegueWithIdentifier: kSegueForExposureViewController sender: self];
}

- (IBAction) handleBufferButton: (UIButton *) sender {

	DDLogDebug(@"Buffer Button");
}

- (IBAction) handleIntervalButton: (UIButton *) sender {

	DDLogDebug(@"Interval Button");

	[self performSegueWithIdentifier: kSegueForIntervalInput sender: self];
}

- (IBAction) handleAdvancedCameraSettingsButton: (UIButton *) sender {

	DDLogDebug(@"Advanced Camera Settings Button");
}

- (IBAction) handleVideoShotDurationButton: (UIButton *) sender {

	DDLogDebug(@"Video Duration Button");

	[self performSegueWithIdentifier: kSegueForVideoShotDurationInput sender: self];
}

- (IBAction) handleShotDurationButton: (UIButton *) sender {

	DDLogDebug(@"Shot Duration Button");

	[self performSegueWithIdentifier: kSegueForShotDurationInput sender: self];
}

- (IBAction) handleFrameCountButton: (UIButton *) sender {

	DDLogDebug(@"Frame Count Button");

	[self performSegueWithIdentifier: kSegueForFrameCountInput sender: self];
}

- (IBAction) handleVideoLengthButton: (UIButton *) sender {

	DDLogDebug(@"Video Length Button");

	[self performSegueWithIdentifier: kSegueForVideoLengthInput sender: self];
}

- (IBAction) handleFrameRateButton: (UIButton *) sender {

	DDLogDebug(@"Frame Rate Button");

	[self performSegueWithIdentifier: kSegueForFrameRateInput sender: self];
}

- (IBAction) handleJoystickButton: (UIButton *) sender {

	DDLogDebug(@"Joystick Button");
}

- (void) checkProgramAndHandleNext {

    for (NMXDevice *device in self.appExecutive.deviceList)
    {
        JSDeviceSettings *settings = device.settings;
        [settings synchronize];
    }
    
    if (appExecutive.is3P == NO) {

        if (NO == [appExecutive queryMotorFeasibility])
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Too Fast For Motors"
                                                            message: @"Increase shot duration"
                                                           delegate: self
                                                  cancelButtonTitle: @"OK"
                                                  otherButtonTitles: nil];
            [alert show];
        }
        else
        {
            // If we transition too fast, the hardware gets unhappy...
            usleep(100);
            [self performSegueWithIdentifier: kSegueToMotorRampingViewController sender: self];
        }
    }
    else
    {
        // If we transition too fast, the hardware gets unhappy...
        usleep(100);
        [self performSegueWithIdentifier: kSegueToMotorRampingViewController sender: self];
    }
}

- (IBAction) handleNextButton: (UIButton *) sender {

    //DDLogDebug(@"Next Button");

    __block UInt32 durationInMS;
    __block UInt32 accelInMS;
    __block NMXFPS fps;
    __block NMXProgramMode programMode;
    __block BOOL pingPong = NO;

    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    if (self.recordModeControl.selectedSegmentIndex == 1)
    {
        programMode = NMXProgramModeVideo;
        durationInMS = (int)[self.appExecutive.videoLengthNumber integerValue];
        pingPong = (self.videoModeControl.selectedSegmentIndex == 1);
        if (durationInMS > 50000)
            accelInMS = 5000;
        else
            accelInMS = durationInMS / 10;
    }
    else
    {
        if (self.timelapseModeControl.selectedSegmentIndex == 1)
        {
            programMode = NMXProgramModeTimelapse;
            durationInMS = (int)[self.appExecutive.shotDurationNumber integerValue];
        }
        else
        {
            programMode = NMXProgramModeSMS;
            durationInMS = [self.appExecutive.frameCountNumber intValue];
        }
        accelInMS = durationInMS / 10;
        
        switch ([self.appExecutive.frameRateNumber integerValue])
        {
            case 24:
                fps = NMXFPS24;
                break;
            case 25:
                fps = NMXFPS25;
                break;
            case 30:
            default:
                fps = NMXFPS30;
                break;
        }
    }
    
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{

        [self.appExecutive setProgamSettings: programMode
                                pingPongMode: pingPong
                                    duration: durationInMS
                                       accel: accelInMS
                                         fps: fps];

        dispatch_async(dispatch_get_main_queue(), ^{
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                [self checkProgramAndHandleNext];
        });
    });
}

//------------------------------------------------------------------------------

#pragma mark - UIAlertViewDelegate Methods

- (void) alertView: (UIAlertView *) alertView clickedButtonAtIndex: (NSInteger) buttonIndex {

	NSString *	title	= [alertView buttonTitleAtIndex: buttonIndex];

	if ([title isEqualToString: @"OK"])
	{
		; // TODO: no longer used?
	}
}

//------------------------------------------------------------------------------

#pragma mark - DurationDelegate Protocol Methods

- (void) updateDurationInfo: (NSDictionary *) info {

	NSString *durationName = [info objectForKey: kDurationInfoKeyName];

	if ([durationName isEqualToString: kShotDurationName])
	{
		self.appExecutive.shotDurationNumber	= [info objectForKey: kDurationInfoKeyNumber];
		self.shotDurationValue.text				= [info objectForKey: kDurationInfoKeyString];
        
		[self updateViewFields];
	}
}

//------------------------------------------------------------------------------

#pragma mark - ShortDurationDelegate Protocol Methods

- (void) updateShortDurationInfo: (NSDictionary *) info {
    
	NSString *durationName = [info objectForKey: kShortDurationInfoKeyName];

	if ([durationName isEqualToString: kVideoLengthName])
	{
		self.appExecutive.videoLengthNumber = [info objectForKey: kShortDurationInfoKeyNumber];
		self.videoLengthValue.text			= [info objectForKey: kShortDurationInfoKeyString];
		self.videoShotDurationValue.text	= [info objectForKey: kShortDurationInfoKeyString];
        
		[self updateViewFields];
	}

	else if ([durationName isEqualToString: kVideoShotDurationName])
	{
		self.appExecutive.videoLengthNumber = [info objectForKey: kShortDurationInfoKeyNumber];
		self.videoLengthValue.text			= [info objectForKey: kShortDurationInfoKeyString];
		self.videoShotDurationValue.text	= [info objectForKey: kShortDurationInfoKeyString];
        
		[self updateViewFields];
	}
}

//------------------------------------------------------------------------------

#pragma mark - ExposureDelegate Protocol Methods

- (void) updateExposureNumber: (NSNumber *) number {
    
	if (FALSE == [number isEqualToNumber: self.appExecutive.exposureNumber])
	{
        if ([self.appExecutive validExposureNumber: number])
        {
            self.appExecutive.exposureNumber = number;
            
            NSInteger focus		= [self.appExecutive.focusNumber integerValue];
            NSInteger trigger	= [self.appExecutive.triggerNumber integerValue];
            NSInteger interval		= [self.appExecutive.intervalNumber integerValue];
            NSInteger exposure	    = [self.appExecutive.exposureNumber integerValue];

            NSInteger buffer;
            if (exposure > (interval - focus))
            {
                buffer = focus;
                interval = exposure + focus;
                
                self.appExecutive.intervalNumber = [NSNumber numberWithInteger: interval];
                
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Interval Setting"
                                                                message: @"Interval has been changed to maintain minimum buffer time."
                                                               delegate: self
                                                      cancelButtonTitle: @"OK"
                                                      otherButtonTitles: nil];
                [alert show];

            }
            else
            {
                buffer = interval - exposure;
            }

            self.appExecutive.bufferNumber = [NSNumber numberWithInteger: buffer];
            
            NSInteger delay = exposure - (focus + trigger);
            
            if (delay < 100)
            {
                delay = 100;
                focus = exposure - (delay + trigger);
                
                if (focus < 100)
                {
                    focus = 100;

                    trigger = exposure - (delay + focus);
                    trigger = MAX(100, trigger);
                    self.appExecutive.triggerNumber = [NSNumber numberWithInteger: trigger];
                }
                
                self.appExecutive.focusNumber = [NSNumber numberWithInteger: focus];
            }
            
            self.appExecutive.delayNumber = [NSNumber numberWithInteger: delay];
            
            self.exposureValue.text = [NSString stringWithFormat: @"%@ s", [ExposureViewController stringForExposure: exposure]];
        }
        else
        {
            UIAlertView *alert = [[UIAlertView alloc]
                                  initWithTitle:@""
                                  message:@"The selected exposure value is not allowed"
                                  delegate:nil
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil];
            [alert show];
        }
	}
}

//------------------------------------------------------------------------------

#pragma mark - FrameRateDelegate Protocol Methods

- (void) updateFrameRateNumber: (NSNumber *) number {

	self.appExecutive.frameRateNumber = number;
    
	[self updateViewFields];
}

//------------------------------------------------------------------------------

#pragma mark - UITextFieldDelegate Protocol Methods

- (void) textFieldDidEndEditing: (UITextField *) textField {

	return;
}

- (BOOL) textFieldShouldReturn: (UITextField *) textField {

	[textField resignFirstResponder];

	return YES;
}

- (BOOL) textField: (UITextField *) textField shouldChangeCharactersInRange: (NSRange) range replacementString: (NSString *) string {

	return YES;
}

#pragma mark - Notifications

- (void) handleNotificationRemoveSubviews:(NSNotification *)pNotification {

    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void) handleNotificationRestoreDefaults:(NSNotification *)pNotification {
    
    NSLog(@"Restore Defaults");
    
    recordModeControl.selectedSegmentIndex = 0;
    timelapseModeControl.selectedSegmentIndex = 0;
    
    [self.appExecutive restoreDefaults];
    
    [self updateViewFields];
}

- (void) handleNotificationLoadPreset:(NSNotification *)pNotification {
    
    PresetOb *preset = pNotification.object;
    
    NSLog(@"handleNotificationLoadPreset: %@",preset.name);
    
    appExecutive.exposureNumber = preset.exposure;
    appExecutive.bufferNumber = preset.buffer;
    appExecutive.intervalNumber = preset.interval;
    appExecutive.shotDurationNumber = preset.shotduration;
    appExecutive.frameCountNumber = preset.frames;
    appExecutive.videoLengthNumber = preset.videolength;
    appExecutive.frameRateNumber = preset.fps;
    appExecutive.focusNumber = preset.focus;
    appExecutive.triggerNumber = preset.trigger;
    appExecutive.delayNumber = preset.delay;
    
    [self updateViewFields];
    
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void) handleNotificationSavePreset:(NSNotification *)pNotification {
    
    NSLog(@"handleNotificationSavePreset");

    entity = [NSEntityDescription entityForName:@"PresetOb" inManagedObjectContext:appDelegate.managedObjectContext];
    
    PresetOb *preset1 = [[PresetOb alloc] initWithEntity:entity insertIntoManagedObjectContext:appDelegate.managedObjectContext];
    
    preset1.name = pNotification.object;
    preset1.exposure = appExecutive.exposureNumber;
    preset1.buffer = appExecutive.bufferNumber;
    preset1.interval = appExecutive.intervalNumber;
    preset1.shotduration = appExecutive.shotDurationNumber;
    preset1.frames = appExecutive.frameCountNumber;
    preset1.videolength = appExecutive.videoLengthNumber;
    preset1.fps = appExecutive.frameRateNumber;
    preset1.focus = appExecutive.focusNumber;
    preset1.trigger = appExecutive.triggerNumber;
    preset1.delay = appExecutive.delayNumber;
    preset1.smscontinuous = [NSNumber numberWithInt:(int)recordModeControl.selectedSegmentIndex];
    preset1.timelapsevideo = [NSNumber numberWithInt:(int)timelapseModeControl.selectedSegmentIndex];
    
    NSError *error = nil;
    
    if (![appDelegate.managedObjectContext save:&error])
    {
        NSLog(@"save error");
    }
    
    [self dismissViewControllerAnimated:YES completion:NULL];
    
    UIAlertView *insertAlert = [[UIAlertView alloc]
                                initWithTitle:@""
                                message:@"Preset Saved"
                                delegate:self
                                cancelButtonTitle:@"OK"
                                otherButtonTitles:nil];
    [insertAlert show];

}

- (void) viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear: animated];
}

- (void) didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
}

@end
