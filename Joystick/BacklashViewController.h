//
//  BacklashViewController.h
//  Joystick
//
//  Created by Mark Zykin on 4/6/15.
//  Copyright (c) 2015 Mark Zykin. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol IntValueDelegate

- (void) updateIntValue: (NSInteger) value;

@end


@interface BacklashViewController : UIViewController  <UIPickerViewDelegate, UIPickerViewDataSource>

@property (nonatomic, assign)		id <IntValueDelegate>	delegate;
@property (nonatomic, readwrite)	NSInteger				value;
@property int maxValue;
@property int minValue;
@property int digits;
@property NSString *titleString;
@property NSDictionary *customRigRatioPreset;

@end
