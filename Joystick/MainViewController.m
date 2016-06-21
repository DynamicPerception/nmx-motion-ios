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
#import "JSActiveDeviceViewController.h"


//------------------------------------------------------------------------------

#pragma mark - Private Interface


@interface MainViewController ()

@property (nonatomic, strong)				AppExecutive *				appExecutive;
@property (nonatomic, strong)				SetupViewController *		setupViewController;

@property (nonatomic, strong)				JoystickViewController *	joystickViewController;

@property (strong, nonatomic)   IBOutlet    NSLayoutConstraint *        currentDeviceButtonBottomConstraint;
@property (strong, nonatomic)   IBOutlet    NSLayoutConstraint *        currentDeviceButtonHeightConstraint;

@property (nonatomic, strong)	IBOutlet	JoyButton *					slideButton;
@property (nonatomic, strong)	IBOutlet	JoyButton *					panButton;
@property (nonatomic, strong)	IBOutlet	JoyButton *					tiltButton;
@property (nonatomic, strong)	IBOutlet	JoyButton *					setStartButton;
@property (nonatomic, strong)	IBOutlet	JoyButton *					setStopButton;
@property (nonatomic, strong)	IBOutlet	JoyButton *					flipButton;
@property (nonatomic, strong)	IBOutlet	JoyButton *					nextButton;
@property (nonatomic, strong)	IBOutlet	JoyButton *					fireCameraButton;
@property (strong, nonatomic)   IBOutlet    JoyButton *                 currentDeviceButton;

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
NSString static *SegueToActiveDeviceViewController          = @"SegueToActiveDeviceViewController";


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

@synthesize distancePanLbl,distanceSlideLbl,distanceTiltLbl,trList,trView,brView,brList,tlList,tlView,blList,blView,trList2,tlList2,brList2,blList2,mode3PLbl,uiList,flipButton,image3P,mode3PLbl2,switch2P,joystickViefw,panSliderBG,panSlider,panSliderLbl,tiltSliderBG,tiltSlider,tiltSliderLbl,batteryIcon,ar1,ar2,ar3,setStartView,setStopView,setMid1Btn,setMidView,controlBackground,sendMotorsTimer,goTo1Btn,goToMidBtn,goToStopBtn,setStart1Btn,setStop1Btn;


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

    [super viewDidLoad];

    [[NSUserDefaults standardUserDefaults] setValue:@(NO) forKey:@"_UIConstraintBasedLayoutLogUnsatisfiable"];

    [self initViewForDevice];
    
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
    
    UITapGestureRecognizer *gestureRecognizer1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(enterJoystickMode)];
    [self.joystickViewController.view addGestureRecognizer:gestureRecognizer1];
    gestureRecognizer.cancelsTouchesInView = NO;
    
    if (self.view.frame.size.height > 480)
    {
        UIFont *font = self.currentDeviceButton.titleLabel.font;
        [self.currentDeviceButton.titleLabel setFont: [font fontWithSize: font.pointSize*1.5]];
        self.currentDeviceButtonBottomConstraint.constant = -10;
        self.currentDeviceButtonHeightConstraint.constant = 35;
    }
    self.currentDeviceButton.titleLabel.numberOfLines = 1;
    self.currentDeviceButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    self.currentDeviceButton.titleLabel.lineBreakMode = NSLineBreakByClipping;

}

