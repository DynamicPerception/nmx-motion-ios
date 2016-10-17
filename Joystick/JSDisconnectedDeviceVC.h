//
//  JSDisconnectedDeviceVC.h
//  Joystick
//
//  Created by Mitch Middler on 8/10/16.
//  Copyright © 2016 Dynamic Perception. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NMXDeviceManager.h"


@protocol JSDisconnectedDeviceDelegate <NSObject>

- (void) abortReconnect;
- (void) willAbortReconnect;

@end


@interface JSDisconnectedDeviceVC : UIViewController <UITableViewDataSource, UITableViewDelegate,
                                                      NMXDeviceManagerDelegate, NMXDeviceDelegate, UIAlertViewDelegate>

- (void) reloadDeviceList;

@property id<JSDisconnectedDeviceDelegate> delegate;

@end
