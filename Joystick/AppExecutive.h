//
//  AppExecutive.h
//  Joystick
//
//  Created by Mark Zykin on 10/15/14.
//  Copyright (c) 2014 Dynamic Perception. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "NMXDevice.h"
#import "NMXDeviceManager.h"

@interface AppExecutive : NSObject


@property (nonatomic, readwrite)	CGPoint				joystick;

@property (nonatomic, strong)		NSNumber *			exposureNumber;
@property (nonatomic, readwrite)	NSNumber *			bufferNumber;

@property (nonatomic, strong)		NSNumber *			shotDurationNumber;

@property (nonatomic, strong)		NSNumber *			frameCountNumber;
@property (nonatomic, strong)		NSNumber *			videoLengthNumber;
@property (nonatomic, strong)		NSNumber *			frameRateNumber;


// Advanced Camera Settings

@property (nonatomic, strong)		NSNumber *			triggerNumber;
@property (nonatomic, strong)		NSNumber *			delayNumber;
@property (nonatomic, strong)		NSNumber *			focusNumber;
@property (nonatomic, strong)		NSNumber *			intervalNumber;


// Device Settings

@property (nonatomic, strong)		NSNumber *			lockAxisNumber;
@property (nonatomic, strong)		NSNumber *			sensitivityNumber;


// Ramping Settings

@property (nonatomic, strong)		NSArray *			panIncreaseValues;
@property (nonatomic, strong)		NSArray *			panDecreaseValues;
@property (nonatomic, strong)		NSArray *			tiltIncreaseValues;
@property (nonatomic, strong)		NSArray *			tiltDecreaseValues;
@property (nonatomic, strong)		NSArray *			slideIncreaseValues;
@property (nonatomic, strong)		NSArray *			slideDecreaseValues;


@property (strong, atomic)          NMXDevice *         device;
@property (strong, atomic)          NMXDeviceManager *  deviceManager;
@property (nonatomic, readonly)		NSUserDefaults *	defaults;

//Randall additions

@property (nonatomic, readonly)		UIColor *	appBlueColor;

@property (strong, atomic) NSNumber *selectedMotorFrame;

@property int startPoint1;
@property int endPoint1;
@property int startPoint2;
@property int endPoint2;
@property int startPoint3;
@property int endPoint3;

@property int microstep1;
@property int microstep2;
@property int microstep3;

@property int stopMicrostep1;
@property int stopMicrostep2;
@property int stopMicrostep3;

@property BOOL motor2MicrostepChanged;
@property BOOL motor3MicrostepChanged;

@property BOOL is3P;
@property BOOL midSet;

@property float slide3PVal1;
@property float slide3PVal2;
@property float slide3PVal3;

@property int pan3PVal1;
@property int pan3PVal2;
@property int pan3PVal3;

@property int tilt3PVal1;
@property int tilt3PVal2;
@property int tilt3PVal3;

@property int slideGear;
@property int slideMotor;

@property int panGear;
@property int panMotor;

@property int tiltGear;
@property int tiltMotor;

@property int isHome;

@property int start3PSet;
@property int mid3PSet;
@property int end3PSet;

@property float start3PSlideDistance;
@property float mid3PSlideDistance;
@property float end3PSlideDistance;

@property float start3PPanDistance;
@property float mid3PPanDistance;
@property float end3PPanDistance;

@property float scaledStart3PSlideDistance;
@property float scaledMid3PSlideDistance;
@property float scaledEnd3PSlideDistance;

@property float scaledStart3PPanDistance;
@property float scaledMid3PPanDistance;
@property float scaledEnd3PPanDistance;

@property float scaledStart3PTiltDistance;
@property float scaledMid3PTiltDistance;
@property float scaledEnd3PTiltDistance;

@property float start3PTiltDistance;
@property float mid3PTiltDistance;
@property float end3PTiltDistance;

@property bool slideMicroUpdatedAfter;


@property bool useJoystick;
@property bool isContinuous;

@property float voltageLow;
@property float voltageHigh;
@property float voltage;

#pragma mark Class Management

+ (AppExecutive *) sharedInstance;

#pragma mark Object Management

- (id) init;

#pragma mark Persistence

- (NSString *) nameForDeviceID: (NSString *) deviceName;
- (void) setHandle: (NSString *) handle forDeviceName: (NSString *) deviceName;
- (NSString *) stringWithHandleForDeviceName: (NSString *) deviceName;
- (void) restoreDefaults;
- (NSNumber *) getNumberForKey: (NSString *) key;

#pragma mark Object Operations

- (void) resetFocusTime;
- (void) resetTriggerTime;
- (void) computeDelayTime;
- (void) setPoints;

@end
