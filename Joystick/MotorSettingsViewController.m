//
//  MotorSettingsViewController.m
//  Joystick
//
//  Created by Mark Zykin on 11/21/14.
//  Copyright (c) 2014 Dynamic Perception. All rights reserved.
//

#import <CocoaLumberjack/CocoaLumberjack.h>
#import "MotorSettingsViewController.h"
#import "AppExecutive.h"
#import "JoyButton.h"
#import "MBProgressHUD.h"


//------------------------------------------------------------------------------

#pragma mark - Private Interface


@interface MotorSettingsViewController ()

@property (nonatomic, weak)	IBOutlet	UILabel *				motorSettingsLabel;
@property (nonatomic, weak)	IBOutlet	UIView *				controlBackground;
@property (nonatomic, weak)	IBOutlet	UILabel *				motorNumberLabel;
@property (nonatomic, weak)	IBOutlet	UISegmentedControl *	microstepsControl;
@property (nonatomic, weak)	IBOutlet	UISwitch *				invertDirectionSwitch;
@property (nonatomic, weak)	IBOutlet	UISwitch *				powerSaveSwitch;
@property (weak, nonatomic) IBOutlet    UISwitch *              disableSwitch;
@property (nonatomic, weak)	IBOutlet	UILabel *				backlashLabel;
@property (nonatomic, weak)	IBOutlet	UIButton *				backlashButton;
@property (nonatomic, weak)	IBOutlet	JoyButton *				okButton;

// TODO: the value of this probably comes from and goes to the device, temporarily set to arbitrary value
// may not need to be a property in the future.

@property (nonatomic, readwrite)			NSInteger				backlash;

@end


//------------------------------------------------------------------------------

#pragma mark - Implementation


@implementation MotorSettingsViewController


#pragma mark Static Variables

NSString	static	*SegueToBacklashViewController	= @"SegueToBacklashViewController";


#pragma mark Public Propery Methods

#pragma mark Private Propery Methods

@synthesize leftBtn, rightBtn, okButton, appExecutive, distanceLbl, presetLbl, contentScroll,gearRatioLbl,rigRatioLbl,overallDistanceTxt,leftLbl,rightLbl,unitsLbl,scrollPositionView,unitsTxt,sensitivityValue,sensitivitySlider,joystickResponseLbl,siderealBtn,overallDistanceLbl,toggleJoystickSwitch,dampeningSlider,dampeningLbl,dampeningImg;

//------------------------------------------------------------------------------

- (void) viewDidLoad {
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    self.backlash = [self.appExecutive.device motorQueryBacklash: (int) self.motorNumber];
    
    start = [self.appExecutive.device queryProgramStartPoint:(int)self.motorNumber];
    end = [self.appExecutive.device queryProgramEndPoint:(int)self.motorNumber];
    
    microstepSetting = [self.appExecutive.device motorQueryMicrostep: (int) self.motorNumber];
            
    NSLog(@"start: %i",start);
    NSLog(@"end: %i",end);
    //NSLog(@"viewdidload microstepSetting: %i", microstepSetting);

	// items for IBOutlet objects don't appear until the view is loaded

	self.motorSettingsLabel.text = [NSString stringWithFormat: @"%@ Settings Channel:", self.motorName];
	self.motorNumberLabel.text = [NSString stringWithFormat: @"%ld", (long)self.motorNumber];
    
    [leftBtn addTarget:self action:@selector(enableLeft:) forControlEvents:UIControlEventTouchUpInside];
    [rightBtn addTarget:self action:@selector(enableRight:) forControlEvents:UIControlEventTouchUpInside];
    
    leftBtn.layer.borderWidth = 1.0;
    leftBtn.layer.borderColor = [appDelegate.appBlue CGColor];
    
    rightBtn.layer.borderWidth = 1.0;
    rightBtn.layer.borderColor = [appDelegate.appBlue CGColor];
    
    continuousInterval = 100;
    upperLimit = 4999;
    lowerLimit = -4999;
    
    //[NSTimer scheduledTimerWithTimeInterval:1.000 target:self selector:@selector(jsTimer) userInfo:nil repeats:NO];
    
    defaultColor = [UIColor colorWithRed:55.0/255 green:55.0/255 blue:55.0/255 alpha:1];
    
    //NMXDevice * device = [AppExecutive sharedInstance].device;
    
    if(start > end)
    {
        distance = start - end;
    }
    else
    {
        distance = end - start;
    }
    
    NSLog(@"distance: %f",distance);
    
    presetLbl.text = @"-";
    gearRatioLbl.text = @"-";
    rigRatioLbl.text = @"-";
    leftLbl.text = @"";
    rightLbl.text = @"";
    
    gearRatio = 0;
    
    overallDistanceTxt.delegate = self;
    
    [[NSNotificationCenter defaultCenter]
	 addObserver:self
	 selector:@selector(handleNotificationDistancePreset:)
	 name:@"loadDistancePreset" object:nil];
    
    [[NSNotificationCenter defaultCenter]
	 addObserver:self
	 selector:@selector(handleNotificationUpdateOverallDistance:)
	 name:@"updateOverallDistance" object:nil];
    
    [contentScroll setContentSize:CGSizeMake(contentScroll.frame.size.width, siderealBtn.frame.origin.y + siderealBtn.frame.size.height + 10)];
    
    //Can't find keyplane that supports type 4 for keyboard iPhone-Portrait-NumberPad
    
    gearRatioLbl.text = @"19:1";
    
    if (self.motorNumber == 2 || self.motorNumber == 3)
    {
        rigRatioLbl.text = @"Stage R";
    }
    else
    {
        rigRatioLbl.text = @"Stage 1/0";
        joystickResponseLbl.text = @"Slider Response";
    }
    
    [self setupReturnButtons];
    [self getSavedGearMotorRatios];
    
    contentScroll.delegate = self;
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(handleNotificationRotaryPreset:)
     name:@"linearRotaryPreset" object:nil];
    
    unitsLbl.hidden = YES;
    unitsTxt.borderStyle = UITextBorderStyleNone;
    unitsTxt.textColor = [UIColor whiteColor];
    
    unitsTxt.backgroundColor = [UIColor clearColor];
