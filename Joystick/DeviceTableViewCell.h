//
//  DeviceTableViewCell.h
//  Joystick
//
//  Created by Mitch Middler on 1/14/16.
//  Copyright © 2016 Mark Zykin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NMXDeviceManager.h"

@class DeviceSelectionTableViewController;

@interface DeviceTableViewCell : UITableViewCell <NMXDeviceDelegate, UIAlertViewDelegate>

@property (strong, nonatomic) IBOutlet UIButton *settingsButton;
@property (strong, nonatomic) NMXDevice *device;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
//@property (strong, nonatomic) IBOutlet UIButton *connectGoButton;
@property (strong, nonatomic) IBOutlet UISwitch *connectSwitch;
@property (weak) DeviceSelectionTableViewController *tableView;
@property int runStatus;

- (void) preDeviceStateChange;
- (void) postDeviceStateChange;
- (NSString *)getImageForDeviceStatus: (NMXDevice *)device;

@end