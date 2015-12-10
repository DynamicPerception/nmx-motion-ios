//
//  ViewController.m
//  joystick
//
//  Created by Mark Zykin on 10/1/14.
//  Copyright (c) 2014 Dynamic Perception. All rights reserved.
//

#import <CocoaLumberjack/CocoaLumberjack.h>

#import "MainViewController.h"
#import "SetupViewController.h"
#import "MotorSettingsViewController.h"
#import "AppExecutive.h"
#import "AppDelegate.h"
#import "JoyButton.h"
#import "MBProgressHUD.h"

#define kCurrentFirmwareVersion 44

//------------------------------------------------------------------------------

#pragma mark - Private Interface


@interface MainViewController ()

@property (nonatomic, strong)				AppExecutive *				appExecutive;
@property (nonatomic, strong)				SetupViewController *		setupViewController;

@property (nonatomic, strong)				JoystickViewController *	joystickViewController;

@property (nonatomic, strong)	IBOutlet	JoyButton *					slideButton;
@property (nonatomic, strong)	IBOutlet	JoyButton *					panButton;
@property (nonatomic, strong)	IBOutlet	JoyButton *					tiltButton;
@property (nonatomic, strong)	IBOutlet	JoyButton *					setStartButton;
@property (nonatomic, strong)	IBOutlet	JoyButton *					setStopButton;
@property (nonatomic, strong)	IBOutlet	JoyButton *					flipButton;
@property (nonatomic, strong)	IBOutlet	JoyButton *					nextButton;
@property (nonatomic, strong)	IBOutlet	JoyButton *					fireCameraButton;

@property (nonatomic, retain)	IBOutlet	UISlider *					_dollySlider;
@property (nonatomic, strong)	IBOutlet	UIButton *					settingsButton;
@property (nonatomic, strong)	IBOutlet	UIImageView *				lockAxisIcon;

@property (nonatomic, readonly)				BOOL						lockAxisState;
@property (nonatomic, readonly)				CGFloat						sensitivity;

@property (nonatomic, strong)   IBOutlet    UILabel *                   deviceName;	// TODO: dead code?

@property (nonatomic, strong)               NSTimer *                   controlsTimer;
@property (nonatomic, strong)               NSTimer *                   joystickTimer;

@property (assign)                          bool                        joystickModeActive;
@property (assign)                          bool                        showingModalScreen;
@property (weak, nonatomic)     IBOutlet    UIImageView *image3P;

@end

//------------------------------------------------------------------------------

#pragma mark - Implementation


@implementation MainViewController

#pragma mark Static Variables

NSString static	*SegueToSlideMotorSettingsViewController	= @"SegueToSlideMotorSettingsViewController";
NSString static	*SegueToPanMotorSettingsViewController		= @"SegueToPanMotorSettingsViewController";
NSString static	*SegueToTiltMotorSettingsViewController		= @"SegueToTiltMotorSettingsViewController";
NSString static	*SegueToSetupViewController					= @"SegueToSetupViewController";
NSString static	*EmbedJoystickViewController				= @"EmbedJoystickViewController";


#pragma mark Public Property Synthesis

#pragma mark Private Property Synthesis

@synthesize appExecutive;
@synthesize setupViewController;

@synthesize joystickViewController;

@synthesize slideButton;
@synthesize panButton;
@synthesize tiltButton;

@synthesize _dollySlider;
@synthesize settingsButton;
@synthesize lockAxisIcon;
@synthesize setStartButton;
@synthesize setStopButton;
@synthesize nextButton;
@synthesize fireCameraButton;

@synthesize lockAxisState;
@synthesize sensitivity;

@synthesize distancePanLbl,distanceSlideLbl,distanceTiltLbl,trList,trView,brView,brList,tlList,tlView,blList,blView,trList2,tlList2,brList2,blList2,mode3PLbl,uiList,flipButton,image3P,mode3PLbl2,switch2P,joystickViefw,panSliderBG,panSlider,panSliderLbl,tiltSliderBG,tiltSlider,tiltSliderLbl,batteryIcon,ar1,ar2,ar3,setStartView,setStopView,setMid1Btn,setMidView,controlBackground;


#pragma mark Public Property Methods

#pragma mark Private Property Methods

- (AppExecutive *) appExecutive {

	if (appExecutive == nil)
		appExecutive = [AppExecutive sharedInstance];

	return appExecutive;
}

- (BOOL) lockAxisState {

	return [self.appExecutive.lockAxisNumber boolValue];
}

- (CGFloat) sensitivity {

	return [self.appExecutive.sensitivityNumber floatValue];
}

@synthesize dominantAxisSwitch;

//------------------------------------------------------------------------------

#pragma mark - Object Management

- (void) viewDidLoad {
    
    [[NSUserDefaults standardUserDefaults] setValue:@(NO) forKey:@"_UIConstraintBasedLayoutLogUnsatisfiable"];

    self.appExecutive.device.delegate = self;
    [self.appExecutive.device connect];

    self.joystickModeActive = false;
    self.showingModalScreen = false;

	self.setStartButton.selected = NO;
	self.setStopButton.selected = NO;
	self.nextButton.selected = NO;
	self.fireCameraButton.selected = NO;
    
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    slideButton.layer.borderWidth = 1.0;
    slideButton.layer.borderColor = [appDelegate.appBlue CGColor];
    
    panButton.layer.borderWidth = 1.0;
    panButton.layer.borderColor = [appDelegate.appBlue CGColor];
    
    tiltButton.layer.borderWidth = 1.0;
    tiltButton.layer.borderColor = [appDelegate.appBlue CGColor];
    
    setStartButton.layer.borderWidth = 1.0;
    setStartButton.layer.borderColor = [appDelegate.appBlue CGColor];
    
    setStopButton.layer.borderWidth = 1.0;
    setStopButton.layer.borderColor = [appDelegate.appBlue CGColor];
    
    flipButton.layer.borderWidth = 1.0;
    flipButton.layer.borderColor = [appDelegate.appBlue CGColor];
    
    distanceSlideLbl.alpha = 0;
    distancePanLbl.alpha = 0;
    distanceTiltLbl.alpha = 0;
    
    setStartView.alpha = 0;
    setMidView.alpha = 0;
    setStopView.alpha = 0;
    
    slideGear = 19.2032;
    panGear = 19.2032;
    tiltGear = 19.2032;
    
    slideLinearCustom = 0.00;
    panLinearCustom = 0.00;
    tiltLinearCustom = 0.00;
    
    slideDirection = @"CCW";
    panDirection = @"CCW";
    tiltDirection = @"CCW";
    
    slideRig = @"Stage 1/0";
    panRig = @"Stage R";
    tiltRig = @"Stage R";
    
    int a = (int)[self.appExecutive.defaults integerForKey:@"slideMotor"];
    int b = (int)[self.appExecutive.defaults integerForKey:@"panMotor"];
    int c = (int)[self.appExecutive.defaults integerForKey:@"tiltMotor"];
    
    float d = [self.appExecutive.defaults floatForKey:@"slideMotorCustomValue"];//slideLinearCustom = 0.00;
    float e = [self.appExecutive.defaults floatForKey:@"panMotorCustomValue"];//panLinearCustom = 0.00;
    float f = [self.appExecutive.defaults floatForKey:@"tiltMotorCustomValue"];//tiltLinearCustom = 0.00;
    
    NSLog(@"motors a: %i",a);
    NSLog(@"b: %i",b);
    NSLog(@"c: %i",c);
    
    NSLog(@"d: %f",d);
    NSLog(@"e: %f",e);
    NSLog(@"f: %f",f);
    
    if([appExecutive.defaults objectForKey:@"slideMotor"] != nil)
    {
        if (a == 1)
        {
             slideRig = @"Stage 1/0";
        }
        else if (a == 2)
        {
            slideRig = @"Stage R";
        }
        else if (a == 3)
        {
            slideRig = @"Linear Custom";
            slideLinearCustom = d;
        }
    }
    
    if([appExecutive.defaults objectForKey:@"panMotor"] != nil)
    {
        if (b == 1)
        {
            panRig = @"Stage 1/0";
        }
        else if (b == 2)
        {
            panRig = @"Stage R";
        }
        else if (b == 3)
        {
            panRig = @"Linear Custom";
            panLinearCustom = e;
        }
    }
    
    if([appExecutive.defaults objectForKey:@"tiltMotor"] != nil)
    {
        if (c == 1)
        {
            tiltRig = @"Stage 1/0";
        }
        else if (c == 2)
        {
            tiltRig = @"Stage R";
        }
        else if (c == 3) {
            
            tiltRig = @"Linear Custom";
            tiltLinearCustom = f;
        }
    }
    
    if([appExecutive.defaults objectForKey:@"slideDirection"] != nil)
    {
        slideDirection = [appExecutive.defaults objectForKey:@"slideDirection"] ;
    }
    
    if([appExecutive.defaults objectForKey:@"panDirection"] != nil)
    {
        panDirection = [appExecutive.defaults objectForKey:@"panDirection"] ;
    }
    
    if([appExecutive.defaults objectForKey:@"tiltDirection"] != nil)
    {
        tiltDirection = [appExecutive.defaults objectForKey:@"tiltDirection"];
    }
    
//    float fc = [self.appExecutive.frameCountNumber floatValue];
//    
//    NSLog(@"fc: %f",fc);
//    
//    float range1 = [self.appExecutive.frameCountNumber floatValue] * .33;
//    float range2 = [self.appExecutive.frameCountNumber floatValue] * .75 - range1;
//    float range3 = [self.appExecutive.frameCountNumber floatValue] - range2;
//    
//    
//    NSLog(@"range1: %.02f",range1);
//    NSLog(@"range2: %.02f",range2);
//    NSLog(@"range3: %.02f",range3);
//    
//    float per1 = (float)3/range1;
//    float per2 = (float)3/range2;
//    float per3 = (float)3/range3;
//    
//    NSLog(@"per1: %.02f",per1);
//    NSLog(@"per2: %.02f",per2);
//    NSLog(@"per3: %.02f",per3);
    
    if ([self.appExecutive.defaults integerForKey:@"useJoystick"] == 2)
    {
        NSLog(@"dont use joystick1");
        
        self.appExecutive.useJoystick = NO;
        [self.appExecutive.defaults setObject: [NSNumber numberWithInt:2] forKey: @"useJoystick"];
        
        //self.appExecutive.useJoystick = [self.appExecutive.defaults integerForKey:@"useJoystick"];
    }
    else
    {
        NSLog(@"use joystick1");
        
//        [self.appExecutive.defaults setObject: [NSNumber numberWithInt:1] forKey: @"useJoystick"];
//        [self.appExecutive.defaults synchronize];
        
        self.appExecutive.useJoystick = YES;
        [self.appExecutive.defaults setObject: [NSNumber numberWithInt:1] forKey: @"useJoystick"];
    }
    
    [self.appExecutive.defaults synchronize];
    
    if (self.appExecutive.useJoystick == NO)
    {
        joystickViefw.hidden = YES;
        
        panSliderBG.hidden = NO;
        panSlider.hidden = NO;
        panSliderLbl.hidden = NO;
        tiltSliderBG.hidden = NO;
        tiltSlider.hidden = NO;
        tiltSliderLbl.hidden = NO;
    }
    else
    {
        joystickViefw.hidden = NO;
        
        panSliderBG.hidden = YES;
        panSlider.hidden = YES;
        panSliderLbl.hidden = YES;
        tiltSliderBG.hidden = YES;
        tiltSlider.hidden = YES;
        tiltSliderLbl.hidden = YES;
    }
    
    [NSTimer scheduledTimerWithTimeInterval:0.500 target:self selector:@selector(timerName4) userInfo:nil repeats:NO];
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(handleNotificationJSMode:)
     name:@"enterJSMode" object:nil];
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(handleNotificationExitJSMode:)
     name:@"exitJSMode" object:nil];
    
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideButtonViews)];
    [controlBackground addGestureRecognizer:gestureRecognizer];
    gestureRecognizer.cancelsTouchesInView = NO;
    
    [super viewDidLoad];
}

- (void)hideButtonViews {

    [UIView animateWithDuration:.4 animations:^{
        
        setStartView.alpha = 0;
        setMidView.alpha = 0;
        setStopView.alpha = 0;
        
    } completion:^(BOOL finished) {
        
    }];
}

- (void) timerName4 {
	
    //NSLog(@"vdl: %li",(long)[self.appExecutive.defaults integerForKey:@"is3P"]);
    
    if ([self.appExecutive.defaults integerForKey:@"is3P"] == 1)
    {
        self.appExecutive.is3P = YES;
        [switch2P setOn:YES];
        
        [self.flipButton setTitle:@"Set Mid" forState:UIControlStateNormal];
        mode3PLbl.text = @"3P";
        mode3PLbl2.text = @"3-Point Move";
        image3P.image = [UIImage imageNamed:@"3p.png"];
    }
    else
    {
        
    }
    
    #if TARGET_IPHONE_SIMULATOR
    
        [self showVoltage];
        
    #else
    
    #endif
}

- (void) timerName {
	
    //NSLog(@"frame: %f,%f %f x %f",brView.frame.origin.x, brView.frame.origin.y, brView.frame.size.width,brView.frame.size.height);
    
    for (int i = 0; i <= 3; i++)
    {
        UIImageView *trIV = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, trView.frame.size.width, trView.frame.size.height)];
        
        trIV.image = [trList objectAtIndex:i];
        
        [trView addSubview:trIV];
        [trList2 addObject:trIV];
        
        if (i != 0)
        {
            trIV.alpha = 0;
        }
    }
    
    for (int i = 0; i <= 3; i++)
    {
        UIImageView *tlIV = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, tlView.frame.size.width, tlView.frame.size.height)];
        
        tlIV.image = [tlList objectAtIndex:i];
        
        [tlView addSubview:tlIV];
        [tlList2 addObject:tlIV];
        
        if (i != 0)
        {
            tlIV.alpha = 0;
        }
    }
    
    for (int i = 0; i <= 3; i++)
    {
        UIImageView *blIV = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, blView.frame.size.width, blView.frame.size.height)];
        
        blIV.image = [blList objectAtIndex:i];
        
        [blView addSubview:blIV];
        [blList2 addObject:blIV];
        
        if (i != 0)
        {
            blIV.alpha = 0;
        }
    }
    
    //NSLog(@"blList2: %@",blList2);
    
    for (int i = 0; i <= 3; i++)
    {
        UIImageView *brIV = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, brView.frame.size.width, brView.frame.size.height)];
        
        brIV.image = [brList objectAtIndex:i];
        
        [brView addSubview:brIV];
        [brList2 addObject:brIV];
        
        if (i != 0)
        {
            brIV.alpha = 0;
        }
    }
    
    //NSLog(@"brList2: %@",brList2);

    //[self switchOnLights];
}