//    unitsTxt.layer.borderWidth = 0.5;
    
    if([[UIDevice currentDevice]userInterfaceIdiom] == UIUserInterfaceIdiomPad)
    {
        scrollPositionView.hidden = YES;
    }
    
    okButton.userInteractionEnabled = NO;
    
    if (self.appExecutive.useJoystick == NO)
    {
        [toggleJoystickSwitch setOn:YES];
    }
    
    sensitivityRatio = [self.appExecutive.sensitivityNumber floatValue]/100;
    
    //NSLog(@"sensitivityRatio: %f",sensitivityRatio);
    
    if (self.appExecutive.is3P == YES) {
       
        if (self.motorNumber == 1) {
            
            NSLog(@"start3PSlideDistance: %f",self.appExecutive.start3PSlideDistance);
            NSLog(@"mid3PSlideDistance: %f",self.appExecutive.mid3PSlideDistance);
            NSLog(@"end3PSlideDistance: %f",self.appExecutive.end3PSlideDistance);
        }
        if (self.motorNumber == 2) {
        
            NSLog(@"start3PPanDistance: %f",self.appExecutive.start3PPanDistance);
            NSLog(@"mid3PPanDistance: %f",self.appExecutive.mid3PPanDistance);
            NSLog(@"end3PPanDistance: %f",self.appExecutive.end3PPanDistance);
        }
    }
    
    float maxAccel = 30000;
    
    float a;
    float b;
    
    if ((int)self.motorNumber == 1)
    {
        //16192 = pow(x,2) * maxAccel;
        //16192/maxAcel = x * x
        //.53 = x * x
        
        //NSLog(@"appExecutive.dampening1: %f",appExecutive.dampening1);
        
        a = appExecutive.dampening1/maxAccel;
    }
    else if ((int)self.motorNumber == 2)
    {
//        float conv = pow((float)dampeningSlider.value,2) * maxAccel;
//        
//        dampeningSlider.value = self.appExecutive.dampening2;
        
        a = appExecutive.dampening2/maxAccel;
    }
    else  if ((int)self.motorNumber == 3)
    {
//        float conv = pow((float)dampeningSlider.value,2) * maxAccel;
//        
//        dampeningSlider.value = self.appExecutive.dampening3;

        a = appExecutive.dampening3/maxAccel;
    }
    
    b = sqrtf(a);
    
    float inverseVal = 1 - b;
    
    //dampeningSlider.value = b;
    
    //dampeningSlider.maximumValue = .8; 12-15-15
    
    dampeningSlider.minimumValue = .35;
    dampeningSlider.maximumValue = .715;
    
    dampeningSlider.value = inverseVal;
    
    //dampeningLbl.text = [NSString stringWithFormat:@"%i%%",(int)(dampeningSlider.value * 100)];
    
    int per1 = (int)(dampeningSlider.value * 100);
    
    float per2 = dampeningSlider.value/dampeningSlider.maximumValue;
    
//    NSLog(@"dampeningSlider.value: %f",dampeningSlider.value);
//    NSLog(@"per2: %f",per2);
    
    if (per2 >= .9)
    {
        dampeningImg.image = [UIImage imageNamed:@"dampening100.png"];
    }
    else if (per2 < .9 && per2 >= .75)
    {
        dampeningImg.image = [UIImage imageNamed:@"dampening75.png"];
    }
    else if (per2 < .75 && per2 >= .6)
    {
        dampeningImg.image = [UIImage imageNamed:@"dampening50.png"];
    }
    else if (per2 < .6 && per2 >= .5)
    {
        dampeningImg.image = [UIImage imageNamed:@"dampening25.png"];
    }
    else
    {
        dampeningImg.image = [UIImage imageNamed:@"dampening0.png"];
    }
    
    dampeningLbl.text = [NSString stringWithFormat:@"%i%%",(int)(per1 + (per1 * .2))];
    
//    NSLog(@"a: %f",a);
//    NSLog(@"b: %f",b);
    
    //dampeningSlider.transform = CGAffineTransformRotate(dampeningSlider.transform, 180.0/180*M_PI);
    
    [NSTimer scheduledTimerWithTimeInterval:0.500 target:self selector:@selector(timerNameQuerySleep) userInfo:nil repeats:NO];
 
    [super viewDidLoad];
}

- (void) getSavedGearMotorRatios {

    if (self.motorNumber == 1)
    {
        NSLog(@"self.motorNumber: %i",(int)self.motorNumber);
        NSLog(@"self.appExecutive.defaults slideGear: %i",(int)[self.appExecutive.defaults integerForKey:@"slideGear"]);
        NSLog(@"self.appExecutive.defaults slideMotor: %i",(int)[self.appExecutive.defaults integerForKey:@"slideMotor"]);
        
        if ([self.appExecutive.defaults integerForKey:@"slideGear"])
        {
            NSLog(@"slide setting");
            
            self.appExecutive.slideGear = (int)[self.appExecutive.defaults integerForKey:@"slideGear"];
            
            NSLog(@"get slideGear: %i",self.appExecutive.slideGear);
            
            if (self.appExecutive.slideGear == 1)
            {
                gearRatioLbl.text = @"27:1";
            }
            else if (self.appExecutive.slideGear == 2)
            {
                gearRatioLbl.text = @"19:1";
            }
            else if (self.appExecutive.slideGear == 3)
            {
                gearRatioLbl.text = @"5:1";
            }
        }
        
        if ([self.appExecutive.defaults integerForKey:@"slideMotor"])
        {
            self.appExecutive.slideMotor = (int)[self.appExecutive.defaults integerForKey:@"slideMotor"];
            
            if (self.appExecutive.slideMotor == 1)
            {
                rigRatioLbl.text = @"Stage R";
            }
            else if (self.appExecutive.slideMotor == 2)
            {
                rigRatioLbl.text = @"Stage 1/0";
            }
            else if (self.appExecutive.slideMotor == 3)
            {
                rigRatioLbl.text = [NSString stringWithFormat:@"Linear Custom %.02f",[self.appExecutive.defaults floatForKey:@"slideMotorCustomValue"]];
                
                customLinearParam = [self.appExecutive.defaults floatForKey:@"slideMotorCustomValue"];
            }
            
            //NSLog(@"self.appExecutive.slideMotor: %i",self.appExecutive.slideMotor);
        }
    }
    else if (self.motorNumber == 2)
    {
        if ([self.appExecutive.defaults integerForKey:@"panGear"])
        {
            self.appExecutive.panGear = (int)[self.appExecutive.defaults integerForKey:@"panGear"];
            
            if (self.appExecutive.panGear == 1)
            {
                gearRatioLbl.text = @"27:1";
            }
            else if (self.appExecutive.panGear == 2)
            {
                gearRatioLbl.text = @"19:1";
            }
            else if (self.appExecutive.panGear == 3)
            {
                gearRatioLbl.text = @"5:1";
            }
        }
        
        if ([self.appExecutive.defaults integerForKey:@"panMotor"])
        {
            self.appExecutive.panMotor = (int)[self.appExecutive.defaults integerForKey:@"panMotor"];
            
            if (self.appExecutive.panMotor == 1)
            {
                rigRatioLbl.text = @"Stage R";
            }
            else if (self.appExecutive.panMotor == 2)
            {
                rigRatioLbl.text = @"Stage 1/0";
            }
            else if (self.appExecutive.panMotor == 3)
            {
                rigRatioLbl.text = [NSString stringWithFormat:@"Linear Custom %.02f",[self.appExecutive.defaults floatForKey:@"panMotorCustomValue"]];
                
                customLinearParam = [self.appExecutive.defaults floatForKey:@"panMotorCustomValue"];
            }
        }
    }
    else if (self.motorNumber == 3)
    {
        if ([self.appExecutive.defaults integerForKey:@"tiltGear"])
        {
            self.appExecutive.tiltGear = (int)[self.appExecutive.defaults integerForKey:@"tiltGear"];
            
            if (self.appExecutive.tiltGear == 1)
            {
                gearRatioLbl.text = @"27:1";
            }
            else if (self.appExecutive.tiltGear == 2)
            {
                gearRatioLbl.text = @"19:1";
            }
            else if (self.appExecutive.tiltGear == 3)
            {
                gearRatioLbl.text = @"5:1";
            }
        }
        
        if ([self.appExecutive.defaults integerForKey:@"tiltMotor"])
        {
            self.appExecutive.tiltMotor = (int)[self.appExecutive.defaults integerForKey:@"tiltMotor"];
            
            if (self.appExecutive.tiltMotor == 1)
            {
                rigRatioLbl.text = @"Stage R";
            }
            else if (self.appExecutive.tiltMotor == 2)
            {
                rigRatioLbl.text = @"Stage 1/0";
            }
            else if (self.appExecutive.tiltMotor == 3)
            {
                rigRatioLbl.text = [NSString stringWithFormat:@"Linear Custom %.02f",[self.appExecutive.defaults floatForKey:@"tiltMotorCustomValue"]];
                
                customLinearParam = [self.appExecutive.defaults floatForKey:@"tiltMotorCustomValue"];
            }
        }
    }
}

