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
#import "JSDisconnectedDeviceVC.h"


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
@property (strong, nonatomic) IBOutlet UILabel *slideLabel;
@property (strong, nonatomic) IBOutlet UILabel *panLabel;
@property (strong, nonatomic) IBOutlet UILabel *tiltLabel;

@property (nonatomic, retain)	IBOutlet	UISlider *					_dollySlider;
@property (nonatomic, strong)	IBOutlet	UIButton *					settingsButton;
@property (nonatomic, strong)	IBOutlet	UIImageView *				lockAxisIcon;

@property (nonatomic, readonly)				BOOL						lockAxisState;
@property (nonatomic, readonly)				CGFloat						sensitivity;

@property (nonatomic, strong)   IBOutlet    UILabel *                   deviceName;	// TODO: dead code?

@property (nonatomic, strong)               NSTimer *                   controlsTimer;
@property (nonatomic, strong)               NSTimer *                   joystickTimer;
@property (nonatomic, strong)               NSTimer *                   joystickModeTimer;

@property (assign)                          bool                        joystickModeActive;
@property (assign)                          bool                        showingModalScreen;
@property (weak, nonatomic)     IBOutlet    UIImageView *image3P;
@property (strong, nonatomic) IBOutlet UIView *deviceSelectionView;
@property (strong, nonatomic) IBOutlet UITableView *deviceSelectionTableView;

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

@synthesize distancePanLbl,distanceSlideLbl,distanceTiltLbl,trList,trView,brView,brList,tlList,tlView,blList,blView,trList2,tlList2,brList2,blList2,mode3PLbl,uiList,flipButton,image3P,mode3PLbl2,switch2P,joystickViefw,panSliderBG,panSlider,panSliderLbl,tiltSliderBG,tiltSlider,tiltSliderLbl,batteryIcon,ar1,ar2,ar3,setStartView,setStopView,setMid1Btn,setMidView,controlBackground,sendMotorsTimer,goTo1Btn,goToMidBtn,goToStopBtn,setStart1Btn,setStop1Btn;


#pragma mark Public Property Methods

#pragma mark Private Property Methods

- (AppExecutive *) appExecutive {

	if (appExecutive == nil)
		appExecutive = [AppExecutive sharedInstance];

	return appExecutive;
}

- (BOOL) lockAxisState {
	return self.appExecutive.device.settings.lockAxis;
}

- (CGFloat) sensitivity {
    return self.appExecutive.device.settings.sensitivity;
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
    
    self.deviceSelectionView.alpha = 0;
    setStartView.alpha = 0;
    setMidView.alpha = 0;
    setStopView.alpha = 0;
    
    slideButton.titleLabel.numberOfLines = 1;
    slideButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    slideButton.titleLabel.lineBreakMode = NSLineBreakByClipping;
    slideButton.titleLabel.minimumScaleFactor = .5;
    panButton.titleLabel.numberOfLines = 1;
    panButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    panButton.titleLabel.lineBreakMode = NSLineBreakByClipping;
    panButton.titleLabel.minimumScaleFactor = .5;
    panButton.contentEdgeInsets = UIEdgeInsetsMake(0, 5, 0, 5);
    tiltButton.titleLabel.numberOfLines = 1;
    tiltButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    tiltButton.titleLabel.lineBreakMode = NSLineBreakByClipping;
    tiltButton.titleLabel.minimumScaleFactor = .5;

    
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
    if (appExecutive.deviceList.count <2)
    {
        self.currentDeviceButton.hidden = YES;
    }

}

