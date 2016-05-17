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

@end


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

    device = [AppExecutive sharedInstance].device;
    
    screenWidth = self.view.frame.size.width;
    
    lastFrameValue = framesShotValueLabel.text;
    
    //NSLog(@"graphViewContainer width: %f",graphViewContainer.frame.size.width);
    
    origPlayheadPosition = CGRectMake(playhead.frame.origin.x,
                                      playhead.frame.origin.y,
                                      playhead.frame.size.width,
                                      playhead.frame.size.height);
    
    [cancelBtn addTarget:self action:@selector(cancelTimer:) forControlEvents:UIControlEventTouchUpInside];
    
    [goBtn addTarget:self action:@selector(bypassTimer:) forControlEvents:UIControlEventTouchUpInside];
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self
	 selector:@selector(handleShotDurationNotification:)
	 name:@"chooseReviewShotDuration" object:nil];
    
    [[NSNotificationCenter defaultCenter]
	 addObserver:self
	 selector:@selector(handleAddKeyframeDebug:)
	 name:@"debugKeyframePosition" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(deviceDisconnect:)
                                                 name: kDeviceDisconnectedNotification
                                               object: nil];
    
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

    if (device.fwVersion < 52)
    {
        [self.atProgramEndControl removeSegmentAtIndex:AtProgramEndPingPong animated:NO];
    }
    else if ([device mainQueryPingPongMode])
    {
        [self.atProgramEndControl setSelectedSegmentIndex:AtProgramEndPingPong];
    }
    
	[super viewDidLoad];
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
    
    [device setDelayProgramStartTimer:countdownTime];
    
    [self manageCountdownTimer];
    
    [self doStartMove];
}

- (void) reconnectDelay
{
    timerContainer.hidden = NO;
    
    if (self.appExecutive.is3P == NO)
    {
        self.totalRunTime = [device mainQueryTotalRunTime];
        self.lastRunTime = [device mainQueryRunTime];
    }
    else
    {
        self.lastRunTime = [device queryKeyFrameProgramCurrentTime];
        self.totalRunTime = [device queryKeyFrameProgramMaxTime];
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
        cancelBtn.hidden = YES;
        goBtn.hidden = YES;
        pauseProgramButton.hidden = NO;
        
        [self showKeepAliveView];
        self.reversing = NO;
        self.previousPercentage = 0.f;
    }
}

//count up timer

- (void) countUpTimerFired:(id)sender {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        NSDate *currentDate = [NSDate date];
        NSTimeInterval timeInterval = [currentDate timeIntervalSinceDate:startDate];
        NSDate *timerDate = [NSDate dateWithTimeIntervalSince1970:timeInterval];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        //[dateFormatter setDateFormat:@"HH:mm:ss.SSS"];
        //[dateFormatter setDateFormat:@"mm:ss.SSS"];
        [dateFormatter setDateFormat:@"HH:mm:ss"];
        [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0.0]];
        NSString *timeString = [dateFormatter stringFromDate:timerDate];
        timerLbl.text = timeString;
    });
}

- (void) manageCountupTimer {
    
    if(!running)
    {
        startDate = [NSDate date];
        
        running = TRUE;
        
        //[sender setTitle:@"Stop" forState:UIControlStateNormal];
        
        if (stopTimer == nil)
        {
            stopTimer = [NSTimer scheduledTimerWithTimeInterval:1.0/10.0
                                                         target:self
                                                       selector:@selector(countUpTimerFired:)
                                                       userInfo:nil
                                                        repeats:YES];
        }
    }
    else
    {
        running = FALSE;
        
        //[sender setTitle:@"Start" forState:UIControlStateNormal];
        
        [stopTimer invalidate];
        stopTimer = nil;
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

        [[AppExecutive sharedInstance].device takeUpBacklashKeyFrameProgram];
        [[AppExecutive sharedInstance].device startKeyFrameProgram];

        [self startKeyframeTimer];
    
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        
    });
}

