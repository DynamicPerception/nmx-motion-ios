//
//  NMXDevice.m
//  DP Test
//
//  Created by Dave Koziol on 9/16/14.
//  Copyright (c) 2014 Dynamic Perception. All rights reserved.
//

#import <CocoaLumberjack/CocoaLumberjack.h>

#import "NMXDevice.h"
#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "NSNumber+ASI.h"

#define kDefaultsMotorSledMicrosteps   @"MotorSledMicrosteps"
#define kDefaultsMotorPanMicrosteps   @"MotorPanMicrosteps"
#define kDefaultsMotorTiltMicrosteps   @"MotorTiltMicrosteps"
#define kDefaultsMotorSledInvert       @"MotorSledInvert"
#define kDefaultsMotorPanInvert        @"MotorPanInvert"
#define kDefaultsMotorTiltInvert       @"MotorTiltInvert"

#define kCurrentSupportedFirmwareVersion 45


typedef enum : unsigned char {

    NMXCommandMainStartPlannedMove = 2,
    NMXCommandMainPausePlannedMove = 3,
    NMXCommandMainStopPlannedMove = 4,
    NMXCommandMainDebugLEDToggle = 5,
    NMXCommandMainSetJoystickWatchdog = 14,
    NMXCommandMainProgramDelay = 21,
    NMXCommandMainSMSOrContinuousMotorMode = 22,
    NMXCommandMainSetJoystickMode = 23,
    NMXCommandMainSetPingPongMode = 24,
    NMXCommandMainSendMotorsToStart = 25,
    NMXCommandMainSetStartHere = 26,
    NMXCommandMainSetStopHere = 27,
    NMXCommandMainSetFPS = 28,
    NMXCommandMainSetAppMode = 51,
    NMXCommandMainFlipStartStopPoints = 29,
    NMXCommandMainQueryFirmwareVersion = 100,
    NMXCommandMainQueryRunStatus_DEPRECATED = 101,        // deprecated in v. 0.51
    NMXCommandMainQueryRunTime = 102,
    NMXCommandMainQueryVoltage = 107,
    NMXCommandMainQueryDelayTimer = 117,
    NMXCommandMainQuerySMSOrContinuousMotorMode = 118,
    NMXCommandMainQueryPowerCycle = 119,
    NMXCommandMainQueryPingPongMode = 121,
    NMXCommandMainQueryProgramPercentComplete = 123,
    NMXCommandMainQueryTotalRunTime = 125,
    NMXCommandMainQueryFPS = 127,
    NMXCommandMainQueryRunStatus = 140,    // introduced in firmware v. 0.51
    
} NMXCommandMain;


typedef enum : unsigned char {

    NMXCommandMotorSleep = 2,
    NMXCommandMotorEnable = 3,
    NMXCommandMotorSetBacklash = 5,
    NMXCommandMotorSetMicroStep = 6,
    NMXCommandMotorSetContinuousSpeed = 13,
    NMXCommandMotorSetContinuousAccelDecelRate = 14, //Dampening
    NMXCommandMotorMoveSimple = 15,
    NMXCommandMotorSetProgramStartPoint = 16,
    NMXCommandMotorSetProgramStopPoint = 17,
    NMXCommandMotorSetLeadInShotsOrTime = 19,
    NMXCommandMotorSetTravelShotsOrTravelTime = 20,
    NMXCommandMotorSetProgramAccel = 21,
    NMXCommandMotorSetProgramDecel = 22,
    NMXCommandMotorSendToProgramStartPoint = 23,
    NMXCommandMotorSendToProgramEndPoint = 24,
    NMXCommandMotorSetLeadOutShotsOrTime = 25,
    NMXCommandMotorResetLimitsProgramStart = 27,
    NMXCommandMotorAutoSetProgramMicrosteps = 28,
    NMXCommandMotorSetStartHere = 29,
    NMXCommandMotorSetStopHere = 30,
    NMXCommandMotorPosition = 31,
    NMXCommandMotorQueryBacklash = 101,
    NMXCommandMotorMicrostepValue = 102,
    NMXCommandMotorQueryCurrentPosition = 106,
    NMXCommandMotorQueryRunning = 107,
    NMXCommandMotorQueryContinuousAccelDecel = 109,
    NMXCommandMotorQueryTravelShotsOrTravelTime = 113,
    NMXCommandMotorQueryLeadInShotsOrTime = 114,
    NMXCommandMotorQuerySleep = 117,
    NMXCommandMotorQueryLeadOutShotsOrTime = 119
    
} NMXCommandMotor;


typedef enum : unsigned char {

    NMXCommandEasingRampMode = 18,
    NMXCommandProgramStartPoint = 111,
    NMXCommandProgramStopPoint = 112
    
} NMXCommandProgrammedTravel;


typedef enum : unsigned char {

    NMXCommandCameraEnable = 2,
    NMXCommandCameraExposeNow = 3,
    NMXCommandCameraSetTriggerTime = 4,
    NMXCommandCameraSetFocusTime = 5,
    NMXCommandCameraSetFrames = 6,
    NMXCommandCameraSetExposureDelay = 7,
    NMXCommandCameraSetInterval = 10,
    NMXCommandCameraTestMode = 11,
    NMXCommandCameraKeepAlive = 12,
    NMXCommandCameraQueryMaxShots = 104,
    NMXCommandCameraQueryInterval = 108,
    NMXCommandCameraQueryCurrentShots = 109
    
} NMXCommandCamera;


typedef enum: unsigned char {

    NMXMovingLeft = 0,
    NMXMovingRight = 1,
    NMXMovingStopped = 255
    
} NMXMovingDirection;

typedef enum : unsigned char {

    NMXValueTypeByte = 0,
    NMXValueTypeUInt16 = 1,
    NMXValueTypeSInt16 = 2,
    NMXValueTypeSInt32 = 3,
    NMXValueTypeUInt32 = 4,
    NMXValueTypeFloat = 5,
    NMXValueTypeString = 6,
    NMXValueTypeUInt64 = 15
    
} NMXValueType;

typedef enum: unsigned char {

    NMXSetAxis = 10,
    NMXKeyFrameCount = 11,
    NMXKeyFrameAbscissa = 12,
    NMXKeyFramePosition = 13,
    NMXKeyFrameVelocity = 14,
    NMXKeyFrameEndTransmission = 16,
    NMXKeyFrameContinuousVideoTime = 17,
    NMXStartResumeKeyFrameProgram = 20,
    NMXPauseKeyFrameProgram = 21,
    NMXStopKeyFrameProgram = 22,
    NMXQueryKeyFrameProgramRunState_DEPRECATED = 120,   // deprecated in v. 0.51
    NMXQueryKeyFrameCurrentRunTime = 121,
    NMXQueryKeyFrameMaxRunTime = 122,
    NMXQueryKeyFramePercentComplete = 123
    
} NMXKeyFrameMode;


@interface  NMXDevice()
@property (atomic, strong) CBCentralManager *myCBCentralManager;
@property (atomic, strong) CBPeripheral *myPeripheral;
@property (atomic, strong) NSMutableArray *myServices;
@property (atomic, strong) CBCharacteristic *myOutputCharacteristic;
@property (atomic, strong) NSMutableData *myNotifyBuffer;
@property (atomic, strong) NSMutableData *myNotifyData;
@property (assign) CFTimeInterval lastCommandTime;
@property (assign) int retryCount;
@property (assign) bool retrying;
@property (assign) bool disconnected;
@property (assign) float lastTimeout;
@property (atomic, strong) dispatch_semaphore_t mySemaphore;
@property (atomic, strong) NSData *myLastCommand;
@property (atomic, strong) NSTimer *connectionTimer;

@end


@implementation NMXDevice

NMXMovingDirection moving[4];
bool invertDirection[4];
bool disabled[4];
bool waitForResponse;

@synthesize inBackground;

#pragma mark - Bluetooth

- (id) initWithPeripheral: (CBPeripheral *) peripheral andCentralManager: (CBCentralManager *) centralManager; {

    self = [super init];
    
    if (self)
    {
        peripheral.delegate = self;
        
        self.myCBCentralManager = centralManager;
        self.myPeripheral = peripheral;
        self.myServices = [NSMutableArray arrayWithCapacity: 3];
        self.myNotifyBuffer = [NSMutableData dataWithCapacity: 20];
        self.myNotifyData = 0;
        
        moving[0] = NMXMovingStopped;
        moving[1] = NMXMovingStopped;
        moving[2] = NMXMovingStopped;
        moving[3] = NMXMovingStopped;
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        
        invertDirection[0] = false;
        invertDirection[1] = [defaults boolForKey: kDefaultsMotorSledInvert];
        invertDirection[2] = [defaults boolForKey: kDefaultsMotorPanInvert];
        invertDirection[3] = [defaults boolForKey: kDefaultsMotorTiltInvert];
        
        disabled[0] = false;
        disabled[1] = false;
        disabled[2] = false;
        disabled[3] = false;
        
        self.sledMotor = 1;
        self.panMotor = 2;
        self.tiltMotor = 3;
        self.lastCommandTime = 0;
        self.lastTimeout = 0.0;
        self.retryCount = 0;
        self.retrying = false;
        self.disconnected = true;
        
        waitForResponse = true;
        
        self.serviceDiscoveryRetryCount = 3;
    }
    
    return self;
}

- (NSString *) name {

    return self.myPeripheral.name;
}

- (void) centralManagerDidUpdateState: (CBCentralManager *) central {

    DDLogDebug(@"centralManagerState = %d", (int)central.state);
}

- (void) peripheral: (CBPeripheral *) peripheral didDiscoverServices: (NSError *) error {

    for (CBService *service in peripheral.services)
    {
        //DDLogDebug(@"Discovered service %@ with UDID %@", service, service.UUID);
        
        [peripheral discoverCharacteristics: nil forService: service];
        [self.myServices addObject: service];
    }
}

#pragma mark device connection

- (void) peripheral: (CBPeripheral *) peripheral
didDiscoverCharacteristicsForService: (CBService *) service
              error: (NSError *) error {

    for (CBCharacteristic *characteristic in service.characteristics)
    {
        //DDLogDebug(@"Discovered characteristic %@ of service %@", characteristic, service);
        
        if (characteristic.properties & CBCharacteristicPropertyNotify)
        {
            [peripheral setNotifyValue: true forCharacteristic: characteristic];
        }
        if ([characteristic.UUID isEqual: [CBUUID UUIDWithString:@"BF45E40A-DE2A-4BC8-BBA0-E5D6065F1B4B"]])
        {
            self.myOutputCharacteristic = characteristic;
            if (self.delegate)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    [self abortConnectionRetry];
                    
                    self.myNotifyBuffer = [NSMutableData dataWithCapacity: 20];
                    self.myNotifyData = 0;
                    self.lastCommandTime = 0;
                    self.lastTimeout = 0.0;
                    self.retryCount = 0;
                    self.retrying = false;
                    self.disconnected = false;
                    waitForResponse = false;

                    [self initFirmware];

                    [self.delegate didConnect: self];
                });
            }
        }
    }
}

- (void) initFirmware
{
    [self mainSetAppMode: true];
    [self mainSetJoystickMode: false];
    
    _fwVersion = [self mainQueryFirmwareVersion];
    if (_fwVersion < kCurrentSupportedFirmwareVersion ) _fwVersionUpdateAvailable = YES;
}

