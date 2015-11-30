//
//  GraphView.m
//  Joystick
//
//  Created by Randall Ridley on 7/22/15.
//  Copyright (c) 2015 Mark Zykin. All rights reserved.
//

#import "GraphView.h"

@implementation GraphView

@synthesize frame1, frame2, frame3, frame4, frameCount, scrollView, headerString, isVideo, videoLength, is3P;

- (void)drawRect:(CGRect)rect {
    
    if (is3P)
    {
        //NSLog(@"is3P graphview");
        [self go3P];
    }
    else
    {
        //NSLog(@"is2P graphview");
        [self go];
    }    
}

- (void)go3P {
    
    graphWidth = self.frame.size.width;
    graphHeight = self.frame.size.height;
    
    //.15 * 1000 = 150;
    
    frame1Pixel = frame1/frameCount * graphWidth;
    frame2Pixel = frame2/frameCount * graphWidth;
    frame3Pixel = frame3/frameCount * graphWidth;
    
    float bottomPadding = 20.0f;
    bottomPadding = 0.0f;
    
    UIFont *myFont7 = [UIFont boldSystemFontOfSize: 8.0];
    UIFont *myBold12Font = [UIFont boldSystemFontOfSize:12];
    
    UILabel *header = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0, graphWidth, 20)];
    header.text = headerString;
    header.font = myBold12Font;
    header.textAlignment = NSTextAlignmentCenter;
    header.textColor = [UIColor whiteColor];
    
    [self addSubview:header];
    
    UILabel *marker1 = [[UILabel alloc] initWithFrame:CGRectMake(5.0f, graphHeight - 10, 30, 10)];
    
    marker1.font = myFont7;
    marker1.textAlignment = NSTextAlignmentLeft;
    marker1.textColor = [UIColor whiteColor];
    
    UILabel *marker2 = [[UILabel alloc] initWithFrame:CGRectMake(graphWidth - 35.0f, graphHeight - 10, 30, 10)];
    
    marker2.font = myFont7;
    marker2.textAlignment = NSTextAlignmentRight;
    marker2.textColor = [UIColor whiteColor];
    
    if (isVideo)
    {
        marker1.text = @"00:00";
        marker2.text = videoLength;
    }
    else
    {
        marker1.text = @"1";
        marker2.text = [NSString stringWithFormat:@"%i",(int)frameCount];
    }
    
    [self addSubview:marker1];
    [self addSubview:marker2];
    
    //Draw graph
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetStrokeColorWithColor(context, [UIColor blueColor].CGColor);
    
    CGContextSetLineWidth(context, 2.0f);
    
    CGContextMoveToPoint(context, 0, graphHeight/2); //draw to this point
    
    CGContextAddLineToPoint(context, self.frame.size.width, graphHeight/2); //draw to this point
    
    CGContextStrokePath(context);
    
    CAShapeLayer *increaseCircle = [CAShapeLayer layer];
    [increaseCircle setPath:[[UIBezierPath bezierPathWithOvalInRect:CGRectMake(frame1Pixel-3.5f, (graphHeight/2)-3, 7, 7)] CGPath]];
    [increaseCircle setStrokeColor:[[UIColor clearColor] CGColor]];
    [increaseCircle setFillColor:[[UIColor whiteColor] CGColor]];
    [[self layer] addSublayer:increaseCircle];
    
    CAShapeLayer *decreaseCircle = [CAShapeLayer layer];
    [decreaseCircle setPath:[[UIBezierPath bezierPathWithOvalInRect:CGRectMake(frame2Pixel-3.5f, (graphHeight/2)-3, 7, 7)] CGPath]];
    [decreaseCircle setStrokeColor:[[UIColor clearColor] CGColor]];
    [decreaseCircle setFillColor:[[UIColor whiteColor] CGColor]];
    [[self layer] addSublayer:decreaseCircle];
    
    CAShapeLayer *decreaseCircle2 = [CAShapeLayer layer];
    [decreaseCircle2 setPath:[[UIBezierPath bezierPathWithOvalInRect:CGRectMake(frame3Pixel-3.5f, (graphHeight/2)-3, 7, 7)] CGPath]];
    [decreaseCircle2 setStrokeColor:[[UIColor clearColor] CGColor]];
    [decreaseCircle2 setFillColor:[[UIColor whiteColor] CGColor]];
    [[self layer] addSublayer:decreaseCircle2];
}

