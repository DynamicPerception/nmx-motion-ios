//
//  CameraSettingsTimelineView.h
//  Joystick
//
//  Created by Mitch Middler on 2/3/16.
//  Copyright © 2016 Dynamic Perception. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CameraSettingsTimelineView : UIControl

- (void) setCameraTimesForFocus:(float) focus trigger:(float)trigger delay:(float)delay buffer:(float)bufer animated:(BOOL)animated;
- (void) startPlayheadAnimation;
- (void) stopPlayheadAnimation;

+ (UIColor *)focusColor;
+ (UIColor *)triggerColor;
+ (UIColor *)delayColor;
+ (UIColor *)bufferColor;
+ (UIColor *)intervalColor;
+ (UIColor *)exposureColor;


@end