- (void) initViewForDevice
{
    
    slideGear = 19.2032;
    panGear = 19.2032;
    tiltGear = 19.2032;
    
    slideLinearCustom = 0.00;
    panLinearCustom = 0.00;
    tiltLinearCustom = 0.00;
    
    slideRig = @"Stage 1/0";
    panRig = @"Stage R";
    tiltRig = @"Stage R";

    JSDeviceSettings *settings = self.appExecutive.device.settings;
    
    int a = settings.slideMotor;
    int b = settings.panMotor;
    int c = settings.tiltMotor;
    
    float d = settings.slideMotorCustomValue; //slideLinearCustom = 0.00;
    float e = settings.panMotorCustomValue;   //panLinearCustom = 0.00;
    float f = settings.tiltMotorCustomValue;  //tiltLinearCustom = 0.00;
    
    if(a)
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
        else if (a == 4)
        {
            slideRig = @"Sapphire (1:1)";
        }
    }
    
    if(b)
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
        else if (b == 4)
        {
            panRig = @"Sapphire (1:1)";
        }
        
    }
    
    if(c)
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
        else if (c == 4)
        {
            tiltRig = @"Sapphire (1:1)";
        }
    }
    
    switch (settings.slideGear) {
        case 1:
            slideGear = 27.8512;  // 27:1
            break;
        case 2:
            slideGear = 19.2032;  // 19:1
            break;
        case 3:
            slideGear = 5.1818;  // 5:1
            break;
        case 4:
            slideGear = 60;  // 60:1
            break;
        default:
            break;
    }

    switch (settings.panGear) {
        case 1:
            panGear = 27.8512;  // 27:1
            break;
        case 2:
            panGear = 19.2032;  // 19:1
            break;
        case 3:
            panGear = 5.1818;  // 5:1
            break;
        case 4:
            panGear = 60;  // 60:1
            break;
        default:
            break;
    }

    switch (settings.tiltGear) {
        case 1:
            tiltGear = 27.8512;  // 27:1
            break;
        case 2:
            tiltGear = 19.2032;  // 19:1
            break;
        case 3:
            tiltGear = 5.1818;  // 5:1
            break;
        case 4:
            tiltGear = 60;  // 60:1
            break;
        default:
            break;
    }

    slideDirection = settings.slideDirection;
    panDirection = settings.panDirection;
    tiltDirection = settings.tiltDirection;
    
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
        self.deviceSelectionView.alpha = 0;
        
    } completion: nil ];
}

