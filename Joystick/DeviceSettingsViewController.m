//
//  AboutViewController.m
//  Joystick
//
//  Created by Dave Koziol on 1/5/15.
//  Copyright (c) 2015 Dynamic Perception. All rights reserved.
//

#import <CocoaLumberjack/CocoaLumberjack.h>

#import "DeviceSettingsViewController.h"
#import "AppExecutive.h"
#import "JoyButton.h"
#import "NMXDevice.h"
#import "JSDeviceSettingsVC.h"

@interface DeviceSettingsViewController () <UIPageViewControllerDataSource>

#pragma mark Private Property Synthesis

@property (weak, nonatomic, readonly)	AppExecutive *	appExecutive;

// Device Information subview

@property (strong, nonatomic) IBOutlet UIView *deviceInfoView;
@property (strong, nonatomic) IBOutlet UILabel *deviceInfoLabel;

// Top container view

@property (weak, nonatomic) IBOutlet JoyButton *	emailLogFileButton;
@property (weak, nonatomic) IBOutlet UILabel *		appVersionLabel;
@property (nonatomic, readonly)		NSString *		emailAddress;

// Page view

@property UIPageViewController *pageController;

@end

@implementation DeviceSettingsViewController


static const char *EMAIL_ADDRESS	= "EMAIL_ADDRESS";


#pragma mark - Private Property Synthesis

@synthesize appExecutive;

//------------------------------------------------------------------------------

#pragma mark - Private Property Methods


- (AppExecutive *) appExecutive {

	if (appExecutive == nil)
	{
		appExecutive = [AppExecutive sharedInstance];
	}

	return appExecutive;
}

- (NSString *) emailAddress {

	if (getenv(EMAIL_ADDRESS))
	{
		const char *	envvar = getenv(EMAIL_ADDRESS);
		NSString *		string = [NSString stringWithUTF8String: envvar];

		return string;
	}

	return @"support@dynamicperception.com";
}


//------------------------------------------------------------------------------

#pragma mark - Object Management


- (void) viewDidLoad {

	[super viewDidLoad];

	self.appVersionLabel.text = [[NSBundle mainBundle] objectForInfoDictionaryKey: @"CFBundleShortVersionString"];

    _pageController = [self.storyboard instantiateViewControllerWithIdentifier:@"DeviceSettingsPageID"];
    
    _pageController.dataSource = self;
    NSArray *startingViewControllers = @[[self itemControllerForIndex:0]];
    [_pageController setViewControllers:startingViewControllers
                                 direction:UIPageViewControllerNavigationDirectionForward
                                  animated:NO
                                completion:nil];
    
    [self addChildViewController:_pageController];
    [self.view addSubview: _pageController.view];
    [_pageController didMoveToParentViewController:self];
    
    UIViewController *vc = [self itemControllerForIndex: [[self.appExecutive connectedDeviceList] indexOfObject:self.appExecutive.device]];
    [_pageController setViewControllers:[NSArray arrayWithObjects:vc, nil] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion: nil];
}

- (void) viewDidLayoutSubviews
{
    int yPos = self.deviceInfoView.frame.origin.y + self.deviceInfoLabel.frame.size.height + 20;
    int ht = _emailLogFileButton.frame.origin.y - 8 - yPos ;
    _pageController.view.frame = CGRectMake(20, yPos, self.view.frame.size.width-40, ht);
}

- (void) viewWillAppear: (BOOL) animated {

	[super viewWillAppear: animated];

	[[NSNotificationCenter defaultCenter] addObserver: self
											 selector: @selector(deviceDisconnect:)
												 name: kDeviceDisconnectedNotification
											   object: nil];

}


- (void) viewDidAppear: (BOOL) animated {

	[super viewDidAppear: animated];
}

- (void) viewWillDisappear: (BOOL) animated {

	[super viewWillDisappear: animated];

	[[NSNotificationCenter defaultCenter] removeObserver: self];
}

- (void) deviceDisconnect: (id) object {

    NSLog(@"deviceDisconnect dsvc");
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        [self dismissViewControllerAnimated: YES completion: nil];
    });
}


//------------------------------------------------------------------------------

#pragma mark - IBAction Methods

- (IBAction) handleOk: (id) sender {
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"updateBattery" object:nil];

	[self dismissViewControllerAnimated: YES completion: nil];
}

- (IBAction) handleEmailLogFileButton: (UIButton *) sender {

	if ([MFMailComposeViewController canSendMail])
	{
		NSMutableData *errorLogData = [NSMutableData data];

		// accumulate data for all the log files

		for (NSData *errorLogFileData in [self logFileData])
		{
			[errorLogData appendData: errorLogFileData];
		}

		// compose email with log file data

		MFMailComposeViewController *mailViewController	= [[MFMailComposeViewController alloc] init];
		mailViewController.mailComposeDelegate = self;

		[mailViewController setSubject: @"NMX Motion Log File"];
		[mailViewController setToRecipients: [NSArray arrayWithObject: self.emailAddress]];
		[mailViewController addAttachmentData: errorLogData mimeType: @"text/plain" fileName: @"NMX-Motion-Log-File.txt"];

		[self presentViewController: mailViewController animated: YES completion: NULL];
	}
	else
	{
		NSString *message = @"Sorry, the log file cannot be sent at this time.";
		[[[UIAlertView alloc] initWithTitle: nil message: message delegate: nil cancelButtonTitle: @"OK" otherButtonTitles: nil] show];
	}

	return;
}




