//
//  DurationViewController.h
//  Joystick
//
//  Created by Mark Zykin on 11/26/14.
//  Copyright (c) 2014 Dynamic Perception. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppExecutive.h"

NSString static	*kDurationInfoKeyTitle		= @"kDurationInfoKeyTitle";
NSString static	*kDurationInfoKeyName		= @"kDurationInfoKeyName";
NSString static	*kDurationInfoKeyNumber		= @"kDurationInfoKeyNumber";
NSString static	*kDurationInfoKeyString		= @"kDurationInfoKeyString";


@protocol DurationDelegate

- (void) updateDurationInfo: (NSDictionary *) info;

@end


@interface DurationViewController : UIViewController  <UIPickerViewDelegate, UIPickerViewDataSource> {

    float per1;
    float per2;
    float per3;
}

@property (nonatomic, assign)	id <DurationDelegate>	delegate;
@property (nonatomic, strong)	NSDictionary *			userInfo;

@property (nonatomic, strong)				AppExecutive *	appExecutive;

@property bool isMotorSegue;

#pragma mark Class Query

+ (NSString *) stringForDuration: (NSInteger) duration;


@end
