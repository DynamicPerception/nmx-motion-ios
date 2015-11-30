//
//  PresetViewController.h
//  Joystick
//
//  Created by Randall Ridley on 8/24/15.
//  Copyright (c) 2015 Mark Zykin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "AppDelegate.h"
#import "PresetOb.h"
#import "LinearRotaryViewController.h"

@protocol DistancePresetDelegate

- (void) updateBacklash: (NSInteger) value;

@end

@interface DistancePresetViewController : UIViewController  <UIPickerViewDelegate, UIPickerViewDataSource> {
    
    AppDelegate *appDelegate;
    NSDictionary *selectedPreset;
    NSEntityDescription *entity;
    NSString *heading;
    int selectedRow;
}

@property (nonatomic, assign)		id <DistancePresetDelegate>	delegate;
@property (nonatomic, readwrite)	NSInteger				backlash;
@property (nonatomic, strong)		NSMutableArray *presetList;
@property (nonatomic, strong)		NSMutableArray *presetStringList;
@property (nonatomic, strong)		NSString *currentSettingString;
@property int setting;

- (IBAction)cancel:(id)sender;

@end