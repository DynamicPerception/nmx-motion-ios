//
//  JSMotorRampingTableViewCell.m
//  Joystick
//
//  Created by Mitch Middler on 6/24/16.
//  Copyright © 2016 Dynamic Perception. All rights reserved.
//

#import "JSMotorRampingTableViewCell.h"
#import "MotorRampingView.h"
#import "MotorRampingViewController.h"
#import "JSDeviceSettings.h"
#import "AppExecutive.h"

@interface JSMotorRampingTableViewCell ()
{
}

@end

@implementation JSMotorRampingTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark utility methods

- (void) configure
{
    JSDeviceSettings *settings = self.device.settings;
    
    if(self.mrvc.programMode == NMXProgramModeVideo)
    {
        NSString *a = [ShortDurationViewController stringForShortDuration: [[AppExecutive sharedInstance].videoLengthNumber integerValue]];
        self.frameCount.text = a;
    }
    else
    {
        self.frameCount.text = [NSString stringWithFormat:@"%i",(int)[[AppExecutive sharedInstance].frameCountNumber floatValue]];
    }
    
    if (self.channel == kSlideChannel)
    {
        self.channelLabel.text = @"Slide";
        self.increaseStart.value = [[settings.slideIncreaseValues firstObject] floatValue];
        self.increaseFinal.value = [[settings.slideIncreaseValues lastObject] floatValue];
        self.decreaseStart.value = [[settings.slideDecreaseValues firstObject] floatValue];
        self.decreaseFinal.value = [[settings.slideDecreaseValues lastObject] floatValue];
    }
    else if (self.channel == kPanChannel)
    {
        self.channelLabel.text = @"Pan";
        self.increaseStart.value = [[settings.panIncreaseValues firstObject] floatValue];
        self.increaseFinal.value = [[settings.panIncreaseValues lastObject] floatValue];
        self.decreaseStart.value = [[settings.panDecreaseValues firstObject] floatValue];
        self.decreaseFinal.value = [[settings.panDecreaseValues lastObject] floatValue];
    }
    else
    {
        self.channelLabel.text = @"Tilt";
        self.increaseStart.value = [[settings.tiltIncreaseValues firstObject] floatValue];
        self.increaseFinal.value = [[settings.tiltIncreaseValues lastObject] floatValue];
        self.decreaseStart.value = [[settings.tiltDecreaseValues firstObject] floatValue];
        self.decreaseFinal.value = [[settings.tiltDecreaseValues lastObject] floatValue];
    }
    
    [self configSliders];

}

