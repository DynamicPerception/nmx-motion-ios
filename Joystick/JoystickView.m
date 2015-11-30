//
//  JoystickView.m
//  Joystick
//
//  Created by Mark Zykin on 10/2/14.
//  Copyright (c) 2014 Dynamic Perception. All rights reserved.
//

#import "JoystickView.h"


//------------------------------------------------------------------------------

#pragma mark - Private Interface


@interface JoystickView () {
    
	CGAffineTransform	CGAffineTransformZero;

	CGAffineTransform	unitToScreen;
	CGAffineTransform	screenToUnit;

	CGAffineTransform	unitToVirtual;
	CGAffineTransform	virtualToUnit;

	CGAffineTransform	screenToVirtual;
	CGAffineTransform	virtualToScreen;

	CGAffineTransform	viewToScreen;
	CGAffineTransform	screenToView;

	CGAffineTransform	viewToVirtual;
	CGAffineTransform	virtualToView;
}

@property (nonatomic, readwrite)	CGRect			virtualBounds;
@property (nonatomic, strong)		NSArray *		xAxisLine;
@property (nonatomic, strong)		NSArray *		yAxisLine;
@property (nonatomic, strong)		NSArray *		circle;
@property (nonatomic, strong)		UIImageView *	thumbImageView;
@property (nonatomic, strong)		UIImageView *	rollerballImageView;

@end


//------------------------------------------------------------------------------

#pragma mark - Implementation


@implementation JoystickView


#pragma mark - Public Property Synthesis

@synthesize joystickViewPoint;
@synthesize joystickPosition;
@synthesize thumbImageFile;
@synthesize thumbImage;


#pragma mark - Private Property Synthesis

@synthesize virtualBounds;
@synthesize xAxisLine;
@synthesize yAxisLine;
@synthesize circle;
@synthesize thumbImageView,rollerballImageView;


#pragma mark - Public Property Methods


- (CGPoint) joystickPosition {
    
	CGPoint	virtualPoint = CGPointApplyAffineTransform(self.joystickViewPoint, viewToVirtual);

	joystickPosition = CGPointLimit(virtualPoint);

	return joystickPosition;
}

- (void) setJoystickPosition: (CGPoint) virtualPoint {
    
	joystickPosition = CGPointLimit(virtualPoint);

	self.joystickViewPoint = CGPointApplyAffineTransform(joystickPosition, virtualToView);
}

- (void) setThumbImage: (UIImage *) image {
    
    //NSLog(@"setThumbImage");
    
	thumbImage = image;

	if (self.thumbImage)
	{
        if (thumbImageView)
            [thumbImageView removeFromSuperview];
        
        self.thumbImageView	= [[UIImageView alloc] initWithImage: image];

		[self addSubview: thumbImageView];
	}
}

#pragma mark - Private Property Methods

- (NSArray *) xAxisLine {
    
    NSLog(@"xAxisLine");
    
	if (xAxisLine == nil)
	{
		CGPoint		point0	= CGPointMake(-1, 0);
		CGPoint		point1	= CGPointMake(+1, 0);

		xAxisLine = [JoystickView arrayWithPoints: &point0, &point1, nil];
	}

	return xAxisLine;
}

- (NSArray *) yAxisLine {
    
	if (yAxisLine == nil)
	{
		CGPoint		point0	= CGPointMake(0, -1);
		CGPoint		point1	= CGPointMake(0, +1);

		yAxisLine = [JoystickView arrayWithPoints: &point0, &point1, nil];
	}

	return yAxisLine;
}

- (NSArray *) circle {
    
	if (circle == nil)
	{
		NSMutableArray *	array	= [NSMutableArray array];
		CGFloat				dtheta	= 2.0 * M_PI / 36.0;

		for (NSInteger index = 0; index <= 36; index++)
		{
			CGFloat	theta	= dtheta * index;
			CGFloat	x		= cosf(theta);
			CGFloat y		= sinf(theta);
			CGPoint	point	= CGPointMake(x, y);

			[array addObject: [NSValue valueWithCGPoint: point]];
		}

		circle = [NSArray arrayWithArray: array];
	}

	return  circle;
}


//------------------------------------------------------------------------------

#pragma mark - Object Management


- (void) awakeFromNib {
    
	CGAffineTransformZero = CGAffineTransformMake(0, 0, 0, 0, 0, 0);

	return;
}

//------------------------------------------------------------------------------

#pragma mark - Object Operations


