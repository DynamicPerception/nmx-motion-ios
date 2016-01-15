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

- (void) navigateToMainViewWithDevice: (NMXDevice *)device;
- (void) disconnectAll;

@end

@interface DeviceTableViewCell : UITableViewCell <NMXDeviceDelegate>

@property (strong, nonatomic) IBOutlet UIButton *settingsButton;
@property (strong, nonatomic) NMXDevice *device;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (strong, nonatomic) IBOutlet UIButton *connectGoButton;
@property (weak) DeviceSelectionTableViewController *tableView;

- (void) disconnectDevice;

@end