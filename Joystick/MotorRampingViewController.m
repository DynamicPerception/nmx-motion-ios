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
#import "JSMotorRampingTableViewCell.h"

//------------------------------------------------------------------------------

#pragma mark - Private Interface


@interface MotorRampingViewController () {
    
    float sliderValue;
    
    CGFloat minX;
    CGFloat sliderRange;

}

@property (nonatomic, strong)				AppExecutive *		appExecutive;

@property (nonatomic, strong)	IBOutlet	JoyButton *	editProgramButton;
@property (nonatomic, strong)	IBOutlet	JoyButton *	nextButton;

@property (strong, nonatomic) IBOutlet UIButton *lockButton;

@property (strong, nonatomic) IBOutlet UITableView *tableView;

@property JSDeviceSettings *settings;


@end


//------------------------------------------------------------------------------

#pragma mark - Implementation




@implementation MotorRampingViewController

NSArray static	*frameCountStrings = nil;


#pragma mark Static Variables

//NSString	static	*SegueToReviewStatus


#pragma mark Private Property Synthesis

@synthesize appExecutive, lockButton, selectedFrameNumber,picker, rampSettingSegment, selectedShotDuration, rampSettingImg,slide3P1Lbl,slide3P2Lbl,slide3P3Lbl,slide3PSlider1,slide3PSlider2,slide3PSlider3,pan3PSlider1,pan3PSlider2,pan3PSlider3,tilt3PSlider1,tilt3PSlider2,tilt3PSlider3,pan3P1Lbl,pan3P2Lbl,pan3P3Lbl,tilt3P1Lbl,tilt3P2Lbl,tilt3P3Lbl,slide3PView,pan3PView,tilt3PView,topHeaderLbl,settingsButton,batteryIcon,contentBG;


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

    [self.appExecutive.device mainSetJoystickMode: false];
    
    //NSLog(@"viewdidload ramping");
    
    self.programMode = [self.appExecutive.device mainQueryProgramMode];
    
    //    self.tableView.rowHeight = 200;
    
#if TARGET_IPHONE_SIMULATOR
    
    self.programMode = NMXProgramModeVideo;
    
#endif
    
    
    //NSLog(@"self.programMode ramping: %i",self.programMode);
    
    NSInteger	frameCount;
    
    if(self.programMode == NMXProgramModeVideo)
    {
        self.selectedFrameCount = [self.appExecutive.videoLengthNumber intValue];
        frameCount	= [self.appExecutive.videoLengthNumber integerValue];
        
        //NSLog(@"self.videoLengthNumber: %@",self.appExecutive.videoLengthNumber);
    }
    else
    {
        self.selectedFrameCount = [self.appExecutive.frameCountNumber intValue]; //300
        frameCount	= [self.appExecutive.frameCountNumber integerValue];
    }
    
    //NSLog(@"self.programMode: %i",self.programMode);
    NSLog(@"selectedFrameCount: %i",self.selectedFrameCount);
    
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
    
    rampSettingSegment.selectedSegmentIndex = 0;
    
    NSDictionary *	attributes = @{ NSForegroundColorAttributeName: [UIColor whiteColor] };
    
    [self.rampSettingSegment setTitleTextAttributes: attributes forState: UIControlStateNormal];
    [self.rampSettingSegment setTitleTextAttributes: attributes forState: UIControlStateSelected];
    
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
    
    [super viewDidLoad];
}

- (void) timerName {
	
}

#pragma mark - Notifications

- (void) handleContinuousFrameNotification:(NSNotification *)pNotification {
    
    int cs = [pNotification.object intValue];
    
    self.currentSelectedFrameValue = cs;
    
    [self frameValueSelected];
    
    NSLog(@"handleContinuousFrameNotification result: %i",cs);
}

- (void) handleVideoFrameNotification:(NSNotification *)pNotification {
    
    int cs = [pNotification.object intValue];
    
    self.currentSelectedFrameValue = cs;
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
    
    self.currentSelectedFrameValue = cs;
    
    [self frameValueSelected];
}