- (void) setupTransforms {
    
	CGPoint		screenOrigin	= self.bounds.origin;
	CGSize		screenSize		= self.bounds.size;
    
    //NSLog(@"screenSize: %f x %f",screenSize.width,screenSize.height);
    
	[self setupVirtualBounds];

	CGPoint		virtualOrigin	= self.virtualBounds.origin;
	CGSize		virtualSize		= self.virtualBounds.size;

	unitToScreen = CGAffineTransformMake(screenSize.width, 0, 0, screenSize.height, screenOrigin.x, screenOrigin.y);
	screenToUnit = CGAffineTransformInvert(unitToScreen);

	unitToVirtual = CGAffineTransformMake(virtualSize.width, 0, 0, virtualSize.height, virtualOrigin.x, virtualOrigin.y);
	virtualToUnit = CGAffineTransformInvert(unitToVirtual);

	screenToVirtual = CGAffineTransformConcat(screenToUnit, unitToVirtual);
	virtualToScreen = CGAffineTransformConcat(virtualToUnit, unitToScreen);

	viewToScreen = CGAffineTransformMake(1, 0, 0, -1, 0, screenSize.height);
	screenToView = CGAffineTransformInvert(viewToScreen);

	viewToVirtual = CGAffineTransformConcat(viewToScreen, screenToVirtual);
	virtualToView = CGAffineTransformConcat(virtualToScreen, screenToView);

	// initialize joystick postion to orign, derive actual view location

	self.joystickPosition = CGPointZero;
}

- (void) setupVirtualBounds {
    
	CGRect	minimalBounds = CGRectMake(-1, -1, 2, 2);

	self.virtualBounds = CGRectInset(minimalBounds, -0.05, -0.05);

	if (self.bounds.size.width > self.bounds.size.height)
		[self scaleHorizontalToVertical: 1.0];

	else if (self.bounds.size.width < self.bounds.size.height)
		[self scaleVerticalToHorizontal: 1.0];

	return;
}

- (void) scaleHorizontalToVertical: (CGFloat) factor {
    
	CGPoint	origin	= self.virtualBounds.origin;
	CGSize	size	= self.virtualBounds.size;
	CGFloat	aspect	= self.bounds.size.width / self.bounds.size.height;
	CGFloat xAve	= origin.x + (size.width / 2.0);

	size.width	= (size.height * aspect) / factor;
	origin.x	= xAve - (size.width / 2.0);

	self.virtualBounds = CGRectWithPointAndSize(origin, size);
}

- (void) scaleVerticalToHorizontal: (CGFloat) factor {
    
	CGPoint	origin	= self.virtualBounds.origin;
	CGSize	size	= self.virtualBounds.size;
	CGFloat	aspect	= self.bounds.size.width / self.bounds.size.height;
	CGFloat yAve	= origin.y + (size.height / 2.0);

	size.height	= (size.width / aspect) / factor;
	origin.y	= yAve - (size.height / 2.0);

	self.virtualBounds = CGRectWithPointAndSize(origin, size);
}


//------------------------------------------------------------------------------

#pragma mark - Object Query


//------------------------------------------------------------------------------

#pragma mark - Drawing


- (void) drawRect: (CGRect) rect {
    
	BOOL	setupDone = (CGAffineTransformEqualToTransform(virtualToView, CGAffineTransformZero) == FALSE);

	if (setupDone)
	{
		[self drawVirtualPoints: self.circle];
		[self drawJoystickPosition];
	}
}

