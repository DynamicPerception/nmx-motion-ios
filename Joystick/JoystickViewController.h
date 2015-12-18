//
//  JoystickViewController.h
//  joystick
//
//  Created by Mark Zykin on 10/1/14.
//  Copyright (c) 2014 Dynamic Perception. All rights reserved.
//

#import <UIKit/UIKit.h>

#pragma mark Protocols

@protocol JoystickOutput

- (void) joystickPosition: (CGPoint) position;

@end

@interface JoystickViewController : UIViewController {

    UIImageView *rollerballImageView;
    
    float startX;
    float startY;
    float lastX;
    float lastY;
    float halfX;
    float halfY;
    bool leftRight;
    NSTimer *timer;
    float distX;
    float distY;
    bool upDown;
    UILabel *panTiltLbl;
}

#pragma mark Public Properties

- (void) updateJoystickDelegate: (CGPoint) viewLocation;

@property (nonatomic, assign)	id <JoystickOutput>	delegate;

@property bool axisLocked;
@property CGPoint vl;
@property (nonatomic, strong) UIImageView *degreeCircle;

@end
