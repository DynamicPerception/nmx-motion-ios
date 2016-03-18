//
//  HSpline.h
//  Joystick
//
//  Created by Mitch Middler on 3/15/16.
//  Copyright © 2016 Dynamic Perception. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface KeyFrameModel : NSObject

@property float time;
@property float position;
@property float velocity;

@end


@interface HSpline : NSObject

- (void) optimizePointVelForAxis:(NSMutableArray<KeyFrameModel *> *)keyframes;

@property float velocityIncrement;

@end