- (void) configSliders {
    
    UIColor *	blue	= [UIColor blueColor];
    UIColor *	white	= [UIColor whiteColor];
    
    // set colors so motion of motor has same color along slider tracks
    
    self.increaseStart.minimumTrackTintColor = white;
    self.increaseStart.maximumTrackTintColor = blue;
    self.increaseFinal.minimumTrackTintColor = blue;
    self.increaseFinal.maximumTrackTintColor = white;
    
    self.decreaseStart.minimumTrackTintColor = white;
    self.decreaseStart.maximumTrackTintColor = blue;
    self.decreaseFinal.minimumTrackTintColor = blue;
    self.decreaseFinal.maximumTrackTintColor = white;
    
    [self.increaseStart addTarget:self action:@selector(showFrameText:) forControlEvents:UIControlEventTouchDownRepeat];
    [self.decreaseStart addTarget:self action:@selector(showFrameText:) forControlEvents:UIControlEventTouchDownRepeat];
    [self.increaseFinal addTarget:self action:@selector(showFrameText:) forControlEvents:UIControlEventTouchDownRepeat];
    [self.decreaseFinal addTarget:self action:@selector(showFrameText:) forControlEvents:UIControlEventTouchDownRepeat];

    [self.increaseStart addTarget:self action:@selector(resetSelectedThumb:) forControlEvents:UIControlEventTouchDown];
    [self.decreaseStart addTarget:self action:@selector(resetSelectedThumb:) forControlEvents:UIControlEventTouchDown];
    [self.increaseFinal addTarget:self action:@selector(resetSelectedThumb:) forControlEvents:UIControlEventTouchDown];
    [self.decreaseFinal addTarget:self action:@selector(resetSelectedThumb:) forControlEvents:UIControlEventTouchDown];

    UIImage *i = [self.mrvc imageWithImage:[UIImage imageNamed:@"thumb3.png"] scaledToSize:CGSizeMake(30.0, 30.0)];
    UIImage *b = [self.mrvc imageWithImage:[UIImage imageNamed:@"thumbBlue.png"] scaledToSize:CGSizeMake(30.0, 30.0)];
    //mm can I use the selected state to automatically set the blue thumb????
    [self.increaseStart setThumbImage:i forState:UIControlStateNormal];
    [self.increaseStart setThumbImage:i forState:UIControlStateHighlighted];
    [self.increaseStart setThumbImage:i forState:UIControlStateSelected];
    [self.decreaseStart setThumbImage:i forState:UIControlStateNormal];
    [self.decreaseStart setThumbImage:i forState:UIControlStateHighlighted];
    [self.decreaseStart setThumbImage:i forState:UIControlStateSelected];
    [self.increaseFinal setThumbImage:i forState:UIControlStateNormal];
    [self.increaseFinal setThumbImage:i forState:UIControlStateHighlighted];
    [self.increaseFinal setThumbImage:i forState:UIControlStateSelected];
    [self.decreaseFinal setThumbImage:i forState:UIControlStateNormal];
    [self.decreaseFinal setThumbImage:i forState:UIControlStateHighlighted];
    [self.decreaseFinal setThumbImage:i forState:UIControlStateSelected];

    self.increaseStart.restorationIdentifier = @"increaseStart";
    self.increaseFinal.restorationIdentifier = @"increaseFinal";
    self.decreaseStart.restorationIdentifier = @"decreaseStart";
    self.decreaseFinal.restorationIdentifier = @"decreaseFinal";

    float halfSelectedFrameCount = self.mrvc.selectedFrameCount/2.f;
    self.lbl1.text = [NSString stringWithFormat:@"%i",(int)(self.increaseStart.value * halfSelectedFrameCount)];
    self.lbl2.text = [NSString stringWithFormat:@"%i",(int)(self.increaseFinal.value * halfSelectedFrameCount)];
    self.lbl3.text = [NSString stringWithFormat:@"%i",(int)(self.decreaseStart.value * halfSelectedFrameCount+halfSelectedFrameCount)];
    self.lbl4.text = [NSString stringWithFormat:@"%i",(int)(self.decreaseFinal.value * halfSelectedFrameCount+halfSelectedFrameCount)];

    if (self.mrvc.programMode == NMXProgramModeVideo)
    {
        self.lbl1.text = [self.mrvc convertTime2:[self.lbl1.text floatValue]];
        self.lbl2.text = [self.mrvc convertTime2:[self.lbl2.text floatValue]];
        self.lbl3.text = [self.mrvc convertTime2:[self.lbl3.text floatValue]];
        self.lbl4.text = [self.mrvc convertTime2:[self.lbl4.text floatValue]];
    }
    
    // hide this stuff until the view has been configured and can be drawn properly
    self.lbl1.alpha = 0;
    self.lbl2.alpha = 0;
    self.lbl3.alpha = 0;
    self.lbl4.alpha = 0;
    self.slideView.increaseStart = CGPointMake(-10, -10);
    self.slideView.increaseFinal = CGPointMake(-10, -10);
    self.slideView.decreaseStart = CGPointMake(-10, -10);
    self.slideView.decreaseFinal = CGPointMake(-10, -10);
    [self.slideView setNeedsDisplay];

    //[NSTimer scheduledTimerWithTimeInterval:0.15 target:self selector:@selector(setupDisplays) userInfo:nil repeats:NO];

    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:.15f target:self selector:@selector(setupDisplays) userInfo:nil repeats:NO];
    [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
    
}

/*
Theoretically this is what should trigger setupDisplays since subviews have been configured.  However, there is still some bounds that change
related to our sliders so we calculate thumb positions incorrectly.  Our workaround is to call setupDisplay from a timer.
- (void) layoutSubviews
{
    [self setupDisplays];
}
*/

