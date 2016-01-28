//
//  AppExecutive.m
//  Joystick
//
//  Created by Mark Zykin on 10/15/14.
//  Copyright (c) 2014 Dynamic Perception. All rights reserved.
//

#import <CocoaLumberjack/CocoaLumberjack.h>
#import "AppExecutive.h"

//------------------------------------------------------------------------------

#pragma mark - User Defaults Category

@implementation NSUserDefaults (Number)

- (NSNumber *) numberForKey: (NSString *) key {

	NSObject *	object		= [[NSUserDefaults standardUserDefaults] objectForKey: key];
	BOOL		isNumber	= [object isKindOfClass: [NSNumber class]];
	NSNumber *	number		= (isNumber ? (NSNumber *) object : nil);

	return number;
}

@end

//------------------------------------------------------------------------------

#pragma mark - Private Interface

typedef enum {

	DidSetFrameRate,
	DidSetFrameCount,
	DidSetVideoLength,
	DidSetNeither
}
LastSet;


@interface AppExecutive ()


@property (nonatomic, readwrite)	LastSet				forFrameRate;

@end


//------------------------------------------------------------------------------

#pragma mark - Implementation


@implementation AppExecutive

#pragma mark Static Variables

AppExecutive	static	*sharedInstance	= nil;

NSInteger		static	defaultFocusTime	=  600;
NSInteger		static	defaultTriggerTime	=  100;
NSInteger		static	defaultDelayTime	=  800;
NSInteger		static	defaultExposureTime	= 1500; // defaultFocusTime + defaultTriggerTime + defaultDelayTime
NSInteger		static	defaultBufferTime	= 2500; // defaultIntervalTime - defaultExposureTime
NSInteger		static	defaultIntervalTime	= 4000;

NSInteger		static	defaultShotDuration	= 1000 * 20 * 60;	// 20 minutes in milliseconds
NSInteger		static	defaultFrameCount	= 300;				// number of frames in shot
NSInteger		static	defaultVideoLength	= 1000 * 10;		// 10 seconds in milliseconds
NSInteger		static	defaultFrameRate	= 24;				// frames per second

BOOL			static defaultLockAxisState	= NO;		// Dominant axis lock off
CGFloat			static defaultSensitivity	= 100.0;	// 100% joystick sensitivity

CGFloat			static defaultRampingStart	= 0.25;
CGFloat			static defaultRampingFinal	= 0.75;

NSString		static 	*kDefaultsExposure		= @"kDefaultsExposure";
NSString		static 	*kDefaultsBuffer		= @"kDefaultsBuffer";
NSString		static 	*kDefaultsShotDuration	= @"kDefaultsShotDuration";

NSString		static 	*kDefaultsFrameCount	= @"kDefaultsFrameCount";
NSString		static 	*kDefaultsVideoLength	= @"kDefaultsVideoLength";
NSString		static 	*kDefaultsFrameRate		= @"kDefaultsFrameRate";

NSString		static 	*kDefaultsTrigger		= @"kDefaultsTrigger";
NSString		static 	*kDefaultsDelay			= @"kDefaultsDelay";
NSString		static 	*kDefaultsFocus			= @"kDefaultsFocus";
NSString		static 	*kDefaultsInterval		= @"kDefaultsInterval";

NSString		static 	*kDefaultsDeviceHandles	= @"kDefaultsDeviceHandles";

NSString		static 	*kDefaultsLockAxisState	= @"kDefaultsLockAxisState";
NSString		static 	*kDefaultsSensitivity	= @"kDefaultsSensitivity";

NSString		static *kDefaultsPanIncreaseValues		= @"kDefaultsPanIncreaseValues";
NSString		static *kDefaultsPanDecreaseValues		= @"kDefaultsPanDecreaseValues";
NSString		static *kDefaultsTiltIncreaseValues		= @"kDefaultsTiltIncreaseValues";
NSString		static *kDefaultsTiltDecreaseValues		= @"kDefaultsTiltDecreaseValues";
NSString		static *kDefaultsSlideIncreaseValues	= @"kDefaultsSlideIncreaseValues";
NSString		static *kDefaultsSlideDecreaseValues	= @"kDefaultsSlideDecreaseValues";


