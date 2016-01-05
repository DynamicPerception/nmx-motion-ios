//
//  LinearRotaryViewController.h
//  Joystick
//
//  Created by Randall Ridley on 9/10/15.
//  Copyright (c) 2015 Mark Zykin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JoyButton.h"
#import "AppDelegate.h"

@interface LinearRotaryViewController : UIViewController <UITextFieldDelegate,UIPickerViewDataSource,UIPickerViewDelegate> {

    AppDelegate *appDelegate;
    NSString *preset;
    UIPickerView *picker;
    float selectedFloat;
}

@property (weak, nonatomic) IBOutlet UITextField *valueTxt;
@property (weak, nonatomic) IBOutlet UILabel *headingLbl;
@property (weak, nonatomic) NSString *heading;
@property (nonatomic, strong)		NSMutableArray *presetList;
@property (nonatomic, strong)		NSMutableArray *presetStringList;
@property (nonatomic, strong)	IBOutlet	UIPickerView *	picker;
@property float currentCustomVal;

- (IBAction) handleOkButton: (id) sender;
- (IBAction) cancel:(id)sender;

@end
