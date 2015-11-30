//
//  DrawTest.h
//  Joystick
//
//  Created by Randall Ridley on 7/22/15.
//  Copyright (c) 2015 Mark Zykin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GraphView.h"

@interface DrawTest : UIViewController {

    float lastX;
    NSTimer *playheadTimer;
    float masterFrameCount;
    float progressInterval;
    float graphWidth;
}

@property (strong, nonatomic) IBOutlet GraphView *graphView;
@property (strong, nonatomic) IBOutlet GraphView *panGraph;
@property (strong, nonatomic) IBOutlet GraphView *tiltGraph;
@property (strong, nonatomic) IBOutlet UIView *playheadView;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;

@end
