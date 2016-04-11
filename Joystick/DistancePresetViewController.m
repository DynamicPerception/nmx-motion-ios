//
//  BacklashViewController.m
//  Joystick
//
//  Created by Mark Zykin on 4/6/15.
//  Copyright (c) 2015 Mark Zykin. All rights reserved.
//

#import <CocoaLumberjack/CocoaLumberjack.h>

#import "DistancePresetViewController.h"
#import "JoyButton.h"

//------------------------------------------------------------------------------

#pragma mark - Private Interface


@interface DistancePresetViewController ()

// TODO: These arrays are identical; do we need separate arrays for the columns?

@property (nonatomic, strong)				NSArray *		digitsHundreds;
@property (nonatomic, strong)				NSArray *		digitsTens;
@property (nonatomic, strong)				NSArray *		digitsOnes;

@property (nonatomic, strong)	IBOutlet	UIView *		controlBackground;
@property (nonatomic, strong)	IBOutlet	UIPickerView *	picker;
@property (nonatomic, strong)	IBOutlet	JoyButton *		okButton;

@end


//------------------------------------------------------------------------------

#pragma mark - Implementation

@implementation DistancePresetViewController


#pragma mark Public Propery Synthesis

@synthesize delegate;
@synthesize backlash;


#pragma mark Private Propery Synthesis

@synthesize picker;

@synthesize presetList, presetStringList, setting, currentSettingString,currentCustomVal;


#pragma mark Public Propery Methods

- (NSInteger) backlash {

    return backlash;
}

- (void) setBacklash: (NSInteger) value {

    backlash = value;
}

#pragma mark Private Propery Methods


//------------------------------------------------------------------------------

#pragma mark - Object Management


- (void) viewDidLoad {
    
    [super viewDidLoad];
    
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    self.picker.delegate = self;
    self.picker.dataSource = self;
    
    presetList = [[NSMutableArray alloc] init];
    presetStringList = [[NSMutableArray alloc] init];
    
    entity = [NSEntityDescription entityForName:@"PresetOb" inManagedObjectContext:appDelegate.managedObjectContext];
    
    //    -'Gear Ratio' This would be a drop down or modal selector: 27:1,  19:1,  5:1 and 'Custom'. A value associated with these settings would be displayed to the right as usual, if 'Custom' this value would be editable. Otherwise it's not editable.
    //
    //    -'Rig Ratio' this is also a drop down or modal selector; Stage R, Stage 1/0 and 'Custom'.  Same thing.. A value associated with these settings would be displayed to the right as usual, if 'Custom' this value would be editable. Otherwise it's not editable.
    //
    //    -'Overall Distance'
    
    
    if (setting == 0) //Gear
    {
        NSDictionary *dict1 = [[NSDictionary alloc] initWithObjectsAndKeys:
                               @"27:1", @"val1", nil];
        
        [presetList addObject:dict1];
        
        
        NSDictionary *dict2 = [[NSDictionary alloc] initWithObjectsAndKeys:
                               @"19:1", @"val1", nil];
        
        [presetList addObject:dict2];
        
        
        NSDictionary *dict3 = [[NSDictionary alloc] initWithObjectsAndKeys:
                               @"5:1", @"val1", nil];
        
        [presetList addObject:dict3];
    }
    else if (setting == 1) //Rig
    {
        NSDictionary *dict1 = [[NSDictionary alloc] initWithObjectsAndKeys:
                               @"Stage R", @"val1", nil];
        
        [presetList addObject:dict1];
        
        NSDictionary *dict2 = [[NSDictionary alloc] initWithObjectsAndKeys:
                               @"Stage 1/0", @"val1", nil];
        
        [presetList addObject:dict2];
        
        NSDictionary *dict4 = [[NSDictionary alloc] initWithObjectsAndKeys:
                               @"Linear Custom", @"val1", nil];
        
        [presetList addObject:dict4];
//
//        NSDictionary *dict5 = [[NSDictionary alloc] initWithObjectsAndKeys:
//                               @"Rotary Custom", @"val1", nil];
//        
//        [presetList addObject:dict5];
    }
    else if (setting == 2)  // Direction label
    {
        NSUInteger numLabels = [DistancePresetViewController numDirectionLabels];
        for (int i = 0; i < numLabels; i++)
        {
            NSString *label = [DistancePresetViewController labelForDirectionIndex: i];
            NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:
                               label, @"val1", nil];
            [presetList addObject:dict];
            
            if ([currentSettingString isEqualToString: label])
            {
                [picker selectRow:i inComponent:0 animated:NO];
                selectedRow = i;
            }

        }
    }
    
    
    if (setting == 0)
    {
        if ([currentSettingString isEqualToString:@"27:1"])
        {
            [picker selectRow:0 inComponent:0 animated:NO];
            selectedRow = 0;
        }
        else if ([currentSettingString isEqualToString:@"19:1"])
        {
            [picker selectRow:1 inComponent:0 animated:NO];
            selectedRow = 1;
        }
        else
        {
            [picker selectRow:2 inComponent:0 animated:NO];
            selectedRow = 2;
        }
    }
    else if (setting == 1)
    {
        if ([currentSettingString isEqualToString:@"Stage R"])
        {
            [picker selectRow:0 inComponent:0 animated:NO];
            selectedRow = 0;
        }
        else if ([currentSettingString isEqualToString:@"Stage 1/0"])
        {
            [picker selectRow:1 inComponent:0 animated:NO];
            selectedRow = 1;
        }
        else
        {
            [picker selectRow:2 inComponent:0 animated:NO];
            selectedRow = 2;
        }
    }
    
    NSLog(@"selectedRow: %i",selectedRow);
    
    selectedPreset = [presetList objectAtIndex:selectedRow];
    
