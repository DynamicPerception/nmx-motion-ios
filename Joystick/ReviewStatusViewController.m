	//
//  ReviewSettingsViewController.m
//  Joystick
//
//  Created by Mark Zykin on 11/24/14.
//  Copyright (c) 2014 Dynamic Perception. All rights reserved.
//

#import <CocoaLumberjack/CocoaLumberjack.h>

#import "ReviewStatusViewController.h"
#import "SetupModeKeys.h"

#import "AppExecutive.h"
#import "DurationViewController.h"
#import "ShortDurationViewController.h"
#import "NMXDevice.h"
#import "HSpline.h"

//------------------------------------------------------------------------------

#pragma mark - Private Interface


typedef enum {

	ControllerStateMotorRampingOrSendMotors,
	ControllerStateMotorRampingOrStartProgram,
	ControllerStatePauseProgram,
	ControllerStateConfirmPauseProgram,
	ControllerStateResumeOrStopProgram
}
ControllerState;

typedef enum{
    AtProgramEndStop,
    AtProgramEndKeepAlive,
    AtProgramEndPingPong
} AtProgramEndMode;


@interface ReviewStatusViewController ()

@property (nonatomic, strong)	IBOutlet	UIView *			controlBackground;

@property (nonatomic, strong)	IBOutlet	UIView *			timelapseView;
@property (nonatomic, strong)	IBOutlet	UILabel *			timelapseTitle;
@property (nonatomic, strong)	IBOutlet	UIProgressView *	timelapseProgressView;
@property (nonatomic, strong)	IBOutlet	UILabel *			timelapseTimeRemainingValueLabel;
@property (nonatomic, strong)	IBOutlet	UILabel *			framesShotValueLabel;
@property (nonatomic, strong)	IBOutlet	UILabel *			videoLengthValueLabel;

@property (nonatomic, strong)	IBOutlet	UIView *			videoView;
@property (nonatomic, strong)	IBOutlet	UILabel *			videoTitle;
@property (nonatomic, strong)	IBOutlet	UIProgressView *	videoProgressView;
@property (nonatomic, strong)	IBOutlet	UILabel *			videoTimeRemainingValueLabel;

@property (nonatomic, strong)	IBOutlet	JoyButton *			motorRampingButton;
@property (nonatomic, strong)	IBOutlet	JoyButton *			sendMotorsToStartButton;
@property (nonatomic, strong)	IBOutlet	JoyButton *			startProgramButton;
@property (nonatomic, strong)	IBOutlet	JoyButton *			pauseProgramButton;
@property (nonatomic, strong)	IBOutlet	JoyButton *			confirmPauseProgramButton;
@property (nonatomic, strong)	IBOutlet	JoyButton *			resumeProgramButton;
@property (nonatomic, strong)	IBOutlet	JoyButton *			stopProgramButton;
@property (weak, nonatomic) IBOutlet        JoyButton *         reconnectButton;
@property (weak, nonatomic) IBOutlet        UILabel *           disconnectedLabel;
@property (strong, nonatomic)   IBOutlet    UIPickerView *      deviceSelectionPicker;

@property (nonatomic, strong)				NSArray *			stateButtons;

@property (nonatomic, readwrite)			ControllerState		currentState;

@property (nonatomic, strong)				NSTimer *			confirmPauseTimer;
@property (nonatomic, strong)				NSTimer *			sendMotorsTimer;
@property (nonatomic, strong)               NSTimer *           statusTimer;
@property (nonatomic, strong)               NSTimer *           disconnectedTimer;

@property (nonatomic, assign)               UInt8               fps;
@property (nonatomic, assign)               UInt32              totalRunTime;
@property (nonatomic, assign)               UInt32              lastRunTime;
@property (nonatomic, assign)               time_t              timeOfLastRunTime;
@property (nonatomic, assign)               float               timePerFrame;
@property (nonatomic, assign)               NMXProgramMode      programMode;

@property                                   float               previousPercentage;
@property                                   BOOL                reversing;

@property                                   NMXDevice          *displayedDevice;

@property JSDisconnectedDeviceVC *disconnectedDeviceVC;

@end

NSString static	*SegueToDisconnectedDeviceViewController	= @"DeviceDisconnectedSequeFromReviewStatus";

//------------------------------------------------------------------------------

#pragma mark - Implementation


@implementation ReviewStatusViewController

#pragma mark Private Propery Synthesis

@synthesize controlBackground;

@synthesize timelapseProgressView;
@synthesize timelapseTimeRemainingValueLabel;
@synthesize framesShotValueLabel;
@synthesize videoLengthValueLabel;

@synthesize videoProgressView;
@synthesize videoTimeRemainingValueLabel;

@synthesize motorRampingButton;
@synthesize sendMotorsToStartButton;
@synthesize startProgramButton;
@synthesize pauseProgramButton;
@synthesize confirmPauseProgramButton;
@synthesize resumeProgramButton;
@synthesize stopProgramButton;

@synthesize stateButtons;
@synthesize currentState;

@synthesize confirmPauseTimer;
@synthesize sendMotorsTimer;
@synthesize statusTimer;

@synthesize graphView, panGraph, tiltGraph, appExecutive, graphViewContainer, playhead, goBtn, cancelBtn, keepAliveView, startTimerBtn,
            timerContainer, timerLbl, disconnectStatusLbl, disconnectBtn,graph3P,dic,shareBtn,settingsButton,batteryIcon,contentBG,shareBtn2,debugTxt;

#pragma mark Public Propery Methods

#pragma mark Private Propery Methods


- (NSArray *) stateButtons {

	if (stateButtons == nil)
	{
		stateButtons = [NSArray arrayWithObjects:
							self.motorRampingButton,
							self.sendMotorsToStartButton,
							self.startProgramButton,
							self.pauseProgramButton,
							self.confirmPauseProgramButton,
							self.resumeProgramButton,
							self.stopProgramButton,
							nil];
	}

	return stateButtons;
}

- (NSTimer *) confirmPauseTimer {

	if (confirmPauseTimer == nil)
	{
		confirmPauseTimer = [NSTimer scheduledTimerWithTimeInterval: 5.0
															 target: self
														   selector: @selector(handleConfirmPauseTimer:)
														   userInfo: nil
															repeats: NO];
	}

	return confirmPauseTimer;
}

- (void) setConfirmPauseTimer: (NSTimer *) object {

	if (object != self.confirmPauseTimer)
		[self.confirmPauseTimer invalidate];

	confirmPauseTimer = object;
}

- (NSTimer *) sendMotorsTimer {

	if (sendMotorsTimer == nil)
	{
		sendMotorsTimer = [NSTimer scheduledTimerWithTimeInterval: 0.5
														   target: self
														 selector: @selector(handleSendMotorsTimer:)
														 userInfo: nil
														  repeats: YES];
	}

	return sendMotorsTimer;
}

- (void) setSendMotorsTimer: (NSTimer *) object {

	if (object != self.sendMotorsTimer)
		[self.sendMotorsTimer invalidate];

	sendMotorsTimer = object;
}

- (NSTimer *) statusTimer {

    if (statusTimer == nil)
    {
        statusTimer = [NSTimer scheduledTimerWithTimeInterval: 2.0
                                                           target: self
                                                         selector: @selector(handleStatusTimer:)
                                                         userInfo: nil
                                                          repeats: YES];
    }
    
    return statusTimer;
}

- (void) setStatusTimer:(NSTimer *) object {

    if (object != self.statusTimer)
    {
        [self.statusTimer invalidate];
    }
    
    statusTimer = object;
}

//------------------------------------------------------------------------------

#pragma mark - Class Utilities


+ (UIColor *) colorWithRed: (int) red green: (int) green blue: (int) blue {

	CGFloat	uiRed	= ((CGFloat) red   / 256.0) ;
	CGFloat	uiGreen	= ((CGFloat) green / 256.0) ;
	CGFloat	uiBlue	= ((CGFloat) blue  / 256.0) ;

	UIColor *color = [UIColor colorWithRed: uiRed green: uiGreen blue: uiBlue alpha: 1.0];

	return color;
}


//------------------------------------------------------------------------------

- (AppExecutive *) appExecutive {

    if (appExecutive == nil)
        appExecutive = [AppExecutive sharedInstance];
    
    return appExecutive;
}

#pragma mark - Object Management


- (void) viewDidLoad {
        
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];

    self.deviceSelectionPicker.delegate = self;
    self.deviceSelectionPicker.dataSource = self;
    self.deviceSelectionPicker.transform = CGAffineTransformMakeScale(0.8, 0.8);
    [self setDevicePickerVisible: YES];
    
    self.displayedDevice = self.appExecutive.device;
    
    screenWidth = self.view.frame.size.width;
    
    lastFrameValue = framesShotValueLabel.text;
    
    //NSLog(@"graphViewContainer width: %f",graphViewContainer.frame.size.width);
    
    origPlayheadPosition = CGRectMake(playhead.frame.origin.x,
                                      playhead.frame.origin.y,
                                      playhead.frame.size.width,
                                      playhead.frame.size.height);
    
    [cancelBtn addTarget:self action:@selector(cancelTimer:) forControlEvents:UIControlEventTouchUpInside];
    
    [goBtn addTarget:self action:@selector(bypassTimer:) forControlEvents:UIControlEventTouchUpInside];
    
    timerContainer.hidden = YES;
    startTimerBtn.hidden = YES;
    keepAliveView.hidden = YES;
    self.previousPercentage = 0.f;
    
    if (!debugDisconnect)
    {
        disconnectBtn.hidden = YES;
        disconnectStatusLbl.hidden = YES;
    }

    [self setupIcons];

    if (self.appExecutive.device.fwVersion < 52)
    {
        [self.atProgramEndControl removeSegmentAtIndex:AtProgramEndPingPong animated:NO];
    }
    else if ([self.appExecutive.device mainQueryPingPongMode])
    {
        [self.atProgramEndControl setSelectedSegmentIndex:AtProgramEndPingPong];
    }
    
	[super viewDidLoad];
}

- (void) setDevicePickerVisible: (BOOL)visible
{
    if (self.appExecutive.deviceList.count <= 1 || self.appExecutive.is3P)
    {
        self.deviceSelectionPicker.hidden = YES;
    }
    else
    {
        self.deviceSelectionPicker.hidden = !visible;
    }
}

- (void) setupIcons {
    
    [shareBtn setImageEdgeInsets:UIEdgeInsetsMake(0.0, -10.0, 0.0, 0.0)];
    [shareBtn setTitleEdgeInsets:UIEdgeInsetsMake(0.0, 60.0, 0.0, 0.0)];
    [shareBtn setTitle:@"Share your behind the scenes" forState:UIControlStateNormal];
    
    UIImage *ig = [UIImage imageNamed: @"Instagram.png"];
    
    UIImageView *igv = [[UIImageView alloc] initWithFrame:CGRectMake(3, 3, 25, 25)];
    
    igv.image = ig;
    
    [shareBtn addSubview:igv];
    
    UIImage *ig2 = [UIImage imageNamed: @"facebook.png"];
    
    UIImageView *igv2 = [[UIImageView alloc] initWithFrame:CGRectMake(31, 3, 25, 25)];
    
    igv2.image = ig2;
    
    [shareBtn addSubview:igv2];
    
    
    UIImageView *igv3 = [[UIImageView alloc] initWithFrame:CGRectMake(1, 1, 23, 23)];
    
    igv3.image = ig;
    
    UIImageView *igv4 = [[UIImageView alloc] initWithFrame:CGRectMake(26, 1, 23, 23)];
    
    igv4.image = ig2;
    
    [shareBtn2 setTitle:@"" forState:UIControlStateNormal];
    [shareBtn2 addSubview:igv3];
    [shareBtn2 addSubview:igv4];
}