- (void) initViewForDevice
{
    
    slideGear = 19.2032;
    panGear = 19.2032;
    tiltGear = 19.2032;
    
    slideLinearCustom = 0.00;
    panLinearCustom = 0.00;
    tiltLinearCustom = 0.00;
    
    slideDirection = @"R";
    panDirection = @"CCW";
    tiltDirection = @"UP";
    
    slideRig = @"Stage 1/0";
    panRig = @"Stage R";
    tiltRig = @"Stage R";
    
    int a = (int)[self.appExecutive.defaults integerForKey:@"slideMotor"];
    int b = (int)[self.appExecutive.defaults integerForKey:@"panMotor"];
    int c = (int)[self.appExecutive.defaults integerForKey:@"tiltMotor"];
    
    float d = [self.appExecutive.defaults floatForKey:@"slideMotorCustomValue"];//slideLinearCustom = 0.00;
    float e = [self.appExecutive.defaults floatForKey:@"panMotorCustomValue"];//panLinearCustom = 0.00;
    float f = [self.appExecutive.defaults floatForKey:@"tiltMotorCustomValue"];//tiltLinearCustom = 0.00;
    
    JSDeviceSettings *settings = self.appExecutive.device.settings;
    
    if([appExecutive.defaults objectForKey:@"slideMotor"] != nil)
    {
        if (a == 1)
        {
            slideRig = @"Stage R";
            
        }
        else if (a == 2)
        {
            slideRig = @"Stage 1/0";
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
    
    
    self.slideDirectionMode = [NSNumber numberWithInt:kLeftRightLabel];
    self.panDirectionMode = [NSNumber numberWithInt:kClockwiseCounterClockwiseLabel];
    self.tiltDirectionMode = [NSNumber numberWithInt:kUpDownLabel];
    
    // Restore saved label values for direction
    if([appExecutive.defaults objectForKey:@"slideDirectionMode"] != nil)
    {
        self.slideDirectionMode = [appExecutive.defaults objectForKey:@"slideDirectionMode"] ;
    }
    else
    {
        [appExecutive.defaults setObject:self.slideDirectionMode forKey:@"slideDirectionMode"];
    }
    
    if([appExecutive.defaults objectForKey:@"panDirectionMode"] != nil)
    {
        self.panDirectionMode = [appExecutive.defaults objectForKey:@"panDirectionMode"] ;
    }
    else
    {
        [appExecutive.defaults setObject:self.panDirectionMode forKey:@"panDirectionMode"];
    }
    
    if([appExecutive.defaults objectForKey:@"tiltDirectionMode"] != nil)
    {
        self.tiltDirectionMode = [appExecutive.defaults objectForKey:@"tiltDirectionMode"];
    }
    else
    {
        [appExecutive.defaults setObject:self.tiltDirectionMode forKey:@"tiltDirectionMode"];
    }
    
    if (settings.useJoystick == NO)
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
	
    if ([self.appExecutive.userDefaults integerForKey:@"is3P"] == 1)
    {
        self.appExecutive.is3P = YES;
        [switch2P setOn:YES];
        
        [self.flipButton setTitle:@"Set Mid" forState:UIControlStateNormal];
        mode3PLbl.text = @"3P";
        mode3PLbl2.text = @"3-Point Move";
        image3P.image = [UIImage imageNamed:@"3p.png"];
        goToStopBtn.enabled = NO;
        goToStopBtn.alpha = .5;
        goTo1Btn.enabled = NO;
        goTo1Btn.alpha = .5;
        goToMidBtn.enabled = NO;
        goToMidBtn.alpha = .5;
    }
    
    #if TARGET_IPHONE_SIMULATOR
    
        [self showVoltage];
        
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
    
    NMXDevice *device = self.appExecutive.device;
    if (device.fwVersion < 46 && switch2P.on)
    {
        switch2P.on = NO;
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Firmware Version"
                                                        message: @"The firmare version installed on the NMX device does not support this feature.  Install the latest firmware to access 3P mode."
                                                       delegate: nil
                                              cancelButtonTitle: @"OK"
                                              otherButtonTitles: nil];
        [alert show];
        
        return;
    }

    
    [self enterJoystickMode];
    
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
        
        JSDeviceSettings *settings = self.appExecutive.device.settings;
        
        if (swe.isOn)
        {
            [self.flipButton setTitle:@"Set Mid" forState:UIControlStateNormal];
            
            mode3PLbl.text = @"3P";
            mode3PLbl2.text = @"3-Point Move";
            image3P.image = [UIImage imageNamed:@"3p.png"];
            
            if (settings.mid3PSet == 2)
            {
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
                
                goToStopBtn.enabled = NO;
                goToStopBtn.alpha = .5;
                goTo1Btn.enabled = NO;
                goTo1Btn.alpha = .5;
                goToMidBtn.enabled = NO;
                goToMidBtn.alpha = .5;
                
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
            
            if (start2pTotals != 0 || settings.start2pSet == 1)
            {
                self.setStartButton.selected = YES;
            }
            
            if (end2pTotals != 0 || settings.end2pSet == 1)
            {
                self.setStopButton.selected = YES;
            }
            
            if (start2pTotals != 0 && end2pTotals != 0) {
                
                [UIView animateWithDuration:.4 animations:^{
                    
                    distanceSlideLbl.alpha = 1;
                    distancePanLbl.alpha = 1;
                    distanceTiltLbl.alpha = 1;
                    
                    goToStopBtn.enabled = YES;
                    goToStopBtn.alpha = 1;
                    goTo1Btn.enabled = YES;
                    goTo1Btn.alpha = 1;
                    goToMidBtn.enabled = YES;
                    goToMidBtn.alpha = 1;
                    
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
    
    [self.appExecutive.userDefaults setObject: [NSNumber numberWithInt:self.appExecutive.is3P] forKey: @"is3P"];
    
}

- (void) resetTimers {
    
    //NSLog(@"resetTimers");
	
    brInd = 0;
    blInd = 0;
    trInd = 0;
    tlInd = 0;
}

- (void) viewWillAppear: (BOOL) animated {
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
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
    
    //    self.currentDeviceButton.hidden = (self.appExecutive.deviceList.count < 2);
    NSString *name = [self.appExecutive stringWithHandleForDeviceName: self.appExecutive.device.name];
    [self.currentDeviceButton setTitle:name forState:UIControlStateNormal];
    
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
    
    JSDeviceSettings *settings = self.appExecutive.device.settings;
    
    self.setStartButton.selected = NO;
    self.setStopButton.selected = NO;
    self.flipButton.selected = NO;
    
    if (settings.useJoystick == NO)
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
        settings.startPoint1 + settings.endPoint1 +
        settings.startPoint2 + settings.endPoint2 +
        settings.startPoint3 + settings.endPoint3;
    
    startTotals = settings.start3PSlideDistance + settings.start3PPanDistance + settings.start3PTiltDistance;
    midTotals = settings.mid3PSlideDistance + settings.mid3PPanDistance + settings.mid3PTiltDistance;
    endTotals = settings.end3PSlideDistance +  settings.end3PPanDistance + settings.end3PTiltDistance;
    
    if (self.appExecutive.is3P == NO)
    {
        NSLog(@"startEndTotal: %i",startEndTotal);
        
        if (start2pTotals != 0 || settings.start2pSet == 1) {
            
            self.setStartButton.selected = YES;
        }
        
        if (end2pTotals != 0 || settings.end2pSet == 1) {
            
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
    
    NMXDevice *device = self.appExecutive.device;
    
    [device mainSetAppMode: true];
    [device mainSetJoystickMode: false];
    
    int queryStatusKeyFrame = [device queryKeyFrameProgramRunState];
    int queryStatus = [device mainQueryRunStatus];
    
    if (NMXRunStatusRunning & queryStatus || NMXRunStatusRunning & queryStatusKeyFrame)
    {
        if (NMXRunStatusKeyframe & queryStatusKeyFrame)
        {
            appExecutive.is3P = YES;
            [switch2P setOn:YES];
        }
        
        [self showVoltage];
        [self performSegueWithIdentifier: SegueToSetupViewController sender: self];
    }
    else
    {
        inverted1 = [device motorQueryInvertDirection: 1];
        inverted2 = [device motorQueryInvertDirection: 2];
        inverted3 = [device motorQueryInvertDirection: 3];
        
        [device motorEnable: device.sledMotor];
        [device motorEnable: device.panMotor];
        [device motorEnable: device.tiltMotor];
        
        [self setupMicrosteps];
        [self enterJoystickMode];
    }
    
    if ((NMXRunStatusRunning & queryStatus) == 0)
    {
        [NSTimer scheduledTimerWithTimeInterval:0.10 target:self selector:@selector(startStopQueryTimer) userInfo:nil repeats:NO];
    }
    else
    {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    }
}

- (void) doubleEnterJoystickTimer{
    
    [self enterJoystickMode];
}

- (void) startStopQueryTimer {
    
    [self exitJoystickMode];
    
    JSDeviceSettings *settings = self.appExecutive.device.settings;
    
    settings.startPoint1 = [self.appExecutive.device queryProgramStartPoint:1];
    settings.endPoint1 = [self.appExecutive.device queryProgramEndPoint:1];
    
    settings.startPoint2 = [self.appExecutive.device queryProgramStartPoint:2];
    settings.endPoint2 = [self.appExecutive.device queryProgramEndPoint:2];
    
    settings.startPoint3 = [self.appExecutive.device queryProgramStartPoint:3];
    settings.endPoint3 = [self.appExecutive.device queryProgramEndPoint:3];
    
    
    start2pTotals = settings.startPoint1 + settings.startPoint2 + settings.startPoint3;
    end2pTotals = settings.endPoint1 + settings.endPoint2 + settings.endPoint3;
    
    startEndTotal =
    settings.startPoint1 + settings.endPoint1 +
    settings.startPoint2 + settings.endPoint2 +
    settings.startPoint3 + settings.endPoint3;
    
    // initialize microstep based on the device's last settings
    settings.microstep1 = [self.appExecutive.device motorQueryMicrostep2:1];
    settings.microstep2 = [self.appExecutive.device motorQueryMicrostep2:2];
    settings.microstep3 = [self.appExecutive.device motorQueryMicrostep2:3];
    
    bool pc = [self.appExecutive.device queryPowerCycle];
    
    if (pc == 0)
    {
        if (self.appExecutive.is3P == YES) {
            
            if (settings.start3PSet == 2)
            {
                self.setStartButton.selected = YES;
            }
            
            if (settings.end3PSet == 2)
            {
                self.setStopButton.selected = YES;
            }
            
            if (settings.mid3PSet == 2)
            {
                self.flipButton.selected = YES;
            }
        }
        
        startTotals = settings.start3PSlideDistance + settings.start3PPanDistance + settings.start3PTiltDistance;
        midTotals = settings.mid3PSlideDistance + settings.mid3PPanDistance + settings.mid3PTiltDistance;
        endTotals = settings.end3PSlideDistance + settings.end3PPanDistance + settings.end3PTiltDistance;
        
        if ([appExecutive.userDefaults integerForKey:@"is3P"] == 0)
        {
            if(start2pTotals != 0 || settings.start2pSet == 1)
            {
                self.setStartButton.selected = YES;
            }
            
            if(end2pTotals != 0 || settings.end2pSet == 1)
            {
                self.setStopButton.selected = YES;
            }
        }
        else
        {
            if (settings.mid3PSet == 2)
            {
                self.flipButton.selected = YES;
            }
        }
    }
    else
    {
        //NSLog(@"reset values");
        
        settings.start3PSlideDistance = 0.f;
        settings.start3PPanDistance = 0.f;
        settings.start3PTiltDistance = 0.f;
        
        settings.mid3PSlideDistance = 0.f;
        settings.mid3PPanDistance = 0.f;
        settings.mid3PTiltDistance = 0.f;
        
        settings.end3PSlideDistance = 0.f;
        settings.end3PPanDistance = 0.f;
        settings.end3PTiltDistance = 0.f;
        
        settings.mid3PSet = 0.f;
        settings.start3PSet = 0.f;
        settings.end3PSet = 0.f;

        settings.slide3PVal1 = 0.f;
        settings.slide3PVal2 = 0.f;
        settings.slide3PVal3 = 0.f;

        settings.scaledStart3PSlideDistance = 0.f;
        settings.scaledStart3PPanDistance = 0.f;
        settings.scaledStart3PTiltDistance = 0.f;
        
        settings.scaledMid3PSlideDistance = 0.f;
        settings.scaledMid3PPanDistance = 0.f;
        settings.scaledMid3PTiltDistance = 0.f;
        
        settings.scaledEnd3PSlideDistance = 0.f;
        settings.scaledEnd3PPanDistance = 0.f;
        settings.scaledEnd3PTiltDistance = 0.f;

        settings.start2pSet = 0;
        settings.end2pSet = 0;
        
        [settings synchronize];
    }
    
    [settings synchronize];
    
    if (([appExecutive.userDefaults integerForKey:@"is3P"] == 0 ||
         [appExecutive.userDefaults objectForKey:@"is3P"] == nil) &&
        (settings.start2pSet == 1 && settings.end2pSet == 1))
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
    
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}

- (void) showVoltage {
    
    JSDeviceSettings *settings = self.appExecutive.device.settings;
    #if TARGET_IPHONE_SIMULATOR
        
        settings.voltage = 12.1;
        settings.voltageLow = 10.5;
        settings.voltageHigh = 12.5;
        
    #else
        
        settings.voltage = [self.appExecutive.device mainQueryVoltage];
        
    #endif
    
    float newBase = settings.voltageHigh - settings.voltageLow;
    if (newBase == 0) newBase = 1;
    
    //NSLog(@"newBase: %.02f",newBase);
    
    float newVoltage = settings.voltage - settings.voltageLow;
    
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
        
    JSDeviceSettings *settings = self.appExecutive.device.settings;
    float newBase = settings.voltageHigh - settings.voltageLow;
    
    NSLog(@"newBase: %.02f",newBase);
    
    float newVoltage = settings.voltage - settings.voltageLow;
    
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
    
    //NSLog(@"handleNotificationJSMode");
    
    [self enterJoystickMode];
}

- (void) handleNotificationExitJSMode:(NSNotification *)pNotification {
    
    //NSLog(@"handleNotificationExitJSMode");
    
    [self exitJoystickMode];
}

- (void) updateLabels {
    
    JSDeviceSettings *settings = self.appExecutive.device.settings;
    
    distance1 = settings.endPoint1 - settings.startPoint1;
    distance2 = settings.endPoint2 - settings.startPoint2;
    distance3 = settings.endPoint3 - settings.startPoint3;
    
    // Restore saved label values for direction
    if([appExecutive.defaults objectForKey:@"slideDirectionMode"] != nil)
    {
        self.slideDirectionMode = [appExecutive.defaults objectForKey:@"slideDirectionMode"] ;
    }
    
    if([appExecutive.defaults objectForKey:@"panDirectionMode"] != nil)
    {
        self.panDirectionMode = [appExecutive.defaults objectForKey:@"panDirectionMode"] ;
    }
    
    if([appExecutive.defaults objectForKey:@"tiltDirectionMode"] != nil)
    {
        self.tiltDirectionMode = [appExecutive.defaults objectForKey:@"tiltDirectionMode"];
    }
    
    if (distance1 != 0 || distance2 != 0 || distance3 != 0)
    {
        NSLog(@"\n");
        
        NSDictionary *a = [self getDistance:
                                          1:
                        settings.microstep1:
                                  distance1:
                                   slideRig:
                                  slideGear:
                           slideLinearCustom];
        
        NSDictionary *b = [self getDistance:
                                          2:
                        settings.microstep2:
                                  distance2:
                                     panRig:
                                    panGear:
                           panLinearCustom];
        
        NSDictionary *c = [self getDistance:
                                          3:
                        settings.microstep3:
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

    int directionMode = [self.slideDirectionMode intValue];
    if (inverted1 == 1)
    {
        direction = [DistancePresetViewController leftDirectionLabelForIndex: directionMode];
    }
    else
    {
        direction = [DistancePresetViewController rightDirectionLabelForIndex: directionMode];
    }

    if([slideRig containsString:@"Stage R"] || [slideRig containsString:@"Rotary Custom"])
    {
        displayString = [NSString stringWithFormat:@"%.02f Deg %@", 0.0, direction];
        
        NSString *rp = [NSString stringWithFormat:@"%.02f Deg %@", 0.0, direction];
        
        displayString = [rp stringByReplacingOccurrencesOfString:@"-" withString:@""];
    }
    else
    {
        displayString = [NSString stringWithFormat:@"%.02f In %@", 0.0, direction];
        
        NSString *rp = [NSString stringWithFormat:@"%.02f In %@", 0.0, direction];
        
        displayString = [rp stringByReplacingOccurrencesOfString:@"-" withString:@""];
    }
    
    distanceSlideLbl.text = displayString;

    directionMode = [self.panDirectionMode intValue];
    if (inverted2 == 1)
    {
        direction = [DistancePresetViewController leftDirectionLabelForIndex: directionMode];
    }
    else
    {
        direction = [DistancePresetViewController rightDirectionLabelForIndex: directionMode];
    }

    if([panRig containsString:@"Stage R"] || [panRig containsString:@"Rotary Custom"])
    {
        displayString = [NSString stringWithFormat:@"%.02f Deg %@", 0.0, direction];
        
        NSString *rp = [NSString stringWithFormat:@"%.02f Deg %@", 0.0, direction];
        
        displayString = [rp stringByReplacingOccurrencesOfString:@"-" withString:@""];
    }
    else
    {
        displayString = [NSString stringWithFormat:@"%.02f In %@", 0.0, direction];
        
        NSString *rp = [NSString stringWithFormat:@"%.02f In %@", 0.0, direction];
        
        displayString = [rp stringByReplacingOccurrencesOfString:@"-" withString:@""];
    }
    
    distancePanLbl.text = displayString;

    
    directionMode = [self.tiltDirectionMode intValue];
    if (inverted3 == 1)
    {
        direction = [DistancePresetViewController leftDirectionLabelForIndex: directionMode];
    }
    else
    {
        direction = [DistancePresetViewController rightDirectionLabelForIndex: directionMode];
    }
    
    if([tiltRig containsString:@"Stage R"] || [tiltRig containsString:@"Rotary Custom"])
    {
        displayString = [NSString stringWithFormat:@"%.02f Deg %@", 0.0, direction];
        
        NSString *rp = [NSString stringWithFormat:@"%.02f Deg %@", 0.0, direction];
        
        displayString = [rp stringByReplacingOccurrencesOfString:@"-" withString:@""];
    }
    else
    {
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
    
    if (debugDistance)
    {
        
        NSLog(@"updateInvertUI rigRatioLbl: %@ motor: %i",rigRatioLbl,motor);
        NSLog(@"updateInvertUI degrees: %f motor: %i",degrees,motor);
        
    }

    int directionMode;
    if (motor == 1)
    {
        directionMode = [self.slideDirectionMode intValue];
    }
    else if (motor == 2)
    {
        directionMode = [self.panDirectionMode intValue];
    }
    else
    {
        directionMode = [self.tiltDirectionMode intValue];
    }
    
    NSString *displayString;
    
    if([rigRatioLbl containsString:@"Stage R"] || [rigRatioLbl containsString:@"Rotary Custom"])
    {
        float directionDist = degrees;
        
        if ((directionDist >= 0. && inverted) ||
            (directionDist < 0. && !inverted))
        {
            direction = [DistancePresetViewController leftDirectionLabelForIndex: directionMode];
        }
        else
        {
            direction = [DistancePresetViewController rightDirectionLabelForIndex: directionMode];
        }
        
        displayString = [NSString stringWithFormat:@"%.02f Deg %@", degrees, direction];
        
        NSString *rp = [NSString stringWithFormat:@"%.02f Deg %@", degrees, direction];
        
        displayString = [rp stringByReplacingOccurrencesOfString:@"-" withString:@""];
    }
    else
    {
        float directionDist = inches;
        
        if ((directionDist >= 0. && inverted) ||
            (directionDist < 0. && !inverted))
        {
            direction = [DistancePresetViewController leftDirectionLabelForIndex: directionMode];
        }
        else
        {
            direction = [DistancePresetViewController rightDirectionLabelForIndex: directionMode];
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

    JSDeviceSettings *settings = self.appExecutive.device.settings;
    
    [device motorSet: device.sledMotor Microstep: settings.microstep1];
    [device motorSet: device.panMotor Microstep: settings.microstep2];
    [device motorSet: device.tiltMotor Microstep: settings.microstep3];
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

- (void) handleEnteredBackground: (NSNotification *) notification {

    DDLogDebug(@"handleEnteredBackground");
    
    [self exitJoystickMode];
}

- (void) handleBecomeActive: (NSNotification *) notification {

    DDLogDebug(@"handleBecomeActive");
    
    [self enterJoystickMode];
}

- (void) deviceDisconnect: (id) object {
    
    if (!disconnected) {
        
    NSLog(@"deviceDisconnect popview notification mvc: %@",object);
    
    //[appDelegate.nav popToRootViewControllerAnimated: true];
        
//    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        
//        [self.navigationController popToRootViewControllerAnimated: true];
//    });

        disconnected = YES;

        //mm If connected to multiple - don't go back... see if we can reconnect
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.navigationController popToRootViewControllerAnimated: true];
        });
     
    }

//    [[NSNotificationCenter defaultCenter]
//     postNotificationName:@"showNotificationHost"
//     object:self.restorationIdentifier];
}

//------------------------------------------------------------------------------

#pragma mark - Navigation

- (BOOL) shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    if ([identifier isEqualToString: SegueToActiveDeviceViewController])
    {
        if (self.appExecutive.deviceList.count <= 1)
        {
            return NO;
        }
    }
    
    return YES;
}

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
        msvc.directionLabelMode = self.slideDirectionMode;
        
        [self exitJoystickMode];
        self.showingModalScreen = true;
	}
	else if ([segue.identifier isEqualToString: SegueToPanMotorSettingsViewController])
	{
		MotorSettingsViewController *msvc = segue.destinationViewController;

		msvc.motorName = @"Pan";
		msvc.motorNumber = self.appExecutive.device.panMotor;
        msvc.directionLabelMode = self.panDirectionMode;

        [self exitJoystickMode];
        self.showingModalScreen = true;
    }
	else if ([segue.identifier isEqualToString: SegueToTiltMotorSettingsViewController])
	{
		MotorSettingsViewController *msvc = segue.destinationViewController;

		msvc.motorName = @"Tilt";
		msvc.motorNumber = self.appExecutive.device.tiltMotor;
        msvc.directionLabelMode = self.tiltDirectionMode;
        
        [self exitJoystickMode];
        self.showingModalScreen = true;
    }
    else if ([segue.identifier isEqualToString: SegueToActiveDeviceViewController])
    {
        JSActiveDeviceViewController *advc = segue.destinationViewController;
        advc.mainVC = self;
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
    
    int pos1 = [self.appExecutive.device motorQueryCurrentPosition:1];
    int pos2 = [self.appExecutive.device motorQueryCurrentPosition:2];
    int pos3 = [self.appExecutive.device motorQueryCurrentPosition:3];
    
    JSDeviceSettings *settings = self.appExecutive.device.settings;
    
    settings.start3PSlideDistance = pos1;
    settings.start3PPanDistance = pos2;
    settings.start3PTiltDistance = pos3;
    
    [self convertUnits:1];
    
    settings.start3PSet = 2;
    
    startTotals = settings.start3PSlideDistance + settings.start3PPanDistance + settings.start3PTiltDistance;
    
    if (self.appExecutive.is3P == NO)
    {
        [self.appExecutive.device mainSetStartHere];
        
        settings.start2pSet = 1;
        
        int pos4 = [self.appExecutive.device queryProgramStartPoint:1];
        int pos5 = [self.appExecutive.device queryProgramStartPoint:2];
        int pos6 = [self.appExecutive.device queryProgramStartPoint:3];
        
        settings.startPoint1 = pos4;
        
        settings.startPoint2 = pos5;
        
        settings.startPoint3 = pos6;
        
        start2pTotals = settings.startPoint1 + settings.startPoint2 + settings.startPoint3;
        end2pTotals = settings.endPoint1 + settings.endPoint2 + settings.endPoint3;
        
        if ((start2pTotals != 0 && end2pTotals != 0) || (settings.start2pSet == 1 && settings.end2pSet == 1))
        {
            [UIView animateWithDuration:.4 animations:^{
                
                distanceSlideLbl.alpha = 1;
                distancePanLbl.alpha = 1;
                distanceTiltLbl.alpha = 1;
                
            } completion:^(BOOL finished) {
                
                
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
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    self.sendMotorsTimer = self.sendMotorsTimer;
    
    JSDeviceSettings *settings = self.appExecutive.device.settings;
    
    if (self.appExecutive.is3P == YES)
    {
        [self.appExecutive.device motorSet:1 SetMotorPosition: settings.start3PSlideDistance];
        [self.appExecutive.device motorSet:2 SetMotorPosition: settings.start3PPanDistance];
        [self.appExecutive.device motorSet:3 SetMotorPosition: settings.start3PTiltDistance];
    }
    else
    {
        [self.appExecutive.device mainSendMotorsToStart];
    }
    
    [UIView animateWithDuration:.4 animations:^{
        
        setStartView.alpha = 0;
        
    } completion:^(BOOL finished) {
        
    }];
    
    //[self enterJoystickMode];
    
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
        
        JSDeviceSettings *settings = self.appExecutive.device.settings;
        
        settings.mid3PSlideDistance = [self.appExecutive.device motorQueryCurrentPosition:1];
        settings.mid3PPanDistance = [self.appExecutive.device motorQueryCurrentPosition:2];
        settings.mid3PTiltDistance = [self.appExecutive.device motorQueryCurrentPosition:3];
        
        [self convertUnits:2];
        
        settings.mid3PSet = 2;
        
        midTotals = settings.mid3PSlideDistance + settings.mid3PPanDistance + settings.mid3PTiltDistance;
        
        [UIView animateWithDuration:.4 animations:^{
            
            setMidView.alpha = 0;
            
        } completion:^(BOOL finished) {
            
        }];
        
        [self enterJoystickMode];
    }
}

- (IBAction) goToMidPoint1:(id)sender {
    
    [self exitJoystickMode];
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    self.sendMotorsTimer = self.sendMotorsTimer;

    if (self.appExecutive.is3P == YES)
    {
        JSDeviceSettings *settings = self.appExecutive.device.settings;

        [self.appExecutive.device motorSet:1 SetMotorPosition: settings.mid3PSlideDistance];
        [self.appExecutive.device motorSet:2 SetMotorPosition: settings.mid3PPanDistance];
        [self.appExecutive.device motorSet:3 SetMotorPosition: settings.mid3PTiltDistance];
    }
    
    [UIView animateWithDuration:.4 animations:^{
        
        setMidView.alpha = 0;
        
    } completion:^(BOOL finished) {
        
    }];
    
    //[self enterJoystickMode];
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
    
    int pos1 = [self.appExecutive.device motorQueryCurrentPosition:1];
    int pos2 = [self.appExecutive.device motorQueryCurrentPosition:2];
    int pos3 = [self.appExecutive.device motorQueryCurrentPosition:3];
    
    JSDeviceSettings *settings = self.appExecutive.device.settings;
    
    settings.end3PSlideDistance = pos1;
    settings.end3PPanDistance = pos2;
    settings.end3PTiltDistance = pos3;
    
    [self convertUnits:3];
    
    settings.end3PSet = 2;
    
    endTotals = settings.end3PSlideDistance + settings.end3PPanDistance + settings.end3PTiltDistance;
    
    if (self.appExecutive.is3P == NO)
    {
        [self.appExecutive.device mainSetStopHere];
        
        settings.end2pSet = 1;
        
        int pos4 = [self.appExecutive.device queryProgramEndPoint:1];
        int pos5 = [self.appExecutive.device queryProgramEndPoint:2];
        int pos6 = [self.appExecutive.device queryProgramEndPoint:3];
        
        settings.endPoint1 = pos4;
        settings.endPoint2 = pos5;
        settings.endPoint3 = pos6;
        
        start2pTotals = settings.startPoint1 + settings.startPoint2 + settings.startPoint3;
        end2pTotals = settings.endPoint1 + settings.endPoint2 + settings.endPoint3;
        
        if ((start2pTotals != 0 && end2pTotals != 0) || (settings.start2pSet == 1 && settings.end2pSet == 1))
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
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    self.sendMotorsTimer = self.sendMotorsTimer;

    JSDeviceSettings *settings = self.appExecutive.device.settings;
    
    if (self.appExecutive.is3P == YES)
    {
        [self.appExecutive.device motorSet:1 SetMotorPosition: settings.end3PSlideDistance];
        [self.appExecutive.device motorSet:2 SetMotorPosition: settings.end3PPanDistance];
        [self.appExecutive.device motorSet:3 SetMotorPosition: settings.end3PTiltDistance];
    }
    else
    {
        [self.appExecutive.device motorSendToEndPoint:1];
        [self.appExecutive.device motorSendToEndPoint:2];
        [self.appExecutive.device motorSendToEndPoint:3];
    }

    [UIView animateWithDuration:.4 animations:^{
        
        setStopView.alpha = 0;
        
    } completion:^(BOOL finished) {
        
    }];
    
    //[self enterJoystickMode];
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
    
    [self enterJoystickMode];

	DDLogDebug(@"Slide Button");
}

- (IBAction) handlePanButton: (id) sender {
    
    [self enterJoystickMode];

	DDLogDebug(@"Pan Button");
}

- (IBAction) handleTiltButton: (id) sender {
    
    [self enterJoystickMode];

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
    
    [self enterJoystickMode];
    
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
    
    [self enterJoystickMode];
    
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
    
    [self enterJoystickMode];
    
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
    
    [self enterJoystickMode];

	[UIView animateWithDuration:.4 animations:^{
        
        setStartView.alpha = 1.0;
        
    } completion:^(BOOL finished) {
        
    }];
}

- (IBAction) handleFlipButton: (UIButton *) sender {
    
    [self enterJoystickMode];
    
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
    
    [self enterJoystickMode];
    
    [UIView animateWithDuration:.4 animations:^{
        
        setStopView.alpha = 1.0;
        
    } completion:^(BOOL finished) {
        
    }];
}


- (IBAction)deviceSelectionButtonSelected:(id)sender {
    [self exitJoystickMode];
    self.showingModalScreen = true;
}


- (void) convertUnits : (int)pointIndex {
    
    int convertVal[3];
    
    JSDeviceSettings *settings = self.appExecutive.device.settings;
    
    for(int i = 0; i < 3; i++) {
        
        // The raw value from the controller is queried here
        
        convertVal[i] = [self.appExecutive.device motorQueryCurrentPosition:i+1];
        
        // Get this motor's microsteps
        
        int thisMicros = 0;
        
        switch(i)
        {
            case 0:
                
                thisMicros = settings.microstep1;
                break;
                
            case 1:
                
                thisMicros = settings.microstep2;
                break;
                
            case 2:
                
                thisMicros = settings.microstep3;
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
        settings.scaledStart3PSlideDistance = (float)convertVal[0];
        settings.scaledStart3PPanDistance = (float)convertVal[1];
        settings.scaledStart3PTiltDistance = (float)convertVal[2];
    }
    else if (pointIndex == 2) {
        settings.scaledMid3PSlideDistance = (float)convertVal[0];
        settings.scaledMid3PPanDistance = (float)convertVal[1];
        settings.scaledMid3PTiltDistance = (float)convertVal[2];
    }
    else if (pointIndex == 3) {
        settings.scaledEnd3PSlideDistance = (float)convertVal[0];
        settings.scaledEnd3PPanDistance = (float)convertVal[1];
        settings.scaledEnd3PTiltDistance = (float)convertVal[2];
    }
}

- (void) convertUnits3 : (int)pointIndex {
    
    int convertVal[3];
    
    JSDeviceSettings *settings = self.appExecutive.device.settings;
    
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
                
                thisMicros = settings.microstep1;
                break;
                
            case 1:
                
                thisMicros = settings.microstep2;
                break;
                
            case 2:
                
                thisMicros = settings.microstep3;
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
        settings.scaledStart3PSlideDistance = (float)convertVal[0];
        settings.scaledStart3PPanDistance = (float)convertVal[1];
        settings.scaledStart3PTiltDistance = (float)convertVal[2];
    }
    else if (pointIndex == 2) {
        settings.scaledMid3PSlideDistance = (float)convertVal[0];
        settings.scaledMid3PPanDistance = (float)convertVal[1];
        settings.scaledMid3PTiltDistance = (float)convertVal[2];
    }
    else if (pointIndex == 3) {
        settings.scaledEnd3PSlideDistance = (float)convertVal[0];
        settings.scaledEnd3PPanDistance = (float)convertVal[1];
        settings.scaledEnd3PTiltDistance = (float)convertVal[2];
    }
}

- (float) convertUnits2 : (int)pointIndex : (float)convertVal {
    
    // The raw value from the controller is queried here

    // Get this motor's microsteps
    
    int thisMicros = 0;
    
    JSDeviceSettings *settings = self.appExecutive.device.settings;
    
    switch(pointIndex)
    {
        case 1:
            
            thisMicros = settings.microstep1;
            break;
            
        case 2:
            
            thisMicros = settings.microstep2;
            break;
            
        case 3:
            
            thisMicros = settings.microstep3;
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
    
    [self enterJoystickMode];
    
    [self hideButtonViews];

	//DDLogDebug(@"Next Button");
    
    UIAlertView *alertView;
    
    JSDeviceSettings *settings = self.appExecutive.device.settings;
    
    if (appExecutive.is3P)
    {
        if (settings.start3PSet != 2)
        {
            alertView = [[UIAlertView alloc]
                         initWithTitle:@"3-Point Move"
                         message:@"Please set Start point" delegate:nil
                         cancelButtonTitle:@"OK" otherButtonTitles:nil];
            
            [alertView show];
            
            return;
        }
        
        if (settings.mid3PSet != 2)
        {
            alertView = [[UIAlertView alloc]
                         initWithTitle:@"3-Point Move"
                         message:@"Please set Mid point" delegate:nil
                         cancelButtonTitle:@"OK" otherButtonTitles:nil];
            
            [alertView show];
            
            return;
        }
        
        if (settings.end3PSet != 2)
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
    
    [self enterJoystickMode];
    
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

- (void) handleSendMotorsTimer: (NSTimer *) sender {
    
    bool moving;
    
    moving = [self.appExecutive.device motorQueryRunning: self.appExecutive.device.sledMotor];
    
    if (!moving)
        moving = [self.appExecutive.device motorQueryRunning: self.appExecutive.device.panMotor];
    if (!moving)
        moving = [self.appExecutive.device motorQueryRunning: self.appExecutive.device.tiltMotor];
    
    if (!moving)
    {
        [self.sendMotorsTimer invalidate];
        self.sendMotorsTimer = nil;
        
        //self.startProgramButton.enabled = YES;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            [self enterJoystickMode];
        });
    }
    else
    {
        //NSLog(@"moving");
    }
}

- (void) activeDeviceChanged
{
    [self initViewForDevice];
}


@end