- (IBAction) manage2P:(id)sender {
    
    [self hideButtonViews];
    
    UISwitch *swe = sender;
    
    if (swe.isOn)
    {
        self.appExecutive.is3P = YES;
    }
    else
    {
        self.appExecutive.is3P = NO;
    }
    
    [UIView animateWithDuration:.4 animations:^{
        
        //mode3PLbl.alpha = 0;
        mode3PLbl2.alpha = 0;
        image3P.alpha = 0;
        
    } completion:^(BOOL finished) {
        
        if (swe.isOn)
        {
            [self.flipButton setTitle:@"Set Mid" forState:UIControlStateNormal];
            
            mode3PLbl.text = @"3P";
            mode3PLbl2.text = @"3-Point Move";
            image3P.image = [UIImage imageNamed:@"3p.png"];
            
            NSLog(@"self.appExecutive.mid3PSet: %li",(long)self.appExecutive.mid3PSet);
            
            if (self.appExecutive.mid3PSet == 2)
            {
                NSLog(@"turn mid on");
                
                self.flipButton.selected = YES;
            }
            else
            {
                self.flipButton.selected = NO;
            }
            
            [UIView animateWithDuration:.4 animations:^{
                
                distanceSlideLbl.alpha = 0;
                distancePanLbl.alpha = 0;
                distanceTiltLbl.alpha = 0;
                
            } completion:^(BOOL finished) {
                
            }];
        }
        else
        {
            [self.flipButton setTitle:@"Flip" forState:UIControlStateNormal];
            
            mode3PLbl.text = @"2P";
            mode3PLbl2.text = @"Two Point Move";
            image3P.image = [UIImage imageNamed:@"2p.png"];
            self.flipButton.selected = NO;
            
            if (start2pTotals != 0)
            {
                self.setStartButton.selected = YES;
            }
            
            if (end2pTotals != 0)
            {
                self.setStopButton.selected = YES;
            }
            
            if (start2pTotals != 0 && end2pTotals != 0) {
                
                [UIView animateWithDuration:.4 animations:^{
                    
                    distanceSlideLbl.alpha = 1;
                    distancePanLbl.alpha = 1;
                    distanceTiltLbl.alpha = 1;
                    
                } completion:^(BOOL finished) {
                    
                }];
            }
        }
        
        //mode3PLbl.alpha = 1;
        
    }];
    
    if (swe.isOn)
    {
        self.appExecutive.is3P = YES;
    }
    else
    {
        self.appExecutive.is3P = NO;
    }
    
    NSLog(@"appExecutive.is3P: %i",self.appExecutive.is3P);
    
    [self.appExecutive.defaults setObject: [NSNumber numberWithInt:self.appExecutive.is3P] forKey: @"is3P"];
    [self.appExecutive.defaults synchronize];
    
    NSLog(@"defaults is3P: %li",(long)[appExecutive.defaults integerForKey:@"is3P"]);
}

- (void) resetTimers {
    
    //NSLog(@"resetTimers");
	
    brInd = 0;
    blInd = 0;
    trInd = 0;
    tlInd = 0;
}

- (void) viewWillAppear: (BOOL) animated {
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(handleNotificationJSMode:)
     name:@"enterJSMode" object:nil];
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(handleNotificationExitJSMode:)
     name:@"exitJSMode" object:nil];

	[super viewWillAppear: animated];

    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(handleEnteredBackground:)
                                                 name: UIApplicationDidEnterBackgroundNotification
                                               object: nil];
    
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(handleBecomeActive:)
                                                 name: UIApplicationDidBecomeActiveNotification
                                               object: nil];
    
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(deviceDisconnect:)
                                                 name: kDeviceDisconnectedNotification
                                                object: nil];
    
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(handleUpdateLabelsNotification:)
                                                 name: @"updateLabels"
                                               object: nil];
    
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(handleUpdateBatteryViewNotification:)
                                                 name: @"updateBattery"
                                               object: nil];
    
    
	// gear icon for button

	[self.settingsButton setTitle: @"\u2699" forState: UIControlStateNormal];

	// lock axis icon
    
    self.lockAxisIcon.hidden = YES;

	//self.lockAxisIcon.hidden = self.lockAxisState == FALSE;
    
    dominantAxisSwitch.on = [self.appExecutive.lockAxisNumber boolValue];
    
    if (dominantAxisSwitch.on)
    {
        self.joystickViewController.axisLocked = YES;
    }
    else
    {
        self.joystickViewController.axisLocked = NO;
    }
    
    float ratio = .65;
    
    UIImage *a; // = [UIImage imageNamed:@"track-thumb.png"];
    
    //a = [UIImage imageNamed: @"slide-button.png"];
    //a = [UIImage imageNamed: @"white-thumb.png"];
    a = [UIImage imageNamed: @"white-joystick4.png"];
    
    UIImage *tt = [self imageWithImage:a scaledToSize:CGSizeMake(a.size.width * (ratio), a.size.height * (ratio))];
    
    UIImage *mint = [UIImage imageNamed:@"min-track3.png"];
    UIImage *max2 = [UIImage imageNamed:@"max-track3.png"];
    
//    mint = [self imageWithImage:mint scaledToSize:CGSizeMake(mint.size.width * ratio, mint.size.height * 2)];
//    max2 = [self imageWithImage:max2 scaledToSize:CGSizeMake(max2.size.width * ratio, max2.size.height * 2)];
    
    [_dollySlider setThumbImage:tt forState:UIControlStateNormal];
    [_dollySlider setMinimumTrackImage:mint forState:UIControlStateNormal];
    [_dollySlider setMinimumTrackImage:mint forState:UIControlStateDisabled];
    [_dollySlider setMaximumTrackImage:max2 forState:UIControlStateNormal];
    [_dollySlider setMaximumTrackImage:max2 forState:UIControlStateDisabled];
    
    [panSlider setThumbImage:tt forState:UIControlStateNormal];
    [panSlider setMinimumTrackImage:mint forState:UIControlStateNormal];
    [panSlider setMinimumTrackImage:mint forState:UIControlStateDisabled];
    [panSlider setMaximumTrackImage:max2 forState:UIControlStateNormal];
    [panSlider setMaximumTrackImage:max2 forState:UIControlStateDisabled];
    
    [tiltSlider setThumbImage:tt forState:UIControlStateNormal];
    [tiltSlider setMinimumTrackImage:mint forState:UIControlStateNormal];
    [tiltSlider setMinimumTrackImage:mint forState:UIControlStateDisabled];
    [tiltSlider setMaximumTrackImage:max2 forState:UIControlStateNormal];
    [tiltSlider setMaximumTrackImage:max2 forState:UIControlStateDisabled];
    
    slideButton.userInteractionEnabled = NO;
    panButton.userInteractionEnabled = NO;
    tiltButton.userInteractionEnabled = NO;
    
    [NSTimer scheduledTimerWithTimeInterval:0.500 target:self selector:@selector(enableInteractions) userInfo:nil repeats:NO];
}

- (void) enableInteractions {
	
    //NSLog(@"enable buttons");
    
    slideButton.userInteractionEnabled = YES;
    panButton.userInteractionEnabled = YES;
    tiltButton.userInteractionEnabled = YES;
}