- (void) timerName4 {
	
    if (self.appExecutive.is3P)
    {
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
            
            if (settings.start2pSet == 1)
            {
                self.setStartButton.selected = YES;
            }
            
            if (settings.end2pSet == 1)
            {
                self.setStopButton.selected = YES;
            }
            
            if (settings.start2pSet == 1 && settings.end2pSet == 1) {
                
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
    
    self.appExecutive.is3P = swe.isOn;
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
    
    dominantAxisSwitch.on = [self lockAxisState];
    
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
    
    [self initViewData];
    
    [NSTimer scheduledTimerWithTimeInterval:0.500 target:self selector:@selector(enableInteractions) userInfo:nil repeats:NO];
}

- (void) initViewData
{
    //    self.currentDeviceButton.hidden = (self.appExecutive.deviceList.count < 2);
    NSString *name = [self.appExecutive stringWithHandleForDeviceName: self.appExecutive.device.name];
    [self.currentDeviceButton setTitle:name forState:UIControlStateNormal];
    
    [self setMotorNames];
    
    [self.deviceSelectionTableView reloadData];
}

- (void) setMotorNames
{
    JSDeviceSettings *settings = self.appExecutive.device.settings;

    [slideButton setTitle:settings.channel1Name forState:UIControlStateNormal];
    [panButton setTitle:settings.channel2Name forState:UIControlStateNormal];
    [tiltButton setTitle:settings.channel3Name forState:UIControlStateNormal];

    self.slideLabel.text = [NSString stringWithFormat:@"%@ Control", settings.channel1Name];
    self.panLabel.text = [NSString stringWithFormat:@"%@ Control", settings.channel2Name];
    self.tiltLabel.text = [NSString stringWithFormat:@"%@ Control", settings.channel3Name];
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

- (void)determineKeyframeButtonStates
{
    self.setStartButton.selected = NO;
    self.setStopButton.selected = NO;
    self.flipButton.selected = NO;
    
    JSDeviceSettings *settings = self.appExecutive.device.settings;
    
    bool pc = [self queryDevicePowerCycle];
    
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
        else
        {
            if(settings.start2pSet == 1)
            {
                self.setStartButton.selected = YES;
            }
            
            if(settings.end2pSet == 1)
            {
                self.setStopButton.selected = YES;
            }
        }
    }
    else
    {
        //NSLog(@"reset values");
        
        for (NMXDevice *device in self.appExecutive.deviceList)
        {
            JSDeviceSettings *settings = device.settings;
            
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
            
            settings.maxStepRateSlide = 4000;
            settings.maxStepRateTilt = 4000;
            settings.maxStepRatePan = 4000;
            
            [settings synchronize];
        }
    }
}

- (void) viewDidAppear: (BOOL) animated {
    
    JSDeviceSettings *settings = self.appExecutive.device.settings;
    
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

    [self determineKeyframeButtonStates];
    
	[super viewDidAppear: animated];
    
	// Debug code to bypass main screen

	if (getenv("GOTO_SETUP"))
	{
		[self performSegueWithIdentifier: SegueToSetupViewController sender: self];
	}
    
    self.showingModalScreen = false;

    for (NMXDevice *device in self.appExecutive.deviceList)
    {
        [device mainSetAppMode: true];
    }

    NMXDevice *device = self.appExecutive.device;
    
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
        for (NMXDevice *device in self.appExecutive.deviceList)
        {
            inverted1 = [device motorQueryInvertDirection: 1];
            inverted2 = [device motorQueryInvertDirection: 2];
            inverted3 = [device motorQueryInvertDirection: 3];
            
            [device motorEnable: device.sledMotor];
            [device motorEnable: device.panMotor];
            [device motorEnable: device.tiltMotor];
        
            JSDeviceSettings *settings = device.settings;
            [device motorSet:1 SetMaxStepRate: settings.maxStepRateSlide];
            [device motorSet:2 SetMaxStepRate: settings.maxStepRatePan];
            [device motorSet:3 SetMaxStepRate: settings.maxStepRateTilt];
            
            [self setupMicrosteps];
        }
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

- (BOOL) queryDevicePowerCycle
{
    BOOL cycle = NO;
    
    for(NMXDevice *device in self.appExecutive.deviceList)
    {
        // It is important that we query each device so that the cycle gets reset properly.
        if ([device queryPowerCycle])
        {
            cycle = YES;
        }
    }

    return cycle;
}

- (void) startStopQueryTimer {
    
    [self exitJoystickMode];
    
    for (NMXDevice *device in self.appExecutive.deviceList)
    {
        JSDeviceSettings *settings = device.settings;
    
        settings.startPoint1 = [device queryProgramStartPoint:1];
        settings.endPoint1 = [device queryProgramEndPoint:1];
        
        settings.startPoint2 = [device queryProgramStartPoint:2];
        settings.endPoint2 = [device queryProgramEndPoint:2];
        
        settings.startPoint3 = [device queryProgramStartPoint:3];
        settings.endPoint3 = [device queryProgramEndPoint:3];
        
        // initialize microstep based on the device's last settings
        settings.microstep1 = [device motorQueryMicrostep2:1];
        settings.microstep2 = [device motorQueryMicrostep2:2];
        settings.microstep3 = [device motorQueryMicrostep2:3];

        [settings synchronize];
    }

    JSDeviceSettings *settings = self.appExecutive.device.settings;
    if (appExecutive.is3P == NO && (settings.start2pSet == 1 && settings.end2pSet == 1))
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
    
    [self initViewData];
    
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}

- (void) showVoltage {

    float voltagePercent = [self.appExecutive calculateVoltage: YES];
    
    float offset = 1 - (batteryIcon.frame.size.height * voltagePercent) - .5;

    [batteryView removeFromSuperview];
    
    batteryView = [[UIView alloc] initWithFrame:CGRectMake(batteryIcon.frame.origin.x + 8,
                                                         batteryIcon.frame.origin.y + (batteryIcon.frame.size.height + offset),
                                                         batteryIcon.frame.size.width * .47,
                                                         batteryIcon.frame.size.height * voltagePercent)];
    
    batteryView.backgroundColor = [UIColor colorWithRed:230.0/255 green:234.0/255 blue:239.0/255 alpha:.8];
    
    //NSLog(@"add battery");
    
    [self.view addSubview:batteryView];
    
    [self.view bringSubviewToFront:setStopView];
}

- (void) handleUpdateBatteryViewNotification:(NSNotification *)pNotification {
    
    [batteryView removeFromSuperview];

    float voltagePercent = [self.appExecutive calculateVoltage: YES];
    
    float offset = 1 - (batteryIcon.frame.size.height * voltagePercent) - .5;

    batteryView = [[UIView alloc] initWithFrame:CGRectMake(batteryIcon.frame.origin.x + 7,
                                                           batteryIcon.frame.origin.y + (batteryIcon.frame.size.height + offset),
                                                           batteryIcon.frame.size.width * .5,
                                                           batteryIcon.frame.size.height * voltagePercent)];
    
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

    JSDeviceSettings *settings = self.appExecutive.device.settings;
    
    int directionMode = [settings.slideDirectionMode intValue];
    if (inverted1 == 1)
    {
        direction = [DistancePresetViewController leftDirectionLabelForIndex: directionMode];
    }
    else
    {
        direction = [DistancePresetViewController rightDirectionLabelForIndex: directionMode];
    }

    if([slideRig containsString:@"Stage R"] ||
       [slideRig containsString:@"Sapphire"] ||
       [slideRig containsString:@"Rotary Custom"])
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

    directionMode = [settings.panDirectionMode intValue];
    if (inverted2 == 1)
    {
        direction = [DistancePresetViewController leftDirectionLabelForIndex: directionMode];
    }
    else
    {
        direction = [DistancePresetViewController rightDirectionLabelForIndex: directionMode];
    }

    if([panRig containsString:@"Stage R"] ||
       [panRig containsString:@"Sapphire"] ||
       [panRig containsString:@"Rotary Custom"])
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

    
    directionMode = [settings.tiltDirectionMode intValue];
    if (inverted3 == 1)
    {
        direction = [DistancePresetViewController leftDirectionLabelForIndex: directionMode];
    }
    else
    {
        direction = [DistancePresetViewController rightDirectionLabelForIndex: directionMode];
    }
    
    if([tiltRig containsString:@"Stage R"] ||
       [tiltRig containsString:@"Sapphire"] ||
       [tiltRig containsString:@"Rotary Custom"])
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
    else if ([rigRatioLbl containsString:@"Sapphire"])
    {
        rigRatio = 1.;
        degrees = (distance/microsteps) * reciprocal * rigRatio * 360;
        calculatedValue = degrees;
        
        if (debugDistance) {
            
            NSLog(@"calculatedValue degrees: %f",calculatedValue);
            
        }
        
        
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

    JSDeviceSettings *settings = self.appExecutive.device.settings;
    
    int directionMode;
    if (motor == 1)
    {
        directionMode = [settings.slideDirectionMode intValue];
    }
    else if (motor == 2)
    {
        directionMode = [settings.panDirectionMode intValue];
    }
    else
    {
        directionMode = [settings.tiltDirectionMode intValue];
    }
    
    NSString *displayString;
    
    if([rigRatioLbl containsString:@"Stage R"] ||
       [rigRatioLbl containsString:@"Sapphire"] ||
       [rigRatioLbl containsString:@"Rotary Custom"])
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

    for (NMXDevice *device in self.appExecutive.deviceList)
    {
        JSDeviceSettings *settings = device.settings;
    
        [device motorSet: device.sledMotor Microstep: settings.microstep1];
        [device motorSet: device.panMotor Microstep: settings.microstep2];
        [device motorSet: device.tiltMotor Microstep: settings.microstep3];
    }
}

- (void) enterJoystickMode {
    
    if (false == self.joystickModeActive)
    {
        for(NMXDevice *device in self.appExecutive.deviceList)
        {
            [device mainSetJoystickMode: true];
            [device mainSetJoystickWatchdog: true];
        }

        //NSLog(@"enterJoystickMode");
        
        self.joystickModeActive = true;
        
        self.joystickModeTimer = [NSTimer scheduledTimerWithTimeInterval: 4.0
                                                                  target: self
                                                                selector: @selector(exitJoystickMode)
                                                                userInfo: nil
                                                                 repeats: NO];

    }
    else
    {
        if (self.joystickModeTimer)
        {
            //NSLog(@"Reschedule JOYSTICK Timer");
            [self.joystickModeTimer invalidate];
            self.joystickModeTimer = [NSTimer scheduledTimerWithTimeInterval: 4.0
                                                                      target: self
                                                                    selector: @selector(exitJoystickMode)
                                                                    userInfo: nil
                                                                     repeats: NO];

        }
    }
}

- (void) exitJoystickMode {
    
    if (self.joystickModeActive)
    {
        for(NMXDevice *device in self.appExecutive.deviceList)
        {
            [device mainSetJoystickMode: false];
        }
        self.joystickModeActive = false;
        
        //NSLog(@"exitJoystickMode");

    }
    
    [self.joystickModeTimer invalidate];
    self.joystickModeTimer = nil;

}

- (void) handleEnteredBackground: (NSNotification *) notification {

    DDLogDebug(@"handleEnteredBackground");
    
    [self exitJoystickMode];
}

- (void) handleBecomeActive: (NSNotification *) notification {

    DDLogDebug(@"handleBecomeActive");
    
    [self enterJoystickMode];
}

- (void) deviceDisconnect: (NSNotification *) notification
{
    //NMXDevice *device = notification.object;

#if 1
    dispatch_async(dispatch_get_main_queue(), ^{

        
        [self performSegueWithIdentifier: @"DeviceDisconnectedSeque" sender: self];

        //        JSDisconnectedDeviceVC *disconnectedVC = [JSDisconnectedDeviceVC new];
        //[self presentViewController:disconnectedVC animated:YES completion: nil];

    });

#else
    if (!disconnected) {
        
        disconnected = YES;

        //mm If connected to multiple - don't go back... see if we can reconnect
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.navigationController popToRootViewControllerAnimated: true];
        });
     
    }
#endif

//    [[NSNotificationCenter defaultCenter]
//     postNotificationName:@"showNotificationHost"
//     object:self.restorationIdentifier];
}

//------------------------------------------------------------------------------

#pragma mark - Navigation

- (BOOL) shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    return YES;
}

