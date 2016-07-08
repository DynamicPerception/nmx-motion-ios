//
//  DeviceSelectionTableViewController.m
//  Joystick
//
//  Created by Dave Koziol on 10/20/14.
//  Copyright (c) 2014 Dynamic Perception. All rights reserved.
//

#import <CocoaLumberjack/CocoaLumberjack.h>
#import "DeviceSelectionTableViewController.h"
#import "AppExecutive.h"
#import "NMXDeviceManager.h"
#import "DeviceTableViewCell.h"
#import "HelpViewController.h"

@interface DeviceSelectionTableViewController ()

@property (nonatomic, strong)	IBOutlet UITableView* tableView;
@property (strong, nonatomic) IBOutlet UIButton *goButton;
@property BOOL confirmingFirmware;
@property BOOL oldFirmwareConfirmed;
@property BOOL multiDeviceConfirmed;

@property NSArray *             deviceList;
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
    self.oldFirmwareConfirmed = NO;
    self.confirmingFirmware = NO;
    self.multiDeviceConfirmed = NO;
    self.activeDevices = [NSMutableArray new];

}


- (void) handleNotificationNotificationHost:(NSNotification *)pNotification {
	
    notificationLbl.text = pNotification.object;
}

- (void) preDevicesStateChange;
{
    [AppExecutive sharedInstance].deviceManager.delegate = self;

    NSArray *cells = [self.tableView visibleCells];
    for (DeviceTableViewCell *cell in cells)
    {
        [cell preDeviceStateChange];
     }
}

- (void) postDevicesStateChange;
{
    NSArray *cells = [self.tableView visibleCells];
    BOOL oneConnected = NO;
    for (DeviceTableViewCell *cell in cells)
    {
        [cell postDeviceStateChange];
        
        if (!cell.device.disconnected)
        {
            oneConnected = YES;
        }
    }
    
    if (oneConnected)
    {
        self.goButton.hidden = NO;
    }
}

- (void) viewWillAppear:(BOOL)animated {
    
	[super viewWillAppear: animated];

    [[AppExecutive sharedInstance].deviceManager setDelegate: self];
    
    [NSTimer scheduledTimerWithTimeInterval:0.500 target:self selector:@selector(timerNameScan) userInfo:nil repeats:NO];
    
    [self.tableView reloadData];
    [self.tableView setNeedsDisplay];

    // Hide separator lines between rows
    // [self.tableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
}

- (void)timerNameScan {
	
     [[AppExecutive sharedInstance].deviceManager startScanning];
}

- (void) viewWillDisappear:(BOOL)animated {
    
	[super viewWillDisappear: animated];
	
    [[AppExecutive sharedInstance].deviceManager stopScanning];
    [[AppExecutive sharedInstance].deviceManager setDelegate: nil];
}

#pragma mark - Table view data source

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {

    return 1;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    // Return the number of rows in the section.
    
    //NSLog(@"device list");
    
    self.deviceList = [[AppExecutive sharedInstance].deviceManager deviceList];
    NSInteger count = [self.deviceList count];
    
    if (0 == count) return 1;
    
    return count;
}

- (void) didDiscoverDevice: (NMXDevice *) device {

    dispatch_async(dispatch_get_main_queue(), ^(void) {
        
        [self.tableView reloadData];
        [self.tableView setNeedsDisplay];
    });
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    BOOL isMessageCell = [self.deviceList count] ? NO : YES;
    
    DeviceTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DeviceCell" forIndexPath:indexPath];
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.textLabel.backgroundColor = [UIColor clearColor];

    if (isMessageCell)
    {
        cell.settingsButton.hidden = YES;
        cell.imageView.hidden = YES;
        cell.textLabel.text = @"No Devices Found";
        //        cell.connectGoButton.hidden = YES;
        cell.connectSwitch.hidden = YES;
    }
    else
    {
        NMXDevice * device = [self.deviceList objectAtIndex: indexPath.row];
        cell.textLabel.text = [[AppExecutive sharedInstance] stringWithHandleForDeviceName: device.name];
        [cell.settingsButton setTitle: @"\u2699" forState: UIControlStateNormal];
        if (device.disconnected)
        {
            cell.settingsButton.hidden = YES;
            //[cell.connectGoButton setTitle:@"Connect" forState:UIControlStateNormal];
            cell.connectSwitch.on = NO;
        }
        //        cell.connectGoButton.hidden = NO;
        cell.connectSwitch.hidden = NO;
        cell.device = device;
        cell.tableView = self;

        NSString *deviceImage = [cell getImageForDeviceStatus: device];
        cell.imageView.image = [UIImage imageNamed: deviceImage];
        cell.imageView.hidden = NO;
    
        NSLog(@"Populating table with device image %@", deviceImage);
    }
    
    return cell;
}