- (void) setupDisplays
{
    self.lbl1.frame = CGRectMake([self xPositionFromSliderValue:self.increaseStart], self.lbl1.frame.origin.y, self.lbl1.frame.size.width, self.lbl1.frame.size.height);
    [self.lbl1 setNeedsDisplay];
    self.lbl2.frame = CGRectMake([self xPositionFromSliderValue:self.increaseFinal], self.lbl2.frame.origin.y, self.lbl2.frame.size.width, self.lbl2.frame.size.height);
    [self.lbl2 setNeedsDisplay];
    self.lbl3.frame = CGRectMake([self xPositionFromSliderValue:self.decreaseStart], self.lbl3.frame.origin.y, self.lbl3.frame.size.width, self.lbl3.frame.size.height);
    [self.lbl3 setNeedsDisplay];
    self.lbl4.frame = CGRectMake([self xPositionFromSliderValue:self.decreaseFinal], self.lbl4.frame.origin.y, self.lbl4.frame.size.width, self.lbl4.frame.size.height);
    [self.lbl4 setNeedsDisplay];
    
    self.slideView.increaseStart = [self locationOfThumb: self.increaseStart];
    self.slideView.increaseFinal = [self locationOfThumb: self.increaseFinal];
    self.slideView.decreaseStart = [self locationOfThumb: self.decreaseStart];
    self.slideView.decreaseFinal = [self locationOfThumb: self.decreaseFinal];
    
    [self.slideView setNeedsDisplay];

    [UIView animateWithDuration:.4 animations:^{
        
        self.lbl1.alpha = 1;
        self.lbl2.alpha = 1;
        self.lbl3.alpha = 1;
        self.lbl4.alpha = 1;
        
    } completion: nil ];
}


- (float) xPositionFromSliderValue:(UISlider *)aSlider {
    
    float sliderRange2 = aSlider.frame.size.width - aSlider.currentThumbImage.size.width;
    float sliderOrigin = aSlider.frame.origin.x + (aSlider.currentThumbImage.size.width / 2.0);
    
    float sliderValueToPixels = (((aSlider.value - aSlider.minimumValue)/(aSlider.maximumValue - aSlider.minimumValue)) * sliderRange2) + sliderOrigin;
    
    sliderValueToPixels = sliderValueToPixels - (aSlider.currentThumbImage.size.width/2);
    
    return sliderValueToPixels;
}

- (CGPoint) locationOfThumb: (UISlider *) slider {
    
    CGFloat 	value		= slider.value;
    CGFloat		range		= slider.maximumValue - slider.minimumValue;
    CGRect		totalTrack	= [slider trackRectForBounds: slider.bounds];
    CGFloat		thumbWidth	= 26.0;
    CGRect		thumbTrack	= CGRectInset(totalTrack, thumbWidth / 2.0, 0.0);
    CGFloat		thumbX		= thumbTrack.origin.x + (value / range) * thumbTrack.size.width;
    CGFloat		thumbY		= thumbTrack.origin.y + thumbTrack.size.height / 2.0;
    CGPoint		thumbPoint	= CGPointMake(thumbX, thumbY);
    CGPoint		location	= [slider convertPoint: thumbPoint toView: slider.superview];
    
    return location;
}

- (void) updateSlideIncreaseStartLabel
{
    if (self.mrvc.programMode == NMXProgramModeVideo)
    {
        self.lbl1.text = [self.mrvc convertTime2:self.mrvc.currentSelectedFrameValue];
    } else {
        self.lbl1.text = [NSString stringWithFormat:@"%i",(int)self.mrvc.currentSelectedFrameValue];
    }
    
    self.lbl1.frame = CGRectMake([self xPositionFromSliderValue:self.increaseStart], self.lbl1.frame.origin.y, self.lbl1.frame.size.width, self.lbl1.frame.size.height);
    [self.lbl1 setNeedsDisplay];
}

