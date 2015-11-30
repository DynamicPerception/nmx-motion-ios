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
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

//- (CGRect)thumbRectForBounds:(CGRect)bounds trackRect:(CGRect)rect value:(float)value {
//    
//    //NSLog(@"rect: %@",rect);
//    //NSLog(@"value: %f",value);
//    
//    CGRect a = CGRectMake(0, 0, 30, 30);
//
//    return a;
//}

- (CGRect)trackRectForBounds:(CGRect)bounds {

    CGRect a = CGRectMake(bounds.origin.x, bounds.origin.y, bounds.size.width, bounds.size.height * .25);
    
    return a;
}

//- (id) initWithFrame: (CGRect)rect
//{
//    if ((self=[super initWithFrame:CGRectMake(rect.origin.x,rect.origin.y,90,27)])){
//        [self awakeFromNib];
//    }
//    return self;
//}

@end
