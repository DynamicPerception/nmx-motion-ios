//
//  MotorRampingViewController.m
//  Joystick
//
//  Created by Mark Zykin on 4/7/15.
//  Copyright (c) 2015 Mark Zykin. All rights reserved.
//

#import <CocoaLumberjack/CocoaLumberjack.h>

#import "MotorRampingViewController.h"
#import "MotorRampingView.h"
#import "ReviewStatusViewController.h"
#import "JoyButton.h"
#import "AppExecutive.h"
#import "MBProgressHUD.h"

//------------------------------------------------------------------------------

#pragma mark - Private Interface


@interface MotorRampingViewController () {
    
    BOOL setup;
    BOOL isLocked;
    NSString *currentFrameTarget;
    float sliderValue;
    NSString *slidername;
    
    CGFloat minX;
    CGFloat sliderRange;
    float currentSelectedFrameValue;
    float currentFrameConvertedToFloat;
    int selectedFrameCount;
}

@property (nonatomic, strong)				AppExecutive *		appExecutive;

@property (nonatomic, strong)	IBOutlet	MotorRampingView *	slideView;
@property (nonatomic, strong)	IBOutlet	MotorRampingView *	panView;
@property (nonatomic, strong)	IBOutlet	MotorRampingView *	tiltView;


@property (nonatomic, strong)	IBOutlet	UISlider *	slideIncreaseStart;
@property (nonatomic, strong)	IBOutlet	UISlider *	slideIncreaseFinal;
@property (nonatomic, strong)	IBOutlet	UISlider *	slideDecreaseStart;
@property (nonatomic, strong)	IBOutlet	UISlider *	slideDecreaseFinal;

@property (nonatomic, strong)	IBOutlet	UISlider *	panIncreaseStart;
@property (nonatomic, strong)	IBOutlet	UISlider *	panIncreaseFinal;
@property (nonatomic, strong)	IBOutlet	UISlider *	panDecreaseStart;
@property (nonatomic, strong)	IBOutlet	UISlider *	panDecreaseFinal;

@property (nonatomic, strong)	IBOutlet	UISlider *	tiltIncreaseStart;
@property (nonatomic, strong)	IBOutlet	UISlider *	tiltIncreaseFinal;
@property (nonatomic, strong)	IBOutlet	UISlider *	tiltDecreaseStart;
@property (nonatomic, strong)	IBOutlet	UISlider *	tiltDecreaseFinal;

@property (nonatomic, strong)	IBOutlet	JoyButton *	editProgramButton;
@property (nonatomic, strong)	IBOutlet	JoyButton *	nextButton;

@property (strong, nonatomic) IBOutlet UIButton *lockButton;

@property (strong, nonatomic) IBOutlet UITextField *frameText;

@property (strong, nonatomic) IBOutlet UIView *frameView;

@property (strong, nonatomic) NSMutableArray *increaseSliders;
@property (strong, nonatomic) NSMutableArray *decreaseSliders;

@property (weak, nonatomic) IBOutlet UILabel *frameCount1;
@property (weak, nonatomic) IBOutlet UILabel *frameCount2;
@property (weak, nonatomic) IBOutlet UILabel *frameCount3;

@property JSDeviceSettings *settings;

@end


//------------------------------------------------------------------------------

#pragma mark - Implementation




@implementation MotorRampingViewController

NSArray static	*frameCountStrings = nil;


#pragma mark Static Variables

//NSString	static	*SegueToReviewStatus


#pragma mark Private Property Synthesis

@synthesize appExecutive, lockButton, frameText, frameView, increaseSliders, decreaseSliders, selectedFrameNumber,picker, framePickerView, rampSettingSegment, selectedShotDuration, frameCount1, frameCount2, frameCount3, rampSettingImg,slide3P1Lbl,slide3P2Lbl,slide3P3Lbl,slide3PSlider1,slide3PSlider2,slide3PSlider3,pan3PSlider1,pan3PSlider2,pan3PSlider3,tilt3PSlider1,tilt3PSlider2,tilt3PSlider3,pan3P1Lbl,pan3P2Lbl,pan3P3Lbl,tilt3P1Lbl,tilt3P2Lbl,tilt3P3Lbl,slide3PView,pan3PView,tilt3PView,topHeaderLbl,settingsButton,batteryIcon,contentBG,slideLbl2,slideLbl1,slideLbl3,slideLbl4,panLbl2,panLbl1,panLbl3,panLbl4,tiltLbl2,tiltLbl1,tiltLbl3,tiltLbl4;


#pragma mark Private Property Methods

- (AppExecutive *) appExecutive {
    
    if (appExecutive == nil)
        appExecutive = [AppExecutive sharedInstance];
    
    return appExecutive;
}


//------------------------------------------------------------------------------

#pragma mark - Object Management

- (void) viewDidLoad {
    
    self.picker.delegate = self;
    self.picker.dataSource = self;
    
    self.settings = self.appExecutive.device.settings;

    device = [AppExecutive sharedInstance].device;
    
    [self.appExecutive.device mainSetJoystickMode: false];
    
    //NSLog(@"viewdidload ramping");
    
    programMode = [self.appExecutive.device mainQueryProgramMode];
    
    
    
#if TARGET_IPHONE_SIMULATOR
    
    programMode = NMXProgramModeVideo;
    
#endif
    
    
    //NSLog(@"programMode ramping: %i",programMode);
    
    NSInteger	frameCount;
    
    if(programMode == NMXProgramModeVideo)
    {
        selectedFrameCount = [self.appExecutive.videoLengthNumber intValue];
        frameCount	= [self.appExecutive.videoLengthNumber integerValue];
        
        //NSLog(@"self.videoLengthNumber: %@",self.appExecutive.videoLengthNumber);
    }
    else
    {
        selectedFrameCount = [self.appExecutive.frameCountNumber intValue]; //300
        frameCount	= [self.appExecutive.frameCountNumber integerValue];
    }
    
    //NSLog(@"programMode: %i",programMode);
    NSLog(@"selectedFrameCount: %i",selectedFrameCount);
    
    NSInteger	ones		= frameCount % 10;
    NSInteger	tens		= (frameCount / 10) % 10;
    NSInteger	hundreds	= (frameCount / 100) % 10;
    NSInteger	thousands	= (frameCount / 1000) % 10;
    
    [self.picker selectRow: thousands inComponent: 0 animated: NO];
    [self.picker selectRow: hundreds  inComponent: 1 animated: NO];
    [self.picker selectRow: tens      inComponent: 2 animated: NO];
    [self.picker selectRow: ones      inComponent: 3 animated: NO];
    
    NSMutableArray *strings = [NSMutableArray array];
    
    for (NSInteger index = 0; index < 10; index++)
    {
        [strings addObject: [NSString stringWithFormat: @"%ld", (long)index]];
    }
    
    frameCountStrings = [NSArray arrayWithArray: strings];
    
    increaseSliders = [[NSMutableArray alloc] init];
    decreaseSliders = [[NSMutableArray alloc] init];
    
    rampSettingSegment.selectedSegmentIndex = 0;
    
    masterFrameCount = [self.appExecutive.frameCountNumber floatValue];
    
    if(programMode == NMXProgramModeVideo)
    {
        NSString *a = [ShortDurationViewController stringForShortDuration: [self.appExecutive.videoLengthNumber integerValue]];
        
        frameCount1.text = a;
        frameCount2.text = a;
        frameCount3.text = a;
    }
    else
    {
        frameCount1.text = [NSString stringWithFormat:@"%i",(int)masterFrameCount];
        frameCount2.text = [NSString stringWithFormat:@"%i",(int)masterFrameCount];
        frameCount3.text = [NSString stringWithFormat:@"%i",(int)masterFrameCount];
    }
    
    [self configSliders];
    [self setupSliderFunctions];
    [self addDoneButton];
    
    rampSettingImg.image = [UIImage imageNamed:@"linear.png"];
    
    [NSTimer scheduledTimerWithTimeInterval:1.500 target:self selector:@selector(timerName) userInfo:nil repeats:NO];
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(handleNotification2:)
     name:@"note2" object:nil];
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(handleChosenFrameNotification4:)
     name:@"chooseFrame4" object:nil];
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(handleContinuousFrameNotification:)
     name:@"chooseContinousFrame" object:nil];
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(handleVideoFrameNotification:)
     name:@"chooseVideoFrame" object:nil];
    
    slideLbl1.alpha = 0;
    slideLbl2.alpha = 0;
    slideLbl3.alpha = 0;
    slideLbl4.alpha = 0;
    
    panLbl1.alpha = 0;
    panLbl2.alpha = 0;
    panLbl3.alpha = 0;
    panLbl4.alpha = 0;
    
    tiltLbl1.alpha = 0;
    tiltLbl2.alpha = 0;
    tiltLbl3.alpha = 0;
    tiltLbl4.alpha = 0;
    
    [super viewDidLoad];
}

- (void) timerName {
	
}

#pragma mark - Notifications

- (void) handleContinuousFrameNotification:(NSNotification *)pNotification {
    
    int cs = [pNotification.object intValue];
    
    currentSelectedFrameValue = cs;
    
    [self frameValueSelected];
    
    NSLog(@"handleContinuousFrameNotification result: %i",cs);
}

- (void) handleVideoFrameNotification:(NSNotification *)pNotification {
    
    int cs = [pNotification.object intValue];
    
    currentSelectedFrameValue = cs;
    selectedVideoFrame = cs;
    
    [self frameValueSelected];

    NSLog(@"handleVideoFrameNotification result: %i",cs);
}

- (void) handleNotification2:(NSNotification *)pNotification {
    
    NSLog(@"handled note");
}

- (void) handleChosenFrameNotification4:(NSNotification *)pNotification {
    
    int cs = [pNotification.object intValue];
    
    NSLog(@"handleChosenFrameNotification4: %i",cs);
    
    //frameText.text = [NSString stringWithFormat:@"%i",cs];
    
    currentSelectedFrameValue = cs;
    
    [self frameValueSelected];
}

#pragma mark - Objects

- (void) saveFrame: (NSNumber *)number; {
    
    int cs = [number intValue];
    
    NSLog(@"saveFrame result: %i",cs);
}