- (void) peripheral: (CBPeripheral *) peripheral
didUpdateValueForCharacteristic: (CBCharacteristic *) characteristic
              error: (NSError *) error {

    [self.myNotifyBuffer appendData: characteristic.value];
    
    if ([self.myNotifyBuffer length] > 9)
    {
        //NSLog(@"self.myNotifyBuffer: %@",self.myNotifyBuffer);
        
        unsigned char length = ((unsigned char *)self.myNotifyBuffer.bytes)[9];
        
        if ([self.myNotifyBuffer length] >= 10 + length)
        {
            if (length > 0)
            {
                //DDLogDebug(@"Response received: %@", self.myNotifyBuffer); randall 8-17-15
            }
            else
            {
                //DDLogDebug(@"Empty Length Response"); randall 8-17-15
            }
            
            dispatch_semaphore_signal(self.mySemaphore);
            
            self.myNotifyData = self.myNotifyBuffer;
            
            //NSLog(@"self.myNotifyData: %@",self.myNotifyData);
            
            self.myNotifyBuffer = [NSMutableData dataWithCapacity: 20];
        }
    }
}

// Bug workaround: sometimes we never get a callback after the attempt to discover services for the device.
// Disconnect and reconnect if we don't get a response after a specific amount of time.
- (void) retryServiceDiscoveryForPeripheral:(CBPeripheral *) peripheral
{
    if (self.disconnected == NO) return;
 
    dispatch_async(dispatch_get_main_queue(), ^{

        self.connectionTimer = [NSTimer scheduledTimerWithTimeInterval:3.0
                                                                target:self
                                                              selector:@selector(retryConnect)
                                                              userInfo:nil
                                                               repeats:YES];
    });
}

- (void) abortConnectionRetry
{
    [self.connectionTimer invalidate];
    self.connectionTimer = nil;
}


- (void) retryConnect
{
    if (self.serviceDiscoveryRetryCount <= 0)
    {
        DDLogDebug(@"Cannot connect to device, bailing out");
        [self abortConnectionRetry];
        return;
    }
    else if (NO == self.disconnected)
    {
        [self abortConnectionRetry];
        return;
    }
    
    // Something went wrong, we never discovered the services, retry.
    self.serviceDiscoveryRetryCount -= 1;
    DDLogDebug(@"Failed to discover services, retrying");
        
    [self disconnect];
        
    NSTimeInterval delaySeconds = .5;
    dispatch_time_t delay = dispatch_time(DISPATCH_TIME_NOW, delaySeconds*NSEC_PER_SEC);
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0);

    dispatch_after(delay,queue, ^{
        [self connect];
    });

}

- (void) peripheralWasConnected: (CBPeripheral *) peripheral
{
    NSLog(@"Delegate .... peripheral Was connected");
    
    [self abortConnectionRetry];
    [self retryServiceDiscoveryForPeripheral:peripheral];
}

- (void) connect {

    DDLogDebug(@"state = %d", (int)self.myCBCentralManager.state);
    self.myPeripheral.delegate = self;
    [self.myCBCentralManager connectPeripheral: self.myPeripheral options: nil];

    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(deviceDisconnect:)
                                                 name: kDeviceDisconnectedNotification
                                               object: nil];
}

- (void) disconnect
{
    [self.myCBCentralManager cancelPeripheralConnection: self.myPeripheral];
    [[NSNotificationCenter defaultCenter] postNotificationName: kDeviceDisconnectedNotification object: nil];
}

// Handle notification that the device was disconnected
- (void) deviceDisconnect: (id) object {

    DDLogDebug(@"Device disconnected NMXDevice");
    
    self.disconnected = true;
    [[NSNotificationCenter defaultCenter] removeObserver: self];
}

#pragma mark - Buffer

- (void) setupBuffer: (unsigned char *) buffer subAddress: (unsigned char) subAddress command: (unsigned char) command dataLength: (unsigned char) dataLength {
    
    buffer[0] = 0;
    buffer[1] = 0;
    buffer[2] = 0;
    buffer[3] = 0;
    buffer[4] = 0;
    buffer[5] = 255;
    buffer[6] = 3;                    // Address 1
    buffer[7] = subAddress;
    buffer[8] = command;
    buffer[9] = dataLength;
}

- (void) setupBuffer2: (char *) buffer subAddress: (unsigned char) subAddress command: (unsigned char) command dataLength: (unsigned char) dataLength {
    
    buffer[0] = 0;
    buffer[1] = 0;
    buffer[2] = 0;
    buffer[3] = 0;
    buffer[4] = 0;
    buffer[5] = 255;
    buffer[6] = 3;                    // Address 1
    buffer[7] = subAddress;
    buffer[8] = command;
    buffer[9] = dataLength;
}

- (void) sendCommand: (NSData *) commandData WithDesc: (NSString *) desc WaitForResponse: (bool) inWaitForResponse WithTimeout: (float) inTimeout {
    
    if (true == self.disconnected)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName: kDeviceDisconnectedNotification object: nil];
        return;
    }
    
    if (false == waitForResponse)
    {
        CFTimeInterval now = CACurrentMediaTime();

        if ((now - self.lastCommandTime) < self.lastTimeout)
        {
            useconds_t sleepTime = (self.lastCommandTime - now + self.lastTimeout) * 1000000;
            usleep(sleepTime);
        }
    }
    else
    {
        [self waitForResponse];
    }
    
    if (inWaitForResponse)
    {
        if (waitForResponse)
        {
             DDLogDebug(@"Waited for response and sending command %@ expect response", desc); //randall 8-17-15
            
            if ([desc containsString:@"Set KeyFrame Position"]) {
                
                desc = [desc stringByReplacingOccurrencesOfString:@"Set KeyFrame Position " withString:@""];
                
                [[NSNotificationCenter defaultCenter] postNotificationName: @"debugKeyframePosition" object: [NSNumber numberWithFloat:[desc floatValue]]];
            }
        }
        else
        {
            DDLogDebug(@"Delayed for response and sending command %@ expect response", desc); //randall 10-20-15
        }
        
        // Be recreating the semaphore we will wait on with each send, we hope to be able to catch back up if we get double responses after a timeout.
        
        self.mySemaphore = dispatch_semaphore_create(0);
    }
    else
    {
        if (waitForResponse)
        {
            DDLogDebug(@"Waited for response and sending command %@ no response expected", desc); //randall 8-17-15
        }
        else
        {
            DDLogDebug(@"Delayed for response and sending command %@ no response expected", desc); //randall 10-20-15
        }
    }
    
    waitForResponse = inWaitForResponse;
    
    //DDLogDebug(@"Sending Command %@ with data %@", desc, commandData); //randall 8-17-15
    
    [self.myPeripheral writeValue: commandData forCharacteristic: self.myOutputCharacteristic type: CBCharacteristicWriteWithResponse];
    
    self.lastCommandTime = CACurrentMediaTime();
    self.myLastCommand = commandData;
    self.lastTimeout = inTimeout;
    
    if (!self.retrying)
    {
        self.retryCount = 0;
    }
    else
    {
        self.retryCount++;
        
        NSLog(@"retryCount: %i",self.retryCount);
    }
}

- (bool) waitForResponse {
    
    long semaphoreResult;
    
    @try
    {
        if((semaphoreResult = dispatch_semaphore_wait(self.mySemaphore, DISPATCH_TIME_NOW)))
        {
            while ((semaphoreResult = dispatch_semaphore_wait(self.mySemaphore, DISPATCH_TIME_NOW)))
            {
                //NSLog(@"semaphoreResult: %li",semaphoreResult);
                
                //NSLog(@"self.mySemaphore: %@",self.mySemaphore);
                
                CFTimeInterval now = CACurrentMediaTime();
                
                if ((now - self.lastCommandTime) < self.lastTimeout)
                {
                    usleep(10000);
                }
                else if (self.retryCount < 10)
                {
                    bool nestedRetry = self.retrying;
                    
                    // We need to retry
                    
                    if (waitForResponse)
                    {
                        dispatch_semaphore_signal(self.mySemaphore);
                    }
                    
                    self.retrying = true;
                    
                    [self sendCommand: self.myLastCommand WithDesc: @"Retrying last command" WaitForResponse: waitForResponse WithTimeout: self.lastTimeout];
                    
                    self.retrying = nestedRetry;
                }
                else// if(!inBackground)
                {
                    DDLogDebug(@"Disconnecting because of too many timeouts");
                    
                    if(!inBackground)
                    {
                        [self.myCBCentralManager cancelPeripheralConnection: self.myPeripheral];
                        
                        // Send the user back to the connection screen...
                        
                        [[NSNotificationCenter defaultCenter] postNotificationName: kDeviceDisconnectedNotification object: nil];
                    }
                    
                    break;
                }
            }
            
        }
        
        if ((self.myNotifyData) && ([self.myNotifyData length] > 8) && (0 == semaphoreResult))
        {
            // Try to look at success flag.
            
            unsigned char error;
            
            memcpy(&error, &self.myNotifyData.bytes[8], sizeof(error));
            
            if (1 != error)
            {
                DDLogError(@"Bad response %@, last command was %@", self.myNotifyData, self.myLastCommand);
                
                //            dispatch_async(dispatch_get_main_queue(), ^{
                //
                //                [[NSNotificationCenter defaultCenter] postNotificationName: kDeviceDisconnectedNotification object: nil];
                //            });
                
                
                
                
                dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName: kDeviceDisconnectedNotification object: nil];
                });
                
                
                
//                @try
//                {
//                    waitForResponse = false;
//                    
//                    [self sendCommand: self.myLastCommand WithDesc: @"Retrying last command" WaitForResponse: true WithTimeout: self.lastTimeout];
//                    
//                    [self waitForResponse];
//                    
//                }
//                @catch (NSException *exception)
//                {
//                    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//                        
//                        [[NSNotificationCenter defaultCenter] postNotificationName: kDeviceDisconnectedNotification object: nil];
//                    });
//                }
//                @finally {}
            }
        }        
    }
    @catch (NSException *exception)
    {
        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            [[NSNotificationCenter defaultCenter] postNotificationName: kDeviceDisconnectedNotification object: nil];
        });
    }
    
    
    return (0 == semaphoreResult);
}

- (NSNumber *) extractReturnedNumberWithValueType: (NMXValueType) inValueType {
    
    NMXValueType    receivedValueType;
    memcpy(&receivedValueType, &self.myNotifyData.bytes[10], sizeof(receivedValueType));
    
    if (receivedValueType == inValueType)
        return [self extractReturnedNumber];
    return nil;
}