#pragma mark Public Property Synthesis

@synthesize joystick;

@synthesize exposureNumber;
@synthesize bufferNumber;
@synthesize shotDurationNumber;

@synthesize frameCountNumber;
@synthesize videoLengthNumber;
@synthesize frameRateNumber;

// Advanced Camera Settings

@synthesize triggerNumber;
@synthesize delayNumber;
@synthesize focusNumber;
@synthesize intervalNumber;

// Device Settings

@synthesize lockAxisNumber;
@synthesize sensitivityNumber;


// Ramping Settings

@synthesize panIncreaseValues;
@synthesize panDecreaseValues;
@synthesize tiltIncreaseValues;
@synthesize tiltDecreaseValues;
@synthesize slideIncreaseValues;
@synthesize slideDecreaseValues;


#pragma mark Private Property Synthesis

@synthesize defaults;
@synthesize forFrameRate;

@synthesize selectedMotorFrame, startPoint1,endPoint1, startPoint2,endPoint2, startPoint3, endPoint3, microstep1, microstep2, microstep3, stopMicrostep1, stopMicrostep2, stopMicrostep3, motor2MicrostepChanged,motor3MicrostepChanged, appBlueColor, is3P,slide3PVal1,slide3PVal3,slide3PVal2,pan3PVal1,pan3PVal2,pan3PVal3,tilt3PVal1,tilt3PVal2,tilt3PVal3,slideGear,slideMotor,panGear,panMotor,tiltGear,tiltMotor,midSet,start3PSlideDistance,start3PPanDistance,start3PTiltDistance,mid3PSlideDistance,mid3PPanDistance,mid3PTiltDistance,end3PSlideDistance,end3PPanDistance,end3PTiltDistance,useJoystick,start3PSet,mid3PSet,end3PSet,isContinuous,voltageHigh,voltageLow,voltage,scaledEnd3PPanDistance,scaledMid3PPanDistance,scaledStart3PPanDistance,scaledEnd3PSlideDistance,scaledEnd3PTiltDistance,scaledMid3PSlideDistance,scaledMid3PTiltDistance,scaledStart3PSlideDistance,scaledStart3PTiltDistance,isVideo,printTilt,dampening1,dampening2,dampening3,resetController;

//------------------------------------------------------------------------------

#pragma mark - Public Property Methods


- (void) setJoystick: (CGPoint) position {

	joystick = position;
}

- (NSNumber *) exposureNumber {

	if (exposureNumber == nil)
	{
		exposureNumber = [self.defaults numberForKey: kDefaultsExposure];

		if (exposureNumber == nil)
		{
			exposureNumber = [NSNumber numberWithInteger: defaultExposureTime];
			[self.defaults setObject: exposureNumber forKey: kDefaultsExposure];
		}
	}

	return exposureNumber;
}

- (NSNumber *) bufferNumber {

	if (bufferNumber == nil)
	{
		bufferNumber = [self.defaults objectForKey: kDefaultsBuffer];

		if (bufferNumber == nil)
		{
			bufferNumber = [NSNumber numberWithInteger: defaultBufferTime];
			[self.defaults setObject: bufferNumber forKey: kDefaultsBuffer];
		}
	}

	return bufferNumber;
}

- (NSNumber *) shotDurationNumber {

	if (shotDurationNumber == nil)
	{
		shotDurationNumber = [self.defaults numberForKey: kDefaultsShotDuration];

		if (shotDurationNumber == nil)
		{
			shotDurationNumber = [NSNumber numberWithInteger: defaultShotDuration];
			[self.defaults setObject: shotDurationNumber forKey: kDefaultsShotDuration];
		}
	}

	return shotDurationNumber;
}