- (void) configSliders {
    
    //NSLog(@"randall configSliders");

    NSDictionary *	attributes = @{ NSForegroundColorAttributeName: [UIColor whiteColor] };
    
    [self.rampSettingSegment setTitleTextAttributes: attributes forState: UIControlStateNormal];
    [self.rampSettingSegment setTitleTextAttributes: attributes forState: UIControlStateSelected];
    
    UIColor *	blue	= [UIColor blueColor];
    UIColor *	white	= [UIColor whiteColor];

    // set colors so motion of motor has same color along slider tracks
    
    self.tiltIncreaseStart.minimumTrackTintColor = white;
    self.tiltIncreaseStart.maximumTrackTintColor = blue;
    self.tiltIncreaseFinal.minimumTrackTintColor = blue;
    self.tiltIncreaseFinal.maximumTrackTintColor = white;
    
    self.tiltDecreaseStart.minimumTrackTintColor = white;
    self.tiltDecreaseStart.maximumTrackTintColor = blue;
    self.tiltDecreaseFinal.minimumTrackTintColor = blue;
    self.tiltDecreaseFinal.maximumTrackTintColor = white;
    
    self.slideIncreaseStart.minimumTrackTintColor = white;
    self.slideIncreaseStart.maximumTrackTintColor = blue;
    self.slideIncreaseFinal.minimumTrackTintColor = blue;
    self.slideIncreaseFinal.maximumTrackTintColor = white;
    
    self.slideDecreaseStart.minimumTrackTintColor = white;
    self.slideDecreaseStart.maximumTrackTintColor = blue;
    self.slideDecreaseFinal.minimumTrackTintColor = blue;
    self.slideDecreaseFinal.maximumTrackTintColor = white;
    
    self.panIncreaseStart.minimumTrackTintColor = white;
    self.panIncreaseStart.maximumTrackTintColor = blue;
    self.panIncreaseFinal.minimumTrackTintColor = blue;
    self.panIncreaseFinal.maximumTrackTintColor = white;
    
    self.panDecreaseStart.minimumTrackTintColor = white;
    self.panDecreaseStart.maximumTrackTintColor = blue;
    self.panDecreaseFinal.minimumTrackTintColor = blue;
    self.panDecreaseFinal.maximumTrackTintColor = white;
    
    slide3PSlider1.minimumValue = 1;
    slide3PSlider1.maximumValue = masterFrameCount * .33;
    
    slide3PSlider2.minimumValue = slide3PSlider1.maximumValue + 1;
    slide3PSlider2.maximumValue = masterFrameCount * .75;
    
    slide3PSlider3.minimumValue = slide3PSlider2.maximumValue + 1;
    slide3PSlider3.maximumValue = masterFrameCount;
    
    slide3PSlider1.value = self.settings.slide3PVal1;
    slide3PSlider2.value = self.settings.slide3PVal2;
    slide3PSlider3.value = self.settings.slide3PVal3;
    
    self.settings.slide3PVal1 = slide3PSlider1.value;
    self.settings.slide3PVal2 = slide3PSlider2.value;
    self.settings.slide3PVal3 = slide3PSlider3.value;
    
    if (programMode == NMXProgramModeVideo)
    {
        slide3P1Lbl.text = [NSString stringWithFormat:@"%f",self.settings.slide3PVal1];
        slide3P2Lbl.text = [NSString stringWithFormat:@"%f",self.settings.slide3PVal2];
        slide3P3Lbl.text = [NSString stringWithFormat:@"%f",self.settings.slide3PVal3];
    }
    else
    {
        slide3P1Lbl.text = [NSString stringWithFormat:@"%i",(int)self.settings.slide3PVal1];
        slide3P2Lbl.text = [NSString stringWithFormat:@"%i",(int)self.settings.slide3PVal2];
        slide3P3Lbl.text = [NSString stringWithFormat:@"%i",(int)self.settings.slide3PVal3];
    }
    
    slide3PSlider1.minimumTrackTintColor = blue;
    slide3PSlider1.maximumTrackTintColor = white;
    
    slide3PSlider2.minimumTrackTintColor = white;
    slide3PSlider2.maximumTrackTintColor = white;
    
    slide3PSlider3.minimumTrackTintColor = white;
    slide3PSlider3.maximumTrackTintColor = blue;
    
    //NSLog(@"appExecutive.is3P mr: %i",appExecutive.is3P);
    
    if (appExecutive.is3P == YES)
    {
        if (programMode == NMXProgramModeVideo)
        {
            NSLog(@"is video");
            
            int sd = [self.appExecutive.videoLengthNumber intValue];
                  
            //int sd = [self.appExecutive.shotDurationNumber intValue];
            
            float per1 = (float)self.settings.slide3PVal1/[self.appExecutive.frameCountNumber floatValue];
            float per2 = (float)self.settings.slide3PVal2/[self.appExecutive.frameCountNumber floatValue];
            float per3 = (float)self.settings.slide3PVal3/[self.appExecutive.frameCountNumber floatValue];
            
            NSLog(@"per1: %f",per1);
            NSLog(@"per2: %f",per2);
            NSLog(@"per3: %f",per3);
            
            float val1 = sd * per1;
            float val2 = sd * per2;
            float val3 = sd * per3;
            
            //[SetupViewController stringForTimeDisplay: interval];
            //[ShortDurationViewController stringForShortDuration: (int)val1];
            
            NSString *a = [self stringForTimeDisplay: (int)val1];
            NSString *b = [self stringForTimeDisplay: (int)val2];
            NSString *c = [self stringForTimeDisplay: (int)val3];
            
            slide3P1Lbl.text = a;
            slide3P2Lbl.text = b;
            slide3P3Lbl.text = c;
            
//            slide3P1Lbl.text = [NSString stringWithFormat:@"%i",(int)val1];
//            slide3P2Lbl.text = [NSString stringWithFormat:@"%i",(int)val2];
//            slide3P3Lbl.text = [NSString stringWithFormat:@"%i",(int)val3];
        }
        
        self.slideView.hidden = YES;
        self.panView.hidden = YES;
        self.tiltView.hidden = YES;
        
        frameCount1.hidden = YES;
        frameCount2.hidden = YES;
        frameCount3.hidden = YES;
        
        lockButton.hidden = YES;
        rampSettingSegment.hidden = YES;
        rampSettingImg.hidden = YES;
        topHeaderLbl.text = @"3-Point Keyframes";
    }
    else
    {
        //NSLog(@"is2P");
        
        slide3PView.hidden = YES;
    }
}

- (NSString *) stringForTimeDisplay: (NSInteger) milliseconds {
    
    NSString *	string	= [self stringForTime: milliseconds]; //+1000
    
    return [NSString stringWithFormat: @"%@ s", string];
}

- (NSString *) stringForTime: (NSInteger) milliseconds {
    
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

- (void) viewWillAppear: (BOOL) animated {
    
    [super viewWillAppear: animated];
    
    //NSLog(@"viewWillAppear ramping");
    
    if (NMXRunStatusRunning & [[AppExecutive sharedInstance].device mainQueryRunStatus] ||
        NMXRunStatusRunning & [[AppExecutive sharedInstance].device queryKeyFrameProgramRunState])
    {
        NSLog(@"gotoreview");
        [self showVoltage];
        
        [self performSegueWithIdentifier: kSegueToReviewStatusViewController sender: self];
    }
    else
    {
        [self showVoltage];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(deviceDisconnect:)
                                                 name: kDeviceDisconnectedNotification
                                               object: nil];
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(handleNotification2:)
     name:@"note2" object:nil];
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(handleChosenFrameNotification4:)
     name:@"chooseFrame4" object:nil];
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(handleContinuousFrameNotification:)
     name:@"chooseContinousFrame" object:nil];
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(handleVideoFrameNotification:)
     name:@"chooseVideoFrame" object:nil];

    
    [self.view setNeedsLayout];
    [self.view layoutIfNeeded];
    
    setup = FALSE;
    [self setupSliders];
    
    [settingsButton setTitle: @"\u2699" forState: UIControlStateNormal];
    
    [NSTimer scheduledTimerWithTimeInterval:0.500 target:self selector:@selector(timerName5) userInfo:nil repeats:NO];
}

- (void) timerName5 {
	
    [self setupDisplays];
}

- (void) viewDidAppear: (BOOL) animated {
    
    //[self setupDisplays];
}

- (void) setupDisplays {

    slideLbl1.frame = CGRectMake([self xPositionFromSliderValue:self.slideIncreaseStart]-6, self.slideLbl1.frame.origin.y, slideLbl1.frame.size.width, slideLbl1.frame.size.height);
    
    [slideLbl1 setNeedsDisplay];
    
    slideLbl2.frame = CGRectMake([self xPositionFromSliderValue:self.slideIncreaseFinal]-6, self.slideLbl2.frame.origin.y, slideLbl2.frame.size.width, slideLbl2.frame.size.height);
    
    [slideLbl2 setNeedsDisplay];
    
    slideLbl3.frame = CGRectMake([self xPositionFromSliderValue:self.slideDecreaseStart]-6, self.slideLbl3.frame.origin.y, slideLbl3.frame.size.width, slideLbl3.frame.size.height);
    
    [slideLbl3 setNeedsDisplay];
    
    slideLbl4.frame = CGRectMake([self xPositionFromSliderValue:self.slideDecreaseFinal]-6, self.slideLbl4.frame.origin.y, slideLbl4.frame.size.width, slideLbl4.frame.size.height);
    
    [slideLbl4 setNeedsDisplay];
    
    //pan
    
    panLbl1.frame = CGRectMake([self xPositionFromSliderValue:self.panIncreaseStart]-6, self.panLbl1.frame.origin.y, panLbl1.frame.size.width, panLbl1.frame.size.height);
    
    [panLbl1 setNeedsDisplay];
    
    panLbl2.frame = CGRectMake([self xPositionFromSliderValue:self.panIncreaseFinal]-6, self.panLbl2.frame.origin.y, panLbl2.frame.size.width, panLbl2.frame.size.height);
    
    [panLbl2 setNeedsDisplay];
    
    panLbl3.frame = CGRectMake([self xPositionFromSliderValue:self.panDecreaseStart]-6, self.panLbl3.frame.origin.y, panLbl3.frame.size.width, panLbl3.frame.size.height);
    
    [panLbl3 setNeedsDisplay];
    
    panLbl4.frame = CGRectMake([self xPositionFromSliderValue:self.panDecreaseFinal]-6, self.panLbl4.frame.origin.y, panLbl4.frame.size.width, panLbl4.frame.size.height);
    
    [panLbl4 setNeedsDisplay];
    
    //tilt
    
    tiltLbl1.frame = CGRectMake([self xPositionFromSliderValue:self.tiltIncreaseStart]-6, self.tiltLbl1.frame.origin.y, tiltLbl1.frame.size.width, tiltLbl1.frame.size.height);
    
    [tiltLbl1 setNeedsDisplay];
    
    tiltLbl2.frame = CGRectMake([self xPositionFromSliderValue:self.tiltIncreaseFinal]-6, self.tiltLbl2.frame.origin.y, tiltLbl2.frame.size.width, tiltLbl2.frame.size.height);
    
    [tiltLbl2 setNeedsDisplay];
    
    tiltLbl3.frame = CGRectMake([self xPositionFromSliderValue:self.tiltDecreaseStart]-6, self.tiltLbl3.frame.origin.y, tiltLbl3.frame.size.width, tiltLbl3.frame.size.height);
    
    [tiltLbl3 setNeedsDisplay];
    
    tiltLbl4.frame = CGRectMake([self xPositionFromSliderValue:self.tiltDecreaseFinal]-6, self.tiltLbl4.frame.origin.y, tiltLbl4.frame.size.width, tiltLbl4.frame.size.height);
    
    [tiltLbl4 setNeedsDisplay];
    
    [UIView animateWithDuration:.4 animations:^{
        
        slideLbl1.alpha = 1;
        slideLbl2.alpha = 1;
        slideLbl3.alpha = 1;
        slideLbl4.alpha = 1;
        
        panLbl1.alpha = 1;
        panLbl2.alpha = 1;
        panLbl3.alpha = 1;
        panLbl4.alpha = 1;
        
        tiltLbl1.alpha = 1;
        tiltLbl2.alpha = 1;
        tiltLbl3.alpha = 1;
        tiltLbl4.alpha = 1;
        
        
    } completion:^(BOOL finished) {
        
        [UIView animateWithDuration:.4 animations:^{
            
            
        } completion:^(BOOL finished) {
            
        }];
        
    }];
}

- (float) xPositionFromSliderValue:(UISlider *)aSlider {
    
    float sliderRange2 = aSlider.frame.size.width - aSlider.currentThumbImage.size.width;
    float sliderOrigin = aSlider.frame.origin.x + (aSlider.currentThumbImage.size.width / 2.0);
    
    float sliderValueToPixels = (((aSlider.value - aSlider.minimumValue)/(aSlider.maximumValue - aSlider.minimumValue)) * sliderRange2) + sliderOrigin;
    
    sliderValueToPixels = sliderValueToPixels - (aSlider.currentThumbImage.size.width/2);
    
    return sliderValueToPixels;
}

- (void) showVoltage {
    
    [NSTimer scheduledTimerWithTimeInterval:.500 target:self selector:@selector(showVoltageTimer) userInfo:nil repeats:NO];
}

- (void) showVoltageTimer {
    
    JSDeviceSettings *settings = self.appExecutive.device.settings;
    float newBase = settings.voltageHigh - settings.voltageLow;
    
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
    
    UIView *v = [[UIView alloc] initWithFrame:CGRectMake(batteryIcon.frame.origin.x + 8,
                                                         batteryIcon.frame.origin.y + (batteryIcon.frame.size.height + offset),
                                                         batteryIcon.frame.size.width * .47,
                                                         batteryIcon.frame.size.height * per4)];
    
    v.backgroundColor = [UIColor colorWithRed:230.0/255 green:234.0/255 blue:239.0/255 alpha:.8];
    
    [contentBG addSubview:v];
}

- (void) viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear: animated];
    
    //[[NSNotificationCenter defaultCenter] removeObserver: self];
}

- (void) deviceDisconnect: (id) object {
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"showNotificationHost" object:self.restorationIdentifier];
    
    NSLog(@"deviceDisconnect motor ramping");
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.navigationController popToRootViewControllerAnimated: true];
    });
}

- (void) didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
}

- (void) printRect: (CGRect) frame named: (NSString *) name {
    
    CGPoint	origin	= frame.origin;
    CGSize	size	= frame.size;
    
    DDLogDebug(@"Frame for %@: origin(%g, %g) size(%g, %g)", name, origin.x, origin.y, size.width, size.height);
}

- (void) setFrameForIncreaseSlider: (UISlider *) slider {
    
    CGRect	slideFrame	= slider.frame;
    CGRect	superframe	= slider.superview.frame;
    CGFloat slideMargin	= 8.0;
    CGFloat slideWidth	= (superframe.size.width / 2) - slideMargin + 4;
    CGPoint origin		= CGPointMake(slideMargin - 2, slideFrame.origin.y);
    CGSize	size		= CGSizeMake(slideWidth, slideFrame.size.height);
    
    slideFrame.origin = origin;
    slideFrame.size   = size;
    slider.frame      = slideFrame;
}

- (void) setFrameForDecreaseSlider: (UISlider *) slider {
    
    CGRect	slideFrame	= slider.frame;
    CGRect	superframe	= slider.superview.frame;
    CGFloat slideMargin	= 8.0;
    CGFloat slideWidth	= (superframe.size.width / 2) - slideMargin + 4;
    CGFloat xCenter		= superframe.size.width / 2.0;
    CGPoint origin		= CGPointMake(xCenter - 2, slideFrame.origin.y);
    CGSize	size		= CGSizeMake(slideWidth, slideFrame.size.height);
    
    slideFrame.origin = origin;
    slideFrame.size   = size;
    slider.frame      = slideFrame;
}

