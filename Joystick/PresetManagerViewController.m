//
//  PresetManagerViewController.m
//  Joystick
//
//  Created by Randall Ridley on 8/26/15.
//  Copyright (c) 2015 Mark Zykin. All rights reserved.
//

#import "PresetManagerViewController.h"

@interface PresetManagerViewController ()

// TODO: These arrays are identical; do we need separate arrays for the columns?

@property (nonatomic, strong)				NSArray *		digitsHundreds;
@property (nonatomic, strong)				NSArray *		digitsTens;
@property (nonatomic, strong)				NSArray *		digitsOnes;

@property (nonatomic, strong)	IBOutlet	UIView *		controlBackground;
@property (nonatomic, strong)	IBOutlet	UIPickerView *	picker;
@property (nonatomic, strong)	IBOutlet	JoyButton *		okButton;

@end

@implementation PresetManagerViewController

- (void) viewDidLoad {
    
    [super viewDidLoad];
}

- (IBAction) restoreDefaults: (id) sender {

    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"restoreDefaults"
     object:nil];
    
    [self dismissViewControllerAnimated: YES completion: NULL];
}

- (IBAction) handleOkButton: (id) sender {

    [self dismissViewControllerAnimated: YES completion: nil];
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
