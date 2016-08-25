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
    
    NSString *reasonString = @"At least one device unexpectedly disconnected.  "
    "You are possibly out of range of communication.  "
    "You may wait until the device is detected or select Abort to return to the start screen.";
    
    self.disconnectedReason.text = reasonString;
    
    [self.reconnectOrAbort setTitle:@"Abort" forState: UIControlStateNormal];
    
}

- (IBAction)reconnectOrAbort:(id)sender {
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


@end