#pragma mark - Objects

- (void) saveFrame: (NSNumber *)number; {
    
    int cs = [number intValue];
    
    NSLog(@"saveFrame result: %i",cs);
}

- (void) configSliders {
    
    //NSLog(@"randall configSliders");

    UIColor *	blue	= [UIColor blueColor];
    UIColor *	white	= [UIColor whiteColor];

    float masterFrameCount = [self.appExecutive.frameCountNumber floatValue];

    slide3PSlider1.minimumValue = 1;
    slide3PSlider1.maximumValue = masterFrameCount * .33;
    
    slide3PSlider2.minimumValue = slide3PSlider1.maximumValue + 1;
    slide3PSlider2.maximumValue = masterFrameCount * .75;
    
    slide3PSlider3.minimumValue = slide3PSlider2.maximumValue + 1;
    slide3PSlider3.maximumValue = masterFrameCount;
    
    slide3PSlider1.value = self.settings.slide3PVal1;
    slide3PSlider2.value = self.settings.slide3PVal2;
    slide3PSlider3.value = self.settings.slide3PVal3;
    
    for (NMXDevice *device in self.appExecutive.deviceList)
    {
        JSDeviceSettings *devSettings = device.settings;

        devSettings.slide3PVal1 = slide3PSlider1.value;
        devSettings.slide3PVal2 = slide3PSlider2.value;
        devSettings.slide3PVal3 = slide3PSlider3.value;
    }
    
    if (self.programMode == NMXProgramModeVideo)
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
        if (self.programMode == NMXProgramModeVideo)
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
        
        self.tableView.hidden = YES;
        
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
    
    [settingsButton setTitle: @"\u2699" forState: UIControlStateNormal];
}


- (void) showVoltage {
    
    [NSTimer scheduledTimerWithTimeInterval:.500 target:self selector:@selector(showVoltageTimer) userInfo:nil repeats:NO];
}

- (void) showVoltageTimer {
    
    float voltagePercent = [self.appExecutive calculateVoltage: NO];
    
    float offset = 1 - (batteryIcon.frame.size.height * voltagePercent) - .5;
    
    if (voltagePercent > 0)
    {
        UIView *v = [[UIView alloc] initWithFrame:CGRectMake(batteryIcon.frame.origin.x + 8,
                                                             batteryIcon.frame.origin.y + (batteryIcon.frame.size.height + offset),
                                                             batteryIcon.frame.size.width * .47,
                                                             batteryIcon.frame.size.height * voltagePercent)];
        
        v.backgroundColor = [UIColor colorWithRed:230.0/255 green:234.0/255 blue:239.0/255 alpha:.8];
    
        [contentBG addSubview:v];
    }
}

- (void) viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear: animated];
    
    //[[NSNotificationCenter defaultCenter] removeObserver: self];
}

