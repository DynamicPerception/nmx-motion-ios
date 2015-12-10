//
//  DrawTest.m
//  Joystick
//
//  Created by Randall Ridley on 7/22/15.
//  Copyright (c) 2015 Mark Zykin. All rights reserved.
//

#import "DrawTest.h"

@interface DrawTest ()

@end

@implementation DrawTest

@synthesize graphView, panGraph, tiltGraph, playheadView, scrollView;

- (void) viewDidLoad {
    
    masterFrameCount = 1000;
    
     NSLog(@"screen width: %f",self.view.frame.size.width);
    
    graphWidth = graphView.frame.size.width;
    
     NSLog(@"graphWidth: %f",graphWidth);
    
    progressInterval = graphWidth/masterFrameCount;
    
    NSLog(@"progressInterval: %f",progressInterval);
    
    
//    NSMutableData *data1, *data2;
//    NSString *myString = @"string for data1";
//    NSString *yourString = @"string for data2";
//    
//    const char *utfMyString = [myString UTF8String];
//    const char *utfYourString = [yourString UTF8String];
//    
//    unsigned char *firstBuffer, secondBuffer[20];
//    
//    /* initialize data1, data2, and secondBuffer... */
//    
//    data1 = [NSMutableData dataWithBytes:utfMyString length:strlen(utfMyString)+1];
//    data2 = [NSMutableData dataWithBytes:utfYourString length:strlen(utfYourString)+1];
//    
//    [data2 getBytes:secondBuffer length:20];
//    
//    NSLog(@"data2 before: \"%s\"\n", (char *)secondBuffer);
//    
//    firstBuffer = [data2 mutableBytes];
//    
//    [data1 getBytes:firstBuffer length:[data2 length]];
//    
//    NSLog(@"data1: \"%s\"\n", (char *)firstBuffer);
//    
//    [data2 getBytes:secondBuffer length:20];
//    
//    NSLog(@"data2 after: \"%s\"\n", (char *)secondBuffer);
    
    
    
    
    
    [self initVars];
    
    
    //[NSTimer scheduledTimerWithTimeInterval:1.0/10.0 target:self selector:@selector(timerName2) userInfo:nil repeats:YES];
    
    
    [super viewDidLoad];
}




- (void) timerName2 {
    
    //NSLog(@"playheadView width: %f",playheadView.frame.size.width);
    
    //NSLog(@"lastX: %f",lastX);
    
    float offset = graphWidth + playheadView.frame.size.width + 15;
    
    if (lastX < offset) {
        
        playheadView.frame = CGRectMake(lastX, playheadView.frame.origin.y, playheadView.frame.size.width, playheadView.frame.size.height);
        
        lastX = lastX + progressInterval;
    }
    else
    {
        [playheadTimer invalidate];
    }
}