- (void) setupSliders {
    
    if (setup == FALSE)
    {
        [self setFrameForIncreaseSlider: self.slideIncreaseStart];
        [self setFrameForIncreaseSlider: self.slideIncreaseFinal];
        [self setFrameForDecreaseSlider: self.slideDecreaseStart];
        [self setFrameForDecreaseSlider: self.slideDecreaseFinal];
        
        [self setFrameForIncreaseSlider: self.panIncreaseStart];
        [self setFrameForIncreaseSlider: self.panIncreaseFinal];
        [self setFrameForDecreaseSlider: self.panDecreaseStart];
        [self setFrameForDecreaseSlider: self.panDecreaseFinal];
        
        [self setFrameForIncreaseSlider: self.tiltIncreaseStart];
        [self setFrameForIncreaseSlider: self.tiltIncreaseFinal];
        [self setFrameForDecreaseSlider: self.tiltDecreaseStart];
        [self setFrameForDecreaseSlider: self.tiltDecreaseFinal];
        
        setup = TRUE;
    }
    
    // get persistent values for slider positions
    
    self.slideIncreaseStart.value = [[self.appExecutive.slideIncreaseValues firstObject] floatValue];
    self.slideIncreaseFinal.value = [[self.appExecutive.slideIncreaseValues lastObject ] floatValue];
    self.slideDecreaseStart.value = [[self.appExecutive.slideDecreaseValues firstObject] floatValue];
    self.slideDecreaseFinal.value = [[self.appExecutive.slideDecreaseValues lastObject ] floatValue];
    
    self.panIncreaseStart.value = [[self.appExecutive.panIncreaseValues firstObject] floatValue];
    self.panIncreaseFinal.value = [[self.appExecutive.panIncreaseValues lastObject ] floatValue];
    self.panDecreaseStart.value = [[self.appExecutive.panDecreaseValues firstObject] floatValue];
    self.panDecreaseFinal.value = [[self.appExecutive.panDecreaseValues lastObject ] floatValue];
    
    self.tiltIncreaseStart.value = [[self.appExecutive.tiltIncreaseValues firstObject] floatValue];
    self.tiltIncreaseFinal.value = [[self.appExecutive.tiltIncreaseValues lastObject ] floatValue];
    self.tiltDecreaseStart.value = [[self.appExecutive.tiltDecreaseValues firstObject] floatValue];
    self.tiltDecreaseFinal.value = [[self.appExecutive.tiltDecreaseValues lastObject ] floatValue];
    
    // set endpoints of lines drawn between slider thumbs
    
    self.slideView.increaseStart = [self locationOfThumb: self.slideIncreaseStart];
    self.slideView.increaseFinal = [self locationOfThumb: self.slideIncreaseFinal];
    self.slideView.decreaseStart = [self locationOfThumb: self.slideDecreaseStart];
    self.slideView.decreaseFinal = [self locationOfThumb: self.slideDecreaseFinal];
    [self.slideView setNeedsDisplay];
    
    self.panView.increaseStart = [self locationOfThumb: self.panIncreaseStart];
    self.panView.increaseFinal = [self locationOfThumb: self.panIncreaseFinal];
    self.panView.decreaseStart = [self locationOfThumb: self.panDecreaseStart];
    self.panView.decreaseFinal = [self locationOfThumb: self.panDecreaseFinal];
    [self.panView setNeedsDisplay];
    
    self.tiltView.increaseStart = [self locationOfThumb: self.tiltIncreaseStart];
    self.tiltView.increaseFinal = [self locationOfThumb: self.tiltIncreaseFinal];
    self.tiltView.decreaseStart = [self locationOfThumb: self.tiltDecreaseStart];
    self.tiltView.decreaseFinal = [self locationOfThumb: self.tiltDecreaseFinal];
    [self.tiltView setNeedsDisplay];
    
    self.slideIncreaseStart.restorationIdentifier = @"slideIncreaseStart";
    self.slideIncreaseFinal.restorationIdentifier = @"slideIncreaseFinal";
    self.slideDecreaseStart.restorationIdentifier = @"slideDecreaseStart";
    self.slideDecreaseFinal.restorationIdentifier = @"slideDecreaseFinal";
    
    self.panIncreaseStart.restorationIdentifier = @"panIncreaseStart";
    self.panIncreaseFinal.restorationIdentifier = @"panIncreaseFinal";
    self.panDecreaseStart.restorationIdentifier = @"panDecreaseStart";
    self.panDecreaseFinal.restorationIdentifier = @"panDecreaseFinal";
    
    self.tiltIncreaseStart.restorationIdentifier = @"tiltIncreaseStart";
    self.tiltIncreaseFinal.restorationIdentifier = @"tiltIncreaseFinal";
    self.tiltDecreaseStart.restorationIdentifier = @"tiltDecreaseStart";
    self.tiltDecreaseFinal.restorationIdentifier = @"tiltDecreaseFinal";
    
    //NSLog(@"(int)self.slideIncreaseValues firstObject: %f",[[self.appExecutive.slideIncreaseValues firstObject] floatValue]);
    
    //float conv = sender.value * (selectedFrameCount/2);
    
    //NSLog(@"(int)self.slideIncreaseStart.value: %i",(int)self.slideIncreaseFinal.value);
    
    //float a = [[self.appExecutive.slideIncreaseValues firstObject] floatValue] * (selectedFrameCount/2);
    
    //NSLog(@"a: %f",a);
    
    //int b = [[self.appExecutive.slideIncreaseValues firstObject] floatValue] * (selectedFrameCount/2);
    
    //NSLog(@"b: %i",b);
    
    s12p = (int)(self.slideIncreaseStart.value * (selectedFrameCount/2));
    
    
    
    slideLbl1.text = [NSString stringWithFormat:@"%i",(int)(self.slideIncreaseStart.value * (selectedFrameCount/2))];
    slideLbl2.text = [NSString stringWithFormat:@"%i",(int)(self.slideIncreaseFinal.value * (selectedFrameCount/2))];
    slideLbl3.text = [NSString stringWithFormat:@"%i",(int)(self.slideDecreaseStart.value * (selectedFrameCount/2)+selectedFrameCount/2)];
    slideLbl4.text = [NSString stringWithFormat:@"%i",(int)(self.slideDecreaseFinal.value * (selectedFrameCount/2)+selectedFrameCount/2)];
    
    panLbl1.text = [NSString stringWithFormat:@"%i",(int)(self.panIncreaseStart.value * (selectedFrameCount/2))];
    panLbl2.text = [NSString stringWithFormat:@"%i",(int)(self.panIncreaseFinal.value * (selectedFrameCount/2))];
    panLbl3.text = [NSString stringWithFormat:@"%i",(int)(self.panDecreaseStart.value * (selectedFrameCount/2)+selectedFrameCount/2)];
    panLbl4.text = [NSString stringWithFormat:@"%i",(int)(self.panDecreaseFinal.value * (selectedFrameCount/2)+selectedFrameCount/2)];
    
    tiltLbl1.text = [NSString stringWithFormat:@"%i",(int)(self.tiltIncreaseStart.value * (selectedFrameCount/2))];
    tiltLbl2.text = [NSString stringWithFormat:@"%i",(int)(self.tiltIncreaseFinal.value * (selectedFrameCount/2))];
    tiltLbl3.text = [NSString stringWithFormat:@"%i",(int)(self.tiltDecreaseStart.value * (selectedFrameCount/2)+selectedFrameCount/2)];
    tiltLbl4.text = [NSString stringWithFormat:@"%i",(int)(self.tiltDecreaseFinal.value * (selectedFrameCount/2)+selectedFrameCount/2)];
    
    
    if (programMode == NMXProgramModeVideo && self.appExecutive.is3P == NO)
    {
        NSLog(@"is video");
        
//        slideLbl1.text = [self convertTime:self.slideIncreaseStart];
//        slideLbl2.text = [self convertTime:self.slideIncreaseFinal];
//        slideLbl3.text = [self convertTime:self.slideDecreaseStart];
//        slideLbl4.text = [self convertTime:self.slideDecreaseFinal];
//        
//        panLbl1.text = [self convertTime:self.panIncreaseStart];
//        panLbl2.text = [self convertTime:self.panIncreaseFinal];
//        panLbl3.text = [self convertTime:self.panDecreaseStart];
//        panLbl4.text = [self convertTime:self.panDecreaseFinal];
//        
//        tiltLbl1.text = [self convertTime:self.tiltIncreaseStart];
//        tiltLbl2.text = [self convertTime:self.tiltIncreaseFinal];
//        tiltLbl3.text = [self convertTime:self.tiltDecreaseStart];
//        tiltLbl4.text = [self convertTime:self.tiltDecreaseFinal];
        
        slideLbl1.text = [self convertTime2:[slideLbl1.text floatValue]];
        slideLbl2.text = [self convertTime2:[slideLbl2.text floatValue]];
        slideLbl3.text = [self convertTime2:[slideLbl3.text floatValue]];
        slideLbl4.text = [self convertTime2:[slideLbl4.text floatValue]];
        
        panLbl1.text = [self convertTime2:[panLbl1.text floatValue]];
        panLbl2.text = [self convertTime2:[panLbl2.text floatValue]];
        panLbl3.text = [self convertTime2:[panLbl3.text floatValue]];
        panLbl4.text = [self convertTime2:[panLbl4.text floatValue]];
        
        tiltLbl1.text = [self convertTime2:[tiltLbl1.text floatValue]];
        tiltLbl2.text = [self convertTime2:[tiltLbl2.text floatValue]];
        tiltLbl3.text = [self convertTime2:[tiltLbl3.text floatValue]];
        tiltLbl4.text = [self convertTime2:[tiltLbl4.text floatValue]];
    }
}

- (NSString *)convertTime2 : (float)val {
    
    //int sd = [self.appExecutive.videoLengthNumber intValue];
    
    int sd = [self.appExecutive.frameCountNumber intValue];
    
    //float per1 = (float)self.appExecutive.slide3PVal1/[self.appExecutive.frameCountNumber floatValue];
    //float val1 = sd * per1;
    
    float per1 = val/[self.appExecutive.frameCountNumber floatValue];
    
    //per1 = val * (selectedFrameCount/2);
    
    NSLog(@"%f per: %f",val,per1);
    
    float val1 = sd * per1;
    
    NSString *a = [self stringForTimeDisplay: (int)val1];
    
    return a;
}

- (NSString *)convertTime : (UISlider *)slider {
    
    //int sd = [self.appExecutive.videoLengthNumber intValue];
    
    int sd = [self.appExecutive.frameCountNumber intValue];
    
    NSLog(@"");
    
    //float per1 = (float)self.appExecutive.slide3PVal1/[self.appExecutive.frameCountNumber floatValue];
    //float val1 = sd * per1;
    
    float per1;
    
    NSString *b;
    
    if ([slider.restorationIdentifier containsString:@"Decrease"]) {
        
        b = [NSString stringWithFormat:@"%@ has final",slider.restorationIdentifier];
        
        //NSLog(@"%@",b);
        
        per1 = slider.value * (selectedFrameCount/2)+selectedFrameCount/2;
    }
    else
    {
        b = [NSString stringWithFormat:@"%@ has start",slider.restorationIdentifier];
        
        //NSLog(@"%@",b);
        
        per1 = slider.value * (selectedFrameCount/2);
    }
    
    //float per1 = (float)self.appExecutive.slide3PVal1/[self.appExecutive.frameCountNumber floatValue];
    
    NSLog(@"slider.value: %f",slider.value);
    NSLog(@"%@ per: %f",slider.restorationIdentifier,per1);
    
    float val1 = sd * per1;
    
    NSString *a = [self stringForTimeDisplay: (int)val1];
    
    return a;
}

//------------------------------------------------------------------------------

#pragma mark - Navigation


- (void) prepareForSegue: (UIStoryboardSegue *) segue sender: (id) sender {

    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if ([segue.identifier isEqualToString: kSegueToReviewStatusViewController])
    {
           // No setup needed
        
        [[NSNotificationCenter defaultCenter] removeObserver: self];
    }
    else if ([segue.identifier isEqualToString:@"FrameCountMotorRamp"])
    {
        FrameCountViewController *secView = [segue destinationViewController];
        
        [secView setIsMotorSegue:YES];
        [secView setCurrentFrameValue:currentSelectedFrameValue];
        [secView setIsRampingScreen:YES];
    }
    else if ([segue.identifier isEqualToString:@"VideoMotorRamp"])
    {
        ShortDurationViewController *secView = [segue destinationViewController];
        [secView setIsMotorSegue:YES];
        [secView setIsSettingVideoFrame:YES];
        [secView setIsMotorSegueVal:currentSelectedFrameValue];
        [secView setSelectedVideoFrame:newVal];
        
    }
    else if ([segue.identifier isEqualToString:@"ContinuousMotorRamp"])
    {
        DurationViewController *secView = [segue destinationViewController];
        [secView setIsMotorSegue:YES];
    }
    else if ([segue.identifier isEqualToString: @"HelpRamping"])
    {
        NSLog(@"HelpSetup");
        
        HelpViewController *msvc = segue.destinationViewController;
        
        [msvc setScreenInd:4];
    }
}

- (IBAction) unwindFromReviewStatusViewController: (UIStoryboardSegue *) segue {
    return;
}

//------------------------------------------------------------------------------

#pragma mark - IBAction Methods

- (IBAction) handleTapGesture: (id) sender {

    [self dismissViewControllerAnimated: YES completion: NULL];
}

