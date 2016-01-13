//
//  DeviceSelectionTableViewController.m
//  Joystick
//
//  Created by Dave Koziol on 10/20/14.
//  Copyright (c) 2014 Dynamic Perception. All rights reserved.
//

#import "DeviceSelectionTableViewController.h"
#import "AppExecutive.h"
#import "NMXDeviceManager.h"

@interface DeviceSelectionTableViewController ()

@property (nonatomic, strong)	IBOutlet UITableView* tableView;
@property (weak, nonatomic)     IBOutlet UISwitch *legacyDeviceSwitch;

@property NSArray *             deviceList;
@end

@implementation DeviceTableViewCell

- (IBAction) settingsButtonSelected: (id) sender
{
    AppExecutive * appExecutive = [AppExecutive sharedInstance];
    appExecutive.device = self.device;
}

- (IBAction) connectButtonSelected: (id) sender
{
    UIButton *button = (UIButton *)sender;
    [button setTitle:@"Go" forState:UIControlStateNormal];
    self.settingsButton.enabled = YES;
}

@end

@implementation DeviceSelectionTableViewController

@synthesize notificationLbl,shareBtn;

- (void) viewDidLoad {
    
//    UIImage *ig = [UIImage imageNamed: @"Instagram.png"];
//    
//    UIImageView *igv = [[UIImageView alloc] initWithFrame:CGRectMake(3, 3, 25, 25)];
//    
//    igv.image = ig;
//    
//    [shareBtn addSubview:igv];
//    
//    UIImage *ig2 = [UIImage imageNamed: @"facebook.png"];
//    
//    UIImageView *igv2 = [[UIImageView alloc] initWithFrame:CGRectMake(31, 3, 25, 25)];
//    
//    igv2.image = ig2;
//    
//    [shareBtn addSubview:igv2];
    
//    float val1 = 26785;
//    
//    val1 = 1000.0 * floor((val1/1000.0)+0.5);
//    
//    NSLog(@"val1: %f",val1);
    
    
    
    
    
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    [AppExecutive sharedInstance].deviceManager = [[NMXDeviceManager alloc] init];
    
    [[AppExecutive sharedInstance].device motorSet: 2 Microstep: 16];
    [[AppExecutive sharedInstance].device motorSet: 3 Microstep: 16];
    
    [NSTimer scheduledTimerWithTimeInterval:1.000 target:self selector:@selector(timerName) userInfo:nil repeats:NO];
    
#if TARGET_IPHONE_SIMULATOR
    [self performSegueWithIdentifier: @"showMainView" sender: self];
#else
	if (getenv("SIMULATE_DEVICE"))
	{
		[self performSegueWithIdentifier: @"showMainView" sender: self];
	}
#endif
    
    notificationLbl.text = @"Waiting for notification";
    notificationLbl.hidden = YES;
}

- (void) handleNotificationNotificationHost:(NSNotification *)pNotification {
	
    notificationLbl.text = pNotification.object;
}

- (void) timerName {
	
    if ([[[AppExecutive sharedInstance].defaults stringForKey: @"didDisconnect"] isEqualToString:@"yes"]) {
        
        //NSLog(@"didDisconnect stored");
        
        //NSString *device = [[AppExecutive sharedInstance].defaults stringForKey: @"deviceName"];
        
//        for (int i = 0; i < self.deviceList.count; i++)
//        {
//            NMXDevice *d = [self.deviceList objectAtIndex: i];
//            
//            NSLog(@"device name: %@",d.name);
//            
//            if ([d.name isEqualToString:device])
//            {
//                NSLog(@"this the 1");
//                [AppExecutive sharedInstance].device = d;
//                [self performSegueWithIdentifier:@"DeviceSelectionToReviewStatus" sender:self];
//                return;
//            }
//        }
    }
}

- (void) viewWillAppear:(BOOL)animated {
    
	[super viewWillAppear: animated];

    [[AppExecutive sharedInstance].deviceManager setDelegate: self];
    
    [NSTimer scheduledTimerWithTimeInterval:0.500 target:self selector:@selector(timerNameScan) userInfo:nil repeats:NO];
   
}

- (void)timerNameScan {
	
     [[AppExecutive sharedInstance].deviceManager startScanning: false];
}