- (void) prepareForSegue: (UIStoryboardSegue *) segue sender: (id) sender {
    
    JSDeviceSettings *settings = self.appExecutive.device.settings;
    
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

		msvc.motorNumber = self.appExecutive.device.sledMotor;
        msvc.directionLabelMode = settings.slideDirectionMode;
        
        [self exitJoystickMode];
        self.showingModalScreen = true;
	}
	else if ([segue.identifier isEqualToString: SegueToPanMotorSettingsViewController])
	{
		MotorSettingsViewController *msvc = segue.destinationViewController;

		msvc.motorNumber = self.appExecutive.device.panMotor;
        msvc.directionLabelMode = settings.panDirectionMode;

        [self exitJoystickMode];
        self.showingModalScreen = true;
    }
	else if ([segue.identifier isEqualToString: SegueToTiltMotorSettingsViewController])
	{
		MotorSettingsViewController *msvc = segue.destinationViewController;

		msvc.motorNumber = self.appExecutive.device.tiltMotor;
        msvc.directionLabelMode = settings.tiltDirectionMode;
        
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
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    dispatch_async(dispatch_get_main_queue(), ^{
    
        [self exitJoystickMode];
    
        for(NMXDevice *device in self.appExecutive.deviceList)
        {
            int pos1 = [device motorQueryCurrentPosition:1];
            int pos2 = [device motorQueryCurrentPosition:2];
            int pos3 = [device motorQueryCurrentPosition:3];
            
            JSDeviceSettings *settings = device.settings;
            
            settings.start3PSlideDistance = pos1;
            settings.start3PPanDistance = pos2;
            settings.start3PTiltDistance = pos3;
            
            [self convertUnits:1 forDevice:device];
            
            settings.start3PSet = 2;

            // 2P settings
            [device mainSetStartHere];
                
            settings.start2pSet = 1;
            
            int pos4 = [device queryProgramStartPoint:1];
            int pos5 = [device queryProgramStartPoint:2];
            int pos6 = [device queryProgramStartPoint:3];
            
            settings.startPoint1 = pos4;
            settings.startPoint2 = pos5;
            settings.startPoint3 = pos6;
            // end 2P
            
            [settings synchronize];
        }
        
        JSDeviceSettings *settings = self.appExecutive.device.settings;
        if (settings.start2pSet == 1 && settings.end2pSet == 1)
        {
            [UIView animateWithDuration:.4 animations:^{
                
                distanceSlideLbl.alpha = 1;
                distancePanLbl.alpha = 1;
                distanceTiltLbl.alpha = 1;
                
            } completion: nil];
        }
        
        [self enterJoystickMode];

        if (self.setStopButton.selected == YES)
        {
            [self updateLabels];
        }

        [MBProgressHUD hideHUDForView:self.view animated:YES];

    });

    [UIView animateWithDuration:.4 animations:^{
        
        setStartView.alpha = 0;
        
    } completion:nil ];
    
}