- (CGPoint) locationOfThumb: (UISlider *) slider {
    
    CGFloat 	value		= slider.value;
    CGFloat		range		= slider.maximumValue - slider.minimumValue;
    CGRect		totalTrack	= [slider trackRectForBounds: slider.bounds];
    CGFloat		thumbWidth	= 26.0;
    CGRect		thumbTrack	= CGRectInset(totalTrack, thumbWidth / 2.0, 0.0);
    CGFloat		thumbX		= thumbTrack.origin.x + (value / range) * thumbTrack.size.width;
    CGFloat		thumbY		= thumbTrack.origin.y + thumbTrack.size.height / 2.0;
    CGPoint		thumbPoint	= CGPointMake(thumbX, thumbY);
    CGPoint		location	= [slider convertPoint: thumbPoint toView: slider.superview];
    
    //DDLogDebug(@"Thumb: (%g, %g)", location.x, location.y);
    
    return location;
}

#pragma mark Slide Controls

- (IBAction) handleSlideIncreaseStart: (UISlider *) sender {
    
    currentSelectedFrameValue = sender.value * (selectedFrameCount/2);
    
    if (sender.value > self.slideIncreaseFinal.value)
    {
        self.slideIncreaseFinal.value = sender.value;
        
        [self updateSlideIncreaseFinalLabel];
    }
    
    //[self updateFrameText];
    
    NSLog(@"currentSelectedFrameValue: %f",currentSelectedFrameValue);
    
    self.slideView.increaseStart = [self locationOfThumb: sender];
    self.slideView.increaseFinal = [self locationOfThumb: self.slideIncreaseFinal];
    
    //NSLog(@"start %@",self.slideView.increaseStart);
    
    [self.slideView setNeedsDisplay];
    
    [self updateSlideIncreaseStartLabel];
    
    [self saveSlideIncreaseValues];
    
    if (isLocked)
    {
        [self updatePanIncreaseStart:sender];
        [self updateTiltIncreaseStart:sender];
    }
}

- (IBAction) handleSlideIncreaseFinal: (UISlider *) sender {
    
    currentSelectedFrameValue = sender.value * (selectedFrameCount/2);
    
    if (sender.value < self.slideIncreaseStart.value)
    {
        self.slideIncreaseStart.value = sender.value;
        
        [self updateSlideIncreaseStartLabel];
    }
    
    NSLog(@"currentSelectedFrameValue: %f",currentSelectedFrameValue);
    
    self.slideView.increaseStart = [self locationOfThumb: self.slideIncreaseStart];
    self.slideView.increaseFinal = [self locationOfThumb: sender];
    
    [self.slideView setNeedsDisplay];
    
    [self updateSlideIncreaseFinalLabel];
    
    [self saveSlideIncreaseValues];
    
    if (isLocked)
    {
        [self updatePanIncreaseFinal:sender];
        [self updateTiltIncreaseFinal:sender];
    }
}

- (void) saveSlideIncreaseValues {
    
    NSNumber *	startValue	= [NSNumber numberWithFloat: self.slideIncreaseStart.value];
    NSNumber *	finalValue	= [NSNumber numberWithFloat: self.slideIncreaseFinal.value];
    NSArray *	rampValues	= [NSArray arrayWithObjects: startValue, finalValue, nil];
    
    //NSLog(@"rampValues: %@",rampValues);
    
    self.appExecutive.slideIncreaseValues = rampValues;
}

- (IBAction) handleSlideDecreaseStart: (UISlider *) sender {
    
    currentSelectedFrameValue = sender.value * (selectedFrameCount/2)+selectedFrameCount/2;
    
    if (sender.value > self.slideDecreaseFinal.value)
    {
        self.slideDecreaseFinal.value = sender.value;
        
        [self updateSlideDecreaseFinalLabel];
    }
    
    //[self updateFrameText];
    
    NSLog(@"currentSelectedFrameValue: %f",currentSelectedFrameValue);
    //NSLog(@"sender.value: %f",sender.value);
    
    self.slideView.decreaseStart = [self locationOfThumb: sender];
    self.slideView.decreaseFinal = [self locationOfThumb: self.slideDecreaseFinal];
    
    [self.slideView setNeedsDisplay];
    
    [self updateSlideDecreaseStartLabel];
    
    [self saveSlideDecreaseValues];
    
    if (isLocked)
    {
        [self updatePanDecreaseStart:sender];
        [self updateTiltDecreaseStart:sender];
    }
}

- (IBAction) handleSlideDecreaseFinal: (UISlider *) sender {
    
    currentSelectedFrameValue = sender.value * (selectedFrameCount/2)+selectedFrameCount/2;
    
    if (sender.value < self.slideDecreaseStart.value)
    {
        self.slideDecreaseStart.value = sender.value;
        
        [self updateSlideDecreaseStartLabel];
    }
    
    //[self updateFrameText];
    
    NSLog(@"currentSelectedFrameValue: %f",currentSelectedFrameValue);
    
    self.slideView.decreaseStart = [self locationOfThumb: self.slideDecreaseStart];
    self.slideView.decreaseFinal = [self locationOfThumb: sender];
    
    [self.slideView setNeedsDisplay];
    
    [self updateSlideDecreaseFinalLabel];
    
    [self saveSlideDecreaseValues];
    
    if (isLocked)
    {
        [self updatePanDecreaseFinal:sender];
        [self updateTiltDecreaseFinal:sender];
    }
}

- (void) saveSlideDecreaseValues {
    
    NSNumber *	startValue	= [NSNumber numberWithFloat: self.slideDecreaseStart.value];
    NSNumber *	finalValue	= [NSNumber numberWithFloat: self.slideDecreaseFinal.value];
    NSArray *	rampValues	= [NSArray arrayWithObjects: startValue, finalValue, nil];
    
    self.appExecutive.slideDecreaseValues = rampValues;
}

#pragma mark Pan Controls

- (IBAction) handlePanIncreaseStart: (UISlider *) sender {
    
    currentSelectedFrameValue = sender.value * (selectedFrameCount/2);
    
    if (sender.value > self.panIncreaseFinal.value)
    {
        self.panIncreaseFinal.value = sender.value;
        
        [self updatePanIncreaseFinalLabel];
    }
    
    //[self updateFrameText];
    
    //NSLog(@"currentSelectedFrameValue: %f",currentSelectedFrameValue);
    
    self.panView.increaseStart = [self locationOfThumb: sender];
    self.panView.increaseFinal = [self locationOfThumb: self.panIncreaseFinal];
    
    [self.panView setNeedsDisplay];

    [self updatePanIncreaseStartLabel];
    
    [self savePanIncreaseValues];
    
    if (isLocked)
    {
        [self updateSlideIncreaseStart:sender];
        [self updateTiltIncreaseStart:sender];
    }
}

- (IBAction) handlePanIncreaseFinal: (UISlider *) sender {
    
    currentSelectedFrameValue = sender.value * (selectedFrameCount/2);
    
    if (sender.value < self.panIncreaseStart.value)
    {
        self.panIncreaseStart.value = sender.value;
        
        [self updatePanIncreaseStartLabel];
    }
    
    //[self updateFrameText];
    
    //NSLog(@"currentSelectedFrameValue: %f",currentSelectedFrameValue);
    
    self.panView.increaseStart = [self locationOfThumb: self.panIncreaseStart];
    self.panView.increaseFinal = [self locationOfThumb: sender];
    
    [self.panView setNeedsDisplay];
    
    [self updatePanIncreaseFinalLabel];
    
    [self savePanIncreaseValues];
    
    if (isLocked)
    {
        [self updateSlideIncreaseFinal:sender];
        [self updateTiltIncreaseFinal:sender];
    }
}

- (void) savePanIncreaseValues {
    
    NSNumber *	startValue	= [NSNumber numberWithFloat: self.panIncreaseStart.value];
    NSNumber *	finalValue	= [NSNumber numberWithFloat: self.panIncreaseFinal.value];
    NSArray *	rampValues	= [NSArray arrayWithObjects: startValue, finalValue, nil];
    
    self.appExecutive.panIncreaseValues = rampValues;
}

- (IBAction) handlePanDecreaseStart: (UISlider *) sender {
    
    currentSelectedFrameValue = sender.value * (selectedFrameCount/2)+selectedFrameCount/2;
    
    if (sender.value > self.panDecreaseFinal.value)
    {
        self.panDecreaseFinal.value = sender.value;
        
        [self updatePanDecreaseFinalLabel];
    }
    
    //[self updateFrameText];
    
    //NSLog(@"currentSelectedFrameValue: %f",currentSelectedFrameValue);
    
    self.panView.decreaseStart = [self locationOfThumb: sender];
    self.panView.decreaseFinal = [self locationOfThumb: self.panDecreaseFinal];
    
    [self.panView setNeedsDisplay];
    
    [self updatePanDecreaseStartLabel];
    
    [self savePanDecreaseValues];
    
    if (isLocked)
    {
        [self updateSlideDecreaseStart:sender];
        [self updateTiltDecreaseStart:sender];
    }
}

- (IBAction) handlePanDecreaseFinal: (UISlider *) sender {
    
    currentSelectedFrameValue = sender.value * (selectedFrameCount/2)+selectedFrameCount/2;
    
    if (sender.value < self.panDecreaseStart.value)
    {
        self.panDecreaseStart.value = sender.value;
        
        [self updatePanDecreaseStartLabel];
    }
    
    //[self updateFrameText];
    
    //NSLog(@"currentSelectedFrameValue: %f",currentSelectedFrameValue);
    
    self.panView.decreaseStart = [self locationOfThumb: self.panDecreaseStart];
    self.panView.decreaseFinal = [self locationOfThumb: sender];
    
    [self.panView setNeedsDisplay];
    
    [self updatePanDecreaseFinalLabel];
    
    [self savePanDecreaseValues];
    
    if (isLocked)
    {
        [self updateSlideDecreaseFinal:sender];
        [self updateTiltDecreaseFinal:sender];
    }
}

- (void) savePanDecreaseValues {
    
    NSNumber *	startValue	= [NSNumber numberWithFloat: self.panDecreaseStart.value];
    NSNumber *	finalValue	= [NSNumber numberWithFloat: self.panDecreaseFinal.value];
    NSArray *	rampValues	= [NSArray arrayWithObjects: startValue, finalValue, nil];
    
    self.appExecutive.panDecreaseValues = rampValues;
}

#pragma mark Tilt Controls

- (IBAction) handleTiltIncreaseStart: (UISlider *) sender {
    
    currentSelectedFrameValue = sender.value * (selectedFrameCount/2);
    
    if (sender.value > self.tiltIncreaseFinal.value)
    {
        self.tiltIncreaseFinal.value = sender.value;
        
        [self updateTiltIncreaseFinalLabel];
    }
    
    //[self updateFrameText];
    
    //NSLog(@"currentSelectedFrameValue: %f",currentSelectedFrameValue);
    
    self.tiltView.increaseStart = [self locationOfThumb: sender];
    self.tiltView.increaseFinal = [self locationOfThumb: self.tiltIncreaseFinal];
    
    [self.tiltView setNeedsDisplay];
    
    [self updateTiltIncreaseStartLabel];
    
    [self saveTiltIncreaseValues];
    
    if (isLocked)
    {
        [self updateSlideIncreaseStart:sender];
        [self updatePanIncreaseStart:sender];
    }
}

- (IBAction) handleTiltIncreaseFinal: (UISlider *) sender {
    
    currentSelectedFrameValue = sender.value * (selectedFrameCount/2);
    
    if (sender.value < self.tiltIncreaseStart.value)
    {
        self.tiltIncreaseStart.value = sender.value;
        
        [self updateTiltIncreaseStartLabel];
    }
    
    //[self updateFrameText];
    
    //NSLog(@"currentSelectedFrameValue: %f",currentSelectedFrameValue);
    
    self.tiltView.increaseStart = [self locationOfThumb: self.tiltIncreaseStart];
    self.tiltView.increaseFinal = [self locationOfThumb: sender];
    
    [self.tiltView setNeedsDisplay];
    
    [self updateTiltIncreaseFinalLabel];
    
    [self saveTiltIncreaseValues];
    
    if (isLocked)
    {
        [self updateSlideIncreaseFinal:sender];
        [self updatePanIncreaseFinal:sender];
    }
}

- (void) saveTiltIncreaseValues {
    
    NSNumber *	startValue	= [NSNumber numberWithFloat: self.tiltIncreaseStart.value];
    NSNumber *	finalValue	= [NSNumber numberWithFloat: self.tiltIncreaseFinal.value];
    NSArray *	rampValues	= [NSArray arrayWithObjects: startValue, finalValue, nil];
    
    self.appExecutive.tiltIncreaseValues = rampValues;
}

- (IBAction) handleTiltDecreaseStart: (UISlider *) sender {
    
    currentSelectedFrameValue = sender.value * (selectedFrameCount/2)+selectedFrameCount/2;
    
    if (sender.value > self.tiltDecreaseFinal.value)
    {
        self.tiltDecreaseFinal.value = sender.value;
        
        [self updateTiltDecreaseFinalLabel];
    }
    
    //[self updateFrameText];
    
    //NSLog(@"currentSelectedFrameValue: %f",currentSelectedFrameValue);
    
    self.tiltView.decreaseStart = [self locationOfThumb: sender];
    self.tiltView.decreaseFinal = [self locationOfThumb: self.tiltDecreaseFinal];
    
    [self.tiltView setNeedsDisplay];
    
    [self updateTiltDecreaseStartLabel];
    
    [self saveTiltDecreaseValues];
    
    if (isLocked)
    {
        [self updateSlideDecreaseStart:sender];
        [self updatePanDecreaseStart:sender];
    }
}