- (void) viewWillDisappear:(BOOL)animated {
    
	[super viewWillDisappear: animated];
	
    [[AppExecutive sharedInstance].deviceManager stopScanning];
    [[AppExecutive sharedInstance].deviceManager setDelegate: nil];
}

- (IBAction) legacyDeviceChanged: (UISwitch *) sender {

    [[AppExecutive sharedInstance].deviceManager stopScanning];
    [self.tableView reloadData];
    [[AppExecutive sharedInstance].deviceManager startScanning: sender.on];
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

#pragma mark - Table view data source

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {

    return 1;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    // Return the number of rows in the section.
    
    //NSLog(@"device list");
    
    self.deviceList = [[AppExecutive sharedInstance].deviceManager deviceList];
    return [self.deviceList count];
}

- (void) didDiscoverDevice: (NMXDevice *) device {

    dispatch_async(dispatch_get_main_queue(), ^(void) {
        
        [self.tableView reloadData];
        [self.tableView setNeedsDisplay];
    });
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    DeviceTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DeviceCell" forIndexPath:indexPath];

    NMXDevice * device = [self.deviceList objectAtIndex: indexPath.row];
    cell.textLabel.text = [[AppExecutive sharedInstance] stringWithHandleForDeviceName: device.name];
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.textLabel.backgroundColor = [UIColor clearColor];
    [cell.settingsButton setTitle: @"\u2699" forState: UIControlStateNormal];
    cell.device = device;

    NSString *deviceImage = [self getImageForDeviceStatus: device];
    cell.imageView.image = [UIImage imageNamed: deviceImage];
    
    NSLog(@"Populating table with device image %@", deviceImage);
    
    return cell;
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    if ([identifier isEqualToString:@"showMainView"] || [identifier isEqualToString: @"simulatorShowMainView"])
    {
#if !TARGET_IPHONE_SIMULATOR
        
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        NMXDevice *device = [self.deviceList objectAtIndex: indexPath.row];
        
        if (device.fwVersionUpdateAvailable)
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"New Firmware Version"
                                                            message: @"New firmware is available for the NMX, please update the NMX firmware asap.  If you continue some features will be disabled."
                                                           delegate: self
                                                  cancelButtonTitle: @"Cancel"
                                                  otherButtonTitles: @"Continue", nil];
            [alert show];
            return NO;
        }
        else if (0 == device.fwVersion)
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Device not ready"
                                                            message: @"The device is being initialized, please wait."
                                                           delegate: self
                                                  cancelButtonTitle: @"OK"
                                                  otherButtonTitles: nil];
            [alert show];
            return NO;
        }
#endif
    }
    
    return YES;
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 0)
    {
        [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
    }
    else
    {
        [self performSegueWithIdentifier:@"showMainView" sender:self];
    }
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {

    if ([[segue identifier] isEqualToString:@"showMainView"] || [[segue identifier] isEqualToString: @"simulatorShowMainView"])
    {
        #if !TARGET_IPHONE_SIMULATOR
        
            AppExecutive * appExecutive = [AppExecutive sharedInstance];
            NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
            appExecutive.device = [self.deviceList objectAtIndex: indexPath.row];
        
            //NSLog(@"device name: %@",appExecutive.device.name);
        
        #endif
    }
}

- (void) didReceiveMemoryWarning {

    [super didReceiveMemoryWarning];
}

- (void) didDisconnectDevice: (CBPeripheral *) peripheral
{
    // Called after the device has been queried for the firmware version number and disconnected

    NSLog(@"Device disconnected from initFirmware");
    
    dispatch_async(dispatch_get_main_queue(), ^(void) {

    
        NSArray *cells = [self.tableView visibleCells];
        for (UITableViewCell *cell in cells)
        {
            if ([cell.textLabel.text containsString: peripheral.name])
            {
                NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
                NMXDevice *device = [self.deviceList objectAtIndex: indexPath.row];

                NSString *deviceImage = [self getImageForDeviceStatus: device];
                cell.imageView.image = [UIImage imageNamed: deviceImage];
                
                NSLog(@"Updating image after firmware check %@", deviceImage);
            }
        }
    });
        
}


@end