- (void) deviceDisconnect: (NSNotification *) notification
{
    //NMXDevice *device = notification.object;
    
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

- (NSString *)convertTime2 : (float)val {
    
    int sd = [self.appExecutive.frameCountNumber intValue];
    
    float per1 = val/[self.appExecutive.frameCountNumber floatValue];
    float val1 = sd * per1;
    
    NSString *a = [self stringForTimeDisplay: (int)val1];
    
    return a;
}

- (NSString *)convertTime : (UISlider *)slider {
    
    int sd = [self.appExecutive.frameCountNumber intValue];
    
    float per1;
    
    NSString *b;
    
    if ([slider.restorationIdentifier containsString:@"Decrease"]) {
        
        b = [NSString stringWithFormat:@"%@ has final",slider.restorationIdentifier];
        
        //NSLog(@"%@",b);
        
        per1 = slider.value * (self.selectedFrameCount/2)+self.selectedFrameCount/2;
    }
    else
    {
        b = [NSString stringWithFormat:@"%@ has start",slider.restorationIdentifier];
        
        //NSLog(@"%@",b);
        
        per1 = slider.value * (self.selectedFrameCount/2);
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
        [secView setCurrentFrameValue:self.currentSelectedFrameValue];
        [secView setIsRampingScreen:YES];
    }
    else if ([segue.identifier isEqualToString:@"VideoMotorRamp"])
    {
        ShortDurationViewController *secView = [segue destinationViewController];
        [secView setIsMotorSegue:YES];
        [secView setIsSettingVideoFrame:YES];
        [secView setIsMotorSegueVal:self.currentSelectedFrameValue];
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

- (IBAction) handleEditProgramButton: (UIButton *) sender {

    for (NMXDevice *device in self.appExecutive.deviceList)
    {
        JSDeviceSettings *settings = device.settings;
        [settings synchronize];
    }
    
    return; // unwind
}

- (IBAction) handleNextButton: (UIButton *) sender {

    //mm Test that unfeasibleDevice works --- I removed a bunch of threading stuff that seem uneccessary
    //mm Test 3P mode works, I removed some code that was using the 2p sliders in 3p mode.  Not sure why that was there.
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];

    dispatch_async(dispatch_get_main_queue(), ^{
        
        for (NMXDevice *device in self.appExecutive.deviceList)
        {
            JSDeviceSettings *settings = device.settings;
            [settings synchronize];
        }

        NSString *unfeasibleDevice = nil;
        
        if (appExecutive.is3P == NO)
        {
            for (NMXDevice *device in self.appExecutive.deviceList)
            {
                for (int channel = 0; channel < kNumChannels; channel++)
                {
                    NSArray *increaseValues, *decreaseValues;
                    unsigned char motor;
                    if (channel == kSlideChannel)
                    {
                        motor = device.sledMotor;
                        increaseValues = device.settings.slideIncreaseValues;
                        decreaseValues = device.settings.slideDecreaseValues;
                    }
                    else if (channel == kPanChannel)
                    {
                        motor = device.panMotor;
                        increaseValues = device.settings.panIncreaseValues;
                        decreaseValues = device.settings.panDecreaseValues;
                    }
                    else
                    {
                        motor = device.tiltMotor;
                        increaseValues = device.settings.tiltIncreaseValues;
                        decreaseValues = device.settings.tiltDecreaseValues;
                    }
                    
                    UInt32  durationInMS = [device motorQueryShotsTotalTravelTime: motor] +
                    [device motorQueryLeadInShotsOrTime: motor] +
                    [device motorQueryLeadOutShotsOrTime: motor];
                    UInt32  leadIn, leadOut, accelInMS, decelInMS;
                    
                    float increaseStart = [[increaseValues firstObject] floatValue];
                    float increaseEnd = [[increaseValues lastObject] floatValue];
                    float decreaseStart = [[decreaseValues firstObject] floatValue];
                    float decreaseEnd = [[decreaseValues lastObject] floatValue];
                    
                    leadIn = durationInMS * increaseStart / 2;
                    accelInMS = durationInMS * (increaseEnd - increaseStart) / 2;
                    leadOut = durationInMS * (1 - decreaseEnd) / 2;
                    decelInMS = durationInMS * (decreaseEnd - decreaseStart) / 2;
                    
                    [device motorSet: motor SetLeadInShotsOrTime: leadIn];
                    [device motorSet: motor SetProgramAccel: accelInMS];
                    [device motorSet: motor SetProgramDecel: decelInMS];
                    [device motorSet: motor SetLeadOutShotsOrTime: leadOut];
                    [device motorSet: motor SetShotsTotalTravelTime: durationInMS - leadIn - leadOut];
                    
                    if (NO == [device motorQueryFeasibility: motor])
                    {
                        unfeasibleDevice = [appExecutive stringWithHandleForDeviceName: device.name];
                        break;
                    }
                }
            }
            
        }
    
        [MBProgressHUD hideHUDForView:self.view animated:YES];
            
        if (unfeasibleDevice)
        {
            NSString *message = [NSString stringWithFormat:@"Reduce ramping or lead in/out time for device : %@", unfeasibleDevice];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Too Fast For Motors"
                                                            message: message
                                                           delegate: self
                                                  cancelButtonTitle: @"OK"
                                                  otherButtonTitles: nil];
            [alert show];
        }
        else
        {
            [self performSegueWithIdentifier: kSegueToReviewStatusViewController sender: self];
        }

    });

}

#pragma mark Randall Updates - Ramp Easing

- (IBAction) handleSlide3PSlider1:(id)sender {
    
    UISlider *s = sender;
    
    for (NMXDevice *device in self.appExecutive.deviceList)
    {
        JSDeviceSettings *devSettings = device.settings;
        devSettings.slide3PVal1 = s.value;
    }
    
    self.currentSelectedFrameValue = self.settings.slide3PVal1;
    
    NSLog(@"s.value: %f",s.value);
    
    slide3P1Lbl.text = [NSString stringWithFormat:@"%i",(int)self.settings.slide3PVal1];
    
    if (self.programMode == NMXProgramModeVideo)
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
}

- (IBAction) handleSlide3PSlider2:(id)sender {
    
    UISlider *s = sender;
    
    self.settings.slide3PVal2 = s.value;
    
    self.currentSelectedFrameValue = self.settings.slide3PVal2;
    
    //NSLog(@"slide3PVal2: %f",appExecutive.slide3PVal2);
    
    slide3P2Lbl.text = [NSString stringWithFormat:@"%i",(int)self.settings.slide3PVal2];
    
    if (self.programMode == NMXProgramModeVideo)
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
    
    self.currentSelectedFrameValue = self.settings.slide3PVal3;
    
    slide3P3Lbl.text = [NSString stringWithFormat:@"%i",(int)self.settings.slide3PVal3];
    
    //NSLog(@"slide3PVal3: %f",appExecutive.slide3PVal3);
    
    if (self.programMode == NMXProgramModeVideo)
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
    
    if (self.isLocked) {
        
        self.isLocked = false;
        
        [lockButton setTitle:@"Lock" forState:UIControlStateNormal];
    }
    else
    {
        self.isLocked = true;
        
        [lockButton setTitle:@"Unlock" forState:UIControlStateNormal];
    }
}

- (void) update3PTimer {
    
    NSLog(@"update3PTimer");
}

- (void) updateSlide3PVal1: (UISlider *) slider {
    
    sliderValue = slider.value;
    
    for (NMXDevice *device in self.appExecutive.deviceList)
    {
        JSDeviceSettings *devSettings = device.settings;
        devSettings.slide3PVal1 = sliderValue;
    }
    
    NSLog(@"upsl3p1 appExecutive.slide3PVal1: %f",self.settings.slide3PVal1);
    
    slide3P1Lbl.text = [NSString stringWithFormat:@"%i",(int)self.settings.slide3PVal1];
    
    if (self.programMode == NMXProgramModeVideo)
    {
        NSLog(@"upsl3p1 currentSelectedFrameValue: %f",self.currentSelectedFrameValue);
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
    
    self.settings.slide3PVal2 = sliderValue;
    
    slide3P2Lbl.text = [NSString stringWithFormat:@"%i",(int)self.settings.slide3PVal2];
    
    if (self.programMode == NMXProgramModeVideo)
    {
        NSString *a = [self stringForTimeDisplay: (int)selectedVideoFrame];
        
        slide3P2Lbl.text = a;
    }
    
    [self.slide3PView setNeedsDisplay];
    
}

- (void) updateSlide3PVal3: (UISlider *) slider {
    
    sliderValue = slider.value;
    
    self.settings.slide3PVal3 = sliderValue;
    
    slide3P3Lbl.text = [NSString stringWithFormat:@"%i",(int)self.settings.slide3PVal3];
    
    if (self.programMode == NMXProgramModeVideo)
    {
        NSString *a = [self stringForTimeDisplay: (int)selectedVideoFrame];
        
        slide3P3Lbl.text = a;
    }
    
    [self.slide3PView setNeedsDisplay];
}

// 2P cell
- (void) showFrameText:(JSMotorRampingTableViewCell *)cell slider:(UISlider *)slider
{
    self.currentCell = cell;
    self.selectedSlider = slider;
    self.currentFrameTarget = slider.restorationIdentifier;

    [self showFrameText];
}

// coming from 3P
- (void) showFrameText:(id)sender {
    
    UISlider *slider = sender;
    self.currentCell = nil;
    self.selectedSlider = slider;
    self.currentFrameTarget = slider.restorationIdentifier;

    [self showFrameText];
}


- (void) showFrameText
{
    if (appExecutive.is3P && self.programMode == NMXProgramModeVideo)
    {
        float selected3PVal;
        
        if ([self.currentFrameTarget isEqualToString:@"3PS"])
        {
            selected3PVal = self.settings.slide3PVal1;
        }
        else if ([self.currentFrameTarget isEqualToString:@"3PM"])
        {
            selected3PVal = self.settings.slide3PVal2;
        }
        else if ([self.currentFrameTarget isEqualToString:@"3PE"])
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
    
    NSString *framestring = [NSString stringWithFormat:@"%f",self.currentSelectedFrameValue];
    
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
    
    
    
    if(self.programMode == NMXProgramModeVideo)
    {
        NSLog(@"NMXProgramModeVideo");
        
        [self performSegueWithIdentifier:@"VideoMotorRamp" sender:self];
    }
    else
    {
        NSLog(@"NMXProgramModeSMS");
        
        [self performSegueWithIdentifier:@"FrameCountMotorRamp" sender:self];
    }
}


- (float) roundNumber10: (float)val {
    
    float val1 = 10.0 * floor((val/10.0) + 0.5);
    
    return val1;
}

- (void) resetThumbSelection
{
    UIImage *w = [self imageWithImage:[UIImage imageNamed:@"thumb3.png"] scaledToSize:CGSizeMake(30.0, 30.0)];
    
    for (NSInteger j = 0; j < [self.tableView numberOfSections]; ++j)
    {
        for (NSInteger i = 0; i < [self.tableView numberOfRowsInSection:j]; ++i)
        {
            JSMotorRampingTableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:j]];
            [cell setThumbImage: w];
        }
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

- (void) frameValueSelected {
    
    if (appExecutive.is3P == YES)
    {
        [self frameSelected3P];
    }
    else
    {
        [self frameSelected2P];
    }
}

- (void) frameSelected3P {
    
    [self updateOther3PThumbs];
}

- (void) frameSelected2P
{
    int frameCountHalf = (self.selectedFrameCount/2);

    if ([self.currentFrameTarget containsString:@"increase"])
    {
        self.currentFrameConvertedToFloat = self.currentSelectedFrameValue/frameCountHalf;
    }
    else
    {
        float f2 = self.currentSelectedFrameValue - frameCountHalf;
        float f3 = f2 / (self.selectedFrameCount/2);
        self.currentFrameConvertedToFloat = f3;
    }
    
    self.selectedSlider.value = self.currentFrameConvertedToFloat;
 
    if([self.currentFrameTarget isEqualToString:@"increaseStart"])
    {
        [self.currentCell updateIncreaseStart: self.selectedSlider];
    }
    else if([self.currentFrameTarget isEqualToString:@"increaseFinal"])
    {
        [self.currentCell updateIncreaseFinal: self.selectedSlider];
    }
    if([self.currentFrameTarget isEqualToString:@"decreaseStart"])
    {
        [self.currentCell updateDecreaseStart: self.selectedSlider];
    }
    if([self.currentFrameTarget isEqualToString:@"decreaseFinal"])
    {
        [self.currentCell updateDecreaseFinal: self.selectedSlider];
    }

    
    [self updateOther2PThumbs];
}

- (void) updateOther3PThumbs {
    
    if (self.programMode == NMXProgramModeVideo)
    {
        int sd = [self.appExecutive.videoLengthNumber intValue];
        
        //int sd = [self.appExecutive.shotDurationNumber intValue];
        
        //60000 = (15/20) * 80000;
        
        //60000 = x/20 * 80000;
        //60000/80000 = x/20
        //.75 = x / 20
        //.75 * 20 = x;
        //15
        
        //NSLog(@"self.currentSelectedFrameValue: %f",self.currentSelectedFrameValue);
        
        float val1 = self.currentSelectedFrameValue/(float)sd; //60000/80000
        
        NSLog(@"%f/%f = val1: %f",self.currentSelectedFrameValue,(float)sd,val1);
        
        float val5 = val1 * [self.appExecutive.frameCountNumber floatValue]; //.75 * 20
        
        NSLog(@"%f * %f = val5: %f",val1,[self.appExecutive.frameCountNumber floatValue],val5);
        
//        float val6 = val1 * [self.appExecutive.frameCountNumber floatValue]; //.75 * 20
//        
//        NSLog(@"val6: %f",val6);
        
        self.currentSelectedFrameValue = val5;
    }
    
    if([self.currentFrameTarget isEqualToString:@"3PS"])
    {
        NSLog(@"3PS: %f",self.currentSelectedFrameValue);
        
        slide3PSlider1.value = self.currentSelectedFrameValue;
        
        for (NMXDevice *device in self.appExecutive.deviceList)
        {
            JSDeviceSettings *devSettings = device.settings;
            devSettings.slide3PVal1 = sliderValue;
        }
        
        [self updateSlide3PVal1:slide3PSlider1];
    }
    else if([self.currentFrameTarget isEqualToString:@"3PM"])
    {
        NSLog(@"3PM: %f",self.currentSelectedFrameValue);
        
        slide3PSlider2.value = self.currentSelectedFrameValue;
        
        [self updateSlide3PVal2:slide3PSlider2];
    }
    else
    {
        NSLog(@"3PE: %f",self.currentSelectedFrameValue);
        
        slide3PSlider3.value = self.currentSelectedFrameValue;
        
        [self updateSlide3PVal3:slide3PSlider3];
    }
}

- (void) updateOther2PThumbs {

    if (self.isLocked)
    {
        if([self.currentFrameTarget isEqualToString:@"increaseStart"])
        {
            [self updateIncreaseStartSliders: self.selectedSlider];
        }
        else if([self.currentFrameTarget isEqualToString:@"increaseFinal"])
        {
            [self updateIncreaseFinalSliders: self.selectedSlider];
        }
        else if([self.currentFrameTarget isEqualToString:@"decreaseStart"])
        {
            [self updateDecreaseStartSliders: self.selectedSlider];
        }
        else if([self.currentFrameTarget isEqualToString:@"decreaseFinal"])
        {
            [self updateDecreaseFinalSliders: self.selectedSlider];
        }
    }
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
    
    doneBarButton.target = self;
    doneBarButton.action = @selector( doneEditingFrame: );
}

- (IBAction) doneEditingFrame:(id)sender {
    
    [NSTimer scheduledTimerWithTimeInterval:0.250 target:self selector:@selector(frameValueSelected) userInfo:nil repeats:NO];
}


- (void) setupSliderFunctions {

    [slide3PSlider1 addTarget:self action:@selector(showFrameText:) forControlEvents:UIControlEventTouchDownRepeat];
    [slide3PSlider2 addTarget:self action:@selector(showFrameText:) forControlEvents:UIControlEventTouchDownRepeat];
    [slide3PSlider3 addTarget:self action:@selector(showFrameText:) forControlEvents:UIControlEventTouchDownRepeat];
    
    [pan3PSlider1 addTarget:self action:@selector(showFrameText:) forControlEvents:UIControlEventTouchDownRepeat];
    [pan3PSlider2 addTarget:self action:@selector(showFrameText:) forControlEvents:UIControlEventTouchDownRepeat];
    [pan3PSlider3 addTarget:self action:@selector(showFrameText:) forControlEvents:UIControlEventTouchDownRepeat];
    
    [tilt3PSlider1 addTarget:self action:@selector(showFrameText:) forControlEvents:UIControlEventTouchDownRepeat];
    [tilt3PSlider2 addTarget:self action:@selector(showFrameText:) forControlEvents:UIControlEventTouchDownRepeat];
    [tilt3PSlider3 addTarget:self action:@selector(showFrameText:) forControlEvents:UIControlEventTouchDownRepeat];
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
    
    self.currentSelectedFrameValue = [framestring floatValue];
    
    NSLog(@"self.currentSelectedFrameValue: %f",self.currentSelectedFrameValue);
    
    return;
}

- (void) updateIncreaseStartSliders: (UISlider *) slider
{
    NSNumber *	startValue	= [NSNumber numberWithFloat: slider.value];

    // update the device settings
    for (NMXDevice *device in self.appExecutive.deviceList)
    {
        NSNumber *final = [device.settings.slideIncreaseValues lastObject];
        float finalVal = MAX(startValue.floatValue, final.floatValue);
        NSArray *sliderampValues = [NSArray arrayWithObjects: startValue, [NSNumber numberWithFloat:finalVal], nil];
        final = [device.settings.panIncreaseValues lastObject];
        finalVal = MAX(startValue.floatValue, final.floatValue);
        NSArray *panrampValues = [NSArray arrayWithObjects: startValue, [NSNumber numberWithFloat:finalVal], nil];
        final = [device.settings.tiltIncreaseValues lastObject];
        finalVal = MAX(startValue.floatValue, final.floatValue);
        NSArray *tiltrampValues = [NSArray arrayWithObjects: startValue, [NSNumber numberWithFloat:finalVal], nil];
        device.settings.slideIncreaseValues = sliderampValues;
        device.settings.panIncreaseValues = panrampValues;
        device.settings.tiltIncreaseValues = tiltrampValues;
    }
    
    // update the visible sliders
    for (NSInteger j = 0; j < [self.tableView numberOfSections]; ++j)
    {
        for (NSInteger i = 0; i < [self.tableView numberOfRowsInSection:j]; ++i)
        {
            JSMotorRampingTableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:j]];
            [cell updateIncreaseStart:slider];
        }
    }
}

- (void) updateIncreaseFinalSliders: (UISlider *) slider
{
    NSNumber *finalValue = [NSNumber numberWithFloat: slider.value];
    
    // update the device settings
    for (NMXDevice *device in self.appExecutive.deviceList)
    {
        NSNumber *start = [device.settings.slideIncreaseValues firstObject];
        float startVal = MIN(start.floatValue, finalValue.floatValue);
        NSArray *sliderampValues = [NSArray arrayWithObjects: [NSNumber numberWithFloat:startVal], finalValue, nil];
        start = [device.settings.panIncreaseValues firstObject];
        startVal = MIN(start.floatValue, finalValue.floatValue);
        NSArray *panrampValues = [NSArray arrayWithObjects: [NSNumber numberWithFloat:startVal], finalValue, nil];
        start = [device.settings.tiltIncreaseValues firstObject];
        startVal = MIN(start.floatValue, finalValue.floatValue);
        NSArray *tiltrampValues = [NSArray arrayWithObjects: [NSNumber numberWithFloat:startVal], finalValue, nil];
        device.settings.slideIncreaseValues = sliderampValues;
        device.settings.panIncreaseValues = panrampValues;
        device.settings.tiltIncreaseValues = tiltrampValues;
    }

    // update the visible sliders
    for (NSInteger j = 0; j < [self.tableView numberOfSections]; ++j)
    {
        for (NSInteger i = 0; i < [self.tableView numberOfRowsInSection:j]; ++i)
        {
            JSMotorRampingTableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:j]];
            [cell updateIncreaseFinal:slider];
        }
    }
}

