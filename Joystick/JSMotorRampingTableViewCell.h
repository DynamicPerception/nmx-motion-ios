//
//  JSMotorRampingTableViewCell.h
//  Joystick
//
//  Created by Mitch Middler on 6/24/16.
//  Copyright © 2016 Dynamic Perception. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MotorRampingViewController;
@class MotorRampingView;
@class NMXDevice;

typedef enum
{
    kSlideChannel = 0,
    kPanChannel = 1,
    kTiltChannel = 2,
    kNumChannels = 3
} JSChannelIdx;

@interface JSMotorRampingTableViewCell : UITableViewCell

@property NMXDevice *device;
@property MotorRampingViewController *mrvc;

@property (strong, nonatomic) IBOutlet MotorRampingView *slideView;
@property (weak, nonatomic) IBOutlet UILabel *frameCount;
@property (strong, nonatomic) IBOutlet UILabel *channelLabel;

@property (nonatomic, strong)	IBOutlet	UISlider *	increaseStart;
@property (nonatomic, strong)	IBOutlet	UISlider *	increaseFinal;
@property (nonatomic, strong)	IBOutlet	UISlider *	decreaseStart;
@property (nonatomic, strong)	IBOutlet	UISlider *	decreaseFinal;

@property (weak, nonatomic) IBOutlet UILabel *lbl1;
@property (weak, nonatomic) IBOutlet UILabel *lbl2;
@property (weak, nonatomic) IBOutlet UILabel *lbl3;
@property (weak, nonatomic) IBOutlet UILabel *lbl4;

@property JSChannelIdx channel;

- (void) setThumbImage: (UIImage *)image;

- (void) updateIncreaseStart: (UISlider *) slider;
- (void) updateIncreaseFinal: (UISlider *) slider;
- (void) updateDecreaseStart: (UISlider *) slider;
- (void) updateDecreaseFinal: (UISlider *) slider;

- (void) configure;
- (void) setupDisplays;

@end
