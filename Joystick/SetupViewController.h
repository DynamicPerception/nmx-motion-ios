//
//  ProgramSetupViewController.h
//  Joystick
//
//  Created by Mark Zykin on 10/7/14.
//  Copyright (c) 2014 Dynamic Perception. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ExposureViewController.h"
#import "DurationViewController.h"
#import "ShortDurationViewController.h"
#import "FrameRateViewController.h"
#import "PresetOb.h"
#import "AppDelegate.h"
#import "HelpViewController.h"
#import "JSDisconnectedDeviceVC.h"

@interface SetupViewController : UIViewController <ExposureDelegate, DurationDelegate, ShortDurationDelegate, FrameRateDelegate,
                                 JSDisconnectedDeviceDelegate, UITextFieldDelegate> {
    
    AppDelegate *appDelegate;
    NSEntityDescription *entity;
}

@property (weak, nonatomic) IBOutlet UIButton *restoreDefaultsBtn;
@property (weak, nonatomic) IBOutlet UIView *buttonView;
@property (weak, nonatomic) IBOutlet UILabel *minimuDurationLbl;
@property (weak, nonatomic) IBOutlet UILabel *minimumDurationHeaderLbl;
@property (weak, nonatomic) IBOutlet UILabel *minimumDurationSubHeaderLbl;
@property (weak, nonatomic) IBOutlet UIImageView *batteryIcon;

@end
