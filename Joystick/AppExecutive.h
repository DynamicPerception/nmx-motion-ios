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
#import "JSDeviceSettings.h"

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

// device

@property (strong, atomic)          NMXDevice *           device;
@property (strong, atomic)          NMXDeviceManager *    deviceManager;
@property (nonatomic)               NSUserDefaults *      userDefaults;
@property (nonatomic, readonly)		JSDeviceSettings *    defaults;
@property (strong, atomic)          NSArray<NMXDevice *> *deviceList;

@property BOOL is3P;

///////////////////////

@property bool isContinuous;

@property bool isVideo;

#pragma mark Class Management

+ (AppExecutive *) sharedInstance;

#pragma mark Object Management

- (id) init;

- (void) setActiveDevice: (NMXDevice *)device;
- (JSDeviceSettings *) defaultsForDevice: (NMXDevice *) device;
- (NSArray<NMXDevice *> *) connectedDeviceList;

#pragma mark Persistence

- (NSString *) nameForDeviceID: (NSString *) deviceName;
- (void) setHandle: (NSString *) handle forDeviceName: (NSString *) deviceName;
- (NSString *) stringWithHandleForDeviceName: (NSString *) deviceName;
- (void) restoreDefaults;
- (NSNumber *) getNumberForKey: (NSString *) key;

#pragma mark validation

- (BOOL) validExposureNumber: (NSNumber *) number;
- (BOOL) validDelayNumber: (NSNumber *) number;
- (BOOL) validFocusNumber: (NSNumber *) number;
- (BOOL) validTriggerNumber: (NSNumber *) number;

#pragma mark program delay methods

- (void) setProgramDelayTime: (NSTimeInterval) delay;
- (NSDate *) getDelayTimerStartTime;
- (NSTimeInterval) getProgramDelayTime;
- (NSTimeInterval) getTimeSinceDelayStarted;
- (void) setOriginalProgramDelay: (NSTimeInterval)delay;
- (NSTimeInterval) getOriginalProgramDelay;

#pragma mark batch device comm

- (BOOL) queryMotorFeasibility;
- (void) setProgamSettings: (NMXProgramMode) programMode
              pingPongMode: (BOOL)pingPong
                  duration: (UInt32) durationInMS
                     accel: (UInt32) accelInMS
                       fps: (NMXFPS) fps;




@end
