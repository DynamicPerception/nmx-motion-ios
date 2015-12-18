//
//  SetSecondsViewController.m
//  Joystick
//
//  Created by Mark Zykin on 12/23/14.
//  Copyright (c) 2014 Dynamic Perception. All rights reserved.
//

#import <CocoaLumberjack/CocoaLumberjack.h>

#import "SetSecondsViewController.h"
#import "JoyButton.h"
#import "AppExecutive.h"


//------------------------------------------------------------------------------

#pragma mark - Private Interface


@interface SetSecondsViewController ()

@property (nonatomic, strong)				AppExecutive *	appExecutive;
@property (nonatomic, strong)				NSArray *		secondsTens;
@property (nonatomic, strong)				NSArray *		secondsOnes;
@property (nonatomic, strong)				NSArray *		secondsTenths;

@property (nonatomic, strong)	IBOutlet	UIView *		controlBackground;
@property (nonatomic, strong)	IBOutlet	UILabel *		titleLabel;
@property (nonatomic, strong)	IBOutlet	UILabel *		messageLabel;
@property (nonatomic, strong)	IBOutlet	UIPickerView *	picker;
@property (nonatomic, strong)	IBOutlet	JoyButton *		okButton;

@end


//------------------------------------------------------------------------------

#pragma mark - Implementation


@implementation SetSecondsViewController

#pragma mark Static Variables

NSArray	static	*secondsOnes	= nil;
NSArray	static	*secondsTenths	= nil;

NSInteger static	minimumTimeValue	= 100;	//  minimum time value in milliseconds


#pragma mark Public Propery Synthesis

@synthesize variableToSet;


#pragma mark Private Propery Synthesis

@synthesize appExecutive;

@synthesize secondsTens;
@synthesize secondsOnes;
@synthesize secondsTenths;

@synthesize controlBackground;
@synthesize titleLabel;
@synthesize messageLabel;
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

	return;
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
	[self setTitleAndMessage];

	NSInteger milliseconds = [self getVariableValue];

	[self setPickerValue: milliseconds animated: NO];

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


- (void) setTitleAndMessage {

	NSString *format = @"Set %@ in Seconds";

	if ([self.variableToSet isEqualToString: kSetSecondsForFocus])
	{
		self.titleLabel.text = @"Focus";
		self.messageLabel.text = [NSString stringWithFormat: format, @"Focus"];
		self.secondsTens	= [self digitArrayWithLimit: 0];
		self.secondsOnes	= [self digitArrayWithLimit: 9];
		self.secondsTenths	= [self decimalArray];
	}

	else if ([self.variableToSet isEqualToString: kSetSecondsForTrigger])
	{
		self.titleLabel.text = @"Trigger";
		self.messageLabel.text = [NSString stringWithFormat: format, @"Trigger"];
		self.secondsTens	= [self digitArrayWithLimit: 9];
		self.secondsOnes	= [self digitArrayWithLimit: 9];
		self.secondsTenths	= [self decimalArray];
	}

	else if ([self.variableToSet isEqualToString: kSetSecondsForDelay])
	{
		self.titleLabel.text = @"Delay";
		self.messageLabel.text = [NSString stringWithFormat: format, @"Delay"];
		self.secondsTens	= [self digitArrayWithLimit: 6];
		self.secondsOnes	= [self digitArrayWithLimit: 9];
		self.secondsTenths	= [self decimalArray];
	}
}

- (NSArray *) digitArrayWithLimit: (NSInteger) limit {

	NSMutableArray *work = [NSMutableArray array];

	for (NSInteger index = 0; index <= limit; index++)
		[work addObject: [NSString stringWithFormat: @"%ld", (long) index]];

	return [NSArray arrayWithArray: work];
}

- (NSArray *) decimalArray {

	NSMutableArray *work = [NSMutableArray array];

	for (NSInteger index = 0; index < 10; index++)
		[work addObject: [NSString stringWithFormat: @".%ld", (long) index]];

	return [NSArray arrayWithArray: work];
}