- (IBAction) handleTiltDecreaseFinal: (UISlider *) sender {
    
    currentSelectedFrameValue = sender.value * (selectedFrameCount/2)+selectedFrameCount/2;
    
    if (sender.value < self.tiltDecreaseStart.value)
    {
        self.tiltDecreaseStart.value = sender.value;
        
        [self updateTiltDecreaseStartLabel];
    }
    
    //[self updateFrameText];
    
    //NSLog(@"currentSelectedFrameValue: %f",currentSelectedFrameValue);
    
    self.tiltView.decreaseStart = [self locationOfThumb: self.tiltDecreaseStart];
    self.tiltView.decreaseFinal = [self locationOfThumb: sender];
    
    [self.tiltView setNeedsDisplay];
    
    [self updateTiltDecreaseFinalLabel];
    
    [self saveTiltDecreaseValues];
    
    if (isLocked)
    {
        [self updateSlideDecreaseFinal:sender];
        [self updatePanDecreaseFinal:sender];
    }
}

- (void) saveTiltDecreaseValues {
    
    NSNumber *	startValue	= [NSNumber numberWithFloat: self.tiltDecreaseStart.value];
    NSNumber *	finalValue	= [NSNumber numberWithFloat: self.tiltDecreaseFinal.value];
    NSArray *	rampValues	= [NSArray arrayWithObjects: startValue, finalValue, nil];
    
    self.appExecutive.tiltDecreaseValues = rampValues;
}

- (IBAction) handleEditProgramButton: (UIButton *) sender {

    return; // unwind
}

- (IBAction) handleNextButton: (UIButton *) sender {

    //NMXDevice * device = [AppExecutive sharedInstance].device;
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    JSDeviceSettings *settings = self.appExecutive.device.settings;
    [settings synchronize];
    
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        UInt32  durationInMS = [device motorQueryShotsTotalTravelTime: device.sledMotor] + [device motorQueryLeadInShotsOrTime: device.sledMotor] + [device motorQueryLeadOutShotsOrTime: device.sledMotor];
        
        UInt32  leadIn, leadOut, accelInMS, decelInMS;
        
        leadIn = durationInMS * self.slideIncreaseStart.value / 2;
        accelInMS = durationInMS * (self.slideIncreaseFinal.value - self.slideIncreaseStart.value) / 2;
        leadOut = durationInMS * (1 - self.slideDecreaseFinal.value) / 2;
        decelInMS = durationInMS * (self.slideDecreaseFinal.value - self.slideDecreaseStart.value) / 2;
        
        [device motorSet: device.sledMotor SetLeadInShotsOrTime: leadIn];
        [device motorSet: device.sledMotor SetProgramAccel: accelInMS];
        [device motorSet: device.sledMotor SetProgramDecel: decelInMS];
        [device motorSet: device.sledMotor SetLeadOutShotsOrTime: leadOut];
        [device motorSet: device.sledMotor SetShotsTotalTravelTime: durationInMS - leadIn - leadOut];
        
        durationInMS = [device motorQueryShotsTotalTravelTime: device.panMotor] + [device motorQueryLeadInShotsOrTime: device.panMotor] + [device motorQueryLeadOutShotsOrTime: device.panMotor];
        leadIn = durationInMS * self.panIncreaseStart.value / 2;
        accelInMS = durationInMS * (self.panIncreaseFinal.value - self.panIncreaseStart.value) / 2;
        leadOut = durationInMS * (1 - self.panDecreaseFinal.value) / 2;
        decelInMS = durationInMS * (self.panDecreaseFinal.value - self.panDecreaseStart.value) / 2;
        
        [device motorSet: device.panMotor SetLeadInShotsOrTime: leadIn];
        [device motorSet: device.panMotor SetProgramAccel: accelInMS];
        [device motorSet: device.panMotor SetProgramDecel: decelInMS];
        [device motorSet: device.panMotor SetLeadOutShotsOrTime: leadOut];
        [device motorSet: device.panMotor SetShotsTotalTravelTime: durationInMS - leadIn - leadOut];
        
        durationInMS = [device motorQueryShotsTotalTravelTime: device.tiltMotor] + [device motorQueryLeadInShotsOrTime: device.tiltMotor] + [device motorQueryLeadOutShotsOrTime: device.tiltMotor];
        leadIn = durationInMS * self.tiltIncreaseStart.value / 2;
        accelInMS = durationInMS * (self.tiltIncreaseFinal.value - self.tiltIncreaseStart.value) / 2;
        leadOut = durationInMS * (1 - self.tiltDecreaseFinal.value) / 2;
        decelInMS = durationInMS * (self.tiltDecreaseFinal.value - self.tiltDecreaseStart.value) / 2;
        
        [device motorSet: device.tiltMotor SetLeadInShotsOrTime: leadIn];
        [device motorSet: device.tiltMotor SetProgramAccel: accelInMS];
        [device motorSet: device.tiltMotor SetProgramDecel: decelInMS];
        [device motorSet: device.tiltMotor SetLeadOutShotsOrTime: leadOut];
        [device motorSet: device.tiltMotor SetShotsTotalTravelTime: durationInMS - leadIn - leadOut];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            
            if (appExecutive.is3P == NO)
            {
                if ((NO == [device motorQueryFeasibility: device.sledMotor]) ||
                    (NO == [device motorQueryFeasibility: device.panMotor]) ||
                    (NO == [device motorQueryFeasibility: device.tiltMotor]))
                {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Too Fast For Motors"
                                                                    message: @"Reduce ramping or lead in/out time"
                                                                   delegate: self
                                                          cancelButtonTitle: @"OK"
                                                          otherButtonTitles: nil];
                    [alert show];
                }
                else
                {
                    [self performSegueWithIdentifier: kSegueToReviewStatusViewController sender: self];
                }
            }
            else
            {
                [self performSegueWithIdentifier: kSegueToReviewStatusViewController sender: self];
            }
        });
    });
}

#pragma mark Randall Updates - Ramp Easing

- (IBAction) handleSlide3PSlider1:(id)sender {
    
    UISlider *s = sender;
    
    self.settings.slide3PVal1 = s.value;
    
    currentSelectedFrameValue = self.settings.slide3PVal1;
    
    NSLog(@"s.value: %f",s.value);
    
    slide3P1Lbl.text = [NSString stringWithFormat:@"%i",(int)self.settings.slide3PVal1];
    
    if (programMode == NMXProgramModeVideo)
    {
        int sd = [self.appExecutive.videoLengthNumber intValue];
        
        //int sd = [self.appExecutive.shotDurationNumber intValue];
        
        float per1 = (float)self.settings.slide3PVal1/[self.appExecutive.frameCountNumber floatValue];
        
        float val1 = sd * per1;
        
        NSLog(@"val1 before: %f",val1);
        
        float val2 = [self roundNumber10:val1];
        
        NSLog(@"val2 after: %f",val2);
        
        //slide3P1Lbl.text = [NSString stringWithFormat:@"%i",(int)val1];
        
        //NSString *a = [ShortDurationViewController stringForShortDuration: (int)val1];
        NSString *a = [self stringForTimeDisplay: (int)val1];
        
        slide3P1Lbl.text = a;
    }
    
    [appExecutive.userDefaults setObject: [NSNumber numberWithFloat:self.settings.slide3PVal1] forKey: @"slide3PVal1"];
    [appExecutive.userDefaults synchronize];
}

- (IBAction) handleSlide3PSlider2:(id)sender {
    
    UISlider *s = sender;
    
    self.settings.slide3PVal2 = s.value;
    
    currentSelectedFrameValue = self.settings.slide3PVal2;
    
    //NSLog(@"slide3PVal2: %f",appExecutive.slide3PVal2);
    
    slide3P2Lbl.text = [NSString stringWithFormat:@"%i",(int)self.settings.slide3PVal2];
    
    if (programMode == NMXProgramModeVideo)
    {
        int sd = [self.appExecutive.videoLengthNumber intValue];
        
        //int sd = [self.appExecutive.shotDurationNumber intValue];
        
        float per2 = (float)self.settings.slide3PVal2/[self.appExecutive.frameCountNumber floatValue];
        
        float val2 = sd * per2;
        
        //slide3P2Lbl.text = [NSString stringWithFormat:@"%i",(int)val2];
        
        //NSString *a = [ShortDurationViewController stringForShortDuration: (int)val2];
        
        NSString *a = [self stringForTimeDisplay: (int)val2];
        
        slide3P2Lbl.text = a;
    }
}

- (IBAction) handleSlide3PSlider3:(id)sender {
    
    UISlider *s = sender;
    
    self.settings.slide3PVal3 = s.value;
    
    currentSelectedFrameValue = self.settings.slide3PVal3;
    
    slide3P3Lbl.text = [NSString stringWithFormat:@"%i",(int)self.settings.slide3PVal3];
    
    //NSLog(@"slide3PVal3: %f",appExecutive.slide3PVal3);
    
    if (programMode == NMXProgramModeVideo)
    {
        int sd = [self.appExecutive.videoLengthNumber intValue];
        
        //int sd = [self.appExecutive.shotDurationNumber intValue];
        
        float per3 = (float)self.settings.slide3PVal3/[self.appExecutive.frameCountNumber floatValue];
        
        float val3 = sd * per3;
        
        //slide3P3Lbl.text = [NSString stringWithFormat:@"%i",(int)val3];
        
        //NSString *a = [ShortDurationViewController stringForShortDuration: (int)val3];
        
        NSString *a = [self stringForTimeDisplay: (int)val3];
        
        slide3P3Lbl.text = a;
    }
}

- (IBAction) updateRampEasingValue:(id)sender {
    
    rampMode = (UInt32)rampSettingSegment.selectedSegmentIndex + 1;
    
    if (rampSettingSegment.selectedSegmentIndex == 0) {
        
        rampSettingImg.image = [UIImage imageNamed:@"linear.png"];
    }
    else if(rampSettingSegment.selectedSegmentIndex == 1) {
        
        rampSettingImg.image = [UIImage imageNamed:@"parabolic.png"];
    }
    else
    {
        rampSettingImg.image = [UIImage imageNamed:@"inverse.png"];
    }
    
    //[device rampingSetEasing: rampMode];
}

#pragma mark Randall Updates - Update Sync Slide Controls

- (IBAction) handleLockButton:(id)sender {
    
    if (isLocked) {
        
        isLocked = false;
        
        [lockButton setTitle:@"Lock" forState:UIControlStateNormal];
    }
    else
    {
        isLocked = true;
        
        [lockButton setTitle:@"Unlock" forState:UIControlStateNormal];
    }
}

- (void) update3PTimer {
    
    NSLog(@"update3PTimer");
}

- (void) updateSlide3PVal1: (UISlider *) slider {
    
//    if (slider.value > appExecutive.slide3PVal1)
//        appExecutive.slide3PVal1 = slider.value;
    
    sliderValue = slider.value;
    slidername = slider.restorationIdentifier;
    
    self.settings.slide3PVal1 = sliderValue;
    
    NSLog(@"upsl3p1 appExecutive.slide3PVal1: %f",self.settings.slide3PVal1);
    
    slide3P1Lbl.text = [NSString stringWithFormat:@"%i",(int)self.settings.slide3PVal1];
    
    if (programMode == NMXProgramModeVideo)
    {
        NSLog(@"upsl3p1 currentSelectedFrameValue: %f",currentSelectedFrameValue);
        NSLog(@"upsl3p1 selectedVideoFrame: %i",selectedVideoFrame);
        
        int sd = [self.appExecutive.videoLengthNumber intValue];
        
        //int sd = [self.appExecutive.shotDurationNumber intValue];
        
        float per1 = (float)self.settings.slide3PVal1/[self.appExecutive.frameCountNumber floatValue];
        
        NSLog(@"upsl3p1 per1: %f",per1);
        
        float val1 = sd * per1;
        
        NSLog(@"upsl3p1 val1: %f",val1);
        
        NSString *a = [self stringForTimeDisplay: (int)val1];
        
        slide3P1Lbl.text = a;
    }
    
    [self.slide3PView setNeedsDisplay];
    
}

- (void) updateSlide3PVal2: (UISlider *) slider {
    
    sliderValue = slider.value;
    slidername = slider.restorationIdentifier;
    
    self.settings.slide3PVal2 = sliderValue;
    
    slide3P2Lbl.text = [NSString stringWithFormat:@"%i",(int)self.settings.slide3PVal2];
    
    if (programMode == NMXProgramModeVideo)
    {
        NSString *a = [self stringForTimeDisplay: (int)selectedVideoFrame];
        
        slide3P2Lbl.text = a;
    }
    
    [self.slide3PView setNeedsDisplay];
    
}

- (void) updateSlide3PVal3: (UISlider *) slider {
    
    sliderValue = slider.value;
    slidername = slider.restorationIdentifier;
    
    self.settings.slide3PVal3 = sliderValue;
    
    slide3P3Lbl.text = [NSString stringWithFormat:@"%i",(int)self.settings.slide3PVal3];
    
    if (programMode == NMXProgramModeVideo)
    {
        NSString *a = [self stringForTimeDisplay: (int)selectedVideoFrame];
        
        slide3P3Lbl.text = a;
    }
    
    [self.slide3PView setNeedsDisplay];
}

