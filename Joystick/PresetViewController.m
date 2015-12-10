//
//  BacklashViewController.m
//  Joystick
//
//  Created by Mark Zykin on 4/6/15.
//  Copyright (c) 2015 Mark Zykin. All rights reserved.
//

#import <CocoaLumberjack/CocoaLumberjack.h>

#import "PresetViewController.h"
#import "JoyButton.h"

//------------------------------------------------------------------------------

#pragma mark - Private Interface


@interface PresetViewController ()

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

@implementation PresetViewController


#pragma mark Public Propery Synthesis

@synthesize delegate;
@synthesize backlash;


#pragma mark Private Propery Synthesis

@synthesize picker;

@synthesize presetList, presetStringList,deleteBtn,buttonView,overwriteBtn;


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
    
    entity = [NSEntityDescription entityForName:@"PresetOb" inManagedObjectContext:appDelegate.managedObjectContext];
    
    [self loadPresets];
    
    
//    NSLayoutConstraint *lcd = [NSLayoutConstraint constraintWithItem:overwriteBtn
//                                                           attribute:NSLayoutAttributeCenterX
//                                                           relatedBy:NSLayoutRelationEqual
//                                                              toItem:self.view
//                                                           attribute:NSLayoutAttributeRight
//                                                          multiplier:.25
//                                                            constant:0];
//    [buttonView addConstraints:@[lcd]];
}

- (void) loadPresets {
    
    NSLog(@"loadPresets");
    
    presetList = [[NSMutableArray alloc] init];
    presetStringList = [[NSMutableArray alloc] init];
        
    NSError *error = nil;
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    entity = [NSEntityDescription entityForName:@"PresetOb" inManagedObjectContext:appDelegate.managedObjectContext];
    [fetchRequest setEntity:entity];
    [fetchRequest setReturnsObjectsAsFaults:NO];
    
    NSArray *fetchedObjects = [appDelegate.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    if(fetchedObjects.count > 0)
    {
        //NSLog(@"presets: %@",fetchedObjects);
        
        deleteBtn.enabled = YES;
        
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

- (IBAction) deletePreset:(id)sender {
    UIActionSheet * sheet = [[UIActionSheet alloc]
                             initWithTitle:@"Delete Preset?"
                             delegate:self
                             cancelButtonTitle:@"Cancel"
                             destructiveButtonTitle:nil
                             otherButtonTitles:@"Yes",nil];
    
    [sheet showInView:self.view];
}

- (IBAction) overwritePreset:(id)sender {
    UIActionSheet * sheet = [[UIActionSheet alloc]
                             initWithTitle:@"Overwrite Preset?"
                             delegate:self
                             cancelButtonTitle:@"Cancel"
                             destructiveButtonTitle:nil
                             otherButtonTitles:@"Yes",nil];
    
    [sheet showInView:self.view];
}

- (void) confirmDelete {

    NSLog(@"delete");
    
    [appDelegate.managedObjectContext deleteObject:selectedPreset];
    
    NSError *error = nil;
    
    if (![appDelegate.managedObjectContext save:&error])
    {
        NSLog(@"save error");
    }
    
    [self loadPresets];
}

- (void) confirmOverwrite {

    NSLog(@"overwrite");
    
    NSString *name = selectedPreset.name;
    
    [appDelegate.managedObjectContext deleteObject:selectedPreset];
    
    NSError *error = nil;
    
    if (![appDelegate.managedObjectContext save:&error])
    {
        NSLog(@"save error");
    }
    
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"savePreset"
     object:name];
}

- (void) actionSheet:(UIActionSheet *)actionSheet willDismissWithButtonIndex:(NSInteger)buttonIndex {
    
    if ([actionSheet.title isEqualToString:@"Delete Preset?"])
    {
        switch (buttonIndex)
        {
            case 0:
            {
                [self confirmDelete];
            }
                break;
                
            case 1:
            {
                
            }
                break;
            
            default:
                break;
        }
    }
    else if ([actionSheet.title isEqualToString:@"Overwrite Preset?"])
    {
        switch (buttonIndex)
        {
            case 0:
            {
                [self confirmOverwrite];
            }
                break;
                
            case 1:
            {
                
            }
                break;
                
            default:
                break;
        }
    }
}




- (void) viewDidAppear: (BOOL) animated {

    [super viewDidAppear: animated];
    
}



//------------------------------------------------------------------------------

#pragma mark - Object Operations


//------------------------------------------------------------------------------

#pragma mark - IBAction Methods


- (IBAction) handleOkButton: (id) sender {

    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"loadPreset"
     object:selectedPreset];
    
    [self dismissViewControllerAnimated: YES completion: nil];
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
    PresetOb *po = [presetList objectAtIndex: row];
    NSString *		string		= po.name;
    
    return [[NSAttributedString alloc] initWithString: string attributes: attributes];
}

- (void) pickerView: (UIPickerView *) pickerView didSelectRow: (NSInteger) row inComponent: (NSInteger) component {

    if (presetList.count) {
        
        selectedPreset = [presetList objectAtIndex:row];
    }
    
    //DDLogDebug(@"Current value: %@", selectedPreset);
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


@end