- (void) setupReturnButtons {
    
    overallDistanceTxt.borderStyle = UITextBorderStyleNone;
    overallDistanceTxt.text = @"-";
    overallDistanceTxt.textColor = [UIColor whiteColor];
    //overallDistanceTxt.backgroundColor = [UIColor redColor];
    overallDistanceTxt.textAlignment = NSTextAlignmentRight;
    
    int distanceInt = abs((int)distance);
    
    overallDistanceTxt.text = [NSString stringWithFormat:@"%i",distanceInt];
    
    //http://stackoverflow.com/questions/20192303/how-to-add-a-done-button-to-numpad-keyboard-in-ios7
    
    UIToolbar* keyboardToolbar = [[UIToolbar alloc] init];
    
    [keyboardToolbar sizeToFit];
    
    UIBarButtonItem *flexBarButton = [[UIBarButtonItem alloc]
                                      initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                      target:nil action:nil];
    
    UIBarButtonItem *doneBarButton = [[UIBarButtonItem alloc]
                                      initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                      target:self.view
                                      action:@selector(endEditing:)];
    
    keyboardToolbar.items = @[flexBarButton, doneBarButton];
    
    overallDistanceTxt.inputAccessoryView = keyboardToolbar;
    
    UIToolbar* keyboardToolbar2 = [[UIToolbar alloc] init];
    
    [keyboardToolbar2 sizeToFit];
    
    UIBarButtonItem *flexBarButton2 = [[UIBarButtonItem alloc]
                                      initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                      target:nil action:nil];
    
    UIBarButtonItem *doneBarButton2 = [[UIBarButtonItem alloc]
                                      initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                      target:self.view
                                      action:@selector(endEditing:)];
    
    keyboardToolbar2.items = @[flexBarButton2, doneBarButton2];
    
    unitsTxt.inputAccessoryView = keyboardToolbar2;
    unitsTxt.delegate = self;
    unitsTxt.restorationIdentifier = @"unitsTxt";
}

#pragma mark - Scrollview Delegate Methods

- (void) scrollViewDidScroll:(UIScrollView *)scrollView {
    
    if(scrollPositionView.alpha == 0)
    {
        [UIView animateWithDuration:.25 animations:^{
            
            scrollPositionView.alpha = 1;
            
        } completion:^(BOOL finished) {
            
        }];
    }
}

- (void) scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    
    float bottomEdge = scrollView.contentOffset.y + scrollView.frame.size.height;
    
    if (bottomEdge >= scrollView.contentSize.height) {
        
        //NSLog(@"at the end");
        
        [UIView animateWithDuration:.25 animations:^{
            
            scrollPositionView.alpha = 0;
            
        } completion:^(BOOL finished) {
            
        }];
    }
    else
    {
        [UIView animateWithDuration:.25 animations:^{
            
            scrollPositionView.alpha = 1;
            
        } completion:^(BOOL finished) {
            
        }];
    }
}

#pragma mark - Notifications

- (void) handleNotificationRotaryPreset:(NSNotification *)pNotification {
    
    NSDictionary *preset = pNotification.object;
    
    NSLog(@"linearRotary: %@",preset);
    
    rigRatioLbl.text = [NSString stringWithFormat:@"%@ %@",
                        [preset objectForKey:@"val2"],
                        [preset objectForKey:@"val1"]];
    
    if ([[preset objectForKey:@"val2"] isEqualToString:@"Linear Custom"])
    {
        customLinearParam = [[preset objectForKey:@"val1"] floatValue];
        
        NSLog(@"customLinearParam: %.02f",customLinearParam);
        
        if (self.motorNumber == 1)
        {
            self.appExecutive.slideMotor = 3;
            
            [self.appExecutive.defaults setObject: [NSNumber numberWithInt:self.appExecutive.slideMotor] forKey: @"slideMotor"];
            [self.appExecutive.defaults setObject: [NSNumber numberWithFloat:customLinearParam] forKey: @"slideMotorCustomValue"];
            
            NSLog(@"set slideMotor: %li",(long)[self.appExecutive.defaults integerForKey:@"slideMotor"]);
        }
        else if (self.motorNumber == 2)
        {
            self.appExecutive.panMotor = 3;
            
            [self.appExecutive.defaults setObject: [NSNumber numberWithInt:self.appExecutive.panMotor] forKey: @"panMotor"];
            [self.appExecutive.defaults setObject: [NSNumber numberWithFloat:customLinearParam] forKey: @"panMotorCustomValue"];
            
            NSLog(@"set panMotor: %li",(long)[self.appExecutive.defaults integerForKey:@"panMotor"]);
        }
        else if (self.motorNumber == 3)
        {
            self.appExecutive.tiltMotor = 3;
            
            [self.appExecutive.defaults setObject: [NSNumber numberWithInt:self.appExecutive.tiltMotor] forKey: @"tiltMotor"];
            [self.appExecutive.defaults setObject: [NSNumber numberWithFloat:customLinearParam] forKey: @"tiltMotorCustomValue"];
            
            NSLog(@"set tiltMotor: %li",(long)[self.appExecutive.defaults integerForKey:@"tiltMotor"]);
        }
        
        [self.appExecutive.defaults synchronize];
    }
    
    [self getDistance];
    [self updateInvertUI];
    
    [self dismissViewControllerAnimated: YES completion: nil];
}

- (void) handleNotificationUpdateOverallDistance:(NSNotification *)pNotification {
    
    float newFloat = [pNotification.object floatValue];
    
    NSLog(@"newFloat: %f",newFloat);
    
    if (([rigRatioLbl.text containsString:@"Stage R"] || [rigRatioLbl.text containsString:@"Rotary Custom"]))
    {
        // && distance != 0
        
        degrees = newFloat;
        
        NSLog(@"new degrees: %f",degrees);
        
        [self recalculate:degrees];
    }
    else
    {
        inches = newFloat;
        
        NSLog(@"new inches: %f",inches);
        
        [self recalculate:inches];
    }
    
//    [self getDistance];
    [self updateInvertUI];
}

