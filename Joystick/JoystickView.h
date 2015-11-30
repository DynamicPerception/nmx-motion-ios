//
//  JoystickView.h
//  Joystick
//
//  Created by Mark Zykin on 10/2/14.
//  Copyright (c) 2014 Dynamic Perception. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JoystickView : UIView


#pragma mark Public Properties

@property (nonatomic, readwrite)	CGPoint		joystickViewPoint;
@property (nonatomic, readwrite)	CGPoint		joystickPosition;
@property (nonatomic, assign)		NSString *	thumbImageFile;
@property (nonatomic, strong)		UIImage *	thumbImage;

#pragma mark Object Operations

- (void) setupTransforms;


@end