- (NSNumber *) extractReturnedNumber {
    
    NMXValueType valueType;
    NSNumber * returnedNumber;
    
    //NSLog(@"myNotifyData.bytes: %@",&self.myNotifyData.bytes[10]);
    
//    NSLog(@"sizeof(valueType): %lu",sizeof(valueType));
//    NSLog(@"valueType: %c",&valueType);
    
    if (self.myNotifyData.length != 0) {
        
         memcpy(&valueType, &self.myNotifyData.bytes[10], sizeof(valueType));
        
        //    @try {
        //
        //        memcpy(&valueType, &self.myNotifyData.bytes[10], sizeof(valueType));
        //    }
        //    @catch (NSException * e) {
        //
        //        NSLog(@"memcpy Exception: %@", e);
        //
        //        dispatch_async(dispatch_get_main_queue(), ^(void) {
        //
        //            [[NSNotificationCenter defaultCenter] postNotificationName: kDeviceDisconnectedNotification object: @"Peripheral disconnected Randall memcpy"];
        //        });
        //
        //    }
        
        
        
        switch (valueType)
        {
            case NMXValueTypeByte:
            {
                UInt8 byteValue;
                
                memcpy(&byteValue, &self.myNotifyData.bytes[11], sizeof(valueType));
                returnedNumber = [NSNumber numberWithUInt8: byteValue];
                break;
            }
            case NMXValueTypeUInt16:
            {
                UInt16  unsignedIntValue;
                memcpy(&unsignedIntValue, &self.myNotifyData.bytes[11], sizeof(unsignedIntValue));
                unsignedIntValue = CFSwapInt16(unsignedIntValue);
                returnedNumber = [NSNumber numberWithUInt16: unsignedIntValue];
                break;
            }
            case NMXValueTypeSInt16:
            {
                SInt16  intValue;
                memcpy(&intValue, &self.myNotifyData.bytes[11], sizeof(intValue));
                intValue = CFSwapInt16(intValue);
                returnedNumber = [NSNumber numberWithSInt16: intValue];
                break;
            }
            case NMXValueTypeUInt32:
            {
                UInt32  unsignedlongValue;
                memcpy(&unsignedlongValue, &self.myNotifyData.bytes[11], sizeof(unsignedlongValue));
                unsignedlongValue = CFSwapInt32(unsignedlongValue);
                returnedNumber = [NSNumber numberWithUInt32: unsignedlongValue];
                break;
            }
            case NMXValueTypeSInt32:
            {
                SInt32  longValue;
                memcpy(&longValue, &self.myNotifyData.bytes[11], sizeof(longValue));
                longValue = CFSwapInt32(longValue);
                returnedNumber = [NSNumber numberWithSInt32: longValue];
                break;
            }
            case NMXValueTypeFloat:
            {
                UInt32  unsignedlongValue;
                memcpy(&unsignedlongValue, &self.myNotifyData.bytes[11], sizeof(unsignedlongValue));
                unsignedlongValue = CFSwapInt32(unsignedlongValue);
                float   floatValue = unsignedlongValue / 100.0;
                returnedNumber = [NSNumber numberWithFloat: floatValue];
            }
                break;
            default:
                DDLogError(@"ERROR: Camera returned a value Type we don't currently support in extractNumber!!!");
                returnedNumber = nil;
                break;
        }
        dispatch_semaphore_signal(self.mySemaphore);
        return returnedNumber;
    }
    else
    {
        NSLog(@"self.myNotifyData.bytes: %lu",(unsigned long)self.myNotifyData.length);
        
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            
            //[[NSNotificationCenter defaultCenter] postNotificationName: kDeviceDisconnectedNotification object: @"Peripheral disconnected Randall memcpy"];
        });
        
        return [NSNumber numberWithFloat: 99];

    }
}

#pragma mark - Main Set

- (BOOL) checkFWMinRequiredVersion: (UInt16) minVersionRequiredForCommand {
    return self.fwVersion >= minVersionRequiredForCommand;
}

- (void) mainDebugLEDToggle {
    unsigned char newDataBytes[16];
    [self setupBuffer: newDataBytes subAddress: 0 command: NMXCommandMainDebugLEDToggle dataLength: 0];
    NSData *newData = [NSData dataWithBytes: newDataBytes length: 10];
    [self sendCommand: newData WithDesc: @"LEDToggle" WaitForResponse: true WithTimeout: 0.2];
}

- (void) mainSetProgramMode: (NMXProgramMode) programMode {
    
    unsigned char newDataBytes[16];
    [self setupBuffer: newDataBytes subAddress: 0 command: NMXCommandMainSMSOrContinuousMotorMode dataLength: 1];
    newDataBytes[10] = programMode;
    NSData *newData = [NSData dataWithBytes: newDataBytes length: 11];
    NSString * descString = [NSString stringWithFormat: @"Set SMS/ContinuousMode %d", newDataBytes[10]];
    [self sendCommand: newData WithDesc: descString WaitForResponse: true WithTimeout: 0.2];
}

- (void) mainStartPlannedMove {
    
    unsigned char newDataBytes[16];
    
    [self setupBuffer: newDataBytes subAddress: 0 command: NMXCommandMainStartPlannedMove dataLength: 0];
    
    NSData *newData = [NSData dataWithBytes: newDataBytes length: 10];
    
    [self sendCommand: newData WithDesc: @"Start Planned Move" WaitForResponse: true WithTimeout: 3.0];
    
    //changed timeout to 3 randall
}

- (void) mainPausePlannedMove {
    unsigned char newDataBytes[16];
    [self setupBuffer: newDataBytes subAddress: 0 command: NMXCommandMainPausePlannedMove dataLength: 0];
    NSData *newData = [NSData dataWithBytes: newDataBytes length: 10];
    [self sendCommand: newData WithDesc: @"Pause Planned Move" WaitForResponse: true WithTimeout: 0.2];
}

- (void) mainStopPlannedMove {
    
    unsigned char newDataBytes[16];
    [self setupBuffer: newDataBytes subAddress: 0 command: NMXCommandMainStopPlannedMove dataLength: 0];
    NSData *newData = [NSData dataWithBytes: newDataBytes length: 10];
    [self sendCommand: newData WithDesc: @"Stop Planned Move" WaitForResponse: true WithTimeout: 0.2];
}

- (void) mainSetJoystickWatchdog: (bool) watchdog {
    
    unsigned char newDataBytes[16];
    [self setupBuffer: newDataBytes subAddress: 0 command: NMXCommandMainSetJoystickWatchdog dataLength: 1];
    newDataBytes[10] = watchdog;
    NSData *newData = [NSData dataWithBytes: newDataBytes length: 11];
    
    [self sendCommand: newData WithDesc: @"Set Joystick Watchdog" WaitForResponse: true WithTimeout: 0.2];
}

- (void) mainSetJoystickMode: (bool) joystickMode {
    
    unsigned char newDataBytes[16];
    
    [self setupBuffer: newDataBytes subAddress: 0 command: NMXCommandMainSetJoystickMode dataLength: 1];
    newDataBytes[10] = joystickMode;
    
    NSData *newData = [NSData dataWithBytes: newDataBytes length: 11];
    NSString * description;
    
    if (joystickMode)
        description = @"Set Joystick Mode True";
    else
        description = @"Set Joystick Mode False";
    
    [self sendCommand: newData WithDesc: description WaitForResponse: true WithTimeout: 0.2];
}

- (void) mainSetAppMode: (bool) appMode {
    
    unsigned char newDataBytes[16];
    [self setupBuffer: newDataBytes subAddress: 0 command: NMXCommandMainSetAppMode dataLength: 1];
    newDataBytes[10] = appMode;
    NSData *newData = [NSData dataWithBytes: newDataBytes length: 11];
    NSString * description;
    
    if (appMode)
        description = @"Set App Mode True";
    else
        description = @"Set App Mode False";
    [self sendCommand: newData WithDesc: description WaitForResponse: false WithTimeout: 0.2];
}

- (void) mainSetPingPongMode: (bool) pingpongMode {
    
    unsigned char newDataBytes[16];
    [self setupBuffer: newDataBytes subAddress: 0 command: NMXCommandMainSetPingPongMode dataLength: 1];
    newDataBytes[10] = pingpongMode;
    NSData *newData = [NSData dataWithBytes: newDataBytes length: 11];
    [self sendCommand: newData WithDesc: @"Set Ping Pong Mode" WaitForResponse: true WithTimeout: 0.2];
}


- (void) mainSendMotorsToStart {
    
    unsigned char newDataBytes[16];
    [self setupBuffer: newDataBytes subAddress: 0 command: NMXCommandMainSendMotorsToStart dataLength: 0];
    NSData *newData = [NSData dataWithBytes: newDataBytes length: 10];
    [self sendCommand: newData WithDesc: @"Send Motors To Start Point" WaitForResponse: true WithTimeout: 0.2];
}

- (unsigned char) motorAutoSetMicrosteps: (int) motorNumber {

    unsigned char   microsteps;
    unsigned char   newDataBytes[16];
    [self setupBuffer: newDataBytes subAddress: motorNumber command: NMXCommandMotorAutoSetProgramMicrosteps dataLength: 0];
    NSData *newData = [NSData dataWithBytes: newDataBytes length: 10];
    
    [self sendCommand: newData WithDesc: @"Motor Auto Set Microsteps" WaitForResponse: true WithTimeout: 3.0];
    
    if ([self waitForResponse])
    {
        memcpy(&microsteps, &self.myNotifyData.bytes[11], sizeof(microsteps));
        dispatch_semaphore_signal(self.mySemaphore);
        DDLogDebug(@"Got a microsteps of %d", (int)microsteps);
    }
    
    return microsteps;
}

- (void) mainSetStartHere {
    
    unsigned char newDataBytes[16];
    [self setupBuffer: newDataBytes subAddress: 0 command: NMXCommandMainSetStartHere dataLength: 0];
    NSData *newData = [NSData dataWithBytes: newDataBytes length: 10];
    [self sendCommand: newData WithDesc: @"Set Motors Start Point Here" WaitForResponse: true WithTimeout: 0.2];
}

- (void) mainSetStopHere {
    
    unsigned char newDataBytes[16];
    [self setupBuffer: newDataBytes subAddress: 0 command: NMXCommandMainSetStopHere dataLength: 0];
    NSData *newData = [NSData dataWithBytes: newDataBytes length: 10];
    [self sendCommand: newData WithDesc: @"Set Motors Stop Point Here" WaitForResponse: true WithTimeout: 0.2];
}

- (void) mainSetFPS: (NMXFPS) fps {
    
    unsigned char newDataBytes[16];
    [self setupBuffer: newDataBytes subAddress: 0 command: NMXCommandMainSetFPS dataLength: 1];
    newDataBytes[10] = fps;
    NSData *newData = [NSData dataWithBytes: newDataBytes length: 11];
    [self sendCommand: newData WithDesc: @"Set FPS" WaitForResponse: true WithTimeout: 0.2];
}

- (void) mainFlipStartStop {
    
    unsigned char newDataBytes[16];
    [self setupBuffer: newDataBytes subAddress: 0 command: NMXCommandMainFlipStartStopPoints dataLength: 0];
    NSData *newData = [NSData dataWithBytes: newDataBytes length: 10];
    [self sendCommand: newData WithDesc: @"Set Motors Flip Start Stop Points" WaitForResponse: true WithTimeout: 0.2];
}

#pragma mark - Main Query

- (UInt16) mainQueryFirmwareVersion {
    
    UInt16    fwVerison;
    unsigned char   newDataBytes[16];
    [self setupBuffer: newDataBytes subAddress: 0 command: NMXCommandMainQueryFirmwareVersion dataLength: 0];
    NSData *newData = [NSData dataWithBytes: newDataBytes length: 10];
    
    [self sendCommand: newData WithDesc: @"Query Firmware Version" WaitForResponse: true WithTimeout: 0.2];
    
    if ([self waitForResponse])
    {
        NSLog(@"mainQueryFirmwareVersion Waiting for version");
        fwVerison = [[self extractReturnedNumber] UInt16Value];
    }

    NSLog(@"mainQueryFirmwareVersion = %i", fwVerison);
    return fwVerison;
}