//increase start

- (void) updateSlideIncreaseStartLabel
{
    if (programMode == NMXProgramModeVideo) {
        slideLbl1.text = [self convertTime2:currentSelectedFrameValue];
    } else {
        slideLbl1.text = [NSString stringWithFormat:@"%i",(int)currentSelectedFrameValue];
    }

    slideLbl1.frame = CGRectMake([self xPositionFromSliderValue:self.slideIncreaseStart]-6, self.slideLbl1.frame.origin.y, slideLbl1.frame.size.width, slideLbl1.frame.size.height);
    [slideLbl1 setNeedsDisplay];
}

- (void) updatePanIncreaseStartLabel
{
    if (programMode == NMXProgramModeVideo) {
        panLbl1.text = [self convertTime2:currentSelectedFrameValue];
    }
    else {
        panLbl1.text = [NSString stringWithFormat:@"%i",(int)currentSelectedFrameValue];
    }

    panLbl1.frame = CGRectMake([self xPositionFromSliderValue:self.panIncreaseStart]-6, self.panLbl1.frame.origin.y, panLbl1.frame.size.width, panLbl1.frame.size.height);
    [panLbl1 setNeedsDisplay];
}

- (void) updateTiltIncreaseStartLabel
{
    if (programMode == NMXProgramModeVideo) {
        tiltLbl1.text = [self convertTime2:currentSelectedFrameValue];
    }
    else {
        tiltLbl1.text = [NSString stringWithFormat:@"%i",(int)currentSelectedFrameValue];
    }

    tiltLbl1.frame = CGRectMake([self xPositionFromSliderValue:self.tiltIncreaseStart]-6, self.tiltLbl1.frame.origin.y, tiltLbl1.frame.size.width, tiltLbl1.frame.size.height);
    [tiltLbl1 setNeedsDisplay];

}

- (void) updateSlideIncreaseStart: (UISlider *) slider {
    
    if (slider.value > self.slideIncreaseFinal.value)
        self.slideIncreaseFinal.value = slider.value;
    
    sliderValue = slider.value;
    slidername = slider.restorationIdentifier;
    
    self.slideIncreaseStart.value = sliderValue;
    
    self.slideView.increaseStart = [self locationOfThumb: self.slideIncreaseStart];
    self.slideView.increaseFinal = [self locationOfThumb: self.slideIncreaseFinal];
    
    [self.slideView setNeedsDisplay];
    
    slideLbl1.frame = CGRectMake([self xPositionFromSliderValue:slider]-6, self.slideLbl1.frame.origin.y, slideLbl1.frame.size.width, slideLbl1.frame.size.height);
    
    slideLbl1.text = [NSString stringWithFormat:@"%i",(int)currentSelectedFrameValue];
    
    
    [self saveSlideIncreaseValues];
    
    [self updateSlideIncreaseStartLabel];
}

- (void) updatePanIncreaseStart: (UISlider *) slider {
    
    if (slider.value > self.panIncreaseFinal.value)
        self.panIncreaseFinal.value = slider.value;
    
    sliderValue = slider.value;
    slidername = slider.restorationIdentifier;
    
    self.panIncreaseStart.value = sliderValue;
    
    self.panView.increaseStart = [self locationOfThumb: self.panIncreaseStart];
    self.panView.increaseFinal = [self locationOfThumb: self.panIncreaseFinal];
    
    [self.panView setNeedsDisplay];
    [self savePanIncreaseValues];

    [self updatePanIncreaseStartLabel];
}

- (void) updateTiltIncreaseStart: (UISlider *) slider {
    
    if (slider.value > self.tiltIncreaseFinal.value)
        self.tiltIncreaseFinal.value = slider.value;
    
    sliderValue = slider.value;
    slidername = slider.restorationIdentifier;
    
    self.tiltIncreaseStart.value = sliderValue;
    
    self.tiltView.increaseStart = [self locationOfThumb: self.tiltIncreaseStart];
    self.tiltView.increaseFinal = [self locationOfThumb: self.tiltIncreaseFinal];
    
    [self.tiltView setNeedsDisplay];
    [self saveTiltIncreaseValues];
    
    [self updateTiltDecreaseStartLabel];
}

//increase final

- (void) updateSlideIncreaseFinalLabel
{
    if (programMode == NMXProgramModeVideo)
    {
        slideLbl2.text = [self convertTime2:currentSelectedFrameValue];
    }
    else
    {
        slideLbl2.text = [NSString stringWithFormat:@"%i",(int)currentSelectedFrameValue];
    }
    
    slideLbl2.frame = CGRectMake([self xPositionFromSliderValue:self.slideIncreaseFinal]-6, self.slideLbl2.frame.origin.y, slideLbl2.frame.size.width, slideLbl2.frame.size.height);
    [slideLbl2 setNeedsDisplay];
}

- (void) updatePanIncreaseFinalLabel
{
    if (programMode == NMXProgramModeVideo) {
        panLbl2.text = [self convertTime2:currentSelectedFrameValue];
    }
    else {
        panLbl2.text = [NSString stringWithFormat:@"%i",(int)currentSelectedFrameValue];
    }
    
    panLbl2.frame = CGRectMake([self xPositionFromSliderValue:self.panIncreaseFinal]-6, self.panLbl2.frame.origin.y, panLbl2.frame.size.width, panLbl2.frame.size.height);
    [panLbl2 setNeedsDisplay];
}

- (void) updateTiltIncreaseFinalLabel
{
    if (programMode == NMXProgramModeVideo) {
        tiltLbl2.text = [self convertTime2:currentSelectedFrameValue];
    }
    else {
        tiltLbl2.text = [NSString stringWithFormat:@"%i",(int)currentSelectedFrameValue];
    }

    tiltLbl2.frame = CGRectMake([self xPositionFromSliderValue:self.tiltIncreaseFinal]-6, self.tiltLbl2.frame.origin.y, tiltLbl2.frame.size.width, tiltLbl2.frame.size.height);
    [tiltLbl2 setNeedsDisplay];
}


- (void) updateSlideIncreaseFinal: (UISlider *) slider {
    
    if (slider.value < self.slideIncreaseStart.value)
        self.slideIncreaseStart.value = slider.value;
    
    sliderValue = slider.value;
    slidername = slider.restorationIdentifier;
    
    self.slideIncreaseFinal.value = sliderValue;
    
    self.slideView.increaseStart = [self locationOfThumb: self.slideIncreaseStart];
    self.slideView.increaseFinal = [self locationOfThumb: self.slideIncreaseFinal];
    
    [self.slideView setNeedsDisplay];
    [self saveSlideIncreaseValues];
    
    [self updateSlideIncreaseFinalLabel];
}

- (void) updatePanIncreaseFinal: (UISlider *) slider {
    
    if (slider.value < self.panIncreaseStart.value)
        self.panIncreaseStart.value = slider.value;
    
    sliderValue = slider.value;
    slidername = slider.restorationIdentifier;
    
    self.panIncreaseFinal.value = sliderValue;
    
    self.panView.increaseStart = [self locationOfThumb: self.panIncreaseStart];
    self.panView.increaseFinal = [self locationOfThumb: self.panIncreaseFinal];
    
    [self.panView setNeedsDisplay];
    [self savePanIncreaseValues];
    
    [self updatePanIncreaseFinalLabel];
}

- (void) updateTiltIncreaseFinal: (UISlider *) slider {
    
    if (slider.value < self.tiltIncreaseStart.value)
        self.tiltIncreaseStart.value = slider.value;
    
    sliderValue = slider.value;
    slidername = slider.restorationIdentifier;
    
    self.tiltIncreaseFinal.value = sliderValue;
    
    self.tiltView.increaseStart = [self locationOfThumb: self.tiltIncreaseStart];
    self.tiltView.increaseFinal = [self locationOfThumb: self.tiltIncreaseFinal];
    
    [self.tiltView setNeedsDisplay];
    [self saveTiltIncreaseValues];
    
    [self updateTiltIncreaseFinalLabel];
}

//decrease start

- (void) updateSlideDecreaseStartLabel
{
    if (programMode == NMXProgramModeVideo) {
        slideLbl3.text = [self convertTime2:currentSelectedFrameValue];
    }
    else {
        slideLbl3.text = [NSString stringWithFormat:@"%i",(int)currentSelectedFrameValue];
    }

    slideLbl3.frame = CGRectMake([self xPositionFromSliderValue:self.slideDecreaseStart]-6, self.slideLbl3.frame.origin.y, slideLbl3.frame.size.width, slideLbl3.frame.size.height);
    [slideLbl3 setNeedsDisplay];
}


- (void) updatePanDecreaseStartLabel
{
    if (programMode == NMXProgramModeVideo) {
        panLbl3.text = [self convertTime2:currentSelectedFrameValue];
    }
    else {
        panLbl3.text = [NSString stringWithFormat:@"%i",(int)currentSelectedFrameValue];
    }

    panLbl3.frame = CGRectMake([self xPositionFromSliderValue:self.panDecreaseStart]-6, self.panLbl3.frame.origin.y, panLbl3.frame.size.width, panLbl3.frame.size.height);
    [panLbl3 setNeedsDisplay];
}

- (void) updateTiltDecreaseStartLabel
{
    if (programMode == NMXProgramModeVideo) {
        tiltLbl3.text = [self convertTime2:currentSelectedFrameValue];
    }
    else {
        tiltLbl3.text = [NSString stringWithFormat:@"%i",(int)currentSelectedFrameValue];
    }

    tiltLbl3.frame = CGRectMake([self xPositionFromSliderValue:self.tiltDecreaseStart]-6, self.tiltLbl3.frame.origin.y, tiltLbl3.frame.size.width, tiltLbl3.frame.size.height);
    [tiltLbl3 setNeedsDisplay];
}


- (void) updateSlideDecreaseStart: (UISlider *) slider {
    
    if (slider.value > self.slideDecreaseFinal.value)
        self.slideDecreaseFinal.value = slider.value;
    
    sliderValue = slider.value;
    slidername = slider.restorationIdentifier;
    
    self.slideDecreaseStart.value = sliderValue;
    
    self.slideView.decreaseStart = [self locationOfThumb: self.slideDecreaseStart];
    self.slideView.decreaseFinal = [self locationOfThumb: self.slideDecreaseFinal];
    
    [self.slideView setNeedsDisplay];
    [self saveSlideDecreaseValues];
    
    [self updateSlideDecreaseStartLabel];
}

- (void) updatePanDecreaseStart: (UISlider *) slider {
    
    if (slider.value > self.panDecreaseFinal.value)
        self.panDecreaseFinal.value = slider.value;
    
    sliderValue = slider.value;
    slidername = slider.restorationIdentifier;
    
    self.panDecreaseStart.value = sliderValue;
    
    self.panView.decreaseStart = [self locationOfThumb: self.panDecreaseStart];
    self.panView.decreaseFinal = [self locationOfThumb: self.panDecreaseFinal];
    
    [self.panView setNeedsDisplay];
    [self savePanDecreaseValues];
    
    [self updatePanDecreaseStartLabel];
}

- (void) updateTiltDecreaseStart: (UISlider *) slider {
    
    if (slider.value > self.tiltDecreaseFinal.value)
        self.tiltDecreaseFinal.value = slider.value;
    
    sliderValue = slider.value;
    slidername = slider.restorationIdentifier;
    
    self.tiltDecreaseStart.value = sliderValue;
    
    self.tiltView.decreaseStart = [self locationOfThumb: self.tiltDecreaseStart];
    self.tiltView.decreaseFinal = [self locationOfThumb: self.tiltDecreaseFinal];
    
    [self.tiltView setNeedsDisplay];
    [self saveTiltDecreaseValues];
    
    [self updateTiltDecreaseStartLabel];
}

//decrease final

- (void) updateSlideDecreaseFinalLabel
{
    if (programMode == NMXProgramModeVideo) {
        slideLbl4.text = [self convertTime2:currentSelectedFrameValue];
    }
    else {
        slideLbl4.text = [NSString stringWithFormat:@"%i",(int)currentSelectedFrameValue];
    }
    
    slideLbl4.frame = CGRectMake([self xPositionFromSliderValue:self.slideDecreaseFinal]-6, self.slideLbl4.frame.origin.y, slideLbl4.frame.size.width, slideLbl4.frame.size.height);
    [slideLbl4 setNeedsDisplay];
}

- (void) updatePanDecreaseFinalLabel
{
    if (programMode == NMXProgramModeVideo) {
        panLbl4.text = [self convertTime2:currentSelectedFrameValue];
    }
    else {
        panLbl4.text = [NSString stringWithFormat:@"%i",(int)currentSelectedFrameValue];
    }

    panLbl4.frame = CGRectMake([self xPositionFromSliderValue:self.panDecreaseFinal]-6, self.panLbl4.frame.origin.y, panLbl4.frame.size.width, panLbl4.frame.size.height);
    [panLbl4 setNeedsDisplay];
}

