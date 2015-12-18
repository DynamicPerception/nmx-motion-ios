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
#import "JoyButton.h"

@protocol PresetDelegate

- (void) updateBacklash: (NSInteger) value;

@end


@interface PresetViewController : UIViewController  <UIPickerViewDelegate, UIPickerViewDataSource, UIActionSheetDelegate> {

    AppDelegate *appDelegate;
    PresetOb *selectedPreset;
    NSEntityDescription *entity;
}

@property (nonatomic, assign)		id <PresetDelegate>	delegate;
@property (nonatomic, readwrite)	NSInteger				backlash;
@property (nonatomic, strong)		NSMutableArray *presetList;
@property (nonatomic, strong)		NSMutableArray *presetStringList;
@property (weak, nonatomic) IBOutlet JoyButton *deleteBtn;
@property (weak, nonatomic) IBOutlet UIView *buttonView;
@property (weak, nonatomic) IBOutlet JoyButton *overwriteBtn;


- (IBAction) cancel:(id)sender;
- (IBAction) deletePreset:(id)sender;
- (IBAction) overwritePreset:(id)sender;

@end