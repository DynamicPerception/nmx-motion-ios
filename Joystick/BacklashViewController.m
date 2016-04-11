//
//  BacklashViewController.m
//  Joystick
//
//  Created by Mark Zykin on 4/6/15.
//  Copyright (c) 2015 Mark Zykin. All rights reserved.
//

#import <CocoaLumberjack/CocoaLumberjack.h>

#import "BacklashViewController.h"
#import "JoyButton.h"

//------------------------------------------------------------------------------

#pragma mark - Private Interface


@interface BacklashViewController ()

// TODO: These arrays are identical; do we need separate arrays for the columns?

@property (nonatomic, strong)				NSArray *		digitsHundreds;
@property (nonatomic, strong)				NSArray *		digitsTens;
@property (nonatomic, strong)				NSArray *		digitsOnes;

@property (nonatomic, strong)	IBOutlet	UIView *		controlBackground;
@property (nonatomic, strong)	IBOutlet	UIPickerView *	picker;
@property (nonatomic, strong)	IBOutlet	JoyButton *		okButton;

@end


//------------------------------------------------------------------------------

#pragma mark - Implementation

@implementation BacklashViewController


#pragma mark Public Propery Synthesis

@synthesize delegate;
@synthesize backlash;


#pragma mark Private Propery Synthesis

@synthesize picker;


#pragma mark Public Propery Methods


- (NSInteger) backlash {

	return backlash;
}

- (void) setBacklash: (NSInteger) value {

	backlash = value;
}


#pragma mark Private Propery Methods


//------------------------------------------------------------------------------

#pragma mark - Object Management


- (void) viewDidLoad {

	[super viewDidLoad];

	self.picker.delegate = self;
	self.picker.dataSource = self;

	[self setupDigitArrays];
}

- (void) viewDidAppear: (BOOL) animated {

	[super viewDidAppear: animated];

	[self setPickerValue: self.backlash animated: NO];
}

- (void) didReceiveMemoryWarning {

	[super didReceiveMemoryWarning];
}

- (void) setupDigitArrays {

	self.digitsHundreds		= [self digitArray];
	self.digitsTens			= [self digitArray];
	self.digitsOnes			= [self digitArray];
}

- (NSArray *) digitArray {

	NSMutableArray *digits = [NSMutableArray array];

	for (NSInteger index = 0; index <= 9; index++)
		[digits addObject: [NSString stringWithFormat: @"%ld", (long) index]];

	return [NSArray arrayWithArray: digits];
}


//------------------------------------------------------------------------------

#pragma mark - Object Operations


- (NSInteger) getPickerValue {

	NSInteger	hundreds	= [self.picker selectedRowInComponent: 0];
	NSInteger	tens		= [self.picker selectedRowInComponent: 1];
	NSInteger	ones		= [self.picker selectedRowInComponent: 2];
	NSInteger	value		= (hundreds * 100) + (tens * 10) + ones;

	return value;
}

- (void) setPickerValue: (NSInteger) value animated: (BOOL) animated {

	NSInteger	hundreds	= (value / 100) % 10;
	NSInteger	tens		= (value / 10) % 10;
	NSInteger	ones		= value % 10;

	[self.picker selectRow: hundreds    inComponent: 0 animated: animated];
	[self.picker selectRow: tens        inComponent: 1 animated: animated];
	[self.picker selectRow: ones        inComponent: 2 animated: animated];
}


//------------------------------------------------------------------------------

#pragma mark - IBAction Methods


- (IBAction) handleOkButton: (id) sender {

	DDLogDebug(@"Dismiss Backlash Picker Button");

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
			string = [self.digitsHundreds objectAtIndex: row];
			break;

		case 1:
			string = [self.digitsTens objectAtIndex: row];
			break;

		case 2:
			string = [self.digitsOnes objectAtIndex: row];
			break;

		default:
			return nil;
			break;
	}

	return [[NSAttributedString alloc] initWithString: string attributes: attributes];
}

- (void) pickerView: (UIPickerView *) pickerView didSelectRow: (NSInteger) row inComponent: (NSInteger) component {

	self.backlash = [self getPickerValue];

	[self.delegate updateBacklash: self.backlash];

	DDLogDebug(@"Current value: %ld", (long)self.backlash);
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
			return self.digitsHundreds.count;

		case 1:
			return self.digitsTens.count;

		case 2:
			return self.digitsOnes.count;

		default: break;
	}

	return 10;
}


@end
