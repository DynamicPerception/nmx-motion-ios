//
//  NMXDevice.h
//  DP Test
//
//  Created by Dave Koziol on 9/16/14.
//  Copyright (c) 2014 Dynamic Perception. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

@class JSDeviceSettings;

#define kDeviceDisconnectedNotification     @"com.dynamicperception.disconnect"

typedef enum : unsigned char {

    NMXProgramModeSMS = 0,
    NMXProgramModeTimelapse = 1,
    NMXProgramModeVideo = 2
} NMXProgramMode;

// Deprecated
typedef enum : unsigned char {

    _Deprecated_NMXRunStatusStopped = 0,
    _Deprecated_NMXRunStatusPaused =  1,
    _Deprecated_NMXRunStatusRunning = 2,
    _Deprecated_NMXRunStatusDelayTimer = 3,
    _Deprecated_NMXRunStatusKeepAlive = 4,
} _Deprecated_NMXRunStatus;

// Deprecated
typedef enum : unsigned char {

    _Deprecated_NMXKeyFrameRunStatusStopped = 0,
    _Deprecated_NMXKeyFrameRunStatusRunning = 1,
    _Deprecated_NMXKeyFrameRunStatusPaused = 2,
    _Deprecated_NMXKeyFrameRunStatusDelayTimer = 3,
    _Deprecated_NMXKeyFrameRunStatusKeepAlive = 4,
    _Deprecated_NMXKeyFrameRunStatusPingPong = 5,
} _Deprecated_NMXKeyFrameRunStatus;


typedef enum : unsigned char {

    NMXRunStatusUnknown   = 0xFF,
    NMXRunStatusRunning   = 1 << 0,
    NMXRunStatusPaused    = 1 << 1,
    NMXRunStatusKeyframe  = 1 << 2,
    NMXRunStatusDelayTimer= 1 << 3,
    NMXRunStatusKeepAlive = 1 << 4,
    NMXRunStatusPingPong  = 1 << 5,

} NMXRunStatus;


typedef enum : unsigned char {

    NMXFPS30 = 0,
    NMXFPS24 = 1,
    NMXFPS25 = 2
    
} NMXFPS;


@class NMXDevice;

@protocol NMXDeviceDelegate <NSObject>

@required

- (void) didConnect: (NMXDevice *) device;

@optional

- (void) reconnectFailed: (NMXDevice *) device;

@end

@interface NMXDevice : NSObject <CBCentralManagerDelegate, CBPeripheralDelegate>

- (id) initWithPeripheral: (CBPeripheral *) peripheral andCentralManager: (CBCentralManager *) centralManager;
- (void) connect;
- (void) disconnect;

- (void) setDeviceAddress:(unsigned char) address;
- (int) queryDeviceAddress;

- (UInt32) mainQueryStartHere;

- (void) mainDebugLEDToggle;
- (void) mainSetProgramMode: (NMXProgramMode) programMode;
- (void) mainStartPlannedMove;
- (void) mainPausePlannedMove;
- (void) mainStopPlannedMove;
- (void) mainSetJoystickWatchdog: (bool) watchdog;
- (void) mainSetJoystickMode: (bool) joystickMode;
- (void) mainSetAppMode: (bool) appMode;
- (void) mainSetPingPongMode: (bool) pingpongMode;
- (void) mainSendMotorsToStart;
- (void) mainSetStartHere;
- (void) mainSetStopHere;
- (void) mainSetFPS: (NMXFPS) fps;
- (void) mainSetControllerCount: (UInt8) controllerCount;
- (void) mainFlipStartStop;

