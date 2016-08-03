//
//  ViewController.h
//  joystick
//
//  Created by Mark Zykin on 10/1/14.
//  Copyright (c) 2014 Dynamic Perception. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "JoystickViewController.h"
#import "NMXDevice.h"
#import "AppDelegate.h"
#import "JoystickSlider.h"
#import "HelpViewController.h"

@interface MainViewController : UIViewController <JoystickOutput, UITableViewDelegate,
                                                  UITableViewDataSource> {

    bool animated1;
    
    float distance1;
    float distance2;
    float distance3;
    
    bool inverted1;
    bool inverted2;
    bool inverted3;
    
    float slideGear;
    float panGear;
    float tiltGear;
    
    NSString *slideRig;
    NSString *panRig;
    NSString *tiltRig;
    NSString *slideDirection;
    NSString *panDirection;
    NSString *tiltDirection;
    
    float slideLinearCustom;
    float panLinearCustom;
    float tiltLinearCustom;
    int trInd;
    int tlInd;
    int brInd;
    int blInd;
    
    NSTimer *brTimer;
    NSTimer *blTimer;
    NSTimer *trTimer;
    NSTimer *tlTimer;
    
    NSTimer *brTimer2;
    NSTimer *blTimer2;
    NSTimer *trTimer2;
    NSTimer *tlTimer2;
    
    UISlider *_dollySlider;
    
    AppDelegate *appDelegate;
    
    UIView *batteryView;
    
    bool debugDistance;
    bool disconnected;
}

@property (weak, nonatomic)	IBOutlet UISwitch *dominantAxisSwitch;
@property (weak, nonatomic)	IBOutlet UISwitch *switch2P;

@property (weak, nonatomic) IBOutlet UILabel *distanceSlideLbl;
@property (weak, nonatomic) IBOutlet UILabel *distancePanLbl;
@property (weak, nonatomic) IBOutlet UILabel *distanceTiltLbl;

@property (weak, nonatomic) IBOutlet UILabel *mode3PLbl;
@property (weak, nonatomic) IBOutlet UILabel *mode3PLbl2;

@property (strong, nonatomic) IBOutlet NSMutableArray *trList;
@property (weak, nonatomic) IBOutlet UIView *trView;
@property (strong, nonatomic) IBOutlet NSMutableArray *tlList;
@property (weak, nonatomic) IBOutlet UIView *tlView;
@property (strong, nonatomic) IBOutlet NSMutableArray *brList;
@property (weak, nonatomic) IBOutlet UIView *brView;
@property (strong, nonatomic) IBOutlet NSMutableArray *blList;
@property (weak, nonatomic) IBOutlet UIView *blView;

@property (strong, nonatomic) IBOutlet NSMutableArray *trList2;
@property (strong, nonatomic) IBOutlet NSMutableArray *tlList2;
@property (strong, nonatomic) IBOutlet NSMutableArray *brList2;
@property (strong, nonatomic) IBOutlet NSMutableArray *blList2;

@property (strong, nonatomic) IBOutlet NSMutableArray *uiList;
@property (weak, nonatomic) IBOutlet UIView *joystickViefw;

@property (weak, nonatomic) IBOutlet UIImageView *panSliderBG;
@property (weak, nonatomic) IBOutlet JoystickSlider *panSlider;
@property (weak, nonatomic) IBOutlet UILabel *panSliderLbl;

@property (weak, nonatomic) IBOutlet UIImageView *tiltSliderBG;
@property (weak, nonatomic) IBOutlet JoystickSlider *tiltSlider;
@property (weak, nonatomic) IBOutlet UILabel *tiltSliderLbl;
@property (weak, nonatomic) IBOutlet UIImageView *batteryIcon;

@property (strong, nonatomic) NSMutableArray *ar1;
@property (strong, nonatomic) NSMutableArray *ar2;
@property (strong, nonatomic) NSMutableArray *ar3;

@property (weak, nonatomic) IBOutlet UIView *setStartView;
@property (weak, nonatomic) IBOutlet UIButton *setStart1Btn;
@property (weak, nonatomic) IBOutlet UIButton *goTo1Btn;
@property (weak, nonatomic) IBOutlet UIButton *cancel1Btn;

@property (weak, nonatomic) IBOutlet UIView *setMidView;
@property (weak, nonatomic) IBOutlet UIButton *setMid1Btn;
@property (weak, nonatomic) IBOutlet UIButton *goToMidBtn;
@property (weak, nonatomic) IBOutlet UIButton *cancelMidBtn;

@property (weak, nonatomic) IBOutlet UIView *setStopView;
@property (weak, nonatomic) IBOutlet UIButton *setStop1Btn;
@property (weak, nonatomic) IBOutlet UIButton *goToStopBtn;
@property (weak, nonatomic) IBOutlet UIButton *cancelStopBtn;
@property (weak, nonatomic) IBOutlet UIView *controlBackground;

@property (nonatomic, strong)				NSTimer *			sendMotorsTimer;

- (IBAction) setStartPoint1:(id)sender;
- (IBAction) goToStartPoint1:(id)sender;
- (IBAction) closeStartView:(id)sender;

- (IBAction) setStopPoint1:(id)sender;
- (IBAction) goToStopPoint1:(id)sender;
- (IBAction) closeStopView:(id)sender;

- (IBAction) setMidPoint1:(id)sender;
- (IBAction) goToMidPoint1:(id)sender;
- (IBAction) closeMidView:(id)sender;

- (IBAction) unwindFromSetupViewController: (UIStoryboardSegue *) segue;
- (IBAction) handleDominantAxisSwitch: (UISwitch *) sender;
- (IBAction) manage2P:(id)sender;

- (void) activeDeviceChanged;

@end