- (NMXRunStatus) runStatusFromOldRunStatus:(_Deprecated_NMXRunStatus) runStatus
{
    NMXRunStatus newStatus;
    switch (runStatus)
    {
        case _Deprecated_NMXRunStatusStopped :
            newStatus = NMXRunStatusStopped;
            break;
        case _Deprecated_NMXRunStatusPaused :
            newStatus = NMXRunStatusPaused;
            break;
        case  _Deprecated_NMXRunStatusRunning:
            newStatus = NMXRunStatusRunning;
            break;
        case _Deprecated_NMXRunStatusDelayTimer:
            newStatus = NMXRunStatusDelayTimer;
            break;
        case _Deprecated_NMXRunStatusKeepAlive:
            newStatus = NMXRunStatusKeepAlive;
            break;
        default:
            newStatus = 99;
            break;
    }
    
    return newStatus;
}

- (NMXRunStatus) runStatusFromOldKeyframRunStatus:(_Deprecated_NMXKeyFrameRunStatus) runStatus
{
    
    NMXRunStatus newStatus;
    switch (runStatus)
    {
        case _Deprecated_NMXKeyFrameRunStatusStopped :
            newStatus = NMXRunStatusStopped;
            break;
        case _Deprecated_NMXKeyFrameRunStatusPaused :
            newStatus = NMXRunStatusPaused;
            break;
        case  _Deprecated_NMXKeyFrameRunStatusRunning:
            newStatus = NMXRunStatusRunning;
            break;
        case _Deprecated_NMXKeyFrameRunStatusDelayTimer:
            newStatus = NMXRunStatusDelayTimer;
            break;
        case _Deprecated_NMXKeyFrameRunStatusKeepAlive:
            newStatus = NMXRunStatusKeepAlive;
            break;
        case _Deprecated_NMXKeyFrameRunStatusPingPong:
            newStatus = NMXRunStatusPingPong;
            break;
        default:
            newStatus = 99;
            break;
    }
    
    return newStatus;
}


- (NSString*) bitString:(unsigned char) mask{
    NSString *str = @"";
    for (NSUInteger i = 0; i < 8 ; i++) {
        // Prepend "0" or "1", depending on the bit
        str = [NSString stringWithFormat:@"%@%@",
               mask & 1 ? @"1" : @"0", str];
        mask >>= 1;
    }
    return str;
}

- (NMXRunStatus) mainQueryRunStatus {
    
    unsigned char command = NMXCommandMainQueryRunStatus;
    
    BOOL oldFirmwareForRunStatus = NO;
    if (_fwVersion < 51 )
    {
        oldFirmwareForRunStatus = YES;
        command = NMXCommandMainQueryRunStatus_DEPRECATED;
    }
    
    NMXRunStatus    runStatus;
    unsigned char   newDataBytes[16];
    [self setupBuffer: newDataBytes subAddress: 0 command: command dataLength: 0];
    
    NSData *newData = [NSData dataWithBytes: newDataBytes length: 10];
    
    [self sendCommand: newData WithDesc: @"Query Run Status" WaitForResponse: true WithTimeout: 0.3];
    
    if ([self waitForResponse])
    {
        @try {
    
            //NSLog(@"try runstatus");
            
            runStatus = [[self extractReturnedNumber] UInt8Value];
            
            if (oldFirmwareForRunStatus)
            {
                runStatus = [self runStatusFromOldRunStatus:(_Deprecated_NMXRunStatus)runStatus];
            }

            //NSLog(@"runStatus: %i",runStatus);
        }
        @catch (NSException * e) {
    
            NSLog(@"na. memcpy Exception: %@", e);
        }
    }
    
    NSString *bin = [self bitString:runStatus];
    NSLog(@"*********     Run Status = %@", bin);
    
    return runStatus;
}

- (UInt32) mainQueryRunTime {
    
    static UInt32   lastRunTime = 0;       // We always want to have a value even if we get disconnected for this.
    
    UInt32    runTime = lastRunTime;
    unsigned char newDataBytes[16];
    [self setupBuffer: newDataBytes subAddress: 0 command: NMXCommandMainQueryRunTime dataLength: 0];
    NSData *newData = [NSData dataWithBytes: newDataBytes length: 10];
    
    [self sendCommand: newData WithDesc: @"Query Run Time" WaitForResponse: true WithTimeout: 0.3];
    
    if ([self waitForResponse])
    {
        NSNumber * runTimeNumber = [self extractReturnedNumberWithValueType: NMXValueTypeUInt32];
        
        if (runTimeNumber)
            lastRunTime = runTime = [runTimeNumber UInt32Value];
    }
    
    return runTime;
}

- (float) mainQueryVoltage {
    
    float    voltage;
    unsigned char newDataBytes[16];
    [self setupBuffer: newDataBytes subAddress: 0 command: NMXCommandMainQueryVoltage dataLength: 0];
    NSData *newData = [NSData dataWithBytes: newDataBytes length: 10];
    
    [self sendCommand: newData WithDesc: @"Query Voltage" WaitForResponse: true WithTimeout: 0.2];
    
    if ([self waitForResponse])
    {
        voltage = [[self extractReturnedNumber] floatValue] / 100;
    }
    
    return voltage;
}

- (NMXProgramMode) mainQueryProgramMode {
    
    NMXProgramMode    programMode;
    unsigned char   newDataBytes[16];
    
    [self setupBuffer: newDataBytes subAddress: 0 command: NMXCommandMainQuerySMSOrContinuousMotorMode dataLength: 0];
    NSData *newData = [NSData dataWithBytes: newDataBytes length: 10];
    
    [self sendCommand: newData WithDesc: @"Query Program Mode" WaitForResponse: true WithTimeout: 0.3];
    
    if ([self waitForResponse])
    {
        programMode = [[self extractReturnedNumber] UInt8Value];
    }
    
    return programMode;
}

- (bool) mainQueryPingPongMode {
    
    unsigned char   pingPongMode;
    unsigned char   newDataBytes[16];
    [self setupBuffer: newDataBytes subAddress: 0 command: NMXCommandMainQueryPingPongMode dataLength: 0];
    NSData *newData = [NSData dataWithBytes: newDataBytes length: 10];
    
    [self sendCommand: newData WithDesc: @"Query Ping Pong Mode" WaitForResponse: true WithTimeout: 0.2];
    
    if ([self waitForResponse])
    {
        pingPongMode = [[self extractReturnedNumber] UInt8Value];
    }
    
    return pingPongMode;
}

- (unsigned char) mainQueryProgramPercentComplete {
    
    static unsigned char lastPercent = 0;       // We always want to have a value even if we get disconnected for this.
    unsigned char   percent;
    unsigned char   newDataBytes[16];
    [self setupBuffer: newDataBytes subAddress: 0 command: NMXCommandMainQueryProgramPercentComplete dataLength: 0];
    NSData *newData = [NSData dataWithBytes: newDataBytes length: 10];
    
    [self sendCommand: newData WithDesc: @"Query Percent Complete" WaitForResponse: true WithTimeout: 0.3];
    
    if ([self waitForResponse])
    {
        NSNumber * percentNumber = [self extractReturnedNumberWithValueType: NMXValueTypeByte];
        if (percentNumber)
            lastPercent = percent = [percentNumber UInt8Value];
    }
    
    return percent;
}

- (UInt32) mainQueryTotalRunTime {
    
    UInt32    runTime;
    unsigned char newDataBytes[16];
    [self setupBuffer: newDataBytes subAddress: 0 command: NMXCommandMainQueryTotalRunTime dataLength: 0];
    NSData *newData = [NSData dataWithBytes: newDataBytes length: 10];
    
    [self sendCommand: newData WithDesc: @"Query Total Run Time" WaitForResponse: true WithTimeout: 0.2];
    
    if ([self waitForResponse])
    {
        runTime = [[self extractReturnedNumber] UInt32Value];
    }
    
    return runTime;
}

- (NMXFPS) mainQueryFPS {
    
    //mm -- FIXME  -- this was using NMXCommandMainQueryRunStatus BUG!  Confirming from Michael the correct return value
    NMXFPS          fps;
    unsigned char   newDataBytes[16];
    [self setupBuffer: newDataBytes subAddress: 0 command: NMXCommandMainQueryFPS dataLength: 0];
    NSData *newData = [NSData dataWithBytes: newDataBytes length: 10];
    
    [self sendCommand: newData WithDesc: @"Query FPS" WaitForResponse: true WithTimeout: 0.2];
    
    if ([self waitForResponse])
    {
        fps = [[self extractReturnedNumber] UInt8Value];
    }
    
    return fps;
}

- (UInt32) mainQueryStartHere {
    
    UInt32    runTime;
    
    unsigned char newDataBytes[16];
    [self setupBuffer: newDataBytes subAddress: 0 command: NMXCommandMainSetStartHere dataLength: 0];
    NSData *newData = [NSData dataWithBytes: newDataBytes length: 10];
    [self sendCommand: newData WithDesc: @"Query Motors Start Point Here" WaitForResponse: true WithTimeout: 0.2];
    
    if ([self waitForResponse])
    {
        runTime = [[self extractReturnedNumber] UInt32Value];
        
        NSLog(@"queryStartHere response: %i",[self waitForResponse]);
    }
    
    return  runTime;
}

#pragma mark - Motor Set

- (void) motorEnable: (int) motorNumber {

    unsigned char newDataBytes[16];
    [self setupBuffer: newDataBytes subAddress: motorNumber command: NMXCommandMotorEnable dataLength: 1];
    newDataBytes[10] = 1;                   // Enabled
    NSData *newData = [NSData dataWithBytes: newDataBytes length: 11];
    [self sendCommand: newData WithDesc: @"Enable Motor" WaitForResponse: true WithTimeout: 0.2];
}

- (void) motorSet: (int) motorNumber SleepMode: (int) sleepMode {
    
    unsigned char newDataBytes[16];
    [self setupBuffer: newDataBytes subAddress: motorNumber command: NMXCommandMotorSleep dataLength: 1];
    newDataBytes[10] = sleepMode;
    NSData *newData = [NSData dataWithBytes: newDataBytes length: 11];
    [self sendCommand: newData WithDesc: @"Set Sleep Mode" WaitForResponse: true WithTimeout: 0.2];
}

- (void) motorSet: (int) motorNumber InvertDirection: (bool) inInvertDirection {
    
    invertDirection[motorNumber] = inInvertDirection;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    switch (motorNumber)
    {
        case 1:
            [defaults setBool: inInvertDirection forKey: kDefaultsMotorSledInvert];
            break;
        case 2:
            [defaults setBool: inInvertDirection forKey: kDefaultsMotorPanInvert];
            break;
        case 3:
            [defaults setBool: inInvertDirection forKey: kDefaultsMotorTiltInvert];
            break;
    }
    [defaults synchronize];
}

- (void) motorSet: (int) motorNumber Disabled: (bool) inDisabled {
    
    disabled[motorNumber] = inDisabled;
}

- (void) motorSet: (int) motorNumber SetBacklash: (UInt16) backlash {
    
    unsigned char newDataBytes[16];
    [self setupBuffer: newDataBytes subAddress: motorNumber command: NMXCommandCameraSetFocusTime dataLength: 2];
    unsigned char * backlashPtr = (unsigned char *)&backlash;
    newDataBytes[10] = backlashPtr[1];
    newDataBytes[11] = backlashPtr[0];
    
    NSData *newData = [NSData dataWithBytes: newDataBytes length: 12];
    NSString *  descString = [NSString stringWithFormat: @"Set Backlash %d", (unsigned int)backlash];
    [self sendCommand: newData WithDesc: descString WaitForResponse: true WithTimeout: 0.2];
}

