//
//  JSDisconnectedDeviceVC.m
//  Joystick
//
//  Created by Mitch Middler on 8/10/16.
//  Copyright © 2016 Dynamic Perception. All rights reserved.
//

#import "JSDisconnectedDeviceVC.h"
#import "AppExecutive.h"
#import "NMXDevice.h"

@interface JSDisconnectedDeviceVC ()

@property (strong, nonatomic) IBOutlet UILabel *disconnectedReason;
@property NSMutableArray<NMXDevice *> *deviceList;
@property (strong, nonatomic) IBOutlet UIButton *reconnectOrAbort;
@property (strong, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation JSDisconnectedDeviceVC

- (void)viewDidLoad {
    [super viewDidLoad];

    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    NSString *reasonString = @"Shot setup progress saved successfully to NMX.\n\n"
    "App has detected a loss in communication (possibly due to distance or "
    "interference) and will attempt to reconnect automatically.  Please wait or "
    "select Abort to return to the controller connection screen and manually reconnect to the controller.";
    
    self.disconnectedReason.text = reasonString;
    
    [self.reconnectOrAbort setTitle:@"Abort" forState: UIControlStateNormal];
    
    [AppExecutive sharedInstance].deviceManager.delegate = self;
    [[AppExecutive sharedInstance].deviceManager startScanning];
    
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(deviceDisconnect:)
                                                 name: kDeviceDisconnectedNotification
                                               object: nil];

    
}

- (void) viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];

    [AppExecutive sharedInstance].deviceManager.delegate = nil;
    [[AppExecutive sharedInstance].deviceManager stopScanning];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];

}

- (IBAction)reconnectOrAbort:(id)sender
{
    if (self.delegate)
    {
        [self.delegate willAbortReconnect];
    }

    [self dismissViewControllerAnimated:YES completion:^(void) {
        if (self.delegate)
        {
            [self.delegate abortReconnect];
        }
        
    }];

}

- (void)dismissView
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) reloadDeviceList
{
    [self.tableView reloadData];
    [self.tableView setNeedsDisplay];
}

#pragma mark NMXDeviceManagerDelegate and NMXDeviceDelegate methods

- (void) didDiscoverDevice: (NMXDevice *) device
{
    
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        
        if ([[AppExecutive sharedInstance].deviceList containsObject: device])
        {
            [self.tableView reloadData];
            [self.tableView setNeedsDisplay];

            if (device.disconnected)
            {
                device.delegate = self;
                device.serviceDiscoveryRetryCount = 3;  // Retry connection 3 times
                [device connect];
            }
        }
        
    });
}

- (void) reconnectFailed:(NMXDevice *)device
{
    NSString *err = [NSString stringWithFormat: @"Failed to re-establish a connection to %@.  Please reset controller", device.name];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Connection Error"
                                                    message: err
                                                   delegate: nil
                                          cancelButtonTitle: @"OK"
                                          otherButtonTitles: nil];
    [alert show];

}

- (void) didConnect: (NMXDevice *) device
{
    [self reloadDeviceList];
}

- (void) deviceDisconnect: (NSNotification *) notification
{
    NSLog(@"JSDisconnectedDeviceVC got device disconnect   MODAL VIEW = %p", self.presentedViewController);
    [self reloadDeviceList];
}


#pragma mark - Table view data source

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    // Return the number of rows in the section.
    NSArray <NMXDevice *>*dList = [AppExecutive sharedInstance].deviceList;
    
    self.deviceList = [NSMutableArray new];
    
    int count = 0;
    for (NMXDevice *device in dList)
    {
        if (device.disconnected)
        {
            [self.deviceList addObject:device];
            count++;
        }
    }
    
    if (count == 0)
    {
        [self dismissView];
    }
    
    return count;
}

/*
- (void) didDiscoverDevice: (NMXDevice *) device {
    
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        
        [self.tableView reloadData];
        [self.tableView setNeedsDisplay];
    });
}
*/

- (NSString *)getImageForDeviceStatus: (NMXDevice *)device
{
    //    NSString *deviceImage = @"DeviceState_Indeterminate.png";
    NSString *deviceImage = @"DeviceState_Off.png";
    //deviceImage = device.fwVersionUpdateAvailable ? @"DeviceState_Warning.png" : @"DeviceState_Ready.png";
    
    return deviceImage;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DisconnectedDeviceCell" forIndexPath:indexPath];
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.textLabel.backgroundColor = [UIColor clearColor];
    
    
    NMXDevice *device = self.deviceList[indexPath.row];

    if (device)
    {
        cell.textLabel.text = [[AppExecutive sharedInstance] stringWithHandleForDeviceName: device.name];
        
        NSString *deviceImage = [self getImageForDeviceStatus:device];
        cell.imageView.image = [UIImage imageNamed: deviceImage];
        cell.imageView.hidden = NO;
        
    }
    
    return cell;
    
}

#pragma mark - UIAlertViewDelegate Methods

- (void) alertView: (UIAlertView *) alertView clickedButtonAtIndex: (NSInteger) buttonIndex {
    
    NSString *	title	= [alertView buttonTitleAtIndex: buttonIndex];
    
    if ([title isEqualToString: @"OK"])
    {
        [self reconnectOrAbort: nil];
    }
}



@end
