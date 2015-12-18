//
//  ShortDurationViewController.h
//  Joystick
//
//  Created by Mark Zykin on 12/5/14.
//  Copyright (c) 2014 Dynamic Perception. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppExecutive.h"

NSString static	*kShortDurationInfoKeyTitle		= @"kShortDurationInfoKeyTitle";
NSString static	*kShortDurationInfoKeyName		= @"kShortDurationInfoKeyName";
NSString static	*kShortDurationInfoKeyNumber	= @"kShortDurationInfoKeyNumber";
NSString static	*kShortDurationInfoKeyString	= @"kShortDurationInfoKeyString";


@protocol ShortDurationDelegate

- (void) updateShortDurationInfo: (NSDictionary *) info;

@end


@interface ShortDurationViewController : UIViewController  <UIPickerViewDelegate, UIPickerViewDataSource> {

    NSNumber *videoLength;
    float per1;
    float per2;
    float per3;
}

@property (nonatomic, assign)	id <ShortDurationDelegate>	delegate;
@property (nonatomic, strong)	NSDictionary *				userInfo;

@property bool isReviewShotTimerSegue;
@property bool isMotorSegue;
@property bool isSettingVideoFrame;
@property int isMotorSegueVal;
@property int selectedVideoFrame;

@property (strong, nonatomic) IBOutlet UILabel *subheaderLbl;

@property (nonatomic, strong)				AppExecutive *	appExecutive;

#pragma mark Class Query

+ (NSString *) stringForShortDuration: (NSInteger) duration;


@end