- (IBAction) goToStartPoint1:(id)sender {
    
    [self exitJoystickMode];
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    self.sendMotorsTimer = self.sendMotorsTimer;
    
    for (NMXDevice *device in self.appExecutive.deviceList)
    {
        JSDeviceSettings *settings = device.settings;
    
        if (self.appExecutive.is3P == YES)
        {
            [device motorSet:1 SetMotorPosition: settings.start3PSlideDistance];
            [device motorSet:2 SetMotorPosition: settings.start3PPanDistance];
            [device motorSet:3 SetMotorPosition: settings.start3PTiltDistance];
        }
        else
        {
            [device mainSendMotorsToStart];
        }
    }
    
    [UIView animateWithDuration:.4 animations:^{
        
        setStartView.alpha = 0;
        
    } completion:^(BOOL finished) {
        
    }];
    
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
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self exitJoystickMode];
            
            flipButton.selected = YES;
            
            for (NMXDevice *device in self.appExecutive.deviceList)
            {
                JSDeviceSettings *settings = device.settings;
                
                settings.mid3PSlideDistance = [device motorQueryCurrentPosition:1];
                settings.mid3PPanDistance = [device motorQueryCurrentPosition:2];
                settings.mid3PTiltDistance = [device motorQueryCurrentPosition:3];
                
                [self convertUnits:2 forDevice:device];
                
                settings.mid3PSet = 2;
                
                [UIView animateWithDuration:.4 animations:^{
                    
                    setMidView.alpha = 0;
                    
                } completion: nil ];
                
                [settings synchronize];
            }
            
            [self enterJoystickMode];
            
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            
        });

    }
}


