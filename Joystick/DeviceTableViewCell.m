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

@interface DeviceTableViewCell()

@property (atomic, strong) NSTimer *connectionTimer;

@end

@implementation DeviceTableViewCell

- (IBAction) settingsButtonSelected: (id) sender
{
#if !TARGET_IPHONE_SIMULATOR
    
    AppExecutive * appExecutive = [AppExecutive sharedInstance];
    appExecutive.device = self.device;
    
    [self.tableView performSegueWithIdentifier:@"showSettingsView" sender:self];
#endif
}

- (IBAction)connectSwitchSelected:(id)sender {
    if (self.connectSwitch.on)
    {
        if (self.device.disconnected)
        {
            [self connect];
        }
    }
    else
    {
        [self disconnect];
    }

}

- (void) disconnect
{
    AppExecutive *ae = [AppExecutive sharedInstance];
    ae.deviceManager.delegate = self;
    
    [self.device disconnect];
    self.settingsButton.enabled = NO;
    self.settingsButton.hidden = YES;
    self.imageView.image = [UIImage imageNamed: @"DeviceState_Off.png"];
    [self.tableView.activeDevices removeObject: self.device];
}

- (void) connectionTimeout
{
    [self handleConnectionError];
}

#pragma mark device firmware initialization

- (void) initFirmware
{
    self.device.delegate = self;
    self.device.serviceDiscoveryRetryCount = 3;  // Retry connection 3 times
    [self.device connect];
}

- (NSString *)getImageForDeviceStatus: (NMXDevice *)device
{
    //    NSString *deviceImage = @"DeviceState_Indeterminate.png";
    NSString *deviceImage = @"DeviceState_Off.png";
    if (device.fwVersion && NO == device.disconnected)
    {
        if (NMXRunStatusRunning & self.runStatus)
        {
            deviceImage = @"DeviceStateRunning.png";
        }
        else
        {
            deviceImage = device.fwVersionUpdateAvailable ? @"DeviceState_Warning.png" : @"DeviceState_Ready.png";
        }
    }
    
    return deviceImage;
}

- (void) handleConnectionError
{
    [self.connectionTimer invalidate];
    self.connectionTimer = nil;

    [self.activityIndicator stopAnimating];
    //    [self.connectGoButton setTitle:@"Connect" forState:UIControlStateNormal];
    //    self.connectGoButton.hidden = NO;
    //    self.connectGoButton.enabled = YES;
    self.settingsButton.hidden = YES;
    self.connectSwitch.selected = NO;
    
    NSString *deviceImage = [self getImageForDeviceStatus: self.device];
    self.imageView.image = [UIImage imageNamed: deviceImage];
    
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Connection Error"
                                                    message: @"Please reset controller"
                                                   delegate: nil
                                          cancelButtonTitle: @"OK"
                                          otherButtonTitles: nil];
    [alert show];

    [self.connectSwitch setOn:NO animated:YES];

}

- (void) connect
{
    self.connectionTimer = [NSTimer scheduledTimerWithTimeInterval:15.0
                                                            target:self
                                                          selector:@selector(connectionTimeout)
                                                          userInfo:nil
                                                           repeats:YES];
    
    [self.tableView preDevicesStateChange];
    
    [self initFirmware];
    
    [self.activityIndicator startAnimating];
}

- (BOOL) confirmOkForMultiController: (NMXDevice *)device
{
    if (self.tableView.activeDevices.count == 0) return YES;
    
    NSString *msg = nil;
    
    if (device.fwVersion < 68)
    {
        msg = @"The firmware on the selected device must be upgraded to "
               "v. 0.68 or newer to use in a multi-contoller environment."
               "\nDisconnecting.";
    }
    else
    {
        for (NMXDevice *activeDevice in self.tableView.activeDevices)
        {
            if (activeDevice.fwVersion < 68)
            {
                msg = [NSString stringWithFormat:@"Device %@ must be upgraded to "
                                                  "v. 0.68 or newer to use a multi-contoller environment."
                                                  "\nDisconnecting.", [[AppExecutive sharedInstance] stringWithHandleForDeviceName: activeDevice.name] ];
                break;
            }
        }
    }
    
    if (msg)
    {
        [self.connectSwitch setOn:NO animated:YES];
        [self disconnect];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Error"
                                                        message: msg
                                                       delegate: nil
                                              cancelButtonTitle: @"OK"
                                              otherButtonTitles: nil];
        [alert show];
        return NO;

    }
    
    return YES;
}

- (void) determineRunStatus: (NMXDevice *)device
{
    int queryStatus = [device mainQueryRunStatus];
    int queryStatusKeyFrame = [device queryKeyFrameProgramRunState];
    
    self.runStatus = queryStatus | queryStatusKeyFrame;
}

- (void) didConnect: (NMXDevice *) device
{
    // Initialize the device state and query firmware
    
    // For now, we are doing all of our device communication on the main queue.  Would be good to move it to it's own queue...
    
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        [self determineRunStatus: device];

        if (self.runStatus & NMXRunStatusKeyframe)
        {
            [AppExecutive sharedInstance].is3P = YES;
        }
        
        if (self.runStatus == 99 || self.runStatus == NMXRunStatusUnknown) {
            
            NSLog(@"stop everything");
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self handleConnectionError];
            });
        }
        else {
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [self.connectionTimer invalidate];
                self.connectionTimer = nil;
                [self.activityIndicator stopAnimating];
                //                [self.connectGoButton setTitle:@"Go >" forState:UIControlStateNormal];
                self.connectSwitch.on = YES;
                //                self.connectGoButton.hidden = NO;
                self.settingsButton.enabled = YES;
                self.settingsButton.hidden = NO;
                
                NSString *deviceImage = [self getImageForDeviceStatus: device];
                self.imageView.image = [UIImage imageNamed: deviceImage];

                if (NMXRunStatusRunning & self.runStatus)
                {
                    self.numRunning = [device mainQueryControllerCount];
                }
                
                if ([self confirmOkForMultiController: device] &&
                    ![self.tableView.activeDevices containsObject: device])
                {
                    [self.tableView.activeDevices addObject: device];
                }

                [self.tableView postDevicesStateChange];
                
            });
        }
    });
    
    
}


- (void) preDeviceStateChange
{
    self.connectSwitch.enabled = NO;
}

- (void) postDeviceStateChange
{
    self.connectSwitch.enabled = YES;
}

#pragma mark NMXDeviceManagerDelegate

- (void) didDisconnectDevice: (CBPeripheral *) peripheral {
    
    // Eat this, we disconnected the device ourself

}

@end
