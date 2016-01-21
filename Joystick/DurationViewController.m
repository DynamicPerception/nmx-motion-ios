//
//  DurationViewController.m
//  Joystick
//
//  Created by Mark Zykin on 11/26/14.
//  Copyright (c) 2014 Dynamic Perception. All rights reserved.
//

#import <CocoaLumberjack/CocoaLumberjack.h>

#import "DurationViewController.h"
#import "JoyButton.h"
#import "NMXDevice.h"


//------------------------------------------------------------------------------

#pragma mark - Private Interface


@interface DurationViewController ()

@property (nonatomic, strong)	IBOutlet	UIView *		controlBackground;
@property (nonatomic, strong)	IBOutlet	UILabel *		title;
@property (nonatomic, strong)	IBOutlet	UIPickerView *	picker;
@property (nonatomic, strong)	IBOutlet	JoyButton *		okButton;

@end

//------------------------------------------------------------------------------

#pragma mark - Implementation


@implementation DurationViewController

#pragma mark Static Variables

NSArray	static	*hoursNumbers = nil;
NSArray	static	*hoursStrings = nil;

NSArray	static	*minutesNumbers = nil;
NSArray	static	*minutesStrings = nil;

NSArray	static	*secondsNumbers = nil;
NSArray static	*secondsStrings = nil;


#pragma mark Public Propery Synthesis

@synthesize delegate;
@synthesize userInfo;


#pragma mark Private Propery Synthesis

@synthesize controlBackground;
@synthesize title;
@synthesize picker;
@synthesize okButton;

@synthesize isMotorSegue,appExecutive;


#pragma mark Public Propery Methods

- (AppExecutive *) appExecutive {
    
    if (appExecutive == nil)
        appExecutive = [AppExecutive sharedInstance];
    
    return appExecutive;
}

#pragma mark Private Propery Methods

//------------------------------------------------------------------------------

#pragma mark - Class Management

+ (void) initialize {
    
	NSMutableArray *mutableNumbers	= [NSMutableArray array];
	NSMutableArray *mutableStrings	= [NSMutableArray array];

    //for (NSInteger index = 0; index < 60; index++)
	for (NSInteger index = 0; index <= 99; index++)
		[mutableNumbers addObject: [NSNumber numberWithInteger: index]];

	//for (NSInteger index = 0; index < 60; index++)
    for (NSInteger index = 0; index <= 99; index++)
		[mutableStrings addObject: [NSString stringWithFormat: @"%02ldh", (long)index]];

	hoursNumbers = [NSArray arrayWithArray: mutableNumbers];
	hoursStrings = [NSArray arrayWithArray: mutableStrings];

	[mutableStrings removeAllObjects];
    
	for (NSInteger index = 0; index < 60; index++)
		[mutableStrings addObject: [NSString stringWithFormat: @"%02ldm", (long)index]];

	minutesNumbers = [NSArray arrayWithArray: mutableNumbers];
	minutesStrings = [NSArray arrayWithArray: mutableStrings];

	[mutableStrings removeAllObjects];
    
	for (NSInteger index = 0; index < 60; index++)
		[mutableStrings addObject: [NSString stringWithFormat: @"%02lds", (long)index]];

	secondsNumbers = [NSArray arrayWithArray: mutableNumbers];
	secondsStrings = [NSArray arrayWithArray: mutableStrings];
}

//------------------------------------------------------------------------------

#pragma mark - Class Query

+ (NSString *) stringForDuration: (NSInteger) duration {
    
	NSInteger	wholeseconds	= duration / 1000;

	NSInteger	hours	= wholeseconds / 3600;
	NSInteger	minutes	= (wholeseconds % 3600) / 60;
	NSInteger	seconds	= wholeseconds % 60;

	NSString *	string	= [NSString stringWithFormat: @"%02ld:%02ld:%02ld", (long)hours, (long)minutes, (long)seconds];

	return string;
}

//------------------------------------------------------------------------------

#pragma mark - Object Management

- (void) viewDidLoad {
    
	[super viewDidLoad];

	self.picker.delegate = self;
	self.picker.dataSource = self;
    
    if(isMotorSegue)
    {
        self.title.text = @"Choose Frame Location";
    }

//	self.picker.layer.borderWidth = 1.0;
//	self.picker.layer.borderColor = [[UIColor grayColor] CGColor];
}

