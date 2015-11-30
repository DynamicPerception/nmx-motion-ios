//
//  AboutViewController.m
//  Joystick
//
//  Created by Dave Koziol on 1/5/15.
//  Copyright (c) 2015 Dynamic Perception. All rights reserved.
//

#import <CocoaLumberjack/CocoaLumberjack.h>

#import "DeviceSettingsViewController.h"
#import "AppExecutive.h"
#import "JoyButton.h"
#import "NMXDevice.h"

@interface DeviceSettingsViewController ()

#pragma mark Private Property Synthesis

@property (weak, nonatomic, readonly)	AppExecutive *	appExecutive;

// Device Information subview

@property (weak, nonatomic) IBOutlet UILabel *		firmwareVersionLabel;
@property (weak, nonatomic) IBOutlet UILabel *		voltageLabel;
@property (weak, nonatomic) IBOutlet UILabel *		deviceIDLabel;
@property (weak, nonatomic) IBOutlet UILabel *		deviceNameLabel;
@property (weak, nonatomic) IBOutlet UIButton *		deviceNameButton;

// Joystick Settings subview

@property (weak, nonatomic)	IBOutlet UILabel *		sensitivityValue;
@property (weak, nonatomic)	IBOutlet UISlider *		sensitivitySlider;
@property (weak, nonatomic)	IBOutlet UISwitch *		dominantAxisSwitch;

// Top container view

@property (weak, nonatomic) IBOutlet JoyButton *	emailLogFileButton;
@property (weak, nonatomic) IBOutlet UILabel *		appVersionLabel;

@property (nonatomic, readonly) 	NSString *		deviceID;
@property (nonatomic, strong)		UIAlertView *	nameAlertView;
@property (nonatomic, strong)		UITextField *	nameTextField;

@property (nonatomic, readonly)		NSString *		emailAddress;

@end

@implementation DeviceSettingsViewController


static const char *SIMULATE_DEVICE	= "SIMULATE_DEVICE";
static const char *EMAIL_ADDRESS	= "EMAIL_ADDRESS";


#pragma mark - Private Property Synthesis

@synthesize appExecutive;

@synthesize deviceID;
@synthesize nameAlertView;
@synthesize nameTextField;

@synthesize sensitivityValue;
@synthesize sensitivitySlider;
@synthesize dominantAxisSwitch;

@synthesize voltageHighTxt,voltageLowTxt;


//------------------------------------------------------------------------------

#pragma mark - Private Property Methods


- (AppExecutive *) appExecutive {

	if (appExecutive == nil)
	{
		appExecutive = [AppExecutive sharedInstance];
	}

	return appExecutive;
}

- (NSString *) deviceID {

	if (getenv(SIMULATE_DEVICE))
	{
		const char *	string	= getenv(SIMULATE_DEVICE);
		NSString *		device	= [NSString stringWithUTF8String: string];

		return device;
	}
	else
	{
		return self.appExecutive.device.name;
	}
}

- (NSString *) emailAddress {

	if (getenv(EMAIL_ADDRESS))
	{
		const char *	envvar = getenv(EMAIL_ADDRESS);
		NSString *		string = [NSString stringWithUTF8String: envvar];

		return string;
	}

	return @"support@dynamicperception.com";
}


//------------------------------------------------------------------------------

#pragma mark - Object Management


- (void) viewDidLoad {

	[super viewDidLoad];

	self.appVersionLabel.text = [[NSBundle mainBundle] objectForInfoDictionaryKey: @"CFBundleShortVersionString"];

	UInt16 fwVersion = [self.appExecutive.device mainQueryFirmwareVersion];

	self.firmwareVersionLabel.text = [NSString stringWithFormat: @"%d", fwVersion];
    
    float voltage = [self.appExecutive.device mainQueryVoltage];
    
    self.voltageLabel.text = [NSString stringWithFormat: @"%.02f", voltage];

	self.deviceIDLabel.text = self.deviceID;
    
    voltageLowTxt.delegate = self;
    voltageHighTxt.delegate = self;
    
    voltageHighTxt.text = [NSString stringWithFormat:@"%.02f",appExecutive.voltageHigh];
    voltageLowTxt.text = [NSString stringWithFormat:@"%.02f",appExecutive.voltageLow];
    
    //voltageHighTxt.layer.borderColor=[[UIColor whiteColor]CGColor];
    
    voltageHighTxt.layer.cornerRadius=1.0f;
    voltageHighTxt.layer.borderColor=[[UIColor whiteColor]CGColor];
    voltageHighTxt.layer.borderWidth= 1.0f;
    
    voltageLowTxt.layer.cornerRadius=1.0f;
    voltageLowTxt.layer.borderColor=[[UIColor whiteColor]CGColor];
    voltageLowTxt.layer.borderWidth= 1.0f;
}

