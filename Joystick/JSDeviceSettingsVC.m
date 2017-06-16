//
//  JSDeviceSettingsVC.m
//  Joystick
//
//  Created by Mitch Middler on 6/8/16.
//  Copyright © 2016 Dynamic Perception. All rights reserved.
//

#import <CocoaLumberjack/CocoaLumberjack.h>
#import "JSDeviceSettingsVC.h"
#import "AppExecutive.h"
#import "NMXDevice.h"


@interface JSDeviceSettingsVC()

@property (nonatomic) AppExecutive *appExecutive;

// Device Information subview

@property (strong, nonatomic) IBOutlet UILabel  *deviceNameLabel;
@property (strong, nonatomic) IBOutlet UILabel  *deviceIDLabel;
@property (strong, nonatomic) IBOutlet UILabel  *firmwareVersionLabel;
@property (strong, nonatomic) IBOutlet UILabel  *voltageLabel;
@property (strong, nonatomic) IBOutlet UIButton *deviceNameButton;
@property (strong, nonatomic) IBOutlet UISwitch *slaveModeSwitch;

@property (weak, nonatomic) IBOutlet UITextField *voltageLowTxt;
@property (weak, nonatomic) IBOutlet UITextField *voltageHighTxt;


@property (nonatomic, strong)		UITextField *	nameTextField;
@property (nonatomic, readonly) 	NSString *		deviceID;
@property (nonatomic, strong)		UIAlertView *	nameAlertView;
@property (nonatomic)               NMXDevice      *device;

@end

@implementation JSDeviceSettingsVC

static const char *SIMULATE_DEVICE	= "SIMULATE_DEVICE";

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    self.firmwareVersionLabel.text = [NSString stringWithFormat: @"%d", self.device.fwVersion];
    
    float voltage = [self.device mainQueryVoltage];
    
    self.voltageLabel.text = [NSString stringWithFormat: @"%.02f", voltage];
    
    self.deviceIDLabel.text = self.deviceID;
    
    self.voltageLowTxt.delegate = self;
    self.voltageHighTxt.delegate = self;
    
    
    self.voltageHighTxt.text = [NSString stringWithFormat:@"%.02f",self.device.settings.voltageHigh];
    self.voltageLowTxt.text = [NSString stringWithFormat:@"%.02f",self.device.settings.voltageLow];
    
    //voltageHighTxt.layer.borderColor=[[UIColor whiteColor]CGColor];
    
    self.voltageHighTxt.layer.cornerRadius=1.0f;
    self.voltageHighTxt.layer.borderColor=[[UIColor whiteColor]CGColor];
    self.voltageHighTxt.layer.borderWidth= 1.0f;
    
    self.voltageLowTxt.layer.cornerRadius=1.0f;
    self.voltageLowTxt.layer.borderColor=[[UIColor whiteColor]CGColor];
    self.voltageLowTxt.layer.borderWidth= 1.0f;

    
}

- (void) viewWillAppear: (BOOL) animated {
    
    [super viewWillAppear: animated];
    
    [self updateDeviceNameField];
    
    [self.slaveModeSwitch setOn: [self.device cameraQuerySlaveMode] animated:NO];
}

- (void) viewDidAppear: (BOOL) animated {
    
    [super viewDidAppear: animated];
    
    self.deviceNameButton.layer.borderWidth = 1.0;
    self.deviceNameButton.layer.borderColor = [[UIColor whiteColor] CGColor];
}

- (void) updateDeviceNameField {
    
    self.deviceNameLabel.text = [self.appExecutive nameForDeviceID: self.deviceID];
}

#pragma mark - Private Property Methods


- (AppExecutive *) appExecutive {
    
    if (_appExecutive == nil)
    {
        _appExecutive = [AppExecutive sharedInstance];
    }
    
    return _appExecutive;
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
        return [self.appExecutive connectedDeviceList][self.itemIndex].name;
    }
}

- (NMXDevice *) device
{
    return [self.appExecutive connectedDeviceList][self.itemIndex];
}

//------------------------------------------------------------------------------

#pragma mark - IBAction Methods

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

- (IBAction)setSlaveMode:(UISwitch *)sender {
    [self.device cameraSetSlaveMode: [sender isOn]];
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

- (BOOL) textFieldShouldReturn:(UITextField*)textField {
    
    self.device.settings.voltageHigh = [self.voltageHighTxt.text floatValue];
    self.device.settings.voltageLow = [self.voltageLowTxt.text floatValue];
    
    
    if (self.device.settings.voltageHigh <= self.device.settings.voltage)
    {
        self.device.settings.voltageHigh = self.device.settings.voltage;
        self.voltageHighTxt.text = [NSString stringWithFormat:@"%.02f", self.device.settings.voltageHigh];
    }
    
    if (self.device.settings.voltageLow >= self.device.settings.voltage)
    {
        self.device.settings.voltageLow = self.device.settings.voltage;
        self.voltageLowTxt.text = [NSString stringWithFormat:@"%.02f", self.device.settings.voltageLow];
    }
    
    [textField resignFirstResponder];
    
    
    return YES;
}


@end
