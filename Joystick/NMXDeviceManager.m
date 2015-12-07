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
#define kDynamicPerceptionOldServiceUDID    @"B8E06067-62AD-41BA-9231-206AE80AB550"     // DP needs to change this.


@interface NMXDeviceManager()
@property (atomic, strong) CBCentralManager* myCBCentralManager;
@property (atomic, strong) NSMutableArray * myDevices;
@property (assign)	BOOL			scanRequested;
@property (assign)	BOOL			scanInProcess;
@property (assign)  BOOL            legacyDevices;
@end



@implementation NMXDeviceManager

@synthesize inReview;


- (id)init {

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

- (void)centralManagerDidUpdateState: (CBCentralManager *)central {

    DDLogDebug(@"centralManagerState = %d", (int)central.state);
    
    NSLog(@"centralManagerDidUpdateState");
    
    if (central.state == CBCentralManagerStatePoweredOn)
    {
        if ((true == self.scanRequested) && (false == self.scanInProcess))
        {
            if (self.legacyDevices)
                [self.myCBCentralManager scanForPeripheralsWithServices:@[[CBUUID UUIDWithString: kDynamicPerceptionOldServiceUDID]]
                                                                options:nil];
            else
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

- (void) centralManager: (CBCentralManager *) central
  didDiscoverPeripheral: (CBPeripheral *) peripheral
      advertisementData: (NSDictionary *) advertisementData
                   RSSI: (NSNumber *) RSSI {

    //DDLogDebug(@"Discovered %@", peripheral.name);
    
    NMXDevice * newDevice = [[NMXDevice alloc] initWithPeripheral: peripheral andCentralManager: self.myCBCentralManager];
    
    //randall update 1 - check if device already added to list
    
    bool alreadyAdded = false;
    
    for (NMXDevice *device in self.myDevices)
    {
        if ([device.name isEqualToString:newDevice.name])
        {
            alreadyAdded = true;
        }
    }
    
    if(!alreadyAdded)
    {
        [self.myDevices addObject: newDevice];
    }
    
    //randall update 1 end
    
    if ((self.delegate) && ([self.delegate respondsToSelector:@selector(didDiscoverDevice:)]))
        [self.delegate didDiscoverDevice: newDevice];
}

- (void) centralManager: (CBCentralManager *) central
   didConnectPeripheral: (CBPeripheral *) peripheral {

    DDLogDebug(@"Peripheral connected");
    [peripheral discoverServices:nil];
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {

    //DDLogDebug(@"Peripheral disconnected");
    
    NSLog(@"Peripheral disconnected");
    
    
    if ((self.delegate) && ([self.delegate respondsToSelector:@selector(didDisconnectDevice:)]))
    {
        [self.delegate didDisconnectDevice: peripheral];
    }
    else
    {
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            
            [[NSNotificationCenter defaultCenter] postNotificationName: kDeviceDisconnectedNotification object: @"Peripheral disconnected Randall"];
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Bluetooth Issue"
                                                            message: @"All settings saved on NMX - Tap OK to reconnect"
                                                           delegate: self
                                                  cancelButtonTitle: @"OK"
                                                  otherButtonTitles: nil];
            
            [alert show];
        });
    }
}

- (void) alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {

    NSLog(@"alertView dismiss");
    
    //[[NSNotificationCenter defaultCenter] postNotificationName: kDeviceDisconnectedNotification object: nil];
}

- (void) startScanning: (BOOL) inLegacyDevices; {

    NSLog(@"startScanning inLegacyDevices");
    
    self.legacyDevices = inLegacyDevices;
    
    if ((self.myCBCentralManager.state == CBCentralManagerStatePoweredOn) && (false == self.scanInProcess))
    {
        if (self.legacyDevices)
            [self.myCBCentralManager scanForPeripheralsWithServices:@[[CBUUID UUIDWithString: kDynamicPerceptionOldServiceUDID]]
                                                            options:nil];
        else
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
    self.myDevices = [NSMutableArray arrayWithCapacity: 3];
}

- (void)isInReview {
    
    inReview = YES;
}

- (void)notInReview {
    
    inReview = NO;
}

- (NSArray *) deviceList {

    return [NSArray arrayWithArray: self.myDevices];
}

@end