- (void) setShotDurationNumber: (NSNumber *) number {

    //NSLog(@"setShotDurationNumber");
    
	if (FALSE == [number isEqualToNumber: self.shotDurationNumber])
	{
		if ([self validShotDurationNumber: number])
		{
			shotDurationNumber = number;
			[self computeFrameCountForShotDurationAndInterval];
			[self saveValue: shotDurationNumber forKey: kDefaultsShotDuration];
		}
	}
}

- (NSNumber *) frameCountNumber {

	if (frameCountNumber == nil)
	{
		frameCountNumber = [self.defaults numberForKey: kDefaultsFrameCount];

		if (frameCountNumber == nil)
		{
			frameCountNumber = [NSNumber numberWithInteger: defaultFrameCount];
			[self.defaults setObject: frameCountNumber forKey: kDefaultsFrameCount];
		}
	}

	return frameCountNumber;
}

- (void) setFrameCountNumber: (NSNumber *) number {

	if (FALSE == [number isEqualToNumber: self.frameCountNumber])
	{
		if ([self validFrameCountNumber: number])
		{
			frameCountNumber = number;

			[self computeVideoLength];
			[self computeShotDuration];
			[self saveValue: frameCountNumber forKey: kDefaultsFrameCount];

			self.forFrameRate = DidSetFrameCount;
		}
	}
}

- (NSNumber *) videoLengthNumber {

	if (videoLengthNumber == nil)
	{
		videoLengthNumber = [self.defaults numberForKey: kDefaultsVideoLength];

		if (videoLengthNumber == nil)
		{
			videoLengthNumber = [NSNumber numberWithInteger: defaultVideoLength];
			[self.defaults setObject: videoLengthNumber forKey: kDefaultsVideoLength];
		}
	}

	return videoLengthNumber;
}

- (void) setVideoLengthNumber: (NSNumber *) number {

	if (FALSE == [number isEqualToNumber: self.frameRateNumber])
	{
		if ([self validVideoLengthNumber: number])
		{
			videoLengthNumber = number;

			[self computeFrameCount];
			[self computeShotDuration];
			[self saveValue: videoLengthNumber forKey: kDefaultsVideoLength];

			self.forFrameRate = DidSetVideoLength;
		}
	}
}

- (NSNumber *) frameRateNumber {

	if (frameRateNumber == nil)
	{
		frameRateNumber = [self.defaults numberForKey: kDefaultsFrameRate];

		if (frameRateNumber == nil)
		{
			frameRateNumber = [NSNumber numberWithInteger: defaultFrameRate];
			[self.defaults setObject: frameRateNumber forKey: kDefaultsFrameRate];
		}
	}

	return frameRateNumber;
}

- (void) setFrameRateNumber: (NSNumber *) number {

	if (FALSE == [number isEqualToNumber: self.frameRateNumber])
	{
		frameRateNumber = number;
		[self computeFrameCount];
		[self computeShotDuration];
		[self saveValue: frameRateNumber forKey: kDefaultsFrameRate];
	}
}

- (NSNumber *) triggerNumber {

	if (triggerNumber == nil)
	{
		triggerNumber = [self.defaults numberForKey: kDefaultsTrigger];

		if (triggerNumber == nil)
		{
			triggerNumber = [NSNumber numberWithInteger: defaultTriggerTime];
			[self.defaults setObject: triggerNumber forKey: kDefaultsTrigger];
		}
	}

	return triggerNumber;
}

- (void) setTriggerNumber: (NSNumber *) number {

	if (FALSE == [number isEqualToNumber: self.triggerNumber])
	{
		if ([self validTriggerNumber: number])
		{
			triggerNumber = number;
			[self saveValue: triggerNumber forKey: kDefaultsTrigger];
		}
	}
}

- (NSNumber *) delayNumber {

	if (delayNumber == nil)
	{
		delayNumber = [self.defaults numberForKey: kDefaultsDelay];

		if (delayNumber == nil)
		{
			delayNumber = [NSNumber numberWithInteger: defaultDelayTime];
			[self.defaults setObject: delayNumber forKey: kDefaultsDelay];
		}
	}

	return delayNumber;
}


