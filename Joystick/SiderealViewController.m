//
//  SiderealViewController.m
//  Joystick
//
//  Created by Randall Ridley on 10/21/15.
//  Copyright (c) 2015 Mark Zykin. All rights reserved.
//

#import "SiderealViewController.h"

@interface SiderealViewController ()

@end

@implementation SiderealViewController

- (void) viewDidLoad {
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (IBAction) handleOkButton:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