- (UIImage *) imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize {
    
    //UIGraphicsBeginImageContext(newSize);
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

- (void) viewDidAppear: (BOOL) animated {
    
    //NSLog(@"didappear self.appExecutive.useJoystick: %i",self.appExecutive.useJoystick);
    
    if (self.appExecutive.useJoystick == NO)
    {
        joystickViefw.hidden = YES;
        
        panSliderBG.hidden = NO;
        panSlider.hidden = NO;
        panSliderLbl.hidden = NO;
        tiltSliderBG.hidden = NO;
        tiltSlider.hidden = NO;
        tiltSliderLbl.hidden = NO;
    }
    else
    {
        joystickViefw.hidden = NO;
        
        panSliderBG.hidden = YES;
        panSlider.hidden = YES;
        panSliderLbl.hidden = YES;
        tiltSliderBG.hidden = YES;
        tiltSlider.hidden = YES;
        tiltSliderLbl.hidden = YES;
    }

    startEndTotal =
        appExecutive.startPoint1 + appExecutive.endPoint1 +
        appExecutive.startPoint2 + appExecutive.endPoint2 +
        appExecutive.startPoint3 + appExecutive.endPoint3;
    
    startTotals = self.appExecutive.start3PSlideDistance +
    self.appExecutive.start3PPanDistance +
    self.appExecutive.start3PTiltDistance;
    
    midTotals = self.appExecutive.mid3PSlideDistance +
    self.appExecutive.mid3PPanDistance +
    self.appExecutive.mid3PTiltDistance;
    
    endTotals = self.appExecutive.end3PSlideDistance +
    self.appExecutive.end3PPanDistance +
    self.appExecutive.end3PTiltDistance;
    
    if (self.appExecutive.is3P == NO)
    {
        NSLog(@"startEndTotal: %i",startEndTotal);
        
        if (start2pTotals != 0) {
            
            self.setStartButton.selected = YES;
        }
        
        if (end2pTotals != 0) {
            
            self.setStopButton.selected = YES;
        }
        
    }
    else if (self.appExecutive.is3P == YES)
    {
        if (startTotals != 0 )
        {
            self.setStartButton.selected = YES;
        }
        
        if (midTotals != 0 )
        {
            self.flipButton.selected = YES;
        }
        
        if (endTotals != 0 )
        {
            self.setStopButton.selected = YES;
        }
    }
    
	[super viewDidAppear: animated];
    
	// Debug code to bypass main screen

	if (getenv("GOTO_SETUP"))
	{
		[self performSegueWithIdentifier: SegueToSetupViewController sender: self];
	}
    
    if (self.showingModalScreen)
    {
        [self enterJoystickMode];
        
        [NSTimer scheduledTimerWithTimeInterval:0.100 target:self selector:@selector(doubleEnterJoystickTimer) userInfo:nil repeats:NO];
        
        self.showingModalScreen = false;
    }
}

- (void) doubleEnterJoystickTimer{
    
    [self enterJoystickMode];
}

- (void) startStopQueryTimer {
    
    [self exitJoystickMode];
    
    //[appExecutive setPoints];
    
    appExecutive.microstep1 = [appExecutive.device motorQueryMicrostep: 1] * 200;
    appExecutive.microstep2 = [appExecutive.device motorQueryMicrostep: 2] * 200;
    appExecutive.microstep3 = [appExecutive.device motorQueryMicrostep: 3] * 200;
    
    self.appExecutive.startPoint1 = [self.appExecutive.device queryProgramStartPoint:1];
    self.appExecutive.endPoint1 = [self.appExecutive.device queryProgramEndPoint:1];
    
    NSLog(@"mvc startPoint1: %i",self.appExecutive.startPoint1);
    NSLog(@"mvc endPoint1: %i",self.appExecutive.endPoint1);
    
    self.appExecutive.startPoint2 = [self.appExecutive.device queryProgramStartPoint:2];
    self.appExecutive.endPoint2 = [self.appExecutive.device queryProgramEndPoint:2];
    
    NSLog(@"mvc startPoint2: %i",self.appExecutive.startPoint2);
    NSLog(@"mvc endPoint2: %i",self.appExecutive.endPoint2);
    
    self.appExecutive.startPoint3 = [self.appExecutive.device queryProgramStartPoint:3];
    self.appExecutive.endPoint3 = [self.appExecutive.device queryProgramEndPoint:3];
    
    NSLog(@"mvc startPoint3: %i",self.appExecutive.startPoint3);
    NSLog(@"mvc endPoint3: %i",self.appExecutive.endPoint3);
    
    start2pTotals = appExecutive.startPoint1 + appExecutive.startPoint2 + appExecutive.startPoint3;
    end2pTotals = appExecutive.endPoint1 + appExecutive.endPoint2 + appExecutive.endPoint3;
    
    startEndTotal =
    appExecutive.startPoint1 + appExecutive.endPoint1 +
    appExecutive.startPoint2 + appExecutive.endPoint2 +
    appExecutive.startPoint3 + appExecutive.endPoint3;
    
    self.appExecutive.microstep1 = [self.appExecutive.device motorQueryMicrostep2:1];
    self.appExecutive.microstep2 = [self.appExecutive.device motorQueryMicrostep2:2];
    self.appExecutive.microstep3 = [self.appExecutive.device motorQueryMicrostep2:3];
    
//    NSLog(@"self.appExecutive.microstep1: %f",(float)self.appExecutive.microstep1);
//    NSLog(@"self.appExecutive.microstep2: %f",(float)self.appExecutive.microstep2);
//    NSLog(@"self.appExecutive.microstep3: %f",(float)self.appExecutive.microstep3);
    
    bool pc = [self.appExecutive.device queryPowerCycle];
    
    //NSLog(@"pc: %i", pc);
    
    NSString *storedDevice = [self.appExecutive.defaults stringForKey:@"deviceName"];
    
    bool isSameDevice = [self.appExecutive.device.name isEqualToString:storedDevice];
    
    if (pc == 0 && isSameDevice == YES)
    {
        NSLog(@"startEndTotal 2: %i",startEndTotal);
        
        //NSLog(@"didload is3P: %i",[appExecutive.defaults integerForKey:@"is3P"]);
        
//        NSLog(@"start3PSet: %li", (long)[appExecutive.defaults integerForKey:@"start3PSet"]);
//        NSLog(@"mid3PSet: %li", (long)[appExecutive.defaults integerForKey:@"mid3PSet"]);
//        NSLog(@"end3PSet: %li", (long)[appExecutive.defaults integerForKey:@"end3PSet"]);
        
        if (self.appExecutive.is3P == YES) {
            
            if ([self.appExecutive.defaults integerForKey:@"start3PSet"] == 2)
            {
                self.setStartButton.selected = YES;
                self.appExecutive.start3PSet = 2;
            }
            
            if ([self.appExecutive.defaults integerForKey:@"end3PSet"] == 2)
            {
                self.setStopButton.selected = YES;
                self.appExecutive.end3PSet = 2;
            }
            
            if ([self.appExecutive.defaults integerForKey:@"mid3PSet"] == 2)
            {
                self.appExecutive.mid3PSet = 2;
            }
        }
        
        //NSLog(@"start3PSlideDistance: %f", [appExecutive.defaults floatForKey:@"start3PSlideDistance"]);
        
        self.appExecutive.start3PSlideDistance = [appExecutive.defaults floatForKey:@"start3PSlideDistance"];
        self.appExecutive.start3PPanDistance = [appExecutive.defaults floatForKey:@"start3PPanDistance"];
        self.appExecutive.start3PTiltDistance = [appExecutive.defaults floatForKey:@"start3PTiltDistance"];
        
        self.appExecutive.mid3PSlideDistance = [appExecutive.defaults floatForKey:@"mid3PSlideDistance"];
        self.appExecutive.mid3PPanDistance = [appExecutive.defaults floatForKey:@"mid3PPanDistance"];
        self.appExecutive.mid3PTiltDistance = [appExecutive.defaults floatForKey:@"mid3PTiltDistance"];
        
        self.appExecutive.end3PSlideDistance = [appExecutive.defaults floatForKey:@"end3PSlideDistance"];
        self.appExecutive.end3PPanDistance = [appExecutive.defaults floatForKey:@"end3PPanDistance"];
        self.appExecutive.end3PTiltDistance = [appExecutive.defaults floatForKey:@"end3PTiltDistance"];
        
//        NSLog(@"start3PSlideDistance: %f",self.appExecutive.start3PSlideDistance);
//        NSLog(@"start3PPanDistance: %f",self.appExecutive.start3PPanDistance);
//        NSLog(@"start3PTiltDistance: %f",self.appExecutive.start3PTiltDistance);
//        
//        NSLog(@"mid3PSlideDistance: %f",self.appExecutive.mid3PSlideDistance);
//        NSLog(@"mid3PPanDistance: %f",self.appExecutive.mid3PPanDistance);
//        NSLog(@"mid3PTiltDistance: %f",self.appExecutive.mid3PTiltDistance);
//        
//        NSLog(@"end3PSlideDistance: %f",self.appExecutive.end3PSlideDistance);
//        NSLog(@"end3PPanDistance: %f",self.appExecutive.end3PPanDistance);
//        NSLog(@"end3PTiltDistance: %f",self.appExecutive.end3PTiltDistance);
        
        startTotals = self.appExecutive.start3PSlideDistance +
        self.appExecutive.start3PPanDistance +
        self.appExecutive.start3PTiltDistance;
        
        midTotals = self.appExecutive.mid3PSlideDistance +
        self.appExecutive.mid3PPanDistance +
        self.appExecutive.mid3PTiltDistance;
        
        endTotals = self.appExecutive.end3PSlideDistance +
        self.appExecutive.end3PPanDistance +
        self.appExecutive.end3PTiltDistance;
        
//        NSLog(@"3P startTotals: %i", startTotals);
//        NSLog(@"3P midTotals: %i", midTotals);
//        NSLog(@"3P endTotals: %i", endTotals);
        
//        [self.appExecutive.defaults setObject: [NSNumber numberWithFloat:8] forKey: @"saved3PMicro1"];
//        [self.appExecutive.defaults setObject: [NSNumber numberWithFloat:4] forKey: @"saved3PMicro2"];
//        [self.appExecutive.defaults setObject: [NSNumber numberWithFloat:16] forKey: @"saved3PMicro3"];
        
//        [self.appExecutive.defaults setObject: [NSNumber numberWithFloat:-3986.000000] forKey: @"scaledStart3PSlideDistance"];
//        [self.appExecutive.defaults setObject: [NSNumber numberWithFloat:5913472.000000] forKey: @"scaledStart3PPanDistance"];
//        [self.appExecutive.defaults setObject: [NSNumber numberWithFloat:-6918448.000000] forKey: @"scaledStart3PTiltDistance"];
//        
//        [self.appExecutive.defaults setObject: [NSNumber numberWithFloat:-8696.000000] forKey: @"scaledMid3PSlideDistance"];
//        [self.appExecutive.defaults setObject: [NSNumber numberWithFloat:5932160.000000] forKey: @"scaledMid3PPanDistance"];
//        [self.appExecutive.defaults setObject: [NSNumber numberWithFloat:-6921208.000000] forKey: @"scaledMid3PTiltDistance"];
//        
//        [self.appExecutive.defaults setObject: [NSNumber numberWithFloat:-16452.000000] forKey: @"scaledEnd3PSlideDistance"];
//        [self.appExecutive.defaults setObject: [NSNumber numberWithFloat:5955772.000000] forKey: @"scaledEnd3PPanDistance"];
//        [self.appExecutive.defaults setObject: [NSNumber numberWithFloat:-6923192.000000] forKey: @"scaledEnd3PTiltDistance"];
        
        self.appExecutive.scaledStart3PSlideDistance = [appExecutive.defaults floatForKey:@"scaledStart3PSlideDistance"];
        self.appExecutive.scaledStart3PPanDistance = [appExecutive.defaults floatForKey:@"scaledStart3PPanDistance"];
        self.appExecutive.scaledStart3PTiltDistance = [appExecutive.defaults floatForKey:@"scaledStart3PTiltDistance"];
        
        self.appExecutive.scaledMid3PSlideDistance = [appExecutive.defaults floatForKey:@"scaledMid3PSlideDistance"];
        self.appExecutive.scaledMid3PPanDistance = [appExecutive.defaults floatForKey:@"scaledMid3PPanDistance"];
        self.appExecutive.scaledMid3PTiltDistance = [appExecutive.defaults floatForKey:@"scaledMid3PTiltDistance"];
        
        self.appExecutive.scaledEnd3PSlideDistance = [appExecutive.defaults floatForKey:@"scaledEnd3PSlideDistance"];
        self.appExecutive.scaledEnd3PPanDistance = [appExecutive.defaults floatForKey:@"scaledEnd3PPanDistance"];
        self.appExecutive.scaledEnd3PTiltDistance = [appExecutive.defaults floatForKey:@"scaledEnd3PTiltDistance"];

        
//        NSLog(@"after scaledStart3PSlideDistance: %f",self.appExecutive.scaledStart3PSlideDistance);
//        NSLog(@"after scaledStart3PPanDistance: %f",self.appExecutive.scaledStart3PPanDistance);
//        NSLog(@"after scaledStart3PTiltDistance: %f",self.appExecutive.scaledStart3PTiltDistance);
//        
//        NSLog(@"after scaledMid3PSlideDistance: %f",self.appExecutive.scaledMid3PSlideDistance);
//        NSLog(@"after scaledMid3PPanDistance: %f",self.appExecutive.scaledMid3PPanDistance);
//        NSLog(@"after scaledMid3PTiltDistance: %f",self.appExecutive.scaledMid3PTiltDistance);
//        
//        NSLog(@"after scaledEnd3PSlideDistance: %f",self.appExecutive.scaledEnd3PSlideDistance);
//        NSLog(@"after scaledEnd3PPanDistance: %f",self.appExecutive.scaledEnd3PPanDistance);
//        NSLog(@"after scaledEnd3PTiltDistance: %f",self.appExecutive.scaledEnd3PTiltDistance);
        
        if ([appExecutive.defaults integerForKey:@"is3P"] == 0)
        {
            NSLog(@"its 2p");
            
//            if (startEndTotal != 0 && self.appExecutive.is3P == NO)
//            {
//                self.setStartButton.selected = YES;
//                self.setStopButton.selected = YES;
//            }
            
            if(start2pTotals != 0)
            {
                self.setStartButton.selected = YES;
            }
            
            if(end2pTotals != 0)
            {
                self.setStopButton.selected = YES;
            }
        }
        else
        {
            if ([self.appExecutive.defaults integerForKey:@"mid3PSet"] == 2)
            {
                self.flipButton.selected = YES;
            }
        }
    }
    else if (pc != 0 || isSameDevice == NO)
    {
        //NSLog(@"reset values");
        
        [self.appExecutive.defaults setObject: [NSNumber numberWithFloat:0] forKey: @"start3PSlideDistance"];
        [self.appExecutive.defaults setObject: [NSNumber numberWithFloat:0] forKey: @"start3PPanDistance"];
        [self.appExecutive.defaults setObject: [NSNumber numberWithFloat:0] forKey: @"start3PTiltDistance"];
        
        [self.appExecutive.defaults setObject: [NSNumber numberWithFloat:0] forKey: @"mid3PSlideDistance"];
        [self.appExecutive.defaults setObject: [NSNumber numberWithFloat:0] forKey: @"mid3PPanDistance"];
        [self.appExecutive.defaults setObject: [NSNumber numberWithFloat:0] forKey: @"mid3PTiltDistance"];
        
        [self.appExecutive.defaults setObject: [NSNumber numberWithFloat:0] forKey: @"end3PSlideDistance"];
        [self.appExecutive.defaults setObject: [NSNumber numberWithFloat:0] forKey: @"end3PPanDistance"];
        [self.appExecutive.defaults setObject: [NSNumber numberWithFloat:0] forKey: @"end3PTiltDistance"];
        
        [self.appExecutive.defaults setObject: [NSNumber numberWithInt:0] forKey: @"start3PSet"];
        [self.appExecutive.defaults setObject: [NSNumber numberWithInt:0] forKey: @"mid3PSet"];
        [self.appExecutive.defaults setObject: [NSNumber numberWithInt:0] forKey: @"end3PSet"];
        
        [self.appExecutive.defaults setObject: [NSNumber numberWithFloat:0] forKey: @"slide3PVal1"];
        [self.appExecutive.defaults setObject: [NSNumber numberWithFloat:0] forKey: @"slide3PVal2"];
        [self.appExecutive.defaults setObject: [NSNumber numberWithFloat:0] forKey: @"slide3PVal3"];
        
        [self.appExecutive.defaults setObject: [NSNumber numberWithFloat:0] forKey: @"scaledStart3PSlideDistance"];
        [self.appExecutive.defaults setObject: [NSNumber numberWithFloat:0] forKey: @"scaledStart3PPanDistance"];
        [self.appExecutive.defaults setObject: [NSNumber numberWithFloat:0] forKey: @"scaledStart3PTiltDistance"];
        
        [self.appExecutive.defaults setObject: [NSNumber numberWithFloat:0] forKey: @"scaledMid3PSlideDistance"];
        [self.appExecutive.defaults setObject: [NSNumber numberWithFloat:0] forKey: @"scaledMid3PPanDistance"];
        [self.appExecutive.defaults setObject: [NSNumber numberWithFloat:0] forKey: @"scaledMid3PTiltDistance"];
        
        [self.appExecutive.defaults setObject: [NSNumber numberWithFloat:0] forKey: @"scaledEnd3PSlideDistance"];
        [self.appExecutive.defaults setObject: [NSNumber numberWithFloat:0] forKey: @"scaledEnd3PPanDistance"];
        [self.appExecutive.defaults setObject: [NSNumber numberWithFloat:0] forKey: @"scaledEnd3PTiltDistance"];
        
        [self.appExecutive.defaults setObject: [NSNumber numberWithFloat:0] forKey: @"saved3PMicro1"];
        [self.appExecutive.defaults setObject: [NSNumber numberWithFloat:0] forKey: @"saved3PMicro2"];
        [self.appExecutive.defaults setObject: [NSNumber numberWithFloat:0] forKey: @"saved3PMicro3"];
        
        [self.appExecutive.defaults setObject: self.appExecutive.device.name forKey: @"deviceName"];
        
        [self.appExecutive.defaults synchronize];
    }
    
    if (([self.appExecutive.defaults floatForKey:@"slide3PVal1"] == 0))
    {
        //NSLog(@"set default 3P vals");
        
        self.appExecutive.slide3PVal1 = 1;
        self.appExecutive.slide3PVal2 = [self.appExecutive.frameCountNumber floatValue]/2;
        self.appExecutive.slide3PVal3 = [self.appExecutive.frameCountNumber floatValue];
    }
    else
    {
        //NSLog(@"get saved 3P vals");
        
        self.appExecutive.slide3PVal1 = [self.appExecutive.defaults floatForKey:@"slide3PVal1"];
        self.appExecutive.slide3PVal2 = [self.appExecutive.defaults floatForKey:@"slide3PVal2"];
        self.appExecutive.slide3PVal3 = [self.appExecutive.defaults floatForKey:@"slide3PVal3"];
    }
    
    if ((![self.appExecutive.defaults integerForKey:@"micro2"] || ![self.appExecutive.defaults integerForKey:@"micro3"]))
    {
        [[AppExecutive sharedInstance].device motorSet: 2 Microstep: 16];
        
        [self.appExecutive.defaults setObject: [NSNumber numberWithInt:1] forKey: @"micro2"];
        [self.appExecutive.defaults synchronize];
        
        [[AppExecutive sharedInstance].device motorSet: 3 Microstep: 16];
        
        [self.appExecutive.defaults setObject: [NSNumber numberWithInt:1] forKey: @"micro3"];
        [self.appExecutive.defaults synchronize];
        
        //microstepSetting = 16;
    }
    
//    //keyframe position
//    
//    NSLog(@"appExecutive.slide3PVal1: %f",appExecutive.slide3PVal1);
//    NSLog(@"appExecutive.slide3PVal2: %f",appExecutive.slide3PVal2);
//    NSLog(@"appExecutive.slide3PVal3: %f",appExecutive.slide3PVal3);
    
    //NSLog(@"sdn: %i",[self.appExecutive.shotDurationNumber intValue]);
    //NSLog(@"appExecutive.slide3PVal2: %f",appExecutive.slide3PVal2);
    
    [self.appExecutive.defaults setObject: [NSNumber numberWithFloat:appExecutive.slide3PVal1] forKey: @"slide3PVal1"];
    [self.appExecutive.defaults setObject: [NSNumber numberWithFloat:appExecutive.slide3PVal2] forKey: @"slide3PVal2"];
    [self.appExecutive.defaults setObject: [NSNumber numberWithFloat:appExecutive.slide3PVal3] forKey: @"slide3PVal3"];
    
    if (![self.appExecutive.defaults floatForKey:@"voltageLow"])
    {
        //NSLog(@"set default voltages");
        
        [self.appExecutive.defaults setObject: [NSNumber numberWithFloat:10.5] forKey: @"voltageLow"];
        [self.appExecutive.defaults setObject: [NSNumber numberWithFloat:12.5] forKey: @"voltageHigh"];
        
        [self.appExecutive.defaults synchronize];
    }
    
    self.appExecutive.voltageLow = [self.appExecutive.defaults floatForKey:@"voltageLow"];
    self.appExecutive.voltageHigh = [self.appExecutive.defaults floatForKey:@"voltageHigh"];
    
    [self.appExecutive.defaults synchronize];
    
    appExecutive.dampening1 = [appExecutive.device motorQueryContinuousAccelDecel: 1]/100;
    appExecutive.dampening2 = [appExecutive.device motorQueryContinuousAccelDecel: 2]/100;
    appExecutive.dampening3 = [appExecutive.device motorQueryContinuousAccelDecel: 3]/100;
    
//    NSLog(@"appExecutive.dampening1: %f",appExecutive.dampening1);
//    NSLog(@"appExecutive.dampening2: %f",appExecutive.dampening2);
//    NSLog(@"appExecutive.dampening3: %f",appExecutive.dampening3);
    
    if (([appExecutive.defaults integerForKey:@"is3P"] == 0 ||
         [appExecutive.defaults objectForKey:@"is3P"] == nil) &&
        (start2pTotals != 0 && end2pTotals != 0))
    {
        [UIView animateWithDuration:.4 animations:^{
            
            distanceSlideLbl.alpha = 1;
            distancePanLbl.alpha = 1;
            distanceTiltLbl.alpha = 1;
            
        } completion:^(BOOL finished) {
            
            [UIView animateWithDuration:.4 animations:^{
                
            } completion:^(BOOL finished) {
                
            }];
        }];
    }
    
    [self showVoltage];
    [self updateLabels];
    [self enterJoystickMode];
}

- (void) showVoltage {
    
    #if TARGET_IPHONE_SIMULATOR
        
        self.appExecutive.voltage = 12.1;
        self.appExecutive.voltageLow = 10.5;
        self.appExecutive.voltageHigh = 12.5;
        
    #else
        
        self.appExecutive.voltage = [self.appExecutive.device mainQueryVoltage];
        
    #endif
    
    
//    float range = self.appExecutive.voltageHigh - self.appExecutive.voltageLow;
//    
//    float diff = self.appExecutive.voltageHigh - self.appExecutive.voltage;
//    
//    float per = diff/range;
//    
//    float per2 = self.appExecutive.voltage/self.appExecutive.voltageHigh;
    
    //per2 = .35;
    
//    NSLog(@"voltage: %.02f",self.appExecutive.voltage);
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
    
    batteryView = [[UIView alloc] initWithFrame:CGRectMake(batteryIcon.frame.origin.x + 8,
                                                         batteryIcon.frame.origin.y + (batteryIcon.frame.size.height + offset),
                                                         batteryIcon.frame.size.width * .47,
                                                         batteryIcon.frame.size.height * per4)];
    
    batteryView.backgroundColor = [UIColor colorWithRed:230.0/255 green:234.0/255 blue:239.0/255 alpha:.8];
    
    //NSLog(@"add battery");
    
    [self.view addSubview:batteryView];
    
    [self.view bringSubviewToFront:setStopView];
}

- (void) handleUpdateBatteryViewNotification:(NSNotification *)pNotification {
    
    [batteryView removeFromSuperview];
        
//    float range = self.appExecutive.voltageHigh - self.appExecutive.voltageLow;
//    
//    float diff = self.appExecutive.voltageHigh - self.appExecutive.voltage;
//    
//    float per = diff/range;
//    
//    float per2 = self.appExecutive.voltage/self.appExecutive.voltageHigh;
    
    //per2 = .35;
    
//    NSLog(@"voltage: %.02f",self.appExecutive.voltage);
//    NSLog(@"high: %.02f",self.appExecutive.voltageHigh);
//    NSLog(@"low: %.02f",self.appExecutive.voltageLow);
//    NSLog(@"range: %.02f",range);
//    NSLog(@"diff: %.02f",diff);
//    NSLog(@"per: %.02f",per);
//    NSLog(@"per2: %.02f",per2);
    
    float newBase = self.appExecutive.voltageHigh - self.appExecutive.voltageLow;
    
    NSLog(@"newBase: %.02f",newBase);
    
    float newVoltage = self.appExecutive.voltage - self.appExecutive.voltageLow;
    
    NSLog(@"newVoltage: %.02f",newVoltage);
    
    float per4 = newVoltage/newBase;
    
    NSLog(@"per4: %.02f",per4);
    
    if (per4 > 1)
    {
        per4 = 1;
    }
    
    float offset = 1 - (batteryIcon.frame.size.height * per4) - .5;
    
    batteryView = [[UIView alloc] initWithFrame:CGRectMake(batteryIcon.frame.origin.x + 7,
                                                           batteryIcon.frame.origin.y + (batteryIcon.frame.size.height + offset),
                                                           batteryIcon.frame.size.width * .5,
                                                           batteryIcon.frame.size.height * per4)];
    
    batteryView.backgroundColor = [UIColor colorWithRed:230.0/255 green:234.0/255 blue:239.0/255 alpha:.8];
    
    NSLog(@"add battery 2");
    
    [self.view addSubview:batteryView];
}

#pragma mark - Notifications

- (void) handleUpdateLabelsNotification:(NSNotification *)pNotification {
    
    NSLog(@"handleUpdateLabelsNotification");
    
    NSDictionary *labelDict = pNotification.object;
    
    NSLog(@"labelDict: %@",labelDict);
    
    int motor = [[labelDict objectForKey:@"motor"] intValue];
    float gr = [[labelDict objectForKey:@"gearRatio"] floatValue];
    
    if (motor == 1)
    {
        slideRig = [labelDict objectForKey:@"rigRatio"];
        slideGear = gr;
        slideDirection = [labelDict objectForKey:@"direction"];
        inverted1 = [[labelDict objectForKey:@"inverted"] intValue];
        slideLinearCustom = [[labelDict objectForKey:@"customLinear"] floatValue];
    }
    else if (motor == 2)
    {
        panRig = [labelDict objectForKey:@"rigRatio"];
        panGear = gr;
        panDirection = [labelDict objectForKey:@"direction"];
        inverted2 = [[labelDict objectForKey:@"inverted"] intValue];
        panLinearCustom = [[labelDict objectForKey:@"customLinear"] floatValue];
    }
    else
    {
        tiltRig = [labelDict objectForKey:@"rigRatio"];
        tiltGear = gr;
        tiltDirection = [labelDict objectForKey:@"direction"];
        inverted3 = [[labelDict objectForKey:@"inverted"] intValue];
        tiltLinearCustom = [[labelDict objectForKey:@"customLinear"] floatValue];
    }
    
    [self updateLabels];
}

- (void) handleNotificationJSMode:(NSNotification *)pNotification {
    
    NSLog(@"handleNotificationJSMode");
    
    [self enterJoystickMode];
}

- (void) handleNotificationExitJSMode:(NSNotification *)pNotification {
    
    NSLog(@"handleNotificationExitJSMode");
    
    [self exitJoystickMode];
}

- (void) updateLabels {
    
//    NSLog(@"ul microstep1: %i",self.appExecutive.microstep1);
//    NSLog(@"ul microstep2: %i",self.appExecutive.microstep2);
//    NSLog(@"ul microstep3: %i",self.appExecutive.microstep3);
    
    distance1 = appExecutive.endPoint1 - appExecutive.startPoint1;
    distance2 = appExecutive.endPoint2 - appExecutive.startPoint2;
    distance3 = appExecutive.endPoint3 - appExecutive.startPoint3;
    
//    NSLog(@"ul distance1: %f",distance1);
//    NSLog(@"ul distance2: %f",distance2);
//    NSLog(@"ul distance3: %f",distance3);
//    NSLog(@"\n");
//
//    NSLog(@"panRig: %@",panRig);
//    NSLog(@"panGear: %f",panGear);
    
    if (distance1 != 0 || distance2 != 0 || distance3 != 0)
    {
        NSLog(@"\n");
        
        NSDictionary *a = [self getDistance:1:
                           self.appExecutive.microstep1:
                                  distance1:
                                   slideRig:
                                  slideGear:
                           slideLinearCustom];
        
        NSDictionary *b = [self getDistance:2:
                           self.appExecutive.microstep2:
                                  distance2:
                                     panRig:
                                    panGear:
                           panLinearCustom];
        
        NSDictionary *c = [self getDistance:3:
                           self.appExecutive.microstep3:
                                  distance3:
                                    tiltRig:
                                   tiltGear:
                           tiltLinearCustom];
        
        if (debugDistance) {
        
        NSLog(@"getdistance dict1: %@",a);
        NSLog(@"getdistance dict2: %@",b);
        NSLog(@"getdistance dict3: %@",c);
            
        }
        
        distanceSlideLbl.text = [self updateInvertUI:
                                           inverted1:
                                 [[a objectForKey:@"degrees"] floatValue]:
                                 [[a objectForKey:@"inches"] floatValue]:
                                      slideDirection:
                                            slideRig:
                                 1];
        
        distancePanLbl.text = [self updateInvertUI:
                                         inverted2:
                               [[b objectForKey:@"degrees"] floatValue]:
                               [[b objectForKey:@"inches"] floatValue]:
                                      panDirection:
                                            panRig:
                               2];
        
        distanceTiltLbl.text = [self updateInvertUI:
                                          inverted3:
                                [[c objectForKey:@"degrees"] floatValue]:
                                [[c objectForKey:@"inches"] floatValue]:
                                      tiltDirection:
                                            tiltRig:
                                3];
    }
    else
    {
        [self setDefaultLabels];
    }
}

- (void) setDefaultLabels {

    NSString *direction;
    NSString *displayString;
    
    if([slideRig containsString:@"Stage R"] || [slideRig containsString:@"Rotary Custom"])
    {
        if (inverted1 == 1)
        {
            direction = @"CW";
        }
        else
        {
            direction = @"CCW";
        }
        
        displayString = [NSString stringWithFormat:@"%.02f Deg %@", 0.0, direction];
        
        NSString *rp = [NSString stringWithFormat:@"%.02f Deg %@", 0.0, direction];
        
        displayString = [rp stringByReplacingOccurrencesOfString:@"-" withString:@""];
    }
    else
    {
        if (inverted1 == 1)
        {
            direction = @"L";
        }
        else
        {
            direction = @"R";
        }
        
        displayString = [NSString stringWithFormat:@"%.02f In %@", 0.0, direction];
        
        NSString *rp = [NSString stringWithFormat:@"%.02f In %@", 0.0, direction];
        
        displayString = [rp stringByReplacingOccurrencesOfString:@"-" withString:@""];
    }
    
    distanceSlideLbl.text = displayString;
    
    if([panRig containsString:@"Stage R"] || [panRig containsString:@"Rotary Custom"])
    {
        if (inverted1 == 1)
        {
            direction = @"CW";
        }
        else
        {
            direction = @"CCW";
        }
        
        displayString = [NSString stringWithFormat:@"%.02f Deg %@", 0.0, direction];
        
        NSString *rp = [NSString stringWithFormat:@"%.02f Deg %@", 0.0, direction];
        
        displayString = [rp stringByReplacingOccurrencesOfString:@"-" withString:@""];
    }
    else
    {
        if (inverted1 == 1)
        {
            direction = @"L";
        }
        else
        {
            direction = @"R";
        }
        
        displayString = [NSString stringWithFormat:@"%.02f In %@", 0.0, direction];
        
        NSString *rp = [NSString stringWithFormat:@"%.02f In %@", 0.0, direction];
        
        displayString = [rp stringByReplacingOccurrencesOfString:@"-" withString:@""];
    }
    
    distancePanLbl.text = displayString;
    
    if([tiltRig containsString:@"Stage R"] || [tiltRig containsString:@"Rotary Custom"])
    {
        if (inverted1 == 1)
        {
            direction = @"CW";
        }
        else
        {
            direction = @"CCW";
        }
        
        displayString = [NSString stringWithFormat:@"%.02f Deg %@", 0.0, direction];
        
        NSString *rp = [NSString stringWithFormat:@"%.02f Deg %@", 0.0, direction];
        
        displayString = [rp stringByReplacingOccurrencesOfString:@"-" withString:@""];
    }
    else
    {
        if (inverted1 == 1)
        {
            direction = @"L";
        }
        else
        {
            direction = @"R";
        }
        
        displayString = [NSString stringWithFormat:@"%.02f In %@", 0.0, direction];
        
        NSString *rp = [NSString stringWithFormat:@"%.02f In %@", 0.0, direction];
        
        displayString = [rp stringByReplacingOccurrencesOfString:@"-" withString:@""];
    }
    
    distanceTiltLbl.text = displayString;
}

- (NSDictionary *)getDistance: (int)motor : (int)microstepSetting : (float)distance : (NSString *)rigRatioLbl : (float)gearRatio : (float)customLinearParam {
    
    float microsteps; // = 200;
    float reciprocal = 0;
    float inches;
    float degrees;
    float calculatedValue;
    
    //NSLog(@"getdistance microstepSetting: %i motor: %i",microstepSetting,motor);
    
    if (microstepSetting == 4)
    {
        microsteps = 800;
    }
    else if (microstepSetting == 8)
    {
        microsteps = 1600;
    }
    else
    {
        microsteps = 3200;
    }
    
    //float gearRatio = 0;
    
    float a = 1;
    
    //gearRatio = 19.2032;
    
    reciprocal = a/gearRatio;
    
    float rigRatio;
    
    if (debugDistance) {
        
    NSLog(@"gd rigRatioLbl: %@ motor: %i",rigRatioLbl,motor);
    NSLog(@"gd microsteps: %f motor: %i",microsteps,motor);
    NSLog(@"gd distance: %f motor: %i",distance,motor);
    NSLog(@"gd gearRatio: %f motor: %i",gearRatio,motor);
    NSLog(@"gd reciprocal: %f motor: %i",reciprocal,motor);
        
    }
    
    if (([rigRatioLbl containsString:@"Stage R"] ||
         [rigRatioLbl containsString:@"Rotary Custom"]))
    {
         //&& distance != 0
        
        //rigRatio = 3.2727;
        
        rigRatio = .30555;
        
        //degrees = (distance/(motorsteps * gearRatio * rigRatio)) * microstepSetting;
        
        degrees = (distance/microsteps) * reciprocal * rigRatio * 360;
        
//        float a1 = (distance/microsteps);
//        float a2 = a1 * reciprocal;
//        float a3 = a2 * rigRatio;
//        float a4 = a3 * 360;
        
//        NSLog(@"a1: %f",a1);
//        NSLog(@"a2: %f",a2);
//        NSLog(@"a3: %f",a3);
//        NSLog(@"a4: %f",a4);
        
        calculatedValue = degrees;
        
        if (debugDistance) {
        
        NSLog(@"calculatedValue degrees: %f",calculatedValue);
            
        }
        
        //NSLog(@"degrees: %f motor: %i",degrees,motor);
    }
    else
    {
        //rigRatio = .2988;
        //inches = (distance/(motorsteps * gearRatio * rigRatio)) * microstepSetting;
        //inches = (31000/800) * .0513 * 3.54;
        //inches = (distance/microsteps) * reciprocal * 3.54;
        
        if([rigRatioLbl containsString:@"Linear Custom"])
        {
            NSLog(@"contains Linear Custom MVC: %f",customLinearParam);
            
            inches = ((distance/microsteps) * reciprocal) * customLinearParam;
            
            float a1 = (distance/microsteps);
            float a2 = a1 * reciprocal;
            float a3 = a2 * customLinearParam;
            
            NSLog(@"a1: %f",a1); //28.695625
            NSLog(@"a2: %f",a2); //1.494315
            NSLog(@"a3: %f",a3);
        }
        else //randall 11-16-15
        {
            //inches = ((distance/microsteps) * reciprocal) * 3.54;
            inches = ((distance/microsteps) * reciprocal) * 3.346;
            
            float a1 = (distance/microsteps);
            float a2 = a1 * reciprocal;
            float a3 = a2 * 3.346;
            
            NSLog(@"a1: %f",a1);
            NSLog(@"a2: %f",a2);
            NSLog(@"a3: %f",a3);
        }
        
        calculatedValue = inches;
        
        if (debugDistance) {
        
        NSLog(@"calculatedValue in: %f",calculatedValue);
            
        }
        
        //NSLog(@"inches: %f motor: %i",inches,motor);
    }
    
    NSLog(@"\n");
    
    NSDictionary *dict1 = [[NSDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithFloat:degrees],@"degrees",[NSNumber numberWithFloat:inches],@"inches", nil];
    
    return dict1;
}

- (NSString *)updateInvertUI : (int)inverted : (float)degrees : (float)inches : (NSString *)direction : (NSString *)rigRatioLbl : (int)motor {
    
    if (debugDistance) {
    
    NSLog(@"updateInvertUI rigRatioLbl: %@ motor: %i",rigRatioLbl,motor);
    NSLog(@"updateInvertUI degrees: %f motor: %i",degrees,motor);
        
    }
    
    NSString *displayString;
    
    if([rigRatioLbl containsString:@"Stage R"] || [rigRatioLbl containsString:@"Rotary Custom"])
    {
        if (inverted == 1)
        {
            direction = @"CW";
        }
        else
        {
            direction = @"CCW";
        }
        
        displayString = [NSString stringWithFormat:@"%.02f Deg %@", degrees, direction];
        
        NSString *rp = [NSString stringWithFormat:@"%.02f Deg %@", degrees, direction];
        
        displayString = [rp stringByReplacingOccurrencesOfString:@"-" withString:@""];
    }
    else
    {
        if (inverted == 1)
        {
            direction = @"L";
        }
        else
        {
            direction = @"R";
        }
        
        displayString = [NSString stringWithFormat:@"%.02f In %@", inches, direction];
        
        NSString *rp = [NSString stringWithFormat:@"%.02f In %@", inches, direction];
        
        displayString = [rp stringByReplacingOccurrencesOfString:@"-" withString:@""];
    }
    
    if (debugDistance) {
        
    NSLog(@"displayString: %@",displayString);
    NSLog(@"\n");
        
    }
    
    return displayString;
}

- (void) setupMicrosteps {

    NMXDevice *device = self.appExecutive.device;
    
//    UInt32 queryStartHere = [device mainQueryStartHere];
//    
//    NSLog(@"queryStartHere: %i", queryStartHere);
    
    [device motorSet: device.sledMotor Microstep: [device motorQueryMicrostep: device.sledMotor]];
    [device motorSet: device.panMotor Microstep: [device motorQueryMicrostep: device.panMotor]];
    [device motorSet: device.tiltMotor Microstep: [device motorQueryMicrostep: device.tiltMotor]];
}

- (void) enterJoystickMode {
    
    //NSLog(@"enterJoystickMode");

    if (false == self.joystickModeActive)
    {
        [self.appExecutive.device mainSetJoystickMode: true];
        [self.appExecutive.device mainSetJoystickWatchdog: true];
        
        self.joystickModeActive = true;
    }
}

- (void) exitJoystickMode {
    
    //NSLog(@"exitJoystickMode");

    if (self.joystickModeActive)
    {
        [self.appExecutive.device mainSetJoystickMode: false];
        self.joystickModeActive = false;
    }
}

- (void) didConnect: (NMXDevice *) device {

    // For now, we are doing all of our device communication on the main queue.  Would be good to move it to it's own queue...
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        
        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            [device mainSetAppMode: true];
            [device mainSetJoystickMode: false];
            
            queryStatus = [device mainQueryRunStatus];
            queryStatusKeyFrame = [device queryKeyFrameProgramRunState];
            
            if (NMXRunStatusStopped != queryStatus || NMXKeyFrameRunStatusStopped != queryStatusKeyFrame)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    if (NMXKeyFrameRunStatusStopped != queryStatusKeyFrame)
                    {
                        appExecutive.is3P = YES;
                        [switch2P setOn:YES];
                    }
                        
                    self.appExecutive.voltage = [self.appExecutive.device mainQueryVoltage];
                    self.appExecutive.voltageLow = [self.appExecutive.defaults floatForKey:@"voltageLow"];
                    self.appExecutive.voltageHigh = [self.appExecutive.defaults floatForKey:@"voltageHigh"];
                    [self showVoltage];
                    [self performSegueWithIdentifier: SegueToSetupViewController sender: self];
                });
            }
            else
            {
                [device motorEnable: device.sledMotor];
                [device motorEnable: device.panMotor];
                [device motorEnable: device.tiltMotor];
                
                [self setupMicrosteps];
                int version = [device mainQueryFirmwareVersion];
                
             //NSLog(@"version: %i",version);
                
                if (version < kCurrentFirmwareVersion)
                {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"New Firmware Version"
                                                                            message: @"New firmware is available for the NMX, please update the NMX firmware asap"
                                                                           delegate: nil
                                                                  cancelButtonTitle: @"OK"
                                                                  otherButtonTitles: nil];
                        [alert show];
                    });
                }
                
                [self enterJoystickMode];
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                
                if (NMXRunStatusStopped == queryStatus)
                {
                    [NSTimer scheduledTimerWithTimeInterval:0.10 target:self selector:@selector(startStopQueryTimer) userInfo:nil repeats:NO];
                }
            });
        });
    });
}

