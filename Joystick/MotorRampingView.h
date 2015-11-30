//
//  MotorRampingView.h
//  Joystick
//
//  Created by Mark Zykin on 4/23/15.
//  Copyright (c) 2015 Mark Zykin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MotorRampingView : UIView

@property (nonatomic, readwrite)	CGPoint	increaseStart;
@property (nonatomic, readwrite)	CGPoint	increaseFinal;
@property (nonatomic, readwrite)	CGPoint	decreaseStart;
@property (nonatomic, readwrite)	CGPoint	decreaseFinal;

- (void) setViewWidth: (CGFloat) width;

@end