- (void) handleNotificationDistancePreset:(NSNotification *)pNotification {
    
    //NSString *direction;
    
    NSLog(@"preset Notification: %@",pNotification.object);
	
    NSDictionary *presetDict = pNotification.object;
    NSString *preset = [presetDict objectForKey:@"val1"];
    
    //unitsTxt.enabled = YES;
    
    NSLog(@"preset: %@",preset);
    
    if (selectedSetting == 0)
    {
        gearRatioLbl.text = preset;
        
        if (self.motorNumber == 1)
        {
            if ([preset isEqualToString:@"27:1"])
            {
                self.appExecutive.slideGear = 1;
            }
            else if ([preset isEqualToString:@"19:1"])
            {
                self.appExecutive.slideGear = 2;
            }
            else if ([preset isEqualToString:@"5:1"])
            {
                self.appExecutive.slideGear = 3;
            }
            
            [self.appExecutive.defaults setObject: [NSNumber numberWithInt:self.appExecutive.slideGear] forKey: @"slideGear"];
            [self.appExecutive.defaults synchronize];
            
            NSLog(@"set slideGear: %li",(long)[self.appExecutive.defaults integerForKey:@"slideGear"]);
        }
        else if (self.motorNumber == 2)
        {
            if ([preset isEqualToString:@"27:1"])
            {
                self.appExecutive.panGear = 1;
            }
            else if ([preset isEqualToString:@"19:1"])
            {
                self.appExecutive.panGear = 2;
            }
            else if ([preset isEqualToString:@"5:1"])
            {
                self.appExecutive.panGear = 3;
            }
            
            [self.appExecutive.defaults setObject: [NSNumber numberWithInt:self.appExecutive.panGear] forKey: @"panGear"];
            [self.appExecutive.defaults synchronize];
            
            NSLog(@"set panGear: %li",(long)[self.appExecutive.defaults integerForKey:@"panGear"]);
        }
        else if (self.motorNumber == 3)
        {
            if ([preset isEqualToString:@"27:1"])
            {
                self.appExecutive.tiltGear = 1;
            }
            else if ([preset isEqualToString:@"19:1"])
            {
                self.appExecutive.tiltGear = 2;
            }
            else if ([preset isEqualToString:@"5:1"])
            {
                self.appExecutive.tiltGear = 3;
            }
            
            [self.appExecutive.defaults setObject: [NSNumber numberWithInt:self.appExecutive.tiltGear] forKey: @"tiltGear"];
            [self.appExecutive.defaults synchronize];
            
            NSLog(@"set tiltGear: %li",(long)[self.appExecutive.defaults integerForKey:@"tiltGear"]);
        }
    }
    else
    {
        rigRatioLbl.text = preset;
        
        if (self.motorNumber == 1)
        {
            if ([preset isEqualToString:@"Stage R"])
            {
                self.appExecutive.slideMotor = 1;
            }
            else if ([preset isEqualToString:@"Stage 1/0"])
            {
                self.appExecutive.slideMotor = 2;
            }
            else if ([preset containsString:@"Linear Custom"])
            {
                self.appExecutive.slideMotor = 3;
            }
            
            [self.appExecutive.defaults setObject: [NSNumber numberWithInt:self.appExecutive.slideMotor] forKey: @"slideMotor"];
            
            NSLog(@"set slideMotor: %li",(long)[self.appExecutive.defaults integerForKey:@"slideMotor"]);
        }
        else if (self.motorNumber == 2)
        {
            if ([preset isEqualToString:@"Stage R"])
            {
                self.appExecutive.panMotor = 1;
            }
            else if ([preset isEqualToString:@"Stage 1/0"])
            {
                self.appExecutive.panMotor = 2;
            }
            else if ([preset isEqualToString:@"Linear Custom"])
            {
                self.appExecutive.panMotor = 3;
            }
            
            [self.appExecutive.defaults setObject: [NSNumber numberWithInt:self.appExecutive.panMotor] forKey: @"panMotor"];
            
            NSLog(@"set panMotor: %li",(long)[self.appExecutive.defaults integerForKey:@"panMotor"]);
        }
        else if (self.motorNumber == 3)
        {
            if ([preset isEqualToString:@"Stage R"])
            {
                self.appExecutive.tiltMotor = 1;
            }
            else if ([preset isEqualToString:@"Stage 1/0"])
            {
                self.appExecutive.tiltMotor = 2;
            }
            else if ([preset isEqualToString:@"Linear Custom"])
            {
                self.appExecutive.tiltMotor = 3;
            }
            
            [self.appExecutive.defaults setObject: [NSNumber numberWithInt:self.appExecutive.tiltMotor] forKey: @"tiltMotor"];
            
            
            NSLog(@"set tiltMotor: %li",(long)[self.appExecutive.defaults integerForKey:@"tiltMotor"]);
        }
        
        [self.appExecutive.defaults synchronize];
    }
    
    [self getDistance];
    [self updateInvertUI];
}

- (void) getDistance {
    
    //int motorsteps = 200;
    float microsteps;
    float reciprocal = 0;
    
    //NSLog(@"getdistance microstepSetting: %i",microstepSetting);
    
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
    
    if ([gearRatioLbl.text isEqualToString:@"19:1"])
    {
        gearRatio = 19.2032;
        //19.2045
    }
    else if ([gearRatioLbl.text isEqualToString:@"27:1"])
    {
        //gearRatio = 27;
        gearRatio = 27.8512;
    }
    else if ([gearRatioLbl.text isEqualToString:@"13:1"])
    {
        //gearRatio = 13;
        gearRatio = 13.7336;
    }
    else if ([gearRatioLbl.text isEqualToString:@"5:1"])
    {
        //gearRatio = 5;
        gearRatio = 5.1818;
    }
    
    reciprocal = a/gearRatio;
    
    float rigRatio;
    
//    NSLog(@"microsteps: %f",microsteps);
//    NSLog(@"distance: %f",distance);
//    NSLog(@"gearRatio: %f",gearRatio);
//    NSLog(@"reciprocal: %f",reciprocal);
    
    if (([rigRatioLbl.text containsString:@"Stage R"] ||
         [rigRatioLbl.text containsString:@"Rotary Custom"]) && distance != 0)
    {
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
        
        //NSLog(@"degrees: %f",degrees);
    }
    else
    {
        //rigRatio = .2988;
        //inches = (distance/(motorsteps * gearRatio * rigRatio)) * microstepSetting;
        //inches = (31000/800) * .0513 * 3.54;
        //inches = (distance/microsteps) * reciprocal * 3.54;
        
        if([rigRatioLbl.text containsString:@"Linear Custom"])
        {
            inches = ((distance/microsteps) * reciprocal) * customLinearParam;
            
            NSLog(@"contains Linear Custom gd MS: %f", customLinearParam);
            
//            float a1 = (distance/microsteps);
//            float a2 = a1 * reciprocal;
//            float a3 = a2 * customLinearParam;
            
//            NSLog(@"a1: %f",a1);
//            NSLog(@"a2: %f",a2);
//            NSLog(@"a3: %f",a3);
        }
        else
        {
            //inches = ((distance/microsteps) * reciprocal) * 3.54;
            inches = ((distance/microsteps) * reciprocal) * 3.346;
        }
        
//        float a1 = (distance/microsteps);
//        float a2 = a1 * reciprocal;
//        float a3 = a2 * 3.54;
//        
//        NSLog(@"a1: %f",a1);
//        NSLog(@"a2: %f",a2);
//        NSLog(@"a3: %f",a3);
        
        calculatedValue = inches;
        
        //NSLog(@"inches: %f",inches);
    }
    
    NSLog(@"calculatedValue: %f",calculatedValue);
    NSLog(@"\n");
    
    /*
        Motor steps - m (steps per rotation)
        Gear ratio - g (input rotations per output rotation)
        Rig ratio - r (input rotations per output inch / rotation)
        Final ratio - f (steps per inch / rotation)
        
        m * g * r = f
        
        For example:
         
        Typical m = 200 steps/rot
        Our gear ratio r = 19.2032 rot in / rot out
        Stage-R ratio = 3.2727 rot in /rot out
        Stage Zero/One ratio = 0.2988 rot in / inch out
        
        Stage R calc:
        200 * 19.2032 * 3.2727 = 12569.26 full steps / platform rotation = 34.91 full steps / platform degree
        
        Stage Zero/One calc:
        200 * 19.2032 * 0.2988 = 1147.58 full steps / platform inch 
     
    */
}