- (void) setDelayNumber: (NSNumber *) number {

	if (FALSE == [number isEqualToNumber: self.delayNumber])
	{
        delayNumber = number;
        [self saveValue: delayNumber forKey: kDefaultsDelay];
    }
}
 
 - (void) setExposureNumber: (NSNumber *) number {
 
	if (FALSE == [number isEqualToNumber: self.exposureNumber])
	{
        exposureNumber = number;
        [self saveValue: exposureNumber forKey: kDefaultsExposure];
	}
 }
 

- (NSNumber *) focusNumber {

	if (focusNumber == nil)
	{
		focusNumber = [self.defaults numberForKey: kDefaultsFocus];

		if (focusNumber == nil)
		{
			focusNumber = [NSNumber numberWithInteger: defaultFocusTime];
			[self.defaults setObject: focusNumber forKey: kDefaultsFocus];
		}
	}

	return focusNumber;
}

- (void) setFocusNumber: (NSNumber *) number {

	if (FALSE == [number isEqualToNumber: self.focusNumber])
	{
		if ([self validFocusNumber: number])
		{
			focusNumber = number;
			[self saveValue: focusNumber forKey: kDefaultsFocus];
		}
	}
}

- (NSNumber *) intervalNumber {

	if (intervalNumber == nil)
	{
		intervalNumber = [self.defaults numberForKey: kDefaultsInterval];

		if (intervalNumber == nil)
		{
			intervalNumber = [NSNumber numberWithInteger: defaultIntervalTime];
			[self.defaults setObject: intervalNumber forKey: kDefaultsInterval];
		}
	}

	return intervalNumber;
}

- (void) setIntervalNumber: (NSNumber *) number {

	if (FALSE == [number isEqualToNumber: self.intervalNumber])
	{
		if ([self validIntervalNumber: number])
		{
			intervalNumber = number;
            [self computeShotDuration];	// computes frameCount if changed

			[self saveValue: intervalNumber forKey: kDefaultsInterval];
		}
	}
}

- (NSNumber *) lockAxisNumber {

	if (lockAxisNumber == nil)
	{
		lockAxisNumber = [self.defaults numberForKey: kDefaultsLockAxisState];

		if (lockAxisNumber == nil)
		{
			lockAxisNumber = [NSNumber numberWithBool: defaultLockAxisState];
			[self.defaults setObject: lockAxisNumber forKey: kDefaultsLockAxisState];
		}
	}

	return lockAxisNumber;
}

- (void) setLockAxisNumber: (NSNumber *) number {

	if (FALSE == [number isEqualToNumber: self.lockAxisNumber])
	{
		lockAxisNumber = number;
		[self saveValue: lockAxisNumber forKey: kDefaultsLockAxisState];
	}
}

- (NSNumber *) sensitivityNumber {

	if (sensitivityNumber == nil)
	{
		sensitivityNumber = [self.defaults numberForKey: kDefaultsSensitivity];

		if (sensitivityNumber == nil)
		{
			sensitivityNumber = [NSNumber numberWithFloat: defaultSensitivity];
			[self.defaults setObject: sensitivityNumber forKey: kDefaultsSensitivity];
		}
	}

	return sensitivityNumber;
}

- (void) setSensitivityNumber: (NSNumber *) number {

	if (FALSE == [number isEqualToNumber: self.sensitivityNumber])
	{
		sensitivityNumber = number;
		[self saveValue: sensitivityNumber forKey: kDefaultsSensitivity];
	}
}


NSArray *defaultRampingValues() {

	NSNumber *startValue	= [NSNumber numberWithFloat: defaultRampingStart];
	NSNumber *finalValue	= [NSNumber numberWithFloat: defaultRampingFinal];
	NSArray  *values		= [NSArray arrayWithObjects: startValue, finalValue, nil];

	return values;
}