- (void) motorSet: (int) motorNumber Microstep: (unsigned char) microstep {
    
    unsigned char newDataBytes[16];
    [self setupBuffer: newDataBytes subAddress: motorNumber command: NMXCommandMotorSetMicroStep dataLength: 1];
    newDataBytes[10] = microstep;
    NSData *newData = [NSData dataWithBytes: newDataBytes length: 11];
    [self sendCommand: newData WithDesc: @"Set Microstep" WaitForResponse: true WithTimeout: 0.2];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    switch (motorNumber)
    {
        case 1:
            [defaults setInteger: microstep forKey: kDefaultsMotorSledMicrosteps];
            break;
        case 2:
            [defaults setInteger: microstep forKey: kDefaultsMotorPanMicrosteps];
            break;
        case 3:
            [defaults setInteger: microstep forKey: kDefaultsMotorTiltMicrosteps];
            break;
    }
    [defaults synchronize];
}

- (void) motorSet: (int) motorNumber ContinuousSpeed: (float) speed {
    
    if (false == disabled[motorNumber])
    {
        if (invertDirection[motorNumber])
        {
            speed = -speed;
        }
        
        if (0 == speed)
        {
            moving[motorNumber] = NMXMovingStopped;
        }
        
        unsigned char newDataBytes[16];
        
        [self setupBuffer: newDataBytes subAddress: motorNumber command: NMXCommandMotorSetContinuousSpeed dataLength: 4];
        
        unsigned char * speedPtr = (unsigned char *)&speed;
        
        newDataBytes[10] = speedPtr[3];
        newDataBytes[11] = speedPtr[2];
        newDataBytes[12] = speedPtr[1];
        newDataBytes[13] = speedPtr[0];
        
        NSData *newData = [NSData dataWithBytes: newDataBytes length: 14];
        NSString *  descString = [NSString stringWithFormat: @"Set Continuous Speed %f", speed];
        
        [self sendCommand: newData WithDesc: descString WaitForResponse: false WithTimeout: 0.1];

        // Send the stop command twice just to be sure...
        
        if (0 == speed)
        {
            [self sendCommand: newData WithDesc: descString WaitForResponse: false WithTimeout: 0.1];
        }
    }
}

- (void) motorSet: (int) motorNumber ContinuousSpeedAccelDecel: (float) speed {
        
        unsigned char newDataBytes[16];
        
        [self setupBuffer: newDataBytes subAddress: motorNumber command: NMXCommandMotorSetContinuousAccelDecelRate dataLength: 4];
        
        unsigned char * speedPtr = (unsigned char *)&speed;
        
        newDataBytes[10] = speedPtr[3];
        newDataBytes[11] = speedPtr[2];
        newDataBytes[12] = speedPtr[1];
        newDataBytes[13] = speedPtr[0];
        
        NSData *newData = [NSData dataWithBytes: newDataBytes length: 14];
        NSString *descString = [NSString stringWithFormat: @"Set Continuous Speed Dampening %f motor: %i", speed,motorNumber];
        
        [self sendCommand: newData WithDesc: descString WaitForResponse: false WithTimeout: 0.1];
        
        // Send the stop command twice just to be sure...
        
        if (0 == speed)
        {
            [self sendCommand: newData WithDesc: descString WaitForResponse: false WithTimeout: 0.1];
        }
}

- (void) motorMove: (int) motorNumber Direction: (unsigned char) direction Steps: (UInt32) steps {
    
    if (false == disabled[motorNumber])
    {
        // If we are already moving in this direction, do nothing.
        if ((0 == steps) && (direction == moving[motorNumber]))
            return;
        if (invertDirection[motorNumber])
        {
            if (direction)
                direction = 0;
            else
                direction = 1;
        }
        
        moving[motorNumber] = direction;
        
        unsigned char newDataBytes[16];
        
        [self setupBuffer: newDataBytes subAddress: motorNumber command: NMXCommandMotorMoveSimple dataLength: 5];
        
        newDataBytes[10] = direction;
        
        unsigned char * stepsPtr = (unsigned char *)&steps;
        newDataBytes[11] = stepsPtr[3];
        newDataBytes[12] = stepsPtr[2];
        newDataBytes[13] = stepsPtr[1];
        newDataBytes[14] = stepsPtr[0];
        
        NSData *newData = [NSData dataWithBytes: newDataBytes length: 15];
        
        NSString * descString = [NSString stringWithFormat: @"Motor Move %d in direction %d", motorNumber, direction];
        [self sendCommand: newData WithDesc: descString WaitForResponse: true WithTimeout: 0.2];
    }
}

- (void) motorSetStartHere: (int) motorNumber {

    unsigned char newDataBytes[16];
    [self setupBuffer: newDataBytes subAddress: motorNumber command: NMXCommandMotorSetStartHere dataLength: 0];
    NSData *newData = [NSData dataWithBytes: newDataBytes length: 10];
    [self sendCommand: newData WithDesc: @"Send Motor To Start Point" WaitForResponse: true WithTimeout: 0.2];
}

- (void) resetLimits: (int) motorNumber {
    
    unsigned char newDataBytes[16];
    [self setupBuffer: newDataBytes subAddress: motorNumber command: NMXCommandMotorResetLimitsProgramStart dataLength: 0];
    NSData *newData = [NSData dataWithBytes: newDataBytes length: 10];
    [self sendCommand: newData WithDesc: @"Reset Limits" WaitForResponse: true WithTimeout: 0.2];
}

- (void) motorSetStopHere: (int) motorNumber {

    unsigned char newDataBytes[16];
    [self setupBuffer: newDataBytes subAddress: motorNumber command: NMXCommandMotorSetStopHere dataLength: 0];
    NSData *newData = [NSData dataWithBytes: newDataBytes length: 10];
    [self sendCommand: newData WithDesc: @"Send Motor To Start Point" WaitForResponse: true WithTimeout: 0.2];
}

- (void) motorSet:(int)motorNumber ProgramStartPoint: (UInt32) position {
    
    unsigned char newDataBytes[16];
    [self setupBuffer: newDataBytes subAddress: motorNumber command: NMXCommandMotorSetProgramStartPoint dataLength: 4];
    unsigned char * positionPtr = (unsigned char *)&position;
    newDataBytes[10] = positionPtr[3];
    newDataBytes[11] = positionPtr[2];
    newDataBytes[12] = positionPtr[1];
    newDataBytes[13] = positionPtr[0];
    
    NSData *newData = [NSData dataWithBytes: newDataBytes length: 14];
    NSString *  descString = [NSString stringWithFormat: @"Set Program Start Point %d", (unsigned int)position];
    [self sendCommand: newData WithDesc: descString WaitForResponse: true WithTimeout: 0.2];
}

- (void) motorSet:(int)motorNumber SetMotorPosition: (UInt32) position {
    
    unsigned char newDataBytes[16];
    [self setupBuffer: newDataBytes subAddress: motorNumber command: NMXCommandMotorPosition dataLength: 4];
    unsigned char * positionPtr = (unsigned char *)&position;
    newDataBytes[10] = positionPtr[3];
    newDataBytes[11] = positionPtr[2];
    newDataBytes[12] = positionPtr[1];
    newDataBytes[13] = positionPtr[0];
    
    NSData *newData = [NSData dataWithBytes: newDataBytes length: 14];
    NSString *  descString = [NSString stringWithFormat: @"Set Motor Position %d", (unsigned int)position];
    [self sendCommand: newData WithDesc: descString WaitForResponse: true WithTimeout: 0.2];
}

- (void) motorSet:(int)motorNumber ProgramStopPoint: (UInt32) position {
    
    unsigned char newDataBytes[16];
    [self setupBuffer: newDataBytes subAddress: motorNumber command: NMXCommandMotorSetProgramStopPoint dataLength: 4];
    unsigned char * positionPtr = (unsigned char *)&position;
    newDataBytes[10] = positionPtr[3];
    newDataBytes[11] = positionPtr[2];
    newDataBytes[12] = positionPtr[1];
    newDataBytes[13] = positionPtr[0];
    
    NSData *newData = [NSData dataWithBytes: newDataBytes length: 14];
    NSString *  descString = [NSString stringWithFormat: @"Set Program Stop Point %d", (unsigned int)(unsigned int)position];
    [self sendCommand: newData WithDesc: descString WaitForResponse: true WithTimeout: 0.2];
}

- (void) motorSendToStartPoint: (int) motorNumber {

    unsigned char newDataBytes[16];
    [self setupBuffer: newDataBytes subAddress: motorNumber command: NMXCommandMotorSendToProgramStartPoint dataLength: 0];
    NSData *newData = [NSData dataWithBytes: newDataBytes length: 10];
    [self sendCommand: newData WithDesc: @"Send Motor To Start Point" WaitForResponse: true WithTimeout: 0.2];
}

- (void) motorSendToEndPoint: (int) motorNumber {
    
    unsigned char newDataBytes[16];
    [self setupBuffer: newDataBytes subAddress: motorNumber command: NMXCommandMotorSendToProgramEndPoint dataLength: 0];
    NSData *newData = [NSData dataWithBytes: newDataBytes length: 10];
    [self sendCommand: newData WithDesc: @"Send Motor To End Point" WaitForResponse: true WithTimeout: 0.2];
}

- (void) motorSet:(int)motorNumber SetLeadInShotsOrTime: (UInt32) leadIn {
    
    unsigned char newDataBytes[16];
    [self setupBuffer: newDataBytes subAddress: motorNumber command: NMXCommandMotorSetLeadInShotsOrTime dataLength: 4];
    unsigned char * leadInPtr = (unsigned char *)&leadIn;
    newDataBytes[10] = leadInPtr[3];
    newDataBytes[11] = leadInPtr[2];
    newDataBytes[12] = leadInPtr[1];
    newDataBytes[13] = leadInPtr[0];
    
    NSData *newData = [NSData dataWithBytes: newDataBytes length: 14];
    NSString *  descString = [NSString stringWithFormat: @"Set Lead In Shots or Time %d", (unsigned int)leadIn];
    [self sendCommand: newData WithDesc: descString WaitForResponse: true WithTimeout: 0.3];
}

- (void) motorSet:(int)motorNumber SetLeadOutShotsOrTime: (UInt32) leadOut {
    
    unsigned char newDataBytes[16];
    [self setupBuffer: newDataBytes subAddress: motorNumber command: NMXCommandMotorSetLeadOutShotsOrTime dataLength: 4];
    unsigned char * leadOutPtr = (unsigned char *)&leadOut;
    newDataBytes[10] = leadOutPtr[3];
    newDataBytes[11] = leadOutPtr[2];
    newDataBytes[12] = leadOutPtr[1];
    newDataBytes[13] = leadOutPtr[0];
    
    NSData *newData = [NSData dataWithBytes: newDataBytes length: 14];
    NSString *  descString = [NSString stringWithFormat: @"Set Lead Out Shots or Time %d", (unsigned int)leadOut];
    [self sendCommand: newData WithDesc: descString WaitForResponse: true WithTimeout: 0.3];
}