- (void) handleAddKeyframeDebug:(NSNotification *)pNotification {
    
    NSNumber *n = pNotification.object;
    
    if (debugInd == 0) {
        
        debugTxt.text = [NSString stringWithFormat:@"%@\n start tilt out: %f",debugTxt.text,[n floatValue]];
    }
    else if (debugInd == 1) {
        
        debugTxt.text = [NSString stringWithFormat:@"%@\n mid tilt out: %f",debugTxt.text,[n floatValue]];
    }
    else {
        
        debugTxt.text = [NSString stringWithFormat:@"%@\n end tilt out: %f",debugTxt.text,[n floatValue]];
    }
    
    debugInd++;
}

#pragma mark - Delay

- (void) setControlVisibilityForDelayState: (BOOL) delayState
{
    if (delayState)
    {
        [self showKeepAliveView];
        cancelBtn.hidden = NO;
        goBtn.hidden = NO;
        startTimerBtn.hidden = YES;
        timerContainer.hidden = NO;
        pauseProgramButton.hidden = YES;
        [self setDevicePickerVisible: NO];
    }
}

- (void) handleShotDurationNotification:(NSNotification *)pNotification {
    
    NSNumber *n = pNotification.object;
        
    countdownTime = [n intValue];
    originalCountdownTime = countdownTime;
    [appExecutive setOriginalProgramDelay:countdownTime];

    [appExecutive setProgramDelayTime:countdownTime];
    timerStartTime = [appExecutive getDelayTimerStartTime];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"HH:mm:ss"];
    NSLog(@"handleShotDurationNotification countdownTime: %g  startTime %@",countdownTime, [dateFormatter stringFromDate:timerStartTime]);
    
    int	wholeseconds	= countdownTime / 1000;
    int	hours			= wholeseconds / 3600;
    int	minutes			= (wholeseconds % 3600) / 60;
    int	seconds			= wholeseconds % 60;
    
    timerLbl.text = [NSString stringWithFormat:@"%02ld:%02ld:%02ld", (long)hours, (long)minutes, (long)seconds];
    
    [self setControlVisibilityForDelayState:YES];
    
    for (NMXDevice *device in self.appExecutive.deviceList)
    {
        [device setDelayProgramStartTimer:countdownTime];
    }
    
    [self manageCountdownTimer];
    
    [self doStartMove];
}

- (void) reconnectDelay
{
    timerContainer.hidden = NO;
    [self setDevicePickerVisible: NO];
    
    if (self.appExecutive.is3P == NO)
    {
        self.totalRunTime = [self.appExecutive.device mainQueryTotalRunTime];
        self.lastRunTime = [self.appExecutive.device mainQueryRunTime];
    }
    else
    {
        self.lastRunTime = [self.appExecutive.device queryKeyFrameProgramCurrentTime];
        self.totalRunTime = [self.appExecutive.device queryKeyFrameProgramMaxTime];
    }
    
    self.timeOfLastRunTime = time(nil);
    
    countdownTime = [appExecutive getProgramDelayTime];
    timerStartTime = [appExecutive getDelayTimerStartTime];
    originalCountdownTime = [appExecutive getOriginalProgramDelay];
    
    [self manageCountdownTimer];
    
    [self setControlVisibilityForDelayState: YES];
    
    sendMotorsToStartButton.hidden = YES;
    motorRampingButton.hidden = YES;
    
    if (self.appExecutive.is3P == NO)
    {
        self.statusTimer = self.statusTimer;
    }
    else
    {
        [self startKeyframeTimer];
    }

}

- (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize {

    //UIGraphicsBeginImageContext(newSize);
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

//http://stackoverflow.com/questions/17145112/countdown-timer-ios-tutorial

- (void) manageCountdownTimer {
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [countdownTimer invalidate];
    
        running = TRUE;
    
        countdownTimer = [NSTimer scheduledTimerWithTimeInterval:.01f target:self selector:@selector(countDownTimerFired:) userInfo:nil repeats:YES];
    });
}

- (void) showKeepAliveView
{
    if(self.programMode != NMXProgramModeVideo)
    {
        self.atProgramEndControl.enabled = YES;
        keepAliveView.hidden = NO;
    }
}


- (void) countDownTimerFired:(id)sender {
    
    NSTimeInterval ti = [[NSDate date] timeIntervalSinceDate: timerStartTime];

    NSTimeInterval timeRemaining = countdownTime/1000 - ti;
    
    if(timeRemaining > 0 )
    {
        int	wholeseconds	= (int)timeRemaining;
        int	hours			= wholeseconds / 3600;
        int	minutes			= (wholeseconds % 3600) / 60;
        int	seconds			= wholeseconds % 60;
        
        timerLbl.text = [NSString stringWithFormat:@"%02ld:%02ld:%02ld", (long)hours, (long)minutes, (long)seconds];
    }
    else
    {
        //clear timer UI and start program
        
        [countdownTimer invalidate];
        
        timerContainer.hidden = YES;
        [self setDevicePickerVisible: YES];
        cancelBtn.hidden = YES;
        goBtn.hidden = YES;
        pauseProgramButton.hidden = NO;
        
        [self showKeepAliveView];
        self.reversing = NO;
        self.previousPercentage = 0.f;
    }
}


- (IBAction) resetPressed:(id)sender{
    
    [stopTimer invalidate];
    stopTimer = nil;
    startDate = [NSDate date];
    //timerLbl.text = @"00.00.00.000";
    timerLbl.text = @"00:00";
    running = FALSE;
}

- (void) timerName {
	
    sendMotorsToStartButton.hidden = YES;
    motorRampingButton.hidden = YES;
}

- (void) startKeyframeProgram
{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    dispatch_async(dispatch_get_main_queue(), ^(void) {

        NSUInteger deviceCount = self.appExecutive.deviceList.count;
        
        for (NMXDevice *device in self.appExecutive.deviceList)
        {
            [device takeUpBacklashKeyFrameProgram];
            [device mainSetControllerCount: (int)deviceCount];
        }
        for (NMXDevice *device in self.appExecutive.deviceList)
        {
            [device startKeyFrameProgram];
        }
        [self startKeyframeTimer];
    
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        
    });
}

- (void) start2PProgram
{
    NSUInteger deviceCount = self.appExecutive.deviceList.count;
    
    for (NMXDevice *device in self.appExecutive.deviceList)
    {
        [device mainSetControllerCount: (int)deviceCount];
    }

    for (NMXDevice *device in self.appExecutive.deviceList)
    {
        [device mainStartPlannedMove];
    }

}

- (void) doStartMove {
    
    if (appExecutive.is3P == YES)
    {
        [self startKeyframeProgram];
        
        [self startKeyframeTimer];
    }
    else
    {
        [self start2PProgram];
    }
    
    if(self.programMode != NMXProgramModeVideo)
    {
        [self showKeepAliveView];
        self.reversing = NO;
        self.previousPercentage = 0.f;
    }
    
    startTimerBtn.hidden = YES;
    
    if (self.appExecutive.is3P == NO)
    {
        self.totalRunTime = [self.appExecutive.device mainQueryTotalRunTime];
        self.statusTimer = self.statusTimer;
    }
    else
    {
        self.totalRunTime = [self.appExecutive.device queryKeyFrameProgramMaxTime];
    }
    
    if (self.programMode != NMXProgramModeVideo)
    {
        self.timePerFrame = self.totalRunTime / [self.appExecutive.device cameraQueryMaxShots];
    }
}

- (void) startKeyframeTimer {

    if (!keyframeTimer )
    {
        keyframeTimer = [NSTimer scheduledTimerWithTimeInterval:2.000
                                                         target:self
                                                       selector:@selector(handleKeyFrameStatusTimer:)
                                                       userInfo:nil
                                                        repeats:YES];
    }
}

- (void) startProgram {
    
    NSLog(@"startProgram");
    
    if (appExecutive.is3P == YES)
    {
        [self startKeyframeProgram];
    }
    else
    {
        [self start2PProgram];
    }
    
    [self transitionToState: ControllerStatePauseProgram];
    
    if(self.programMode != NMXProgramModeVideo)
    {
        [self showKeepAliveView];
        self.reversing = NO;
        self.previousPercentage = 0.f;
    }
    
    startTimerBtn.hidden = YES;
}

- (NSString *) stringForShortDuration: (NSInteger) duration {
    
    NSInteger	wholeseconds	= duration / 1000;
    NSInteger	milliseconds	= duration % 1000;
    NSInteger	minutes			= (wholeseconds % 3600) / 60;
    NSInteger	seconds			= wholeseconds % 60;
    NSInteger	tenths			= milliseconds / 100;
    
    NSString *	string	= [NSString stringWithFormat: @"%02ld:%02ld.%1ld", (long)minutes, (long)seconds, (long)tenths];
    
    return string;
}

#pragma mark - viewWillAppear

- (void) viewWillAppear: (BOOL) animated {
    
	[super viewWillAppear: animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleShotDurationNotification:)
                                                 name:@"chooseReviewShotDuration" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleAddKeyframeDebug:)
                                                 name:@"debugKeyframePosition" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(deviceDisconnect:)
                                                 name: kDeviceDisconnectedNotification
                                               object: nil];
    
	[self.view sendSubviewToBack: self.controlBackground];

    [self.reconnectButton setHidden: true];
    [self.disconnectedLabel setHidden: true];
	[self setFieldColors];
	[self transitionToState: ControllerStateMotorRampingOrSendMotors];
    
    [self setupAfterConnection];
    [self clearFields];
    
    [[AppExecutive sharedInstance].deviceManager setDelegate: self];
    
    NMXRunStatus runStatus;
    
    if (appExecutive.is3P == YES)
    {
        runStatus = [self.appExecutive.device queryKeyFrameProgramRunState];
    }
    else
    {
        runStatus = [self.appExecutive.device mainQueryRunStatus];
    }

    [self.view bringSubviewToFront:timerContainer];
    timerContainer.hidden = YES;
    [self setDevicePickerVisible: YES];
    
    queryFPS = [self.appExecutive.device mainQueryFPS];
    
    switch (queryFPS)
    {
        case NMXFPS24:
            
            self.fps = 24;
            break;
        case NMXFPS25:
            
            self.fps = 25;
            break;
        default:
        case NMXFPS30:
            
            self.fps = 30;
            break;
    }
    
    
    if (runStatus & NMXRunStatusDelayTimer)
    {
        [self reconnectDelay];
    }
    else if (self.appExecutive.is3P == NO)
    {
        if(runStatus & NMXRunStatusRunning ||
           runStatus & NMXRunStatusPaused)
        {
            [self showKeepAliveView];
            self.reversing = NO;
            self.previousPercentage = 0.f;

            self.motorRampingButton.hidden = YES;
            self.sendMotorsToStartButton.hidden = YES;

            if(runStatus & NMXRunStatusPingPong)
            {
                [self.atProgramEndControl setSelectedSegmentIndex:AtProgramEndPingPong];
            }
            else if (runStatus & NMXRunStatusKeepAlive)
            {
                [self.atProgramEndControl setSelectedSegmentIndex:AtProgramEndKeepAlive];
            }
            else
            {
                [self.atProgramEndControl setSelectedSegmentIndex:AtProgramEndStop];
            }

            if (runStatus & NMXRunStatusPaused)
            {
                [self transitionToResumeOrStopProgramState];
            }
            else
            {
                [self transitionToPauseProgramState];
            }
            
            self.statusTimer = self.statusTimer;
            
        }
    }
    else
    {
        if(runStatus & NMXRunStatusRunning ||
           runStatus & NMXRunStatusPaused)
        {
            //NSLog(@"review NMXKeyFrameRunStatusRunning/Paused");
            
            [self showKeepAliveView];
            self.reversing = NO;
            self.previousPercentage = 0.f;

            self.motorRampingButton.hidden = YES;
            self.sendMotorsToStartButton.hidden = YES;

            if(runStatus & NMXRunStatusPingPong)
            {
                [self.atProgramEndControl setSelectedSegmentIndex:AtProgramEndPingPong];
            }
            else if (runStatus & NMXRunStatusKeepAlive)
            {
                [self.atProgramEndControl setSelectedSegmentIndex:AtProgramEndKeepAlive];
            }
            else
            {
                [self.atProgramEndControl setSelectedSegmentIndex:AtProgramEndStop];
            }

            if (runStatus & NMXRunStatusPaused)
            {
                [self transitionToResumeOrStopProgramState];
            }
            else
            {
                [self transitionToPauseProgramState];
            }

            self.totalRunTime = [self.appExecutive.device queryKeyFrameProgramMaxTime];
            
            [self startKeyframeTimer];
        }
    }
    
    if (self.appExecutive.is3P == YES)
    {
        graphView.hidden = YES;
        panGraph.hidden = YES;
        tiltGraph.hidden = YES;
        
        [self setupGraphViews3P];
        
        if (!(runStatus & NMXRunStatusRunning) &&
            !(runStatus & NMXRunStatusPaused) && !camClosed)
        {
            for (NMXDevice *device in self.appExecutive.deviceList)
            {
                [self initKeyFrameValues: device];
            }
        }
    }
    else
    {
        graph3P.hidden = YES;
        [self setupGraphViews];
    }
    
    [settingsButton setTitle: @"\u2699" forState: UIControlStateNormal];
    
    if ([[UIScreen mainScreen] bounds].size.height <= 480)
    {
        NSLog(@"screen 480");
        
        shareBtn.hidden = YES;
        shareBtn2.hidden = NO;
    }
    
    [self showVoltage];
}

