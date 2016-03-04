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
//mm keepAliveSwitch,
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
    
    timerContainer.hidden = YES;
    startTimerBtn.hidden = YES;
    keepAliveView.hidden = YES;
    
    //http://stackoverflow.com/questions/13155461/creating-a-stopwatch-in-iphone
    
    //[device setDelayProgramStartTimer:3000];
    
    if (!debugDisconnect)
    {
        disconnectBtn.hidden = YES;
        disconnectStatusLbl.hidden = YES;
    }

    [self setupIcons];
    
    if ([device mainQueryPingPongMode])
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

#pragma mark - Delay Timer Notification

- (void) handleShotDurationNotification:(NSNotification *)pNotification {
    
    NSNumber *n = pNotification.object;
        
    secondsLeft = [n intValue];
    
    //secondsLeft = 5000; //debug
    
    [appExecutive.defaults setObject: [NSNumber numberWithInt:secondsLeft] forKey: @"programDelayTimer"];
    [appExecutive.defaults synchronize];
    
    //NSLog(@"defaults programDelay: %@",[appExecutive getNumberForKey: @"programDelayTimer"]);
    
    NSLog(@"handleShotDurationNotification secondsLeft: %i",secondsLeft);
    
    int	wholeseconds	= secondsLeft / 1000;
    int	hours			= wholeseconds / 3600;
    int	minutes			= (wholeseconds % 3600) / 60;
    int	seconds			= wholeseconds % 60;
    
    timerLbl.text = [NSString stringWithFormat:@"%02ld:%02ld:%02ld", (long)hours, (long)minutes, (long)seconds];
    
    //NSLog(@"timer duration: %@",n);
    
    keepAliveView.hidden = YES;
    cancelBtn.hidden = NO;
    goBtn.hidden = NO;
    startTimerBtn.hidden = YES;
    timerContainer.hidden = NO;
    
    [device setDelayProgramStartTimer:secondsLeft];
    
    [self manageCountdownTimer];
    
    [self doStartMove];
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
    
    [countdownTimer invalidate];
    
    running = TRUE;
    
    countdownTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(countDownTimerFired:) userInfo:nil repeats:YES];
}

