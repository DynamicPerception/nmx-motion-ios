//
//  JoyButton.m
//  Joystick
//
//  Created by Mark Zykin on 11/25/14.
//  Copyright (c) 2014 Dynamic Perception. All rights reserved.
//

#import "JoyButton.h"

//------------------------------------------------------------------------------

#pragma mark - Private Interface


@interface JoyButton ()

@property (nonatomic, strong)	UIColor *	titleColor;
@property (nonatomic, strong)	UIColor *	normalColor;
@property (nonatomic, strong)	UIColor *	highlightColor;
@property (nonatomic, strong)	UIColor *	selectedColor;
@property (nonatomic, strong)	UIColor *	disabledColor;

@end


//------------------------------------------------------------------------------

#pragma mark - Implementation


@implementation JoyButton

#pragma mark Public Propery Synthesis

#pragma mark Private Propery Synthesis

@synthesize titleColor;
@synthesize normalColor;
@synthesize highlightColor;
@synthesize selectedColor;
@synthesize disabledColor;


#pragma mark Public Propery Methods

#pragma mark Private Propery Methods

- (UIColor *) titleColor {

	if (titleColor == nil)
		titleColor = [JoyButton colorWithRed: 255 green: 255 blue: 255];

	return titleColor;
}

- (UIColor *) normalColor {

	if (normalColor == nil)
		normalColor = [JoyButton colorWithRed: 55 green: 55 blue: 55];

	return normalColor;
}

- (UIColor *) highlightColor {

	if (highlightColor == nil)
		highlightColor = [JoyButton colorWithRed: 98 green: 170 blue: 246];

	return highlightColor;
}

- (UIColor *) selectedColor {

	if (selectedColor == nil)
		selectedColor = [JoyButton colorWithRed: 98 green: 170 blue: 246];

	return selectedColor;
}

- (UIColor *) disabledColor {

	if (disabledColor == nil)
		disabledColor = [JoyButton colorWithRed: 180 green: 180 blue: 180];

	return disabledColor;
}


//------------------------------------------------------------------------------

#pragma mark - Object Management


- (void) awakeFromNib {

	[self setButtonAppearance];
}

- (void) setButtonAppearance {

	[self setTitleColor: self.titleColor    forState: UIControlStateNormal];
	[self setTitleColor: self.titleColor    forState: UIControlStateSelected];
	[self setTitleColor: self.titleColor	forState: UIControlStateDisabled];

	UIImage *normalUIImage    = [self imageForButtonWithColor: self.normalColor];
	UIImage *highlightUIImage = [self imageForButtonWithColor: self.highlightColor];
	UIImage *selectedUIImage  = [self imageForButtonWithColor: self.selectedColor];
	UIImage *disabledUIImage  = [self imageForButtonWithColor: self.normalColor];

	[self setBackgroundImage: normalUIImage    forState: UIControlStateNormal];
	[self setBackgroundImage: highlightUIImage forState: UIControlStateHighlighted];
	[self setBackgroundImage: selectedUIImage  forState: UIControlStateSelected];
	[self setBackgroundImage: disabledUIImage  forState: UIControlStateDisabled];

//	self.layer.borderWidth = 1.0;
//	self.layer.borderColor = [[UIColor redColor] CGColor];
	self.layer.cornerRadius = 5.0;
	self.clipsToBounds = TRUE;
}

- (UIImage *) imageForButtonWithColor: (UIColor *) color {

	CGSize size = self.frame.size;
	CGRect frame = CGRectMake(0, 0, size.width, size.height);

	// create image from just a color on the fly so we don't need a resource file

	UIGraphicsBeginImageContext(self.frame.size);
	CGContextRef currentContext = UIGraphicsGetCurrentContext();
	CGContextSetFillColorWithColor(currentContext, color.CGColor);
	CGContextFillRect(currentContext, frame);
	UIImage *buttonImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();

	return  buttonImage;
}


//------------------------------------------------------------------------------

#pragma mark - Class Utilities


+ (UIColor *) colorWithRed: (int) red green: (int) green blue: (int) blue {

	CGFloat	uiRed	= ((CGFloat) red   / 256.0) ;
	CGFloat	uiGreen	= ((CGFloat) green / 256.0) ;
	CGFloat	uiBlue	= ((CGFloat) blue  / 256.0) ;

	UIColor *color = [UIColor colorWithRed: uiRed green: uiGreen blue: uiBlue alpha: 1.0];

	return color;
}


@end