- (void) doStartMove {
    
    if (appExecutive.is3P == YES)
    {
        [self startKeyframeProgram];
        
        [self startKeyframeTimer];
    }
    else
    {
        [[AppExecutive sharedInstance].device mainStartPlannedMove];
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
        self.totalRunTime = [device mainQueryTotalRunTime];
        self.statusTimer = self.statusTimer;
    }
    else
    {
        self.totalRunTime = [device queryKeyFrameProgramMaxTime];
    }
    
    if (self.programMode != NMXProgramModeVideo)
    {
        self.timePerFrame = self.totalRunTime / [device cameraQueryMaxShots];
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
        [[AppExecutive sharedInstance].device mainStartPlannedMove];
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
        runStatus = [device queryKeyFrameProgramRunState];
    }
    else
    {
        runStatus = [device mainQueryRunStatus];
    }

    
    //NSLog(@"viewWillAppear status: %i", runStatus);
    //NSLog(@"keepAlive setting: %ld",(long)[appExecutive.defaults integerForKey: @"keepAlive"]);
    //NSLog(@"viewWillAppear savedSecondsLeft: %i", savedSecondsLeft);
    
    [self.view bringSubviewToFront:timerContainer];
    timerContainer.hidden = YES;
    
    queryFPS = [device mainQueryFPS];
    
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

            self.totalRunTime = [device queryKeyFrameProgramMaxTime];
            
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
            [self initKeyFrameValues];
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

- (void) initKeyFrameValues {
    
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
    
    
    [appExecutive.device setCurrentKeyFrameAxis:0];
    [appExecutive.device setKeyFrameCount:3];
    
//    int sd = [self.appExecutive.shotDurationNumber intValue];
//        
//    NSLog(@"sd: %i",sd);
    
    if (self.programMode == NMXProgramModeVideo)
    {
        [appExecutive.device setKeyFrameVideoTime:[self.appExecutive.videoLengthNumber intValue]];
    }
    
    float val1 = (float)((int)(self.appExecutive.slide3PVal1 - 1));
    float val2 = (float)((int)(self.appExecutive.slide3PVal2 - 1));
    float val3 = (float)((int)(self.appExecutive.slide3PVal3 - 1));
    
    float per1 = (float)self.appExecutive.slide3PVal1/[self.appExecutive.frameCountNumber floatValue];
    float per2 = (float)self.appExecutive.slide3PVal2/[self.appExecutive.frameCountNumber floatValue];
    float per3 = (float)self.appExecutive.slide3PVal3/[self.appExecutive.frameCountNumber floatValue];
    
    if (self.programMode == NMXProgramModeVideo)
    {
        val1 = (float)((int)([self.appExecutive.videoLengthNumber intValue] * per1));
        val2 = (float)((int)([self.appExecutive.videoLengthNumber intValue] * per2));
        val3 = (float)((int)([self.appExecutive.videoLengthNumber intValue] * per3));
    }
    else if (self.appExecutive.isContinuous == YES)
    {
        //NSLog(@"isContinuous");
        
        val1 = (float)((int)(self.appExecutive.slide3PVal1 * [self.appExecutive.intervalNumber intValue]));
        val2 = (float)((int)(self.appExecutive.slide3PVal2 * [self.appExecutive.intervalNumber intValue]));
        val3 = (float)((int)(self.appExecutive.slide3PVal3 * [self.appExecutive.intervalNumber intValue]));
    }
    
    float conversionFactor = (float)appExecutive.microstep1 / 16;
    
    float startSlideOut = self.appExecutive.scaledStart3PSlideDistance * conversionFactor;
    float midSlideOut = self.appExecutive.scaledMid3PSlideDistance * conversionFactor;
    float endSlideOut = self.appExecutive.scaledEnd3PSlideDistance * conversionFactor;

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
    
    [appExecutive.device setKeyFrameAbscissa:val1];
    [appExecutive.device setKeyFrameAbscissa:val2];
    [appExecutive.device setKeyFrameAbscissa:val3];
    [hs optimizePointVelForAxis:keyframeArray];

    NSLog(@"Slider Motor keyframes");
    NSLog(@"val1: %f   position : %g",(float)val1, startSlideOut);
    NSLog(@"val2: %f   position : %g",(float)val2, midSlideOut);
    NSLog(@"val3: %f   position : %g",(float)val3, endSlideOut);
    
    NSLog(@"appExecutive.microstep1: %f",(float)appExecutive.microstep1);

    
    [appExecutive.device setKeyFramePosition:startSlideOut];
    [appExecutive.device setKeyFramePosition:midSlideOut];
    [appExecutive.device setKeyFramePosition:endSlideOut];
    
    [appExecutive.device setKeyFrameVelocity:(float)0];
    [appExecutive.device setKeyFrameVelocity:keyframeArray[1].velocity];
    [appExecutive.device setKeyFrameVelocity:(float)0];
    
    NSLog(@"mid slide Velocity: %g",keyframeArray[1].velocity);
    
    [appExecutive.device endKeyFrameTransmission];
    
    //pan motor
    
    [appExecutive.device setCurrentKeyFrameAxis:1];
    [appExecutive.device setKeyFrameCount:3];
    
    [appExecutive.device setKeyFrameAbscissa:val1]; //15
    [appExecutive.device setKeyFrameAbscissa:val2]; //100
    [appExecutive.device setKeyFrameAbscissa:val3]; //250
    
    NSLog(@"appExecutive.microstep2: %f",(float)appExecutive.microstep2);
    
    float conversionFactor2 = (float)appExecutive.microstep2 / 16;
    
    float startPanOut = self.appExecutive.scaledStart3PPanDistance * conversionFactor2;
    float midPanOut = self.appExecutive.scaledMid3PPanDistance * conversionFactor2;
    float endPanOut = self.appExecutive.scaledEnd3PPanDistance * conversionFactor2;
    
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
    
    [appExecutive.device setKeyFramePosition:startPanOut];
    [appExecutive.device setKeyFramePosition:midPanOut];
    [appExecutive.device setKeyFramePosition:endPanOut];
    
    [appExecutive.device setKeyFrameVelocity:(float)0];
    [appExecutive.device setKeyFrameVelocity:keyframeArray[1].velocity];
    [appExecutive.device setKeyFrameVelocity:(float)0];
    
    NSLog(@"mid pan Velocity: %g",keyframeArray[1].velocity);
    
    [appExecutive.device endKeyFrameTransmission];
    
    //tilt motor
    
    [appExecutive.device setCurrentKeyFrameAxis:2];
    [appExecutive.device setKeyFrameCount:3];
    
    [appExecutive.device setKeyFrameAbscissa:val1]; //15
    [appExecutive.device setKeyFrameAbscissa:val2]; //100
    [appExecutive.device setKeyFrameAbscissa:val3]; //250
    
    NSLog(@"appExecutive.microstep3: %f",(float)appExecutive.microstep3);
    
    float conversionFactor3 = (float)appExecutive.microstep3 / 16;
    
    float startTiltOut = self.appExecutive.scaledStart3PTiltDistance * conversionFactor3;
    float midTiltOut = self.appExecutive.scaledMid3PTiltDistance * conversionFactor3;
    float endTiltOut = self.appExecutive.scaledEnd3PTiltDistance * conversionFactor3;
    
    NSLog(@"startSlideOut: %f",startSlideOut);
    NSLog(@"startPanOut: %f",startPanOut);
    NSLog(@"startTiltOut: %f",startTiltOut);
    
    NSLog(@"midSlideOut: %f",midSlideOut);
    NSLog(@"midPanOut: %f",midPanOut);
    NSLog(@"midTiltOut: %f",midTiltOut);
    
    NSLog(@"endSlideOut: %f",endSlideOut);
    NSLog(@"endPanOut: %f",endPanOut);
    NSLog(@"endTiltOut: %f",endTiltOut);
    
    debugTxt.text = @"";
    
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
    
    [appExecutive.device setKeyFramePosition:startTiltOut];
    [appExecutive.device setKeyFramePosition:midTiltOut];
    [appExecutive.device setKeyFramePosition:endTiltOut];
    
    [appExecutive.device setKeyFrameVelocity:(float)0];
    [appExecutive.device setKeyFrameVelocity:keyframeArray[1].velocity];
    [appExecutive.device setKeyFrameVelocity:(float)0];
    
    NSLog(@"mid tilt Velocity: %g",keyframeArray[1].velocity);
    
    [appExecutive.device endKeyFrameTransmission];
        
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

    device = [AppExecutive sharedInstance].device;

    self.programMode = [device mainQueryProgramMode];
    
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
            
            if ([device mainQueryPingPongMode])
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
        runStatus = [device mainQueryRunStatus];
    }
    else
    {
        runStatus = [device queryKeyFrameProgramRunState];
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

    [[AppExecutive sharedInstance].deviceManager setDelegate: nil];
    
    [super viewWillDisappear: animated];

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
}

//------------------------------------------------------------------------------

#pragma mark - IBAction Methods

- (IBAction)mangeAtProgramEndSelection:(id)sender {
    
    NSInteger atEndSelection = self.atProgramEndControl.selectedSegmentIndex;
    
    [appExecutive.defaults setObject: [NSNumber numberWithLong:atEndSelection] forKey: @"keepAlive"];
    [appExecutive.defaults synchronize];
    
    //NSLog(@"keepAlive setting: %ld",(long)[appExecutive.defaults integerForKey: @"keepAlive"]);
    
    [device keepAlive: atEndSelection==AtProgramEndKeepAlive];
    if (device.fwVersion >= 52)
    {
        [device mainSetPingPongMode: atEndSelection==AtProgramEndPingPong];
    }

}

- (IBAction) cancelTimer: (JoyButton *) sender {

    cancelBtn.hidden = YES;
    goBtn.hidden = YES;
    
    //[device setDelayProgramStartTimer:0];
    
    if (appExecutive.is3P == YES)
    {
        originalCountdownTime = 0;
        [[AppExecutive sharedInstance].device stopKeyFrameProgram];
        
        [keyframeTimer invalidate];
        keyframeTimer = nil;
    }
    else
    {
        [[AppExecutive sharedInstance].device mainStopPlannedMove];
        
        [self.statusTimer invalidate];
        self.statusTimer = nil;
    }
    
    [countdownTimer invalidate];
    
    //[self manageCountupTimer];
    
    [self transitionToMotorRampingOrStartProgramState];
    startTimerBtn.hidden = NO;

    timerContainer.hidden = YES;
}

- (IBAction) bypassTimer: (JoyButton *) sender {

    cancelBtn.hidden = YES;
    goBtn.hidden = YES;
    
    [countdownTimer invalidate];
    
    timerContainer.hidden = YES;
    
    if (appExecutive.is3P == YES)
    {
        originalCountdownTime = 0;
        [[AppExecutive sharedInstance].device stopKeyFrameProgram];
    }
    else
    {
        [[AppExecutive sharedInstance].device mainStopPlannedMove];
    }
    
    [device setDelayProgramStartTimer:0];
    
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
        [[AppExecutive sharedInstance].device mainStartPlannedMove];
    }
    
    [self showKeepAliveView];
    
    [self transitionToPauseProgramState];
}

