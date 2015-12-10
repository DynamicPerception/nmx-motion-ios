//
//  HelpViewController.h
//  Joystick
//
//  Created by Randall Ridley on 10/6/15.
//  Copyright (c) 2015 Mark Zykin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HelpViewController : UIViewController

@property int screenInd;
@property (weak, nonatomic) IBOutlet UITextView *helpTxt;

- (IBAction) handleOkButton:(id)sender;

@end