- (void) initKeyFrameValues: (NMXDevice *)device {
    
    //for shoot move, absicssa is multiple of 1000

    // Initialize keyframe arrays to be used in midpoint velocity calculation
    NSMutableArray<KeyFrameModel *> *keyframeArray;
    KeyFrameModel *kfm;
    keyframeArray = [NSMutableArray arrayWithCapacity:3];
    for (int point = 0; point < 3; point++)
    {
        KeyFrameModel *kfm = [KeyFrameModel new];
        [keyframeArray addObject: kfm];
    }
    HSpline *hs = [HSpline new];
    if (self.programMode == NMXProgramModeVideo)
    {
        hs.velocityIncrement = 0.1;
    }
    else
    {
        hs.velocityIncrement = 0.1;
    }
    
    //slide motor
    
    
    [device setCurrentKeyFrameAxis:0];
    [device setKeyFrameCount:3];
    
//    int sd = [self.appExecutive.shotDurationNumber intValue];
//        
//    NSLog(@"sd: %i",sd);
    
    if (self.programMode == NMXProgramModeVideo)
    {
        [device setKeyFrameVideoTime:[self.appExecutive.videoLengthNumber intValue]];
    }
    
    JSDeviceSettings *settings = device.settings;
    
    float val1 = (float)((int)(settings.slide3PVal1 - 1));
    float val2 = (float)((int)(settings.slide3PVal2 - 1));
    float val3 = (float)((int)(settings.slide3PVal3 - 1));
    
    float per1 = (float)settings.slide3PVal1/[self.appExecutive.frameCountNumber floatValue];
    float per2 = (float)settings.slide3PVal2/[self.appExecutive.frameCountNumber floatValue];
    float per3 = (float)settings.slide3PVal3/[self.appExecutive.frameCountNumber floatValue];
    
    if (self.programMode == NMXProgramModeVideo)
    {
        val1 = (float)((int)([self.appExecutive.videoLengthNumber intValue] * per1));
        val2 = (float)((int)([self.appExecutive.videoLengthNumber intValue] * per2));
        val3 = (float)((int)([self.appExecutive.videoLengthNumber intValue] * per3));
    }
    else if (self.appExecutive.isContinuous == YES)
    {
        val1 = (float)((int)(settings.slide3PVal1 * [self.appExecutive.intervalNumber intValue]));
        val2 = (float)((int)(settings.slide3PVal2 * [self.appExecutive.intervalNumber intValue]));
        val3 = (float)((int)(settings.slide3PVal3 * [self.appExecutive.intervalNumber intValue]));
    }
    
    float conversionFactor = (float)settings.microstep1 / 16;
    
    float startSlideOut = settings.scaledStart3PSlideDistance * conversionFactor;
    float midSlideOut = settings.scaledMid3PSlideDistance * conversionFactor;
    float endSlideOut = settings.scaledEnd3PSlideDistance * conversionFactor;

    kfm = keyframeArray[0];
    kfm.time = val1;
    kfm.position = startSlideOut;
    kfm.velocity = 0;
    kfm = keyframeArray[1];
    kfm.time = val2;
    kfm.position = midSlideOut;
    kfm.velocity = 0;
    kfm = keyframeArray[2];
    kfm.time = val3;
    kfm.position = endSlideOut;
    kfm.velocity = 0;
    
    [device setKeyFrameAbscissa:val1];
    [device setKeyFrameAbscissa:val2];
    [device setKeyFrameAbscissa:val3];
    [hs optimizePointVelForAxis:keyframeArray];

    [device setKeyFramePosition:startSlideOut];
    [device setKeyFramePosition:midSlideOut];
    [device setKeyFramePosition:endSlideOut];
    
    [device setKeyFrameVelocity:(float)0];
    [device setKeyFrameVelocity:keyframeArray[1].velocity];
    [device setKeyFrameVelocity:(float)0];
    
    [device endKeyFrameTransmission];
    
    //pan motor
    
    [device setCurrentKeyFrameAxis:1];
    [device setKeyFrameCount:3];
    
    [device setKeyFrameAbscissa:val1]; //15
    [device setKeyFrameAbscissa:val2]; //100
    [device setKeyFrameAbscissa:val3]; //250
    
    float conversionFactor2 = (float)settings.microstep2 / 16;
    
    float startPanOut = settings.scaledStart3PPanDistance * conversionFactor2;
    float midPanOut = settings.scaledMid3PPanDistance * conversionFactor2;
    float endPanOut = settings.scaledEnd3PPanDistance * conversionFactor2;
    
    kfm = keyframeArray[0];
    kfm.time = val1;
    kfm.position = startPanOut;
    kfm.velocity = 0;
    kfm = keyframeArray[1];
    kfm.time = val2;
    kfm.position = midPanOut;
    kfm.velocity = 0;
    kfm = keyframeArray[2];
    kfm.time = val3;
    kfm.position = endPanOut;
    kfm.velocity = 0;

    [hs optimizePointVelForAxis:keyframeArray];
    
    [device setKeyFramePosition:startPanOut];
    [device setKeyFramePosition:midPanOut];
    [device setKeyFramePosition:endPanOut];
    
    [device setKeyFrameVelocity:(float)0];
    [device setKeyFrameVelocity:keyframeArray[1].velocity];
    [device setKeyFrameVelocity:(float)0];
    
    [device endKeyFrameTransmission];
    
    //tilt motor
    
    [device setCurrentKeyFrameAxis:2];
    [device setKeyFrameCount:3];
    
    [device setKeyFrameAbscissa:val1]; //15
    [device setKeyFrameAbscissa:val2]; //100
    [device setKeyFrameAbscissa:val3]; //250
    
    float conversionFactor3 = (float)settings.microstep3 / 16;
    
    float startTiltOut = settings.scaledStart3PTiltDistance * conversionFactor3;
    float midTiltOut = settings.scaledMid3PTiltDistance * conversionFactor3;
    float endTiltOut = settings.scaledEnd3PTiltDistance * conversionFactor3;
    
    debugTxt.text = [NSString stringWithFormat:@"%@\n start tilt in: %f\n mid tilt in: %f\n end tilt in: %f",debugTxt.text, startTiltOut,midTiltOut,endTiltOut];
    
    kfm = keyframeArray[0];
    kfm.time = val1;
    kfm.position = startTiltOut;
    kfm.velocity = 0;
    kfm = keyframeArray[1];
    kfm.time = val2;
    kfm.position = midTiltOut;
    kfm.velocity = 0;
    kfm = keyframeArray[2];
    kfm.time = val3;
    kfm.position = endTiltOut;
    kfm.velocity = 0;
    
    [hs optimizePointVelForAxis:keyframeArray];
    
    [device setKeyFramePosition:startTiltOut];
    [device setKeyFramePosition:midTiltOut];
    [device setKeyFramePosition:endTiltOut];
    
    [device setKeyFrameVelocity:(float)0];
    [device setKeyFrameVelocity:keyframeArray[1].velocity];
    [device setKeyFrameVelocity:(float)0];
    
    NSLog(@"mid tilt Velocity: %g",keyframeArray[1].velocity);
    
    [device endKeyFrameTransmission];
        
    //    if (self.programMode == NMXProgramModeSMS)
    //    {
    //        val1 = [self roundNumber:val1];
    //        val2 = [self roundNumber:val2];
    //        val3 = [self roundNumber:val3];
    //    }
}

- (float) roundNumber: (float)val {

    float val1 = 1000.0 * floor((val/1000.0) + 0.5);
    
    return val1;
}

- (void) setupAfterConnection {

    self.programMode = [self.appExecutive.device mainQueryProgramMode];
    
    switch (self.programMode)
    {
        case NMXProgramModeSMS:
            
            self.timelapseView.hidden = NO;
            self.videoView.hidden = YES;
            self.timelapseTitle.text = @"Timelapse SMS";
            break;
            
        case NMXProgramModeTimelapse:
            
            self.timelapseView.hidden = NO;
            self.videoView.hidden = YES;
            self.timelapseTitle.text = @"Timelapse Continuous";
            break;
            
        case NMXProgramModeVideo:
            
            self.timelapseView.hidden = YES;
            self.videoView.hidden = NO;
            
            if ([self.appExecutive.device mainQueryPingPongMode])
            {
                self.videoTitle.text = @"Video Ping Pong";
            }
            else
            {
                self.videoTitle.text = @"Video One Shot";
            }
            break;
    }

    NMXRunStatus runStatus;
    if (self.appExecutive.is3P == NO)
    {
        runStatus = [self.appExecutive.device mainQueryRunStatus];
    }
    else
    {
        runStatus = [self.appExecutive.device queryKeyFrameProgramRunState];
    }

    if (runStatus & NMXRunStatusDelayTimer)
    {
        [self reconnectDelay];
    }
    else if (runStatus & NMXRunStatusPaused)
    {
        [self transitionToState: ControllerStateResumeOrStopProgram];
    }
    else if (runStatus & NMXRunStatusRunning)
    {
        [self transitionToState: ControllerStatePauseProgram];
    }
    else
    {
        [self transitionToState: ControllerStateMotorRampingOrSendMotors];
    }
}

- (void) viewWillDisappear:(BOOL)animated {
    
    NSLog(@"viewWillDisappear");
    
    [self.disconnectedTimer invalidate];
    self.disconnectedTimer = nil;

    if (!self.disconnectedDeviceVC)
    {
        [[AppExecutive sharedInstance].deviceManager setDelegate: nil];
    }
    
    [super viewWillDisappear: animated];

    [[NSNotificationCenter defaultCenter] removeObserver: self];
}

- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver: self];
}

