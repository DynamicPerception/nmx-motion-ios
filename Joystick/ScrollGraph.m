//
//  ScrollGraph.m
//  Joystick
//
//  Created by Randall Ridley on 7/22/15.
//  Copyright (c) 2015 Mark Zykin. All rights reserved.
//

#import "ScrollGraph.h"

@implementation ScrollGraph


@synthesize frame1, frame2, frame3, frame4, frameCount;

- (void) drawRect:(CGRect)rect {
    
    float graphWidth = self.frame.size.width;
    float graphHeight = self.frame.size.height;
    float graphWidthPercentage = graphWidth/frameCount;
    
    
    //    NSLog(@"graphWidth: %f",graphWidth);
    //    NSLog(@"graphWidthPercentage: %f",graphWidthPercentage);
    
    //int frameLblX = 5;
    
    
    UIFont *myFont7 = [ UIFont fontWithName: @"Arial" size: 6.0 ];
    
    for (int i = 0; i < frameCount; i++) {
        
        BOOL isMultipleOfTen = !(i % 10);
        
        if (isMultipleOfTen && i > 0) {
            
            UILabel *marker = [[UILabel alloc] initWithFrame:CGRectMake(i, self.frame.size.height - 25, 20, 20)];
            marker.text = [NSString stringWithFormat:@"%i",i];
            
            marker.font = myFont7;
            [self addSubview:marker];
        }
    }
    
    float frame1Pixel = frame1*graphWidthPercentage;
    float frame2Pixel = frame2*graphWidthPercentage;
    float frame3Pixel = frame3*graphWidthPercentage;
    float frame4Pixel = frame4*graphWidthPercentage;
    
    
    
    
    
    
    
    //Draw graph
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetStrokeColorWithColor(context, [UIColor redColor].CGColor);
    
    // Draw them with a 2.0 stroke width so they are a bit more visible.
    
    CGContextSetLineWidth(context, 2.0f);
    
    //CGContextMoveToPoint(context, 0.0f, graphHeight); //start at this point
    
    CGContextMoveToPoint(context, frame1Pixel, graphHeight - 30.0f); //draw to this point
    CGContextAddLineToPoint(context, frame2Pixel, graphHeight - 70.0f); //draw to this point
    CGContextAddLineToPoint(context, frame3Pixel, graphHeight - 70.0f); //draw to this point
    CGContextAddLineToPoint(context, frame4Pixel, graphHeight - 30.0f); //draw to this point
    
    //CGContextAddLineToPoint(context, graphWidth-3.0f, 20.0f); //draw to this point end of graph
    
    // and now draw the Path!
    
    CGContextStrokePath(context);
    
    
    [self setContentSize:CGSizeMake(self.frame.size.width + 1000.0f, self.frame.size.height)];
}

@end