- (void) handleEnteredBackground: (NSNotification *) notification {

    DDLogDebug(@"handleEnteredBackground");
    
    [self exitJoystickMode];
}

- (void) handleBecomeActive: (NSNotification *) notification {

    DDLogDebug(@"handleBecomeActive");
    
    [self enterJoystickMode];
}

- (void) deviceDisconnect: (id) object {
    
    NSLog(@"deviceDisconnect popview notification: %@",object);
    
    //[appDelegate.nav popToRootViewControllerAnimated: true];
        
    [self.navigationController popToRootViewControllerAnimated: true];

//    [[NSNotificationCenter defaultCenter]
//     postNotificationName:@"showNotificationHost"
//     object:self.restorationIdentifier];
}

//------------------------------------------------------------------------------

#pragma mark - Navigation

- (void) prepareForSegue: (UIStoryboardSegue *) segue sender: (id) sender {
    
	if ([segue.identifier isEqualToString: EmbedJoystickViewController])
	{
        // joystick view controller is embedded, net to set its delegagte
        
		self.joystickViewController = segue.destinationViewController;
		self.joystickViewController.delegate = self;
        
        [[NSNotificationCenter defaultCenter] removeObserver: self];
        
        //NSLog(@"remove observer embed");
	}
	else if ([segue.identifier isEqualToString: SegueToSetupViewController])
	{
		self.setupViewController = segue.destinationViewController;
        
        [[NSNotificationCenter defaultCenter] removeObserver: self];
        
        //NSLog(@"remove observer setup");
	}
	else if ([segue.identifier isEqualToString: SegueToSlideMotorSettingsViewController])
	{
        // motor settings view controller needs to know which motor it's working with
        
		MotorSettingsViewController *msvc = segue.destinationViewController;

		msvc.motorName = @"Slide";
		msvc.motorNumber = self.appExecutive.device.sledMotor;
        
        [self exitJoystickMode];
        self.showingModalScreen = true;
	}
	else if ([segue.identifier isEqualToString: SegueToPanMotorSettingsViewController])
	{
		MotorSettingsViewController *msvc = segue.destinationViewController;

		msvc.motorName = @"Pan";
		msvc.motorNumber = self.appExecutive.device.panMotor;

        [self exitJoystickMode];
        self.showingModalScreen = true;
    }
	else if ([segue.identifier isEqualToString: SegueToTiltMotorSettingsViewController])
	{
		MotorSettingsViewController *msvc = segue.destinationViewController;

		msvc.motorName = @"Tilt";
		msvc.motorNumber = self.appExecutive.device.tiltMotor;

        [self exitJoystickMode];
        self.showingModalScreen = true;
    }
    else if ([segue.identifier isEqualToString: @"HelpJoystick"])
    {
        NSLog(@"HelpJoystick");
        
        HelpViewController *msvc = segue.destinationViewController;
        
        [msvc setScreenInd:1];
        
        [self exitJoystickMode];
        self.showingModalScreen = true;
    }
}

