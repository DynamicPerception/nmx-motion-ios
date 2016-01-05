//
//  SavePresetViewController.m
//  Joystick
//
//  Created by Randall Ridley on 8/24/15.
//  Copyright (c) 2015 Mark Zykin. All rights reserved.
//

#import "SavePresetViewController.h"

@interface SavePresetViewController ()

// TODO: These arrays are identical; do we need separate arrays for the columns?

@property (nonatomic, strong)	IBOutlet	UIView *		controlBackground;
@property (nonatomic, strong)	IBOutlet	JoyButton *		okButton;

@end

@implementation SavePresetViewController

@synthesize presetTxt;

- (void) viewDidLoad {
    
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    presetTxt.delegate = self;
    self.okButton.enabled = NO;
    
    [super viewDidLoad];
}

- (void) textFieldDidEndEditing:(UITextField *)textField {
    
    if (textField.text.length > 0)
    {
        self.okButton.enabled = YES;
    }
    else
    {
        self.okButton.enabled = NO;
    }
}

- (IBAction) handleOkButton: (id) sender {
    BOOL valid = [self validatePreset:presetTxt.text];
    
    if (valid)
    {
        [self savePreset];
    }
    else
    {
        UIAlertView *insertAlert = [[UIAlertView alloc]
                                    initWithTitle:@""
                                    message:@"Please choose another preset name"
                                    delegate:self
                                    cancelButtonTitle:@"OK"
                                    otherButtonTitles:nil];
        
        [insertAlert show];
    }
}

- (IBAction) cancel:(id)sender {
    [self dismissViewControllerAnimated: YES completion: nil];
}

- (void) savePreset {
    
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"savePreset"
     object:presetTxt.text];    
}

- (bool) validatePreset: (NSString *) name {

    NSError *error = nil;
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    entity = [NSEntityDescription entityForName:@"PresetOb" inManagedObjectContext:appDelegate.managedObjectContext];
    [fetchRequest setEntity:entity];
    [fetchRequest setReturnsObjectsAsFaults:NO];
    
    NSArray *fetchedObjects = [appDelegate.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    if(fetchedObjects.count > 0)
    {
        for (int i = 0; i < fetchedObjects.count; i++)
        {
            PresetOb *a = [fetchedObjects objectAtIndex:i];
            
            if ([a.name isEqualToString:name]) {
                
                return false;
            }
        }
    }
    
    return true;
}

- (BOOL) textFieldShouldReturn:(UITextField*)textField {
	
	[textField resignFirstResponder];
	
	return YES;
}

- (void) didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
}

@end