- (UInt16) mainQueryFirmwareVersion;
- (NMXRunStatus) mainQueryRunStatus;
- (UInt32) mainQueryRunTime;
- (float) mainQueryVoltage;
- (unsigned char) mainQueryProgramPercentComplete;
- (UInt32) mainQueryTotalRunTime;
- (NMXProgramMode) mainQueryProgramMode;
- (bool) mainQueryPingPongMode;
- (NMXFPS) mainQueryFPS;
- (UInt32) mainQueryControllerCount;
- (void) motorEnable: (int) motorNumber;
- (void) motorSet: (int) motorNumber SleepMode: (int) sleepMode;
- (void) motorSet: (int) motorNumber InvertDirection: (bool) invertDirection;
- (void) motorSet: (int) motorNumber Disabled: (bool) inDisabled;
- (void) motorSet: (int) motorNumber SetBacklash: (UInt16) backlash;
- (void) motorSet: (int) motorNumber SetMaxStepRate: (UInt16) maxStepRate;
- (void) motorSet: (int) motorNumber Microstep: (unsigned char) microstep;
- (void) motorSet: (int) motorNumber ContinuousSpeed: (float) speed;
- (void) motorMove: (int) motorNumber Direction: (unsigned char) direction Steps: (UInt32) steps;
- (UInt16) motorQueryBacklash: (int) motorNumber;
- (UInt16) motorQueryMaxStepRate: (int) motorNumber;
- (void) takeUpBacklashKeyFrameProgram;
- (int) motorQueryCurrentPosition: (int) motorNumber;
- (bool) motorQueryRunning: (int) motorNumber;
- (UInt32) motorQueryShotsTotalTravelTime: (int) motorNumber;
- (UInt32) motorQueryLeadInShotsOrTime: (int) motorNumber;
- (UInt32) motorQueryLeadOutShotsOrTime: (int) motorNumber;
- (bool) motorQuerySleep: (int) motorNumber;
- (bool) motorQueryInvertDirection: (int) motorNumber;
- (bool) motorQueryDisabled: (int) motorNumber;
- (void) motorSet:(int)motorNumber ProgramStartPoint: (UInt32) position;
- (void) motorSet:(int)motorNumber ProgramStopPoint: (UInt32) position;
- (void) motorSendToStartPoint: (int) motorNumber;
- (unsigned char) motorAutoSetMicrosteps: (int) motorNumber;
- (bool) motorQueryFeasibility: (int) motorNumber;
- (void) motorSetStartHere: (int) motorNumber;
- (void) motorSetStopHere: (int) motorNumber;
- (void) motorSet:(int)motorNumber SetLeadInShotsOrTime: (UInt32) leadIn;
- (void) motorSet:(int)motorNumber SetLeadOutShotsOrTime: (UInt32) leadOut;
- (void) motorSet:(int)motorNumber SetShotsTotalTravelTime: (UInt32) shots;
- (void) motorSet:(int)motorNumber SetProgramAccel: (UInt32) accel;
- (void) motorSet:(int)motorNumber SetProgramDecel: (UInt32) decel;
- (void) cameraSetEnable: (bool) enabled;
- (void) cameraExposeNow;
- (void) cameraSetTriggerTime: (UInt32) time;
- (void) cameraSetFocusTime: (UInt16) time;
- (void) cameraSetFrames: (UInt16) frames;
- (void) cameraSetExposureDelay: (UInt16) delay;
- (void) cameraSetInterval: (UInt32) interval;
- (void) cameraSetTestMode: (bool) testMode;
- (void) cameraSetSlaveMode: (bool) slaveMode;
- (UInt32) cameraQueryMaxShots;
- (UInt16) cameraQueryCurrentShots;
- (UInt32) cameraQueryInterval;
- (bool) cameraQuerySlaveMode;


- (void) rampingSetEasing: (int)value;
- (void) setDelayProgramStartTimer: (UInt64) timerValue;
- (UInt32) queryDelayTime;
- (void) keepAlive: (bool) value;
- (UInt32) queryProgramStartPoint : (int)motor;
- (UInt32) queryProgramEndPoint : (int)motor;

- (UInt16) motorQueryMicrostep2: (int) motorNumber;

@property (readonly) NSString * name;
@property (atomic, strong) id<NMXDeviceDelegate> delegate;
@property (assign) unsigned char sledMotor;
@property (assign) unsigned char panMotor;
@property (assign) unsigned char tiltMotor;
@property (atomic) unsigned char address;
@property bool inBackground;
@property (readonly) UInt16 fwVersion;
@property (readonly) BOOL fwVersionUpdateAvailable;
@property (readonly) bool disconnected;
@property (atomic) int serviceDiscoveryRetryCount;
@property JSDeviceSettings *settings;

- (void) setHomePosition : (int) motor;

- (void) setCurrentKeyFrameAxis: (UInt16) value;
- (void) setKeyFrameCount: (UInt16) value;
- (void) setKeyFrameAbscissa: (float) value;
- (void) setKeyFramePosition: (float) value;
- (void) setKeyFrameVelocity: (float) value;
- (void) endKeyFrameTransmission;
- (void) startKeyFrameProgram;
- (void) pauseKeyFrameProgram;
- (void) stopKeyFrameProgram;
- (void) setKeyFrameVideoTime: (UInt32) value;

- (UInt32) queryKeyFrameProgramRunState;
- (UInt32) queryKeyFrameProgramCurrentTime;
- (UInt32) queryKeyFrameProgramMaxTime;
- (UInt32) queryKeyFramePercentComplete;
- (bool) queryPowerCycle;
- (void) motorSet: (int) motorNumber ContinuousSpeedAccelDecel: (float) speed;
- (float) motorQueryContinuousAccelDecel: (int) motorNumber;
- (void) motorSet:(int)motorNumber SetMotorPosition: (UInt32) position;
- (void) resetLimits: (int) motorNumber;
- (void) motorSendToEndPoint: (int) motorNumber;

- (void) peripheralWasConnected: (CBPeripheral *) peripheral;

+ (unsigned char) defaultAddress;

@end