- (void) updateSlideIncreaseFinalLabel
{
    if (self.mrvc.programMode == NMXProgramModeVideo)
    {
        self.lbl2.text = [self.mrvc convertTime2:self.mrvc.currentSelectedFrameValue];
    }
    else
    {
        self.lbl2.text = [NSString stringWithFormat:@"%i",(int)self.mrvc.currentSelectedFrameValue];
    }
    
    self.lbl2.frame = CGRectMake([self xPositionFromSliderValue:self.increaseFinal], self.lbl2.frame.origin.y, self.lbl2.frame.size.width, self.lbl2.frame.size.height);
    [self.lbl2 setNeedsDisplay];
}

- (void) updateSlideDecreaseStartLabel
{
    if (self.mrvc.programMode == NMXProgramModeVideo)
    {
        self.lbl3.text = [self.mrvc convertTime2:self.mrvc.currentSelectedFrameValue];
    }
    else
    {
        self.lbl3.text = [NSString stringWithFormat:@"%i",(int)self.mrvc.currentSelectedFrameValue];
    }
    
    self.lbl3.frame = CGRectMake([self xPositionFromSliderValue:self.decreaseStart], self.lbl3.frame.origin.y, self.lbl3.frame.size.width, self.lbl3.frame.size.height);
    [self.lbl3 setNeedsDisplay];
}

- (void) updateSlideDecreaseFinalLabel
{
    if (self.mrvc.programMode == NMXProgramModeVideo)
    {
        self.lbl4.text = [self.mrvc convertTime2:self.mrvc.currentSelectedFrameValue];
    }
    else
    {
        self.lbl4.text = [NSString stringWithFormat:@"%i",(int)self.mrvc.currentSelectedFrameValue];
    }
    
    self.lbl4.frame = CGRectMake([self xPositionFromSliderValue:self.decreaseFinal], self.lbl4.frame.origin.y, self.lbl4.frame.size.width, self.lbl4.frame.size.height);
    [self.lbl4 setNeedsDisplay];
}


#pragma mark Control Actions

- (IBAction) handleSlideIncreaseStart: (UISlider *) sender {
    
    self.mrvc.currentSelectedFrameValue = sender.value * (self.mrvc.selectedFrameCount/2);
    
    if (sender.value > self.increaseFinal.value)
    {
        self.increaseFinal.value = sender.value;
        
        [self updateSlideIncreaseFinalLabel];
    }
    
    self.slideView.increaseStart = [self locationOfThumb: sender];
    self.slideView.increaseFinal = [self locationOfThumb: self.increaseFinal];
    
    [self.slideView setNeedsDisplay];
    
    [self updateSlideIncreaseStartLabel];
    
    [self saveSlideIncreaseValues];
    
    if (self.mrvc.isLocked)
    {
        [self.mrvc updateIncreaseStartSliders:sender];
    }
}

- (IBAction) handleSlideIncreaseFinal: (UISlider *) sender {
    
    self.mrvc.currentSelectedFrameValue = sender.value * (self.mrvc.selectedFrameCount/2);
    
    if (sender.value < self.increaseStart.value)
    {
        self.increaseStart.value = sender.value;
        
        [self updateSlideIncreaseStartLabel];
    }
    
    self.slideView.increaseStart = [self locationOfThumb: self.increaseStart];
    self.slideView.increaseFinal = [self locationOfThumb: sender];
    
    [self.slideView setNeedsDisplay];
    
    [self updateSlideIncreaseFinalLabel];
    
    [self saveSlideIncreaseValues];
    
    if (self.mrvc.isLocked)
    {
        [self.mrvc updateIncreaseFinalSliders:sender];
    }
}

- (void) saveSlideIncreaseValues {
    
    NSNumber *	startValue	= [NSNumber numberWithFloat: self.increaseStart.value];
    NSNumber *	finalValue	= [NSNumber numberWithFloat: self.increaseFinal.value];
    NSArray *	rampValues	= [NSArray arrayWithObjects: startValue, finalValue, nil];
    
    if (self.channel == kSlideChannel)
    {
        self.device.settings.slideIncreaseValues = rampValues;
    }
    else if (self.channel == kPanChannel)
    {
        self.device.settings.panIncreaseValues = rampValues;
    }
    else
    {
        self.device.settings.tiltIncreaseValues = rampValues;
    }
}