- (void) initVars {

    //    285 - 150 = x * 150;
    //    135 = x * 150;
    //    135/150 = x;
    
    //    float f2 = textFloat - (selectedFrameCount/2);
    //    float f3 = f2 / (selectedFrameCount/2);
    
    float slideIn1 = 0.408547;
    float slideIn2 = 0.7811965;
    float slideDe1 = 0.3076923;
    float slideDe2 = 0.9452992;
    
    
    float calcFirstSlideIncreasePoint = slideIn1/2;
    float calcSecondSlideIncreasePoint = slideIn2/2;
    
    float calcFirstSlideDecreasePoint = slideDe1/2+.5;
    float calcSecondSlideDecreasePoint = slideDe2/2+.5;
    
//    NSLog(@"calcFirstSlideIncreasePoint: %f",calcFirstSlideIncreasePoint);
//    NSLog(@"calcSecondSlideIncreasePoint: %f",calcSecondSlideIncreasePoint);
//    
//    NSLog(@"calcFirstSlideDecreasePoint: %f",calcFirstSlideDecreasePoint);
//    NSLog(@"calcSecondSlideDecreasePoint: %f",calcSecondSlideDecreasePoint);
    
    
    graphView.frame1 = calcFirstSlideIncreasePoint;
    graphView.frame2 = calcSecondSlideIncreasePoint;
    graphView.frame3 = calcFirstSlideDecreasePoint;
    graphView.frame4 = calcSecondSlideDecreasePoint;
    
    
    //    graphView.frame1 = .15;
    //    graphView.frame2 = .25;
    //    graphView.frame3 = .66;
    //    graphView.frame4 = .77;
    graphView.headerString = @"Slider";
    
    graphView.frameCount = masterFrameCount;
    
    
    float panIn1 = 0.1145299;
    float panIn2 = 0.842735;
    float panDe1 = 0.4615385;
    float panDe2 = 0.565812;
    
    
    float calcFirstPanIncreasePoint = panIn1/2;
    float calcSecondPanIncreasePoint = panIn2/2;
    
    float calcFirstPanDecreasePoint = panDe1/2+.5;
    float calcSecondPanDecreasePoint = panDe2/2+.5;
    
    
    panGraph.frame1 = calcFirstPanIncreasePoint;
    panGraph.frame2 = calcSecondPanIncreasePoint;
    panGraph.frame3 = calcFirstPanDecreasePoint;
    panGraph.frame4 = calcSecondPanDecreasePoint;
    
    
    //    panGraph.frame1 = .25;
    //    panGraph.frame2 = .35;
    //    panGraph.frame3 = .76;
    //    panGraph.frame4 = .97;
    panGraph.headerString = @"Pan";
    
    panGraph.frameCount = masterFrameCount;
    
    
    float tiltIn1 = 0.0;
    float tiltIn2 = 0.4786325;
    float tiltDe1 = 0.2017094;
    float tiltDe2 = 0.7333333;
    
    
    float calcFirstTiltIncreasePoint = tiltIn1/2;
    float calcSecondTiltIncreasePoint = tiltIn2/2;
    
    float calcFirstTiltDecreasePoint = tiltDe1/2+.5;
    float calcSecondTiltDecreasePoint = tiltDe2/2+.5;
    
    tiltGraph.frame1 = calcFirstTiltIncreasePoint;
    tiltGraph.frame2 = calcSecondTiltIncreasePoint;
    tiltGraph.frame3 = calcFirstTiltDecreasePoint;
    tiltGraph.frame4 = calcSecondTiltDecreasePoint;

    //    tiltGraph.frame1 = .05;
    //    tiltGraph.frame2 = .45;
    //    tiltGraph.frame3 = .56;
    //    tiltGraph.frame4 = .87;
    
    tiltGraph.headerString = @"Tilt";
    
    tiltGraph.frameCount = masterFrameCount;
    
    lastX = playheadView.frame.origin.x;
    
    //    [[NSNotificationCenter defaultCenter]
    //	 addObserver:self
    //	 selector:@selector(handleNotification:)
    //	 name:@"note" object:nil];
}

- (void) timerName {
    
    //NSLog(@"playheadView width: %f",playheadView.frame.size.width);
    
    //NSLog(@"lastX: %f",lastX);
    
    //NSLog(@"graphView width: %f",graphView.frame.size.width);
    
    float offset = graphView.frame.size.width + playheadView.frame.size.width + 15;
    
    if (lastX < offset) {
        
        playheadView.frame = CGRectMake(lastX, playheadView.frame.origin.y, playheadView.frame.size.width, playheadView.frame.size.height);
        
        lastX = lastX + 10;
    }
    else
    {
        [playheadTimer invalidate];
    }
}

//    2015-07-23 11:17:03.382 NMX Motion[30361:3430029] slideIncrease: (
//                                                                      "0.408547",
//                                                                      "0.7811965"
//                                                                      )
//    2015-07-23 11:17:03.383 NMX Motion[30361:3430029] slideDecrease: (
//                                                                      "0.3076923",
//                                                                      "0.9452992"
//                                                                      )
//    2015-07-23 11:17:03.387 NMX Motion[30361:3430029] panIncrease: (
//                                                                    "0.1145299",
//                                                                    "0.842735"
//                                                                    )
//    2015-07-23 11:17:03.388 NMX Motion[30361:3430029] panDecrease: (
//                                                                    "0.4615385",
//                                                                    "0.565812"
//                                                                    )
//    2015-07-23 11:17:03.389 NMX Motion[30361:3430029] tiltIncrease: (
//                                                                     0,
//                                                                     "0.4786325"
//                                                                     )
//    2015-07-23 11:17:03.389 NMX Motion[30361:3430029] tiltDecrease: (
//                                                                     "0.2017094",
//                                                                     "0.7333333"
//

- (void) didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
}

@end