//startview

- (IBAction) setStartPoint1:(id)sender {
    
    //DDLogDebug(@"Set Start Button");
    
    self.setStartButton.selected = YES;
    
    [self exitJoystickMode];
    
    self.appExecutive.start3PSlideDistance = [self.appExecutive.device motorQueryCurrentPosition:1];
    self.appExecutive.start3PPanDistance = [self.appExecutive.device motorQueryCurrentPosition:2];
    self.appExecutive.start3PTiltDistance = [self.appExecutive.device motorQueryCurrentPosition:3];
    
    NSLog(@"appExecutive.microstep1: %f",(float)appExecutive.microstep1);
    
    NSLog(@"before start3PSlideDistance: %f",self.appExecutive.start3PSlideDistance);
    NSLog(@"before start3PPanDistance: %f",self.appExecutive.start3PPanDistance);
    NSLog(@"before start3PTiltDistance: %f",self.appExecutive.start3PTiltDistance);
    
    [self convertUnits:1];
    
    [self.appExecutive.defaults setObject: [NSNumber numberWithFloat:self.appExecutive.start3PSlideDistance]
                                   forKey: @"start3PSlideDistance"];
    
    [self.appExecutive.defaults setObject: [NSNumber numberWithFloat:self.appExecutive.start3PPanDistance]
                                   forKey: @"start3PPanDistance"];
    
    [self.appExecutive.defaults setObject: [NSNumber numberWithFloat:self.appExecutive.start3PTiltDistance]
                                   forKey: @"start3PTiltDistance"];
    
    [self.appExecutive.defaults setObject: [NSNumber numberWithInt:2] forKey: @"start3PSet"];
    [self.appExecutive.defaults setObject: [NSNumber numberWithFloat:(float)appExecutive.microstep1]
                                   forKey: @"saved3PMicro1"];
    
    self.appExecutive.start3PSet = 2;
    
    //NSLog(@"start3PSet: %li",(long)[appExecutive.defaults integerForKey:@"start3PSet"]);
    //    NSLog(@"after scaledStart3PSlideDistance: %f",self.appExecutive.scaledStart3PSlideDistance);
    //    NSLog(@"after scaledStart3PPanDistance: %f",self.appExecutive.scaledStart3PPanDistance);
    //    NSLog(@"after scaledStart3PTiltDistance: %f",self.appExecutive.scaledStart3PTiltDistance);
    
    [self.appExecutive.defaults setObject: [NSNumber numberWithFloat:self.appExecutive.scaledStart3PSlideDistance]
                                   forKey: @"scaledStart3PSlideDistance"];
    
    [self.appExecutive.defaults setObject: [NSNumber numberWithFloat:self.appExecutive.scaledStart3PPanDistance]
                                   forKey: @"scaledStart3PPanDistance"];
    
    [self.appExecutive.defaults setObject: [NSNumber numberWithFloat:self.appExecutive.scaledStart3PTiltDistance]
                                   forKey: @"scaledStart3PTiltDistance"];
    
    [self.appExecutive.defaults synchronize];
    
    startTotals = self.appExecutive.start3PSlideDistance +
    self.appExecutive.start3PPanDistance +
    self.appExecutive.start3PTiltDistance;
    
    if (self.appExecutive.is3P == NO)
    {
        [self.appExecutive.device mainSetStartHere];
        
        self.appExecutive.startPoint1 = [self.appExecutive.device queryProgramStartPoint:1];
        
        NSLog(@"set startPoint1: %i",self.appExecutive.startPoint1);
        
        self.appExecutive.startPoint2 = [self.appExecutive.device queryProgramStartPoint:2];
        
        NSLog(@"set startPoint2: %i",self.appExecutive.startPoint2);
        
        self.appExecutive.startPoint3 = [self.appExecutive.device queryProgramStartPoint:3];
        
        NSLog(@"set startPoint3: %i",self.appExecutive.startPoint3);
        
        start2pTotals = appExecutive.startPoint1 + appExecutive.startPoint2 + appExecutive.startPoint3;
        end2pTotals = appExecutive.endPoint1 + appExecutive.endPoint2 + appExecutive.endPoint3;
        
        if (start2pTotals != 0 && end2pTotals != 0)
        {
            [UIView animateWithDuration:.4 animations:^{
                
                distanceSlideLbl.alpha = 1;
                distancePanLbl.alpha = 1;
                distanceTiltLbl.alpha = 1;
                
            } completion:^(BOOL finished) {
                
                [UIView animateWithDuration:.4 animations:^{
                    
                } completion:^(BOOL finished) {
                    
                }];
            }];
        }
    }
    
    [self enterJoystickMode];
    
    if (self.setStopButton.selected == YES)
    {
        [self updateLabels];
    }
    
    [UIView animateWithDuration:.4 animations:^{
        
        setStartView.alpha = 0;
        
    } completion:^(BOOL finished) {
        
    }];
}