- (void) motorSet:(int)motorNumber SetShotsTotalTravelTime: (UInt32) shots {
    
    unsigned char newDataBytes[16];
    
    [self setupBuffer: newDataBytes subAddress: motorNumber command: NMXCommandMotorSetTravelShotsOrTravelTime dataLength: 4];
    
    unsigned char * shotsPtr = (unsigned char *)&shots;
    
    newDataBytes[10] = shotsPtr[3];
    newDataBytes[11] = shotsPtr[2];
    newDataBytes[12] = shotsPtr[1];
    newDataBytes[13] = shotsPtr[0];
    
    NSData *newData = [NSData dataWithBytes: newDataBytes length: 14];
    
    NSString *descString = [NSString stringWithFormat: @"Set Shots Total Travel Time %d", (unsigned int)shots];
    
    [self sendCommand: newData WithDesc: descString WaitForResponse: true WithTimeout: 0.3];
}

- (void) motorSet:(int)motorNumber SetProgramAccel: (UInt32) accel {
    
    unsigned char newDataBytes[16];
    
    [self setupBuffer: newDataBytes subAddress: motorNumber command: NMXCommandMotorSetProgramAccel dataLength: 4];
    
    unsigned char * accelPtr = (unsigned char *)&accel;
    
    newDataBytes[10] = accelPtr[3];
    newDataBytes[11] = accelPtr[2];
    newDataBytes[12] = accelPtr[1];
    newDataBytes[13] = accelPtr[0];
    
    NSData *newData = [NSData dataWithBytes: newDataBytes length: 14];
    NSString *  descString = [NSString stringWithFormat: @"Set Program Accel %d", (unsigned int)accel];
    
    [self sendCommand: newData WithDesc: descString WaitForResponse: true WithTimeout: 0.3];
}

- (void) motorSet:(int)motorNumber SetProgramDecel: (UInt32) decel {
    
    unsigned char newDataBytes[16];
    [self setupBuffer: newDataBytes subAddress: motorNumber command: NMXCommandMotorSetProgramDecel dataLength: 4];
    unsigned char * decelPtr = (unsigned char *)&decel;
    newDataBytes[10] = decelPtr[3];
    newDataBytes[11] = decelPtr[2];
    newDataBytes[12] = decelPtr[1];
    newDataBytes[13] = decelPtr[0];
    
    NSData *newData = [NSData dataWithBytes: newDataBytes length: 14];
    NSString *  descString = [NSString stringWithFormat: @"Set Program Decel %d", (unsigned int)decel];
    [self sendCommand: newData WithDesc: descString WaitForResponse: true WithTimeout: 0.3];
}


#pragma mark - Motor Query

- (UInt16) motorQueryBacklash: (int) motorNumber {

    UInt16    backlash;
    unsigned char newDataBytes[16];
    [self setupBuffer: newDataBytes subAddress: motorNumber command: NMXCommandMotorQueryBacklash dataLength: 0];
    NSData *newData = [NSData dataWithBytes: newDataBytes length: 10];
    
    [self sendCommand: newData WithDesc: @"QueryBacklash" WaitForResponse: true WithTimeout: 0.2];
    
    if ([self waitForResponse])
    {
        backlash = [[self extractReturnedNumber] UInt16Value];
    }
    
    return backlash;
}

- (int) motorQueryCurrentPosition: (int) motorNumber {
    
    int    currentPosition;
    char newDataBytes[16];
    
    [self setupBuffer2: newDataBytes subAddress: motorNumber command: NMXCommandMotorQueryCurrentPosition dataLength: 0];
    
    NSData *newData = [NSData dataWithBytes: newDataBytes length: 10];
    
    [self sendCommand: newData WithDesc: @"QueryCurrentPosition" WaitForResponse: true WithTimeout: 0.2];
    
    if ([self waitForResponse])
    {
        currentPosition = [[self extractReturnedNumber] intValue];
    }
    
    return currentPosition;
}

- (bool) motorQueryRunning: (int) motorNumber {

    char            running;
    unsigned char   newDataBytes[16];
    [self setupBuffer: newDataBytes subAddress: motorNumber command: NMXCommandMotorQueryRunning dataLength: 0];
    NSData *newData = [NSData dataWithBytes: newDataBytes length: 10];
    
    [self sendCommand: newData WithDesc: @"QueryRunning" WaitForResponse: true WithTimeout: 1.0];
    
    if ([self waitForResponse])
    {
        running = [[self extractReturnedNumber] boolValue];
    }
    
    return running;
}

- (UInt32) motorQueryShotsTotalTravelTime: (int) motorNumber {

    UInt32    currentPosition;
    unsigned char newDataBytes[16];
    [self setupBuffer: newDataBytes subAddress: motorNumber command: NMXCommandMotorQueryTravelShotsOrTravelTime dataLength: 0];
    NSData *newData = [NSData dataWithBytes: newDataBytes length: 10];
    
    [self sendCommand: newData WithDesc: @"QueryShotsTravelTime" WaitForResponse: true WithTimeout: 0.3];
    
    if ([self waitForResponse])
    {
        currentPosition = [[self extractReturnedNumber] UInt32Value];
    }
    
    return currentPosition;
}

- (float) motorQueryContinuousAccelDecel: (int) motorNumber {
    
    float    voltage;
    unsigned char newDataBytes[16];
    [self setupBuffer: newDataBytes subAddress: motorNumber command: NMXCommandMotorQueryContinuousAccelDecel dataLength: 0];
    NSData *newData = [NSData dataWithBytes: newDataBytes length: 10];
    
    [self sendCommand: newData WithDesc: @"Query ContinuousAccelDecel" WaitForResponse: true WithTimeout: 0.2];
    
    if ([self waitForResponse])
    {
        voltage = [[self extractReturnedNumber] floatValue];
    }
    
    return voltage;
    
//    UInt32    currentPosition;
//    unsigned char newDataBytes[16];
//    [self setupBuffer: newDataBytes subAddress: motorNumber command: NMXCommandMotorQueryContinuousAccelDecel dataLength: 0];
//    NSData *newData = [NSData dataWithBytes: newDataBytes length: 10];
//    
//    [self sendCommand: newData WithDesc: @"ContinuousAccelDecel" WaitForResponse: true WithTimeout: 0.3];
//    
//    if ([self waitForResponse])
//    {
//        currentPosition = [[self extractReturnedNumber] UInt32Value];
//    }
//    
//    return currentPosition;
}



- (UInt32) motorQueryLeadInShotsOrTime: (int) motorNumber {

    UInt32    leadIn;
    unsigned char newDataBytes[16];
    [self setupBuffer: newDataBytes subAddress: motorNumber command: NMXCommandMotorQueryLeadInShotsOrTime dataLength: 0];
    NSData *newData = [NSData dataWithBytes: newDataBytes length: 10];
    
    [self sendCommand: newData WithDesc: @"QueryLeadIn" WaitForResponse: true WithTimeout: 0.3];
    
    if ([self waitForResponse])
    {
        leadIn = [[self extractReturnedNumber] UInt32Value];
    }
    
    return leadIn;
}

- (UInt32) motorQueryLeadOutShotsOrTime: (int) motorNumber {

    UInt32    leadOut;
    unsigned char newDataBytes[16];
    [self setupBuffer: newDataBytes subAddress: motorNumber command: NMXCommandMotorQueryLeadOutShotsOrTime dataLength: 0];
    NSData *newData = [NSData dataWithBytes: newDataBytes length: 10];
    
    [self sendCommand: newData WithDesc: @"QueryLeadOut" WaitForResponse: true WithTimeout: 0.3];
    
    if ([self waitForResponse])
    {
        leadOut = [[self extractReturnedNumber] UInt32Value];
    }
    
    return leadOut;
}

- (bool) motorQuerySleep: (int) motorNumber {

    char            sleepMode;
    unsigned char   newDataBytes[16];
    [self setupBuffer: newDataBytes subAddress: motorNumber command: NMXCommandMotorQuerySleep dataLength: 0];
    NSData *newData = [NSData dataWithBytes: newDataBytes length: 10];
    
    [self sendCommand: newData WithDesc: @"QuerySleep" WaitForResponse: true WithTimeout: 0.2];
    
    if ([self waitForResponse])
    {
        sleepMode = [[self extractReturnedNumber] boolValue];
    }
    
    return sleepMode;
}

- (bool) motorQueryInvertDirection: (int) motorNumber {

    return invertDirection[motorNumber];
}

- (bool) motorQueryDisabled: (int) motorNumber {

    return disabled[motorNumber];
}

- (unsigned char) motorQueryMicrostep: (int) motorNumber {

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    unsigned char microsteps = 8;
    
    switch (motorNumber)
    {
        case 1:
            microsteps = [defaults integerForKey: kDefaultsMotorSledMicrosteps];
            if (0 == microsteps)
                microsteps = 4;
            break;
        case 2:
            microsteps = [defaults integerForKey: kDefaultsMotorPanMicrosteps];
            if (0 == microsteps)
                microsteps = 8;
            break;
        case 3:
            microsteps = [defaults integerForKey: kDefaultsMotorTiltMicrosteps];
            if (0 == microsteps)
                microsteps = 8;
            break;
    }
    return microsteps;
}

- (UInt16) motorQueryMicrostep2: (int) motorNumber {
    
    //NSLog(@"motorQueryMicrostep2");
    
    UInt16    microstep;
    unsigned char newDataBytes[16];
    
    [self setupBuffer: newDataBytes subAddress: motorNumber command: NMXCommandMotorMicrostepValue dataLength: 0];
    
    NSData *newData = [NSData dataWithBytes: newDataBytes length: 10];
    
    [self sendCommand: newData WithDesc: @"QueryMicrostep" WaitForResponse: true WithTimeout: 0.2];
    
    if ([self waitForResponse])
    {
        microstep = [[self extractReturnedNumber] UInt16Value];
    }
    
    return microstep;
}

#pragma mark - Camera Set

- (void) cameraSetEnable: (bool) enabled {
    
    unsigned char newDataBytes[16];
    [self setupBuffer: newDataBytes subAddress: 4 command: NMXCommandCameraEnable dataLength: 1];
    newDataBytes[10] = enabled;
    NSData *newData = [NSData dataWithBytes: newDataBytes length: 11];
    [self sendCommand: newData WithDesc: @"Enable Camera" WaitForResponse: true WithTimeout: 0.2];
}

- (void) cameraExposeNow {
    
    unsigned char newDataBytes[16];
    [self setupBuffer: newDataBytes subAddress: 4 command: NMXCommandCameraExposeNow dataLength: 0];
    NSData *newData = [NSData dataWithBytes: newDataBytes length: 10];
    [self sendCommand: newData WithDesc: @"Camera Expose Now" WaitForResponse: true WithTimeout: 0.2];
}

- (void) cameraSetTriggerTime: (UInt32) time {
    
    unsigned char newDataBytes[16];
    [self setupBuffer: newDataBytes subAddress: 4 command: NMXCommandCameraSetTriggerTime dataLength: 4];
    unsigned char * timePtr = (unsigned char *)&time;
    newDataBytes[10] = timePtr[3];
    newDataBytes[11] = timePtr[2];
    newDataBytes[12] = timePtr[1];
    newDataBytes[13] = timePtr[0];
    
    NSData *newData = [NSData dataWithBytes: newDataBytes length: 14];
    NSString *  descString = [NSString stringWithFormat: @"Set Trigger Time %d", (unsigned int)time];
    [self sendCommand: newData WithDesc: descString WaitForResponse: true WithTimeout: 0.2];
}

