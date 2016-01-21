//
//  ShortDurationViewController.m
//  Joystick
//
//  Created by Mark Zykin on 12/5/14.
//  Copyright (c) 2014 Dynamic Perception. All rights reserved.
//

#import <CocoaLumberjack/CocoaLumberjack.h>

#import "ShortDurationViewController.h"
#import "JoyButton.h"
#import "NMXDevice.h"


//------------------------------------------------------------------------------

#pragma mark - Private Interface


@interface ShortDurationViewController ()

@property (nonatomic, strong)	IBOutlet	UIView *		controlBackground;
@property (nonatomic, strong)	IBOutlet	UILabel *		title;
@property (nonatomic, strong)	IBOutlet	UIPickerView *	picker;
@property (nonatomic, strong)	IBOutlet	JoyButton *		okButton;

@end


//------------------------------------------------------------------------------

#pragma mark - Implementation


@implementation ShortDurationViewController

#pragma mark Static Variables

NSArray	static	*hoursNumbers = nil;
NSArray	static	*hoursStrings = nil;


NSArray	static	*minutesNumbers = nil;
NSArray	static	*minutesStrings = nil;

NSArray	static	*secondsNumbers = nil;
NSArray static	*secondsStrings = nil;

NSArray	static	*tenthsNumbers = nil;
NSArray static	*tenthsStrings = nil;


#pragma mark Public Propery Synthesis

@synthesize delegate;
@synthesize userInfo;


#pragma mark Private Propery Synthesis

@synthesize controlBackground;
@synthesize title;
@synthesize picker;
@synthesize okButton;

@synthesize isReviewShotTimerSegue, subheaderLbl, isMotorSegue, isMotorSegueVal, isSettingVideoFrame, selectedVideoFrame;

@synthesize appExecutive;

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
    
    
    for (NSInteger index = 0; index <= 24; index++)
        [mutableNumbers addObject: [NSNumber numberWithInteger: index]];
    
    for (NSInteger index = 0; index <= 24; index++)
        [mutableStrings addObject: [NSString stringWithFormat: @"%02ldh", (long)index]];
    
    hoursNumbers = [NSArray arrayWithArray: mutableNumbers];
    hoursStrings = [NSArray arrayWithArray: mutableStrings];
    
    
    [mutableStrings removeAllObjects];
    [mutableNumbers removeAllObjects];
    
    
    for (NSInteger index = 0; index < 60; index++)
		[mutableNumbers addObject: [NSNumber numberWithInteger: index]];

	for (NSInteger index = 0; index < 60; index++)
		[mutableStrings addObject: [NSString stringWithFormat: @"%02ldm", (long)index]];

	minutesNumbers = [NSArray arrayWithArray: mutableNumbers];
	minutesStrings = [NSArray arrayWithArray: mutableStrings];

	[mutableStrings removeAllObjects];
    
    
    
	for (NSInteger index = 0; index < 60; index++)
		[mutableStrings addObject: [NSString stringWithFormat: @"%02lds", (long)index]];

	secondsNumbers = [NSArray arrayWithArray: mutableNumbers];
	secondsStrings = [NSArray arrayWithArray: mutableStrings];

	[mutableStrings removeAllObjects];
	[mutableNumbers removeAllObjects];
    
    

	for (NSInteger index = 0; index < 10; index++)
		[mutableNumbers addObject: [NSNumber numberWithInteger: index]];

	for (NSInteger index = 0; index < 10; index++)
		[mutableStrings addObject: [NSString stringWithFormat: @".%ld", (long)index]];

	tenthsNumbers = [NSArray arrayWithArray: mutableNumbers];
	tenthsStrings = [NSArray arrayWithArray: mutableStrings];
}


//------------------------------------------------------------------------------

#pragma mark - Class Query


+ (NSString *) stringForShortDuration: (NSInteger) duration {

	NSInteger	wholeseconds	= duration / 1000;
	NSInteger	milliseconds	= duration % 1000;
	NSInteger	minutes			= (wholeseconds % 3600) / 60;
	NSInteger	seconds			= wholeseconds % 60;
	NSInteger	tenths			= milliseconds / 100;

	NSString *	string	= [NSString stringWithFormat: @"%02ld:%02ld.%1ld", (long)minutes, (long)seconds, (long)tenths];

	return string;
}


//------------------------------------------------------------------------------

#pragma mark - Object Management


