//
//  AboutViewController.h
//  Joystick
//
//  Created by Dave Koziol on 1/5/15.
//  Copyright (c) 2015 Dynamic Perception. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>			// email composer
#include <math.h>
#import <QuartzCore/QuartzCore.h>

@interface DeviceSettingsViewController : UIViewController <UITextFieldDelegate, MFMailComposeViewControllerDelegate> {

    NSString *low;
    NSString *high;
}

@property (weak, nonatomic) IBOutlet UITextField *voltageLowTxt;
@property (weak, nonatomic) IBOutlet UITextField *voltageHighTxt;

@end