- (void) drawJoystickPosition {
    
	CGPoint		line0	= CGPointZero;
	CGPoint 	line1	= self.joystickPosition;
	NSArray *	points	= [JoystickView arrayWithPoints: &line0, &line1, nil];

	[self drawVirtualPoints: points];
    
    float ratio = 1.5;

	if (self.thumbImageView)
	{
		CGPoint thumbCenter	= CGPointApplyAffineTransform(self.joystickPosition, virtualToView);
		CGSize thumbSize	= self.thumbImageView.frame.size;
        
        CGSize thumbSize2	= CGSizeMake(thumbSize.width * ratio, thumbSize.height * ratio);
        CGVector thumbOffset	= CGVectorMake(-thumbSize.width / 2, -thumbSize.height / 2);
        
        if([[UIDevice currentDevice]userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
        {
            if ([[UIScreen mainScreen] bounds].size.height <= 480)
            {
//                thumbSize	= CGSizeMake(self.thumbImageView.frame.size.width * .65, self.thumbImageView.frame.size.height * .65) ;
//                thumbOffset	= CGVectorMake(-thumbSize.width / 1.8, -thumbSize.height / 1.3);
            }
            else if ([[UIScreen mainScreen] bounds].size.height == 568)
            {
                thumbCenter = CGPointMake(thumbCenter.x, thumbCenter.y + 20);
            }
            else if ([[UIScreen mainScreen] bounds].size.height == 736 || [[UIScreen mainScreen] bounds].size.height == 667)
            {
                thumbCenter = CGPointMake(thumbCenter.x, thumbCenter.y + 30);
                //thumbSize = CGSizeMake(thumbSize.width * ratio, thumbSize.height * ratio);
            }
        }
        else
        {
            //iPad
        }
        
        CGPoint thumbOrigin = CGPointAddVector(thumbCenter, thumbOffset);

		self.thumbImageView.frame = CGRectWithPointAndSize(thumbOrigin, thumbSize);
        self.rollerballImageView.frame = CGRectWithPointAndSize(thumbOrigin, thumbSize2);
	}
}

- (void) drawVirtualPoints: (NSArray *) virtualPointArray {
    
	NSArray *screenPointArray = [JoystickView applyTransform: virtualToScreen toPoints: virtualPointArray];

	[self drawScreenPoints: screenPointArray];
}

- (void) drawScreenPoints: (NSArray *) screenPointArray {
    
	CGMutablePathRef	pointPath	= CGPathCreateMutable();
	NSEnumerator *		valueHopper	= [screenPointArray objectEnumerator];
	NSValue *			pointValue	= [valueHopper nextObject];
	CGPoint 			screenPoint	= [pointValue CGPointValue];
	CGColorRef			fillColor	= [[UIColor colorWithRed: 55.0 / 256 green: 55.0/256 blue: 55.0/256 alpha:1.0] CGColor];
    
    fillColor	= [[UIColor clearColor] CGColor];

	// move to first point

	CGPathMoveToPoint(pointPath, &screenToView, screenPoint.x, screenPoint.y);

	// draw remaining points as connected lines

	while (pointValue = [valueHopper nextObject])
	{
		screenPoint = [pointValue CGPointValue];

		CGPathAddLineToPoint(pointPath, &screenToView, screenPoint.x, screenPoint.y);
	}

	CGContextRef currentContext = UIGraphicsGetCurrentContext();

	CGContextAddPath(currentContext, pointPath);
	CGContextClosePath(currentContext);
	CGContextSetFillColorWithColor(currentContext, fillColor);
	CGContextFillPath(currentContext);
	CGPathRelease(pointPath);    
}


//------------------------------------------------------------------------------

#pragma mark - Class Utilities


+ (NSArray *) applyTransform: (CGAffineTransform) xform toPoints: (NSArray *) inputArray {
    
	NSMutableArray *outputArray = [NSMutableArray array];

	for (NSValue *inputValue in inputArray)
	{
		CGPoint inputPoint = [inputValue CGPointValue];
		CGPoint outputPoint = CGPointApplyAffineTransform(inputPoint, xform);

		NSValue *outputValue = [NSValue valueWithCGPoint: outputPoint];

		[outputArray addObject: outputValue];
	}

	return [NSArray arrayWithArray: outputArray];
}

+ (NSArray *) arrayWithPoints: (CGPoint *) point, ... {
    
	NSMutableArray *	array		= [NSMutableArray array];
	CGPoint	*			nextPoint;
	va_list				pointList;

	va_start(pointList, point);

	[array addObject: [NSValue valueWithCGPoint: *point]];

	while ((nextPoint = va_arg(pointList, CGPoint *)) != nil)
		[array addObject: [NSValue valueWithCGPoint: *nextPoint]];

	va_end(pointList);

	return array;
}


//------------------------------------------------------------------------------

#pragma mark - Structure Utilities


CGPoint CGPointLimit(CGPoint point) {
    
	CGFloat size = sqrtf(point.x * point.x + point.y * point.y);

	if (size > 1.0)
		return CGPointMake(point.x / size, point.y / size);

	return point;
}

CGRect CGRectWithPointAndSize(CGPoint point, CGSize size) {
    
	return CGRectMake(point.x, point.y, size.width, size.height);
}

CGPoint CGPointAddVector(CGPoint point, CGVector vector) {
    
	return CGPointMake(point.x + vector.dx, point.y + vector.dy);
}

@end