- (void) viewDidLoad {

	self.picker.delegate = self;
	self.picker.dataSource = self;
    
    NSLog(@"ShortDuration isMotorSegueVal: %i",isMotorSegueVal);
    
    if (isReviewShotTimerSegue)
    {
        [okButton setTitle:@"Start" forState:UIControlStateNormal];
        subheaderLbl.text = @"Set Hours and Minutes";
    }
    else if(isMotorSegue)
    {
        self.title.text = @"Choose Frame Location";
    }
    
    if (isSettingVideoFrame)
    {
        selectedVideoFrame = [self roundNumber:selectedVideoFrame];
        
        NSLog(@"selectedVideoFrame: %i",selectedVideoFrame);
    }
    
    NSLog(@"video fc: %f",[self.appExecutive.frameCountNumber floatValue]);
    
//    float per1 = 0;
//    float per2 = 0;
//    float per3 = 0;
//    
//    NSLog(@"video fc: %f",[self.appExecutive.frameCountNumber floatValue]);
//    
//    if (self.appExecutive.is3P)
//    {
//        per1 = (float)self.appExecutive.slide3PVal1/[self.appExecutive.frameCountNumber floatValue];
//        per2 = (float)self.appExecutive.slide3PVal2/[self.appExecutive.frameCountNumber floatValue];
//        per3 = (float)self.appExecutive.slide3PVal3/[self.appExecutive.frameCountNumber floatValue];
//        
//        NSLog(@"per1: %.02f",per1);
//        NSLog(@"per2: %.02f",per2);
//        NSLog(@"per3: %.02f",per3);
//    }
    
    [super viewDidLoad];
}

- (float) roundNumber: (float)val {
    
    float val1 = 100.0 * floor((val/100.0) + 0.5);
    
    return val1;
}