- (IBAction) goToStartPoint1:(id)sender {
    
    [self exitJoystickMode];
    
    if (self.appExecutive.is3P == YES)
    {
        [self.appExecutive.device motorSet:1 SetMotorPosition: self.appExecutive.start3PSlideDistance];
        [self.appExecutive.device motorSet:2 SetMotorPosition: self.appExecutive.start3PPanDistance];
        [self.appExecutive.device motorSet:3 SetMotorPosition: self.appExecutive.start3PTiltDistance];
    }
    else
    {
        [self.appExecutive.device resetLimits:1];
        [self.appExecutive.device resetLimits:2];
        [self.appExecutive.device resetLimits:3];
        
        NSLog(@"go to startPoint1: %i",self.appExecutive.startPoint1);
        NSLog(@"go to startPoint2: %i",self.appExecutive.startPoint2);
        NSLog(@"go to startPoint3: %i",self.appExecutive.startPoint3);
        NSLog(@"\n");
        
        [self.appExecutive.device motorSet:1 SetMotorPosition: self.appExecutive.startPoint1];
        [self.appExecutive.device motorSet:2 SetMotorPosition: self.appExecutive.startPoint2];
        [self.appExecutive.device motorSet:3 SetMotorPosition: self.appExecutive.startPoint3];
    }
    
    [UIView animateWithDuration:.4 animations:^{
        
        setStartView.alpha = 0;
        
    } completion:^(BOOL finished) {
        
    }];
    
    [self enterJoystickMode];
}

- (IBAction) closeStartView:(id)sender {
    
    [UIView animateWithDuration:.4 animations:^{
        
        setStartView.alpha = 0;
        
    } completion:^(BOOL finished) {
        
    }];
}

//midview

- (IBAction) setMidPoint1:(id)sender {
    
    if (self.appExecutive.is3P == YES)
    {
        [self exitJoystickMode];
        
        flipButton.selected = YES;
        
        self.appExecutive.mid3PSlideDistance = [self.appExecutive.device motorQueryCurrentPosition:1];
        self.appExecutive.mid3PPanDistance = [self.appExecutive.device motorQueryCurrentPosition:2];
        self.appExecutive.mid3PTiltDistance = [self.appExecutive.device motorQueryCurrentPosition:3];
        
        NSLog(@"appExecutive.microstep2: %f",(float)appExecutive.microstep2);
        
        NSLog(@"before mid3PSlideDistance: %f",self.appExecutive.mid3PSlideDistance);
        NSLog(@"before mid3PPanDistance: %f",self.appExecutive.mid3PPanDistance);
        NSLog(@"before mid3PTiltDistance: %f",self.appExecutive.mid3PTiltDistance);
        
        [self convertUnits:2];
        
        [self.appExecutive.defaults setObject: [NSNumber numberWithFloat:self.appExecutive.mid3PSlideDistance]
                                       forKey: @"mid3PSlideDistance"];
        
        [self.appExecutive.defaults setObject: [NSNumber numberWithFloat:self.appExecutive.mid3PPanDistance]
                                       forKey: @"mid3PPanDistance"];
        
        [self.appExecutive.defaults setObject: [NSNumber numberWithFloat:self.appExecutive.mid3PTiltDistance]
                                       forKey: @"mid3PTiltDistance"];
        
        [self.appExecutive.defaults setObject: [NSNumber numberWithInt:2] forKey: @"mid3PSet"];
        
        [self.appExecutive.defaults setObject: [NSNumber numberWithFloat:(float)appExecutive.microstep2]
                                       forKey: @"saved3PMicro2"];
        
        self.appExecutive.mid3PSet = 2;
        
        //        NSLog(@"after scaledMid3PSlideDistance: %f",self.appExecutive.scaledMid3PSlideDistance);
        //        NSLog(@"after scaledMid3PPanDistance: %f",self.appExecutive.scaledMid3PPanDistance);
        //        NSLog(@"after scaledMid3PTiltDistance: %f",self.appExecutive.scaledMid3PTiltDistance);
        
        [self.appExecutive.defaults setObject: [NSNumber numberWithFloat:self.appExecutive.scaledMid3PSlideDistance]
                                       forKey: @"scaledMid3PSlideDistance"];
        
        [self.appExecutive.defaults setObject: [NSNumber numberWithFloat:self.appExecutive.scaledMid3PPanDistance]
                                       forKey: @"scaledMid3PPanDistance"];
        
        [self.appExecutive.defaults setObject: [NSNumber numberWithFloat:self.appExecutive.scaledMid3PTiltDistance]
                                       forKey: @"scaledMid3PTiltDistance"];
        
        [self.appExecutive.defaults synchronize];
        
        //NSLog(@"mid3PSet: %li",(long)[appExecutive.defaults integerForKey:@"mid3PSet"]);
        
        midTotals = self.appExecutive.mid3PSlideDistance +
        self.appExecutive.mid3PPanDistance +
        self.appExecutive.mid3PTiltDistance;
        
        [UIView animateWithDuration:.4 animations:^{
            
            setMidView.alpha = 0;
            
        } completion:^(BOOL finished) {
            
        }];
        
        [self enterJoystickMode];
    }
}

- (IBAction) goToMidPoint1:(id)sender {
    
    [self exitJoystickMode];

    if (self.appExecutive.is3P == YES)
    {
        [self.appExecutive.device motorSet:1 SetMotorPosition: self.appExecutive.mid3PSlideDistance];
        [self.appExecutive.device motorSet:2 SetMotorPosition: self.appExecutive.mid3PPanDistance];
        [self.appExecutive.device motorSet:3 SetMotorPosition: self.appExecutive.mid3PTiltDistance];
    }
    
    [UIView animateWithDuration:.4 animations:^{
        
        setMidView.alpha = 0;
        
    } completion:^(BOOL finished) {
        
    }];
    
    [self enterJoystickMode];
}

- (IBAction) closeMidView:(id)sender {
    
    [UIView animateWithDuration:.4 animations:^{
        
        setMidView.alpha = 0;
        
    } completion:^(BOOL finished) {
        
    }];
}

//stopview

- (IBAction) setStopPoint1:(id)sender {

    //DDLogDebug(@"Set Stop Button");
    
    self.setStopButton.selected = YES;
    
    [self exitJoystickMode];
    
    self.appExecutive.end3PSlideDistance = [self.appExecutive.device motorQueryCurrentPosition:1];
    self.appExecutive.end3PPanDistance = [self.appExecutive.device motorQueryCurrentPosition:2];
    self.appExecutive.end3PTiltDistance = [self.appExecutive.device motorQueryCurrentPosition:3];
    
    NSLog(@"appExecutive.microstep3: %f",(float)appExecutive.microstep3);
    
    NSLog(@"before end3PSlideDistance: %f",self.appExecutive.end3PSlideDistance);
    NSLog(@"before end3PPanDistance: %f",self.appExecutive.end3PPanDistance);
    NSLog(@"before end3PTiltDistance: %f",self.appExecutive.end3PTiltDistance);
    
    [self convertUnits:3];
    
    [self.appExecutive.defaults setObject: [NSNumber numberWithFloat:self.appExecutive.end3PSlideDistance]
                                   forKey: @"end3PSlideDistance"];
    
    [self.appExecutive.defaults setObject: [NSNumber numberWithFloat:self.appExecutive.end3PPanDistance]
                                   forKey: @"end3PPanDistance"];
    
    [self.appExecutive.defaults setObject: [NSNumber numberWithFloat:self.appExecutive.end3PTiltDistance]
                                   forKey: @"end3PTiltDistance"];
    
    [self.appExecutive.defaults setObject: [NSNumber numberWithInt:2] forKey: @"end3PSet"];
    
    [self.appExecutive.defaults setObject: [NSNumber numberWithFloat:(float)appExecutive.microstep3]
                                   forKey: @"saved3PMicro3"];
    
    self.appExecutive.end3PSet = 2;
    
    //    NSLog(@"after scaledEnd3PSlideDistance: %f",self.appExecutive.scaledEnd3PSlideDistance);
    //    NSLog(@"after scaledEnd3PPanDistance: %f",self.appExecutive.scaledEnd3PPanDistance);
    //    NSLog(@"after scaledEnd3PTiltDistance: %f",self.appExecutive.scaledEnd3PTiltDistance);
    //NSLog(@"end3PSet: %li",(long)[appExecutive.defaults integerForKey:@"end3PSet"]);
    
    [self.appExecutive.defaults setObject: [NSNumber numberWithFloat:self.appExecutive.scaledEnd3PSlideDistance]
                                   forKey: @"scaledEnd3PSlideDistance"];
    
    [self.appExecutive.defaults setObject: [NSNumber numberWithFloat:self.appExecutive.scaledEnd3PPanDistance]
                                   forKey: @"scaledEnd3PPanDistance"];
    
    [self.appExecutive.defaults setObject: [NSNumber numberWithFloat:self.appExecutive.scaledEnd3PTiltDistance]
                                   forKey: @"scaledEnd3PTiltDistance"];
    
    [self.appExecutive.defaults synchronize];
    
    endTotals = self.appExecutive.end3PSlideDistance +
    self.appExecutive.end3PPanDistance +
    self.appExecutive.end3PTiltDistance;
    
    if (self.appExecutive.is3P == NO)
    {
        [self.appExecutive.device mainSetStopHere];
        
        self.appExecutive.endPoint1 = [self.appExecutive.device queryProgramEndPoint:1];
        
        NSLog(@"set endPoint1: %i",self.appExecutive.endPoint1);
        
        self.appExecutive.endPoint2 = [self.appExecutive.device queryProgramEndPoint:2];
        
        NSLog(@"set endPoint2: %i",self.appExecutive.endPoint2);
        
        self.appExecutive.endPoint3 = [self.appExecutive.device queryProgramEndPoint:3];
        
        NSLog(@"set endPoint3: %i",self.appExecutive.endPoint3);
        
        start2pTotals = appExecutive.startPoint1 + appExecutive.startPoint2 + appExecutive.startPoint3;
        end2pTotals = appExecutive.endPoint1 + appExecutive.endPoint2 + appExecutive.endPoint3;
        
        if (start2pTotals != 0 && end2pTotals != 0)
        {
            [UIView animateWithDuration:.4 animations:^{
                
                distanceSlideLbl.alpha = 1;
                distancePanLbl.alpha = 1;
                distanceTiltLbl.alpha = 1;
                
            } completion:^(BOOL finished) {
                
                [UIView animateWithDuration:.4 animations:^{
                    
                } completion:^(BOOL finished) {
                    
                }];
            }];
        }
    }
    
    if (self.setStartButton.selected == YES)
    {
        [self updateLabels];
    }
    
    [UIView animateWithDuration:.4 animations:^{
        
        setStopView.alpha = 0;
        
    } completion:^(BOOL finished) {
        
    }];
    
    [self enterJoystickMode];
}

- (IBAction) goToStopPoint1:(id)sender {
    
    [self exitJoystickMode];
    
    if (self.appExecutive.is3P == YES)
    {
        [self.appExecutive.device motorSet:1 SetMotorPosition: self.appExecutive.end3PSlideDistance];
        [self.appExecutive.device motorSet:2 SetMotorPosition: self.appExecutive.end3PPanDistance];
        [self.appExecutive.device motorSet:3 SetMotorPosition: self.appExecutive.end3PTiltDistance];
    }
    else
    {
        NSLog(@"goto endpoint1: %i",self.appExecutive.endPoint1);
        NSLog(@"goto endpoint2: %i",self.appExecutive.endPoint2);
        NSLog(@"goto endpoint3: %i",self.appExecutive.endPoint3);
        
        [self.appExecutive.device motorSet:1 SetMotorPosition: self.appExecutive.endPoint1];
        [self.appExecutive.device motorSet:2 SetMotorPosition: self.appExecutive.endPoint2];
        [self.appExecutive.device motorSet:3 SetMotorPosition: self.appExecutive.endPoint3];
    }

    [UIView animateWithDuration:.4 animations:^{
        
        setStopView.alpha = 0;
        
    } completion:^(BOOL finished) {
        
    }];
    
    [self enterJoystickMode];
}

- (IBAction) closeStopView:(id)sender {

    [UIView animateWithDuration:.4 animations:^{
        
        setStopView.alpha = 0;
        
    } completion:^(BOOL finished) {
        
    }];
}

- (IBAction) unwindFromSetupViewController: (UIStoryboardSegue *) segue {

	// reset buttons when coming back from Setup View Controller
    
    [self setupMicrosteps];
    [self enterJoystickMode];

    self.nextButton.selected = NO;
    
    if (self.appExecutive.is3P == NO)
    {
        self.setStartButton.selected = NO;
        self.setStopButton.selected = NO;
        self.fireCameraButton.selected = NO;
        self.flipButton.selected = NO;
    }
}

//------------------------------------------------------------------------------

#pragma mark - JoystickOutput Protocol Methods

- (void) disableButtonsJoystick {
    
    slideButton.userInteractionEnabled = NO;
    panButton.userInteractionEnabled = NO;
    tiltButton.userInteractionEnabled = NO;
    settingsButton.userInteractionEnabled = NO;
    setStartButton.userInteractionEnabled = NO;
    setStopButton.userInteractionEnabled = NO;
    flipButton.userInteractionEnabled = NO;
    nextButton.userInteractionEnabled = NO;
    fireCameraButton.userInteractionEnabled = NO;
    dominantAxisSwitch.userInteractionEnabled = NO;
    switch2P.userInteractionEnabled = NO;
    _dollySlider.userInteractionEnabled = NO;
    
    [self hideButtonViews];
}