- (void) clearFields {

    //NSLog(@"clearFields");
    
    self.videoProgressView.progress = 0;
    self.videoTimeRemainingValueLabel.text = @"00:00.0";
    self.timelapseProgressView.progress = 0;
    self.timelapseTimeRemainingValueLabel.text = @"00:00.0";
    self.framesShotValueLabel.text = @"0";
    self.videoLengthValueLabel.text = @"00:00.0";
    
    lastFrameShotValue = self.framesShotValueLabel.text;
    
    playhead.frame = origPlayheadPosition;
    
    //NSLog(@"origPlayheadPosition.origin.x: %f",origPlayheadPosition.origin.x);
}

- (void) setFieldColors {

	UIColor	*color = [ReviewStatusViewController colorWithRed: 22 green: 22 blue: 22];

	// background color of labels are not settable in interface builder

	self.timelapseTimeRemainingValueLabel.backgroundColor	= color;
	self.framesShotValueLabel.backgroundColor				= color;
	self.videoLengthValueLabel.backgroundColor				= color;
	self.videoTimeRemainingValueLabel.backgroundColor		= color;
}

- (void) didReceiveMemoryWarning {

	[super didReceiveMemoryWarning];	
}

//------------------------------------------------------------------------------

#pragma mark - Navigation

- (void) prepareForSegue: (UIStoryboardSegue *) segue sender: (id) sender {

	// Get the new view controller using [segue destinationViewController].
	// Pass the selected object to the new view controller.
    
    if ([segue.identifier isEqualToString:@"ReviewStatusTimer"])
    {
        ShortDurationViewController *secView = [segue destinationViewController];
        
        [secView setIsReviewShotTimerSegue:YES];
    }
    else if([segue.identifier isEqualToString:@"ReviewDeviceSettings"])
    {
        DeviceSettingsViewController *secView = [segue destinationViewController];
        
        secView.restorationIdentifier = @"";
        
        camClosed = YES;
    }
    else if ([segue.identifier isEqualToString: @"HelpReview"])
    {
        NSLog(@"HelpSetup");
        
        HelpViewController *msvc = segue.destinationViewController;
        
        camClosed = YES;
        
        [msvc setScreenInd:5];
    }
    else if ([segue.identifier isEqualToString:SegueToDisconnectedDeviceViewController])
    {
        self.disconnectedDeviceVC = segue.destinationViewController;
        self.disconnectedDeviceVC.delegate = self;
    }
}

//------------------------------------------------------------------------------

#pragma mark - IBAction Methods

- (IBAction)mangeAtProgramEndSelection:(id)sender {
    
    if (NO == [self checkDeviceConnectionBeforeAction])
    {
        NSNumber *mode = [appExecutive.userDefaults objectForKey: @"keepAlive"];
        self.atProgramEndControl.selectedSegmentIndex = [mode intValue];
        return;
    }
    
    NSInteger atEndSelection = self.atProgramEndControl.selectedSegmentIndex;
    
    [appExecutive.userDefaults setObject: [NSNumber numberWithLong:atEndSelection] forKey: @"keepAlive"];
    [appExecutive.userDefaults synchronize];
    
    for (NMXDevice *device in self.appExecutive.deviceList)
    {
        [device keepAlive: atEndSelection==AtProgramEndKeepAlive];
        if (device.fwVersion >= 52)
        {
            [device mainSetPingPongMode: atEndSelection==AtProgramEndPingPong];
        }
    }

}

- (IBAction) cancelTimer: (JoyButton *) sender {

    if (NO == [self checkDeviceConnectionBeforeAction])
    {
        return;
    }
    
    cancelBtn.hidden = YES;
    goBtn.hidden = YES;
    
    if (appExecutive.is3P == YES)
    {
        originalCountdownTime = 0;
        for (NMXDevice *device in self.appExecutive.deviceList)
        {
            [device stopKeyFrameProgram];
        }
        
        [keyframeTimer invalidate];
        keyframeTimer = nil;
    }
    else
    {
        for (NMXDevice *device in self.appExecutive.deviceList)
        {
            [device mainStopPlannedMove];
        }
        
        [self.statusTimer invalidate];
        self.statusTimer = nil;
    }
    
    [countdownTimer invalidate];
    
    [self transitionToMotorRampingOrStartProgramState];
    startTimerBtn.hidden = NO;

    timerContainer.hidden = YES;
    [self setDevicePickerVisible: YES];
}

- (IBAction) bypassTimer: (JoyButton *) sender {

    if (NO == [self checkDeviceConnectionBeforeAction])
    {
        return;
    }

    cancelBtn.hidden = YES;
    goBtn.hidden = YES;
    
    [countdownTimer invalidate];
    
    timerContainer.hidden = YES;
    [self setDevicePickerVisible: YES];
    
    if (appExecutive.is3P == YES)
    {
        originalCountdownTime = 0;
        for (NMXDevice *device in self.appExecutive.deviceList)
        {
            [device stopKeyFrameProgram];
        }
    }
    else
    {
        for (NMXDevice *device in self.appExecutive.deviceList)
        {
            [device mainStopPlannedMove];
        }
    }
    
    for (NMXDevice *device in self.appExecutive.deviceList)
    {
        [device setDelayProgramStartTimer:0];
    }
    
    [NSTimer scheduledTimerWithTimeInterval:0.150 target:self selector:@selector(removeDelayTimer) userInfo:nil repeats:NO];
}

- (void) removeDelayTimer {
	
    if (appExecutive.is3P == YES)
    {
        originalCountdownTime = 0;
        
        [self startKeyframeProgram];
        
        //NSLog(@"resume keyframe pause");
    }
    else
    {
        [self start2PProgram];
    }
    
    [self showKeepAliveView];
    
    [self transitionToPauseProgramState];
}

- (IBAction) handleMotorRampingButton: (JoyButton *) sender {

	DDLogDebug(@"Motor Ramping Button");
}

- (IBAction) handleSendMotorsToStartButton: (JoyButton *) sender {
    
    if (NO == [self checkDeviceConnectionBeforeAction])
    {
        return;
    }

	//DDLogDebug(@"Send Motors To Start Button");
    originalCountdownTime = 0;
    
    [appExecutive.userDefaults setObject: [NSNumber numberWithInt:0] forKey: @"keepAlive"];
    [appExecutive.userDefaults synchronize];
    
    for (NMXDevice *device in self.appExecutive.deviceList)
    {
        // Set to fastest setting to allow return to home to perform optimally
        [device motorSet: device.sledMotor Microstep: 4];
        [device motorSet: device.panMotor Microstep: 4];
        [device motorSet: device.tiltMotor Microstep: 4];
    
        [device mainSendMotorsToStart];
    }

	[self transitionToState: ControllerStateMotorRampingOrStartProgram];
    
    playhead.frame = origPlayheadPosition;
}

- (IBAction) handleStartProgramButton: (JoyButton *) sender {
    
    if (NO == [self checkDeviceConnectionBeforeAction])
    {
        return;
    }

	DDLogDebug(@"Start Program Button");
    originalCountdownTime = 0;

    for (NMXDevice *device in self.appExecutive.deviceList)
    {
        [device setDelayProgramStartTimer:0];
    }

    [self startProgram];
}

- (IBAction) handlePauseProgramButton: (JoyButton *) sender {

	DDLogDebug(@"Pause Program Button");

	[self transitionToState: ControllerStateConfirmPauseProgram];
}

- (IBAction) handleConfirmPauseProgramButton: (JoyButton *) sender {

    if (NO == [self checkDeviceConnectionBeforeAction])
    {
        return;
    }
    
	DDLogDebug(@"Confirm Pause Program Button");
    
    self.confirmPauseTimer = nil;
    
	[self transitionToState: ControllerStateResumeOrStopProgram];
    
    if (appExecutive.is3P == YES)
    {
        [keyframeTimer invalidate];
        keyframeTimer = nil;

        for (NMXDevice *device in self.appExecutive.deviceList)
        {
            [device pauseKeyFrameProgram];
        }
    }
    else
    {
        self.statusTimer = nil;
        for (NMXDevice *device in self.appExecutive.deviceList)
        {
            [device mainPausePlannedMove];
        }
    }
}

- (IBAction) handleResumeProgramButton: (JoyButton *) sender {

	DDLogDebug(@"Resume Program Button");
    
    if (NO == [self checkDeviceConnectionBeforeAction])
    {
        return;
    }

	[self transitionToState: ControllerStatePauseProgram];
    
    if (appExecutive.is3P == YES)
    {
        [self startKeyframeProgram];
        
        //NSLog(@"resume keyframe pause");
    }
    else
    {
        [self start2PProgram];
    }
}

- (IBAction) handleStopProgramButton: (JoyButton *) sender {
    
	DDLogDebug(@"Stop Program Button");

    if (NO == [self checkDeviceConnectionBeforeAction])
    {
        return;
    }
    
    [self.atProgramEndControl setSelectedSegmentIndex:AtProgramEndStop];
    
    [appExecutive.userDefaults setObject: [NSNumber numberWithInt:0] forKey: @"keepAlive"];
    [appExecutive.userDefaults synchronize];

	[self transitionToState: ControllerStateMotorRampingOrSendMotors];

    [self.appExecutive stopProgram];
    
    keepAliveView.hidden = YES;
    
    [self clearFields];
}

- (IBAction) handleReconnect:(id)sender {
    
    for (NMXDevice *device in self.appExecutive.deviceList)
    {
        device.delegate = self;
        if (device.disconnected)
        {
            [device connect];
        }
    }
    
}

- (void) didConnect: (NMXDevice *) device1 {
    
    [self.disconnectedTimer invalidate];
    self.disconnectedTimer = nil;
    
    [self.reconnectButton setHidden: true];
    [self.disconnectedLabel setHidden: true];
    
    [device1 mainSetAppMode: true];
    [device1 mainSetJoystickMode: false];
    
    [self showKeepAliveView];

    if (self.appExecutive.is3P == YES)
    {
        [self startKeyframeTimer];
    }
    
    [self setupAfterConnection];
}

- (void) didDisconnectDevice: (NMXDevice *) device {
    
    DDLogDebug(@"Did Disconnect Device");

    NMXDevice *newDevice = [self findConnectedDevice];
    if (newDevice) return;
    
    dispatch_async(dispatch_get_main_queue(), ^(void) {

        disconnectStatusLbl.text = @"Did Disconnect Device Init";

        [keyframeTimer invalidate];
        keyframeTimer = nil;
        
        self.statusTimer = nil;
        self.confirmPauseTimer = nil;
        [self hideStateButtons];
        
        if (timerContainer.hidden == NO)
        {
            cancelBtn.hidden = YES;
            goBtn.hidden = YES;
        }

        [self.reconnectButton setHidden: false];

        [self.disconnectedLabel setHidden: false];
        keepAliveView.hidden = YES;
        
        if (self.disconnectedTimer == nil)
        {
            self.disconnectedTimer = [NSTimer scheduledTimerWithTimeInterval: 1.0
                                                                      target: self
                                                                    selector: @selector(handleDisconnectedTimer:)
                                                                    userInfo: nil
                                                                     repeats: YES];
        }
    });
}

- (BOOL) checkDeviceConnectionBeforeAction
{
    NMXDevice *disconnectedDevice = nil;
    for (NMXDevice *aDevice in self.appExecutive.deviceList)
    {
        if (aDevice.disconnected == YES)
        {
            disconnectedDevice = aDevice;
        }
    }
    
    if (disconnectedDevice)
    {
        if (self.disconnectedDeviceVC)
        {
            [self.disconnectedDeviceVC reloadDeviceList];
        }
        else
        {
            [self performSegueWithIdentifier: SegueToDisconnectedDeviceViewController sender: self];
        }
        
        return NO;
    }
    
    return YES;
}