- (void) recalculate: (float)value {
    
    NSLog(@"recalculate: %f",value);
    
    float microsteps;
    float reciprocal = 0;
    
    float rigRatio;
    float a = 1;
    float a2;
    
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
    
    if ([gearRatioLbl.text isEqualToString:@"19:1"])
    {
        gearRatio = 19.2032;
    }
    else if ([gearRatioLbl.text isEqualToString:@"27:1"])
    {
        gearRatio = 27;
    }
    else if ([gearRatioLbl.text isEqualToString:@"5:1"])
    {
        gearRatio = 5;
    }
    
    reciprocal = a/gearRatio;
    
    if (([rigRatioLbl.text containsString:@"Stage R"] ||
         [rigRatioLbl.text containsString:@"Rotary Custom"]) && distance != 0)
    {
        //rigRatio = 3.2727;
        rigRatio = .30555;
        
        //degrees = (distance/microsteps) * reciprocal * rigRatio;
        
        //-110.00 = (distance/1600) * 0.0520 * .30555;
        //-110.00 = (distance/1600) * .015;
        //-110.00/.015 = distance/1600;
        //-.037/1600 = distance;
        
        float a4 = reciprocal * rigRatio * 360; //.184
        float a1 = value / a4; //-597
        a2 = a1 * microsteps; //-.37
        
        NSLog(@"new distance: %f",a2);
        
        int distanceInt = abs((int)a2);
        
        overallDistanceTxt.text = [NSString stringWithFormat:@"%i",distanceInt];
    }
    else
    {
        //rigRatio = .2988;
        
        //inches = (distance/microsteps) * reciprocal * 3.54;
        
        //3 = (distance/1600) * 0.0520 * 3.54;
        //3 = (distance/1600) * .184;
        //3/.184 = distance/1600;
        //16*1600 = distance;
        
        //float a4 = reciprocal * 3.54; //.184
        
        float a4; // = reciprocal * 3.346;
        
        if([rigRatioLbl.text containsString:@"Linear Custom"])
        {
            a4 = reciprocal * customLinearParam;
            
            NSLog(@"contains Linear Custom recalculate: %f",customLinearParam);
        }
        else
        {
            //inches = ((distance/microsteps) * reciprocal) * 3.54;
            
            a4 = reciprocal * 3.346;
        }
        
        NSLog(@"a4: %f",a4);
        
        float a1 = value / a4; //-597
        
        NSLog(@"value: %f / a4: %f a1: %f",value, a4, a1);
        
        a2 = a1 * microsteps; //-.37
        
        NSLog(@"a1: %f / microstepSetting: %f new distance: %f",a1, microsteps, a2);
        
        //NSLog(@"new distance: %f",a2);
        
        int distanceInt = abs((int)a2);
        
        overallDistanceTxt.text = [NSString stringWithFormat:@"%i",distanceInt];
    }
    
    int n = (int)a2;
    int ab = abs(n);
    
    //int newPos = start + ab;
    //int newPos = start - n;
    
    int newPos;
    
    if(start > end)
    {
        newPos = start - n;
    }
    else
    {
        newPos = start + n;
    }
    
    NSLog(@"new end: %i", newPos);
    end = newPos;
    
    //distance = start - end; // 12-8-15 update
    
    if(start > end)
    {
        distance = start - end;
    }
    else
    {
        distance = end - start;
    }
    
    if (self.motorNumber == 1)
    {
        self.appExecutive.endPoint1 = end;
    }
    else if (self.motorNumber == 2)
    {
        self.appExecutive.endPoint2 = end;
    }
    else if (self.motorNumber == 3)
    {
        self.appExecutive.endPoint3 = end;
    }
    
    [appExecutive.device motorSet:(int)self.motorNumber ProgramStopPoint:newPos];
}

- (void) jsTimer {
	
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"enterJSMode"
     object:nil];
    
    joystickmode = YES;
}

- (void) viewWillAppear:(BOOL)animated {
    
    //NSLog(@"R viewWillAppear");
    
    if (self.appExecutive.is3P == YES)
    {
        //overallDistanceLbl.alpha = 0;
        //unitsTxt.alpha = 0;
        
        overallDistanceLbl.textColor = [UIColor grayColor];
        unitsTxt.textColor = [UIColor grayColor];
        unitsTxt.userInteractionEnabled = NO;
    }
    
    NMXDevice * device = [AppExecutive sharedInstance].device;
    
    [super viewWillAppear: animated];

	[self.view sendSubviewToBack: self.controlBackground];

	self.backlashLabel.text = [NSString stringWithFormat: @"%ld", (long)self.backlash];

    //self.powerSaveSwitch.on = [device motorQuerySleep: (int)self.motorNumber];
    self.invertDirectionSwitch.on = [device motorQueryInvertDirection: (int)self.motorNumber];
    self.disableSwitch.on = [device motorQueryDisabled: (int) self.motorNumber];
    
    sensitivitySlider.value	= [self.appExecutive.sensitivityNumber floatValue];
    sensitivityValue.text = [NSString stringWithFormat: @"%3.0f%%", self.sensitivitySlider.value];
    
    //microstepSetting = [device motorQueryMicrostep: (int) self.motorNumber];
        
    switch (microstepSetting)
    {
        case 4:
            self.microstepsControl.selectedSegmentIndex = 0;
            break;
        case 8:
            self.microstepsControl.selectedSegmentIndex = 1;
            break;
        case 16:
        default:
            self.microstepsControl.selectedSegmentIndex = 2;
            break;
    }
    
	[self setSegmentedControllerAttributes];
    
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(deviceDisconnect:)
                                                 name: kDeviceDisconnectedNotification
                                               object: nil];
    
    //NSLog(@"viewwillappear microstepSetting: %i",microstepSetting);
    
    //move to viewdidload 12-8-15
    
//    [self getDistance];
//    [self updateInvertUI];
//    
//    [NSTimer scheduledTimerWithTimeInterval:0.500 target:self selector:@selector(timerNameQuerySleep) userInfo:nil repeats:NO];
}

- (void) timerNameQuerySleep {
    
    //NSLog(@"query sleep");
	
    self.powerSaveSwitch.on = [appExecutive.device motorQuerySleep: (int)self.motorNumber];
    
    okButton.userInteractionEnabled = YES;
    
    [self getDistance];
    [self updateInvertUI];
    
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}

- (void) viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear: animated];
    
    //[[NSNotificationCenter defaultCenter] removeObserver: self];
}

- (void) deviceDisconnect: (id) object {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self dismissViewControllerAnimated: YES completion: nil];
    });
}

- (void) setSegmentedControllerAttributes {
    
	NSDictionary *	attributes = @{ NSForegroundColorAttributeName: [UIColor whiteColor] };

	[self.microstepsControl setTitleTextAttributes: attributes forState: UIControlStateNormal];
	[self.microstepsControl setTitleTextAttributes: attributes forState: UIControlStateSelected];    
}

- (void) didReceiveMemoryWarning {
    
	[super didReceiveMemoryWarning];
}

