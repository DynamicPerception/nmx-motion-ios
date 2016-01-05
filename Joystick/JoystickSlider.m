//
//  JoystickSlider.m
//  Joystick
//
//  Created by Randall Ridley on 10/12/15.
//  Copyright (c) 2015 Mark Zykin. All rights reserved.
//

#import "JoystickSlider.h"

@implementation JoystickSlider

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void) drawRect:(CGRect)rect {
    // Drawing code
}
*/

//- (CGRect) thumbRectForBounds:(CGRect)bounds trackRect:(CGRect)rect value:(float)value {
//    
//    //NSLog(@"rect: %@",rect);
//    //NSLog(@"value: %f",value);
//    
//    CGRect a = CGRectMake(0, 0, 30, 30);
//
//    return a;
//}

- (BOOL) pointInside:(CGPoint)point withEvent:(UIEvent*)event {
    
    CGRect bounds = self.bounds;
    bounds = CGRectInset(bounds, -10, -15);
    return CGRectContainsPoint(bounds, point);
}

- (CGRect) trackRectForBounds:(CGRect)bounds {

    CGRect a = CGRectMake(bounds.origin.x, bounds.origin.y, bounds.size.width, bounds.size.height * .25);
    
    return a;
}

- (BOOL) beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    //NSLog(@"track");
    
    [super beginTrackingWithTouch:touch withEvent:event];
    CGPoint touchLocation = [touch locationInView:self];
    
    CGFloat value = self.minimumValue + (self.maximumValue - self.minimumValue) *
    ((touchLocation.x - self.currentThumbImage.size.width/2) /
     (self.frame.size.width-self.currentThumbImage.size.width));
    
    [self setValue:value animated:YES];
    
    return YES;
}

//- (id) initWithFrame: (CGRect)rect
//{
//    if ((self=[super initWithFrame:CGRectMake(rect.origin.x,rect.origin.y,90,27)])){
//        [self awakeFromNib];
//    }
//    return self;
//}

@end
