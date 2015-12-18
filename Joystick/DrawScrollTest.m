//
//  DrawScrollTest.m
//  Joystick
//
//  Created by Randall Ridley on 7/22/15.
//  Copyright (c) 2015 Mark Zykin. All rights reserved.
//

#import "DrawScrollTest.h"

@interface DrawScrollTest ()

@end

@implementation DrawScrollTest

@synthesize slideGraph;

- (void) viewDidLoad {
    
    slideGraph.frame1 = 22;
    slideGraph.frame2 = 137;
    slideGraph.frame3 = 180;
    slideGraph.frame4 = 289;
    
    slideGraph.frameCount = 1000;
    
    slideGraph.backgroundColor = [UIColor lightGrayColor];
    
    [super viewDidLoad];
}

- (void) didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
}

@end
