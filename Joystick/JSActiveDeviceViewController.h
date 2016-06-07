//
//  JSActiveDeviceViewController.h
//  Joystick
//
//  Created by Mitch Middler on 5/31/16.
//  Copyright © 2016 Dynamic Perception. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MainViewController;


@interface JSActiveDeviceViewController : UIViewController <UIPickerViewDelegate, UIPickerViewDataSource>

@property MainViewController *mainVC;

@end


