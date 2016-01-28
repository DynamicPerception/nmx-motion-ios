//
//  SetSecondsViewController.h
//  Joystick
//
//  Created by Mark Zykin on 12/23/14.
//  Copyright (c) 2014 Mark Zykin. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SecondsViewDelegate <NSObject>

- (NSInteger)  getIntegerValueForSecondsView;
- (void)       setNumberValueForSecondsView : (NSNumber *)number;
- (NSString *) getTitleTextForSecondsView;
- (int)        getTensLimitForSecondsView;
- (int)        getOnesLimitForSecondsView;
- (int)        getMaximumMillisecondsForSecondsView;

@end


@interface SetSecondsViewController : UIViewController <UIPickerViewDelegate, UIPickerViewDataSource>

@property (nonatomic, weak) id<SecondsViewDelegate> delegate;

@end