- (void) viewWillAppear: (BOOL) animated {

	[super viewWillAppear: animated];
	[self.view sendSubviewToBack: self.controlBackground];
    
    if (self.appExecutive.is3P)
    {
        per1 = (float)self.appExecutive.slide3PVal1/[self.appExecutive.frameCountNumber floatValue];
        per2 = (float)self.appExecutive.slide3PVal2/[self.appExecutive.frameCountNumber floatValue];
        per3 = (float)self.appExecutive.slide3PVal3/[self.appExecutive.frameCountNumber floatValue];
        
        NSLog(@"short per1: %.02f",per1);
        NSLog(@"short per2: %.02f",per2);
        NSLog(@"short per3: %.02f",per3);
    }

	if (self.userInfo)
	{
        videoLength	= [self.userInfo objectForKey: kShortDurationInfoKeyNumber];
        
        //NSLog(@"videoLength: %@",videoLength);
        
		NSNumber *	number			= [self.userInfo objectForKey: kShortDurationInfoKeyNumber];
		NSInteger	duration		= [number integerValue];
		NSInteger	wholeseconds	= duration / 1000;
		NSInteger	milliseconds	= duration % 1000;
		NSInteger	minutes			= (wholeseconds % 3600) / 60;
		NSInteger	seconds			= wholeseconds % 60;
//        NSInteger	hours			= seconds % 60;
//        NSInteger	hours2			= seconds * 60;
		NSInteger	tenths			= milliseconds / 100;
        
//        NSLog(@"seconds: %li",(long)seconds);
//        NSLog(@"hours: %li",(long)hours);
//        NSLog(@"hours2: %li",(long)hours2);

		NSInteger	minutesRow	= [minutesNumbers indexOfObject: [NSNumber numberWithInteger: minutes]];
		NSInteger	secondsRow	= [secondsNumbers indexOfObject: [NSNumber numberWithInteger: seconds]];
		NSInteger	tenthsRow	= [tenthsNumbers  indexOfObject: [NSNumber numberWithInteger: tenths]];
        
        if (!isReviewShotTimerSegue)
        {
            [self.picker selectRow: minutesRow inComponent: 0 animated: NO];
            [self.picker selectRow: secondsRow inComponent: 1 animated: NO];
            [self.picker selectRow: tenthsRow  inComponent: 2 animated: NO];
        }
        
        self.title.text = [self.userInfo objectForKey: kShortDurationInfoKeyTitle];
	}
    
    if (isMotorSegue || isSettingVideoFrame)
    {
        NSNumber *	number			= [NSNumber numberWithInt:isMotorSegueVal];
        
        if (isSettingVideoFrame && selectedVideoFrame != 0)
        {
            number			= [NSNumber numberWithInt:selectedVideoFrame];
            
            NSLog(@"isSettingVideoFrame: %@",number);
        }
        
        NSInteger	duration		= [number integerValue];
        
        NSLog(@"duration: %li",(long)duration);
        
        
        NSInteger	wholeseconds	= duration / 1000;
        NSInteger	milliseconds	= duration % 1000;
        NSInteger	minutes			= (wholeseconds % 3600) / 60;
        NSInteger	seconds			= wholeseconds % 60;
//        NSInteger	hours			= seconds % 60;
//        NSInteger	hours2			= seconds * 60;
        NSInteger	tenths			= milliseconds / 100;
        
//        NSLog(@"seconds: %li",(long)seconds);
//        NSLog(@"hours: %li",(long)hours);
//        NSLog(@"hours2: %li",(long)hours2);
        
        NSInteger	minutesRow	= [minutesNumbers indexOfObject: [NSNumber numberWithInteger: minutes]];
        NSInteger	secondsRow	= [secondsNumbers indexOfObject: [NSNumber numberWithInteger: seconds]];
        NSInteger	tenthsRow	= [tenthsNumbers  indexOfObject: [NSNumber numberWithInteger: tenths]];
        
        if (!isReviewShotTimerSegue)
        {
            [self.picker selectRow: minutesRow inComponent: 0 animated: NO];
            [self.picker selectRow: secondsRow inComponent: 1 animated: NO];
            [self.picker selectRow: tenthsRow  inComponent: 2 animated: NO];
        }
        
        self.title.text = [self.userInfo objectForKey: kShortDurationInfoKeyTitle];
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
    dispatch_async(dispatch_get_main_queue(), ^{
        [self dismissViewControllerAnimated: YES completion: nil];
    });
}

//------------------------------------------------------------------------------

#pragma mark - IBAction Methods

- (IBAction) handleOkButton: (id) sender {

	DDLogDebug(@"Dismiss Short Duration Picker Button");
    
    //NSNumber *	numberForHours; //	= [hoursNumbers objectAtIndex: [self.picker selectedRowInComponent: 0]];
	NSNumber *	numberForMinutes; //	= [minutesNumbers objectAtIndex: [self.picker selectedRowInComponent: 0]];
	NSNumber *	numberForSeconds; //	= [secondsNumbers objectAtIndex: [self.picker selectedRowInComponent: 1]];
	NSNumber *	numberForTenths; //		= [secondsNumbers objectAtIndex: [self.picker selectedRowInComponent: 2]];

    //NSInteger	hours;
	NSInteger	minutes; //		= [numberForMinutes integerValue];
	NSInteger	seconds; //		= [numberForSeconds integerValue];
	NSInteger	tenths; //		= [numberForTenths integerValue];
    
    NSInteger	duration; //	= 1000 * (minutes * 60 + seconds) + (100 * tenths);
    NSNumber *	number; //	= [NSNumber numberWithInteger: duration];
    NSString *	string; //	= [ShortDurationViewController stringForShortDuration: duration];
    
    if (isReviewShotTimerSegue)
    {
        NSNumber *	numberForHours		= [hoursNumbers   objectAtIndex: [self.picker selectedRowInComponent: 0]];
        NSNumber *	numberForMinutes	= [minutesNumbers objectAtIndex: [self.picker selectedRowInComponent: 1]];
        
        NSInteger	hours		= [numberForHours integerValue];
        NSInteger	minutes		= [numberForMinutes integerValue];
        NSInteger	seconds		= 0;
        NSInteger	duration	= 1000 * (hours * 3600 + minutes * 60 + seconds);
        
        number	= [NSNumber numberWithInteger: duration];
        
        //NSLog(@"timer duration: %@", string);
        
        [[NSNotificationCenter defaultCenter]
         postNotificationName:@"chooseReviewShotDuration"
         object:number];
    }
    else if(!isMotorSegue)
    {
        numberForMinutes	= [minutesNumbers objectAtIndex: [self.picker selectedRowInComponent: 0]];
        numberForSeconds	= [secondsNumbers objectAtIndex: [self.picker selectedRowInComponent: 1]];
        numberForTenths		= [secondsNumbers objectAtIndex: [self.picker selectedRowInComponent: 2]];
        
        minutes		= [numberForMinutes integerValue];
        seconds		= [numberForSeconds integerValue];
        tenths		= [numberForTenths integerValue];
        
        duration	= 1000 * (minutes * 60 + seconds) + (100 * tenths);
        number	= [NSNumber numberWithInteger: duration];
        string	= [ShortDurationViewController stringForShortDuration: duration];
        
        NSString *	name	= [self.userInfo objectForKey: kShortDurationInfoKeyName];
        NSArray *	keys	= @[kShortDurationInfoKeyName, kShortDurationInfoKeyNumber, kShortDurationInfoKeyString];
        NSArray *	objects	= @[name, number, string];
        NSDictionary *	info	= [NSDictionary dictionaryWithObjects: objects forKeys: keys];

        [self.delegate updateShortDurationInfo: info];
    }
    else
    {
        //isMotorSegue
        
        //NSLog(@"isMotorSegue seconds tenths");
        
        numberForMinutes	= [minutesNumbers objectAtIndex: [self.picker selectedRowInComponent: 0]];
        numberForSeconds	= [secondsNumbers objectAtIndex: [self.picker selectedRowInComponent: 1]];
        numberForTenths		= [secondsNumbers objectAtIndex: [self.picker selectedRowInComponent: 2]];
        
        minutes		= [numberForMinutes integerValue];
        seconds		= [numberForSeconds integerValue];
        tenths		= [numberForTenths integerValue];
        
        duration	= 1000 * (minutes * 60 + seconds) + (100 * tenths);
        
        //NSLog(@"video isMotorSegue duration: %li",(long)duration);
        
        [[NSNotificationCenter defaultCenter]
         postNotificationName:@"chooseVideoFrame"
         object:[NSNumber numberWithInt:(int)duration]];
    }
    
    //NSLog(@"OK video fc: %f",[self.appExecutive.frameCountNumber floatValue]);
    
    if (self.appExecutive.is3P)
    {
        self.appExecutive.slide3PVal1 = [self.appExecutive.frameCountNumber floatValue] * per1;
        self.appExecutive.slide3PVal2 = [self.appExecutive.frameCountNumber floatValue] * per2;
        self.appExecutive.slide3PVal3 = [self.appExecutive.frameCountNumber floatValue] * per3;
        
        NSLog(@"sd new 1: %.02f",appExecutive.slide3PVal1);
        NSLog(@"sd new 2: %.02f",appExecutive.slide3PVal2);
        NSLog(@"sd new 3: %.02f",appExecutive.slide3PVal3);
        
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
		case 0: case 1:
			return  65.0;

		case 2:
			return 35.0;
	}

	return 35.0;
}

- (NSAttributedString *) pickerView: (UIPickerView *) pickerView attributedTitleForRow: (NSInteger) row forComponent: (NSInteger) component {

	NSDictionary *	attributes	=  @{ NSForegroundColorAttributeName: [UIColor whiteColor]};
	NSString *		string		= nil;

    if (isReviewShotTimerSegue)
    {
        switch (component)
        {
            case 0: string = [hoursStrings objectAtIndex: row];	break;
            case 1: string = [minutesStrings objectAtIndex: row];	break;

            default: break;
        }
    }
    else
    {
        switch (component)
        {
            case 0: string = [minutesStrings objectAtIndex: row];	break;
            case 1: string = [secondsStrings objectAtIndex: row];	break;
            case 2: string = [tenthsStrings  objectAtIndex: row];	break;
                
            default: break;
        }
    }

	return [[NSAttributedString alloc] initWithString: string attributes: attributes];
}

- (void) pickerView: (UIPickerView *) pickerView didSelectRow: (NSInteger) row inComponent: (NSInteger) component {

	return;
}

//------------------------------------------------------------------------------

#pragma mark - UIPickerViewDataSource Protocol Methods

- (NSInteger) numberOfComponentsInPickerView: (UIPickerView *) pickerView {

    
    if (isReviewShotTimerSegue)
    {
        return 2;
    }
    else
    {
        return 3;
    }
}

- (NSInteger) pickerView: (UIPickerView *) pickerView numberOfRowsInComponent: (NSInteger) component {

    if (isReviewShotTimerSegue)
    {
        switch (component)
        {
            case 0: return hoursNumbers.count;
            case 1: return minutesNumbers.count;
                
            default: break;
        }
    }
    else
    {
        switch (component)
        {
            case 0: return minutesNumbers.count;
            case 1: return secondsNumbers.count;
            case 2: return tenthsNumbers.count;
                
            default: break;
        }
    }

	return 0;
}

@end
