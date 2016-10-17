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

#define MAX_DAYS 9

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

NSArray	static	*daysNumbers = nil;
NSArray	static	*daysStrings = nil;

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

    for (NSInteger index = 0; index <= MAX_DAYS; index++)
    {
        [mutableNumbers addObject: [NSNumber numberWithInteger: index]];
        [mutableStrings addObject: [NSString stringWithFormat: @"%ldd", (long)index]];
    }
    
    daysNumbers = [NSArray arrayWithArray: mutableNumbers];
    daysStrings = [NSArray arrayWithArray: mutableStrings];

    [mutableStrings removeAllObjects];
    [mutableNumbers removeAllObjects];
    
	for (NSInteger index = 0; index <= 23; index++)
    {
		[mutableNumbers addObject: [NSNumber numberWithInteger: index]];
		[mutableStrings addObject: [NSString stringWithFormat: @"%02ldh", (long)index]];
    }

	hoursNumbers = [NSArray arrayWithArray: mutableNumbers];
	hoursStrings = [NSArray arrayWithArray: mutableStrings];

	[mutableStrings removeAllObjects];
    [mutableNumbers removeAllObjects];
    
	for (NSInteger index = 0; index < 60; index++)
    {
		[mutableStrings addObject: [NSString stringWithFormat: @"%02ldm", (long)index]];
        [mutableNumbers addObject: [NSNumber numberWithInteger: index]];
    }

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

    NSInteger	days	= wholeseconds / (3600*24);
    wholeseconds -= days * (3600*24);
	NSInteger	hours	= wholeseconds / 3600;
	NSInteger	minutes	= (wholeseconds % 3600) / 60;
	NSInteger	seconds	= wholeseconds % 60;

	NSString *	string	= [NSString stringWithFormat: @"%ld:%02ld:%02ld:%02ld", (long)days, (long)hours, (long)minutes, (long)seconds];

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
        JSDeviceSettings *settings = self.appExecutive.device.settings;

        per1 = (float)settings.slide3PVal1/[self.appExecutive.frameCountNumber floatValue];
        per2 = (float)settings.slide3PVal2/[self.appExecutive.frameCountNumber floatValue];
        per3 = (float)settings.slide3PVal3/[self.appExecutive.frameCountNumber floatValue];
    }

	if (self.userInfo)
	{
		NSNumber *	number			= [self.userInfo objectForKey: kDurationInfoKeyNumber];
		NSInteger	duration		= [number integerValue];
		NSInteger	wholeseconds	= duration / 1000;
        NSInteger	days	        = wholeseconds / (3600*24);
        wholeseconds -= days * (3600*24);
		NSInteger	hours			= wholeseconds / 3600;
		NSInteger	minutes			= (wholeseconds % 3600) / 60;
		NSInteger	seconds			= wholeseconds % 60;

        if (days > MAX_DAYS)
        {
            days = MAX_DAYS;
            hours = 23;
            minutes = 59;
            seconds = 59;
        }

        NSInteger	daysRow	    = [daysNumbers    indexOfObject: [NSNumber numberWithInteger: days]];
		NSInteger	hoursRow	= [hoursNumbers   indexOfObject: [NSNumber numberWithInteger: hours]];
		NSInteger	minutesRow	= [minutesNumbers indexOfObject: [NSNumber numberWithInteger: minutes]];
		NSInteger	secondsRow	= [secondsNumbers indexOfObject: [NSNumber numberWithInteger: seconds]];

        [self.picker selectRow: daysRow    inComponent: 0 animated: NO];
		[self.picker selectRow: hoursRow   inComponent: 1 animated: NO];
		[self.picker selectRow: minutesRow inComponent: 2 animated: NO];
		[self.picker selectRow: secondsRow inComponent: 3 animated: NO];

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

- (void) deviceDisconnect: (NSNotification *) notification
{
    //NMXDevice *device = notification.object;
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        [self dismissViewControllerAnimated: YES completion: nil];
    });
}

//------------------------------------------------------------------------------

#pragma mark - IBAction Methods

- (IBAction) handleOkButton: (id) sender {

	DDLogDebug(@"Dismiss Duration Picker Button");

    NSNumber *	numberForDays		= [daysNumbers    objectAtIndex: [self.picker selectedRowInComponent: 0]];
	NSNumber *	numberForHours		= [hoursNumbers   objectAtIndex: [self.picker selectedRowInComponent: 1]];
	NSNumber *	numberForMinutes	= [minutesNumbers objectAtIndex: [self.picker selectedRowInComponent: 2]];
	NSNumber *	numberForSeconds	= [secondsNumbers objectAtIndex: [self.picker selectedRowInComponent: 3]];

    NSInteger	days		= [numberForDays integerValue];
	NSInteger	hours		= [numberForHours integerValue];
	NSInteger	minutes		= [numberForMinutes integerValue];
	NSInteger	seconds		= [numberForSeconds integerValue];
	NSInteger	duration	= 1000 * (days * (3600*24) + hours * 3600 + minutes * 60 + seconds);
    
    if (isMotorSegue)
    {
        duration = 1000 * (days * (3600*24) + hours * 3600 + minutes * 60);
        
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
        
        [self.delegate updateDurationInfo: info];
        
        if ([appExecutive.frameCountNumber integerValue] > USHRT_MAX)
        {
            self.appExecutive.frameCountNumber = [NSNumber numberWithInteger: USHRT_MAX];
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Duration Setting"
                                                            message: @"New duration exceeds frame count limit.  Duration has been adjusted to a legal value."
                                                           delegate: self
                                                  cancelButtonTitle: @"OK"
                                                  otherButtonTitles: nil];
            [alert show];

        }
    }
    
    if (self.appExecutive.is3P)
    {
        for (NMXDevice *device in self.appExecutive.deviceList)
        {
            JSDeviceSettings *settings = device.settings;

            settings.slide3PVal1 = [self.appExecutive.frameCountNumber floatValue] * per1;
            settings.slide3PVal2 = [self.appExecutive.frameCountNumber floatValue] * per2;
            settings.slide3PVal3 = [self.appExecutive.frameCountNumber floatValue] * per3;
        }
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
		case 0: case 1: case 2: case 3:
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
		case 0: string = [daysStrings    objectAtIndex: row];	break;
		case 1: string = [hoursStrings   objectAtIndex: row];	break;
		case 2: string = [minutesStrings objectAtIndex: row];	break;
		case 3: string = [secondsStrings objectAtIndex: row];	break;

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
    
	return 4;
}

- (NSInteger) pickerView: (UIPickerView *) pickerView numberOfRowsInComponent: (NSInteger) component {
    
	switch (component)
	{
		case 0: return daysStrings.count;
		case 1: return hoursStrings.count;
		case 2: return minutesStrings.count;
		case 3: return secondsStrings.count;

		default: break;
	}

	return 0;
}

@end