- (IBAction) handleMotorRampingButton: (JoyButton *) sender {

	DDLogDebug(@"Motor Ramping Button");
}

- (IBAction) handleSendMotorsToStartButton: (JoyButton *) sender {
    
	//DDLogDebug(@"Send Motors To Start Button");
    originalCountdownTime = 0;
    
    [appExecutive.defaults setObject: [NSNumber numberWithInt:0] forKey: @"keepAlive"];
    [appExecutive.defaults synchronize];
    
    // Set to fastest setting to allow return to home to perform optimally
    [device motorSet: device.sledMotor Microstep: 4];
    [device motorSet: device.panMotor Microstep: 4];
    [device motorSet: device.tiltMotor Microstep: 4];
    
    [device mainSendMotorsToStart];

	[self transitionToState: ControllerStateMotorRampingOrStartProgram];
    
    playhead.frame = origPlayheadPosition;
}

- (IBAction) handleStartProgramButton: (JoyButton *) sender {
    
	DDLogDebug(@"Start Program Button");
    originalCountdownTime = 0;

    [device setDelayProgramStartTimer:0];

    [self startProgram];
}

- (IBAction) handlePauseProgramButton: (JoyButton *) sender {

	DDLogDebug(@"Pause Program Button");

	[self transitionToState: ControllerStateConfirmPauseProgram];
}