- (NSInteger) getVariableValue {

	if ([self.variableToSet isEqualToString: kSetSecondsForFocus])
		return [self.appExecutive.focusNumber integerValue];

	else if ([self.variableToSet isEqualToString: kSetSecondsForTrigger])
		return [self.appExecutive.triggerNumber integerValue];

	else if ([self.variableToSet isEqualToString: kSetSecondsForDelay])
		return  [self.appExecutive.delayNumber integerValue];

	return 0;
}

- (void) setVariableValue: (NSInteger) value {

	NSNumber *number = [NSNumber numberWithInteger: value];

	if ([self.variableToSet isEqualToString: kSetSecondsForFocus])
		self.appExecutive.focusNumber = number;

	else if ([self.variableToSet isEqualToString: kSetSecondsForTrigger])
		self.appExecutive.triggerNumber = number;

	else if ([self.variableToSet isEqualToString: kSetSecondsForDelay])
		self.appExecutive.delayNumber = number;
}

- (NSInteger) getPickerValue {

	NSInteger	tens			= [self.picker selectedRowInComponent: 0];
	NSInteger	ones			= [self.picker selectedRowInComponent: 1];
	NSInteger	tenths			= [self.picker selectedRowInComponent: 2];
	NSInteger	milliseconds	= (tens * 10000) + (ones * 1000) + (tenths * 100);

	return milliseconds;
}

- (void) setPickerValue: (NSInteger) milliseconds animated: (BOOL) animated {

	NSInteger	tens			= (milliseconds / 10000) % 10;
	NSInteger	ones			= (milliseconds / 1000) % 10;
	NSInteger	tenths			= (milliseconds / 100) % 10;

	[self.picker selectRow: tens   inComponent: 0 animated: animated];
	[self.picker selectRow: ones   inComponent: 1 animated: animated];
	[self.picker selectRow: tenths inComponent: 2 animated: animated];
}


//------------------------------------------------------------------------------

#pragma mark - IBAction Methods


- (IBAction) handleOkButton: (id) sender {

	DDLogDebug(@"Dismiss Set Seconds Picker Button");

	NSInteger	milliseconds	= [self getPickerValue];

	[self setVariableValue: milliseconds];
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

	NSDictionary *	attributes	= @{ NSForegroundColorAttributeName: [UIColor whiteColor]};
	NSString *		string		= nil;

	switch (component)
	{
		case 0:
			string = [self.secondsTens objectAtIndex: row];
			break;

		case 1:
			string = [self.secondsOnes objectAtIndex: row];
			break;

		case 2:
			string = [self.secondsTenths objectAtIndex: row];
			break;

		default:
			return nil;
			break;
	}

	return [[NSAttributedString alloc] initWithString: string attributes: attributes];
}

- (void) pickerView: (UIPickerView *) pickerView didSelectRow: (NSInteger) row inComponent: (NSInteger) component {

	NSInteger milliseconds = [self getPickerValue];

	if ([self.variableToSet isEqualToString: kSetSecondsForDelay])
	{
		NSInteger maximum = (self.secondsTens.count - 1) * 10000;

		if (milliseconds > maximum)
			[self setPickerValue: maximum animated: YES];
	}

	if (milliseconds < minimumTimeValue)
		[self setPickerValue: minimumTimeValue animated: YES];
}


//------------------------------------------------------------------------------

#pragma mark - UIPickerViewDataSource Protocol Methods


- (NSInteger) numberOfComponentsInPickerView: (UIPickerView *) pickerView {

	return 3;
}

- (NSInteger) pickerView: (UIPickerView *) pickerView numberOfRowsInComponent: (NSInteger) component {

	switch (component)
	{
		case 0:
			return self.secondsTens.count;

		case 1:
			return self.secondsOnes.count;

		case 2:
			return self.secondsTenths.count;

		default: break;
	}
	return 10;
}


@end
