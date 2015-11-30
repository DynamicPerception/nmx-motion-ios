//
//  LinearRotaryViewController.m
//  Joystick
//
//  Created by Randall Ridley on 9/10/15.
//  Copyright (c) 2015 Mark Zykin. All rights reserved.
//

#import "LinearRotaryViewController.h"

@interface LinearRotaryViewController ()

// TODO: These arrays are identical; do we need separate arrays for the columns?

@property (nonatomic, strong)	IBOutlet	UIView *		controlBackground;
@property (nonatomic, strong)	IBOutlet	JoyButton *		okButton;

@end

@implementation LinearRotaryViewController

NSArray	static	*intervalOnes	= nil;
NSArray	static	*intervalTenths	= nil;

@synthesize valueTxt,headingLbl,heading,presetList,presetStringList,picker,okButton;

+ (void) initialize {

    NSMutableArray *ones	= [NSMutableArray array];
    NSMutableArray *tenths	= [NSMutableArray array];
    
    for (NSInteger index = 0; index < 10; index++)
    {
        [ones   addObject: [NSString stringWithFormat: @"%ld",  (long) index]];
        [tenths addObject: [NSString stringWithFormat: @".%ld", (long) index]];
    }
    
    intervalOnes	= [NSArray arrayWithArray: ones];
    intervalTenths	= [NSArray arrayWithArray: tenths];
}

- (void)viewDidLoad {
    
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    valueTxt.delegate = self;
    self.okButton.enabled = NO;
    
    headingLbl.text = heading;
    
    [self setupReturnButton];
    
    [super viewDidLoad];
}

- (void)setupReturnButton {
    
    UIToolbar* keyboardToolbar = [[UIToolbar alloc] init];
    
    [keyboardToolbar sizeToFit];
    
    UIBarButtonItem *flexBarButton = [[UIBarButtonItem alloc]
                                      initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                      target:nil action:nil];
    
    UIBarButtonItem *doneBarButton = [[UIBarButtonItem alloc]
                                      initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                      target:self.view
                                      action:@selector(endEditing:)];
    
    keyboardToolbar.items = @[flexBarButton, doneBarButton];
    
    valueTxt.inputAccessoryView = keyboardToolbar;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    
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
    NSDictionary *dict1 = [[NSDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithFloat:selectedFloat], @"val1",heading, @"val2", nil];
    
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"linearRotaryPreset"
     object:dict1];
    
    //[self dismissViewControllerAnimated: YES completion: nil];
}

- (IBAction)cancel:(id)sender {
    [self dismissViewControllerAnimated: YES completion: nil];
}

- (BOOL)textFieldShouldReturn:(UITextField*)textField {
    
    [textField resignFirstResponder];
    
    return YES;
}

#pragma mark - Object Operations


- (float) getPickerValue {

    NSInteger	hundreds		= [self.picker selectedRowInComponent: 0];
    NSInteger	tens			= [self.picker selectedRowInComponent: 1];
    NSInteger	ones			= [self.picker selectedRowInComponent: 2];
    NSInteger	tenths			= [self.picker selectedRowInComponent: 3];
    
    float	milliseconds	= (hundreds * 10) + (tens) + (ones * .1) + (tenths * .01);
    
    return milliseconds;
}

- (void) setPickerValue: (NSInteger) milliseconds animated: (BOOL) animated {
    
    NSInteger	hundreds			= (milliseconds / 10000) % 10;
    NSInteger	tens			= (milliseconds / 1000) % 10;
    NSInteger	ones			= (milliseconds / 100) % 10;
    NSInteger	tenths			= (milliseconds / 10) % 10;
    
    [self.picker selectRow: hundreds   inComponent: 0 animated: animated];
    [self.picker selectRow: tens   inComponent: 1 animated: animated];
    [self.picker selectRow: ones   inComponent: 2 animated: animated];
    [self.picker selectRow: tenths inComponent: 3 animated: animated];
}

- (CGFloat) pickerView: (UIPickerView *) pickerView rowHeightForComponent: (NSInteger) component {

    return 21.0;
}

- (CGFloat) pickerView: (UIPickerView *) pickerView widthForComponent: (NSInteger) component {

    return 40.0;
}

- (NSAttributedString *) pickerView: (UIPickerView *) pickerView attributedTitleForRow: (NSInteger) row forComponent: (NSInteger) component {

    NSDictionary *	attributes	=  @{ NSForegroundColorAttributeName: [UIColor whiteColor]};
    NSString *		string		= nil;
    
    switch (component)
    {
        case 0:
            string = [intervalOnes objectAtIndex: row];
        case 1:
            string = [intervalOnes objectAtIndex: row];
            break;
        case 2:
            string = [intervalTenths objectAtIndex: row];
            break;
        case 3:
            string = [intervalOnes objectAtIndex: row];
            break;
            
        default:
            return nil;
            break;
    }
    
    return [[NSAttributedString alloc] initWithString: string attributes: attributes];
}

- (void) pickerView: (UIPickerView *) pickerView didSelectRow: (NSInteger) row inComponent: (NSInteger) component {

    selectedFloat = [self getPickerValue];
    
    NSLog(@"float: %.02f",selectedFloat);
    
    if(selectedFloat > 0)
    {
        okButton.enabled = YES;
    }
}


//------------------------------------------------------------------------------

#pragma mark - UIPickerViewDataSource Protocol Methods


- (NSInteger) numberOfComponentsInPickerView: (UIPickerView *) pickerView {

    return 4;
}

- (NSInteger) pickerView: (UIPickerView *) pickerView numberOfRowsInComponent: (NSInteger) component {

    return 10;
}

- (void) didReceiveMemoryWarning {

    [super didReceiveMemoryWarning];
}

@end