- (NSArray *) panIncreaseValues {

	if (panIncreaseValues == nil)
	{
		panIncreaseValues = [self.defaults arrayForKey: kDefaultsPanIncreaseValues];

		if (panIncreaseValues == nil)
		{
			panIncreaseValues = defaultRampingValues();
			[self.defaults setObject: panIncreaseValues forKey: kDefaultsPanIncreaseValues];
		}
	}

	return panIncreaseValues;
}

- (void) setPanIncreaseValues: (NSArray *) array {

	panIncreaseValues = array;
	[self saveValue: panIncreaseValues forKey: kDefaultsPanIncreaseValues];
}

- (NSArray *) panDecreaseValues {

	if (panDecreaseValues == nil)
	{
		panDecreaseValues = [self.defaults arrayForKey: kDefaultsPanDecreaseValues];

		if (panDecreaseValues == nil)
		{
			panDecreaseValues = defaultRampingValues();
			[self.defaults setObject: panDecreaseValues forKey: kDefaultsPanDecreaseValues];
		}
	}

	return panDecreaseValues;
}

- (void) setPanDecreaseValues: (NSArray *) array {

	panDecreaseValues = array;
	[self saveValue: panDecreaseValues forKey: kDefaultsPanDecreaseValues];
}

- (NSArray *) tiltIncreaseValues {

	if (tiltIncreaseValues == nil)
	{
		tiltIncreaseValues = [self.defaults arrayForKey: kDefaultsTiltIncreaseValues];

		if (tiltIncreaseValues == nil)
		{
			tiltIncreaseValues = defaultRampingValues();
			[self.defaults setObject: tiltIncreaseValues forKey: kDefaultsTiltIncreaseValues];
		}
	}

	return tiltIncreaseValues;
}

- (void) setTiltIncreaseValues: (NSArray *) array {

	tiltIncreaseValues = array;
	[self saveValue: tiltIncreaseValues forKey: kDefaultsTiltIncreaseValues];
}

- (NSArray *) tiltDecreaseValues {

	if (tiltDecreaseValues == nil)
	{
		tiltDecreaseValues = [self.defaults arrayForKey: kDefaultsTiltDecreaseValues];

		if (tiltDecreaseValues == nil)
		{
			tiltDecreaseValues = defaultRampingValues();
			[self.defaults setObject: tiltDecreaseValues forKey: kDefaultsTiltDecreaseValues];
		}
	}

	return tiltDecreaseValues;
}

- (void) setTiltDecreaseValues: (NSArray *) array {

	tiltDecreaseValues = array;
	[self saveValue: tiltDecreaseValues forKey: kDefaultsTiltDecreaseValues];
}

- (NSArray *) slideIncreaseValues {

	if (slideIncreaseValues == nil)
	{
		slideIncreaseValues = [self.defaults arrayForKey: kDefaultsSlideIncreaseValues];

		if (slideIncreaseValues == nil)
		{
			slideIncreaseValues = defaultRampingValues();
			[self.defaults setObject: slideIncreaseValues forKey: kDefaultsSlideIncreaseValues];
		}
	}
    
	return slideIncreaseValues;
}

- (void) setSlideIncreaseValues: (NSArray *) array {

	slideIncreaseValues = array;
	[self saveValue: slideIncreaseValues forKey: kDefaultsSlideIncreaseValues];
}

- (NSArray *) slideDecreaseValues {

	if (slideDecreaseValues == nil)
	{
		slideDecreaseValues = [self.defaults arrayForKey: kDefaultsSlideDecreaseValues];

		if (slideDecreaseValues == nil)
		{
			slideDecreaseValues = defaultRampingValues();
			[self.defaults setObject: slideDecreaseValues forKey: kDefaultsSlideDecreaseValues];
		}
	}

	return slideDecreaseValues;
}

- (void) setSlideDecreaseValues: (NSArray *) array {

	slideDecreaseValues = array;
	[self saveValue: slideDecreaseValues forKey: kDefaultsSlideDecreaseValues];
}

