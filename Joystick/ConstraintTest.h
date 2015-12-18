//
//  ConstraintTest.h
//  Joystick
//
//  Created by Randall Ridley on 9/12/15.
//  Copyright (c) 2015 Mark Zykin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JoyButton.h"

@interface ConstraintTest : UIViewController
@property (weak, nonatomic) IBOutlet UIView *buttonView;
@property (weak, nonatomic) IBOutlet JoyButton *overBtn;

@end