- (void) updateTiltDecreaseFinalLabel
{
    if (programMode == NMXProgramModeVideo) {
        tiltLbl4.text = [self convertTime2:currentSelectedFrameValue];
    }
    else {
        tiltLbl4.text = [NSString stringWithFormat:@"%i",(int)currentSelectedFrameValue];
    }

    tiltLbl4.frame = CGRectMake([self xPositionFromSliderValue:self.tiltDecreaseFinal]-6, self.tiltLbl4.frame.origin.y, tiltLbl4.frame.size.width, tiltLbl4.frame.size.height);
    [tiltLbl4 setNeedsDisplay];

}


- (void) updateSlideDecreaseFinal: (UISlider *) slider {
    
    if (slider.value < self.slideDecreaseStart.value)
        self.slideDecreaseStart.value = slider.value;
    
    sliderValue = slider.value;
    slidername = slider.restorationIdentifier;
    
    self.slideDecreaseFinal.value = sliderValue;
    
    self.slideView.decreaseStart = [self locationOfThumb: self.slideDecreaseStart];
    self.slideView.decreaseFinal = [self locationOfThumb: self.slideDecreaseFinal];
    
    [self.slideView setNeedsDisplay];
    [self saveSlideDecreaseValues];
    
    [self updateSlideDecreaseFinalLabel];
}

- (void) updatePanDecreaseFinal: (UISlider *) slider {
    
    if (slider.value < self.panDecreaseStart.value)
        self.panDecreaseStart.value = slider.value;
    
    sliderValue = slider.value;
    slidername = slider.restorationIdentifier;
    
    self.panDecreaseFinal.value = sliderValue;
    
    self.panView.decreaseStart = [self locationOfThumb: self.panDecreaseStart];
    self.panView.decreaseFinal = [self locationOfThumb: self.panDecreaseFinal];
    
    [self.panView setNeedsDisplay];
    [self savePanDecreaseValues];
    
    [self updatePanDecreaseFinalLabel];
}

- (void) updateTiltDecreaseFinal: (UISlider *) slider {
    
    if (slider.value < self.tiltDecreaseStart.value)
        self.tiltDecreaseStart.value = slider.value;
    
    sliderValue = slider.value;
    slidername = slider.restorationIdentifier;
    
    self.tiltDecreaseFinal.value = sliderValue;
    
    self.tiltView.decreaseStart = [self locationOfThumb: self.tiltDecreaseStart];
    self.tiltView.decreaseFinal = [self locationOfThumb: self.tiltDecreaseFinal];
    
    [self.tiltView setNeedsDisplay];
    [self saveTiltDecreaseValues];
    
    [self updateTiltDecreaseFinalLabel];

}

- (IBAction) showFrameText:(id)sender {
    
    UISlider *slider = sender;
    
    currentFrameTarget = slider.restorationIdentifier;
    
    if (appExecutive.is3P && programMode == NMXProgramModeVideo)
    {
        float selected3PVal;
        
        if ([currentFrameTarget isEqualToString:@"3PS"])
        {
            selected3PVal = self.settings.slide3PVal1;
        }
        else if ([currentFrameTarget isEqualToString:@"3PM"])
        {
            selected3PVal = self.settings.slide3PVal2;
        }
        else if ([currentFrameTarget isEqualToString:@"3PE"])
        {
            selected3PVal = self.settings.slide3PVal3;
        }
        
        int sd = [self.appExecutive.videoLengthNumber intValue];
        
        //int sd = [self.appExecutive.shotDurationNumber intValue];
        
        float per1 = selected3PVal/[self.appExecutive.frameCountNumber floatValue];
        
        newVal = sd * per1;
        
        newVal = [self roundNumber10:newVal];
        
        NSLog(@"newVal: %i",newVal);
    }
    
    NSString *framestring = [NSString stringWithFormat:@"%f",currentSelectedFrameValue];
    
    NSLog(@"framestring: %@",framestring);
    
    NSInteger	frameCount	= [framestring integerValue];
    NSInteger	ones		= frameCount % 10;
    NSInteger	tens		= (frameCount / 10) % 10;
    NSInteger	hundreds	= (frameCount / 100) % 10;
    NSInteger	thousands	= (frameCount / 1000) % 10;
    
    [self.picker selectRow: thousands inComponent: 0 animated: NO];
    [self.picker selectRow: hundreds  inComponent: 1 animated: NO];
    [self.picker selectRow: tens      inComponent: 2 animated: NO];
    [self.picker selectRow: ones      inComponent: 3 animated: NO];
    
    
    
    if(programMode == NMXProgramModeVideo)
    {
        //NSLog(@"go to isMotorSegue");
        
        NSLog(@"NMXProgramModeVideo");
        
        [self performSegueWithIdentifier:@"VideoMotorRamp" sender:self];
    }
    else
    {
        NSLog(@"NMXProgramModeSMS");
        
        [self performSegueWithIdentifier:@"FrameCountMotorRamp" sender:self];
        
//        if(programMode == NMXProgramModeTimelapse)
//        {
//            NSLog(@"NMXProgramModeTimelapse");
//            
//            [self performSegueWithIdentifier:@"ContinuousMotorRamp" sender:self];
//        }
//        else
//        {
//            //NMXProgramModeSMS
//            
//            NSLog(@"NMXProgramModeSMS");
//            
//            [self performSegueWithIdentifier:@"FrameCountMotorRamp" sender:self];
//        }        
    }
}

- (float) roundNumber10: (float)val {
    
    float val1 = 10.0 * floor((val/10.0) + 0.5);
    
    return val1;
}

- (IBAction) resetSelectedThumb:(id)sender {
    
    UISlider *slider = sender;
    
    UIImage *w = [self imageWithImage:[UIImage imageNamed:@"thumb3.png"] scaledToSize:CGSizeMake(30.0, 30.0)];
    UIImage *b = [self imageWithImage:[UIImage imageNamed:@"thumbBlue.png"] scaledToSize:CGSizeMake(30.0, 30.0)];
    
    for (UISlider *s in increaseSliders)
    {
        [s setThumbImage:w forState:UIControlStateNormal];
    }
    
    for (UISlider *s in decreaseSliders)
    {
        [s setThumbImage:w forState:UIControlStateNormal];
    }
    
    [slider setThumbImage:b forState:UIControlStateNormal];
    [slider setThumbImage:b forState:UIControlStateHighlighted];
    [slider setThumbImage:b forState:UIControlStateSelected];
    
    NSString *framestring = [NSString stringWithFormat:@"%f",currentSelectedFrameValue];
    
    //frameText.text = framestring;
    
    NSInteger	frameCount	= [framestring integerValue];
    NSInteger	ones		= frameCount % 10;
    NSInteger	tens		= (frameCount / 10) % 10;
    NSInteger	hundreds	= (frameCount / 100) % 10;
    NSInteger	thousands	= (frameCount / 1000) % 10;
    
    [self.picker selectRow: thousands inComponent: 0 animated: NO];
    [self.picker selectRow: hundreds  inComponent: 1 animated: NO];
    [self.picker selectRow: tens      inComponent: 2 animated: NO];
    [self.picker selectRow: ones      inComponent: 3 animated: NO];
    
    currentFrameTarget = slider.restorationIdentifier;
    
    //NSLog(@"slider.restorationIdentifier : %@",slider.restorationIdentifier );
    //NSLog(@"currentFrameTarget: %@",currentFrameTarget);
    
    if (![slider.restorationIdentifier isEqualToString:currentFrameTarget])
    {
        //[self hideFrameText];
    }
}