//------------------------------------------------------------------------------

#pragma mark - Private Property Methods

- (NSUserDefaults *) defaults {

	if (defaults == nil)
		defaults =  [NSUserDefaults standardUserDefaults];

	return defaults;
}

//------------------------------------------------------------------------------

#pragma mark - Class Management


+ (void) initialize {

	sharedInstance = [[AppExecutive alloc] init];
}


+  (AppExecutive *) sharedInstance {

	if (sharedInstance == nil)
		sharedInstance = [[AppExecutive alloc] init];

	return sharedInstance;
}


//------------------------------------------------------------------------------

#pragma mark - Object Management


- (id) init {

	if (self = [super init])
	{
		self.forFrameRate = DidSetNeither; // TODO: set but not used
        
		if (getenv("CLEAR_DEVICE_HANDLES"))
		{
			[self.defaults removeObjectForKey: kDefaultsDeviceHandles];
			[self.defaults synchronize];
		}
	}

	return self;
}


//------------------------------------------------------------------------------

#pragma mark - Persistence


- (void) saveValue: (NSObject *) object forKey: (NSString *) key {

	[self.defaults setObject: object forKey: key];
	[self.defaults synchronize];
}

- (NSNumber *) getNumberForKey: (NSString *) key {

	NSObject *	object	= [self.defaults objectForKey: key];
	NSNumber *	number	= ([object isKindOfClass: [NSNumber class]] ? (NSNumber *) object : nil);

	return number;
}

- (NSString *) nameForDeviceID: (NSString *) deviceName {

	if (deviceName)
	{
		NSDictionary *	allHandles	= [self.defaults dictionaryForKey: kDefaultsDeviceHandles];
		NSString *		thisHandle	= [allHandles objectForKey: deviceName];

		return thisHandle;
	}

	return nil;
}

- (void) setHandle: (NSString *) handle forDeviceName: (NSString *) deviceName {

	NSDictionary *			oldHandles	= [self.defaults dictionaryForKey: kDefaultsDeviceHandles];
	NSMutableDictionary *	newHandles	= [NSMutableDictionary dictionaryWithDictionary: oldHandles];

	if (handle.length == 0)
		[newHandles removeObjectForKey: deviceName];
	else
		[newHandles setObject: handle forKey: deviceName];

	[self.defaults setObject: newHandles forKey: kDefaultsDeviceHandles];
	[self.defaults synchronize];
}

- (NSString *) stringWithHandleForDeviceName: (NSString *) deviceName {

	NSString *deviceHandle = [self nameForDeviceID: deviceName];
    
    if (deviceHandle)
    {
        return deviceHandle;
    }

    return deviceName;
}


//------------------------------------------------------------------------------

#pragma mark - Object Operations


- (void) computeShotDuration {

	//DDLogDebug(@"computeShotDuration");

	NSInteger	frameCount	= [self.frameCountNumber integerValue];
	NSInteger	interval	= [self.intervalNumber integerValue];

	self.shotDurationNumber = [NSNumber numberWithFloat: frameCount * interval];
    
    //NSLog(@"self.shotDurationNumber: %@",self.shotDurationNumber);
}

- (void) computeFrameCountForShotDurationAndInterval {

	//DDLogDebug(@"computeFrameCountForShotDurationAndInterval");

	NSInteger	shotDuration	= [self.shotDurationNumber integerValue];
	NSInteger	interval		= [self.intervalNumber integerValue];
	NSInteger	frameCount		= (NSInteger) roundf((float) shotDuration / interval);

	self.frameCountNumber = [NSNumber numberWithInteger: frameCount];
}

- (void) computeFrameCount {

	//DDLogDebug(@"computeFrameCount");

	NSInteger	videoLength		= [self.videoLengthNumber integerValue];
	NSInteger	frameRate		= [self.frameRateNumber  integerValue];
	NSInteger	frameCount		= (NSInteger) roundf((float) (videoLength * frameRate) / 1000);

	self.frameCountNumber = [NSNumber numberWithInteger: frameCount];
}

