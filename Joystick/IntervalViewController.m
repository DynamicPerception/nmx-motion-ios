//
//  IntervalViewController.m
//  Joystick
//
//  Created by Mark Zykin on 12/19/14.
//  Copyright (c) 2014 Dynamic Perception. All rights reserved.
//

#import <CocoaLumberjack/CocoaLumberjack.h>

#import "IntervalViewController.h"
#import "JoyButton.h"
#import "AppExecutive.h"

//------------------------------------------------------------------------------

#pragma mark - Private Interface


@interface IntervalViewController ()

@property (nonatomic, strong)				AppExecutive *	appExecutive;

@property (nonatomic, strong)	IBOutlet	UIView *		controlBackground;
@property (nonatomic, strong)	IBOutlet	UIPickerView *	picker;
@property (nonatomic, strong)	IBOutlet	JoyButton *		okButton;

@end


//------------------------------------------------------------------------------

#pragma mark - Implementation


@implementation IntervalViewController

#pragma mark Static Variables

NSArray	static	*intervalOnes	= nil;
NSArray	static	*intervalTenths	= nil;

NSInteger static	minimumTimeValue	= 100;	//  minimum time value in milliseconds


#pragma mark Public Propery Synthesis

#pragma mark Private Propery Synthesis

@synthesize appExecutive;
@synthesize controlBackground;
@synthesize picker;
@synthesize okButton;


#pragma mark Public Propery Methods


#pragma mark Private Propery Methods


- (AppExecutive *) appExecutive {

	if (appExecutive == nil)
		appExecutive = [AppExecutive sharedInstance];

	return appExecutive;
}


//------------------------------------------------------------------------------

#pragma mark - Class Management


+ (void) initialize {

	NSMutableArray *ones	= [NSMutableArray array];
	NSMutableArray *tenths	= [NSMutableArray array];

	for (NSInteger index = 0; index < 10; index++)
	{
		[ones   addObject: [NSString stringWithFormat: @"%ld",  (long) index]];
		[tenths addObject: [NSString stringWithFormat: @".%ld", (long) index]];
	}

	intervalOnes	= [NSArray arrayWithArray: ones];
	intervalTenths	= [NSArray arrayWithArray: tenths];
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

	NSInteger	interval	= [self.appExecutive.intervalNumber integerValue];

	[self setPickerValue: interval animated: NO];

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

    [self dismissViewControllerAnimated: YES completion: nil];
}


//------------------------------------------------------------------------------

#pragma mark - Object Operations


- (NSInteger) getPickerValue {

    NSInteger	hundreds			= [self.picker selectedRowInComponent: 0];
	NSInteger	tens			= [self.picker selectedRowInComponent: 1];
	NSInteger	ones			= [self.picker selectedRowInComponent: 2];
	NSInteger	tenths			= [self.picker selectedRowInComponent: 3];
	NSInteger	milliseconds	= (hundreds * 100000) + (tens * 10000) + (ones * 1000) + (tenths * 100);

	return milliseconds;
}

- (void) setPickerValue: (NSInteger) milliseconds animated: (BOOL) animated {

    NSInteger	hundreds			= (milliseconds / 100000) % 10;
	NSInteger	tens			= (milliseconds / 10000) % 10;
	NSInteger	ones			= (milliseconds / 1000) % 10;
	NSInteger	tenths			= (milliseconds / 100) % 10;

    [self.picker selectRow: hundreds   inComponent: 0 animated: animated];
	[self.picker selectRow: tens   inComponent: 1 animated: animated];
	[self.picker selectRow: ones   inComponent: 2 animated: animated];
	[self.picker selectRow: tenths inComponent: 3 animated: animated];
}


//------------------------------------------------------------------------------

#pragma mark - IBAction Methods


- (IBAction) handleOkButton: (id) sender {

	DDLogDebug(@"Dismiss Interval Picker Button");

	NSInteger	interval	= [self getPickerValue];

	self.appExecutive.intervalNumber = [NSNumber numberWithInteger: interval];
	[self dismissViewControllerAnimated: YES completion: nil];
}


//------------------------------------------------------------------------------

#pragma mark - UIPickerViewDelegate Protocol Methods


- (CGFloat) pickerView: (UIPickerView *) pickerView rowHeightForComponent: (NSInteger) component {

	return 21.0;
}

- (CGFloat) pickerView: (UIPickerView *) pickerView widthForComponent: (NSInteger) component {

	return 40.0;
}

- (NSAttributedString *) pickerView: (UIPickerView *) pickerView attributedTitleForRow: (NSInteger) row forComponent: (NSInteger) component {

	NSDictionary *	attributes	=  @{ NSForegroundColorAttributeName: [UIColor whiteColor]};
	NSString *		string		= nil;

	switch (component)
	{
		case 0:
            string = [intervalOnes objectAtIndex: row];
        case 1:
			string = [intervalOnes objectAtIndex: row];
			break;
		case 2:
			string = [intervalOnes objectAtIndex: row];
			break;
        case 3:
            string = [intervalTenths objectAtIndex: row];
            break;

		default:
			return nil;
			break;
	}

	return [[NSAttributedString alloc] initWithString: string attributes: attributes];
}

- (void) pickerView: (UIPickerView *) pickerView didSelectRow: (NSInteger) row inComponent: (NSInteger) component {

	NSInteger milliseconds = [self getPickerValue];

	if (milliseconds < minimumTimeValue)
		[self setPickerValue: minimumTimeValue animated: YES];
}


//------------------------------------------------------------------------------

#pragma mark - UIPickerViewDataSource Protocol Methods


- (NSInteger) numberOfComponentsInPickerView: (UIPickerView *) pickerView {

	return 4;
}

- (NSInteger) pickerView: (UIPickerView *) pickerView numberOfRowsInComponent: (NSInteger) component {

	return 10;
}


@end