//    [[NSNotificationCenter defaultCenter]
//	 addObserver:self
//	 selector:@selector(handleNotificationRotaryPreset:)
//	 name:@"linearRotaryPreset" object:nil];
}


- (void) handleNotificationRotaryPreset:(NSNotification *)pNotification {
    
    NSDictionary *preset1 = pNotification.object;
    
    NSLog(@"linearRotary: %@",preset1);
}

- (void) loadPresets {
    
    NSLog(@"loadPresets");
    
    NSError *error = nil;
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    entity = [NSEntityDescription entityForName:@"PresetOb" inManagedObjectContext:appDelegate.managedObjectContext];
    [fetchRequest setEntity:entity];
    [fetchRequest setReturnsObjectsAsFaults:NO];
    
    NSArray *fetchedObjects = [appDelegate.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    if(fetchedObjects.count > 0)
    {
        NSLog(@"presets: %@",fetchedObjects);
        
        for (int i = 0; i < fetchedObjects.count; i++)
        {
            PresetOb *a = [fetchedObjects objectAtIndex:i];
            
            [presetList addObject:a];
        }
        
        selectedPreset = [fetchedObjects objectAtIndex:0];
    }
    else
    {
        self.okButton.enabled = NO;
    }
    
    [self.picker reloadAllComponents];
}

- (IBAction) cancel:(id)sender {
    [self dismissViewControllerAnimated: YES completion: nil];
}

- (void) viewDidAppear: (BOOL) animated {
    
    [super viewDidAppear: animated];
}

//------------------------------------------------------------------------------

#pragma mark - Object Operations

//------------------------------------------------------------------------------

#pragma mark - IBAction Methods

- (IBAction) handleOkButton: (id) sender {
    
    if (setting == 0 || setting == 2)
    {
        [[NSNotificationCenter defaultCenter]
         postNotificationName:@"loadDistancePreset"
         object:selectedPreset];
        
        [self dismissViewControllerAnimated: YES completion: nil];
    }
    else if (setting == 1)
    {
        if (selectedRow == 2)
        {
           heading = @"Linear Custom";
            [self performSegueWithIdentifier:@"LinearRotarySegue" sender:self];
        }
        else if (selectedRow == 3)
        {
            heading = @"Rotary Custom";
            [self performSegueWithIdentifier:@"LinearRotarySegue" sender:self];
        }
        else
        {
            [[NSNotificationCenter defaultCenter]
             postNotificationName:@"loadDistancePreset"
             object:selectedPreset];
            
             [self dismissViewControllerAnimated: YES completion: nil];
        }
    }
    else if (setting == 2)  // direction label
    {
        
    }
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    LinearRotaryViewController *msvc = segue.destinationViewController;
    
    [msvc setHeading:heading];
    [msvc setCurrentCustomVal:currentCustomVal];
}

//------------------------------------------------------------------------------

#pragma mark - UIPickerViewDelegate Protocol Methods

- (CGFloat) pickerView: (UIPickerView *) pickerView rowHeightForComponent: (NSInteger) component {
    
    return 21.0;
}

- (CGFloat) pickerView: (UIPickerView *) pickerView widthForComponent: (NSInteger) component {
    
    return 200.0;
}

- (NSAttributedString *) pickerView: (UIPickerView *) pickerView attributedTitleForRow: (NSInteger) row forComponent: (NSInteger) component {

    NSDictionary *	attributes	=  @{ NSForegroundColorAttributeName: [UIColor whiteColor]};
    NSDictionary *po = [presetList objectAtIndex: row];
    
    NSString *		string		= [po objectForKey:@"val1"];
    
    return [[NSAttributedString alloc] initWithString: string attributes: attributes];
}

- (void) pickerView: (UIPickerView *) pickerView didSelectRow: (NSInteger) row inComponent: (NSInteger) component {
    
    if (presetList.count)
    {
        selectedPreset = [presetList objectAtIndex:row];
    }
    
    selectedRow = (int)row;
    
    NSLog(@"selectedRow: %i",selectedRow);
}

//------------------------------------------------------------------------------

#pragma mark - UIPickerViewDataSource Protocol Methods

- (NSInteger) numberOfComponentsInPickerView: (UIPickerView *) pickerView {

    return 1;
}

- (NSInteger) pickerView: (UIPickerView *) pickerView numberOfRowsInComponent: (NSInteger) component {

    return presetList.count;
}

- (void) didReceiveMemoryWarning {

    [super didReceiveMemoryWarning];
}

#pragma mark direction labels


+ (int) indexForDirectionLabel: (NSString *) labelString
{
    NSRange range = [labelString rangeOfString:@"/"];
    NSRange lStrRange;
    lStrRange.location = 0;
    lStrRange.length = range.location;
    NSString *lString = [labelString substringWithRange: lStrRange];

    NSArray *leftDirLabels = [DistancePresetViewController leftDirectionLabels];
    int idx = (int)[leftDirLabels indexOfObject: lString];
    
    return  idx;

}


+ (NSString *) labelForDirectionIndex: (int) index
{
    NSArray *leftDirLabels = [DistancePresetViewController leftDirectionLabels];
    NSArray *rightDirLabels = [DistancePresetViewController rightDirectionLabels];

    NSString *lLabel = leftDirLabels[index];
    NSString *rLabel = rightDirLabels[index];
    NSString *label = [NSString stringWithFormat:@"%@/%@", lLabel, rLabel];
    return label;
}

+ (NSArray *)leftDirectionLabels
{
    static NSArray * leftDirectionLabels = nil;
    
    @synchronized (leftDirectionLabels)
    {
        if (leftDirectionLabels == nil) {
            leftDirectionLabels = [NSArray arrayWithObjects: @"L", @"CW", @"UP", @"IN", nil];
        }
        
        return leftDirectionLabels;
    }
}

+ (NSArray *)rightDirectionLabels
{
    static NSArray * rightDirectionLabels = nil;
    
    @synchronized (rightDirectionLabels)
    {
        if (rightDirectionLabels == nil) {
            rightDirectionLabels = [NSArray arrayWithObjects: @"R", @"CCW", @"DOWN", @"OUT", nil];
        }
        
        return rightDirectionLabels;
    }
}


+ (NSString *)leftDirectionLabelForIndex: (int) labelIndex
{
    return [DistancePresetViewController leftDirectionLabels][labelIndex];
}

+ (NSString *)rightDirectionLabelForIndex: (int) labelIndex
{
    return [DistancePresetViewController rightDirectionLabels][labelIndex];
}

+ (NSUInteger) numDirectionLabels
{
    return [DistancePresetViewController rightDirectionLabels].count;
}


@end
