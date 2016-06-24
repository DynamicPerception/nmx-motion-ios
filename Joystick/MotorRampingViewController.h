//
//  MotorRampingViewController.h
//  Joystick
//
//  Created by Mark Zykin on 4/7/15.
//  Copyright (c) 2015 Mark Zykin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FrameCountViewController.h"
#import "ShortDurationViewController.h"
#import "DurationViewController.h"
#import "NMXDevice.h"
#import "NMXDeviceManager.h"
#import "SetupViewController.h"
#import "HelpViewController.h"

NSString	static	*kSegueToMotorRampingViewController	= @"SegueToMotorRampingViewController";

@interface MotorRampingViewController : UIViewController <UITextFieldDelegate, MotorRampingDelegate, UIPickerViewDataSource, UIPickerViewDelegate> {

    //id myDelegate;
    
    NMXProgramMode      programMode;
    bool isVideo;
    UInt32  rampMode;
    float masterFrameCount;
    
    NSTimer *update3PTimer;
    bool isProg;
    int newVal;
    int selectedVideoFrame;
    float selectedPercentage;
    
    int s12p;
    int s22p;
    int s32p;
    int s42p;
    
    int p12p;
    int p22p;
    int p32p;
    int p42p;
    
    int t12p;
    int t22p;
    int t32p;
    int t42p;
}

@property int selectedFrameNumber;
@property int selectedShotDuration;

@property (nonatomic, strong)	IBOutlet UIPickerView *	picker;
@property (strong, nonatomic) IBOutlet UIView *framePickerView;
@property (strong, nonatomic) IBOutlet UISegmentedControl *rampSettingSegment;
@property (weak, nonatomic) IBOutlet UIImageView *rampSettingImg;

@property (weak, nonatomic) IBOutlet UILabel *slide3P1Lbl;
@property (weak, nonatomic) IBOutlet UILabel *slide3P2Lbl;
@property (weak, nonatomic) IBOutlet UILabel *slide3P3Lbl;

@property (weak, nonatomic) IBOutlet UISlider *slide3PSlider1;
@property (weak, nonatomic) IBOutlet UISlider *slide3PSlider2;
@property (weak, nonatomic) IBOutlet UISlider *slide3PSlider3;

@property (weak, nonatomic) IBOutlet UILabel *pan3P1Lbl;
@property (weak, nonatomic) IBOutlet UILabel *pan3P2Lbl;
@property (weak, nonatomic) IBOutlet UILabel *pan3P3Lbl;

@property (weak, nonatomic) IBOutlet UISlider *pan3PSlider1;
@property (weak, nonatomic) IBOutlet UISlider *pan3PSlider2;
@property (weak, nonatomic) IBOutlet UISlider *pan3PSlider3;

@property (weak, nonatomic) IBOutlet UILabel *tilt3P1Lbl;
@property (weak, nonatomic) IBOutlet UILabel *tilt3P2Lbl;
@property (weak, nonatomic) IBOutlet UILabel *tilt3P3Lbl;

@property (weak, nonatomic) IBOutlet UISlider *tilt3PSlider1;
@property (weak, nonatomic) IBOutlet UISlider *tilt3PSlider2;
@property (weak, nonatomic) IBOutlet UISlider *tilt3PSlider3;

@property (weak, nonatomic) IBOutlet UIView *slide3PView;
@property (weak, nonatomic) IBOutlet UIView *pan3PView;
@property (weak, nonatomic) IBOutlet UIView *tilt3PView;

@property (weak, nonatomic) IBOutlet UILabel *topHeaderLbl;
@property (weak, nonatomic) IBOutlet UIButton *settingsButton;
@property (weak, nonatomic) IBOutlet UIImageView *batteryIcon;
@property (weak, nonatomic) IBOutlet UIView *contentBG;

- (IBAction) handleSlide3PSlider1:(id)sender;
- (IBAction) handleSlide3PSlider2:(id)sender;
- (IBAction) handleSlide3PSlider3:(id)sender;

- (IBAction) updateRampEasingValue:(id)sender;
- (void) saveFrame: (NSNumber *)number;

@property (weak, nonatomic) IBOutlet UILabel *slideLbl2;
@property (weak, nonatomic) IBOutlet UILabel *slideLbl1;
@property (weak, nonatomic) IBOutlet UILabel *slideLbl3;
@property (weak, nonatomic) IBOutlet UILabel *slideLbl4;

@property (weak, nonatomic) IBOutlet UILabel *panLbl2;
@property (weak, nonatomic) IBOutlet UILabel *panLbl1;
@property (weak, nonatomic) IBOutlet UILabel *panLbl3;
@property (weak, nonatomic) IBOutlet UILabel *panLbl4;

@property (weak, nonatomic) IBOutlet UILabel *tiltLbl2;
@property (weak, nonatomic) IBOutlet UILabel *tiltLbl1;
@property (weak, nonatomic) IBOutlet UILabel *tiltLbl3;
@property (weak, nonatomic) IBOutlet UILabel *tiltLbl4;



@end