- (void) updateDecreaseStartSliders: (UISlider *) slider
{
    NSNumber *	startValue	= [NSNumber numberWithFloat: slider.value];
    
    // update the device settings
    for (NMXDevice *device in self.appExecutive.deviceList)
    {
        NSNumber *final = [device.settings.slideDecreaseValues lastObject];
        float finalVal = MAX(startValue.floatValue, final.floatValue);
        NSArray *sliderampValues = [NSArray arrayWithObjects: startValue, [NSNumber numberWithFloat:finalVal], nil];
        final = [device.settings.panDecreaseValues lastObject];
        finalVal = MAX(startValue.floatValue, final.floatValue);
        NSArray *panrampValues = [NSArray arrayWithObjects: startValue, [NSNumber numberWithFloat:finalVal], nil];
        final = [device.settings.tiltDecreaseValues lastObject];
        finalVal = MAX(startValue.floatValue, final.floatValue);
        NSArray *tiltrampValues = [NSArray arrayWithObjects: startValue, [NSNumber numberWithFloat:finalVal], nil];
        device.settings.slideDecreaseValues = sliderampValues;
        device.settings.panDecreaseValues = panrampValues;
        device.settings.tiltDecreaseValues = tiltrampValues;
    }
    

    for (NSInteger j = 0; j < [self.tableView numberOfSections]; ++j)
    {
        for (NSInteger i = 0; i < [self.tableView numberOfRowsInSection:j]; ++i)
        {
            JSMotorRampingTableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:j]];
            [cell updateDecreaseStart:slider];
        }
    }
}

