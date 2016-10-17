//
//  FrameRateViewController.m
//  Joystick
//
//  Created by Mark Zykin on 12/11/14.
//  Copyright (c) 2014 Dynamic Perception. All rights reserved.
//

#import <CocoaLumberjack/CocoaLumberjack.h>

#import "FrameRateViewController.h"
#import "JoyButton.h"
#import "NMXDevice.h"


//------------------------------------------------------------------------------

#pragma mark - Private Interface


@interface FrameRateViewController ()

@property (nonatomic, strong)	IBOutlet	UIView *		controlBackground;
@property (nonatomic, strong)	IBOutlet	UIPickerView *	picker;
@property (nonatomic, strong)	IBOutlet	JoyButton *		okButton;

@end


//------------------------------------------------------------------------------

#pragma mark - Implementation


@implementation FrameRateViewController

#pragma mark Static Variables

NSArray	static	*frameRateNumbers = nil;
NSArray static	*frameRateStrings = nil;


#pragma mark Public Propery Synthesis

@synthesize delegate;
@synthesize frameRate;


#pragma mark Private Propery Synthesis

@synthesize controlBackground;
@synthesize picker;
@synthesize okButton;


#pragma mark Public Propery Methods


- (void) setExposure: (NSNumber *) number {

	NSInteger	index	= [frameRateNumbers indexOfObject: number];
	NSInteger	row		= (index == NSNotFound ? 0 : index);

	frameRate = [frameRateNumbers objectAtIndex: row];
}


#pragma mark Private Propery Methods


//------------------------------------------------------------------------------

#pragma mark - Class Management


+ (void) initialize {

	frameRateNumbers = [NSArray arrayWithObjects:
						[NSNumber numberWithInteger: 24],
						[NSNumber numberWithInteger: 25],
						[NSNumber numberWithInteger: 30],
						nil];

	frameRateStrings = [NSArray arrayWithObjects: @"24", @"25", @"30", nil];
}


//------------------------------------------------------------------------------

#pragma mark - Class Query


//------------------------------------------------------------------------------

#pragma mark - Object Management


- (void) viewDidLoad {

	[super viewDidLoad];

	self.picker.delegate = self;
	self.picker.dataSource = self;
}

- (void) viewWillAppear: (BOOL) animated {

	[super viewWillAppear: animated];
	[self.view sendSubviewToBack: self.controlBackground];

	NSInteger row = [frameRateNumbers indexOfObject: self.frameRate];

	[self.picker selectRow: row inComponent: 0 animated: NO];

    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(deviceDisconnect:)
                                                 name: kDeviceDisconnectedNotification
                                               object: nil];
}

- (void) viewWillDisappear:(BOOL)animated {

    [super viewWillDisappear: animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver: self];
}

- (void) deviceDisconnect: (NSNotification *) notification
{
    //NMXDevice *device = notification.object;
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        [self dismissViewControllerAnimated: YES completion: nil];
    });
}


- (void) didReceiveMemoryWarning {

	[super didReceiveMemoryWarning];	
}


//------------------------------------------------------------------------------

#pragma mark - IBAction Methods


- (IBAction) handleOkButton: (id) sender {

	DDLogDebug(@"Dismiss Frame Rate Picker Button");

	NSInteger	index	= [self.picker selectedRowInComponent: 0];
	NSNumber *	number	= [frameRateNumbers objectAtIndex: index];

	[self.delegate updateFrameRateNumber: number];
	[self dismissViewControllerAnimated: YES completion: nil];
}


//------------------------------------------------------------------------------

#pragma mark - UIPickerViewDelegate Protocol Methods


- (CGFloat) pickerView: (UIPickerView *) pickerView rowHeightForComponent: (NSInteger) component {

	return 21.0;
}

- (CGFloat) pickerView: (UIPickerView *) pickerView widthForComponent: (NSInteger) component {

	return 70.0;
}

- (NSAttributedString *) pickerView: (UIPickerView *) pickerView attributedTitleForRow: (NSInteger) row forComponent: (NSInteger) component {

	NSDictionary *	attributes	=  @{ NSForegroundColorAttributeName: [UIColor whiteColor]};
	NSString *		string		= [frameRateStrings objectAtIndex: row];

	return [[NSAttributedString alloc] initWithString: string attributes: attributes];
}

- (void) pickerView: (UIPickerView *) pickerView didSelectRow: (NSInteger) row inComponent: (NSInteger) component {

	return;
}


//------------------------------------------------------------------------------

#pragma mark - UIPickerViewDataSource Protocol Methods


- (NSInteger) numberOfComponentsInPickerView: (UIPickerView *) pickerView {

	return 1;
}

- (NSInteger) pickerView: (UIPickerView *) pickerView numberOfRowsInComponent: (NSInteger) component {

	return frameRateNumbers.count;
}


@end
