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
@property BOOL confirmingStopPrograms;
@property BOOL confirmingConnectMissing;
@property BOOL oldFirmwareConfirmed;
@property BOOL multiDeviceConfirmed;
@property int  numMissing;
@property int  numReportedRunning;
@property BOOL showMessageCell;

@property NSArray *deviceList;
@property NSArray *tempDevList;
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
    self.confirmingStopPrograms = NO;
    self.confirmingConnectMissing = NO;

    self.activeDevices = [NSMutableArray new];

}

- (void) handleNotificationNotificationHost:(NSNotification *)pNotification {
	
    notificationLbl.text = pNotification.object;
}

- (void) setGoButtonVisibility
{
    self.goButton.hidden = YES;
    
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

- (void) preDevicesStateChange;
{
    [AppExecutive sharedInstance].deviceManager.delegate = self;

    NSArray *cells = [self.tableView visibleCells];
    for (DeviceTableViewCell *cell in cells)
    {
        [cell preDeviceStateChange];
     }
}

- (void) postDevicesStateChange
{
    [self setGoButtonVisibility];
    
    if (self.confirmingConnectMissing)
    {
        self.numMissing--;
        if (self.numMissing <= 0)
        {
            self.confirmingConnectMissing = NO;
            self.numMissing = 0;
            [self navigateToMainView];
        }
    }

}

- (void) viewWillAppear:(BOOL)animated {
    
	[super viewWillAppear: animated];

    if (self.tempDevList)
    {
        self.tempDevList = [NSMutableArray arrayWithArray:self.tempDevList];
    }
    else
    {
        self.activeDevices = [NSMutableArray new];
    }
    
    [[AppExecutive sharedInstance].deviceManager setDelegate: self];
    
    [NSTimer scheduledTimerWithTimeInterval:0.500 target:self selector:@selector(timerNameScan) userInfo:nil repeats:NO];
    
    [self setGoButtonVisibility];

    [self.tableView reloadData];
    [self.tableView setNeedsDisplay];

    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(deviceDisconnect:)
                                                 name: kDeviceDisconnectedNotification
                                               object: nil];

    
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
    
    [[NSNotificationCenter defaultCenter] removeObserver: self];

}

#pragma mark - Table view data source

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {

    return 1;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    // Return the number of rows in the section.
    
    self.showMessageCell = NO;
    
    //NSLog(@"device list");
    self.deviceList = [[AppExecutive sharedInstance].deviceManager deviceList];
    NSInteger count = self.deviceList.count;
    
    if (0 == count)
    {
        self.showMessageCell = YES;
        return 1;
    }
    
    return count;
}