- (void) deviceDisconnect: (NSNotification *) notification
{
    NMXDevice *device = notification.object;
    [self didDisconnectDevice: device];
}


- (void) handleDisconnectedTimer: (NSTimer *) sender {
    
     if (timerContainer.hidden == NO)
     {
         return;
     }
    
    pauseProgramButton.hidden = YES;
    keepAliveView.hidden = YES;
    
    count++;
    
    time_t  currentTime = time(nil);
    UInt32  currentRunTime = self.lastRunTime + ((UInt32)(currentTime - self.timeOfLastRunTime) * 1000) - originalCountdownTime;
    float percentComplete =  currentRunTime / (float)(self.totalRunTime-originalCountdownTime);
    
    NSInteger timeRemaining = self.totalRunTime - self.lastRunTime - ((currentTime - self.timeOfLastRunTime) * 1000.0);
    
    disconnectStatusLbl.text = [NSString stringWithFormat:@"Disconnect Time %i: %li", count, (long)timeRemaining];
    
    if (timeRemaining < 0)
    timeRemaining = 0;
    
    if (percentComplete > 1)
    percentComplete = 1.0;
    
    if (NMXProgramModeVideo == self.programMode)
    {
        self.videoProgressView.progress = percentComplete;
        self.videoTimeRemainingValueLabel.text = [DurationViewController stringForDuration: timeRemaining];
                
        //NSLog(@"percentComplete2: %f",percentComplete2);
        
        if(percentComplete <= 1.0)
        {
            percentCompletePosition = (graphWidth * percentComplete)*screenRatio;
        }
        
        NSLog(@"disconnect percentCompletePosition: %f",percentCompletePosition);
        
        playhead.frame = CGRectMake(percentCompletePosition,
                                    playhead.frame.origin.y,
                                    playhead.frame.size.width,
                                    playhead.frame.size.height);
    }
    else
    {
        unsigned int  framesShot;
        
        if (timeRemaining > 0)
        framesShot = currentRunTime / self.timePerFrame;
        else
        framesShot = self.totalRunTime / self.timePerFrame;
        UInt32  videoLength = framesShot * 1000 / self.fps;
        
        self.timelapseProgressView.progress = percentComplete;
        self.timelapseTimeRemainingValueLabel.text = [DurationViewController stringForDuration: timeRemaining];
        self.framesShotValueLabel.text = [NSString stringWithFormat: @"%d", framesShot];
        self.videoLengthValueLabel.text = [ShortDurationViewController stringForShortDuration: videoLength];
        
        float percentComplete2 = [framesShotValueLabel.text intValue]/masterFrameCount;
        
        NSLog(@"disconnect percentComplete2: %f",percentComplete2);
        
        if(percentComplete2 <= 1.0)
        {
            percentCompletePosition = (graphWidth * percentComplete2) * screenRatio;
        }
        
        NSLog(@"disconnect percentCompletePosition: %f",percentCompletePosition);
        
        playhead.frame = CGRectMake(percentCompletePosition,
                                    playhead.frame.origin.y,
                                    playhead.frame.size.width,
                                    playhead.frame.size.height);
    }
}

- (IBAction) simulateDisconnect:(id)sender {
    
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"showNotificationHost"
     object:self.restorationIdentifier];
    
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        
        self.statusTimer = nil;
        self.confirmPauseTimer = nil;
        [self hideStateButtons];
        [keyframeTimer invalidate];
        keyframeTimer = nil;
        
        [self.reconnectButton setHidden: false];
        [self.disconnectedLabel setHidden: false];
        
        if (self.disconnectedTimer == nil)
        {
            self.disconnectedTimer = [NSTimer scheduledTimerWithTimeInterval: 1.0
                                                                      target: self
                                                                    selector: @selector(handleDisconnectedTimer:)
                                                                    userInfo: nil
                                                                     repeats: YES];
        }
    });
}

//------------------------------------------------------------------------------

#pragma mark - Controller State

- (void) transitionToState: (ControllerState) state {

    self.currentState = state;
    
	[self hideStateButtons];

	switch (state)
	{
		case ControllerStateMotorRampingOrSendMotors:
			[self transitionToMotorRampingOrSendMotorsState];
			break;

		case ControllerStateMotorRampingOrStartProgram:
			[self transitionToMotorRampingOrStartProgramState];
			break;

		case ControllerStatePauseProgram:
			[self transitionToPauseProgramState];
			break;

		case ControllerStateConfirmPauseProgram:
			[self transitionToConfirmPauseProgramState];
			break;

		case ControllerStateResumeOrStopProgram:
			[self transitionToResumeOrStopProgramState];
			break;

		default:
			break;
	}
}

- (void) hideStateButtons {
    
	for (UIButton *button in self.stateButtons)
    {
		button.hidden = YES;
    }
}

- (void) transitionToMotorRampingOrSendMotorsState {
    
	self.motorRampingButton.hidden = NO;
	self.sendMotorsToStartButton.hidden = NO;
}

- (void) transitionToMotorRampingOrStartProgramState {
    
	self.motorRampingButton.hidden = NO;
	self.startProgramButton.hidden = NO;
	self.startProgramButton.enabled = NO;	// disable until hardware reaches start point
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];

	self.sendMotorsTimer = self.sendMotorsTimer;	// check if the hardware is done moving
    
    playhead.frame = origPlayheadPosition;
    
    keepAliveView.hidden = YES;
}

- (void) handleSendMotorsTimer: (NSTimer *) sender {
    
    bool moving = NO;
    
    for (NMXDevice *device in self.appExecutive.deviceList)
    {
        if (!moving)
            moving = [device motorQueryRunning: device.sledMotor];
        if (!moving)
            moving = [device motorQueryRunning: device.panMotor];
        if (!moving)
            moving = [device motorQueryRunning: device.tiltMotor];
        
        if (moving)
        {
            break;
        }
    }

    if (!moving)
    {
        [self.sendMotorsTimer invalidate];
        self.sendMotorsTimer = nil;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            self.startProgramButton.enabled = YES;
            
            if (!self.appExecutive.is3P || [self.appExecutive.device fwVersion] >= 61)
            {
                startTimerBtn.hidden = NO;
            }

            for (NMXDevice *device in self.appExecutive.deviceList)
            {
                JSDeviceSettings *settings = device.settings;

                // Reset motors to correct microstep values
                [device motorSet: device.sledMotor Microstep: settings.microstep1];
                [device motorSet: device.panMotor Microstep: settings.microstep2];
                [device motorSet: device.tiltMotor Microstep: settings.microstep3];
            }
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        });
    }
}

- (void) killStatusTimerOnDisconnect
{
    
    [keyframeTimer invalidate];
    keyframeTimer = nil;
    
    [self.disconnectedTimer invalidate];
    self.disconnectedTimer = nil;
    
    [self.statusTimer invalidate];
    self.statusTimer = nil;
    
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        
        [[NSNotificationCenter defaultCenter] postNotificationName: kDeviceDisconnectedNotification object: self.appExecutive.device];
    });
}

- (NMXDevice *)findConnectedDevice
{
    NMXDevice *device = nil;
    for (NMXDevice *aDevice in self.appExecutive.deviceList)
    {
        if (aDevice.disconnected == NO)
        {
            device = aDevice;
            [self.appExecutive setActiveDevice:device];
        }
    }
    
    return device;
}

- (void) handleKeyFrameStatusTimer: (NSTimer *) sender {
    
    NMXDevice *device = self.appExecutive.device;
    if (device.disconnected)
    {
        device = [self findConnectedDevice];
    }
    if (nil == device)
    {
        [self killStatusTimerOnDisconnect];
        return;
    }
    
    NMXRunStatus runStatus = [device queryKeyFrameProgramRunState];
    
    //NSLog(@"handleKeyFrameStatusTimer runStatus = 0x%x", runStatus);
    
    if (NMXRunStatusUnknown == runStatus)
    {
        [self killStatusTimerOnDisconnect];
        return;
    }
    
    if (runStatus & NMXRunStatusDelayTimer)
    {
        self.totalRunTime = [device queryKeyFrameProgramMaxTime];
        
        self.lastRunTime = [device queryKeyFrameProgramCurrentTime];
        
        self.timeOfLastRunTime = time(nil);

        /* mm this seemed like a good idea to keep the clocks in sync but it is proving to cause problems nixing it
        // If our countdown has drifted from the device "truth", resync the app countdown timer.
        NSTimeInterval ti = [[NSDate date] timeIntervalSinceDate: timerStartTime];
        
        NSLog(@"time since start = %g      device time since start = %g", ti, self.lastRunTime/1000.);
        
        if (ABS(ti - self.lastRunTime/1000.) > 1.)
        {
            countdownTime = countdownTime-self.lastRunTime;
            
            [appExecutive setProgramDelayTime: countdownTime];
            timerStartTime = [appExecutive getDelayTimerStartTime];
            
            NSLog(@"ADJUST Countdown diff = %f", ABS(ti - self.lastRunTime/1000.));
            
            [self manageCountdownTimer];
        }
         */
        //        if (timerContainer.hidden == YES)
        //        {
        //            [self setControlVisibilityForDelayState:YES];
        //        }

    }
    else if (runStatus & NMXRunStatusRunning)
    {
        timerContainer.hidden = YES;
        [self setDevicePickerVisible: YES];
        
        //NSLog(@"NMXKeyFrameRunStatusRunning");
        
        self.lastRunTime = [device queryKeyFrameProgramCurrentTime];

        //float percentCompleteOld = [device queryKeyFramePercentComplete] / (float)100;
        // Mitch - this old and proper method to get the percent complete in KF mode doesn't work when there's a delay, calculated it ourself
        int maxTime = [device queryKeyFrameProgramMaxTime] - originalCountdownTime;
        int runTime = self.lastRunTime - originalCountdownTime;
        float percentComplete = (float)(runTime)/maxTime;
        
        //NSLog(@"OLD  percent = %g    new = %g     countdown = %g    ", percentCompleteOld, percentComplete, originalCountdownTime);
        
        self.timeOfLastRunTime = time(nil);
        
        NSInteger timeRemaining = self.totalRunTime - self.lastRunTime;
        
        if (timeRemaining < 0)
        {
            timeRemaining = 0;
        }
        
        if (percentComplete > 1)  // we may be reversing direction
        {
            self.atProgramEndControl.enabled = NO;

            NSInteger atEndSelection = self.atProgramEndControl.selectedSegmentIndex;
            if (atEndSelection==AtProgramEndPingPong)
            {
                int cycleDir = (int)percentComplete % 2;
                float prct = percentComplete - (int)percentComplete;
                if (cycleDir == 1)
                {
                    self.reversing = YES;
                    percentComplete = 1. - prct;
                }
                else
                {
                    self.reversing = NO;
                    percentComplete = prct;
                }

            }
        }

        self.previousPercentage = percentComplete;
        
        if (NMXProgramModeVideo == self.programMode)
        {
            self.videoProgressView.progress = percentComplete;
            self.videoTimeRemainingValueLabel.text = [DurationViewController stringForDuration: timeRemaining];
            
            //float percentComplete2 = (float)self.lastRunTime/self.totalRunTime;
            //NSLog(@"keyframe video percentComplete2: %f",percentComplete2);
            
            if(percentComplete <= 1.0)
            {
                percentCompletePosition = (graphWidth * percentComplete) * screenRatio;
            }
            
            NSLog(@"keyframe video percentCompletePosition: %f",percentCompletePosition);
            
            playhead.frame = CGRectMake(percentCompletePosition,
                                        playhead.frame.origin.y,
                                        playhead.frame.size.width,
                                        playhead.frame.size.height);
        }
        else
        {
            unsigned int  framesShot = [device cameraQueryCurrentShots];
            
            NSLog(@"framesShot: %i",framesShot);
            
            UInt32  videoLength = framesShot * 1000 / self.fps;
            
            NSLog(@"videoLength: %i",(unsigned int)videoLength);
            
            self.timelapseProgressView.progress = percentComplete;
            self.timelapseTimeRemainingValueLabel.text = [DurationViewController stringForDuration: timeRemaining];
            self.framesShotValueLabel.text = [NSString stringWithFormat: @"%d", framesShot];
            self.videoLengthValueLabel.text = [ShortDurationViewController stringForShortDuration: videoLength];
            
            //NSLog(@"%%    percentComplete per device: %g      remaining %@",percentComplete, self.timelapseTimeRemainingValueLabel.text);
            
            if(percentComplete <= 1.0)
            {
                percentCompletePosition = (graphWidth * percentComplete) * screenRatio;
            }

            NSLog(@"keyframe percentCompletePosition: %f",percentCompletePosition);
            
            playhead.frame = CGRectMake(percentCompletePosition,
                                        playhead.frame.origin.y,
                                        playhead.frame.size.width,
                                        playhead.frame.size.height);
        }
        
        if (percentComplete >= 1.0 || (self.atProgramEndControl.enabled == NO))
        {
            if (runStatus & NMXRunStatusKeepAlive ||
                runStatus & NMXRunStatusPingPong)
            {
                self.timelapseTimeRemainingValueLabel.text = @"-";
                self.videoTimeRemainingValueLabel.text = @"-";
            }
        }

    }
    else if (runStatus & NMXRunStatusPaused)
    {
        NSLog(@"handleKeyframeStatusTimer runStatus: NMXRunStatusPaused");
    }
    else if (runStatus & NMXRunStatusKeepAlive)
    {
        NSLog(@"keep alive");
        
        unsigned int framesShot = [device cameraQueryCurrentShots];
        
        UInt32  videoLength = framesShot * 1000 / self.fps;
        
        self.framesShotValueLabel.text = [NSString stringWithFormat: @"%d", framesShot];
        self.videoLengthValueLabel.text = [ShortDurationViewController stringForShortDuration: videoLength];
        self.timelapseTimeRemainingValueLabel.text = @"-";
        
        float percentComplete2 = [framesShotValueLabel.text intValue]/masterFrameCount;
        
        if(percentComplete2 <= 1.0)
        {
            percentCompletePosition = (graphWidth * percentComplete2) * screenRatio;
        }
        else if(percentComplete2 > 1.0)
        {
            percentCompletePosition = graphWidth * screenRatio;
        }
        
        playhead.frame = CGRectMake(percentCompletePosition,
                                    playhead.frame.origin.y,
                                    playhead.frame.size.width,
                                    playhead.frame.size.height);
    }
    else if (runStatus == NMXRunStatusUnknown)
    {
        NSLog(@"something else");
        [self killStatusTimerOnDisconnect];
    }
    else
    {
        NSLog(@"handleKeyframeStatusTimer runStatus: Stopped");
        
        [keyframeTimer invalidate];
        keyframeTimer = nil;
        
        [self clearFields];
        keepAliveView.hidden = YES;
        [self transitionToState: ControllerStateMotorRampingOrSendMotors];
        
    }
}