- (void) computeVideoLength {

	//DDLogDebug(@"computeVideoLength");

	NSInteger	frameCount	= [self.frameCountNumber integerValue];
	NSInteger	frameRate	= [self.frameRateNumber  integerValue];
	NSInteger	videoLength	= (NSInteger) roundf(((float) frameCount / frameRate) * 1000);

	self.videoLengthNumber = [NSNumber numberWithInteger: videoLength];    
}

//------------------------------------------------------------------------------

#pragma mark - Value Validation


- (void) valueLessThanMinimumTime: (NSString *) title {

	UIAlertView *alert = [[UIAlertView alloc] initWithTitle: title
													message: @"Minimum value is 0.1 seconds."
												   delegate: nil
										  cancelButtonTitle: @"OK"
										  otherButtonTitles: nil];
	[alert show];
}

- (void) valueLessThanMinimumCount: (NSString *) title {

	UIAlertView *alert = [[UIAlertView alloc] initWithTitle: title
													message: @"Minimum value is 1."
												   delegate: nil
										  cancelButtonTitle: @"OK"
										  otherButtonTitles: nil];
	[alert show];
}

- (BOOL) validExposureNumber: (NSNumber *) number {

	float exposure	= [number floatValue];

	if (exposure < 0.1)	// Note: fixed number choices should prevent this
	{
		[self valueLessThanMinimumTime: @"Exposure Setting"];
		return FALSE;
	}

	return TRUE;
}

- (BOOL) validIntervalNumber: (NSNumber *) number {

	float interval	= [number floatValue];

	if (interval < 0.1)
	{
		[self valueLessThanMinimumTime: @"Interval Setting"];
		return FALSE;
	}

	return TRUE;
}

- (BOOL) validShotDurationNumber: (NSNumber *) number {

	NSInteger duration	= [number integerValue];

	if (duration < 100)
	{
		[self valueLessThanMinimumTime: @"Shot Duration Setting"];
		return FALSE;
	}

	return TRUE;
}

- (BOOL) validFrameCountNumber: (NSNumber *) number {

	NSInteger frameCount = [number integerValue];

	if (frameCount < 1)
	{
		[self valueLessThanMinimumCount: @"Frame Count Setting"];
		return FALSE;
	}

	return TRUE;
}

- (BOOL) validVideoLengthNumber: (NSNumber *) number {

	NSInteger videoLength = [number integerValue];

	if (videoLength < 100)
	{
		[self valueLessThanMinimumTime: @"Video Length Setting"];
		return FALSE;
	}

	return TRUE;
}

- (BOOL) validTriggerNumber: (NSNumber *) number {

	NSInteger trigger	= [number integerValue];

	if (trigger < 100)
	{
		[self valueLessThanMinimumTime: @"Trigger Setting"];
		return FALSE;
	}

	return TRUE;
}

- (BOOL) validFocusNumber: (NSNumber *) number {

	NSInteger focus		= [number integerValue];

	if (focus < 100)
	{
		[self valueLessThanMinimumTime: @"Focus Setting"];
		return FALSE;
	}

	return TRUE;
}

- (BOOL) validDelayNumber: (NSNumber *) number {

	NSInteger delay		= [number integerValue];

	if (delay < 100)
	{
		[self valueLessThanMinimumTime: @"Delay Setting"];
		return FALSE;
	}

	return TRUE;
}

