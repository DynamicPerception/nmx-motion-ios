//
//  DeviceTableViewCell.m
//  Joystick
//
//  Created by Mitch Middler on 1/14/16.
//  Copyright © 2016 Mark Zykin. All rights reserved.
//

#import "DeviceTableViewCell.h"
#import "DeviceSelectionTableViewController.h"
#import "AppExecutive.h"

@implementation DeviceTableViewCell

- (IBAction) settingsButtonSelected: (id) sender
{
#if !TARGET_IPHONE_SIMULATOR
    
    AppExecutive * appExecutive = [AppExecutive sharedInstance];
    appExecutive.device = self.device;
    
    [self.tableView performSegueWithIdentifier:@"showSettingsView" sender:self];
#endif
}

- (IBAction) connectButtonSelected: (id) sender
{
    if (self.device.disconnected)
    {
        [self.tableView disconnectAll];
        
        [self initFirmware];
        
        [self.activityIndicator startAnimating];
        
        UIButton *button = (UIButton *)sender;
        button.hidden = YES;
    }
    else
    {
        [self.tableView navigateToMainViewWithDevice: self.device];
    }
}



#pragma mark device firmware initialization

- (void) initFirmware
{
    self.device.delegate = self;
    
    [self.device connect];
}

- (NSString *)getImageForDeviceStatus: (NMXDevice *)device
{
    //    NSString *deviceImage = @"DeviceState_Indeterminate.png";
    NSString *deviceImage = @"DeviceState_Off.png";
    if (device.fwVersion)
    {
        deviceImage = device.fwVersionUpdateAvailable ? @"DeviceState_Warning.png" : @"DeviceState_Ready.png";
    }
    
    return deviceImage;
}

- (void) didConnect: (NMXDevice *) device
{
    // Initialize the device state and query firmware
    
    // For now, we are doing all of our device communication on the main queue.  Would be good to move it to it's own queue...
    
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        int queryStatus = [device mainQueryRunStatus];
        AppExecutive *ae = [AppExecutive sharedInstance];
        
        if (queryStatus == 99) {
            
            NSLog(@"stop everything");
            
            ae.resetController = YES;  // FIX ME: This needs to be handled
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Connection Error"
                                                                message: @"Please reset controller"
                                                               delegate: nil
                                                      cancelButtonTitle: @"OK"
                                                      otherButtonTitles: nil];
                [alert show];
            });
        }
        else {
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [self.activityIndicator stopAnimating];
                [self.connectGoButton setTitle:@"Go >" forState:UIControlStateNormal];
                self.connectGoButton.hidden = NO;
                self.settingsButton.enabled = YES;
                self.settingsButton.hidden = NO;
                
                NSString *deviceImage = [self getImageForDeviceStatus: device];
                self.imageView.image = [UIImage imageNamed: deviceImage];
                
                NSLog(@"Updating image after firmware check %@", deviceImage);
                
            });
        }
    });
    
    
}

- (void) didDisconnectDevice: (CBPeripheral *) peripheral
{
    // Do nothing, we expect this disconnect after querying the version number
}

- (void) disconnectDevice
{
    if (NO == self.device.disconnected)
    {
        [self.device disconnect];
        
        [self.connectGoButton setTitle:@"Connect" forState:UIControlStateNormal];
        self.settingsButton.enabled = NO;
        self.settingsButton.hidden = YES;
        
        self.imageView.image = [UIImage imageNamed: @"DeviceState_Off.png"];
    }
}


@end