- (void) handleStatusTimer: (NSTimer *) sender {
    
    NMXDevice *device = self.appExecutive.device;
    
    NSLog(@"Status timer from %@", device.name);
    
    if (device.disconnected)
    {
        device = [self findConnectedDevice];
    }
    if (nil == device)
    {
        [self killStatusTimerOnDisconnect];
        return;
    }
    
    NMXRunStatus runStatus = [device mainQueryRunStatus];
    
    if (runStatus & NMXRunStatusPaused) {
        NSLog(@"handleStatusTimer runStatus: NMXRunStatusPaused");
            
        // This state should only happen from the user hitting pause, and we already handle that transition...
    }
    else if (runStatus & NMXRunStatusDelayTimer) {

        self.totalRunTime = [device mainQueryTotalRunTime];
        
        self.lastRunTime = [device mainQueryRunTime];
        
        self.timeOfLastRunTime = time(nil);
        /* mm this seemed like a good idea to keep the clocks in sync but it is proving to cause problems nixing it
        // If our countdown has drifted from the device "truth", resync the app countdown timer.
        NSTimeInterval ti = [[NSDate date] timeIntervalSinceDate: timerStartTime];
        if (ABS(ti - self.lastRunTime/1000.) > 1.)
        {
            countdownTime = countdownTime-self.lastRunTime;
            
            [appExecutive setProgramDelayTime: countdownTime];
            timerStartTime = [appExecutive getDelayTimerStartTime];

            [self manageCountdownTimer];
        }
        */
        
        //        if (timerContainer.hidden == YES)
        //        {
        //            [self setControlVisibilityForDelayState:YES];
        //        }
    }
    else if (runStatus & NMXRunStatusKeepAlive) {
        NSLog(@"keep alive");
            
        unsigned int framesShot = [device cameraQueryCurrentShots];
        
        UInt32  videoLength = framesShot * 1000 / self.fps;
        
        self.framesShotValueLabel.text = [NSString stringWithFormat: @"%d", framesShot];
        self.videoLengthValueLabel.text = [ShortDurationViewController stringForShortDuration: videoLength];
        
        self.lastRunTime = [device mainQueryRunTime];
        NSInteger timeRemaining = self.totalRunTime - self.lastRunTime;
        self.timelapseTimeRemainingValueLabel.text = [DurationViewController stringForDuration: timeRemaining];
        
        float percentComplete2 = [framesShotValueLabel.text intValue]/masterFrameCount;
        
        float percentComplete = MIN(1.0, [device mainQueryProgramPercentComplete] / (float)100);
        if (percentComplete >= 1.f || self.reversing)
        {
            self.atProgramEndControl.enabled = NO;
        }
        
        if (self.atProgramEndControl.enabled == NO)  // we've gone beyond the max => either ping pong or keep alive
        {
            if (runStatus & NMXRunStatusKeepAlive ||
                runStatus & NMXRunStatusPingPong)
            {
                self.timelapseTimeRemainingValueLabel.text = @"-";
            }
        }
        
        //NSLog(@"percentComplete2: %f",percentComplete2);
        
        if(percentComplete2 <= 1.0)
        {
            percentCompletePosition = (graphWidth * percentComplete2) * screenRatio;
        }
        else if(percentComplete2 > 1.0)
        {
            percentCompletePosition = graphWidth * screenRatio;
        }
        
        //NSLog(@"percentCompletePosition: %f",percentCompletePosition);
        
        playhead.frame = CGRectMake(percentCompletePosition,
                                    playhead.frame.origin.y,
                                    playhead.frame.size.width,
                                    playhead.frame.size.height);
    }
    else if (runStatus & NMXRunStatusRunning) {
        
        timerContainer.hidden = YES;
        [self setDevicePickerVisible: YES];
        
        //NSLog(@"NMXRunStatusRunning");
        
        int devicePercentComplete = [device mainQueryProgramPercentComplete];
        
        float percentComplete = MIN(1.0, devicePercentComplete / (float)100);
        self.lastRunTime = [device mainQueryRunTime];
        self.timeOfLastRunTime = time(nil);
        
        NSInteger timeRemaining = self.totalRunTime - self.lastRunTime;
        
        if (timeRemaining < 0)
        {
            timeRemaining = 0;
        }
        else if (devicePercentComplete >= 100)  // work around a bug where the controller sometimes reports
                                                // 100% done early in the program, usually after a delay
        {
            percentComplete = .0;
        }
        
        if (self.previousPercentage > percentComplete)  // we are reversing direction
        {
            NSInteger atEndSelection = self.atProgramEndControl.selectedSegmentIndex;
            if (atEndSelection==AtProgramEndPingPong)
            {
                self.reversing = !self.reversing;
            }
        }
        
        if (percentComplete >= 1.f || self.reversing)
        {
            self.atProgramEndControl.enabled = NO;
        }
        
        self.previousPercentage = percentComplete;

        if (self.reversing)
        {
            percentComplete = 1. - percentComplete;
        }
        
        if (NMXProgramModeVideo == self.programMode)
        {
            self.videoProgressView.progress = percentComplete;
            self.videoTimeRemainingValueLabel.text = [DurationViewController stringForDuration: timeRemaining];
            
            //                [self.appExecutive.videoLengthNumber integerValue];
            //                NSLog(@"percentComplete: %f",percentComplete);
            //                NSLog(@"totalRunTime: %u",(unsigned int)self.totalRunTime);
            //                NSLog(@"lastRunTime: %u",(unsigned int)self.lastRunTime);
            //                NSLog(@"timeRemaining: %li",(long)timeRemaining);
            
            //float percentComplete2 = (float)self.lastRunTime/self.totalRunTime;
            //NSLog(@"percentComplete2 orig: %f",percentComplete2);
            
            if(percentComplete <= 1.0)
            {
                //percentCompletePosition = (graphWidth * percentComplete)*screenRatio;
                percentCompletePosition = (graphWidth * percentComplete)*screenRatio;
            }
            
            NSLog(@"percentCompletePosition orig: %f",percentCompletePosition);
            
            playhead.frame = CGRectMake(percentCompletePosition,
                                        playhead.frame.origin.y,
                                        playhead.frame.size.width,
                                        playhead.frame.size.height);
        }
        else
        {
            unsigned int framesShot = [device cameraQueryCurrentShots];
            
            UInt32  videoLength = framesShot * 1000 / self.fps;
            
            self.timelapseProgressView.progress = percentComplete;
            self.timelapseTimeRemainingValueLabel.text = [DurationViewController stringForDuration: timeRemaining];
            self.framesShotValueLabel.text = [NSString stringWithFormat: @"%d", framesShot];
            self.videoLengthValueLabel.text = [ShortDurationViewController stringForShortDuration: videoLength];

            if(percentComplete <= 1.0)
            {
                percentCompletePosition = (graphWidth * percentComplete) * screenRatio;
            }
            
            //NSLog(@"**********  Runtime = %u   Total runtime = %u\n\n", [device mainQueryRunTime], [device mainQueryTotalRunTime]);
            
            //NSLog(@"percentCompletePosition orig: %f",percentCompletePosition);
            
            playhead.frame = CGRectMake(percentCompletePosition,
                                        playhead.frame.origin.y,
                                        playhead.frame.size.width,
                                        playhead.frame.size.height);
        }

        if (self.atProgramEndControl.enabled == NO)  // we've gone beyond the max => either ping pong or keep alive
        {
            if (runStatus & NMXRunStatusKeepAlive ||
                runStatus & NMXRunStatusPingPong)
            {
                self.timelapseTimeRemainingValueLabel.text = @"-";
                self.videoTimeRemainingValueLabel.text  = @"-";
            }
        }

    }
    else if (runStatus == NMXRunStatusUnknown) {
        NSLog(@"something else: %i",runStatus);
        
        [self killStatusTimerOnDisconnect];
        
    }
    else {
        NSLog(@"handleStatusTimer runStatus: Stopped");
        
        // Due to a firmware bug.  We want to make sure we are really stopped...
        
        runStatus = [device mainQueryRunStatus];
        
        if ((runStatus & NMXRunStatusPaused) == 0 &&
            (runStatus & NMXRunStatusRunning) == 0)
        {
            [self.statusTimer invalidate];
            self.statusTimer = nil;
            
            [self clearFields];
            keepAliveView.hidden = YES;
            [self transitionToState: ControllerStateMotorRampingOrSendMotors];
        }
        else
        {
            DDLogWarn(@"Saw a FAKE stopped response");
        }
    }

}