//------------------------------------------------------------------------------

#pragma mark - Navigation

- (void) prepareForSegue: (UIStoryboardSegue *) segue sender: (id) sender {
    
    if (joystickmode)
    {
        [[NSNotificationCenter defaultCenter]
         postNotificationName:@"exitJSMode"
         object:nil];
        
        joystickmode = NO;
    }
    
	if ([segue.identifier isEqualToString: SegueToBacklashViewController])
	{
        [[NSNotificationCenter defaultCenter] removeObserver: self];
        
		BacklashViewController *blvc = segue.destinationViewController;

		blvc.delegate = self;
		blvc.backlash = self.backlash;
	}
    else if ([segue.identifier isEqualToString: @"goToPresets"])
    {
        DistancePresetViewController *secView = [segue destinationViewController];
        [secView setSetting:selectedSetting];
        
        if (selectedSetting == 0)
        {
            [secView setCurrentSettingString:gearRatioLbl.text];
        }
        else
        {
            [secView setCurrentSettingString:rigRatioLbl.text];
            [secView setCurrentCustomVal:customLinearParam];
            
            NSLog(@"customLinearParam: %f",customLinearParam);
        }
    }
    else if ([segue.identifier isEqualToString: @"GoToSidereal"])
    {
        SiderealViewController *secView = [segue destinationViewController];
        
        NSLog(@"GoToSidereal %@",secView.restorationIdentifier);
    }
    else if ([segue.identifier isEqualToString: @"HelpMotorSettings"])
    {
        NSLog(@"HelpMotorSettings");
        
        HelpViewController *msvc = segue.destinationViewController;
        
        [msvc setScreenInd:2];
    }
    else if ([segue.identifier isEqualToString: @"OverallDistance"])
    {
        //NSLog(@"OverallDistance");
        
        OverallDistanceViewController *msvc = segue.destinationViewController;
        
        if (([rigRatioLbl.text containsString:@"Stage R"] || [rigRatioLbl.text containsString:@"Rotary Custom"]) && distance != 0)
        {
            [msvc setDistance:degrees];
            [msvc setSubLabelTxt:@"Set degrees"];
        }
        else
        {
            [msvc setDistance:inches];
            [msvc setSubLabelTxt:@"Set inches"];
        }
    }
}

//------------------------------------------------------------------------------

#pragma mark - BacklashDelegate Methods

- (void) updateBacklash: (NSInteger) value {
    
	DDLogDebug(@"Backlash Value: %ld", (long)value);

	self.backlash = value;
}

//------------------------------------------------------------------------------

#pragma mark - IBAction Methods

- (IBAction) handleDampeningSlider: (UISlider *) sender {
    
//    CGFloat value = sender.value;
//    CGFloat adjustedValue = sender.maximumValue - value + sender.minimumValue;
    
    NSLog(@"val: %f",sender.value);
    
    float inv = 1-sender.value;
  
    
    NSLog(@"inv val: %f",inv);
    
    //dampeningLbl.text = [NSString stringWithFormat:@"%i%%",(int)(sender.value * 100)];
    
    int per1 = (int)(sender.value * 100);
    
    dampeningLbl.text = [NSString stringWithFormat:@"%i%%",(int)(per1 + (per1 * .2))];
    
    
    float per2 = dampeningSlider.value/dampeningSlider.maximumValue;
    
    //NSLog(@"per2: %f",per2);
    
    if (per2 >= .9)
    {
        dampeningImg.image = [UIImage imageNamed:@"dampening100.png"];
    }
    else if (per2 < .9 && per2 >= .75)
    {
        dampeningImg.image = [UIImage imageNamed:@"dampening75.png"];
    }
    else if (per2 < .75 && per2 >= .6)
    {
        dampeningImg.image = [UIImage imageNamed:@"dampening50.png"];
    }
    else if (per2 < .6 && per2 >= .5)
    {
        dampeningImg.image = [UIImage imageNamed:@"dampening25.png"];
    }
    else
    {
        dampeningImg.image = [UIImage imageNamed:@"dampening0.png"];
    }
    
    
    
    //dampeningLbl.text = [NSString stringWithFormat:@"%i%%",(int)(adjustedValue * 100)];
    
    [dampeningTimer invalidate];
    
    dampeningTimer = [NSTimer scheduledTimerWithTimeInterval:1.000 target:self selector:@selector(timerName) userInfo:nil repeats:NO];
}

- (void) timerName {
    
    float maxAccel = 30000;
    
    CGFloat adjustedValue = dampeningSlider.maximumValue - dampeningSlider.value + dampeningSlider.minimumValue;
    
    NSLog(@"adjustedValue: %f",adjustedValue);
    
    //float conv = pow((float)dampeningSlider.value,2) * maxAccel;
    
    float inverseVal = 1 - dampeningSlider.value;
    
    float conv = pow(inverseVal,2) * maxAccel;
    
    NSLog(@"conv: %f",conv);
    
    if ((int)self.motorNumber == 1)
    {
        self.appExecutive.dampening1 = conv;
    }
    else if ((int)self.motorNumber == 2)
    {
        self.appExecutive.dampening2 = conv;
    }
    else
    {
        self.appExecutive.dampening3 = conv;
    }
	
    [self.appExecutive.device motorSet: (int)self.motorNumber ContinuousSpeedAccelDecel: conv];
}

- (IBAction) handleSensitivitySlider: (UISlider *) sender {

    DDLogDebug(@"Sensitivity Slider: %g", sender.value);
    
    self.sensitivityValue.text = [NSString stringWithFormat: @"%3.0f%%", sender.value];
    self.appExecutive.sensitivityNumber = [NSNumber numberWithFloat: sender.value];
    
    sensitivityRatio = [self.appExecutive.sensitivityNumber floatValue]/100;
    
    NSLog(@"sensitivityRatio: %f",sensitivityRatio);
}

- (IBAction) handleReleaseSensitivitySlider: (UISlider *) sender {

    if (sender.value < 10.0)
    {
        [sender setValue: 10.0 animated: YES];
    }
    
    DDLogDebug(@"Release Sensitivity Slider: %g", sender.value);
    
    self.sensitivityValue.text = [NSString stringWithFormat: @"%3.0f%%", sender.value];
    self.appExecutive.sensitivityNumber = [NSNumber numberWithFloat: sender.value];
}

- (IBAction) goToPresets:(id)sender {
    
    UIButton *btn = sender;
    
    selectedSetting = [btn.restorationIdentifier intValue];
    
    NSLog(@"selectedSetting: %i",selectedSetting);
    
    [self performSegueWithIdentifier:@"goToPresets" sender:self];
}

- (IBAction) toogleJoystick:(id)sender {
    
    UISwitch *sw = sender;
    
    if (sw.isOn)
    {
        self.appExecutive.useJoystick = NO;
        [self.appExecutive.defaults setObject: [NSNumber numberWithInt:2] forKey: @"useJoystick"];
    }
    else
    {
        self.appExecutive.useJoystick = YES;
        [self.appExecutive.defaults setObject: [NSNumber numberWithInt:1] forKey: @"useJoystick"];
    }
    
    [self.appExecutive.defaults synchronize];
    
    NSLog(@"self.appExecutive.useJoystick: %i",self.appExecutive.useJoystick);
}