- (void) restoreDefaults {
    
    NSLog(@"restoreDefaults");
    
    //defaults
    
    exposureNumber = [NSNumber numberWithInteger: defaultExposureTime];
    [self.defaults setObject: exposureNumber forKey: kDefaultsExposure];

    focusNumber = [NSNumber numberWithInteger: defaultFocusTime];
    [self.defaults setObject: focusNumber forKey: kDefaultsFocus];
    
    triggerNumber = [NSNumber numberWithInteger: defaultTriggerTime];
    [self.defaults setObject: triggerNumber forKey: kDefaultsTrigger];
    
    delayNumber = [NSNumber numberWithInteger: defaultDelayTime];
    [self.defaults setObject: delayNumber forKey: kDefaultsDelay];
    
    bufferNumber = [NSNumber numberWithInteger: defaultBufferTime];
    [self.defaults setObject: bufferNumber forKey: kDefaultsBuffer];
    
    intervalNumber = [NSNumber numberWithInteger: defaultIntervalTime];
    [self.defaults setObject: intervalNumber forKey: kDefaultsInterval];
    
    shotDurationNumber = [NSNumber numberWithInteger: defaultShotDuration];
    [self.defaults setObject: shotDurationNumber forKey: kDefaultsShotDuration];
    
    frameCountNumber = [NSNumber numberWithInteger: defaultFrameCount];
    [self.defaults setObject: frameCountNumber forKey: kDefaultsFrameCount];
    
    videoLengthNumber = [NSNumber numberWithInteger: defaultVideoLength];
    [self.defaults setObject: videoLengthNumber forKey: kDefaultsVideoLength];
    
    frameRateNumber = [NSNumber numberWithInteger: defaultFrameRate];
    [self.defaults setObject: frameRateNumber forKey: kDefaultsFrameRate];
    
    lockAxisNumber = [NSNumber numberWithBool: defaultLockAxisState];
    [self.defaults setObject: lockAxisNumber forKey: kDefaultsLockAxisState];
    
    sensitivityNumber = [NSNumber numberWithFloat: defaultSensitivity];
    [self.defaults setObject: sensitivityNumber forKey: kDefaultsSensitivity];
    
    //ramping values
    
    panIncreaseValues = defaultRampingValues();
    [self.defaults setObject: panIncreaseValues forKey: kDefaultsPanIncreaseValues];
    
    panDecreaseValues = defaultRampingValues();
    [self.defaults setObject: panDecreaseValues forKey: kDefaultsPanDecreaseValues];
    
    tiltIncreaseValues = defaultRampingValues();
    [self.defaults setObject: tiltIncreaseValues forKey: kDefaultsTiltIncreaseValues];
    
    tiltDecreaseValues = defaultRampingValues();
    [self.defaults setObject: tiltDecreaseValues forKey: kDefaultsTiltDecreaseValues];
    
    slideIncreaseValues = defaultRampingValues();
    [self.defaults setObject: slideIncreaseValues forKey: kDefaultsSlideIncreaseValues];
    
    slideDecreaseValues = defaultRampingValues();
    [self.defaults setObject: slideDecreaseValues forKey: kDefaultsSlideDecreaseValues];
    
    [self.defaults synchronize];
}

- (void) setPoints {
    
    //NSLog(@"startStopQueryTimer");
        
    startPoint1 = [self.device queryProgramStartPoint:1];
    endPoint1 = [self.device queryProgramEndPoint:1];
    
//    NSLog(@"mvc startPoint1: %i",startPoint1);
//    NSLog(@"mvc endPoint1: %i",endPoint1);
    
    startPoint2 = [self.device queryProgramStartPoint:2];
    endPoint2 = [self.device queryProgramEndPoint:2];
    
//    NSLog(@"mvc startPoint2: %i",startPoint2);
//    NSLog(@"mvc endPoint2: %i",endPoint2);
    
    startPoint3 = [self.device queryProgramStartPoint:3];
    endPoint3 = [self.device queryProgramEndPoint:3];
    
//    NSLog(@"mvc startPoint3: %i",startPoint3);
//    NSLog(@"mvc stopPoint3: %i",endPoint3);
    
    int startStopVal =
    startPoint1 + endPoint1 +
    startPoint2 + endPoint2 +
    startPoint3 + endPoint3;
    
        NSLog(@"startStopVal: %i",startStopVal);
    
//        if (startStopVal > 0) {
//            
//            self.setStartButton.selected = YES;
//            self.setStopButton.selected = YES;
//        }
}


@end
