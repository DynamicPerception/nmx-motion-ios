//
//  MotorRampingView.m
//  Joystick
//
//  Created by Mark Zykin on 4/23/15.
//  Copyright (c) 2015 Mark Zykin. All rights reserved.
//

#import "MotorRampingView.h"

@implementation MotorRampingView

@synthesize increaseStart;
@synthesize increaseFinal;
@synthesize decreaseStart;
@synthesize decreaseFinal;

- (void) setViewWidth: (CGFloat) width {

	CGRect	frame	= self.frame;
	CGSize	size	= self.frame.size;

	size.width = width;
	frame.size = size;
	self.frame = frame;
}

- (void) drawRect: (CGRect) rect {

	CGMutablePathRef	increasePath	= CGPathCreateMutable();
	CGMutablePathRef	decreasePath	= CGPathCreateMutable();
	CGContextRef 		currentContext	= UIGraphicsGetCurrentContext();
	CGColorRef			lineColor		= [[UIColor grayColor] CGColor];

	CGPathMoveToPoint(increasePath, NULL, self.increaseStart.x, self.increaseStart.y);
	CGPathAddLineToPoint(increasePath, NULL, self.increaseFinal.x, self.increaseFinal.y);
	CGContextAddPath(currentContext, increasePath);

	CGPathMoveToPoint(decreasePath, NULL, self.decreaseStart.x, self.decreaseStart.y);
	CGPathAddLineToPoint(decreasePath, NULL, self.decreaseFinal.x, self.decreaseFinal.y);
	CGContextAddPath(currentContext, decreasePath);

	CGContextSetLineWidth(currentContext, 2.0);
	CGContextClosePath(currentContext);
	CGContextSetStrokeColorWithColor(currentContext, lineColor);
	CGContextDrawPath(currentContext, kCGPathStroke);

	CGPathRelease(increasePath);
	CGPathRelease(decreasePath);
}


@end
