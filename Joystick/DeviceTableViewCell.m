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
        [self.device disconnect];
        self.settingsButton.enabled = NO;
        self.settingsButton.hidden = YES;
        self.imageView.image = [UIImage imageNamed: @"DeviceState_Off.png"];
        [self.tableView.activeDevices removeObject: self.device];
    }

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
        deviceImage = device.fwVersionUpdateAvailable ? @"DeviceState_Warning.png" : @"DeviceState_Ready.png";
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

- (void) didConnect: (NMXDevice *) device
{
    // Initialize the device state and query firmware
    
    // For now, we are doing all of our device communication on the main queue.  Would be good to move it to it's own queue...
    
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        int queryStatus = [device mainQueryRunStatus];
        int queryStatusKeyFrame = [device queryKeyFrameProgramRunState];
        
        AppExecutive *ae = [AppExecutive sharedInstance];
        
        if (queryStatus == 99 || queryStatusKeyFrame == 99 ||
            queryStatus == NMXRunStatusUnknown || queryStatusKeyFrame == NMXRunStatusUnknown) {
            
            NSLog(@"stop everything");
            
            ae.resetController = YES;  // FIX ME: This needs to be handled
            
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
                
                if ((NMXRunStatusRunning & queryStatus) || NMXRunStatusRunning & queryStatusKeyFrame)
                {
                    [self.tableView navigateToMainView];
                }
                
                [self.tableView postDevicesStateChange];
                
                if (![self.tableView.activeDevices containsObject: device])
                {
                    [self.tableView.activeDevices addObject: device];
                }
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


@end