- (void)go {

    graphWidth = self.frame.size.width;
    graphHeight = self.frame.size.height;
    
    //.15 * 1000 = 150;
    
    frame1Pixel = frame1 * graphWidth;
    frame2Pixel = frame2 * graphWidth;
    frame3Pixel = frame3 * graphWidth;
    frame4Pixel = frame4 * graphWidth;
    
    float bottomPadding = 20.0f;
    bottomPadding = 0.0f;
    
    UIFont *myFont7 = [UIFont boldSystemFontOfSize: 8.0];
    UIFont *myBold12Font = [UIFont boldSystemFontOfSize:12];
    
    UILabel *header = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0, graphWidth, 20)];
    header.text = headerString;
    header.font = myBold12Font;
    header.textAlignment = NSTextAlignmentCenter;
    header.textColor = [UIColor whiteColor];
    
    [self addSubview:header];
    
    UILabel *marker1 = [[UILabel alloc] initWithFrame:CGRectMake(5.0f, graphHeight - 10, 30, 10)];
    
    marker1.font = myFont7;
    marker1.textAlignment = NSTextAlignmentLeft;
    marker1.textColor = [UIColor whiteColor];
    
    UILabel *marker2 = [[UILabel alloc] initWithFrame:CGRectMake(graphWidth - 35.0f, graphHeight - 10, 30, 10)];
    
    marker2.font = myFont7;
    marker2.textAlignment = NSTextAlignmentRight;
    marker2.textColor = [UIColor whiteColor];
    
    if (isVideo)
    {
        marker1.text = @"00:00";
        marker2.text = videoLength;
    }
    else
    {
        marker1.text = @"1";
        marker2.text = [NSString stringWithFormat:@"%i",(int)frameCount];
    }
    
    [self addSubview:marker1];
    [self addSubview:marker2];
    
    //Draw graph
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetStrokeColorWithColor(context, [UIColor blueColor].CGColor);
        
    CGContextSetLineWidth(context, 2.0f);
    
    CGContextMoveToPoint(context, frame1Pixel, graphHeight - bottomPadding); //draw to this point
    
    CGContextAddLineToPoint(context, frame2Pixel, graphHeight - 45.0f); //draw to this point
    CGContextAddLineToPoint(context, frame3Pixel, graphHeight - 45.0f); //draw to this point
    CGContextAddLineToPoint(context, frame4Pixel, graphHeight - bottomPadding); //draw to this point
    
    CGContextStrokePath(context);
    
    CAShapeLayer *increaseCircle = [CAShapeLayer layer];
    [increaseCircle setPath:[[UIBezierPath bezierPathWithOvalInRect:CGRectMake(frame2Pixel-3.5f, graphHeight - 48.0f, 7, 7)] CGPath]];
    [increaseCircle setStrokeColor:[[UIColor clearColor] CGColor]];
    [increaseCircle setFillColor:[[UIColor whiteColor] CGColor]];
    [[self layer] addSublayer:increaseCircle];
    
    CAShapeLayer *decreaseCircle = [CAShapeLayer layer];
    [decreaseCircle setPath:[[UIBezierPath bezierPathWithOvalInRect:CGRectMake(frame3Pixel-3.5f, graphHeight - 48.0f, 7, 7)] CGPath]];
    [decreaseCircle setStrokeColor:[[UIColor clearColor] CGColor]];
    [decreaseCircle setFillColor:[[UIColor whiteColor] CGColor]];
    [[self layer] addSublayer:decreaseCircle];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {

    UITouch *t = [[event allTouches] anyObject];
    CGPoint loc = [t locationInView:[t view]];
    
    float loc2 = loc.x/graphWidth;
    
    NSLog(@"loc x: %f",loc.x);
    NSLog(@"loc2 x: %.02f",loc2);
    
    frame2Pixel = loc2;
    
    self.layer.sublayers = nil;
    
    //CGContextRef context = UIGraphicsGetCurrentContext();
    //CGContextClearRect(context,self.frame);
    
    //[self go];
    //[self setNeedsDisplay];
}

@end