- (IBAction) handleConfirmPauseProgramButton: (JoyButton *) sender {

	DDLogDebug(@"Confirm Pause Program Button");
    
    self.confirmPauseTimer = nil;
    
	[self transitionToState: ControllerStateResumeOrStopProgram];
    
    if (appExecutive.is3P == YES)
    {
        [keyframeTimer invalidate];
        keyframeTimer = nil;

        [[AppExecutive sharedInstance].device pauseKeyFrameProgram];
    }
    else
    {
        self.statusTimer = nil;
        [[AppExecutive sharedInstance].device mainPausePlannedMove];
    }
}

- (IBAction) handleResumeProgramButton: (JoyButton *) sender {

	DDLogDebug(@"Resume Program Button");

	[self transitionToState: ControllerStatePauseProgram];
    
    if (appExecutive.is3P == YES)
    {
        [self startKeyframeProgram];
        
        //NSLog(@"resume keyframe pause");
    }
    else
    {
        [[AppExecutive sharedInstance].device mainStartPlannedMove];
    }
}

- (IBAction) handleStopProgramButton: (JoyButton *) sender {
    
	DDLogDebug(@"Stop Program Button");
    
    [self.atProgramEndControl setSelectedSegmentIndex:AtProgramEndStop];
    
    [appExecutive.defaults setObject: [NSNumber numberWithInt:0] forKey: @"keepAlive"];
    [appExecutive.defaults synchronize];
    
    [appExecutive.defaults setObject: @"no" forKey: @"didDisconnect"];
    [appExecutive.defaults synchronize];
    
    [appExecutive.defaults setObject: appExecutive.device.name forKey: @"deviceName"];
    [appExecutive.defaults synchronize];

	[self transitionToState: ControllerStateMotorRampingOrSendMotors];
    
    if (appExecutive.is3P == YES)
    {
        [[AppExecutive sharedInstance].device stopKeyFrameProgram];
    }
    else
    {
        [[AppExecutive sharedInstance].device mainStopPlannedMove];
        
        [device keepAlive:0];
        if (device.fwVersion >= 52)
        {
            [device mainSetPingPongMode: NO];
        }
    }
    
    keepAliveView.hidden = YES;
    
    [self clearFields];
}

