//
//  ConstraintTest.m
//  Joystick
//
//  Created by Randall Ridley on 9/12/15.
//  Copyright (c) 2015 Mark Zykin. All rights reserved.
//

#import "ConstraintTest.h"

@interface ConstraintTest ()

@end

@implementation ConstraintTest

@synthesize overBtn,buttonView;

- (void)viewDidLoad {
    
    //overBtn.titleLabel.adjustsFontSizeToFitWidth = YES;
    
//    NSLayoutConstraint *lcd = [NSLayoutConstraint constraintWithItem:overBtn
//                                                           attribute:NSLayoutAttributeCenterX
//                                                           relatedBy:NSLayoutRelationEqual
//                                                              toItem:self.view
//                                                           attribute:NSLayoutAttributeRight
//                                                          multiplier:.25
//                                                            constant:0];
//    [self.view addConstraints:@[lcd]];
    
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
}

@end