- (IBAction) enableLeft: (id) sender {
    
    [leftAutoTimer invalidate];
    [rightAutoTimer invalidate];
    
    if (!joystickmode)
    {
        [[NSNotificationCenter defaultCenter]
         postNotificationName:@"enterJSMode"
         object:nil];
        
        joystickmode = YES;
    }
    
    [[AppExecutive sharedInstance].device motorSet: (int)self.motorNumber ContinuousSpeed:0];
    lastContinuousValue = 0;
    
    [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(leftTimer) userInfo:nil repeats:NO];
}

- (void) leftTimer {
	
    if (!rightEnabled)
    {
        if (leftEnabled == NO)
        {
            [leftBtn setBackgroundColor:[UIColor whiteColor]];
            [rightBtn setBackgroundColor:defaultColor];
            okButton.enabled = NO;
            okButton.alpha = .5;
            leftEnabled = YES;
            
            leftAutoTimer = [NSTimer scheduledTimerWithTimeInterval:0.250 target:self selector:@selector(handleLeftTimer) userInfo:nil repeats:YES];
        }
        else
        {
            leftBtn.backgroundColor = defaultColor;
            
            okButton.enabled = YES;
            okButton.alpha = 1.0;
            leftEnabled = NO;
            
            [leftAutoTimer invalidate];
        }
        
        if (rightEnabled)
        {
            rightEnabled = NO;
        }
        
        if(!rightEnabled && !leftEnabled)
        {
            [leftAutoTimer invalidate];
        }
    }
    else
    {
        [leftAutoTimer invalidate];
        rightBtn.backgroundColor = defaultColor;
        leftBtn.backgroundColor = defaultColor;
        rightEnabled = NO;
        leftEnabled = NO;
        okButton.enabled = YES;
        okButton.alpha = 1.0;
    }
}

- (IBAction) enableRight: (id) sender {
    
    [rightAutoTimer invalidate];
    [leftAutoTimer invalidate];
    
    if (!joystickmode)
    {
        [[NSNotificationCenter defaultCenter]
         postNotificationName:@"enterJSMode"
         object:nil];
        
        joystickmode = YES;
    }
    
    [[AppExecutive sharedInstance].device motorSet: (int)self.motorNumber ContinuousSpeed:0];
    
    lastContinuousValue = 0;
    
    [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(rightTimer) userInfo:nil repeats:NO];
}

- (void) rightTimer {
    
    if (!leftEnabled)
    {
        if (rightEnabled == NO)
        {
            rightBtn.backgroundColor = [UIColor whiteColor];
            leftBtn.backgroundColor = defaultColor;
            okButton.enabled = NO;
            okButton.alpha = .5;
            rightEnabled = YES;
            
            rightAutoTimer = [NSTimer scheduledTimerWithTimeInterval:0.250 target:self selector:@selector(handleRightTimer) userInfo:nil repeats:YES];
        }
        else
        {
            rightBtn.backgroundColor = defaultColor;
            okButton.enabled = YES;
            okButton.alpha = 1.0;
            rightEnabled = NO;
            
            [rightAutoTimer invalidate];
        }
        
        if (leftEnabled)
        {
            leftEnabled = NO;
        }
        
        if(!rightEnabled && !leftEnabled)
        {
            [rightAutoTimer invalidate];
        }
    }
    else
    {
        [rightAutoTimer invalidate];
        
        rightBtn.backgroundColor = defaultColor;
        leftBtn.backgroundColor = defaultColor;
        rightEnabled = NO;
        leftEnabled = NO;
        okButton.enabled = YES;
        okButton.alpha = 1.0;
    }
}

- (void) handleLeftTimer {

    if(lastContinuousValue >= lowerLimit + continuousInterval)
    {
        lastContinuousValue = lastContinuousValue -= continuousInterval;
    }
    else
    {
        lastContinuousValue = lowerLimit;
    }
    
    NSLog(@"lastContinuousValue: %f",lastContinuousValue);
    
    [[AppExecutive sharedInstance].device motorSet: (int)self.motorNumber ContinuousSpeed:lastContinuousValue * sensitivityRatio];
}

- (void) handleRightTimer {

    if(lastContinuousValue <= upperLimit - continuousInterval)
    {
        lastContinuousValue = lastContinuousValue += continuousInterval;
    }
    else
    {
        lastContinuousValue = upperLimit;
    }
    
    //- (void) motorSet: (int) motorNumber ContinuousSpeed: (float) speed
    
    NSLog(@"lastContinuousValue: %f",lastContinuousValue);
    
    [[AppExecutive sharedInstance].device motorSet: (int)self.motorNumber ContinuousSpeed:lastContinuousValue * sensitivityRatio];
}

//if buttons pressed change joystick mode

- (IBAction) handleMicrostepsControl: (UISegmentedControl *) sender {
    
    NSLog(@"handleMicrostepsControl: %i",microstepSetting);
    
    if (joystickmode)
    {
        [[NSNotificationCenter defaultCenter]
         postNotificationName:@"exitJSMode"
         object:nil];
        
        joystickmode = NO;
    }
    
	NSInteger index	= sender.selectedSegmentIndex;

    switch (index)
    {
        case 0:
            
            [[AppExecutive sharedInstance].device motorSet: (int)self.motorNumber Microstep: 4];
            microstepSetting = 4;
            
            if ((int)self.motorNumber == 1)
            {
                self.appExecutive.microstep1 = 4;
            }
            else if ((int)self.motorNumber == 2)
            {
                self.appExecutive.microstep2 = 4;
            }
            else
            {
                self.appExecutive.microstep3 = 4;
            }
            
            break;
            
        case 1:
            
            [[AppExecutive sharedInstance].device motorSet: (int)self.motorNumber Microstep: 8];
            microstepSetting = 8;
            
            if ((int)self.motorNumber == 1)
            {
                self.appExecutive.microstep1 = 8;
            }
            else if ((int)self.motorNumber == 2)
            {
                self.appExecutive.microstep2 = 8;
            }
            else
            {
                self.appExecutive.microstep3 = 8;
            }
            
            break;
            
        case 2:
            
            [[AppExecutive sharedInstance].device motorSet: (int)self.motorNumber Microstep: 16];
            microstepSetting = 16;
            
            if ((int)self.motorNumber == 1)
            {
                self.appExecutive.microstep1 = 16;
            }
            else if ((int)self.motorNumber == 2)
            {
                self.appExecutive.microstep2 = 16;
            }
            else
            {
                self.appExecutive.microstep3 = 16;
            }
            
            break;
    }
    
    //NSString *title	= [sender titleForSegmentAtIndex: index];
    //NSInteger value	= [title integerValue];
	
    //DDLogDebug(@"Microsteps Control: %ld", (long)value);
    
    start = [self.appExecutive.device queryProgramStartPoint:(int)self.motorNumber];
    end = [self.appExecutive.device queryProgramEndPoint:(int)self.motorNumber];
    
    NSLog(@"2p start: %i",start);
    NSLog(@"2p end: %i",end);
    
    //distance = start - end;
    
    if(start > end)
    {
        distance = start - end;
    }
    else
    {
        distance = end - start;
    }
    
    if ((int)self.motorNumber == 1)
    {
        self.appExecutive.endPoint1 = end;
        self.appExecutive.startPoint1 = start;
    }
    else if ((int)self.motorNumber == 2)
    {
        self.appExecutive.endPoint2 = end;
        self.appExecutive.startPoint2 = start;
    }
    else
    {
        self.appExecutive.endPoint3 = end;
        self.appExecutive.startPoint3 = start;
    }
    
    [self getDistance];
    [self updateInvertUI];
}