- (IBAction) handleReconnect:(id)sender {
    
    [AppExecutive sharedInstance].device.delegate = self;
    [[AppExecutive sharedInstance].device connect];
    
    //mm this looks wrong!   should only do this on didConnect
    [self.disconnectedTimer invalidate];
    self.disconnectedTimer = nil;
    
    if (self.appExecutive.is3P == YES)
    {
        [self startKeyframeTimer];
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
    
    [self setupAfterConnection];
}

- (void) didDisconnectDevice: (CBPeripheral *) peripheral {
    
    DDLogDebug(@"Did Disconnect Device");
    
//    [appExecutive.defaults setObject: @"yes" forKey: @"didDisconnect"];
//    [appExecutive.defaults synchronize];
    
    [appExecutive.defaults setObject: appExecutive.device.name forKey: @"deviceName"];
    [appExecutive.defaults synchronize];

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

- (void) deviceDisconnect: (id) object
{
    [self didDisconnectDevice: nil];
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
    
    //[[NSNotificationCenter defaultCenter] postNotificationName: kDeviceDisconnectedNotification object: nil];
    
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
    
    bool moving;
    
    moving = [device motorQueryRunning: device.sledMotor];
    
    if (!moving)
        moving = [device motorQueryRunning: device.panMotor];
    if (!moving)
        moving = [device motorQueryRunning: device.tiltMotor];

    if (!moving)
    {
        [self.sendMotorsTimer invalidate];
        self.sendMotorsTimer = nil;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            self.startProgramButton.enabled = YES;
            
            if (!self.appExecutive.is3P || [device fwVersion] >= 61)
            {
                startTimerBtn.hidden = NO;
            }
            
            // Reset motors to correct microstep values
            [device motorSet: device.sledMotor Microstep: appExecutive.microstep1];
            [device motorSet: device.panMotor Microstep: appExecutive.microstep2];
            [device motorSet: device.tiltMotor Microstep: appExecutive.microstep3];
            
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
    
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        
        [[NSNotificationCenter defaultCenter] postNotificationName: kDeviceDisconnectedNotification object: @"program disconnect during run"];
    });
}

- (void) handleKeyFrameStatusTimer: (NSTimer *) sender {
    
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
    else if (runStatus & NMXRunStatusUnknown)
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
        
/*
 //mm debug cycle timing
        UInt32 lastRunTime = [device mainQueryRunTime];
        AppExecutive *ae = [AppExecutive sharedInstance];
        NSInteger intervalTime = [ae intervalNumber].integerValue;
        UInt32 timeIntoCycle = lastRunTime % intervalTime;
        NSInteger focus = [ae.focusNumber integerValue];
        NSInteger trigger = [ae.triggerNumber integerValue];
        NSInteger delay = [ae.delayNumber integerValue];
        NSLog(@"Into Cycle %u    Start of MM = %ld", timeIntoCycle, focus+trigger+delay-900);
*/
        
        timerContainer.hidden = YES;
            
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
            
        [self.statusTimer invalidate];
        self.statusTimer = nil;
        
        keyframeTimer = nil;
        
        [self.disconnectedTimer invalidate];
        self.disconnectedTimer = nil;
        
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            
            [[NSNotificationCenter defaultCenter] postNotificationName: kDeviceDisconnectedNotification object: @"program disconnect during run"];
        });
        
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
    
    masterFrameCount = [self.appExecutive.frameCountNumber floatValue];
    
    graph3P.is3P = YES;
    
    graph3P.frame1 = appExecutive.slide3PVal1;
    graph3P.frame2 = appExecutive.slide3PVal2;
    graph3P.frame3 = appExecutive.slide3PVal3;
    
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
    
    masterFrameCount = [self.appExecutive.frameCountNumber floatValue];
    
    NSArray *slideIncrease = [self.appExecutive slideIncreaseValues];
    NSArray *slideDecrease = [self.appExecutive slideDecreaseValues];
    
    //    NSLog(@"slideIncrease: %@",slideIncrease);
    //    NSLog(@"slideDecrease: %@",slideDecrease);
    
    float firstSlideIncreasePoint = [[slideIncrease objectAtIndex:0] floatValue];
    float secondSlideIncreasePoint = [[slideIncrease objectAtIndex:1] floatValue];
    
    //    NSLog(@"firstSlideIncreasePoint: %f",firstSlideIncreasePoint);
    //    NSLog(@"secondSlideIncreasePoint: %f",secondSlideIncreasePoint);
    
    float firstSlideDecreasePoint = [[slideDecrease objectAtIndex:0] floatValue];
    float secondSlideDecreasePoint = [[slideDecrease objectAtIndex:1] floatValue];
    
    //    NSLog(@"firstSlideDecreasePoint: %f",firstSlideDecreasePoint);
    //    NSLog(@"secondSlideDecreasePoint: %f",secondSlideDecreasePoint);
    
    NSArray *panIncrease = [self.appExecutive panIncreaseValues];
    NSArray *panDecrease = [self.appExecutive panDecreaseValues];
    
    //    NSLog(@"panIncrease: %@",panIncrease);
    //    NSLog(@"panDecrease: %@",panDecrease);
    
    float firstPanIncreasePoint = [[panIncrease objectAtIndex:0] floatValue];
    float secondPanIncreasePoint = [[panIncrease objectAtIndex:1] floatValue];
    
    //    NSLog(@"firstPanIncreasePoint: %f",firstPanIncreasePoint);
    //    NSLog(@"secondPanIncreasePoint: %f",secondPanIncreasePoint);
    
    float firstPanDecreasePoint = [[panDecrease objectAtIndex:0] floatValue];
    float secondPanDecreasePoint = [[panDecrease objectAtIndex:1] floatValue];
    
    //    NSLog(@"firstPanDecreasePoint: %f",firstPanDecreasePoint);
    //    NSLog(@"secondPanDecreasePoint: %f",secondPanDecreasePoint);
    
    NSArray *tiltIncrease = [self.appExecutive tiltIncreaseValues];
    NSArray *tiltDecrease = [self.appExecutive tiltDecreaseValues];
    
    //    NSLog(@"tiltIncrease: %@",tiltIncrease);
    //    NSLog(@"tiltDecrease: %@",tiltDecrease);
    
    float firstTiltIncreasePoint = [[tiltIncrease objectAtIndex:0] floatValue];
    float secondTiltIncreasePoint = [[tiltIncrease objectAtIndex:1] floatValue];
    
    //    NSLog(@"firstTiltIncreasePoint: %f",firstTiltIncreasePoint);
    //    NSLog(@"secondTiltIncreasePoint: %f",secondTiltIncreasePoint);
    
    float firstTiltDecreasePoint = [[tiltDecrease objectAtIndex:0] floatValue];
    float secondTiltDecreasePoint = [[tiltDecrease objectAtIndex:1] floatValue];
    
    //    NSLog(@"firstTiltDecreasePoint: %f",firstTiltDecreasePoint);
    //    NSLog(@"secondTiltDecreasePoint: %f",secondTiltDecreasePoint);
    
    float calcFirstSlideIncreasePoint = firstSlideIncreasePoint/2;
    float calcSecondSlideIncreasePoint = secondSlideIncreasePoint/2;
    
    float calcFirstSlideDecreasePoint = firstSlideDecreasePoint/2 + .5;
    float calcSecondSlideDecreasePoint = secondSlideDecreasePoint/2 + .5;
    
    //    NSLog(@"calcFirstSlideIncreasePoint: %f",calcFirstSlideIncreasePoint);
    //    NSLog(@"calcSecondSlideIncreasePoint: %f",calcSecondSlideIncreasePoint);
    //
    //    NSLog(@"calcFirstSlideDecreasePoint: %f",calcFirstSlideDecreasePoint);
    //    NSLog(@"calcSecondSlideDecreasePoint: %f",calcSecondSlideDecreasePoint);
    
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
    
    self.programMode = [device mainQueryProgramMode];
    
    if(self.programMode == NMXProgramModeVideo)
    {
        graphView.isVideo = YES;
        panGraph.isVideo = YES;
        tiltGraph.isVideo = YES;
        keepAliveView.hidden = YES;
        
        //NSString *a = [DurationViewController stringForShortDuration: [self.appExecutive.shotDurationNumber integerValue]];
        
        NSString *a = [ShortDurationViewController stringForShortDuration: [self.appExecutive.videoLengthNumber integerValue]];
        
        graphView.videoLength = a;
        panGraph.videoLength = a;
        tiltGraph.videoLength = a;
        
        //NSLog(@"ran videoLength: %@",a);
    }
    
    graphWidth = graphView.frame.size.width;
    
    //NSLog(@"graphViewContainer: %f", graphViewContainer.frame.size.width);
    
    //NSLog(@"graphWidth: %f", graphWidth);
    
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
    