- (void) disableButtons {
    
    slideButton.userInteractionEnabled = NO;
    panButton.userInteractionEnabled = NO;
    tiltButton.userInteractionEnabled = NO;
    settingsButton.userInteractionEnabled = NO;
    setStartButton.userInteractionEnabled = NO;
    setStopButton.userInteractionEnabled = NO;
    flipButton.userInteractionEnabled = NO;
    nextButton.userInteractionEnabled = NO;
    fireCameraButton.userInteractionEnabled = NO;
    dominantAxisSwitch.userInteractionEnabled = NO;
    switch2P.userInteractionEnabled = NO;
    
    [self hideButtonViews];
}

- (void) enableButtons {
    
    slideButton.userInteractionEnabled = YES;
    panButton.userInteractionEnabled = YES;
    tiltButton.userInteractionEnabled = YES;
    _dollySlider.userInteractionEnabled = YES;
    settingsButton.userInteractionEnabled = YES;
    setStartButton.userInteractionEnabled = YES;
    setStopButton.userInteractionEnabled = YES;
    flipButton.userInteractionEnabled = YES;
    nextButton.userInteractionEnabled = YES;
    fireCameraButton.userInteractionEnabled = YES;
    dominantAxisSwitch.userInteractionEnabled = YES;
    switch2P.userInteractionEnabled = YES;
}

- (void) moveJoystick: (NSTimer*) theTimer {
    
    if ((self.appExecutive.joystick.x == 0) && (self.appExecutive.joystick.y == 0))
    {
        //joystick reset
        
        [self enableButtons];
        
        [self.appExecutive.device motorSet: self.appExecutive.device.panMotor ContinuousSpeed: 0];
        [self.appExecutive.device motorSet: self.appExecutive.device.tiltMotor ContinuousSpeed: 0];
        
        [self.joystickTimer invalidate];
        self.joystickTimer = nil;
    }
    else
    {
        [self disableButtonsJoystick];
        
        if (self.lockAxisState == TRUE)
        {
             //NSLog(@"lock x: %f y: %f",self.appExecutive.joystick.x,self.appExecutive.joystick.y);
            
            //NSLog(@"joystickViewController.vl.x: %f",self.joystickViewController.vl.x);
            
            if (fabs(self.appExecutive.joystick.x) > fabs(self.appExecutive.joystick.y))
            {
                self.appExecutive.joystick = CGPointMake(self.appExecutive.joystick.x, 0);
            }
            else
            {
                self.appExecutive.joystick = CGPointMake(0, self.appExecutive.joystick.y);
            }
        }

        float moveScale = (self.sensitivity * 50.0);
        
        if (self.appExecutive.joystick.x == 0)
        {
            [self.appExecutive.device motorSet: self.appExecutive.device.panMotor ContinuousSpeed: 0];
        }
        else
        {
            [self.appExecutive.device motorSet: self.appExecutive.device.panMotor ContinuousSpeed: self.appExecutive.joystick.x * moveScale];
        }
        
        if (self.appExecutive.joystick.y == 0)
        {
            [self.appExecutive.device motorSet: self.appExecutive.device.tiltMotor ContinuousSpeed: 0];
        }
        else
        {
            [self.appExecutive.device motorSet: self.appExecutive.device.tiltMotor ContinuousSpeed: self.appExecutive.joystick.y * moveScale];
        }
        
        //DDLogDebug(@"moveJoystick");
    }
}

- (void) joystickPosition: (CGPoint) position {

    if ((position.x < 0.001) && (position.x > -0.001))
    {
        position.x = 0;
    }
    
    if ((position.y < 0.001) && (position.y > -0.001))
    {
        position.y = 0;
    }
    
	self.appExecutive.joystick = position;
    
    if (!self.joystickTimer)
    {
        [self moveJoystick: nil];
        
        self.joystickTimer = [NSTimer scheduledTimerWithTimeInterval: 0.2
                                                              target: self
                                                            selector: @selector(moveJoystick:)
                                                            userInfo: nil
                                                             repeats: YES];
    }
}

//------------------------------------------------------------------------------

#pragma mark - IBAction Methods

- (IBAction) handleDominantAxisSwitch: (UISwitch *) sender {
    
    NSString *value	= (sender.on ? @"ON" : @"OFF");
    
    DDLogDebug(@"Dominant Axis Switch: %@", value);
    
    self.appExecutive.lockAxisNumber = [NSNumber numberWithBool: sender.on];
    
    if (sender.on)
    {
        self.joystickViewController.axisLocked = YES;
        self.joystickViewController.degreeCircle.image = [UIImage imageNamed:@"degree_circleAll.png"];
    }
    else
    {
        self.joystickViewController.axisLocked = NO;
        self.joystickViewController.degreeCircle.image = [UIImage imageNamed:@"degree_circle2.png"];
    }
}

- (IBAction) handleSlideButton: (id) sender {

	DDLogDebug(@"Slide Button");
}

- (IBAction) handlePanButton: (id) sender {

	DDLogDebug(@"Pan Button");
}

- (IBAction) handleTiltButton: (id) sender {

	DDLogDebug(@"Tilt Button");
}

- (void) moveSled: (NSTimer*) theTimer {
    
    //NSLog(@"self.appExecutive.device.sledMotor: %i",self.appExecutive.device.sledMotor);

    if (self._dollySlider.value == 1)
    {
        [self.appExecutive.device motorSet: self.appExecutive.device.sledMotor ContinuousSpeed: 0];
    }
    else
    {
        float moveScale = (self.sensitivity * 50.0);

        if (self._dollySlider.value > 1)
        {
            [self.appExecutive.device motorSet: self.appExecutive.device.sledMotor ContinuousSpeed: (self._dollySlider.value -1) * moveScale];
        }
        else if (self._dollySlider.value < 1)
        {
            [self.appExecutive.device motorSet: self.appExecutive.device.sledMotor ContinuousSpeed: -(1 - self._dollySlider.value) * moveScale];
        }
    }
    
    //DDLogDebug(@"moveSled");
}

- (void) moveSled2: (NSTimer*) theTimer {
    
    //NSLog(@"self.appExecutive.device.sledMotor: %i",self.appExecutive.device.panMotor);
    
    if (self.panSlider.value == 1)
    {
        [self.appExecutive.device motorSet: self.appExecutive.device.panMotor ContinuousSpeed: 0];
    }
    else
    {
        float moveScale = (self.sensitivity * 50.0);
        
        if (self.panSlider.value > 1)
        {
            [self.appExecutive.device motorSet: self.appExecutive.device.panMotor ContinuousSpeed: (self.panSlider.value -1) * moveScale];
        }
        else if (self.panSlider.value < 1)
        {
            [self.appExecutive.device motorSet: self.appExecutive.device.panMotor ContinuousSpeed: -(1 - self.panSlider.value) * moveScale];
        }
        
        //NSLog(@"pan motor pos: %i",(int)[self.appExecutive.device motorQueryCurrentPosition:2]);
    }
    
    //DDLogDebug(@"moveSled2");
}

- (void) moveSled3: (NSTimer*) theTimer {
    
    //NSLog(@"self.appExecutive.device.sledMotor: %i",self.appExecutive.device.panMotor);
    
    if (self.tiltSlider.value == 1)
    {
        [self.appExecutive.device motorSet: self.appExecutive.device.tiltMotor ContinuousSpeed: 0];
    }
    else
    {
        float moveScale = (self.sensitivity * 50.0);
        
        if (self.tiltSlider.value > 1)
        {
            [self.appExecutive.device motorSet: self.appExecutive.device.tiltMotor ContinuousSpeed: (self.tiltSlider.value -1) * moveScale];
        }
        else if (self.tiltSlider.value < 1)
        {
            [self.appExecutive.device motorSet: self.appExecutive.device.tiltMotor ContinuousSpeed: -(1 - self.tiltSlider.value) * moveScale];
        }
    }
    
    //DDLogDebug(@"moveSled2");
}

- (IBAction) handleDollySliderControl: (UISlider *) sender {
    
    [self disableButtons];

    if (!self.controlsTimer)
    {
        [self moveSled: nil];
        
        self.controlsTimer = [NSTimer scheduledTimerWithTimeInterval: 0.1
                                                              target: self
                                                            selector: @selector(moveSled:)
                                                            userInfo: nil
                                                             repeats: YES];
    }
}

- (IBAction) releaseDollySliderControl: (UISlider *) sender {
    
    [self enableButtons];

    [sender setValue: 1];
    [self.appExecutive.device motorSet: self.appExecutive.device.sledMotor ContinuousSpeed: 0];
    [self.controlsTimer invalidate];
    self.controlsTimer = nil;
}

- (IBAction) handleDollyPanControl: (UISlider *) sender {
    
    [self disableButtons];
    
    if (!self.controlsTimer)
    {
        [self moveSled2: nil];
        
        self.controlsTimer = [NSTimer scheduledTimerWithTimeInterval: 0.1
                                                              target: self
                                                            selector: @selector(moveSled2:)
                                                            userInfo: nil
                                                             repeats: YES];
    }
}

- (IBAction) releaseDollyPanControl: (UISlider *) sender {
    
    [self enableButtons];
    
    [sender setValue: 1];
    [self.appExecutive.device motorSet: self.appExecutive.device.panMotor ContinuousSpeed: 0];
    [self.controlsTimer invalidate];
    self.controlsTimer = nil;
}

- (IBAction) handleDollyTiltControl: (UISlider *) sender {
    
    [self disableButtons];
    
    if (!self.controlsTimer)
    {
        [self moveSled3: nil];
        
        self.controlsTimer = [NSTimer scheduledTimerWithTimeInterval: 0.1
                                                              target: self
                                                            selector: @selector(moveSled3:)
                                                            userInfo: nil
                                                             repeats: YES];
    }
}

- (IBAction) releaseDollyTiltControl: (UISlider *) sender {
    
    [self enableButtons];
    
    [sender setValue: 1];
    [self.appExecutive.device motorSet: self.appExecutive.device.tiltMotor ContinuousSpeed: 0];
    [self.controlsTimer invalidate];
    self.controlsTimer = nil;
}

- (IBAction) handleSetStartButton: (UIButton *) sender {

	[UIView animateWithDuration:.4 animations:^{
        
        setStartView.alpha = 1.0;
        
    } completion:^(BOOL finished) {
        
    }];
}

- (IBAction) handleSetStartButtonOrig: (UIButton *) sender {
    
    //DDLogDebug(@"Set Start Button");
    
    self.setStartButton.selected = YES;
    
    [self exitJoystickMode];
    
    self.appExecutive.start3PSlideDistance = [self.appExecutive.device motorQueryCurrentPosition:1];
    self.appExecutive.start3PPanDistance = [self.appExecutive.device motorQueryCurrentPosition:2];
    self.appExecutive.start3PTiltDistance = [self.appExecutive.device motorQueryCurrentPosition:3];
    
    NSLog(@"appExecutive.microstep1: %f",(float)appExecutive.microstep1);
    
    NSLog(@"before start3PSlideDistance: %f",self.appExecutive.start3PSlideDistance);
    NSLog(@"before start3PPanDistance: %f",self.appExecutive.start3PPanDistance);
    NSLog(@"before start3PTiltDistance: %f",self.appExecutive.start3PTiltDistance);
    
    [self convertUnits:1];
    
    [self.appExecutive.defaults setObject: [NSNumber numberWithFloat:self.appExecutive.start3PSlideDistance]
                                   forKey: @"start3PSlideDistance"];
    
    [self.appExecutive.defaults setObject: [NSNumber numberWithFloat:self.appExecutive.start3PPanDistance]
                                   forKey: @"start3PPanDistance"];
    
    [self.appExecutive.defaults setObject: [NSNumber numberWithFloat:self.appExecutive.start3PTiltDistance]
                                   forKey: @"start3PTiltDistance"];
    
    [self.appExecutive.defaults setObject: [NSNumber numberWithInt:2] forKey: @"start3PSet"];
    [self.appExecutive.defaults setObject: [NSNumber numberWithFloat:(float)appExecutive.microstep1]
                                   forKey: @"saved3PMicro1"];
    
    self.appExecutive.start3PSet = 2;
    
    //NSLog(@"start3PSet: %li",(long)[appExecutive.defaults integerForKey:@"start3PSet"]);
    //    NSLog(@"after scaledStart3PSlideDistance: %f",self.appExecutive.scaledStart3PSlideDistance);
    //    NSLog(@"after scaledStart3PPanDistance: %f",self.appExecutive.scaledStart3PPanDistance);
    //    NSLog(@"after scaledStart3PTiltDistance: %f",self.appExecutive.scaledStart3PTiltDistance);
    
    [self.appExecutive.defaults setObject: [NSNumber numberWithFloat:self.appExecutive.scaledStart3PSlideDistance]
                                   forKey: @"scaledStart3PSlideDistance"];
    
    [self.appExecutive.defaults setObject: [NSNumber numberWithFloat:self.appExecutive.scaledStart3PPanDistance]
                                   forKey: @"scaledStart3PPanDistance"];
    
    [self.appExecutive.defaults setObject: [NSNumber numberWithFloat:self.appExecutive.scaledStart3PTiltDistance]
                                   forKey: @"scaledStart3PTiltDistance"];
    
    [self.appExecutive.defaults synchronize];
    
    startTotals = self.appExecutive.start3PSlideDistance +
    self.appExecutive.start3PPanDistance +
    self.appExecutive.start3PTiltDistance;
    
    if (self.appExecutive.is3P == NO)
    {
        [self.appExecutive.device mainSetStartHere];
        
        self.appExecutive.startPoint1 = [self.appExecutive.device queryProgramStartPoint:1];
        
        NSLog(@"mvc startPoint1: %i",self.appExecutive.startPoint1);
        
        self.appExecutive.startPoint2 = [self.appExecutive.device queryProgramStartPoint:2];
        
        NSLog(@"mvc startPoint2: %i",self.appExecutive.startPoint2);
        
        self.appExecutive.startPoint3 = [self.appExecutive.device queryProgramStartPoint:3];
        
        NSLog(@"mvc startPoint3: %i",self.appExecutive.startPoint3);
        
        start2pTotals = appExecutive.startPoint1 + appExecutive.startPoint2 + appExecutive.startPoint3;
        end2pTotals = appExecutive.endPoint1 + appExecutive.endPoint2 + appExecutive.endPoint3;
        
        if (start2pTotals != 0 && end2pTotals != 0)
        {
            [UIView animateWithDuration:.4 animations:^{
                
                distanceSlideLbl.alpha = 1;
                distancePanLbl.alpha = 1;
                distanceTiltLbl.alpha = 1;
                
            } completion:^(BOOL finished) {
                
                [UIView animateWithDuration:.4 animations:^{
                    
                } completion:^(BOOL finished) {
                    
                }];
            }];
        }
    }
    
    [self enterJoystickMode];
    
    if (self.setStopButton.selected == YES)
    {
        [self updateLabels];
    }
}

