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

@class JSMotorRampingTableViewCell;

NSString	static	*kSegueToMotorRampingViewController	= @"SegueToMotorRampingViewController";

@interface MotorRampingViewController : UIViewController <UITextFieldDelegate, MotorRampingDelegate, UIPickerViewDataSource, UIPickerViewDelegate> {

    //id myDelegate;
    
    bool isVideo;
    UInt32  rampMode;
    
    NSTimer *update3PTimer;
    bool isProg;
    int newVal;
    int selectedVideoFrame;
    float selectedPercentage;
}

@property float          currentSelectedFrameValue;
@property int            selectedFrameCount;
@property NMXProgramMode programMode;
@property BOOL           isLocked;


@property int selectedFrameNumber;
@property int selectedShotDuration;

@property (nonatomic, strong)	IBOutlet UIPickerView *	picker;
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

@property NSString *currentFrameTarget;
@property float currentFrameConvertedToFloat;
@property UISlider *selectedSlider;
@property JSMotorRampingTableViewCell *currentCell;

- (IBAction) handleSlide3PSlider1:(id)sender;
- (IBAction) handleSlide3PSlider2:(id)sender;
- (IBAction) handleSlide3PSlider3:(id)sender;
- (IBAction) updateRampEasingValue:(id)sender;
- (void) showFrameText:(JSMotorRampingTableViewCell *)cell slider:(UISlider *)slider;

- (void) resetThumbSelection;
- (void) saveFrame: (NSNumber *)number;
- (NSString *)convertTime2 : (float)val;

- (void) updateIncreaseStartSliders: (UISlider *) slider;
- (void) updateIncreaseFinalSliders: (UISlider *) slider;
- (void) updateDecreaseStartSliders: (UISlider *) slider;
- (void) updateDecreaseFinalSliders: (UISlider *) slider;

- (UIImage *) imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize;

@end
