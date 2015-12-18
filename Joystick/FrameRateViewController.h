//
//  FrameRateViewController.h
//  Joystick
//
//  Created by Mark Zykin on 12/11/14.
//  Copyright (c) 2014 Dynamic Perception. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol FrameRateDelegate

- (void) updateFrameRateNumber: (NSNumber *) number;

@end


@interface FrameRateViewController : UIViewController <UIPickerViewDelegate, UIPickerViewDataSource>

@property (nonatomic, assign)	id <FrameRateDelegate>	delegate;
@property (nonatomic, strong)	NSNumber *				frameRate;


@end