- (IBAction) handleFlipButton: (UIButton *) sender {
    
    //DDLogDebug(@"Flip Button");
    
    if (self.appExecutive.is3P == YES)
    {
        [UIView animateWithDuration:.4 animations:^{
            
            setMidView.alpha = 1.0;
            
        } completion:^(BOOL finished) {
            
        }];
    }
    else
    {
        [self exitJoystickMode];
        
        [self.appExecutive.device mainFlipStartStop];
        
        [self enterJoystickMode];
    }
}

- (IBAction) handleSetStopButton: (UIButton *) sender {
    
    [UIView animateWithDuration:.4 animations:^{
        
        setStopView.alpha = 1.0;
        
    } completion:^(BOOL finished) {
        
    }];
}

- (IBAction) handleSetStopButtonOrig: (UIButton *) sender {

	//DDLogDebug(@"Set Stop Button");
    
	self.setStopButton.selected = YES;

    [self exitJoystickMode];
    
    self.appExecutive.end3PSlideDistance = [self.appExecutive.device motorQueryCurrentPosition:1];
    self.appExecutive.end3PPanDistance = [self.appExecutive.device motorQueryCurrentPosition:2];
    self.appExecutive.end3PTiltDistance = [self.appExecutive.device motorQueryCurrentPosition:3];
    
    NSLog(@"appExecutive.microstep3: %f",(float)appExecutive.microstep3);
    
    NSLog(@"before end3PSlideDistance: %f",self.appExecutive.end3PSlideDistance);
    NSLog(@"before end3PPanDistance: %f",self.appExecutive.end3PPanDistance);
    NSLog(@"before end3PTiltDistance: %f",self.appExecutive.end3PTiltDistance);
    
    [self convertUnits:3];
    
    [self.appExecutive.defaults setObject: [NSNumber numberWithFloat:self.appExecutive.end3PSlideDistance]
                                   forKey: @"end3PSlideDistance"];
    
    [self.appExecutive.defaults setObject: [NSNumber numberWithFloat:self.appExecutive.end3PPanDistance]
                                   forKey: @"end3PPanDistance"];
    
    [self.appExecutive.defaults setObject: [NSNumber numberWithFloat:self.appExecutive.end3PTiltDistance]
                                   forKey: @"end3PTiltDistance"];
    
    [self.appExecutive.defaults setObject: [NSNumber numberWithInt:2] forKey: @"end3PSet"];
    
    [self.appExecutive.defaults setObject: [NSNumber numberWithFloat:(float)appExecutive.microstep3]
                                   forKey: @"saved3PMicro3"];
    
    self.appExecutive.end3PSet = 2;
    
//    NSLog(@"after scaledEnd3PSlideDistance: %f",self.appExecutive.scaledEnd3PSlideDistance);
//    NSLog(@"after scaledEnd3PPanDistance: %f",self.appExecutive.scaledEnd3PPanDistance);
//    NSLog(@"after scaledEnd3PTiltDistance: %f",self.appExecutive.scaledEnd3PTiltDistance);
    //NSLog(@"end3PSet: %li",(long)[appExecutive.defaults integerForKey:@"end3PSet"]);
    
    [self.appExecutive.defaults setObject: [NSNumber numberWithFloat:self.appExecutive.scaledEnd3PSlideDistance]
                                   forKey: @"scaledEnd3PSlideDistance"];
    
    [self.appExecutive.defaults setObject: [NSNumber numberWithFloat:self.appExecutive.scaledEnd3PPanDistance]
                                   forKey: @"scaledEnd3PPanDistance"];
    
    [self.appExecutive.defaults setObject: [NSNumber numberWithFloat:self.appExecutive.scaledEnd3PTiltDistance]
                                   forKey: @"scaledEnd3PTiltDistance"];
    
    [self.appExecutive.defaults synchronize];
    
    endTotals = self.appExecutive.end3PSlideDistance +
    self.appExecutive.end3PPanDistance +
    self.appExecutive.end3PTiltDistance;

    if (self.appExecutive.is3P == NO)
    {
        [self.appExecutive.device mainSetStopHere];
        
        self.appExecutive.endPoint1 = [self.appExecutive.device queryProgramEndPoint:1];
        
        NSLog(@"mvc endPoint1: %i",self.appExecutive.endPoint1);
        
        self.appExecutive.endPoint2 = [self.appExecutive.device queryProgramEndPoint:2];
        
        NSLog(@"mvc endPoint2: %i",self.appExecutive.endPoint2);
        
        self.appExecutive.endPoint3 = [self.appExecutive.device queryProgramEndPoint:3];
        
        NSLog(@"mvc endPoint3: %i",self.appExecutive.endPoint3);
        
        start2pTotals = appExecutive.startPoint1 + appExecutive.startPoint2 + appExecutive.startPoint3;
        end2pTotals = appExecutive.endPoint1 + appExecutive.endPoint2 + appExecutive.endPoint3;
        
        if (start2pTotals != 0 && end2pTotals != 0)
        {
            [UIView animateWithDuration:.4 animations:^{
                
                distanceSlideLbl.alpha = 1;
                distancePanLbl.alpha = 1;
                distanceTiltLbl.alpha = 1;
                
            } completion:^(BOOL finished) {
                
                [UIView animateWithDuration:.4 animations:^{
                    
                } completion:^(BOOL finished) {
                    
                }];
            }];
        }
    }
    
    if (self.setStartButton.selected == YES)
    {
        [self updateLabels];
    }
    
    [self enterJoystickMode];
}

- (void) convertUnits : (int)pointIndex {
    
    int convertVal[3];
    
    for(int i = 0; i < 3; i++) {
        
        // The raw value from the controller is queried here
        
        convertVal[i] = [self.appExecutive.device motorQueryCurrentPosition:i+1];
        
        // Get this motor's microsteps
        
        int thisMicros = 0;
        
        switch(i)
        {
            case 0:
                
                thisMicros = self.appExecutive.microstep1;
                break;
                
            case 1:
                
                thisMicros = self.appExecutive.microstep2;
                break;
                
            case 2:
                
                thisMicros = self.appExecutive.microstep3;
                break;
        }
        
        NSLog(@"%i *= (16 / %i)",convertVal[i],thisMicros);
        
        /* Converted raw steps to constant 16th steps. Resulting conversion factors:
         *  current microsteps == 4, conversion factor == 4,
         *  current microsteps == 8, conversion factor == 2,
         *  current microsteps == 16, conversion factor == 1,
         */
        
        convertVal[i] *= (16 / thisMicros);
        
        //NSLog(@"convertVal[i] %i",convertVal[i]);
    }
    
    if (pointIndex == 1) {
        
        NSLog(@"convert start keyframes");
        
        self.appExecutive.scaledStart3PSlideDistance = (float)convertVal[0];
        self.appExecutive.scaledStart3PPanDistance = (float)convertVal[1];
        self.appExecutive.scaledStart3PTiltDistance = (float)convertVal[2];
    }
    else if (pointIndex == 2) {
        
        NSLog(@"convert mid keyframes");
        
        self.appExecutive.scaledMid3PSlideDistance = (float)convertVal[0];
        self.appExecutive.scaledMid3PPanDistance = (float)convertVal[1];
        self.appExecutive.scaledMid3PTiltDistance = (float)convertVal[2];
    }
    else if (pointIndex == 3) {
        
        NSLog(@"convert stop keyframes");
        
        self.appExecutive.scaledEnd3PSlideDistance = (float)convertVal[0];
        self.appExecutive.scaledEnd3PPanDistance = (float)convertVal[1];
        self.appExecutive.scaledEnd3PTiltDistance = (float)convertVal[2];
    }
}

- (void) convertUnits3 : (int)pointIndex {
    
    int convertVal[3];
    
    for (int i = 0; i < 3; i++) {
        
        // The raw value from the controller is queried here
        
        if (pointIndex == 1) {
            
            convertVal[i] = [[ar1 objectAtIndex:i] floatValue];
        }
        else if (pointIndex == 2) {
            
            convertVal[i] = [[ar2 objectAtIndex:i] floatValue];
        }
        else if (pointIndex == 3) {
            
            convertVal[i] = [[ar3 objectAtIndex:i] floatValue];
        }
        
        // Get this motor's microsteps
        
        int thisMicros = 0;
        
        switch(i)
        {
            case 0:
                
                thisMicros = self.appExecutive.microstep1;
                break;
                
            case 1:
                
                thisMicros = self.appExecutive.microstep2;
                break;
                
            case 2:
                
                thisMicros = self.appExecutive.microstep3;
                break;
        }
        
        NSLog(@"%i *= (16 / %i)",convertVal[i],thisMicros);
        
        /* Converted raw steps to constant 16th steps. Resulting conversion factors:
         *  current microsteps == 4, conversion factor == 4,
         *  current microsteps == 8, conversion factor == 2,
         *  current microsteps == 16, conversion factor == 1,
         */
        
        convertVal[i] *= (16 / thisMicros);
        
        //NSLog(@"convertVal[i] %i",convertVal[i]);
    }
    
    if (pointIndex == 1) {
        
        NSLog(@"convert start");
        
        self.appExecutive.scaledStart3PSlideDistance = (float)convertVal[0];
        self.appExecutive.scaledStart3PPanDistance = (float)convertVal[1];
        self.appExecutive.scaledStart3PTiltDistance = (float)convertVal[2];
    }
    else if (pointIndex == 2) {
        
        NSLog(@"convert mid");
        
        self.appExecutive.scaledMid3PSlideDistance = (float)convertVal[0];
        self.appExecutive.scaledMid3PPanDistance = (float)convertVal[1];
        self.appExecutive.scaledMid3PTiltDistance = (float)convertVal[2];
    }
    else if (pointIndex == 3) {
        
        NSLog(@"convert stop");
        
        self.appExecutive.scaledEnd3PSlideDistance = (float)convertVal[0];
        self.appExecutive.scaledEnd3PPanDistance = (float)convertVal[1];
        self.appExecutive.scaledEnd3PTiltDistance = (float)convertVal[2];
    }
}

- (float) convertUnits2 : (int)pointIndex : (float)convertVal {
    
    // The raw value from the controller is queried here

    // Get this motor's microsteps
    
    int thisMicros = 0;
    
    switch(pointIndex)
    {
        case 1:
            
            thisMicros = self.appExecutive.microstep1;
            
            //thisMicros = [appExecutive.defaults floatForKey:@"saved3PMicro1"];
            break;
            
        case 2:
            
            thisMicros = self.appExecutive.microstep2;
            
            //thisMicros = [appExecutive.defaults floatForKey:@"saved3PMicro2"];
            break;
            
        case 3:
            
            thisMicros = self.appExecutive.microstep3;
            
            //thisMicros = [appExecutive.defaults floatForKey:@"saved3PMicro3"];
            break;
    }
    
    NSLog(@"%f *= (16 / %i)",convertVal,thisMicros);
    
    /* Converted raw steps to constant 16th steps. Resulting conversion factors:
     *  current microsteps == 4, conversion factor == 4,
     *  current microsteps == 8, conversion factor == 2,
     *  current microsteps == 16, conversion factor == 1,
     */
    
    convertVal *= (16 / thisMicros);
    
    NSLog(@"convertVal: %f",convertVal);
    
    return convertVal;
}

- (IBAction) handleNextButton: (UIButton *) sender {
    
    [self hideButtonViews];

	//DDLogDebug(@"Next Button");
    
    NSLog(@"self.appExecutive.start3PSet: %i",self.appExecutive.start3PSet);
    
    UIAlertView *alertView;
    
    if (appExecutive.is3P)
    {
        if (appExecutive.start3PSet != 2)
        {
            alertView = [[UIAlertView alloc]
                         initWithTitle:@"3-Point Move"
                         message:@"Please set Start point" delegate:nil
                         cancelButtonTitle:@"OK" otherButtonTitles:nil];
            
            [alertView show];
            
            return;
        }
        
        if (appExecutive.mid3PSet != 2)
        {
            alertView = [[UIAlertView alloc]
                         initWithTitle:@"3-Point Move"
                         message:@"Please set Mid point" delegate:nil
                         cancelButtonTitle:@"OK" otherButtonTitles:nil];
            
            [alertView show];
            
            return;
        }
        
        if (appExecutive.end3PSet != 2)
        {
            alertView = [[UIAlertView alloc]
                         initWithTitle:@"3-Point Move"
                         message:@"Please set End point" delegate:nil
                         cancelButtonTitle:@"OK" otherButtonTitles:nil];
            
            [alertView show];
            
            return;
        }
    }

    [self exitJoystickMode];
    
    [self performSegueWithIdentifier: SegueToSetupViewController sender: self];
}

- (IBAction) handleFireCameraButton: (UIButton *) sender {
    
    [self hideButtonViews];

    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{

        [self exitJoystickMode];
        [self.appExecutive.device cameraSetEnable: true];
        [self.appExecutive.device cameraExposeNow];
        [self enterJoystickMode];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        });
    });
}

- (IBAction) handleSettingsButton:(id)sender {
    
    [self exitJoystickMode];
    self.showingModalScreen = true;
}

- (void) viewWillDisappear:(BOOL)animated {

    [super viewWillDisappear: animated];
    
    //[[NSNotificationCenter defaultCenter] removeObserver: self];
    
    //randall 8-19-15 removed so joystick mode can be set from motor settings screen. moved to prepare for segue function
}

- (void) didReceiveMemoryWarning {

    [super didReceiveMemoryWarning];
}

@end
