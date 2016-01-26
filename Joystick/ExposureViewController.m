//
//  ExposureViewController.m
//  Joystick
//
//  Created by Mark Zykin on 11/26/14.
//  Copyright (c) 2014 Dynamic Perception. All rights reserved.
//

#import <CocoaLumberjack/CocoaLumberjack.h>

#import "ExposureViewController.h"
#import "JoyButton.h"
#import "NMXDevice.h"


//------------------------------------------------------------------------------

#pragma mark - Private Interface


@interface ExposureViewController ()

@property (nonatomic, strong)	IBOutlet	UIView *		controlBackground;
@property (nonatomic, strong)	IBOutlet	UIPickerView *	picker;
@property (nonatomic, strong)	IBOutlet	JoyButton *		okButton;

@end


//------------------------------------------------------------------------------

#pragma mark - Implementation


@implementation ExposureViewController

#pragma mark Static Variables

NSArray	static	*exposureNumbers = nil;
NSArray static	*exposureStrings = nil;


#pragma mark Public Propery Synthesis

@synthesize delegate;
@synthesize exposure;


#pragma mark Private Propery Synthesis

@synthesize picker;


#pragma mark Public Propery Methods


- (void) setExposure: (NSNumber *) number {

	NSInteger	row	= [exposureNumbers indexOfObject: number];

	if (row == NSNotFound)
	{
		NSNumber *oneSecond = [NSNumber numberWithInteger: 1000];

		row = [exposureNumbers indexOfObject: oneSecond];
	}

	exposure = [exposureNumbers objectAtIndex: row];
}


#pragma mark Private Propery Methods


//------------------------------------------------------------------------------

#pragma mark - Class Management


+ (void) initialize {

	NSMutableArray *mutableNumbers = [NSMutableArray arrayWithObjects:
									  [NSNumber numberWithInteger: 300],
									  [NSNumber numberWithInteger: 600],
									  nil];

	for (NSInteger index = 1; index <= 40; index++)
		[mutableNumbers addObject: [NSNumber numberWithFloat: index * 1000]];

	exposureNumbers = [NSArray arrayWithArray: mutableNumbers];

	NSMutableArray *mutableStrings = [NSMutableArray arrayWithObjects: @"0.3", @"0.6", nil];

	for (NSInteger index = 1; index <= 40; index++)
		[mutableStrings addObject: [NSString stringWithFormat: @"%ld", (long)index]];

	exposureStrings = [NSArray arrayWithArray: mutableStrings];
}


//------------------------------------------------------------------------------

#pragma mark - Class Query


+ (NSString *) stringForExposure: (NSInteger) exposure {

	NSNumber *	number	= [NSNumber numberWithInteger: exposure];
	NSInteger	index	= [exposureNumbers indexOfObject: number];

	if (index == NSNotFound)
	{
		NSInteger	wholeseconds	= exposure / 1000;
		NSInteger	milliseconds	= exposure % 1000;
		NSInteger	tenths			= milliseconds / 100;

		return [NSString stringWithFormat: @"%ld.%ld", (long)wholeseconds, (long)tenths];
	}
	else
	{
		return [exposureStrings objectAtIndex: index];
	}

	return nil;
}


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

	NSInteger row = [exposureNumbers indexOfObject: self.exposure];

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

- (void) deviceDisconnect: (id) object {
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        [self dismissViewControllerAnimated: YES completion: nil];
    });
}


//------------------------------------------------------------------------------

#pragma mark - IBAction Methods


- (IBAction) handleOkButton: (id) sender {

	DDLogDebug(@"Dismiss Exposure Picker Button");

	NSInteger	index	= [self.picker selectedRowInComponent: 0];
	NSNumber *	number	= [exposureNumbers objectAtIndex: index];
	NSString *	string	= [exposureStrings objectAtIndex: index];
    
    NSLog(@"number: %@",number);
    NSLog(@"string: %@",string);

	[self.delegate updateExposureNumber: number];
	[self.delegate updateExposureString: string];
    
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

	NSString *		stringForRow	= [exposureStrings objectAtIndex: row];
	NSDictionary *	attributes		=  @{ NSForegroundColorAttributeName: [UIColor whiteColor]};

	return [[NSAttributedString alloc] initWithString: stringForRow attributes: attributes];
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

	return exposureNumbers.count;
}


@end