- (UIImage *) imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize {
    
    //UIGraphicsBeginImageContext(newSize);
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

- (void) hideFrameText {
    
    [UIView animateWithDuration:.2 animations:^{
        
        //frameView.alpha = 0;
        framePickerView.alpha = 0;
        
    } completion:^(BOOL finished) {
        
        [UIView animateWithDuration:.2 animations:^{
    
            
        } completion:^(BOOL finished) {
            
        }];
    }];
}

- (void) frameValueSelected {
    
    if (appExecutive.is3P == YES)
    {
        [self frameSelected3P];
    }
    else
    {
        [self frameSelected2P];
    }
    
    [self hideFrameText];
}

- (void) frameSelected3P {
    
    [self updateOther3PThumbs];
}

- (void) frameSelected2P {
    
    bool increaseSelected = false;
    
    int frameCountHalf = (selectedFrameCount/2);
    
    for (UISlider *a in increaseSliders)
    {
        if ([a.restorationIdentifier isEqualToString:currentFrameTarget])
        {
            //NSLog(@"is increase slider");
            
            currentFrameConvertedToFloat = currentSelectedFrameValue/(selectedFrameCount/2);
            
            increaseSelected = true;
            
            break;
        }
    }
    
    for (UISlider *a in decreaseSliders)
    {
        if ([a.restorationIdentifier isEqualToString:currentFrameTarget])
        {
            float f2 = currentSelectedFrameValue - (selectedFrameCount/2);
            float f3 = f2 / (selectedFrameCount/2);
            
            currentFrameConvertedToFloat = f3;
            
            break;
        }
    }
    
    NSLog(@"%@ currentFrameConvertedToFloat: %f", currentFrameTarget, currentFrameConvertedToFloat);
    
    if (increaseSelected)
    {
        if (currentSelectedFrameValue > selectedFrameCount/2)
        {
            frameText.text = [NSString stringWithFormat:@"%i",frameCountHalf];
        }
    }
    else
    {
        if (currentSelectedFrameValue < selectedFrameCount/2)
        {
            frameText.text = [NSString stringWithFormat:@"%i",frameCountHalf];
        }
    }
    
    [self updateOther2PThumbs];
}

- (void) updateOther3PThumbs {
    
    if (programMode == NMXProgramModeVideo)
    {
        int sd = [self.appExecutive.videoLengthNumber intValue];
        
        //int sd = [self.appExecutive.shotDurationNumber intValue];
        
        //60000 = (15/20) * 80000;
        
        //60000 = x/20 * 80000;
        //60000/80000 = x/20
        //.75 = x / 20
        //.75 * 20 = x;
        //15
        
        //NSLog(@"currentSelectedFrameValue: %f",currentSelectedFrameValue);
        
        float val1 = currentSelectedFrameValue/(float)sd; //60000/80000
        
        NSLog(@"%f/%f = val1: %f",currentSelectedFrameValue,(float)sd,val1);
        
        float val5 = val1 * [self.appExecutive.frameCountNumber floatValue]; //.75 * 20
        
        NSLog(@"%f * %f = val5: %f",val1,[self.appExecutive.frameCountNumber floatValue],val5);
        
//        float val6 = val1 * [self.appExecutive.frameCountNumber floatValue]; //.75 * 20
//        
//        NSLog(@"val6: %f",val6);
        
        currentSelectedFrameValue = val5;
    }
    
    if([currentFrameTarget isEqualToString:@"3PS"])
    {
        NSLog(@"3PS: %f",currentSelectedFrameValue);
        
        slide3PSlider1.value = currentSelectedFrameValue;
        
        self.settings.slide3PVal1 = sliderValue;
        
        [self updateSlide3PVal1:slide3PSlider1];
    }
    else if([currentFrameTarget isEqualToString:@"3PM"])
    {
        NSLog(@"3PM: %f",currentSelectedFrameValue);
        
        slide3PSlider2.value = currentSelectedFrameValue;
        
        [self updateSlide3PVal2:slide3PSlider2];
    }
    else
    {
        NSLog(@"3PE: %f",currentSelectedFrameValue);
        
        slide3PSlider3.value = currentSelectedFrameValue;
        
        [self updateSlide3PVal3:slide3PSlider3];
    }
}

- (void) updateOther2PThumbs {

    if([currentFrameTarget isEqualToString:@"slideIncreaseStart"])
    {
        self.slideIncreaseStart.value = currentFrameConvertedToFloat;
        
        [self updateSlideIncreaseStart:self.slideIncreaseStart];
        
        if (isLocked)
        {
            [self updatePanIncreaseStart:self.slideIncreaseStart];
            [self updateTiltIncreaseStart:self.slideIncreaseStart];
        }
    }
    else if([currentFrameTarget isEqualToString:@"slideIncreaseFinal"])
    {
        self.slideIncreaseFinal.value = currentFrameConvertedToFloat;
        
        [self updateSlideIncreaseFinal:self.slideIncreaseFinal];
        
        if (isLocked) {
            
            [self updatePanIncreaseFinal:self.slideIncreaseFinal];
            [self updateTiltIncreaseFinal:self.slideIncreaseFinal];
        }
    }
    else if([currentFrameTarget isEqualToString:@"slideDecreaseStart"])
    {
        self.slideDecreaseStart.value = currentFrameConvertedToFloat;
        
        [self updateSlideDecreaseStart:self.slideDecreaseStart];
        
        if (isLocked) {
            
            [self updatePanDecreaseStart:self.slideDecreaseStart];
            [self updateTiltDecreaseStart:self.slideDecreaseStart];
        }
    }
    else if([currentFrameTarget isEqualToString:@"slideDecreaseFinal"])
    {
        self.slideDecreaseFinal.value = currentFrameConvertedToFloat;
        
        [self updateSlideDecreaseFinal:self.slideDecreaseFinal];
        
        if (isLocked) {
            
            [self updatePanDecreaseFinal:self.slideDecreaseFinal];
            [self updateTiltDecreaseFinal:self.slideDecreaseFinal];
        }
    }
    else if([currentFrameTarget isEqualToString:@"panIncreaseStart"])
    {
        self.panIncreaseStart.value = currentFrameConvertedToFloat;
        
        [self updatePanIncreaseStart:self.panIncreaseStart];
        
        if (isLocked) {
            
            [self updateSlideIncreaseStart:self.panIncreaseStart];
            [self updateTiltIncreaseStart:self.panIncreaseStart];
        }
    }
    else if([currentFrameTarget isEqualToString:@"panIncreaseFinal"])
    {
        self.panIncreaseFinal.value = currentFrameConvertedToFloat;
        
        [self updatePanIncreaseFinal:self.panIncreaseFinal];
        
        if (isLocked) {
            
            [self updateSlideIncreaseFinal:self.panIncreaseFinal];
            [self updateTiltIncreaseFinal:self.panIncreaseFinal];
        }
    }
    else if([currentFrameTarget isEqualToString:@"panDecreaseStart"])
    {
        self.panDecreaseStart.value = currentFrameConvertedToFloat;
        
        [self updatePanDecreaseStart:self.panDecreaseStart];
        
        if (isLocked) {
            
            [self updateSlideDecreaseStart:self.panDecreaseStart];
            [self updateTiltDecreaseStart:self.panDecreaseStart];
        }
    }
    else if([currentFrameTarget isEqualToString:@"panDecreaseFinal"])
    {
        self.panDecreaseFinal.value = currentFrameConvertedToFloat;
        
        [self updatePanDecreaseFinal:self.panDecreaseFinal];
        
        if (isLocked) {
            
            [self updateSlideDecreaseFinal:self.panDecreaseFinal];
            [self updateTiltDecreaseFinal:self.panDecreaseFinal];
        }
    }
    else if([currentFrameTarget isEqualToString:@"tiltIncreaseStart"])
    {
        self.tiltIncreaseStart.value = currentFrameConvertedToFloat;
        
        [self updateTiltIncreaseStart:self.tiltIncreaseStart];
        
        if (isLocked) {
            
            [self updateSlideIncreaseStart:self.tiltIncreaseStart];
            [self updatePanIncreaseStart:self.tiltIncreaseStart];
        }
    }
    else if([currentFrameTarget isEqualToString:@"tiltIncreaseFinal"])
    {
        self.tiltIncreaseFinal.value = currentFrameConvertedToFloat;
        
        [self updateTiltIncreaseFinal:self.tiltIncreaseFinal];
        
        if (isLocked) {
            
            [self updateSlideIncreaseFinal:self.tiltIncreaseFinal];
            [self updatePanIncreaseFinal:self.tiltIncreaseFinal];
        }
    }
    else if([currentFrameTarget isEqualToString:@"tiltDecreaseStart"])
    {
        self.tiltDecreaseStart.value = currentFrameConvertedToFloat;
        
        [self updateTiltDecreaseStart:self.tiltDecreaseStart];
        
        if (isLocked) {
            
            [self updateSlideDecreaseStart:self.tiltDecreaseStart];
            [self updatePanDecreaseStart:self.tiltDecreaseStart];
        }
    }
    else if([currentFrameTarget isEqualToString:@"tiltDecreaseFinal"])
    {
        self.tiltDecreaseFinal.value = currentFrameConvertedToFloat;
        
        [self updateTiltDecreaseFinal:self.tiltDecreaseFinal];
        
        if (isLocked) {
            
            [self updateSlideDecreaseFinal:self.tiltDecreaseFinal];
            [self updatePanDecreaseFinal:self.tiltDecreaseFinal];
        }
    }
}

- (void) updateFrameText {
    
    frameText.text = [NSString stringWithFormat:@"%f",currentSelectedFrameValue];
}

- (BOOL) textFieldShouldReturn:(UITextField*)textField {
    
    [textField resignFirstResponder];
    
    [NSTimer scheduledTimerWithTimeInterval:0.500 target:self selector:@selector(frameValueSelected) userInfo:nil repeats:NO];
    
    return YES;
}

- (void) addDoneButton {
    
    UIToolbar* keyboardToolbar = [[UIToolbar alloc] init];
    
    [keyboardToolbar sizeToFit];
    
    UIBarButtonItem *flexBarButton = [[UIBarButtonItem alloc]
                                      initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                      target:nil action:nil];
    
    UIBarButtonItem *doneBarButton = [[UIBarButtonItem alloc]
                                      initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                      target:self.view action:nil];
    
    keyboardToolbar.items = @[flexBarButton, doneBarButton];
    self.frameText.inputAccessoryView = keyboardToolbar;
    
    doneBarButton.target = self;
    doneBarButton.action = @selector( doneEditingFrame: );
}

- (IBAction) doneEditingFrame:(id)sender {
    
    //[self.frameText resignFirstResponder];
    
    [self hideFrameText];
    
    [NSTimer scheduledTimerWithTimeInterval:0.250 target:self selector:@selector(frameValueSelected) userInfo:nil repeats:NO];
}

- (void) setupSliderFunctions {

    frameView.alpha = 0;
    framePickerView.alpha = 0;
    
    frameText.delegate = self;
    //frameText.borderStyle = UITextBorderStyleNone;
    
    [self.slideIncreaseStart addTarget:self action:@selector(showFrameText:) forControlEvents:UIControlEventTouchDownRepeat];
    [self.slideDecreaseStart addTarget:self action:@selector(showFrameText:) forControlEvents:UIControlEventTouchDownRepeat];
    [self.slideIncreaseFinal addTarget:self action:@selector(showFrameText:) forControlEvents:UIControlEventTouchDownRepeat];
    [self.slideDecreaseFinal addTarget:self action:@selector(showFrameText:) forControlEvents:UIControlEventTouchDownRepeat];
    
    [self.panIncreaseStart addTarget:self action:@selector(showFrameText:) forControlEvents:UIControlEventTouchDownRepeat];
    [self.panDecreaseStart addTarget:self action:@selector(showFrameText:) forControlEvents:UIControlEventTouchDownRepeat];
    [self.panIncreaseFinal addTarget:self action:@selector(showFrameText:) forControlEvents:UIControlEventTouchDownRepeat];
    [self.panDecreaseFinal addTarget:self action:@selector(showFrameText:) forControlEvents:UIControlEventTouchDownRepeat];
    
    [self.tiltIncreaseStart addTarget:self action:@selector(showFrameText:) forControlEvents:UIControlEventTouchDownRepeat];
    [self.tiltDecreaseStart addTarget:self action:@selector(showFrameText:) forControlEvents:UIControlEventTouchDownRepeat];
    [self.tiltIncreaseFinal addTarget:self action:@selector(showFrameText:) forControlEvents:UIControlEventTouchDownRepeat];
    [self.tiltDecreaseFinal addTarget:self action:@selector(showFrameText:) forControlEvents:UIControlEventTouchDownRepeat];
    
    [self.slideIncreaseStart addTarget:self action:@selector(resetSelectedThumb:) forControlEvents:UIControlEventTouchDown];
    [self.slideDecreaseStart addTarget:self action:@selector(resetSelectedThumb:) forControlEvents:UIControlEventTouchDown];
    [self.slideIncreaseFinal addTarget:self action:@selector(resetSelectedThumb:) forControlEvents:UIControlEventTouchDown];
    [self.slideDecreaseFinal addTarget:self action:@selector(resetSelectedThumb:) forControlEvents:UIControlEventTouchDown];
    
    [self.panIncreaseStart addTarget:self action:@selector(resetSelectedThumb:) forControlEvents:UIControlEventTouchDown];
    [self.panDecreaseStart addTarget:self action:@selector(resetSelectedThumb:) forControlEvents:UIControlEventTouchDown];
    [self.panIncreaseFinal addTarget:self action:@selector(resetSelectedThumb:) forControlEvents:UIControlEventTouchDown];
    [self.panDecreaseFinal addTarget:self action:@selector(resetSelectedThumb:) forControlEvents:UIControlEventTouchDown];
    
    [self.tiltIncreaseStart addTarget:self action:@selector(resetSelectedThumb:) forControlEvents:UIControlEventTouchDown];
    [self.tiltDecreaseStart addTarget:self action:@selector(resetSelectedThumb:) forControlEvents:UIControlEventTouchDown];
    [self.tiltIncreaseFinal addTarget:self action:@selector(resetSelectedThumb:) forControlEvents:UIControlEventTouchDown];
    [self.tiltDecreaseFinal addTarget:self action:@selector(resetSelectedThumb:) forControlEvents:UIControlEventTouchDown];
    
    [increaseSliders addObject:self.slideIncreaseStart];
    [increaseSliders addObject:self.slideIncreaseFinal];
    [increaseSliders addObject:self.panIncreaseStart];
    [increaseSliders addObject:self.panIncreaseFinal];
    [increaseSliders addObject:self.tiltIncreaseStart];
    [increaseSliders addObject:self.tiltIncreaseFinal];
    
    [decreaseSliders addObject:self.slideDecreaseStart];
    [decreaseSliders addObject:self.slideDecreaseFinal];
    [decreaseSliders addObject:self.panDecreaseStart];
    [decreaseSliders addObject:self.panDecreaseFinal];
    [decreaseSliders addObject:self.tiltDecreaseStart];
    [decreaseSliders addObject:self.tiltDecreaseFinal];
    
    [slide3PSlider1 addTarget:self action:@selector(showFrameText:) forControlEvents:UIControlEventTouchDownRepeat];
    [slide3PSlider2 addTarget:self action:@selector(showFrameText:) forControlEvents:UIControlEventTouchDownRepeat];
    [slide3PSlider3 addTarget:self action:@selector(showFrameText:) forControlEvents:UIControlEventTouchDownRepeat];
    
    [pan3PSlider1 addTarget:self action:@selector(showFrameText:) forControlEvents:UIControlEventTouchDownRepeat];
    [pan3PSlider2 addTarget:self action:@selector(showFrameText:) forControlEvents:UIControlEventTouchDownRepeat];
    [pan3PSlider3 addTarget:self action:@selector(showFrameText:) forControlEvents:UIControlEventTouchDownRepeat];
    
    [tilt3PSlider1 addTarget:self action:@selector(showFrameText:) forControlEvents:UIControlEventTouchDownRepeat];
    [tilt3PSlider2 addTarget:self action:@selector(showFrameText:) forControlEvents:UIControlEventTouchDownRepeat];
    [tilt3PSlider3 addTarget:self action:@selector(showFrameText:) forControlEvents:UIControlEventTouchDownRepeat];
    
    UIImage *i = [self imageWithImage:[UIImage imageNamed:@"thumb3.png"] scaledToSize:CGSizeMake(30.0, 30.0)];
    
    for (UISlider *s in increaseSliders) {
        
        [s setThumbImage:i forState:UIControlStateNormal];
        [s setThumbImage:i forState:UIControlStateHighlighted];
        [s setThumbImage:i forState:UIControlStateSelected];
        //[s setThumbTintColor:[UIColor whiteColor]];
    }
    
    for (UISlider *s in decreaseSliders) {
        
        [s setThumbImage:i forState:UIControlStateNormal];
        [s setThumbImage:i forState:UIControlStateHighlighted];
        [s setThumbImage:i forState:UIControlStateSelected];
        //[s setThumbTintColor:[UIColor whiteColor]];
    }
}

#pragma mark - UIPickerViewDelegate Protocol Methods

- (CGFloat) pickerView: (UIPickerView *) pickerView rowHeightForComponent: (NSInteger) component {

    return 21.0;
}

- (CGFloat) pickerView: (UIPickerView *) pickerView widthForComponent: (NSInteger) component {

    return 40.0;
}

- (NSAttributedString *) pickerView: (UIPickerView *) pickerView attributedTitleForRow: (NSInteger) row forComponent: (NSInteger) component {

    NSDictionary *	attributes	=  @{ NSForegroundColorAttributeName: [UIColor whiteColor]};
    NSString *		string		= [frameCountStrings objectAtIndex: row];
    
    return [[NSAttributedString alloc] initWithString: string attributes: attributes];
}

- (void) pickerView: (UIPickerView *) pickerView didSelectRow: (NSInteger) row inComponent: (NSInteger) component {

    NSInteger	thousands	= [self.picker selectedRowInComponent: 0];
    NSInteger	hundreds	= [self.picker selectedRowInComponent: 1];
    NSInteger	tens		= [self.picker selectedRowInComponent: 2];
    NSInteger	ones		= [self.picker selectedRowInComponent: 3];
    NSInteger	frameCount	= (thousands * 1000) + (hundreds * 100) + (tens * 10) + ones;
    
    NSString *framestring = [NSString stringWithFormat:@"%@",[NSNumber numberWithInteger: frameCount]];
    
    frameText.text = framestring;
    
    currentSelectedFrameValue = [framestring floatValue];
    
    NSLog(@"currentSelectedFrameValue: %f",currentSelectedFrameValue);
    
    return;
}

//------------------------------------------------------------------------------

#pragma mark - UIPickerViewDataSource Protocol Methods

- (NSInteger) numberOfComponentsInPickerView: (UIPickerView *) pickerView {
    return 4;
}

- (NSInteger) pickerView: (UIPickerView *) pickerView numberOfRowsInComponent: (NSInteger) component {
    return frameCountStrings.count;
}


@end