- (void) navigateToMainView
{
    NSString *updatesAvailFor = @"";
    BOOL ready = YES;

#if !TARGET_IPHONE_SIMULATOR

    AppExecutive *appExecutive = [AppExecutive sharedInstance];
    
    NSArray *cells = [self.tableView visibleCells];
    for (DeviceTableViewCell *cell in cells)
    {
        if (cell.connectSwitch.on)
        {
            NMXDevice *device = cell.device;

            if (0 == device.fwVersion)
            {
                ready = NO;
            }
            else if (device.fwVersionUpdateAvailable)
            {
                if (NO == [updatesAvailFor isEqualToString: @""])
                {
                    updatesAvailFor = [updatesAvailFor stringByAppendingString: @", "];
                }
                updatesAvailFor = [updatesAvailFor stringByAppendingString:device.name];
            }
        }

    }
    
    appExecutive.deviceList = [NSArray arrayWithArray:self.activeDevices];
    if (appExecutive.deviceList.count>0)
    {
        appExecutive.device = self.activeDevices[0];
    }
    
#endif

    if (NO == self.oldFirmwareConfirmed && ![updatesAvailFor isEqualToString: @""])
    {
        NSString *updatesString = [NSString stringWithFormat:@"New firmware is available for NMX device(s) %@. Please update the NMX firmware asap.  If you continue some features will be disabled.",
                                   updatesAvailFor];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"New Firmware Version"
                                                        message: updatesString
                                                       delegate: self
                                              cancelButtonTitle: @"Cancel"
                                              otherButtonTitles: @"Continue", nil];
        self.confirmingFirmware = YES;

        [alert show];
    }
    else if (NO == ready)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Device not ready"
                                                        message: @"The device is being initialized, please wait."
                                                       delegate: self
                                              cancelButtonTitle: @"OK"
                                              otherButtonTitles: nil];
        [alert show];
    }
    else
    {
        [self performSegueWithIdentifier:@"showMainView" sender:self];
    }
    
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if(buttonIndex != 0)
    {
        if (self.confirmingFirmware)
        {
            self.oldFirmwareConfirmed = YES;
        }

        self.confirmingFirmware = NO;

        [self navigateToMainView];
    }
    else
    {
        self.confirmingFirmware = NO;

    }
}

- (BOOL) shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    if ([identifier isEqualToString:@"showSettingsView"])
    {
        // The segue is executed automatically as deviced in the storyboard.  However, we need to do some setup fist in the button action handler so perform the seque from there instead
        // See settingsButtonSelected
        return NO;
    }
    
    return YES;
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {

    if ([[segue identifier] isEqualToString:@"showMainView"] || [[segue identifier] isEqualToString: @"simulatorShowMainView"] ||
        [[segue identifier] isEqualToString:@"showSettingsView"])
    {
            //NSLog(@"device name: %@",appExecutive.device.name);
    }
    else if ([[segue identifier] isEqualToString:@"helpDeviceManagement"])
    {
        HelpViewController *msvc = segue.destinationViewController;
        [msvc setScreenInd:6];
    }
}

- (void) didReceiveMemoryWarning {

    [super didReceiveMemoryWarning];
}

- (IBAction)goAction:(id)sender {
    [self navigateToMainView];
}

@end
