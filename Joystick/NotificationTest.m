//
//  NotificationTest.m
//  Joystick
//
//  Created by Randall Ridley on 7/24/15.
//  Copyright (c) 2015 Mark Zykin. All rights reserved.
//

#import "NotificationTest.h"

@interface NotificationTest ()

@end

@implementation NotificationTest

- (void) viewDidLoad {
    
    [super viewDidLoad];
}

- (IBAction) test: (id) sender {

    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"note2"
     object:nil];
}

- (IBAction) done: (id) sender {

    [self dismissViewControllerAnimated: YES completion: ^{
        
    }];
}

- (void) didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
}

@end
