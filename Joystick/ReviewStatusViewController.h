//
//  ReviewSettingsViewController.h
//  Joystick
//
//  Created by Mark Zykin on 11/24/14.
//  Copyright (c) 2014 Dynamic Perception. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NMXDevice.h"
#import "NMXDeviceManager.h"
#import "GraphView.h"
#import "AppExecutive.h"
#import "ShortDurationViewController.h"
#import "JoyButton.h"
#import "AppDelegate.h"

#import "ELCImagePickerController.h"
#import "ELCAlbumPickerController.h"
#import "ELCAssetTablePicker.h"
#import <QuartzCore/QuartzCore.h>
#import <Social/Social.h>
#import <MessageUI/MessageUI.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "DeviceSettingsViewController.h"
#import "HelpViewController.h"
#import "MBProgressHUD.h"

NSString static	*kSegueToReviewStatusViewController	= @"SegueToReviewStatusViewController";


@interface ReviewStatusViewController : UIViewController <NMXDeviceDelegate, NMXDeviceManagerDelegate,UIImagePickerControllerDelegate,UIActionSheetDelegate,ELCImagePickerControllerDelegate,UIScrollViewDelegate,UIActionSheetDelegate,MFMessageComposeViewControllerDelegate,MFMailComposeViewControllerDelegate,UIDocumentInteractionControllerDelegate> {

    float playheadInterval;
    float lastX;
    NSString *lastFrameShotValue;
    NSInteger shotDurationAnimationLength;
    NSInteger videoRunTime;
    CGRect origPlayheadPosition;
    
    NSTimer *stopTimer;
    NSDate *startDate;
    BOOL running;
    
    NSTimer *countdownTimer;
    NSDate  *timerStartTime;
    NSTimeInterval countdownTime;
    NSTimeInterval originalCountdownTime;
//    int hours;
//    int minutes;
//    int seconds;
    
    float masterFrameCount;
    float graphWidth;
    
    NSString *lastFrameValue;
    float percentCompletePosition;
    
    float screenWidth;
    bool keepAliveStarted;
    
    int count;
    bool debugDisconnect;
    float screenRatio;
    NSTimer *keyframeTimer;
    
    UIImage *chosenImage;
    UIImage *createdImage;
    
    AppDelegate *appDelegate;
    int queryFPS;
    bool camClosed;
    bool reconnecting3P;
    int debugInd;
}

@property (strong, nonatomic) IBOutlet UIView *graphViewContainer;
@property (strong, nonatomic) IBOutlet UIView *playhead;
@property (strong, nonatomic) IBOutlet GraphView *graphView;
@property (strong, nonatomic) IBOutlet GraphView *panGraph;
@property (strong, nonatomic) IBOutlet GraphView *tiltGraph;
@property (nonatomic, strong) AppExecutive *appExecutive;
@property (strong, nonatomic) IBOutlet JoyButton *goBtn;
@property (strong, nonatomic) IBOutlet JoyButton *cancelBtn;
@property (strong, nonatomic) IBOutlet UIView *keepAliveView;
@property (strong, nonatomic) IBOutlet UIButton *startTimerBtn;
@property (strong, nonatomic) IBOutlet UISegmentedControl *atProgramEndControl;
@property (strong, nonatomic) IBOutlet UIView *timerContainer;
@property (strong, nonatomic) IBOutlet UILabel *timerLbl;
@property (weak, nonatomic) IBOutlet UIButton *disconnectBtn;
@property (weak, nonatomic) IBOutlet UILabel *disconnectStatusLbl;
@property (weak, nonatomic) IBOutlet GraphView *graph3P;
@property (weak, nonatomic) IBOutlet JoyButton *shareBtn;
@property (weak, nonatomic) IBOutlet JoyButton *shareBtn2;

@property (nonatomic, retain) UIDocumentInteractionController *dic;
@property (weak, nonatomic) IBOutlet UIButton *settingsButton;
@property (weak, nonatomic) IBOutlet UIImageView *batteryIcon;
@property (weak, nonatomic) IBOutlet UIView *contentBG;
@property (weak, nonatomic) IBOutlet UITextView *debugTxt;


- (IBAction) simulateDisconnect:(id)sender;
- (IBAction) shareScene:(id)sender;

@end
