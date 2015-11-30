//
//  NMXDeviceManager.h
//  DP Test
//
//  Created by Dave Koziol on 9/16/14.
//  Copyright (c) 2014 Dynamic Perception. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "NMXDevice.h"

@protocol NMXDeviceManagerDelegate <NSObject>

@optional

- (void) didDiscoverDevice: (NMXDevice *) device;
- (void) didDisconnectDevice: (CBPeripheral *) device;

@end

@interface NMXDeviceManager : NSObject <CBCentralManagerDelegate> {

}

- (void) startScanning: (BOOL) inLegacyDevices;
- (void) stopScanning;
- (NSArray *) deviceList;

- (void)isInReview;
- (void)notInReview;

@property (atomic, strong) id<NMXDeviceManagerDelegate> delegate;
@property bool inReview;

@end