- (NSMutableArray *) logFileData {

	DDFileLogger *		logger		= [self fileLogger];
	NSUInteger			maxFiles	= 10;
	NSMutableArray *	logData		= [NSMutableArray array];
	NSArray *			sortedInfo	= [logger.logFileManager sortedLogFileInfos];

	for (int index = 0; index < MIN(sortedInfo.count, maxFiles); index++)
	{
		DDLogFileInfo *	logFileInfo	= [sortedInfo objectAtIndex: index];
		NSData *		fileData	= [NSData dataWithContentsOfFile: logFileInfo.filePath];

		[logData addObject: fileData];
	}

	return logData;
}

- (DDFileLogger *) fileLogger {

	for (NSObject *object in [DDLog allLoggers])
	{
		if ([object isKindOfClass: [DDFileLogger class]])
			 return (DDFileLogger *) object;
	}

	return nil;
}


//------------------------------------------------------------------------------

#pragma mark - MFMailComposeViewControllerDelegate Methods


- (void) mailComposeController: (MFMailComposeViewController *) controller didFinishWithResult: (MFMailComposeResult) result error: (NSError *) error {

	[controller dismissViewControllerAnimated: YES completion: NULL];

	switch (result)
	{
		case MFMailComposeResultCancelled:
			[self mailAlertWithMessage: @"Mail was canceled."];
			break;

		case MFMailComposeResultSaved:
			[self mailAlertWithMessage: @"Mail was saved."];
			break;

		case MFMailComposeResultSent:
			[self mailAlertWithMessage: @"Mail was sent."];
			break;

		case MFMailComposeResultFailed:
			[self mailAlertWithError: error];
			break;

		default: break;
	}
}

- (void) mailAlertWithMessage: (NSString *) message {

	UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Mail Status"
													message: message
												   delegate: nil
										  cancelButtonTitle: @"OK"
										  otherButtonTitles: nil];
	[alert show];
}

- (void) mailAlertWithError: (NSError *) error {

	NSString *message = error.localizedDescription;

	UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Mail Error"
													message: message
												   delegate: nil
										  cancelButtonTitle: @"OK"
										  otherButtonTitles: nil];
	[alert show];
}



//------------------------------------------------------------------------------

#pragma mark - UITextFieldDelegate Protocol Methods

- (BOOL) textField: (UITextField *) textField shouldChangeCharactersInRange: (NSRange) range replacementString: (NSString *) string {

    if (!string.length)
        return YES;
    
    if ([textField.restorationIdentifier isEqualToString:@"low"] || [textField.restorationIdentifier isEqualToString:@"high"])
    {
        NSString *newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
        NSString *expression = @"^([0-9]+)?(\\.([0-9]{1,2})?)?$";
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:expression
                                                                               options:NSRegularExpressionCaseInsensitive
                                                                                 error:nil];
        NSUInteger numberOfMatches = [regex numberOfMatchesInString:newString
                                                            options:0
                                                              range:NSMakeRange(0, [newString length])];
        if (numberOfMatches == 0)
            return NO;
    }
    
    return YES;
}

#pragma mark UIPageViewControllerDataSource

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    JSDeviceSettingsVC *itemController = (JSDeviceSettingsVC *)viewController;
    
    if (itemController.itemIndex > 0)
    {
        return [self itemControllerForIndex:itemController.itemIndex-1];
    }
    
    return nil;
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    JSDeviceSettingsVC *itemController = (JSDeviceSettingsVC *)viewController;

    if (itemController.itemIndex+1 < [self.appExecutive connectedDeviceList].count)
    {
        return [self itemControllerForIndex:itemController.itemIndex+1];
    }
    
    return nil;
}

- (JSDeviceSettingsVC *)itemControllerForIndex:(NSUInteger)itemIndex
{
    if (itemIndex < [self.appExecutive connectedDeviceList].count)
    {
        JSDeviceSettingsVC *pageItemController = [self.storyboard instantiateViewControllerWithIdentifier:@"ItemController"];
        pageItemController.itemIndex = (int)itemIndex;
        return pageItemController;
    }
    
    return nil;
}


#pragma mark Page Indicator

- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController
{
    NSUInteger count = [self.appExecutive connectedDeviceList].count;
    return count > 1 ? count : 0;
}

- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController
{
    return [[self.appExecutive connectedDeviceList] indexOfObject:self.appExecutive.device];
}

@end
