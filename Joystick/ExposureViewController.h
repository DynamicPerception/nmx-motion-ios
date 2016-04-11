//
//  ExposureViewController.h
//  Joystick
//
//  Created by Mark Zykin on 11/26/14.
//  Copyright (c) 2014 Dynamic Perception. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol ExposureDelegate

- (void) updateExposureNumber: (NSNumber *) number;

@end


@interface ExposureViewController : UIViewController <UIPickerViewDelegate, UIPickerViewDataSource>

@property (nonatomic, assign)	id <ExposureDelegate>	delegate;
@property (nonatomic, strong)	NSNumber *				exposure;


#pragma mark Class Query

+ (NSString *) stringForExposure: (NSInteger) exposure;


@end
