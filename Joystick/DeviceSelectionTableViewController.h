//
//  DeviceSelectionTableViewController.h
//  Joystick
//
//  Created by Dave Koziol on 10/20/14.
//  Copyright (c) 2014 Dynamic Perception. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NMXDeviceManager.h"
#import "JoyButton.h"

@interface DeviceSelectionTableViewController : UIViewController <NMXDeviceManagerDelegate, UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet JoyButton *shareBtn;
@property (weak, nonatomic) IBOutlet UILabel *notificationLbl;

@end