//    float voltage = self.appExecutive.voltage;
//    
//    float range = self.appExecutive.voltageHigh - self.appExecutive.voltageLow;
//    
//    float diff = self.appExecutive.voltageHigh - voltage;
//    
//    float per = diff/range;
//    
//    float per2 = voltage/self.appExecutive.voltageHigh;
    
    //per2 = .35;
    
//    NSLog(@"voltage: %.02f",voltage);
//    NSLog(@"high: %.02f",self.appExecutive.voltageHigh);
//    NSLog(@"low: %.02f",self.appExecutive.voltageLow);
//    NSLog(@"range: %.02f",range);
//    NSLog(@"diff: %.02f",diff);
//    NSLog(@"per: %.02f",per);
//    NSLog(@"per2: %.02f",per2);
    
    float newBase = self.appExecutive.voltageHigh - self.appExecutive.voltageLow;
    
    //NSLog(@"newBase: %.02f",newBase);
    
    float newVoltage = self.appExecutive.voltage - self.appExecutive.voltageLow;
    
    //NSLog(@"newVoltage: %.02f",newVoltage);
    
    float per4 = newVoltage/newBase;
    
    //NSLog(@"per4: %.02f",per4);
    
    if (per4 > 1)
    {
        per4 = 1;
    }
    
    if (per4 < 0)
    {
        per4 = 0;
    }
    
    float offset = 1 - (batteryIcon.frame.size.height * per4) - .5;
    
    UIView *v = [[UIView alloc] initWithFrame:CGRectMake(batteryIcon.frame.origin.x + 8,
                                                         batteryIcon.frame.origin.y + (batteryIcon.frame.size.height + offset),
                                                         batteryIcon.frame.size.width * .47,
                                                         batteryIcon.frame.size.height * per4)];
    
//    [[UIView alloc] initWithFrame:CGRectMake(batteryIcon.frame.origin.x + 7,
//                                                         batteryIcon.frame.origin.y + (batteryIcon.frame.size.height + offset),
//                                                         batteryIcon.frame.size.width * .5,
//                                                         batteryIcon.frame.size.height * per4)];
    
    v.backgroundColor = [UIColor colorWithRed:230.0/255 green:234.0/255 blue:239.0/255 alpha:.8];
    
    [controlBackground addSubview:v];
}

@end
