//
//  NMXDeviceManager.m
//  DP Test
//
//  Created by Dave Koziol on 9/16/14.
//  Copyright (c) 2014 Dynamic Perception. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CocoaLumberjack/CocoaLumberjack.h>

#import "NMXDeviceManager.h"
#import "NMXDevice.h"


#define kDynamicPerceptionServiceUDID   @"a3a9eb86-c0fd-4a5c-b191-bff60a7f9ea7"

@interface NMXDeviceManager()
@property (atomic, strong) CBCentralManager* myCBCentralManager;
@property (atomic, strong) NSMutableArray * myDevices;
@property (assign)	BOOL			scanRequested;
@property (assign)	BOOL			scanInProcess;
@end



@implementation NMXDeviceManager

@synthesize inReview,disconnected;


- (id) init {

    self = [super init];
    
    if (self)
    {
        self.myDevices = [NSMutableArray arrayWithCapacity: 3];
        
        self.myCBCentralManager = [[CBCentralManager alloc] initWithDelegate: self queue: dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0) options: nil];
        self.scanRequested = false;
        self.scanInProcess = false;
    }
    
    return self;
}

- (void) centralManagerDidUpdateState: (CBCentralManager *)central {

    DDLogDebug(@"centralManagerState = %d", (int)central.state);
    
    NSLog(@"centralManagerDidUpdateState");
    
    if (central.state == CBCentralManagerStatePoweredOn)
    {
        if ((true == self.scanRequested) && (false == self.scanInProcess))
        {
            [self.myCBCentralManager scanForPeripheralsWithServices:@[[CBUUID UUIDWithString: kDynamicPerceptionServiceUDID]]
                                                            options:nil];
            self.scanInProcess = true;
            self.scanRequested = false;
            
            DDLogDebug(@"Starting Scanning for dynamic perception peripherals");
        }
    }
    else
    {
        self.scanInProcess = false;
    }
}

- (NMXDevice *)addToList: (NMXDevice *)newDevice
{
    for (NMXDevice *device in self.myDevices)
    {
        if ([device.name isEqualToString:newDevice.name])
        {
            return device;
        }
    }
    
    [self.myDevices addObject: newDevice];
    
    return newDevice;
}


- (void) centralManager: (CBCentralManager *) central
  didDiscoverPeripheral: (CBPeripheral *) peripheral
      advertisementData: (NSDictionary *) advertisementData
                   RSSI: (NSNumber *) RSSI {

    //DDLogDebug(@"Discovered %@", peripheral.name);
    
    NMXDevice * newDevice = [[NMXDevice alloc] initWithPeripheral: peripheral andCentralManager: self.myCBCentralManager];

    newDevice = [self addToList: newDevice];
    
    if ((self.delegate) && ([self.delegate respondsToSelector:@selector(didDiscoverDevice:)]))
        [self.delegate didDiscoverDevice: newDevice];
}

- (void) centralManager: (CBCentralManager *) central
   didConnectPeripheral: (CBPeripheral *) peripheral {

    DDLogDebug(@"Peripheral connected");
    
    if (peripheral.delegate)
    {
        NMXDevice *peripheralDelegate = (NMXDevice *)peripheral.delegate;
        
        peripheralDelegate = [self addToList: peripheralDelegate];
        
        if ([peripheralDelegate respondsToSelector:@selector(peripheralWasConnected:)])
        {
            [peripheralDelegate peripheralWasConnected: peripheral];
        }
    }
    
    [peripheral discoverServices:nil];
}

- (void) centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {

    //DDLogDebug(@"centralManager Peripheral disconnected");
    
    NSArray *deviceArray = [NSArray arrayWithArray:self.myDevices];
    NMXDevice *disconnectedDevice = nil;
    
    for (NMXDevice *device in deviceArray)
    {
        if ([device.name isEqualToString: peripheral.name])
        {
            disconnectedDevice = device;
            [disconnectedDevice disconnect];
        }
    }

    if ((self.delegate) && ([self.delegate respondsToSelector:@selector(didDisconnectDevice:)]))
    {
        [self.delegate didDisconnectDevice: disconnectedDevice];
    }
    else
    {
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            
            if (!disconnected) {

                disconnected = YES;

                [[NSNotificationCenter defaultCenter] postNotificationName: kDeviceDisconnectedNotification object: disconnectedDevice];
            }
                        
            
        });
    }
}

- (void) alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {

    NSLog(@"alertView dismiss");
    
    //[[NSNotificationCenter defaultCenter] postNotificationName: kDeviceDisconnectedNotification object: nil];
}

- (void) startScanning {

    //NSLog(@"startScanning");
    
    if ((self.myCBCentralManager.state == CBCentralManagerStatePoweredOn) && (false == self.scanInProcess))
    {
        [self.myCBCentralManager scanForPeripheralsWithServices:@[[CBUUID UUIDWithString: kDynamicPerceptionServiceUDID]]
                                                        options:nil];
        self.scanInProcess = true;
        DDLogDebug(@"Starting Scanning for dynamic perception peripherals");
    }
    else
        self.scanRequested = true;
}

- (void) stopScanning {

    self.scanInProcess = false;
    self.scanRequested = false;
    [self.myCBCentralManager stopScan];
}

- (void) isInReview {
    
    inReview = YES;
}

- (void) notInReview {
    
    inReview = NO;
}

- (NSArray *) deviceList {

    return [NSArray arrayWithArray: self.myDevices];
}

@end