- (void) cameraSetFocusTime: (UInt16) time {
    
    unsigned char newDataBytes[16];
    [self setupBuffer: newDataBytes subAddress: 4 command: NMXCommandCameraSetFocusTime dataLength: 2];
    unsigned char * timePtr = (unsigned char *)&time;
    newDataBytes[10] = timePtr[1];
    newDataBytes[11] = timePtr[0];
    
    NSData *newData = [NSData dataWithBytes: newDataBytes length: 12];
    NSString *  descString = [NSString stringWithFormat: @"Set Focus Time %d", (unsigned int)time];
    [self sendCommand: newData WithDesc: descString WaitForResponse: true WithTimeout: 0.2];
}

- (void) cameraSetFrames: (UInt16) frames {
    
    unsigned char newDataBytes[16];
    [self setupBuffer: newDataBytes subAddress: 4 command: NMXCommandCameraSetFrames dataLength: 2];
    unsigned char * framesPtr = (unsigned char *)&frames;
    newDataBytes[10] = framesPtr[1];
    newDataBytes[11] = framesPtr[0];
    
    NSData *newData = [NSData dataWithBytes: newDataBytes length: 12];
    NSString *  descString = [NSString stringWithFormat: @"Set Frames %d", frames];
    [self sendCommand: newData WithDesc: descString WaitForResponse: true WithTimeout: 0.2];
}

- (void) cameraSetExposureDelay: (UInt16) delay {
    
    unsigned char newDataBytes[16];
    [self setupBuffer: newDataBytes subAddress: 4 command: NMXCommandCameraSetExposureDelay dataLength: 2];
    unsigned char * delayPtr = (unsigned char *)&delay;
    newDataBytes[10] = delayPtr[1];
    newDataBytes[11] = delayPtr[0];
    
    NSData *newData = [NSData dataWithBytes: newDataBytes length: 12];
    NSString *  descString = [NSString stringWithFormat: @"Set Exposure Delay %d", (unsigned int)delay];
    [self sendCommand: newData WithDesc: descString WaitForResponse: true WithTimeout: 0.2];
}

- (void) cameraSetInterval: (UInt32) interval {
    
    unsigned char newDataBytes[16];
    [self setupBuffer: newDataBytes subAddress: 4 command: NMXCommandCameraSetInterval dataLength: 4];
    unsigned char * intervalPtr = (unsigned char *)&interval;
    newDataBytes[10] = intervalPtr[3];
    newDataBytes[11] = intervalPtr[2];
    newDataBytes[12] = intervalPtr[1];
    newDataBytes[13] = intervalPtr[0];
    
    NSData *newData = [NSData dataWithBytes: newDataBytes length: 14];
    NSString *  descString = [NSString stringWithFormat: @"Set Interval %d", (unsigned int)interval];
    [self sendCommand: newData WithDesc: descString WaitForResponse: true WithTimeout: 0.2];
}

- (void) cameraSetTestMode: (bool) testMode {

    unsigned char newDataBytes[16];
    [self setupBuffer: newDataBytes subAddress: 4 command: NMXCommandCameraTestMode dataLength: 1];
    newDataBytes[10] = testMode;
    NSData *newData = [NSData dataWithBytes: newDataBytes length: 11];
    [self sendCommand: newData WithDesc: @"Test Camera Mode" WaitForResponse: true WithTimeout: 0.2];
}

#pragma mark - Camera Query

- (UInt32) cameraQueryMaxShots {
    
    UInt32    maxShots;
    unsigned char newDataBytes[16];
    [self setupBuffer: newDataBytes subAddress: 4 command: NMXCommandCameraQueryMaxShots dataLength: 0];
    NSData *newData = [NSData dataWithBytes: newDataBytes length: 10];
    
    [self sendCommand: newData WithDesc: @"QueryMaxShots" WaitForResponse: true WithTimeout: 0.2];
    
    if ([self waitForResponse])
    {
        maxShots = [[self extractReturnedNumber] UInt32Value];
    }
    
    return maxShots;
}

- (UInt32) cameraQueryInterval {
    
    UInt32    interval;
    unsigned char newDataBytes[16];
    [self setupBuffer: newDataBytes subAddress: 4 command: NMXCommandCameraQueryInterval dataLength: 0];
    NSData *newData = [NSData dataWithBytes: newDataBytes length: 10];
    
    [self sendCommand: newData WithDesc: @"QueryCurrentInterval" WaitForResponse: true WithTimeout: 0.2];
    
    if ([self waitForResponse])
    {
        interval = [[self extractReturnedNumber] UInt32Value];
    }
    
    return interval;
}

- (UInt16) cameraQueryCurrentShots {
    
    static UInt16   lastCurrentShots = 0;       // We always want to have a value even if we get disconnected for this.
    UInt16    currentShots;
    unsigned char newDataBytes[16];
    
    [self setupBuffer: newDataBytes subAddress: 4 command: NMXCommandCameraQueryCurrentShots dataLength: 0];
    NSData *newData = [NSData dataWithBytes: newDataBytes length: 10];
    
    [self sendCommand: newData WithDesc: @"QueryCurrentShots" WaitForResponse: true WithTimeout: 0.3];
    
    if ([self waitForResponse])
    {
        NSNumber * currentShotsNumber = [self extractReturnedNumberWithValueType: NMXValueTypeUInt16];
        
        if (currentShotsNumber)
        {
            lastCurrentShots = currentShots = [currentShotsNumber UInt16Value];
        }
    }
    
    return currentShots;
}

#pragma mark - Randall additions

- (void) rampingSetEasing: (int)value {
    
    unsigned char newDataBytes[16];
    [self setupBuffer: newDataBytes subAddress: 1 command: NMXCommandEasingRampMode dataLength: 1];
    
    newDataBytes[10] = value;
    NSData *newData = [NSData dataWithBytes: newDataBytes length: 11];
    
    NSString *descString = [NSString stringWithFormat: @"Set Ramp Easing Value %d", (unsigned int)value];
    
    [self sendCommand: newData WithDesc: descString WaitForResponse: true WithTimeout: 0.3];
}

- (void) setDelayProgramStartTimer: (UInt64) timerValue {
    
    unsigned char newDataBytes[16];
    
    [self setupBuffer: newDataBytes subAddress: 0 command: NMXCommandMainProgramDelay dataLength: 4];
    
    unsigned char * timerPtr = (unsigned char *)&timerValue;
    
    newDataBytes[10] = timerPtr[3];
    newDataBytes[11] = timerPtr[2];
    newDataBytes[12] = timerPtr[1];
    newDataBytes[13] = timerPtr[0];
    
    NSData *newData = [NSData dataWithBytes: newDataBytes length: 14];
    
    NSString *descString = [NSString stringWithFormat: @"Set Program Delay Start Timer %d", (unsigned int)timerValue];
    
    [self sendCommand: newData WithDesc: descString WaitForResponse: true WithTimeout: 0.2];
}

- (UInt32) queryDelayTime {
    
    UInt32    delayTime;
    unsigned char newDataBytes[16];
    
    [self setupBuffer: newDataBytes subAddress: 0 command: NMXCommandMainQueryDelayTimer dataLength: 0];
    
    NSData *newData = [NSData dataWithBytes: newDataBytes length: 10];
    
    [self sendCommand: newData WithDesc: @"QueryProgramDelay" WaitForResponse: true WithTimeout: 0.2];
    
    if ([self waitForResponse])
    {
        delayTime = [[self extractReturnedNumber] UInt16Value];
    }
    
    return delayTime;
}

- (UInt32) queryProgramStartPoint : (int)motor {
    
    UInt32    startPoint;
    unsigned char newDataBytes[16];
    
    [self setupBuffer: newDataBytes subAddress: motor command: NMXCommandProgramStartPoint dataLength: 0];
    
    NSData *newData = [NSData dataWithBytes: newDataBytes length: 10];
    
    [self sendCommand: newData WithDesc: @"QueryProgramStartPoint" WaitForResponse: true WithTimeout: 0.2];
    
    if ([self waitForResponse])
    {
        startPoint = [[self extractReturnedNumber] UInt32Value];
        
        //NSLog(@"query startPoint %i: %i",motor,startPoint);
    }
    
    return startPoint;
}

- (UInt32) queryProgramEndPoint : (int) motor {
    
    UInt32    stopPoint;
    unsigned char newDataBytes[16];
    
    [self setupBuffer: newDataBytes subAddress: motor command: NMXCommandProgramStopPoint dataLength: 0];
    
    NSData *newData = [NSData dataWithBytes: newDataBytes length: 10];
    
    [self sendCommand: newData WithDesc: @"QueryProgramStopPoint" WaitForResponse: true WithTimeout: 0.2];
    
    if ([self waitForResponse])
    {
        stopPoint = [[self extractReturnedNumber] UInt32Value];
        
        //NSLog(@"query stopPoint %i: %i",motor,stopPoint);
    }
    
    return stopPoint;
}

- (void) setHomePosition : (int) motor {
    
    unsigned char newDataBytes[16];
    
    [self setupBuffer: newDataBytes subAddress: motor command: 9 dataLength: 0];
    
    NSData *newData = [NSData dataWithBytes: newDataBytes length: 10];
    
    [self sendCommand: newData WithDesc: @"SetHomeHere" WaitForResponse: true WithTimeout: 0.2];
}

- (void) keepAlive: (bool) value {
    
    unsigned char newDataBytes[16];
    
    [self setupBuffer: newDataBytes subAddress: 4 command: NMXCommandCameraKeepAlive dataLength: 1];
    
    newDataBytes[10] = value;
    
    NSData *newData = [NSData dataWithBytes: newDataBytes length: 11];
    
    NSString *descString = [NSString stringWithFormat: @"Set Keep Alive %d", (unsigned int)value];
    
    [self sendCommand: newData WithDesc: descString WaitForResponse: true WithTimeout: 0.2];
}


#pragma mark - Keyframe Program

- (void) setCurrentKeyFrameAxis: (UInt16) value {
    
    if (NO ==[self checkFWMinRequiredVersion: 46]) return;
    
    unsigned char newDataBytes[16];
    
    [self setupBuffer: newDataBytes subAddress: 5 command: NMXSetAxis dataLength: 2];
    
    unsigned char * valuePtr = (unsigned char *)&value;
    
    newDataBytes[10] = valuePtr[1];
    newDataBytes[11] = valuePtr[0];
    
    NSData *newData = [NSData dataWithBytes: newDataBytes length: 12];
    
    NSString *descString = [NSString stringWithFormat: @"Set KeyFrame Axis %i", value];
    
    [self sendCommand: newData WithDesc: descString WaitForResponse: true WithTimeout: 0.2];
}

- (void) setKeyFrameCount: (UInt16) value {

    if (NO ==[self checkFWMinRequiredVersion: 46]) return;
    
    unsigned char newDataBytes[16];
    
    [self setupBuffer: newDataBytes subAddress: 5 command: NMXKeyFrameCount dataLength: 2];
    
    unsigned char * valuePtr = (unsigned char *)&value;
    
    newDataBytes[10] = valuePtr[1];
    newDataBytes[11] = valuePtr[0];
    
    NSData *newData = [NSData dataWithBytes: newDataBytes length: 12];
    
    NSString *  descString = [NSString stringWithFormat: @"Set KeyFrame Count %d", (unsigned int)value];
    
    [self sendCommand: newData WithDesc: descString WaitForResponse: true WithTimeout: 0.2];
}

