//
//  FrameCountViewController.h
//  Joystick
//
//  Created by Mark Zykin on 12/19/14.
//  Copyright (c) 2014 Dynamic Perception. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MotorRampingDelegate <NSObject>

- (void)saveFrame: (NSNumber *)number;

@end


@interface FrameCountViewController : UIViewController <UIPickerViewDelegate, UIPickerViewDataSource> {

}

@property bool isMotorSegue;
@property bool isRampingScreen;
@property int currentFrameValue;

@property (nonatomic, assign) id <MotorRampingDelegate> myDelegate;

@end