- (void) didDiscoverDevice: (NMXDevice *) device {

    dispatch_async(dispatch_get_main_queue(), ^(void) {
        
        [self.tableView reloadData];
        [self.tableView setNeedsDisplay];
        
    });
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    BOOL isMessageCell = self.showMessageCell;
    
    DeviceTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DeviceCell" forIndexPath:indexPath];
    cell.runStatus = NMXRunStatusUnknown;
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.textLabel.backgroundColor = [UIColor clearColor];

    if (isMessageCell)
    {
        cell.settingsButton.hidden = YES;
        cell.imageView.hidden = YES;
        cell.textLabel.text = @"No Devices Found";
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

        cell.connectSwitch.hidden = NO;
        cell.device = device;
        cell.tableView = self;

        if (cell.device.disconnected == NO)
        {
            [cell determineRunStatus: device];
        }
        
        NSString *deviceImage = [cell getImageForDeviceStatus:device];
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

    int numRunning = 0;
    int numInList = 0;
    int numConnected = 0;
    self.numReportedRunning = 0;
    
    NSArray *cells = [self.tableView visibleCells];
    for (DeviceTableViewCell *cell in cells)
    {
        numInList++;
        
        if (cell.connectSwitch.on)
        {
            if (cell.runStatus & NMXRunStatusRunning)
            {
                numRunning++;
                self.numReportedRunning = MAX(self.numReportedRunning, cell.numRunning);
            }

            numConnected++;
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
    
    BOOL okToProceed = YES;
    NSString *title = @"";
    NSString *msg = @"";
    NSString *altButton = @"";
    
    if (self.numReportedRunning > 0)
    {
        if (self.numReportedRunning != numConnected)
        {
            okToProceed = NO;
            
            // We don't see all of the devices that should be running
            if (self.numReportedRunning > numInList)
            {
                title = @"Device not available";
                msg = @"Not all running devices are visible.\nDo you wish to stop the running program?";
                altButton = @"Stop Program";
                self.confirmingStopPrograms = YES;
            }
            else if (self.numReportedRunning < numConnected)
            {
                title = @"Error";
                msg = @"You have connected to more devices than are running a program.\nDo you wish to stop the running program?";
                altButton = @"Stop Program";
                self.confirmingStopPrograms = YES;
            }
            // We aren't connected to all of the devices that should be running
            else
            {
                title = @"Error";
                msg = @"Not all running devices are connected.\nDo you wish to connect to them now?";
                altButton = @"Connect";
                self.confirmingConnectMissing = YES;
                self.numMissing = self.numReportedRunning-numConnected;
            }
            
        }
        else if (self.numReportedRunning != numRunning)
        {
            title = @"Error";
            msg = @"Device run states do not match.\nDo you wish to stop any running programs now?";
            altButton = @"Stop Programs";
            okToProceed = NO;
            self.confirmingStopPrograms = YES;
        }
    }
    
    if (NO == okToProceed)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle: title
                                                        message: msg
                                                       delegate: self
                                              cancelButtonTitle: @"Cancel"
                                              otherButtonTitles: altButton, nil];
        [alert show];
        return;
    }
    
#endif

    if (NO == ready)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Device not ready"
                                                        message: @"The device is being initialized, please wait."
                                                       delegate: self
                                              cancelButtonTitle: @"OK"
                                              otherButtonTitles: nil];
        [alert show];
    }
    else if (NO == self.oldFirmwareConfirmed && ![updatesAvailFor isEqualToString: @""])
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
    else
    {
        [self performSegueWithIdentifier:@"showMainView" sender:self];
    }
    
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    AppExecutive *ae = [AppExecutive sharedInstance];
    
    if(buttonIndex != 0)
    {
        if (self.confirmingFirmware)
        {
            self.oldFirmwareConfirmed = YES;
            self.confirmingFirmware = NO;
            
            [self navigateToMainView];

        }
        else if (self.confirmingStopPrograms)
        {
            ae.deviceList = [NSArray arrayWithArray:self.activeDevices];
            if (ae.deviceList.count>0)
            {
                [ae setActiveDevice: ae.deviceList[0]];
            }

            [ae stopProgram];
            [self.tableView reloadData];
            
            self.confirmingStopPrograms = NO;
            [self navigateToMainView];
        }
        else if (self.confirmingConnectMissing)
        {
            int numToConnect = self.numMissing;
            NSArray *cells = [self.tableView visibleCells];
            for (DeviceTableViewCell *cell in cells)
            {
                if ([self.activeDevices containsObject: cell.device] == NO)
                {
                    [cell connect];
                    numToConnect--;
                }
                if (numToConnect == 0) break;
            }
            self.numMissing = MAX(0, self.numMissing-numToConnect);   // numMissing is now the number that we attempted to connect
        }

    }

    self.confirmingFirmware = NO;
    self.confirmingStopPrograms = NO;

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

    if ([[segue identifier] isEqualToString:@"showMainView"])
    {
        AppExecutive *ae = [AppExecutive sharedInstance];
        
        ae.deviceList = [NSArray arrayWithArray:self.activeDevices];
        if (ae.deviceList.count>0)
        {
            [ae setActiveDevice: ae.deviceList[0]];
        }
    }
    else if ([[segue identifier] isEqualToString:@"helpDeviceManagement"])
    {
        HelpViewController *msvc = segue.destinationViewController;
        [msvc setScreenInd:6];
    }
    else if ([[segue identifier] isEqualToString:@"showSettingsView"])
    {
        self.tempDevList = [NSArray arrayWithArray:self.activeDevices];
    }

}

- (void) didReceiveMemoryWarning {

    [super didReceiveMemoryWarning];
}

- (IBAction)goAction:(id)sender {
    [self navigateToMainView];
}

- (void) refreshDeviceList
{
    [self.tableView reloadData];
    [self.tableView setNeedsDisplay];
    
    [self setGoButtonVisibility];
}

// Handle disconnect notification

- (void) deviceDisconnect: (NSNotification *) notification
{
    dispatch_async(dispatch_get_main_queue(), ^{

        [self refreshDeviceList];

    });
}


@end