- (void) setKeyFrameAbscissa: (float) value {
    
    if (NO ==[self checkFWMinRequiredVersion: 46]) return;
    
    unsigned char newDataBytes[16];
    
    [self setupBuffer: newDataBytes subAddress: 5 command: NMXKeyFrameAbscissa dataLength: 4];
    
    unsigned char * valPtr = (unsigned char *)&value;
    
    newDataBytes[10] = valPtr[3];
    newDataBytes[11] = valPtr[2];
    newDataBytes[12] = valPtr[1];
    newDataBytes[13] = valPtr[0];
    
    NSData *newData = [NSData dataWithBytes: newDataBytes length: 14];
    
    NSString *descString = [NSString stringWithFormat: @"Set KeyFrame Abscissa %f", value];
    
    [self sendCommand: newData WithDesc: descString WaitForResponse: true WithTimeout: 0.2];
}

- (void) setKeyFramePosition: (float) value {
    
    if (NO ==[self checkFWMinRequiredVersion: 46]) return;
    
    char newDataBytes[16];
    
    [self setupBuffer2: newDataBytes subAddress: 5 command: NMXKeyFramePosition dataLength: 4];
    
    char * valPtr = (char *)&value;
    
    newDataBytes[10] = valPtr[3];
    newDataBytes[11] = valPtr[2];
    newDataBytes[12] = valPtr[1];
    newDataBytes[13] = valPtr[0];
    
    NSData *newData = [NSData dataWithBytes: newDataBytes length: 14];
    
    //NSString *descString = [NSString stringWithFormat: @"Set KeyFrame Position %f", value];
    NSString *descString = [NSString stringWithFormat: @"Set KeyFrame Position %f", value];
    
    [self sendCommand: newData WithDesc: descString WaitForResponse: true WithTimeout: 0.2];
}

- (void) setKeyFrameVelocity: (float) value {
    
    if (NO ==[self checkFWMinRequiredVersion: 46]) return;
    
    unsigned char newDataBytes[16];
    
    [self setupBuffer: newDataBytes subAddress: 5 command: NMXKeyFrameVelocity dataLength: 4];
    
    char * valPtr = (char *)&value;
    
    newDataBytes[10] = valPtr[3];
    newDataBytes[11] = valPtr[2];
    newDataBytes[12] = valPtr[1];
    newDataBytes[13] = valPtr[0];
    
    NSData *newData = [NSData dataWithBytes: newDataBytes length: 14];
    
    NSString *descString = [NSString stringWithFormat: @"Set KeyFrame Velocity %f", value];
    
    [self sendCommand: newData WithDesc: descString WaitForResponse: true WithTimeout: 0.2];
}

//- (void) setKeyFrameVideoTime: (UInt16) value {
//
//    if (NO ==[self checkFWMinRequiredVersion: 46]) return;
//
//    unsigned char newDataBytes[16];
//    
//    [self setupBuffer: newDataBytes subAddress: 5 command: NMXKeyFrameContinuousVideoTime dataLength: 4];
//    
//    char * valPtr = (char *)&value;
//    
//    newDataBytes[10] = valPtr[3];
//    newDataBytes[11] = valPtr[2];
//    newDataBytes[12] = valPtr[1];
//    newDataBytes[13] = valPtr[0];
//    
//    NSData *newData = [NSData dataWithBytes: newDataBytes length: 14];
//    
//    NSString *descString = [NSString stringWithFormat: @"Set KeyFrame Velocity %f", value];
//    
//    [self sendCommand: newData WithDesc: descString WaitForResponse: true WithTimeout: 0.2];
//}

- (void) setKeyFrameVideoTime: (UInt32) value {
  
    if (NO ==[self checkFWMinRequiredVersion: 46]) return;
    
    unsigned char newDataBytes[16];
    
    [self setupBuffer: newDataBytes subAddress: 5 command: NMXKeyFrameContinuousVideoTime dataLength: 4];
    
    unsigned char * valuePtr = (unsigned char *)&value;
    
    newDataBytes[10] = valuePtr[3];
    newDataBytes[11] = valuePtr[2];
    newDataBytes[12] = valuePtr[1];
    newDataBytes[13] = valuePtr[0];
    
    NSData *newData = [NSData dataWithBytes: newDataBytes length: 14];
    
    NSString *descString = [NSString stringWithFormat: @"Set KeyFrame Video Time %d", (unsigned int)value];
    
    [self sendCommand: newData WithDesc: descString WaitForResponse: true WithTimeout: 0.2];
}

- (void) endKeyFrameTransmission {
    
    if (NO ==[self checkFWMinRequiredVersion: 46]) return;
    
    unsigned char newDataBytes[16];
    
    [self setupBuffer: newDataBytes subAddress: 5 command: NMXKeyFrameEndTransmission dataLength: 0];
    
    NSData *newData = [NSData dataWithBytes: newDataBytes length: 10];
    
    [self sendCommand: newData WithDesc: @"End Keyframe Transmission" WaitForResponse: true WithTimeout: 0.2];
}

- (void) startKeyFrameProgram {
    
    if (NO ==[self checkFWMinRequiredVersion: 46]) return;
    
    unsigned char newDataBytes[16];
    
    [self setupBuffer: newDataBytes subAddress: 5 command: NMXStartResumeKeyFrameProgram dataLength: 0];
    
    NSData *newData = [NSData dataWithBytes: newDataBytes length: 10];
    
    [self sendCommand: newData WithDesc: @"Start KeyFrame Program" WaitForResponse: true WithTimeout: 0.2];
}

- (void) stopKeyFrameProgram {
    
    if (NO ==[self checkFWMinRequiredVersion: 46]) return;
    
    unsigned char newDataBytes[16];
    
    [self setupBuffer: newDataBytes subAddress: 5 command: NMXStopKeyFrameProgram dataLength: 0];
    
    NSData *newData = [NSData dataWithBytes: newDataBytes length: 10];
    
    [self sendCommand: newData WithDesc: @"Stop KeyFrame Program" WaitForResponse: true WithTimeout: 0.2];
}

- (void) pauseKeyFrameProgram {
    
    if (NO ==[self checkFWMinRequiredVersion: 46]) return;
    
    unsigned char newDataBytes[16];
    
    [self setupBuffer: newDataBytes subAddress: 5 command: NMXPauseKeyFrameProgram dataLength: 0];
    
    NSData *newData = [NSData dataWithBytes: newDataBytes length: 10];
    
    [self sendCommand: newData WithDesc: @"Pause KeyFrame Program" WaitForResponse: true WithTimeout: 0.2];
}

- (UInt32) queryKeyFrameProgramRunState {
    
    if (_fwVersion >= 51 )
    {
        return [self mainQueryRunStatus];
    }
    
    // command 5.120 was deprecated in firmware v. .51
    
    if (NO ==[self checkFWMinRequiredVersion: 46]) return 0;
    
    UInt32    runState;
    unsigned char newDataBytes[16];
    
    [self setupBuffer: newDataBytes subAddress: 5 command: NMXQueryKeyFrameProgramRunState_DEPRECATED dataLength: 0];
    
    NSData *newData = [NSData dataWithBytes: newDataBytes length: 10];
    
    [self sendCommand: newData WithDesc: @"Query KeyFrame Program Run State" WaitForResponse: true WithTimeout: 0.2];
    
    if ([self waitForResponse])
    {
        runState = [[self extractReturnedNumber] UInt32Value];
        
        runState = [self runStatusFromOldKeyframRunStatus:(_Deprecated_NMXKeyFrameRunStatus)runState];
        
        if (runState != NMXRunStatusStopped)
        {
            runState |= NMXRunStatusKeyframe;  // We are running in keyframe mode so set the bit flag
        }
        
        //NSLog(@"query stopPoint %i: %i",motor,stopPoint);
    }
    
    return runState;
}

- (UInt32) queryKeyFrameProgramCurrentTime {
    
    if (NO ==[self checkFWMinRequiredVersion: 46]) return 0;
    
    UInt32    currentTime;
    unsigned char newDataBytes[16];
    
    [self setupBuffer: newDataBytes subAddress: 5 command: NMXQueryKeyFrameCurrentRunTime dataLength: 0];
    
    NSData *newData = [NSData dataWithBytes: newDataBytes length: 10];
    
    [self sendCommand: newData WithDesc: @"Query KeyFrame Current Run Time" WaitForResponse: true WithTimeout: 0.2];
    
    if ([self waitForResponse])
    {
        currentTime = [[self extractReturnedNumber] UInt32Value];
    }
    
    return currentTime;
}

- (UInt32) queryKeyFrameProgramMaxTime {
    
    if (NO ==[self checkFWMinRequiredVersion: 46]) return 0;
    
    UInt32    maxTime;
    unsigned char newDataBytes[16];
    
    [self setupBuffer: newDataBytes subAddress: 5 command: NMXQueryKeyFrameMaxRunTime dataLength: 0];
    
    NSData *newData = [NSData dataWithBytes: newDataBytes length: 10];
    
    [self sendCommand: newData WithDesc: @"Query KeyFrame Current Run Time" WaitForResponse: true WithTimeout: 0.2];
    
    if ([self waitForResponse])
    {
        maxTime = [[self extractReturnedNumber] UInt32Value];
    }
    
    return maxTime;
}

- (UInt32) queryKeyFramePercentComplete {
    
    if (NO ==[self checkFWMinRequiredVersion: 46]) return 0;
    
    UInt32    percentComplete;
    unsigned char newDataBytes[16];
    
    [self setupBuffer: newDataBytes subAddress: 5 command: NMXQueryKeyFramePercentComplete dataLength: 0];
    
    NSData *newData = [NSData dataWithBytes: newDataBytes length: 10];
    
    [self sendCommand: newData WithDesc: @"Query KeyFrame Current Percent Complete" WaitForResponse: true WithTimeout: 0.2];
    
    if ([self waitForResponse])
    {
        percentComplete = [[self extractReturnedNumber] UInt32Value];
    }
    
    return percentComplete;
}

- (bool) queryPowerCycle {
    
    char            running;
    unsigned char   newDataBytes[16];
    [self setupBuffer: newDataBytes subAddress: 0 command: NMXCommandMainQueryPowerCycle dataLength: 0];
    NSData *newData = [NSData dataWithBytes: newDataBytes length: 10];
    
    [self sendCommand: newData WithDesc: @"Power Cycle" WaitForResponse: true WithTimeout: 1.0];
    
    if ([self waitForResponse])
    {
        running = [[self extractReturnedNumber] boolValue];
    }
    
    return running;
}

#pragma mark - Notes

//0000000000FF03001504

//    buffer[0] = 0;
//    buffer[1] = 0;
//    buffer[2] = 0;
//    buffer[3] = 0;
//    buffer[4] = 0;
//    buffer[5] = 255;
//    buffer[6] = 3;                    // Address 1
//    buffer[7] = subAddress;
//    buffer[8] = command;
//    buffer[9] = dataLength;

//    The protocol starts with a header and is then followed by the address of the controller, then the sub-address (which indicates whether the command is for one of the motors, the camera, or is a general command), then the command number, then the length of the data to be appended, then the data itself.

//    Header: 0000000000FF
//    Address: 03
//    Sub-address: 00
//    Command: 15
//    Data length: 04
//    Data: [xxxxxxxx]

@end
