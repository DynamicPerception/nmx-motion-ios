//
//  BacklashViewController.h
//  Joystick
//
//  Created by Mark Zykin on 4/6/15.
//  Copyright (c) 2015 Mark Zykin. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol BacklashDelegate

- (void) updateBacklash: (NSInteger) value;

@end


@interface BacklashViewController : UIViewController  <UIPickerViewDelegate, UIPickerViewDataSource>

@property (nonatomic, assign)		id <BacklashDelegate>	delegate;
@property (nonatomic, readwrite)	NSInteger				backlash;


@end