- (IBAction) goToMidPoint1:(id)sender {
    
    [self exitJoystickMode];
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    self.sendMotorsTimer = self.sendMotorsTimer;

    if (self.appExecutive.is3P == YES)
    {
        for (NMXDevice *device in self.appExecutive.deviceList)
        {
            JSDeviceSettings *settings = device.settings;

            [device motorSet:1 SetMotorPosition: settings.mid3PSlideDistance];
            [device motorSet:2 SetMotorPosition: settings.mid3PPanDistance];
            [device motorSet:3 SetMotorPosition: settings.mid3PTiltDistance];
        }
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
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    dispatch_async(dispatch_get_main_queue(), ^{

        [self exitJoystickMode];

        for (NMXDevice *device in self.appExecutive.deviceList)
        {
            JSDeviceSettings *settings = device.settings;
            
            int pos1 = [device motorQueryCurrentPosition:1];
            int pos2 = [device motorQueryCurrentPosition:2];
            int pos3 = [device motorQueryCurrentPosition:3];
            
            settings.end3PSlideDistance = pos1;
            settings.end3PPanDistance = pos2;
            settings.end3PTiltDistance = pos3;
            
            settings.end3PSet = 2;
            
            [self convertUnits:3 forDevice:device];

            // 2P settings
            [device mainSetStopHere];
            
            settings.end2pSet = 1;
            
            int pos4 = [device queryProgramEndPoint:1];
            int pos5 = [device queryProgramEndPoint:2];
            int pos6 = [device queryProgramEndPoint:3];
            
            settings.endPoint1 = pos4;
            settings.endPoint2 = pos5;
            settings.endPoint3 = pos6;
            
            [settings synchronize];
            // end 2P
        }
        
        if (self.appExecutive.is3P == NO)
        {
            JSDeviceSettings *settings = self.appExecutive.device.settings;
            if (settings.start2pSet == 1 && settings.end2pSet == 1)
            {
                [UIView animateWithDuration:.4 animations:^{
                    
                    distanceSlideLbl.alpha = 1;
                    distancePanLbl.alpha = 1;
                    distanceTiltLbl.alpha = 1;
                    
                } completion: nil ];
            }
        }

        if (self.setStartButton.selected == YES)
        {
            [self updateLabels];
        }

        [self enterJoystickMode];

        [MBProgressHUD hideHUDForView:self.view animated:YES];

    });
    
    [UIView animateWithDuration:.4 animations:^{
        
        setStopView.alpha = 0;
        
    } completion: nil ];
    
}

- (IBAction) goToStopPoint1:(id)sender {
    
    [self exitJoystickMode];
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    self.sendMotorsTimer = self.sendMotorsTimer;

    for (NMXDevice *device in self.appExecutive.deviceList)
    {
        JSDeviceSettings *settings = device.settings;
    
        if (self.appExecutive.is3P == YES)
        {
            [device motorSet:1 SetMotorPosition: settings.end3PSlideDistance];
            [device motorSet:2 SetMotorPosition: settings.end3PPanDistance];
            [device motorSet:3 SetMotorPosition: settings.end3PTiltDistance];
        }
        else
        {
            [device motorSendToEndPoint:1];
            [device motorSendToEndPoint:2];
            [device motorSendToEndPoint:3];
        }
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
    
    [self enterJoystickMode];
    
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
    
    self.appExecutive.device.settings.lockAxis = [NSNumber numberWithBool: sender.on]?YES:NO;
    
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
    
    [self enterJoystickMode];
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
    
    [self enterJoystickMode];
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
    
    [self enterJoystickMode];
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
    
    [UIView animateWithDuration:.4 animations:^{
        
        self.deviceSelectionView.alpha = 1;
        
    } completion: nil ];


}


- (void) convertUnits : (int)pointIndex forDevice:(NMXDevice *)device
{
    
    int convertVal[3];
    
    JSDeviceSettings *settings = device.settings;
    
    for(int i = 0; i < 3; i++) {
        
        // The raw value from the controller is queried here
        
        convertVal[i] = [device motorQueryCurrentPosition:i+1];
        
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

- (IBAction) handleNextButton: (UIButton *) sender {
    
    [self enterJoystickMode];
    
    [self hideButtonViews];

	//DDLogDebug(@"Next Button");
    
    UIAlertView *alertView;

    for (NMXDevice *device in self.appExecutive.deviceList)
    {
        JSDeviceSettings *settings = device.settings;
        [settings synchronize];
    }
    
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
    
    for (NMXDevice *device in self.appExecutive.deviceList)
    {
        JSDeviceSettings *settings = device.settings;
        [device motorSet:1 SetMaxStepRate: settings.maxStepRateSlide];
        [device motorSet:2 SetMaxStepRate: settings.maxStepRatePan];
        [device motorSet:3 SetMaxStepRate: settings.maxStepRateTilt];
    }

    
    [self performSegueWithIdentifier: SegueToSetupViewController sender: self];
}

- (IBAction) handleFireCameraButton: (UIButton *) sender {
    
    [self enterJoystickMode];
    
    [self hideButtonViews];

    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{

        [self exitJoystickMode];
        
        for (NMXDevice *device in self.appExecutive.deviceList)
        {
            [device cameraSetEnable: true];
            [device cameraExposeNow];
        }
        
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
    
    BOOL moving = NO;
    
    for (NMXDevice *device in self.appExecutive.deviceList)
    {
        if (!moving)
            moving = [device motorQueryRunning: device.sledMotor];
    
        if (!moving)
            moving = [device motorQueryRunning: device.panMotor];
        
        if (!moving)
            moving = [device motorQueryRunning: device.tiltMotor];
        
        if (moving) break;
    }
    
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

#pragma mark device selection table view

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.appExecutive.deviceList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *simpleTableIdentifier = @"SimpleTableCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
        cell.contentView.backgroundColor = self.currentDeviceButton.backgroundColor;
        cell.textLabel.font = self.currentDeviceButton.titleLabel.font;
        cell.textLabel.textColor = [UIColor whiteColor];
    }
    
    NSArray<NMXDevice *> *devices = self.appExecutive.deviceList;
    NSString *name = [self.appExecutive stringWithHandleForDeviceName: devices[indexPath.row].name];
    cell.textLabel.text = name;

    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.appExecutive.device == self.appExecutive.deviceList[indexPath.row])
    {
        for (NSInteger j = 0; j < [tableView numberOfSections]; ++j)
        {
            for (NSInteger i = 0; i < [tableView numberOfRowsInSection:j]; ++i)
            {
                UITableViewCell *otherCell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:j]];
                [otherCell setSelected:NO animated:NO];
            }
        }
        
        [cell setSelected:YES animated:NO];
        cell.textLabel.textColor = [UIColor blackColor];
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView cellForRowAtIndexPath:indexPath].textLabel.textColor = [UIColor whiteColor];
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NMXDevice *newDev = self.appExecutive.deviceList[indexPath.row];

    UITableViewCell *selCel = [tableView cellForRowAtIndexPath:indexPath];
    selCel.textLabel.textColor = [UIColor blackColor];

    if (self.appExecutive.device != newDev)
    {
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        
        for (NSInteger j = 0; j < [tableView numberOfSections]; ++j)
        {
            for (NSInteger i = 0; i < [tableView numberOfRowsInSection:j]; ++i)
            {
                UITableViewCell *otherCell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:j]];
                if (selCel != otherCell) [otherCell setSelected:NO animated:NO];
            }
        }
        
        [selCel setSelected:YES animated:NO];

        
        dispatch_async(dispatch_get_main_queue(), ^{
        
            [self.appExecutive setActiveDevice: newDev];
            [self viewDidAppear:NO];

        });
    }
 
    [UIView animateWithDuration:.4 animations:^{
        
        self.deviceSelectionView.alpha = 0;
        
    } completion: nil];
}

@end