- (IBAction) handleSlideDecreaseStart: (UISlider *) sender {
    
    self.mrvc.currentSelectedFrameValue = sender.value * (self.mrvc.selectedFrameCount/2)+self.mrvc.selectedFrameCount/2;
    
    if (sender.value > self.decreaseFinal.value)
    {
        self.decreaseFinal.value = sender.value;
        
        [self updateSlideDecreaseFinalLabel];
    }
    
    self.slideView.decreaseStart = [self locationOfThumb: sender];
    self.slideView.decreaseFinal = [self locationOfThumb: self.decreaseFinal];
    
    [self.slideView setNeedsDisplay];
    
    [self updateSlideDecreaseStartLabel];
    
    [self saveSlideDecreaseValues];
    
    if (self.mrvc.isLocked)
    {
        [self.mrvc updateDecreaseStartSliders:sender];
    }
}

- (IBAction) handleSlideDecreaseFinal: (UISlider *) sender {
    
    self.mrvc.currentSelectedFrameValue = sender.value * (self.mrvc.selectedFrameCount/2)+self.mrvc.selectedFrameCount/2;
    
    if (sender.value < self.decreaseStart.value)
    {
        self.decreaseStart.value = sender.value;
        
        [self updateSlideDecreaseStartLabel];
    }
    
    self.slideView.decreaseStart = [self locationOfThumb: self.decreaseStart];
    self.slideView.decreaseFinal = [self locationOfThumb: sender];
    
    [self.slideView setNeedsDisplay];
    
    [self updateSlideDecreaseFinalLabel];
    
    [self saveSlideDecreaseValues];
    
    if (self.mrvc.isLocked)
    {
        [self.mrvc updateDecreaseFinalSliders:sender];
    }
}

- (void) saveSlideDecreaseValues {
    
    NSNumber *	startValue	= [NSNumber numberWithFloat: self.decreaseStart.value];
    NSNumber *	finalValue	= [NSNumber numberWithFloat: self.decreaseFinal.value];
    NSArray *	rampValues	= [NSArray arrayWithObjects: startValue, finalValue, nil];
    
    if (self.channel == kSlideChannel)
    {
        self.device.settings.slideDecreaseValues = rampValues;
    }
    else if (self.channel == kPanChannel)
    {
        self.device.settings.panDecreaseValues = rampValues;
    }
    else
    {
        self.device.settings.tiltDecreaseValues = rampValues;
    }
}

#pragma mark thumb actions

- (void) setThumbImage: (UIImage *)image
{
    [self.increaseStart setThumbImage:image forState:UIControlStateNormal];
    [self.increaseFinal setThumbImage:image forState:UIControlStateNormal];
    [self.decreaseStart setThumbImage:image forState:UIControlStateNormal];
    [self.decreaseFinal setThumbImage:image forState:UIControlStateNormal];
}

- (IBAction) resetSelectedThumb:(id)sender
{
    
    UISlider *slider = sender;
    
    UIImage *b = [self.mrvc imageWithImage:[UIImage imageNamed:@"thumbBlue.png"] scaledToSize:CGSizeMake(30.0, 30.0)];

    [self.mrvc resetThumbSelection];
    
    [slider setThumbImage:b forState:UIControlStateNormal];
    [slider setThumbImage:b forState:UIControlStateHighlighted];
    [slider setThumbImage:b forState:UIControlStateSelected];
    
    NSString *framestring = [NSString stringWithFormat:@"%f",self.mrvc.currentSelectedFrameValue];
    
    NSInteger	frameCount	= [framestring integerValue];
    NSInteger	ones		= frameCount % 10;
    NSInteger	tens		= (frameCount / 10) % 10;
    NSInteger	hundreds	= (frameCount / 100) % 10;
    NSInteger	thousands	= (frameCount / 1000) % 10;
    
    [self.mrvc.picker selectRow: thousands inComponent: 0 animated: NO];
    [self.mrvc.picker selectRow: hundreds  inComponent: 1 animated: NO];
    [self.mrvc.picker selectRow: tens      inComponent: 2 animated: NO];
    [self.mrvc.picker selectRow: ones      inComponent: 3 animated: NO];
    
    self.mrvc.currentFrameTarget = slider.restorationIdentifier;
    
}