- (IBAction) handleInvertDirectionSwitch: (UISwitch *) sender {
    
    if (joystickmode)
    {
        [[NSNotificationCenter defaultCenter]
         postNotificationName:@"exitJSMode"
         object:nil];
        
        joystickmode = NO;
    }
    
    [self updateInvertUI];
    
    [[AppExecutive sharedInstance].device motorSet: (int)self.motorNumber InvertDirection: sender.on];

    NSString *	value	= (sender.on ? @"ON" : @"OFF");

	DDLogDebug(@"Invert Direction: %@", value);
}

- (void) updateInvertUI {

    //NSString *direction;
    
    if([rigRatioLbl.text containsString:@"Stage R"] || [rigRatioLbl.text containsString:@"Rotary Custom"])
    {
        if (self.invertDirectionSwitch.isOn)
        {
            direction = @"CW";
        }
        else
        {
            direction = @"CCW";
        }
        
        leftLbl.text = @"CW";
        rightLbl.text = @"CCW";
        
        unitsLbl.text = [NSString stringWithFormat:@"%.02f Deg %@", degrees, direction];
        
        NSString *rp = [NSString stringWithFormat:@"%.02f Deg %@", degrees, direction];
        
        unitsTxt.text = [rp stringByReplacingOccurrencesOfString:@"-" withString:@""];
    }
    else
    {
        if (self.invertDirectionSwitch.isOn)
        {
            direction = @"L";
        }
        else
        {
            direction = @"R";
        }
        
        leftLbl.text = @"L";
        rightLbl.text = @"R";
        
        unitsLbl.text = [NSString stringWithFormat:@"%.02f In %@", inches, direction];
        
        NSString *rp = [NSString stringWithFormat:@"%.02f In %@", inches, direction];
        
        unitsTxt.text = [rp stringByReplacingOccurrencesOfString:@"-" withString:@""];
    }
    
    if ((int)self.motorNumber == 1)
    {
        [self.appExecutive.defaults setObject: direction forKey: @"slideDirection"];
    }
    else if ((int)self.motorNumber == 2)
    {
        [self.appExecutive.defaults setObject: direction forKey: @"panDirection"];
    }
    else if ((int)self.motorNumber == 3)
    {
        [self.appExecutive.defaults setObject: direction forKey: @"tiltDirection"];
    }
}

- (IBAction) handlePowerSaveSwitch: (UISwitch *) sender {
    
    if (joystickmode)
    {
        [[NSNotificationCenter defaultCenter]
         postNotificationName:@"exitJSMode"
         object:nil];
        
        joystickmode = NO;
    }
    
    [[AppExecutive sharedInstance].device motorSet: (int)self.motorNumber SleepMode: sender.on];
     
	NSString *value = (sender.on ? @"ON" : @"OFF");

	DDLogDebug(@"Power Save: %@", value);
}

- (IBAction) handleDisableSwitch:(UISwitch *)sender {
    
    if (joystickmode)
    {
        [[NSNotificationCenter defaultCenter]
         postNotificationName:@"exitJSMode"
         object:nil];
        
        joystickmode = NO;
    }
    
    [[AppExecutive sharedInstance].device motorSet: (int)self.motorNumber Disabled: sender.on];
    
    NSString *value	= (sender.on ? @"ON" : @"OFF");
    
    DDLogDebug(@"Disabled: %@", value);
}

- (IBAction) handleBacklashButton: (UIButton *)sender {
    
    if (joystickmode)
    {
        [[NSNotificationCenter defaultCenter]
         postNotificationName:@"exitJSMode"
         object:nil];
        
        joystickmode = NO;
    }
    
	// bring up 4 digit spinner

	DDLogDebug(@"Backlash Button");

	[self performSegueWithIdentifier: SegueToBacklashViewController sender: self];
}

- (IBAction) handleOkButton:(id)sender {
    
	//DDLogDebug(@"OK Button");
    
    if (joystickmode)
    {
        [[NSNotificationCenter defaultCenter]
         postNotificationName:@"exitJSMode"
         object:nil];
        
        joystickmode = NO;
    }
    
    if (joystickmode)
    {
        [[NSNotificationCenter defaultCenter]
         postNotificationName:@"exitJSMode"
         object:nil];
        
        joystickmode = NO;
    }
    
    int inverted = 0;
    
    if (self.invertDirectionSwitch.isOn)
    {
        inverted = 1;
    }
    
    motorDict = [[NSDictionary alloc] initWithObjectsAndKeys:
                 [NSNumber numberWithInt:(int)self.motorNumber],@"motor",
                 [NSNumber numberWithFloat:inches],@"inches",
                 [NSNumber numberWithFloat:degrees],@"degrees",
                 rigRatioLbl.text,@"rigRatio",
                 [NSNumber numberWithFloat:gearRatio],@"gearRatio",
                 direction,@"direction",
                 [NSNumber numberWithInt:inverted],@"inverted",
                 [NSNumber numberWithFloat:customLinearParam],@"customLinear",nil];
    
    if (distance != 0)
    {
        [[NSNotificationCenter defaultCenter]
         postNotificationName:@"updateLabels"
         object:motorDict];
    }
    
    [[NSNotificationCenter defaultCenter] removeObserver: self];

    [NSTimer scheduledTimerWithTimeInterval:0.250 target:self selector:@selector(okButtonTimer) userInfo:nil repeats:NO];
}

- (void) okButtonTimer {
    
    [[AppExecutive sharedInstance].device motorSet: (int)self.motorNumber SetBacklash: self.backlash];
    
    [self dismissViewControllerAnimated: YES completion: nil];
}

#pragma mark - Textfield Delegate Methods

- (BOOL) textFieldShouldReturn:(UITextField*)textField {
    
    if (textField.text.length == 0)
    {
        textField.text = @"-";
    }
	
	[textField resignFirstResponder];
	
	return YES;
}

- (void) textFieldDidBeginEditing:(UITextField *)textField {
    
    if ([textField.restorationIdentifier isEqualToString:@"unitsTxt"])
    {
        lastUnitValue = textField.text;
    }

    textField.text = @"";
}

- (BOOL) textFieldShouldEndEditing:(UITextField *)textField {
    
    if ([textField.restorationIdentifier isEqualToString:@"unitsTxt"])
    {
        if (textField.text.length == 0 || [textField.text isEqualToString:@"-"])
        {
           textField.text = lastUnitValue;
        }
        else
        {
            NSLog(@"value to recalculate: %f",calculatedValue);
            
            if (([rigRatioLbl.text containsString:@"Stage R"] || [rigRatioLbl.text containsString:@"Rotary Custom"]) && distance != 0)
            {
                degrees = [textField.text floatValue];
                
                [self recalculate:degrees];
            }
            else
            {
                //inches = [textField.text intValue];
                inches = [textField.text floatValue];
                
                [self recalculate:inches];
            }

            [self updateInvertUI];
        }
    }
    else
    {
        if (textField.text.length == 0)
        {
            textField.text = @"-";
        }
    }
    
    return  YES;
}

#pragma mark - Object Management

- (AppExecutive *) appExecutive {
    
    if (appExecutive == nil)
        appExecutive = [AppExecutive sharedInstance];
    
    return appExecutive;
}

@end