- (void) viewWillAppear: (BOOL) animated {

	[super viewWillAppear: animated];

	[[NSNotificationCenter defaultCenter] addObserver: self
											 selector: @selector(deviceDisconnect:)
												 name: kDeviceDisconnectedNotification
											   object: nil];

	[self updateDeviceNameField];

	self.dominantAxisSwitch.on		= [self.appExecutive.lockAxisNumber boolValue];
	self.sensitivitySlider.value	= [self.appExecutive.sensitivityNumber floatValue];
	self.sensitivityValue.text		= [NSString stringWithFormat: @"%3.0f%%", self.sensitivitySlider.value];
}

- (void) updateDeviceNameField {

	self.deviceNameLabel.text = [self.appExecutive nameForDeviceID: self.deviceID];
}

- (void) viewDidAppear: (BOOL) animated {

	[super viewDidAppear: animated];

	self.deviceNameButton.layer.borderWidth = 1.0;
	self.deviceNameButton.layer.borderColor = [[UIColor whiteColor] CGColor];
}

- (void) viewWillDisappear: (BOOL) animated {

	[super viewWillDisappear: animated];

	[[NSNotificationCenter defaultCenter] removeObserver: self];
}

- (void) deviceDisconnect: (id) object {

    NSLog(@"deviceDisconnect");
	[self dismissViewControllerAnimated: YES completion: nil];
}


//------------------------------------------------------------------------------

#pragma mark - IBAction Methods


- (IBAction) handleSensitivitySlider: (UISlider *) sender {

	DDLogDebug(@"Sensitivity Slider: %g", sender.value);

	self.sensitivityValue.text = [NSString stringWithFormat: @"%3.0f%%", sender.value];
	self.appExecutive.sensitivityNumber = [NSNumber numberWithFloat: sender.value];
}

- (IBAction) handleReleaseSensitivitySlider: (UISlider *) sender {

	if (sender.value < 10.0)
	{
		[sender setValue: 10.0 animated: YES];
	}

	DDLogDebug(@"Release Sensitivity Slider: %g", sender.value);

	self.sensitivityValue.text = [NSString stringWithFormat: @"%3.0f%%", sender.value];
	self.appExecutive.sensitivityNumber = [NSNumber numberWithFloat: sender.value];
}

- (IBAction) handleDominantAxisSwitch: (UISwitch *) sender {

	NSString *		value		= (sender.on ? @"ON" : @"OFF");

	DDLogDebug(@"Dominant Axis Switch: %@", value);

	self.appExecutive.lockAxisNumber = [NSNumber numberWithBool: sender.on];
}

- (IBAction) handleDeviceNameButton: (UIButton *) sender {

	DDLogDebug(@"handleDeviceNameButton");

	self.nameAlertView = [[UIAlertView alloc] initWithTitle: @"User Device Name"
												message: @"Enter friendly device name"
											   delegate: self
									  cancelButtonTitle: @"Cancel"
									  otherButtonTitles: @"OK", nil];

	self.nameAlertView.alertViewStyle = UIAlertViewStylePlainTextInput;
	self.nameTextField = [self.nameAlertView textFieldAtIndex: 0];
	self.nameTextField.delegate = self;

	self.nameTextField.text = [self.appExecutive nameForDeviceID: self.deviceID];

	[self.nameAlertView show];
}

- (IBAction) handleOk: (id) sender {
    
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"updateBattery"
     object:nil];

	[self dismissViewControllerAnimated: YES completion: nil];
}

- (IBAction) handleEmailLogFileButton: (UIButton *) sender {

	if ([MFMailComposeViewController canSendMail])
	{
		NSMutableData *errorLogData = [NSMutableData data];

		// accumulate data for all the log files

		for (NSData *errorLogFileData in [self logFileData])
		{
			[errorLogData appendData: errorLogFileData];
		}

		// compose email with log file data

		MFMailComposeViewController *mailViewController	= [[MFMailComposeViewController alloc] init];
		mailViewController.mailComposeDelegate = self;

		[mailViewController setSubject: @"NMX Motion Log File"];
		[mailViewController setToRecipients: [NSArray arrayWithObject: self.emailAddress]];
		[mailViewController addAttachmentData: errorLogData mimeType: @"text/plain" fileName: @"NMX-Motion-Log-File.txt"];

		[self presentViewController: mailViewController animated: YES completion: NULL];
	}
	else
	{
		NSString *message = @"Sorry, the log file cannot be sent at this time.";
		[[[UIAlertView alloc] initWithTitle: nil message: message delegate: nil cancelButtonTitle: @"OK" otherButtonTitles: nil] show];
	}

	return;
}