- (void) updateDecreaseFinalSliders: (UISlider *) slider
{
    NSNumber *finalValue = [NSNumber numberWithFloat: slider.value];
    
    // update the device settings
    for (NMXDevice *device in self.appExecutive.deviceList)
    {
        NSNumber *start = [device.settings.slideDecreaseValues firstObject];
        float startVal = MIN(start.floatValue, finalValue.floatValue);
        NSArray *sliderampValues = [NSArray arrayWithObjects: [NSNumber numberWithFloat:startVal], finalValue, nil];
        start = [device.settings.panDecreaseValues firstObject];
        startVal = MIN(start.floatValue, finalValue.floatValue);
        NSArray *panrampValues = [NSArray arrayWithObjects: [NSNumber numberWithFloat:startVal], finalValue, nil];
        start = [device.settings.tiltDecreaseValues firstObject];
        startVal = MIN(start.floatValue, finalValue.floatValue);
        NSArray *tiltrampValues = [NSArray arrayWithObjects: [NSNumber numberWithFloat:startVal], finalValue, nil];
        device.settings.slideDecreaseValues = sliderampValues;
        device.settings.panDecreaseValues = panrampValues;
        device.settings.tiltDecreaseValues = tiltrampValues;
    }

    for (NSInteger j = 0; j < [self.tableView numberOfSections]; ++j)
    {
        for (NSInteger i = 0; i < [self.tableView numberOfRowsInSection:j]; ++i)
        {
            JSMotorRampingTableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:j]];
            [cell updateDecreaseFinal:slider];
        }
    }
}

//------------------------------------------------------------------------------

#pragma mark - UIPickerViewDataSource Protocol Methods

- (NSInteger) numberOfComponentsInPickerView: (UIPickerView *) pickerView {
    return 4;
}

- (NSInteger) pickerView: (UIPickerView *) pickerView numberOfRowsInComponent: (NSInteger) component {
    return frameCountStrings.count;
}

#pragma mark - Table View Delegate

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return self.appExecutive.deviceList.count;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    JSMotorRampingTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DeviceRampingCell" forIndexPath:indexPath];
    cell.mrvc = self;
    
    cell.device = self.appExecutive.device;
    int deviceIndex = (int)indexPath.section;
    int row = (int)indexPath.row;
    
    cell.channel = row;
    cell.device = self.appExecutive.deviceList[deviceIndex];
    
    [cell configure];
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *name = [self.appExecutive stringWithHandleForDeviceName: self.appExecutive.deviceList[section].name];
    return name;
}

@end