- (void) calculatePingPongReverse
{
    NMXDevice *device = self.appExecutive.device;
    int runningBackwards = 0;
    
    if (AtProgramEndPingPong != self.atProgramEndControl.selectedSegmentIndex)
    {
        self.reversing = NO;
        return;
    }

    
    if (self.programMode == NMXProgramModeVideo)
    {
        if (self.totalRunTime > 0)
        {
            if (self.appExecutive.is3P)
            {
                self.lastRunTime = [device queryKeyFrameProgramCurrentTime];
            }
            else
            {
                self.lastRunTime = [device mainQueryRunTime];
            }

            runningBackwards = ((int)((float)self.lastRunTime/(float)self.totalRunTime)) % 2;
        }
    }
    else
    {
        unsigned int framesPerRun = [self.appExecutive.frameCountNumber intValue];
        unsigned int framesShot = [device cameraQueryCurrentShots];
    
        runningBackwards = ((int)((float)framesShot/(float)framesPerRun)) % 2;
    }
    
    //NSLog(@"Total Run Time = %g     Last Run Time = %g", (float)self.totalRunTime, (float)self.lastRunTime);
    
    self.reversing = runningBackwards ? YES: NO;
}

- (void) transitionToPauseProgramState {
    
    NMXDevice *device = self.appExecutive.device;
	DDLogDebug(@"transitionToPauseProgramState");

	self.pauseProgramButton.hidden = NO;

    switch (queryFPS)
    {
        case NMXFPS24:
            self.fps = 24;
             break;
        case NMXFPS25:
            self.fps = 25;
            break;
        default:
        case NMXFPS30:
            self.fps = 30;
            break;
    }
    
    if (appExecutive.is3P == YES)
    {
        self.totalRunTime = [device queryKeyFrameProgramMaxTime];
    }
    else
    {
        self.totalRunTime = [device mainQueryTotalRunTime];
        self.statusTimer = self.statusTimer;
    }
    
    if (self.programMode != NMXProgramModeVideo)
    {
        self.timePerFrame = self.totalRunTime / [device cameraQueryMaxShots];
    }

    [self calculatePingPongReverse];
}

- (void) transitionToConfirmPauseProgramState {

	DDLogDebug(@"transitionToConfirmPauseProgramState");

	self.confirmPauseProgramButton.hidden = NO;
	self.confirmPauseTimer = self.confirmPauseTimer;
}

- (void) handleConfirmPauseTimer: (NSTimer *) sender {

	DDLogDebug(@"handleConfirmPauseTimer");

	self.confirmPauseTimer = nil;
	[self transitionToState: ControllerStatePauseProgram];
}

- (void) transitionToResumeOrStopProgramState {
    
	self.resumeProgramButton.hidden = NO;
	self.stopProgramButton.hidden = NO;
    self.confirmPauseProgramButton.hidden = YES;
    self.pauseProgramButton.hidden = YES;
    
    [self calculatePingPongReverse];
}

#pragma mark - Graph

- (void) setupGraphViews3P {
    
    NMXDevice *device = self.appExecutive.device;
    masterFrameCount = [self.appExecutive.frameCountNumber floatValue];
    
    graph3P.is3P = YES;

    JSDeviceSettings *settings = device.settings;

    graph3P.frame1 = settings.slide3PVal1;
    graph3P.frame2 = settings.slide3PVal2;
    graph3P.frame3 = settings.slide3PVal3;
    
    graph3P.headerString = @"3-Point Move";
    
    graph3P.frameCount = masterFrameCount;
    
    self.programMode = [device mainQueryProgramMode];
    
    if(self.programMode == NMXProgramModeVideo)
    {
        graph3P.isVideo = YES;
        keepAliveView.hidden = YES;
        
        NSString *a = [ShortDurationViewController stringForShortDuration: [self.appExecutive.videoLengthNumber integerValue]];
        
        //NSString *a = [ShortDurationViewController stringForShortDuration: [self.appExecutive.shotDurationNumber integerValue]];
        
        //NSString *a = [DurationViewController stringForShortDuration: [self.appExecutive.shotDurationNumber integerValue]];
        
        graph3P.videoLength = a;
        
        //NSLog(@"ran videoLength: %@",a);
    }
    
    graphWidth = graph3P.frame.size.width;
    
    //NSLog(@"graphViewContainer: %f", graphViewContainer.frame.size.width);
    
    //NSLog(@"graphWidth: %f", graphWidth);
    
    screenRatio = (screenWidth - 32)/graphWidth;
}

- (void) setupGraphViews {
    
    NMXDevice *device = self.displayedDevice;
    JSDeviceSettings *settings = device.settings;

    masterFrameCount = [self.appExecutive.frameCountNumber floatValue];
    
    NSArray *slideIncrease = [settings slideIncreaseValues];
    NSArray *slideDecrease = [settings slideDecreaseValues];
    
    float firstSlideIncreasePoint = [[slideIncrease objectAtIndex:0] floatValue];
    float secondSlideIncreasePoint = [[slideIncrease objectAtIndex:1] floatValue];
    
    float firstSlideDecreasePoint = [[slideDecrease objectAtIndex:0] floatValue];
    float secondSlideDecreasePoint = [[slideDecrease objectAtIndex:1] floatValue];
    
    NSArray *panIncrease = [settings panIncreaseValues];
    NSArray *panDecrease = [settings panDecreaseValues];
    
    float firstPanIncreasePoint = [[panIncrease objectAtIndex:0] floatValue];
    float secondPanIncreasePoint = [[panIncrease objectAtIndex:1] floatValue];
    
    float firstPanDecreasePoint = [[panDecrease objectAtIndex:0] floatValue];
    float secondPanDecreasePoint = [[panDecrease objectAtIndex:1] floatValue];
    
    NSArray *tiltIncrease = [settings tiltIncreaseValues];
    NSArray *tiltDecrease = [settings tiltDecreaseValues];
    
    float firstTiltIncreasePoint = [[tiltIncrease objectAtIndex:0] floatValue];
    float secondTiltIncreasePoint = [[tiltIncrease objectAtIndex:1] floatValue];
    
    float firstTiltDecreasePoint = [[tiltDecrease objectAtIndex:0] floatValue];
    float secondTiltDecreasePoint = [[tiltDecrease objectAtIndex:1] floatValue];
    
    float calcFirstSlideIncreasePoint = firstSlideIncreasePoint/2;
    float calcSecondSlideIncreasePoint = secondSlideIncreasePoint/2;
    
    float calcFirstSlideDecreasePoint = firstSlideDecreasePoint/2 + .5;
    float calcSecondSlideDecreasePoint = secondSlideDecreasePoint/2 + .5;
    
    graphView.frame1 = calcFirstSlideIncreasePoint;
    graphView.frame2 = calcSecondSlideIncreasePoint;
    graphView.frame3 = calcFirstSlideDecreasePoint;
    graphView.frame4 = calcSecondSlideDecreasePoint;
    
    graphView.headerString = @"Slider";
    graphView.frameCount = masterFrameCount;
    
    float calcFirstPanIncreasePoint = firstPanIncreasePoint/2;
    float calcSecondPanIncreasePoint = secondPanIncreasePoint/2;
    
    float calcFirstPanDecreasePoint = firstPanDecreasePoint/2 + .5;
    float calcSecondPanDecreasePoint = secondPanDecreasePoint/2 + .5;
    
    panGraph.frame1 = calcFirstPanIncreasePoint;
    panGraph.frame2 = calcSecondPanIncreasePoint;
    panGraph.frame3 = calcFirstPanDecreasePoint;
    panGraph.frame4 = calcSecondPanDecreasePoint;
    
    panGraph.headerString = @"Pan";
    panGraph.frameCount = masterFrameCount;
    
    float calcFirstTiltIncreasePoint = firstTiltIncreasePoint/2;
    float calcSecondTiltIncreasePoint = secondTiltIncreasePoint/2;
    
    float calcFirstTiltDecreasePoint = firstTiltDecreasePoint/2 + .5;
    float calcSecondTiltDecreasePoint = secondTiltDecreasePoint/2 + .5;
    
    tiltGraph.frame1 = calcFirstTiltIncreasePoint;
    tiltGraph.frame2 = calcSecondTiltIncreasePoint;
    tiltGraph.frame3 = calcFirstTiltDecreasePoint;
    tiltGraph.frame4 = calcSecondTiltDecreasePoint;
    
    tiltGraph.headerString = @"Tilt";
    tiltGraph.frameCount = masterFrameCount;
    
    self.programMode = [self.appExecutive.device mainQueryProgramMode];
    
    if(self.programMode == NMXProgramModeVideo)
    {
        graphView.isVideo = YES;
        panGraph.isVideo = YES;
        tiltGraph.isVideo = YES;
        keepAliveView.hidden = YES;
        
        NSString *a = [ShortDurationViewController stringForShortDuration: [self.appExecutive.videoLengthNumber integerValue]];
        
        graphView.videoLength = a;
        panGraph.videoLength = a;
        tiltGraph.videoLength = a;
    }
    
    graphWidth = graphView.frame.size.width;
    
    screenRatio = (screenWidth - 32)/graphWidth;
}

#pragma mark - Share

- (void) takePhoto {
    
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    
    [self presentViewController:picker animated:YES completion:NULL];
}

- (void) selectPhoto {
    
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    [self presentViewController:picker animated:YES completion:NULL];
}

#pragma mark ELCImagePickerControllerDelegate Methods

- (void) elcImagePickerController:(ELCImagePickerController *)picker didFinishPickingMediaWithInfo:(NSArray *)info {
    
    NSLog(@"add");
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
    NSMutableArray *images = [NSMutableArray arrayWithCapacity:[info count]];
    
    float posX = 0;
    float posY = 0;
    
    for (NSDictionary *dict in info)
    {
        //NSLog(@"add image");
        UIImage *image = [dict objectForKey:UIImagePickerControllerOriginalImage];
        [images addObject:image];
        UIImageView *view = [[UIImageView alloc] initWithFrame:CGRectMake(posX, posY, image.size.width, image.size.height)];
        view.image = image;
        view.contentMode = UIViewContentModeCenter;
    }
}

- (UIImage *)imageWithView:(UIView *)view {
    
    view.backgroundColor = [UIColor blackColor];
    
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, view.opaque, 0.0);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    UIImage * img = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return img;
}

- (void) elcImagePickerControllerDidCancel:(ELCImagePickerController *)picker {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) displayPickerForGroup:(ALAssetsGroup *)group {
    
    ELCAssetTablePicker *tablePicker = [[ELCAssetTablePicker alloc] initWithStyle:UITableViewStylePlain];
    tablePicker.singleSelection = YES;
    tablePicker.immediateReturn = YES;
    
    ELCImagePickerController *elcPicker = [[ELCImagePickerController alloc] initWithRootViewController:tablePicker];
    elcPicker.maximumImagesCount = 1;
    elcPicker.imagePickerDelegate = self;
    elcPicker.returnsOriginalImage = NO; //Only return the fullScreenImage, not the fullResolutionImage
    tablePicker.parent = elcPicker;
    
    // Move me
    
    tablePicker.assetGroup = group;
    [tablePicker.assetGroup setAssetsFilter:[ALAssetsFilter allAssets]];
    
    [self presentViewController:elcPicker animated:YES completion:nil];
}

- (void) showMultipleImageOptions {
    
    //[self performSegueWithIdentifier:@"Add" sender:self];
}

#pragma mark - Image Picker