- (NSMutableArray *) logFileData {

	DDFileLogger *		logger		= [self fileLogger];
	NSUInteger			maxFiles	= 10;
	NSMutableArray *	logData		= [NSMutableArray array];
	NSArray *			sortedInfo	= [logger.logFileManager sortedLogFileInfos];

	for (int index = 0; index < MIN(sortedInfo.count, maxFiles); index++)
	{
		DDLogFileInfo *	logFileInfo	= [sortedInfo objectAtIndex: index];
		NSData *		fileData	= [NSData dataWithContentsOfFile: logFileInfo.filePath];

		[logData addObject: fileData];
	}

	return logData;
}

- (DDFileLogger *) fileLogger {

	for (NSObject *object in [DDLog allLoggers])
	{
		if ([object isKindOfClass: [DDFileLogger class]])
			 return (DDFileLogger *) object;
	}

	return nil;
}


//------------------------------------------------------------------------------

#pragma mark - MFMailComposeViewControllerDelegate Methods


- (void) mailComposeController: (MFMailComposeViewController *) controller didFinishWithResult: (MFMailComposeResult) result error: (NSError *) error {

	[controller dismissViewControllerAnimated: YES completion: NULL];

	switch (result)
	{
		case MFMailComposeResultCancelled:
			[self mailAlertWithMessage: @"Mail was canceled."];
			break;

		case MFMailComposeResultSaved:
			[self mailAlertWithMessage: @"Mail was saved."];
			break;

		case MFMailComposeResultSent:
			[self mailAlertWithMessage: @"Mail was sent."];
			break;

		case MFMailComposeResultFailed:
			[self mailAlertWithError: error];
			break;

		default: break;
	}
}

- (void) mailAlertWithMessage: (NSString *) message {

	UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Mail Status"
													message: message
												   delegate: nil
										  cancelButtonTitle: @"OK"
										  otherButtonTitles: nil];
	[alert show];
}

- (void) mailAlertWithError: (NSError *) error {

	NSString *message = error.localizedDescription;

	UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Mail Error"
													message: message
												   delegate: nil
										  cancelButtonTitle: @"OK"
										  otherButtonTitles: nil];
	[alert show];
}


//------------------------------------------------------------------------------

#pragma mark - UIAlertViewDelegate Methods


- (void) alertView: (UIAlertView *) alertView clickedButtonAtIndex: (NSInteger) buttonIndex {

	if (alertView == self.nameAlertView)
	{
		NSString *title = [alertView buttonTitleAtIndex: buttonIndex];

		if ([title isEqualToString: @"OK"])
		{
			UITextField *	valueField	= [alertView textFieldAtIndex: 0];
			NSString *		valueText	= valueField.text;

			[self.appExecutive setHandle: valueText forDeviceName: self.deviceID];
		}

		self.nameAlertView = nil;
		self.nameTextField = nil;

		[self updateDeviceNameField];
	}
}

//------------------------------------------------------------------------------

#pragma mark - UITextFieldDelegate Protocol Methods

- (BOOL) textField: (UITextField *) textField shouldChangeCharactersInRange: (NSRange) range replacementString: (NSString *) string {

    if (!string.length)
        return YES;
    
    if ([textField.restorationIdentifier isEqualToString:@"low"] || [textField.restorationIdentifier isEqualToString:@"high"])
    {
        NSString *newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
        NSString *expression = @"^([0-9]+)?(\\.([0-9]{1,2})?)?$";
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:expression
                                                                               options:NSRegularExpressionCaseInsensitive
                                                                                 error:nil];
        NSUInteger numberOfMatches = [regex numberOfMatchesInString:newString
                                                            options:0
                                                              range:NSMakeRange(0, [newString length])];
        if (numberOfMatches == 0)
            return NO;
    }
    
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField*)textField {
    
    self.appExecutive.voltageHigh = [voltageHighTxt.text floatValue];
    
    
    self.appExecutive.voltageLow = [voltageLowTxt.text floatValue];
    
    
    if (self.appExecutive.voltageHigh <= self.appExecutive.voltage)
    {
        self.appExecutive.voltageHigh = self.appExecutive.voltage;
        voltageHighTxt.text = [NSString stringWithFormat:@"%.02f", self.appExecutive.voltageHigh];
    }
    
    if (self.appExecutive.voltageLow >= self.appExecutive.voltage)
    {
        self.appExecutive.voltageLow = self.appExecutive.voltage;
        voltageLowTxt.text = [NSString stringWithFormat:@"%.02f", self.appExecutive.voltageLow];
    }
    
    [textField resignFirstResponder];
    
    [self.appExecutive.defaults setObject: [NSNumber numberWithFloat:self.appExecutive.voltageLow] forKey: @"voltageLow"];
    [self.appExecutive.defaults setObject: [NSNumber numberWithFloat:self.appExecutive.voltageHigh] forKey: @"voltageHigh"];
    
    [self.appExecutive.defaults synchronize];
    
    return YES;
}

@end
