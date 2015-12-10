//
//  SavePresetViewController.h
//  Joystick
//
//  Created by Randall Ridley on 8/24/15.
//  Copyright (c) 2015 Mark Zykin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "PresetOb.h"
#import "JoyButton.h"

@interface SavePresetViewController : UIViewController <UITextFieldDelegate> {

    AppDelegate *appDelegate;
    NSEntityDescription *entity;
}

@property (weak, nonatomic) IBOutlet UITextField *presetTxt;

- (IBAction) handleOkButton: (id) sender;
- (IBAction) cancel:(id)sender;

@end
