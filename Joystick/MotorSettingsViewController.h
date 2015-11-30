//
//  MotorSettingsViewController.h
//  Joystick
//
//  Created by Mark Zykin on 11/21/14.
//  Copyright (c) 2014 Dynamic Perception. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "BacklashViewController.h"
#import "AppExecutive.h"
#import "DistancePresetViewController.h"
#import "AppDelegate.h"
#import "SiderealViewController.h"
#import "HelpViewController.h"

@interface MotorSettingsViewController : UIViewController <BacklashDelegate, UITextFieldDelegate,UIScrollViewDelegate> {

    BOOL leftEnabled;
    BOOL rightEnabled;
    NSTimer *rightAutoTimer;
    NSTimer *leftAutoTimer;
    float lastContinuousValue;
    int continuousInterval;
    int upperLimit;
    int lowerLimit;
    UIColor *defaultColor;
    BOOL joystickmode;
    int selectedSetting;
    float distance;
    int microstepSetting;
    float degrees;
    float inches;
    NSString *lastUnitValue;
    bool hasNegative;
    float calculatedValue;
    int start;
    int end;
    float customLinearParam;
    NSDictionary *motorDict;
    float gearRatio;
    NSString *direction;
    AppDelegate *appDelegate;
    float sensitivityRatio;
    float lastMicrostep;
}

@property (nonatomic, strong)		NSString *	motorName;
@property (nonatomic, readwrite)	NSInteger	motorNumber;
@property (strong, nonatomic) IBOutlet UIButton *leftBtn;
@property (strong, nonatomic) IBOutlet UIButton *rightBtn;
@property (nonatomic, strong)				AppExecutive *				appExecutive;
@property (weak, nonatomic) IBOutlet UILabel *distanceLbl;
@property (weak, nonatomic) IBOutlet UILabel *presetLbl;
@property (weak, nonatomic) IBOutlet UIScrollView *contentScroll;
@property (weak, nonatomic) IBOutlet UILabel *gearRatioLbl;
@property (weak, nonatomic) IBOutlet UILabel *rigRatioLbl;
@property (weak, nonatomic) IBOutlet UITextField *overallDistanceTxt;
@property (weak, nonatomic) IBOutlet UILabel *leftLbl;
@property (weak, nonatomic) IBOutlet UILabel *rightLbl;
@property (weak, nonatomic) IBOutlet UILabel *unitsLbl;
@property (weak, nonatomic) IBOutlet UIView *scrollPositionView;
@property (weak, nonatomic) IBOutlet UITextField *unitsTxt;
@property (weak, nonatomic) IBOutlet UILabel *sensitivityValue;
@property (weak, nonatomic)	IBOutlet UISlider *	sensitivitySlider;
@property (weak, nonatomic) IBOutlet UILabel *joystickResponseLbl;
@property (weak, nonatomic) IBOutlet JoyButton *siderealBtn;
@property (weak, nonatomic) IBOutlet UILabel *overallDistanceLbl;
@property (weak, nonatomic) IBOutlet UISwitch *toggleJoystickSwitch;

- (IBAction) handleReleaseSensitivitySlider: (UISlider *) sender;
- (IBAction) handleSensitivitySlider: (UISlider *) sender;
- (IBAction)goToPresets:(id)sender;
- (IBAction)toogleJoystick:(id)sender;

@end
