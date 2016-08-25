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

@property (nonatomic, strong)				NSArray *		mostSigDigit;
@property (nonatomic, strong)				NSArray *		leastSigDigit;

@property (nonatomic, strong)	IBOutlet	UIView *		controlBackground;
@property (nonatomic, strong)	IBOutlet	UIPickerView *	picker;
@property (nonatomic, strong)	IBOutlet	JoyButton *		okButton;
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;

@end


//------------------------------------------------------------------------------

#pragma mark - Implementation

@implementation BacklashViewController


#pragma mark Public Propery Synthesis

@synthesize delegate;


#pragma mark Private Propery Synthesis

@synthesize picker;


#pragma mark Private Propery Methods


//------------------------------------------------------------------------------

#pragma mark - Object Management

- (id)initWithCoder:(NSCoder *)decoder
{
    self = [super initWithCoder:decoder];

    if (self)
    {
        self.maxValue = 999;
        self.minValue = 0;
        self.digits = 3;
    }
    
    return self;
}

- (void) viewDidLoad {

	[super viewDidLoad];

	self.picker.delegate = self;
	self.picker.dataSource = self;

	[self setupDigitArrays];
    
    
}

- (void) viewWillAppear: (BOOL) animated {

	[super viewWillAppear: animated];

	[self setPickerValue: self.value animated: NO];
    
    self.titleLabel.text = self.titleString;
}

- (void) didReceiveMemoryWarning {

	[super didReceiveMemoryWarning];
}

- (void) setupDigitArrays {

    int max = self.maxValue / pow(10, (self.digits - 1));
    
    self.leastSigDigit	= [self digitArrayWithMax: 9];
    self.mostSigDigit	= [self digitArrayWithMax: max];
}

- (NSArray *) digitArrayWithMax: (int) max
{
	NSMutableArray *digits = [NSMutableArray array];

	for (NSInteger index = 0; index <= max; index++)
		[digits addObject: [NSString stringWithFormat: @"%ld", (long) index]];

	return [NSArray arrayWithArray: digits];
}


//------------------------------------------------------------------------------

#pragma mark - Object Operations


- (NSInteger) getPickerValue {

    int value = 0;
    for (int i = self.digits-1; i >= 0; i--)
    {
        value += pow(10, i) *  [self.picker selectedRowInComponent: self.digits-i-1];
    }

    return value;
}

- (void) setPickerValue: (NSInteger) value animated: (BOOL) animated {

    for (int i = self.digits-1; i >= 0; i--)
    {
        int row =  (value / (int)pow(10, i)) % 10;
        [self.picker selectRow: row inComponent: self.digits-i-1 animated: animated];

    }

}


//------------------------------------------------------------------------------

#pragma mark - IBAction Methods


- (IBAction) handleOkButton: (id) sender {

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

    string = [self.leastSigDigit objectAtIndex: row];

    
	return [[NSAttributedString alloc] initWithString: string attributes: attributes];
}

- (void) pickerView: (UIPickerView *) pickerView didSelectRow: (NSInteger) row inComponent: (NSInteger) component {

	self.value = [self getPickerValue];
    
    self.value = MAX(self.minValue, self.value);
    self.value = MIN(self.maxValue, self.value);
    
    [self.delegate updateIntValue: self.value];

	DDLogDebug(@"Current value: %ld", (long)self.value);
}


//------------------------------------------------------------------------------

#pragma mark - UIPickerViewDataSource Protocol Methods


- (NSInteger) numberOfComponentsInPickerView: (UIPickerView *) pickerView {

	return self.digits;
}

- (NSInteger) pickerView: (UIPickerView *) pickerView numberOfRowsInComponent: (NSInteger) component {

    if (self.digits - component < self.digits)
    {
        return self.leastSigDigit.count;
    }
    else
    {
        return self.mostSigDigit.count;
    }

}


@end
