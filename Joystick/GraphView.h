//
//  GraphView.h
//  Joystick
//
//  Created by Randall Ridley on 7/22/15.
//  Copyright (c) 2015 Mark Zykin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GraphView : UIView {

    float frame1Pixel;
    float frame2Pixel;
    float frame3Pixel;
    float frame4Pixel;
    float graphWidth;
    float graphHeight;
}

@property bool isVideo;
@property (strong, nonatomic) NSString *videoLength;

@property float frame1;
@property float frame2;
@property float frame3;
@property float frame4;
@property float frameCount;

@property BOOL is3P;

@property (strong, nonatomic) NSString *headerString;

@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;

@end
