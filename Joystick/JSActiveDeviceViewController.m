//
//  JSActiveDeviceViewController.m
//  Joystick
//
//  Created by Mitch Middler on 5/31/16.
//  Copyright © 2016 Dynamic Perception. All rights reserved.
//


#import <CocoaLumberjack/CocoaLumberjack.h>

#import "JSActiveDeviceViewController.h"
#import "JoyButton.h"
#import "AppExecutive.h"
#import "MainViewController.h"

@interface JSActiveDeviceViewController()

@property (nonatomic, strong)				AppExecutive *	appExecutive;

@property (nonatomic, strong)	IBOutlet	UIView *		controlBackground;
@property (nonatomic, strong)	IBOutlet	UIPickerView *	picker;
@property (nonatomic, strong)	IBOutlet	JoyButton *		okButton;

@end


//------------------------------------------------------------------------------

#pragma mark - Implementation


@implementation JSActiveDeviceViewController



#pragma mark - Object Management

- (void) viewDidLoad {
    
    [super viewDidLoad];
    
    self.picker.delegate = self;
    self.picker.dataSource = self;
}

- (void) viewWillAppear: (BOOL) animated {
    
    [super viewWillAppear: animated];
    
    self.appExecutive = [AppExecutive sharedInstance];
    
    [self.view sendSubviewToBack: self.controlBackground];
    
    NMXDevice *device = self.appExecutive.device;
    NSUInteger idx = [self.appExecutive.deviceList indexOfObject: device];
    [self.picker selectRow:idx inComponent:0 animated:NO];
    
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(deviceDisconnect:)
                                                 name: kDeviceDisconnectedNotification
                                               object: nil];
}

- (void) viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear: animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver: self];
}

- (void) deviceDisconnect: (id) object {
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        [self dismissViewControllerAnimated: YES completion: nil];
    });
}




//------------------------------------------------------------------------------

#pragma mark - IBAction Methods


- (IBAction) handleOkButton: (id) sender {
    
    NSInteger selectedDev = [self.picker selectedRowInComponent: 0];
    NMXDevice *newDev = self.appExecutive.deviceList[selectedDev];
    
    if (self.appExecutive.device != newDev)
    {
        [self.appExecutive setActiveDevice: newDev];

        [self dismissViewControllerAnimated: YES completion: nil];
    }
    
}


//------------------------------------------------------------------------------

#pragma mark - UIPickerViewDelegate Protocol Methods


- (CGFloat) pickerView: (UIPickerView *) pickerView rowHeightForComponent: (NSInteger) component {
    
    return 21.0;
}

- (CGFloat) pickerView: (UIPickerView *) pickerView widthForComponent: (NSInteger) component {
    
    return 200.0;
}

- (NSAttributedString *) pickerView: (UIPickerView *) pickerView attributedTitleForRow: (NSInteger) row forComponent: (NSInteger) component {
    
    NSDictionary *	attributes	=  @{ NSForegroundColorAttributeName: [UIColor whiteColor]};
    NSString *		string		= nil;
    
    NSArray<NMXDevice *> *devices = self.appExecutive.deviceList;
    
    switch (component)
    {
        case 0:
            string = [self.appExecutive nameForDeviceID: devices[row].name];
            break;
        default:
            return nil;
            break;
    }
    
    return [[NSAttributedString alloc] initWithString: string attributes: attributes];
}

- (void) pickerView: (UIPickerView *) pickerView didSelectRow: (NSInteger) row inComponent: (NSInteger) component {
    
    NSInteger selectedItem = [self.picker selectedRowInComponent: 0];
    NSArray<NMXDevice *> *devices = self.appExecutive.deviceList;
    NSLog(@"Selected %@", devices[selectedItem].name);
}


//------------------------------------------------------------------------------

#pragma mark - UIPickerViewDataSource Protocol Methods


- (NSInteger) numberOfComponentsInPickerView: (UIPickerView *) pickerView {
    return 1;
}

- (NSInteger) pickerView: (UIPickerView *) pickerView numberOfRowsInComponent: (NSInteger) component {
    return self.appExecutive.deviceList.count;
}


@end