- (void) countDownTimerFired:(id)sender {
    
    NSLog(@"countDownTimerFired secondsLeft: %i",secondsLeft);
    
    if(secondsLeft > 0 )
    {
        secondsLeft -=  1000;
        
        int	wholeseconds	= secondsLeft / 1000;
        int	hours			= wholeseconds / 3600;
        int	minutes			= (wholeseconds % 3600) / 60;
        int	seconds			= wholeseconds % 60;
        
        timerLbl.text = [NSString stringWithFormat:@"%02ld:%02ld:%02ld", (long)hours, (long)minutes, (long)seconds];
    }
    else
    {
        //clear timer UI and start program
        
        NSLog(@"clear UI");
        
        [countdownTimer invalidate];
        
        timerContainer.hidden = YES;
        cancelBtn.hidden = YES;
        goBtn.hidden = YES;
        pauseProgramButton.hidden = NO;
        
        if (!self.appExecutive.is3P)
        {
            keepAliveView.hidden = NO;
        }
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

- (void) doStartMove {
    
    [[AppExecutive sharedInstance].device mainStartPlannedMove];
    
    if(self.programMode != NMXProgramModeVideo && !self.appExecutive.is3P)
    {
        keepAliveView.hidden = NO;
    }
    
    startTimerBtn.hidden = YES;
    
    self.totalRunTime = [device mainQueryTotalRunTime];
    
    self.statusTimer = self.statusTimer;
    
    if (self.programMode != NMXProgramModeVideo)
    {
        self.timePerFrame = self.totalRunTime / [device cameraQueryMaxShots];
    }
}

- (void) startKeyframeTimer {

    keyframeTimer = [NSTimer scheduledTimerWithTimeInterval:2.000
                                                     target:self
                                                   selector:@selector(handleKeyFrameStatusTimer:)
                                                   userInfo:nil
                                                    repeats:YES];
}

- (void) startProgram {
    
    NSLog(@"startProgram");
    
    if (appExecutive.is3P == YES)
    {
        [[AppExecutive sharedInstance].device startKeyFrameProgram];
        
        [self startKeyframeTimer];
    }
    else
    {
        [[AppExecutive sharedInstance].device mainStartPlannedMove];
    }
    
    [self transitionToState: ControllerStatePauseProgram];
    
    if(self.programMode != NMXProgramModeVideo && !self.appExecutive.is3P)
    {
        keepAliveView.hidden = NO;
    }
    
    
    //    [device keepAlive: 1]; //mm TESTING
    
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
    
    NMXRunStatus runStatus = [device mainQueryRunStatus];
    NMXRunStatus runStatusKeyFrame = [device queryKeyFrameProgramRunState];
    
    //NSLog(@"viewWillAppear status: %i", runStatus);
    //NSLog(@"keepAlive setting: %ld",(long)[appExecutive.defaults integerForKey: @"keepAlive"]);
    
    int savedSecondsLeft = [[appExecutive getNumberForKey: @"programDelayTimer"] intValue];
    
    //NSLog(@"viewWillAppear savedSecondsLeft: %i", savedSecondsLeft);
    
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
    
    if (self.appExecutive.is3P == NO)
    {
        if (runStatus & NMXRunStatusDelayTimer)
        {
            timerContainer.hidden = NO;
            
            //int currentDelayTime = [device queryDelayTime];
            
            self.totalRunTime = [device mainQueryTotalRunTime];
            self.lastRunTime = [device mainQueryRunTime];
            self.timeOfLastRunTime = time(nil);
            
    //        int shotDuration = (int)[appExecutive.shotDurationNumber integerValue];
    //        
    //        NSLog(@"NMXRunStatusDelayTimer shotDuration: %i", shotDuration);
            
            int timeRemaining = self.totalRunTime - self.lastRunTime;
            
            int	wholeseconds5	= (int)timeRemaining / 1000;
            int	hours5			= wholeseconds5 / 3600;
            int	minutes5		= (wholeseconds5 % 3600) / 60;
            int	seconds5		= wholeseconds5 % 60;
            
            NSLog(@"NMXRunStatusDelayTimer totalRunTime: %02ld:%02ld:%02ld", (long)hours5, (long)minutes5, (long)seconds5);
            
            self.lastRunTime = [device mainQueryRunTime];
            
            int	wholeseconds3	= (int)self.lastRunTime / 1000;
            int	hours3			= wholeseconds3 / 3600;
            int	minutes3		= (wholeseconds3 % 3600) / 60;
            int	seconds3		= wholeseconds3 % 60;
            
            NSLog(@"NMXRunStatusDelayTimer lastRunTime: %02ld:%02ld:%02ld", (long)hours3, (long)minutes3, (long)seconds3);
            
            self.timeOfLastRunTime = time(nil);
            
            if (NMXProgramModeVideo == self.programMode)
            {
                timeRemaining = self.totalRunTime - (savedSecondsLeft * 2) - self.lastRunTime - (int)[appExecutive.videoLengthNumber integerValue];
            }
            else
            {
                timeRemaining = self.totalRunTime - (savedSecondsLeft * 2) - self.lastRunTime - (int)[appExecutive.shotDurationNumber integerValue];
            }
            
            int	wholeseconds	= timeRemaining / 1000;
            int	hours			= wholeseconds / 3600;
            int	minutes			= (wholeseconds % 3600) / 60;
            int	seconds			= wholeseconds % 60;
            
            NSLog(@"NMXRunStatusDelayTimer time remaining2: %02ld:%02ld:%02ld", (long)hours, (long)minutes, (long)seconds);
            
            timerLbl.text = [NSString stringWithFormat:@"%02ld:%02ld:%02ld", (long)hours, (long)minutes, (long)seconds];
            
            secondsLeft = timeRemaining;
            
            NSLog(@"viewWillAppear secondsLeft: %i",secondsLeft);
            
            [self manageCountdownTimer];
            
            //keepAliveView.hidden = YES;
            cancelBtn.hidden = NO;
            goBtn.hidden = NO;
            //startTimerBtn.hidden = YES;
            //timerContainer.hidden = NO;
            
            sendMotorsToStartButton.hidden = YES;
            motorRampingButton.hidden = YES;
            
            self.statusTimer = self.statusTimer;
        }
        else if(runStatus & NMXRunStatusRunning ||
                runStatus & NMXRunStatusPaused ||
                runStatus & NMXRunStatusKeepAlive)
        {
            //mm            [keepAliveSwitch setOn:[appExecutive.defaults integerForKey: @"keepAlive"]];
            [self.atProgramEndControl setSelectedSegmentIndex:AtProgramEndKeepAlive];
            
            keepAliveView.hidden = NO;
            
            self.statusTimer = self.statusTimer;
        }
        else if(runStatus & NMXRunStatusPingPong)
        {
            [self.atProgramEndControl setSelectedSegmentIndex:AtProgramEndPingPong];
            keepAliveView.hidden = NO;
        }
        
        if (runStatus & NMXRunStatusKeepAlive)
        {
            [self transitionToPauseProgramState];
            
            self.motorRampingButton.hidden = YES;
            self.sendMotorsToStartButton.hidden = YES;
        }
    }
    else
    {
        if(runStatusKeyFrame & NMXRunStatusRunning ||
           runStatusKeyFrame & NMXRunStatusPaused)
        {
            //NSLog(@"review NMXKeyFrameRunStatusRunning/Paused");
            
            //mm    [keepAliveSwitch setOn:[appExecutive.defaults integerForKey: @"keepAlive"]];
            [self.atProgramEndControl setSelectedSegmentIndex:[appExecutive.defaults integerForKey: @"keepAlive"]];
            
            if (!self.appExecutive.is3P)
            {
                keepAliveView.hidden = NO;
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
        
        if (!(runStatusKeyFrame & NMXRunStatusRunning) &&
            !(runStatusKeyFrame & NMXRunStatusPaused) && !camClosed)
        {
            [self initKeyFrameValues];
        }
    }
    else
    {
        graph3P.hidden = YES;
        [self setupGraphViews];
    }
    
    if (self.appExecutive.is3P)
    {
        keepAliveView.hidden = YES;
        startTimerBtn.hidden = YES;
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
    
    [appExecutive.device setKeyFrameAbscissa:val1]; //15
    [appExecutive.device setKeyFrameAbscissa:val2]; //100
    [appExecutive.device setKeyFrameAbscissa:val3]; //250
    
    NSLog(@"val1: %f",(float)val1);
    NSLog(@"val2: %f",(float)val2);
    NSLog(@"val3: %f",(float)val3);
    
    NSLog(@"appExecutive.microstep1: %f",(float)appExecutive.microstep1);

    float conversionFactor = (float)appExecutive.microstep1 / 16;
    
    float startSlideOut = self.appExecutive.scaledStart3PSlideDistance * conversionFactor;
    float midSlideOut = self.appExecutive.scaledMid3PSlideDistance * conversionFactor;
    float endSlideOut = self.appExecutive.scaledEnd3PSlideDistance * conversionFactor;
    
    [appExecutive.device setKeyFramePosition:startSlideOut];
    [appExecutive.device setKeyFramePosition:midSlideOut];
    [appExecutive.device setKeyFramePosition:endSlideOut];
    
    [appExecutive.device setKeyFrameVelocity:(float)0];
    [appExecutive.device setKeyFrameVelocity:(float)0];
    [appExecutive.device setKeyFrameVelocity:(float)0];
    
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
    
    [appExecutive.device setKeyFramePosition:startPanOut];
    [appExecutive.device setKeyFramePosition:midPanOut];
    [appExecutive.device setKeyFramePosition:endPanOut];
    
    [appExecutive.device setKeyFrameVelocity:(float)0];
    [appExecutive.device setKeyFrameVelocity:(float)0];
    [appExecutive.device setKeyFrameVelocity:(float)0];
    
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
    
    [appExecutive.device setKeyFramePosition:startTiltOut];
    [appExecutive.device setKeyFramePosition:midTiltOut];
    [appExecutive.device setKeyFramePosition:endTiltOut];
    
    [appExecutive.device setKeyFrameVelocity:(float)0];
    [appExecutive.device setKeyFrameVelocity:(float)0];
    [appExecutive.device setKeyFrameVelocity:(float)0];
    
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

    if (runStatus & NMXRunStatusRunning)
    {
        [self transitionToState: ControllerStatePauseProgram];
    }
    else if (runStatus & NMXRunStatusPaused)
    {
        [self transitionToState: ControllerStateResumeOrStopProgram];
    }
    else if (runStatus == NMXRunStatusStopped)
    {
        [self transitionToState: ControllerStateMotorRampingOrSendMotors];
    }
}

- (void) viewWillDisappear:(BOOL)animated {
    
    NSLog(@"viewWillDisappear");
    
    [self.disconnectedTimer invalidate];

    [super viewWillDisappear: animated];
    
    [[AppExecutive sharedInstance].deviceManager setDelegate: nil];
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
    
    keepAliveView.hidden = YES;
    
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

//mm
/*
- (IBAction) manageKeepAlive:(id)sender {
    
    //mm    [appExecutive.defaults setObject: [NSNumber numberWithInt:keepAliveSwitch.isOn] forKey: @"keepAlive"];
    [appExecutive.defaults setObject: [NSNumber numberWithLong:self.atProgramEndControl.selectedSegmentIndex] forKey: @"keepAlive"];
    [appExecutive.defaults synchronize];
    
     //NSLog(@"keepAlive setting: %ld",(long)[appExecutive.defaults integerForKey: @"keepAlive"]);
    
    [device keepAlive: keepAliveSwitch.isOn];
}
*/

- (IBAction)mangeAtProgramEndSelection:(id)sender {
    
    NSInteger atEndSelection = self.atProgramEndControl.selectedSegmentIndex;
    
    [appExecutive.defaults setObject: [NSNumber numberWithLong:atEndSelection] forKey: @"keepAlive"];
    [appExecutive.defaults synchronize];
    
    //NSLog(@"keepAlive setting: %ld",(long)[appExecutive.defaults integerForKey: @"keepAlive"]);
    
    //mm  [device keepAlive: atEndSelection==AtProgramEndKeepAlive];
    [device mainSetPingPongMode: atEndSelection==AtProgramEndPingPong];

}

- (IBAction) cancelTimer: (JoyButton *) sender {

    cancelBtn.hidden = YES;
    goBtn.hidden = YES;
    
    //[device setDelayProgramStartTimer:0];
    
    [self.statusTimer invalidate];
    self.statusTimer = nil;
    
    [[AppExecutive sharedInstance].device mainStopPlannedMove];
    
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
    
    [[AppExecutive sharedInstance].device mainStopPlannedMove];
    
    [device setDelayProgramStartTimer:0];
    
    [NSTimer scheduledTimerWithTimeInterval:0.150 target:self selector:@selector(removeDelayTimer) userInfo:nil repeats:NO];
}

- (void) removeDelayTimer {
	
    [[AppExecutive sharedInstance].device mainStartPlannedMove];
    
    if (!self.appExecutive.is3P)
    {
        keepAliveView.hidden = NO;
    }
    
    [self transitionToPauseProgramState];
}

- (IBAction) handleMotorRampingButton: (JoyButton *) sender {

	DDLogDebug(@"Motor Ramping Button");
}

- (IBAction) handleSendMotorsToStartButton: (JoyButton *) sender {
    
	//DDLogDebug(@"Send Motors To Start Button");
    
    //NSLog(@"keepAlive 0");
    
    [appExecutive.defaults setObject: [NSNumber numberWithInt:0] forKey: @"keepAlive"];
    [appExecutive.defaults synchronize];
    
    [device mainSendMotorsToStart];
    
    NSLog(@"send motors");

	[self transitionToState: ControllerStateMotorRampingOrStartProgram];
    
    playhead.frame = origPlayheadPosition;
}

- (IBAction) handleStartProgramButton: (JoyButton *) sender {
    
	DDLogDebug(@"Start Program Button");

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
        [[AppExecutive sharedInstance].device startKeyFrameProgram];
        
        [self startKeyframeTimer];
        
        //NSLog(@"resume keyframe pause");
    }
    else
    {
        [[AppExecutive sharedInstance].device mainStartPlannedMove];
    }
}

- (IBAction) handleStopProgramButton: (JoyButton *) sender {
    
	DDLogDebug(@"Stop Program Button");
    
    [device keepAlive:0];
    [device mainSetPingPongMode: NO];
    //mm [keepAliveSwitch setOn:NO animated:NO];
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
    }
    
    [self clearFields];
}

- (IBAction) handleReconnect:(id)sender {
    
    [AppExecutive sharedInstance].device.delegate = self;
    [[AppExecutive sharedInstance].device connect];
    
    [self.disconnectedTimer invalidate];
    
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
    
    if (!self.appExecutive.is3P)
    {
        keepAliveView.hidden = NO;
    }
    
    [self setupAfterConnection];
}

- (void) didDisconnectDevice: (CBPeripheral *) peripheral {
    
    DDLogDebug(@"Did Disconnect Device");
    
    disconnectStatusLbl.text = @"Did Disconnect Device Init";
    
//    [appExecutive.defaults setObject: @"yes" forKey: @"didDisconnect"];
//    [appExecutive.defaults synchronize];
    
    [appExecutive.defaults setObject: appExecutive.device.name forKey: @"deviceName"];
    [appExecutive.defaults synchronize];

    dispatch_async(dispatch_get_main_queue(), ^(void) {
        
        [keyframeTimer invalidate];
        
        self.statusTimer = nil;
        self.confirmPauseTimer = nil;
        [self hideStateButtons];
        
        [self.reconnectButton setHidden: false];
        [self.disconnectedLabel setHidden: false];
        keepAliveView.hidden = YES;
        
        self.disconnectedTimer = [NSTimer scheduledTimerWithTimeInterval: 1.0
                                                                  target: self
                                                                selector: @selector(handleDisconnectedTimer:)
                                                                userInfo: nil
                                                                 repeats: YES];
    });
}

- (void) handleDisconnectedTimer: (NSTimer *) sender {
    
    count++;
    
    time_t  currentTime = time(nil);
    UInt32  currentRunTime = self.lastRunTime + ((UInt32)(currentTime - self.timeOfLastRunTime) * 1000);
    float percentComplete =  currentRunTime / (float)self.totalRunTime;
    
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
        
        [self.reconnectButton setHidden: false];
        [self.disconnectedLabel setHidden: false];
        
        self.disconnectedTimer = [NSTimer scheduledTimerWithTimeInterval: 1.0
                                                                  target: self
                                                                selector: @selector(handleDisconnectedTimer:)
                                                                userInfo: nil
                                                                 repeats: YES];
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
        
        self.startProgramButton.enabled = YES;
        
        if (!self.appExecutive.is3P)
        {
            startTimerBtn.hidden = NO;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        });
    }
}

- (void) handleKeyFrameStatusTimer: (NSTimer *) sender {
    
    NMXRunStatus runStatus = [device queryKeyFrameProgramRunState];
    
    if (runStatus & NMXRunStatusRunning)
    {
        timerContainer.hidden = YES;
        
        //NSLog(@"NMXKeyFrameRunStatusRunning");
        
        float percentComplete = [device queryKeyFramePercentComplete] / (float)100;
        self.lastRunTime = [device queryKeyFrameProgramCurrentTime];
        
        //NSLog(@"lastRunTime: %i",(unsigned int)self.lastRunTime);
        //NSLog(@"keyFrame percentComplete: %f",percentComplete);
        
        self.timeOfLastRunTime = time(nil);
        
        NSInteger timeRemaining = self.totalRunTime - self.lastRunTime;
        
        if (timeRemaining < 0)
        {
            timeRemaining = 0;
        }
        
        if (NMXProgramModeVideo == self.programMode)
        {
            self.videoProgressView.progress = percentComplete;
            self.videoTimeRemainingValueLabel.text = [DurationViewController stringForDuration: timeRemaining];
            
            float percentComplete2 = (float)self.lastRunTime/self.totalRunTime;
            
            NSLog(@"keyframe video percentComplete2: %f",percentComplete2);
            
            if(percentComplete <= 1.0)
            {
                percentCompletePosition = (graphWidth * percentComplete2) * screenRatio;
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
            
            float percentComplete2 = [framesShotValueLabel.text intValue]/masterFrameCount;
            
            NSLog(@"keyframe percentComplete: %f",percentComplete2);
            
            if(percentComplete2 <= 1.0)
            {
                percentCompletePosition = (graphWidth * percentComplete2) * screenRatio;
            }
            
            NSLog(@"keyframe percentCompletePosition: %f",percentCompletePosition);
            
            playhead.frame = CGRectMake(percentCompletePosition,
                                        playhead.frame.origin.y,
                                        playhead.frame.size.width,
                                        playhead.frame.size.height);
        }
    }
    else if (runStatus & NMXRunStatusPaused)
    {
        NSLog(@"handleStatusTimer runStatus: NMXRunStatusPaused");
    }
    else if (runStatus == NMXRunStatusStopped)
    {
        NSLog(@"handleStatusTimer runStatus: NMXRunStatusStopped");
        
        [keyframeTimer invalidate];
        keyframeTimer = nil;
        
        [self clearFields];
        [self transitionToState: ControllerStateMotorRampingOrSendMotors];
        
    }
    else if (runStatus & NMXRunStatusDelayTimer)
    {
        self.totalRunTime = [device queryKeyFrameProgramMaxTime];
        
        self.lastRunTime = [device queryKeyFrameProgramCurrentTime];
        
        int	wholeseconds3	= (int)self.lastRunTime / 1000;
        int	hours3			= wholeseconds3 / 3600;
        int	minutes3		= (wholeseconds3 % 3600) / 60;
        int	seconds3		= wholeseconds3 % 60;
        
        NSLog(@"NMXRunStatusDelayTimer Status lastRunTime: %02ld:%02ld:%02ld", (long)hours3, (long)minutes3, (long)seconds3);
        
        self.timeOfLastRunTime = time(nil);
        
        NSInteger timeRemaining = self.totalRunTime - self.lastRunTime;
        
        NSLog(@"NMXRunStatusDelayTimer Status timeRemaining: %li",(long)timeRemaining);
        
        int currentDelayTime = [device queryDelayTime];
        
        NSLog(@"NMXRunStatusDelayTimer Status currentDelayTime: %i",currentDelayTime);
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
    else
    {
        NSLog(@"something else");
    }
}

- (void) handleStatusTimer: (NSTimer *) sender {
    
    NMXRunStatus runStatus = [device mainQueryRunStatus];
    
    if (runStatus & NMXRunStatusPaused) {
        NSLog(@"handleStatusTimer runStatus: NMXRunStatusPaused");
            
        // This state should only happen from the user hitting pause, and we already handle that transition...
    }
    else if (runStatus == NMXRunStatusStopped) {
        NSLog(@"handleStatusTimer runStatus: NMXRunStatusStopped");
        
        // Due to a firmware bug.  We want to make sure we are really stopped...
        
        runStatus = [device mainQueryRunStatus];
        
        if (NMXRunStatusStopped == runStatus)
        {
            [self.statusTimer invalidate];
            self.statusTimer = nil;
            
            [self clearFields];
            [self transitionToState: ControllerStateMotorRampingOrSendMotors];
        }
        else
        {
            DDLogWarn(@"Saw a FAKE stopped response");
        }
    }
    else if (runStatus & NMXRunStatusDelayTimer) {
        
        self.totalRunTime = [device mainQueryTotalRunTime];
        
        //NSLog(@"NMXRunStatusDelayTimer totalRunTime: %i",self.totalRunTime);
        
        self.lastRunTime = [device mainQueryRunTime];
        
        //NSLog(@"NMXRunStatusDelayTimer lastRunTime: %i",self.lastRunTime);
        
        int	wholeseconds3	= (int)self.lastRunTime / 1000;
        int	hours3			= wholeseconds3 / 3600;
        int	minutes3			= (wholeseconds3 % 3600) / 60;
        int	seconds3			= wholeseconds3 % 60;
        
        NSLog(@"NMXRunStatusDelayTimer Status lastRunTime: %02ld:%02ld:%02ld", (long)hours3, (long)minutes3, (long)seconds3);
        
        self.timeOfLastRunTime = time(nil);
        
        NSInteger timeRemaining = self.totalRunTime - self.lastRunTime;
        
        NSLog(@"NMXRunStatusDelayTimer Status timeRemaining: %li",(long)timeRemaining);
        
        int currentDelayTime = [device queryDelayTime];
        
        NSLog(@"NMXRunStatusDelayTimer Status currentDelayTime: %i",currentDelayTime);
        
    }
    else if (runStatus & NMXRunStatusKeepAlive) {
        NSLog(@"keep alive");
            
        unsigned int framesShot = [device cameraQueryCurrentShots];
        
        UInt32  videoLength = framesShot * 1000 / self.fps;
        
        self.framesShotValueLabel.text = [NSString stringWithFormat: @"%d", framesShot];
        self.videoLengthValueLabel.text = [ShortDurationViewController stringForShortDuration: videoLength];
        self.timelapseTimeRemainingValueLabel.text = @"-";
        
        float percentComplete2 = [framesShotValueLabel.text intValue]/masterFrameCount;
        
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
            
        NSLog(@"NMXRunStatusRunning");
            
        float percentComplete = [device mainQueryProgramPercentComplete] / (float)100;
        self.lastRunTime = [device mainQueryRunTime];
        self.timeOfLastRunTime = time(nil);
        
        NSInteger timeRemaining = self.totalRunTime - self.lastRunTime;
        
        if (timeRemaining < 0)
        {
            timeRemaining = 0;
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
            
            float percentComplete2 = (float)self.lastRunTime/self.totalRunTime;
            
            NSLog(@"percentComplete2 orig: %f",percentComplete2);
            
            if(percentComplete <= 1.0)
            {
                //percentCompletePosition = (graphWidth * percentComplete)*screenRatio;
                percentCompletePosition = (graphWidth * percentComplete2)*screenRatio;
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
            
            NSLog(@"percentComplete per device: %f",percentComplete);
            
            float percentComplete2 = [framesShotValueLabel.text intValue]/masterFrameCount;
            
            NSLog(@"percentComplete2 orig: %f",percentComplete2);
            
            if(percentComplete2 <= 1.0)
            {
                percentCompletePosition = (graphWidth * percentComplete2) * screenRatio;
            }
            
            
            NSLog(@"**********  Runtime = %u   Total runtime = %u", [device mainQueryRunTime], [device mainQueryTotalRunTime]);
            
            //NSLog(@"percentCompletePosition orig: %f",percentCompletePosition);
            
            playhead.frame = CGRectMake(percentCompletePosition,
                                        playhead.frame.origin.y,
                                        playhead.frame.size.width,
                                        playhead.frame.size.height);
        }

    }
    else {
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
