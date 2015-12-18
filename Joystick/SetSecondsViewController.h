//
//  SetSecondsViewController.h
//  Joystick
//
//  Created by Mark Zykin on 12/23/14.
//  Copyright (c) 2014 Mark Zykin. All rights reserved.
//

#import <UIKit/UIKit.h>

NSString	static	*kSetSecondsForFocus		= @"kSetSecondsForFocus";
NSString	static	*kSetSecondsForTrigger		= @"kSetSecondsForTrigger";
NSString	static	*kSetSecondsForDelay		= @"kSetSecondsForDelay";


@interface SetSecondsViewController : UIViewController <UIPickerViewDelegate, UIPickerViewDataSource>

@property (nonatomic, assign)	NSString *	variableToSet;

@end