- (void) showFrameText:(id)sender
{
    [self.mrvc showFrameText: self slider: sender];
}

- (void) updateIncreaseStart: (UISlider *) slider
{
    // This method is used to sync slider with other increaseStart sliders, no need to sync with itself so bail early if that's the case
    if (slider == self.increaseStart) return;
    
    if (slider.value > self.increaseFinal.value)
        self.increaseFinal.value = slider.value;
    
    self.increaseStart.value = slider.value;
    
    self.slideView.increaseStart = [self locationOfThumb: self.increaseStart];
    self.slideView.increaseFinal = [self locationOfThumb: self.increaseFinal];
    
    [self.slideView setNeedsDisplay];
    
    self.lbl1.frame = CGRectMake([self xPositionFromSliderValue:slider], self.lbl1.frame.origin.y, self.lbl1.frame.size.width, self.lbl1.frame.size.height);
    self.lbl1.text = [NSString stringWithFormat:@"%i",(int)self.mrvc.currentSelectedFrameValue];
    
    [self saveSlideIncreaseValues];
    
    [self updateSlideIncreaseStartLabel];
}

- (void) updateIncreaseFinal: (UISlider *) slider
{
    // This method is used to sync slider with other increaseFinal sliders, no need to sync with itself so bail early if that's the case
    if (slider == self.increaseFinal) return;

    if (slider.value < self.increaseStart.value)
        self.increaseStart.value = slider.value;

    self.increaseFinal.value = slider.value;
    
    self.slideView.increaseStart = [self locationOfThumb: self.increaseStart];
    self.slideView.increaseFinal = [self locationOfThumb: self.increaseFinal];
    
    [self.slideView setNeedsDisplay];
    
    self.lbl2.frame = CGRectMake([self xPositionFromSliderValue:slider], self.lbl2.frame.origin.y, self.lbl2.frame.size.width, self.lbl2.frame.size.height);
    self.lbl2.text = [NSString stringWithFormat:@"%i",(int)self.mrvc.currentSelectedFrameValue];
    
    [self saveSlideIncreaseValues];
    
    [self updateSlideIncreaseFinalLabel];
}

- (void) updateDecreaseStart: (UISlider *) slider
{
    // This method is used to sync slider with other decreaseStart sliders, no need to sync with itself so bail early if that's the case
    if (slider == self.decreaseStart) return;

    if (slider.value > self.decreaseFinal.value)
        self.decreaseFinal.value = slider.value;

    self.decreaseStart.value = slider.value;
    
    self.slideView.decreaseStart = [self locationOfThumb: self.decreaseStart];
    self.slideView.decreaseFinal = [self locationOfThumb: self.decreaseFinal];
    
    [self.slideView setNeedsDisplay];
    
    self.lbl3.frame = CGRectMake([self xPositionFromSliderValue:slider], self.lbl3.frame.origin.y, self.lbl3.frame.size.width, self.lbl3.frame.size.height);
    self.lbl3.text = [NSString stringWithFormat:@"%i",(int)self.mrvc.currentSelectedFrameValue];
    
    [self saveSlideDecreaseValues];
    
    [self updateSlideDecreaseStartLabel];

}

- (void) updateDecreaseFinal: (UISlider *) slider
{
    // This method is used to sync slider with other decreaseFinal sliders, no need to sync with itself so bail early if that's the case
    if (slider == self.decreaseFinal) return;

    if (slider.value < self.decreaseStart.value)
        self.decreaseStart.value = slider.value;
    
    self.decreaseFinal.value = slider.value;
    
    self.slideView.decreaseStart = [self locationOfThumb: self.decreaseStart];
    self.slideView.decreaseFinal = [self locationOfThumb: self.decreaseFinal];
    
    [self.slideView setNeedsDisplay];
    
    self.lbl4.frame = CGRectMake([self xPositionFromSliderValue:slider], self.lbl4.frame.origin.y, self.lbl4.frame.size.width, self.lbl4.frame.size.height);
    self.lbl4.text = [NSString stringWithFormat:@"%i",(int)self.mrvc.currentSelectedFrameValue];
    
    [self saveSlideDecreaseValues];
    
    [self updateSlideDecreaseFinalLabel];

}




@end