- (void) viewWillAppear: (BOOL) animated {
    
	[super viewWillAppear: animated];
	[self.view sendSubviewToBack: self.controlBackground];
    
    if (self.appExecutive.is3P)
    {
        per1 = (float)self.appExecutive.slide3PVal1/[self.appExecutive.frameCountNumber floatValue];
        per2 = (float)self.appExecutive.slide3PVal2/[self.appExecutive.frameCountNumber floatValue];
        per3 = (float)self.appExecutive.slide3PVal3/[self.appExecutive.frameCountNumber floatValue];
        
        NSLog(@"dv per1: %.02f",per1);
        NSLog(@"dv per2: %.02f",per2);
        NSLog(@"dv per3: %.02f",per3);
    }

	if (self.userInfo)
	{
		NSNumber *	number			= [self.userInfo objectForKey: kDurationInfoKeyNumber];
		NSInteger	duration		= [number integerValue];
		NSInteger	wholeseconds	= duration / 1000;
		NSInteger	hours			= wholeseconds / 3600;
		NSInteger	minutes			= (wholeseconds % 3600) / 60;
		NSInteger	seconds			= wholeseconds % 60;

		NSInteger	hoursRow	= [hoursNumbers   indexOfObject: [NSNumber numberWithInteger: hours]];
		NSInteger	minutesRow	= [minutesNumbers indexOfObject: [NSNumber numberWithInteger: minutes]];
		NSInteger	secondsRow	= [secondsNumbers indexOfObject: [NSNumber numberWithInteger: seconds]];

		[self.picker selectRow: hoursRow   inComponent: 0 animated: NO];
		[self.picker selectRow: minutesRow inComponent: 1 animated: NO];
		[self.picker selectRow: secondsRow inComponent: 2 animated: NO];

		self.title.text = [self.userInfo objectForKey: kDurationInfoKeyTitle];
	}
    
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

	DDLogDebug(@"Dismiss Duration Picker Button");

	NSNumber *	numberForHours		= [hoursNumbers   objectAtIndex: [self.picker selectedRowInComponent: 0]];
	NSNumber *	numberForMinutes	= [minutesNumbers objectAtIndex: [self.picker selectedRowInComponent: 1]];
	NSNumber *	numberForSeconds	= [secondsNumbers objectAtIndex: [self.picker selectedRowInComponent: 2]];

	NSInteger	hours		= [numberForHours integerValue];
	NSInteger	minutes		= [numberForMinutes integerValue];
	NSInteger	seconds		= [numberForSeconds integerValue];
	NSInteger	duration	= 1000 * (hours * 3600 + minutes * 60 + seconds);
    
    if (isMotorSegue)
    {
        duration = 1000 * (hours * 3600 + minutes * 60);
        
        //post notification
        
        NSLog(@"continuous isMotorSegue duration: %li",(long)duration);
        
        [[NSNotificationCenter defaultCenter]
         postNotificationName:@"chooseContinousLocation"
         object:[NSNumber numberWithInt:(int)duration]];        
    }
    else
    {
        NSString *	name	= [self.userInfo objectForKey: kDurationInfoKeyName];
        NSNumber *	number	= [NSNumber numberWithInteger: duration];
        NSString *	string	= [DurationViewController stringForDuration: duration];;
        
        NSArray *		keys	= @[kDurationInfoKeyName, kDurationInfoKeyNumber, kDurationInfoKeyString];
        NSArray *		objects	= @[name, number, string];
        NSDictionary *	info	= [NSDictionary dictionaryWithObjects: objects forKeys: keys];
        
        duration	= 1000 * (hours * 3600 + minutes * 60 + seconds);
        
        [self.delegate updateDurationInfo: info];
    }
    
    if (self.appExecutive.is3P)
    {
        self.appExecutive.slide3PVal1 = [self.appExecutive.frameCountNumber floatValue] * per1;
        self.appExecutive.slide3PVal2 = [self.appExecutive.frameCountNumber floatValue] * per2;
        self.appExecutive.slide3PVal3 = [self.appExecutive.frameCountNumber floatValue] * per3;
        
        NSLog(@"dv new 1: %.02f",appExecutive.slide3PVal1);
        NSLog(@"dv new 2: %.02f",appExecutive.slide3PVal2);
        NSLog(@"dv new 3: %.02f",appExecutive.slide3PVal3);
        
        [appExecutive.defaults setObject: [NSNumber numberWithFloat:appExecutive.slide3PVal1] forKey: @"slide3PVal1"];
        [appExecutive.defaults setObject: [NSNumber numberWithFloat:appExecutive.slide3PVal2] forKey: @"slide3PVal2"];
        [appExecutive.defaults setObject: [NSNumber numberWithFloat:appExecutive.slide3PVal3] forKey: @"slide3PVal3"];
        [appExecutive.defaults synchronize];
    }

	[self dismissViewControllerAnimated: YES completion: nil];
}

//------------------------------------------------------------------------------

#pragma mark - UIPickerViewDelegate Protocol Methods

- (CGFloat) pickerView: (UIPickerView *) pickerView rowHeightForComponent: (NSInteger) component {
    
	return 21.0;
}

- (CGFloat) pickerView: (UIPickerView *) pickerView widthForComponent: (NSInteger) component {
    
	switch (component)
	{
		case 0: case 1: case 2:
			return  70.0;

		default:
			return 35.0;
	}

	return 35.0;
}

- (NSAttributedString *) pickerView: (UIPickerView *) pickerView attributedTitleForRow: (NSInteger) row forComponent: (NSInteger) component {
    
	NSDictionary *	attributes	=  @{ NSForegroundColorAttributeName: [UIColor whiteColor]};
	NSString *		string		= nil;

	switch (component)
	{
		case 0: string = [hoursStrings   objectAtIndex: row];	break;
		case 1: string = [minutesStrings objectAtIndex: row];	break;
		case 2: string = [secondsStrings objectAtIndex: row];	break;

		default: break;
	}

	return [[NSAttributedString alloc] initWithString: string attributes: attributes];
}

- (void) pickerView: (UIPickerView *) pickerView didSelectRow: (NSInteger) row inComponent: (NSInteger) component {
    
	return;
}

//------------------------------------------------------------------------------

#pragma mark - UIPickerViewDataSource Protocol Methods


- (NSInteger) numberOfComponentsInPickerView: (UIPickerView *) pickerView {
    
	return 3;
}

- (NSInteger) pickerView: (UIPickerView *) pickerView numberOfRowsInComponent: (NSInteger) component {
    
	switch (component)
	{
		case 0: return hoursStrings.count;
		case 1: return minutesStrings.count;
		case 2: return secondsStrings.count;

		default: break;
	}

	return 0;
}

@end
