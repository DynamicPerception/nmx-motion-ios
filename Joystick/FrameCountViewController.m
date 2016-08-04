//
//  FrameCountViewController.m
//  Joystick
//
//  Created by Mark Zykin on 12/19/14.
//  Copyright (c) 2014 Dynamic Perception. All rights reserved.
//

#import <CocoaLumberjack/CocoaLumberjack.h>

#import "FrameCountViewController.h"
#import "JoyButton.h"
#import "AppExecutive.h"


//------------------------------------------------------------------------------

#pragma mark - Private Interface


@interface FrameCountViewController ()

@property (nonatomic, strong)				AppExecutive *	appExecutive;

@property (nonatomic, strong)	IBOutlet	UIView *		controlBackground;
@property (nonatomic, strong)	IBOutlet	UIPickerView *	picker;
@property (nonatomic, strong)	IBOutlet	JoyButton *		okButton;

@end


//------------------------------------------------------------------------------

#pragma mark - Implementation


@implementation FrameCountViewController

#pragma mark Static Variables

NSArray static	*frameCountStrings = nil;


#pragma mark Public Propery Synthesis

#pragma mark Private Propery Synthesis

@synthesize appExecutive;
@synthesize controlBackground;
@synthesize picker;
@synthesize okButton;

@synthesize isMotorSegue, myDelegate, currentFrameValue, isRampingScreen;


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

	NSMutableArray *strings = [NSMutableArray array];

	for (NSInteger index = 0; index < 10; index++)
	{
		[strings addObject: [NSString stringWithFormat: @"%ld", (long)index]];
	}

	frameCountStrings = [NSArray arrayWithArray: strings];
}

//------------------------------------------------------------------------------

#pragma mark - Class Query

//------------------------------------------------------------------------------

#pragma mark - Object Management

- (void) viewDidLoad {

    NSLog(@"framecountvc");
    
	[super viewDidLoad];

	self.picker.delegate = self;
	self.picker.dataSource = self;
    
    [okButton addTarget:self action:@selector(handleOkButton:) forControlEvents:UIControlEventTouchUpInside];
}

- (void) viewWillAppear: (BOOL) animated {

	[super viewWillAppear: animated];
	[self.view sendSubviewToBack: self.controlBackground];

	NSInteger	frameCount;
    
    if (isMotorSegue)
    {
        frameCount = currentFrameValue;
    }
    else
    {
        frameCount	= [self.appExecutive.frameCountNumber integerValue];
    }
    
	NSInteger	ones		= frameCount % 10;
	NSInteger	tens		= (frameCount / 10) % 10;
	NSInteger	hundreds	= (frameCount / 100) % 10;
	NSInteger	thousands	= (frameCount / 1000) % 10;

	[self.picker selectRow: thousands inComponent: 0 animated: NO];
	[self.picker selectRow: hundreds  inComponent: 1 animated: NO];
	[self.picker selectRow: tens      inComponent: 2 animated: NO];
	[self.picker selectRow: ones      inComponent: 3 animated: NO];
    
    if (!isMotorSegue)
    {

        [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(deviceDisconnect:)
                                                 name: kDeviceDisconnectedNotification
                                               object: nil];
    }
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

- (void) didReceiveMemoryWarning {

	[super didReceiveMemoryWarning];	
}

//------------------------------------------------------------------------------

#pragma mark - IBAction Methods

- (IBAction) handleOkButton: (id) sender {

	//DDLogDebug(@"Dismiss Frame Count Picker Button Randall");

	NSInteger	thousands	= [self.picker selectedRowInComponent: 0];
	NSInteger	hundreds	= [self.picker selectedRowInComponent: 1];
	NSInteger	tens		= [self.picker selectedRowInComponent: 2];
	NSInteger	ones		= [self.picker selectedRowInComponent: 3];
	NSInteger	frameCount	= (thousands * 1000) + (hundreds * 100) + (tens * 10) + ones;
    
    float per1 = 0;
    float per2 = 0;
    float per3 = 0;
    
    JSDeviceSettings *settings = self.appExecutive.device.settings;
    
    if (self.appExecutive.is3P && !isRampingScreen)
    {
//        float range1 = [self.appExecutive.frameCountNumber floatValue] * .33;
//        float range2 = [self.appExecutive.frameCountNumber floatValue] * .75;
//        float range3 = [self.appExecutive.frameCountNumber floatValue];
//        
//        NSLog(@"range1: %.02f",range1);
//        NSLog(@"range2: %.02f",range2);
//        NSLog(@"range3: %.02f",range3);
        
        per1 = (float)settings.slide3PVal1/[self.appExecutive.frameCountNumber floatValue];
        per2 = (float)settings.slide3PVal2/[self.appExecutive.frameCountNumber floatValue];
        per3 = (float)settings.slide3PVal3/[self.appExecutive.frameCountNumber floatValue];
        
        NSLog(@"frame count per1: %.02f",per1);
        NSLog(@"frame count per2: %.02f",per2);
        NSLog(@"frame count per3: %.02f",per3);
    }
    
    if (isMotorSegue)
    {
        [[NSNotificationCenter defaultCenter]
         postNotificationName:@"chooseFrame4"
         object:[NSNumber numberWithInteger: frameCount]];
        
        //[myDelegate saveFrame:[NSNumber numberWithInteger: frameCount]];
    }
    else
    {
        self.appExecutive.frameCountNumber = [NSNumber numberWithInteger: frameCount];
    }
    
    if (self.appExecutive.is3P && !isRampingScreen)
    {
        for (NMXDevice *device in self.appExecutive.deviceList)
        {
            JSDeviceSettings *devSettings = device.settings;

            devSettings.slide3PVal1 = [self.appExecutive.frameCountNumber floatValue] * per1;
            devSettings.slide3PVal2 = [self.appExecutive.frameCountNumber floatValue] * per2;
            devSettings.slide3PVal3 = [self.appExecutive.frameCountNumber floatValue] * per3;
        }
    }
	
    [self dismissViewControllerAnimated: YES completion: ^{
        
    }];
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
	NSString *		string		= [frameCountStrings objectAtIndex: row];

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

	return frameCountStrings.count;
}

@end