- (void) launchMultiImageController {
    
    ELCImagePickerController *elcPicker = [[ELCImagePickerController alloc] initImagePicker];
    elcPicker.maximumImagesCount = 20;
    elcPicker.returnsOriginalImage = NO; //Only return the fullScreenImage, not the fullResolutionImage
    elcPicker.imagePickerDelegate = self;
    
    [self presentViewController:elcPicker animated:YES completion:nil];
}

- (void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    chosenImage = info[UIImagePickerControllerEditedImage];
    //self.itemImage.image = chosenImage;
    
    NSLog(@"chose camera pic");
    
    [picker dismissViewControllerAnimated:NO completion:NULL];
    
    [self share2];
    
    //[self performSegueWithIdentifier:@"Add" sender:self];
    
    camClosed = YES;
}

- (void) imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
    camClosed = YES;
}

#pragma mark - Actionsheet

- (void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if ([actionSheet.title isEqualToString:@"Share NMX Motion"])
    {
        switch (buttonIndex)
        {
            case 0:
            {
                NSLog(@"share fb");
                
                [self shareFacebook];
            }
                break;
                
            case 1:
            {
                NSLog(@"share ig");
                
                [self shareInstagram];
            }
                break;
            case 2:
            {
                NSLog(@"email");
                
                //[self sendEmail];
            }
                break;
            case 3:
            {
                NSLog(@"text");
                
                //[self textOutfit];
            }
                break;
            default:
                break;
        }
    }
    else if ([actionSheet.title isEqualToString:@"Add Photo"])
    {
        switch (buttonIndex)
        {
            case 0:
            {
                [self takePhoto];
            }
                break;
                
            case 1:
            {
                [self selectPhoto];
            }
                break;
            default:
                break;
        }
    }
    else
    {
        //        if (buttonIndex == 1)
        //        {
        //
        //        }
        //        else if(buttonIndex == 0)
        //        {
        //            UIGraphicsBeginImageContextWithOptions(self.mainImage.bounds.size, NO, 0.0);
        //            [self.mainImage.image drawInRect:CGRectMake(0, 0, self.mainImage.frame.size.width, self.mainImage.frame.size.height)];
        //            UIImage *SaveImage = UIGraphicsGetImageFromCurrentImageContext();
        //            UIGraphicsEndImageContext();
        //            UIImageWriteToSavedPhotosAlbum(SaveImage, self,@selector(image:didFinishSavingWithError:contextInfo:), nil);
        //        }
    }
}

- (IBAction) shareScene:(UIButton*)sender {
    
    [self takePhoto];    
}

- (void) share2 {
    
    if (appDelegate.hostActive == YES || appDelegate.internetActive == YES)
    {
        
        UIActionSheet * sheet = [[UIActionSheet alloc]
                                 initWithTitle:@"Share NMX Motion"
                                 delegate:self
                                 cancelButtonTitle:@"Cancel"
                                 destructiveButtonTitle:nil
                                 otherButtonTitles:@"Facebook", @"Instagram",nil];
        
        [sheet showInView:self.view];
        
    }
    else
    {
        UIActionSheet * sheet = [[UIActionSheet alloc]
                                 initWithTitle:@"Please Connect to the Internet"
                                 delegate:self
                                 cancelButtonTitle:@"Ok"
                                 destructiveButtonTitle:nil
                                 otherButtonTitles:@"",nil];
        
        [sheet showInView:self.view];
    }
}

- (void) textOutfit {
    
    //UIImage *pic1 = [self loadImage:@"image1.png"];
    
    //    createdImage = [self imageWithView:imageContentView];
    //    createdImage = [self imageWithImage:createdImage scaledToWidth:612];
    
    MFMessageComposeViewController *controller = [[MFMessageComposeViewController alloc] init];
    controller.messageComposeDelegate = self;
    
    if([MFMessageComposeViewController canSendText])
    {
        controller.body = @"NMX Motion iOS";
        //controller.recipients = [NSArray arrayWithObjects:@"12345678", @"87654321", nil];
        controller.messageComposeDelegate = self;
        [self presentViewController:controller animated:YES completion:nil];
    }
    
    if([MFMessageComposeViewController respondsToSelector:@selector(canSendAttachments)] && [MFMessageComposeViewController canSendAttachments])
    {
        NSData* attachment = UIImagePNGRepresentation(createdImage);
        NSString* uti = (NSString*)kUTTypeMessage;
        [controller addAttachmentData:attachment typeIdentifier:uti filename:@"image1.png"];
    }
    else
    {
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        pasteboard.persistent = YES;
        pasteboard.image = createdImage;
    }
}

- (void) messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result {
    
    if(result == MessageComposeResultCancelled)
    {
        //Message cancelled
    }
    else if(result == MessageComposeResultSent)
    {
        //Message sent
    }
    
    switch (result)
    {
        case MessageComposeResultCancelled:
            NSLog(@"Cancelled");
            break;
        case MessageComposeResultFailed:
            
            break;
        case MessageComposeResultSent:
            
            break;
        default:
            break;
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) sendEmail {
    
    //    createdImage = [self imageWithView:imageContentView];
    //    createdImage = [self imageWithImage:createdImage scaledToWidth:612];
    
    //UIImage *pic1 = [self loadImage:@"image1.png"];
    
    MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
    picker.mailComposeDelegate = self;
    //    [picker setToRecipients:recipients];
    //    [picker setSubject:subject];
    NSData* attachment = UIImagePNGRepresentation(createdImage);
    //NSString* uti = (NSString*)kUTTypeMessage;
    [picker addAttachmentData:attachment mimeType:@"image/png" fileName:@"filename.png"];
    [picker setMessageBody:@"NMX Motion iOS" isHTML:YES];
    [self presentViewController:picker animated:YES completion:nil];
}

- (void) shareInstagram {
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 63, 320, 320)];
    imageView.image = chosenImage;
    
    UIImage *screenShot = imageView.image;
    
    NSString *savePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/Test.igo"];
    [UIImagePNGRepresentation(screenShot) writeToFile:savePath atomically:YES];
    
    CGRect rect = CGRectMake(0 ,0 , 0, 0);
    NSString *jpgPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/Test.igo"];
    NSURL *igImageHookFile = [[NSURL alloc] initWithString:[[NSString alloc] initWithFormat:@"file://%@", jpgPath]];
    
    //self.dic = [self setupControllerWithURL:igImageHookFile usingDelegate:self];
    
    self.dic = [UIDocumentInteractionController interactionControllerWithURL:igImageHookFile];
    self.dic.UTI = @"com.instagram.exclusivegram";
    
    [self.dic presentOpenInMenuFromRect: rect inView: self.view animated: YES ];
    NSURL *instagramURL = [NSURL URLWithString:@"instagram://media?id=MEDIA_ID&tag?name=DP"];
    
    if ([[UIApplication sharedApplication] canOpenURL:instagramURL])
    {
        [self.dic presentOpenInMenuFromRect: rect inView: self.view animated: YES ];
    }
    else
    {
        NSLog(@"No Instagram Found");
        
        UIAlertView *alertView = [[UIAlertView alloc]
                                  initWithTitle:@""
                                  message:@"Instagram not Installed" delegate:nil
                                  cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
    }
}

- (UIDocumentInteractionController *) setupControllerWithURL: (NSURL*) fileURL usingDelegate: (id <UIDocumentInteractionControllerDelegate>) interactionDelegate {
    
    UIDocumentInteractionController *interactionController = [UIDocumentInteractionController interactionControllerWithURL: fileURL];
    interactionController.delegate = interactionDelegate;
    return interactionController;
}

- (void) shareFacebook {
    
    //    createdImage = [self imageWithView:imageContentView];
    //    createdImage = [self imageWithImage:createdImage scaledToWidth:612];
    
    if([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook])
    {
        //NSLog(@"SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook");
        
        SLComposeViewController *controller = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
        
        [controller setInitialText:[NSString stringWithFormat:@"Created with NMX Motion iOS"]];
        //[controller addURL:[NSURL URLWithString:url]];
        [controller addImage:chosenImage];
        //[controller addImage:[self mergeImage:pic1 withImage:pic2]];
        //[controller addImage:[self mergeImages2:imageArray]];
        
        [self presentViewController:controller animated:YES completion:Nil];
    }
}

- (void) shareTwitter {
    
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter])
    {
        SLComposeViewController *tweetSheet = [SLComposeViewController
                                               composeViewControllerForServiceType:SLServiceTypeTwitter];
        
        [tweetSheet setInitialText:[NSString stringWithFormat:@"NMX Motion iOS"]];
        [self presentViewController:tweetSheet animated:YES completion:nil];
    }
}

- (void) showVoltage {
    
    [NSTimer scheduledTimerWithTimeInterval:.500 target:self selector:@selector(showVoltageTimer) userInfo:nil repeats:NO];
}

- (void) showVoltageTimer {
    
    float voltagePercent = [self.appExecutive calculateVoltage: NO];
    
    float offset = 1 - (batteryIcon.frame.size.height * voltagePercent) - .5;
    
    UIView *v = [[UIView alloc] initWithFrame:CGRectMake(batteryIcon.frame.origin.x + 8,
                                                         batteryIcon.frame.origin.y + (batteryIcon.frame.size.height + offset),
                                                         batteryIcon.frame.size.width * .47,
                                                         batteryIcon.frame.size.height * voltagePercent)];
    
//    [[UIView alloc] initWithFrame:CGRectMake(batteryIcon.frame.origin.x + 7,
//                                                         batteryIcon.frame.origin.y + (batteryIcon.frame.size.height + offset),
//                                                         batteryIcon.frame.size.width * .5,
//                                                         batteryIcon.frame.size.height * per4)];
    
    v.backgroundColor = [UIColor colorWithRed:230.0/255 green:234.0/255 blue:239.0/255 alpha:.8];
    
    [controlBackground addSubview:v];
}


#pragma mark - UIPickerViewDelegate Protocol Methods


- (CGFloat) pickerView: (UIPickerView *) pickerView rowHeightForComponent: (NSInteger) component {
    
    return 18.0;
}

- (CGFloat) pickerView: (UIPickerView *) pickerView widthForComponent: (NSInteger) component {
    
    return 280.0;
}

- (NSAttributedString *) pickerView: (UIPickerView *) pickerView attributedTitleForRow: (NSInteger) row forComponent: (NSInteger) component {
    
    NSDictionary *	attributes	=  @{ NSForegroundColorAttributeName: [UIColor whiteColor]};
    NSString *		string		= @"";
    
    NSArray<NMXDevice *> *devices = self.appExecutive.deviceList;
    
    switch (component)
    {
        case 0:
            string = [self.appExecutive stringWithHandleForDeviceName: devices[row].name];
            break;
        default:
            return nil;
            break;
    }
    
    return [[NSAttributedString alloc] initWithString: string attributes: attributes];
}

- (void) pickerView: (UIPickerView *) pickerView didSelectRow: (NSInteger) row inComponent: (NSInteger) component
{
    NSArray<NMXDevice *> *devices = self.appExecutive.deviceList;
    self.displayedDevice = devices[row];
    
    [self setupGraphViews];
    [graphView setNeedsDisplay];
    [panGraph setNeedsDisplay];
    [tiltGraph setNeedsDisplay];
}


//------------------------------------------------------------------------------

#pragma mark - UIPickerViewDataSource Protocol Methods


- (NSInteger) numberOfComponentsInPickerView: (UIPickerView *) pickerView {
    return 1;
}

- (NSInteger) pickerView: (UIPickerView *) pickerView numberOfRowsInComponent: (NSInteger) component {
    return self.appExecutive.deviceList.count;
}

#pragma mark JSDisconnectedDeviceDelegate

- (void) willAbortReconnect
{
}

- (void) abortReconnect
{
    self.disconnectedDeviceVC = nil;
}


@end
