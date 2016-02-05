//
//  CameraSettingsTimelineView.m
//  Joystick
//
//  Created by Mitch Middler on 2/3/16.
//  Copyright © 2016 Dynamic Perception. All rights reserved.
//

#import "CameraSettingsTimelineView.h"


@interface CameraSettingsTimelineView()

@property float focusTime;
@property float triggerTime;
@property float delayTime;
@property float bufferTime;

@property UIView *focusBarView;
@property UIView *triggerBarView;
@property UIView *delayBarView;
@property UIView *exposureBarView;
@property UIView *intervalBarView;

@property UIView *playheadView;

@property BOOL stopped;

@end


@implementation CameraSettingsTimelineView

- (void)initialize
{
    self.stopped = YES;
    
    float borderWidth = 1.f;
    self.backgroundColor =  [UIColor colorWithRed:0.10 green:0.20 blue:0.42 alpha:1.0];
    
    self.layer.borderColor = [UIColor colorWithRed:0.38 green:0.66 blue:0.96 alpha:1.0].CGColor;       // self.tintColor.CGColor;
    self.layer.borderWidth = borderWidth;
    
    self.clipsToBounds = YES;
    
    float exposureHtPct = 0.40;
    float subExposureDefPct = 0.20;
    CGSize size = self.frame.size;
    
    self.focusBarView = [[UIView alloc] initWithFrame:CGRectMake(0, borderWidth, size.width*subExposureDefPct, size.height*exposureHtPct)];
    self.focusBarView.backgroundColor =  [UIColor colorWithRed:0.41 green:0.42 blue:0.10 alpha:1.0];
    [self addSubview: self.focusBarView];
    
    self.triggerBarView = [[UIView alloc] initWithFrame:CGRectMake(self.focusBarView.frame.origin.x+self.focusBarView.frame.size.width,
                                                                   borderWidth,
                                                                   size.width*subExposureDefPct,
                                                                   self.focusBarView.frame.size.height)];
    self.triggerBarView.backgroundColor =  [UIColor colorWithRed:0.42 green:0.22 blue:0.09 alpha:1.0];
    [self addSubview: self.triggerBarView];
    
    self.delayBarView = [[UIView alloc] initWithFrame:CGRectMake(self.triggerBarView.frame.origin.x+self.triggerBarView.frame.size.width, borderWidth,
                                                                 size.width*subExposureDefPct, self.focusBarView.frame.size.height)];
    self.delayBarView.backgroundColor =  [UIColor colorWithRed:0.10 green:0.41 blue:0.42 alpha:1.0];
    [self addSubview: self.delayBarView];
    
    self.exposureBarView = [[UIView alloc] initWithFrame:CGRectMake(self.focusBarView.frame.origin.x, self.focusBarView.frame.origin.y+self.focusBarView.frame.size.height,
                                                                    self.focusBarView.frame.size.width+self.triggerBarView.frame.size.width+self.delayBarView.frame.size.width,
                                                                    self.focusBarView.frame.size.height)];
    self.exposureBarView.backgroundColor =  [UIColor colorWithRed:0.10 green:0.30 blue:0.42 alpha:1.0];
    [self addSubview: self.exposureBarView];
    
    self.intervalBarView = [[UIView alloc] initWithFrame:CGRectMake(0,
                                                                    self.exposureBarView.frame.origin.y+self.exposureBarView.frame.size.height,
                                                                    size.width,
                                                                    size.height*(1.-2*exposureHtPct))];
    self.intervalBarView.backgroundColor =  [UIColor colorWithRed:0.10 green:0.11 blue:0.42 alpha:1.0];
    [self addSubview: self.intervalBarView];
    
    float playheadWidth = 4;
    self.playheadView = [[UIView alloc] initWithFrame:CGRectMake(0, borderWidth, playheadWidth, self.intervalBarView.frame.origin.y-borderWidth)];
    self.playheadView.backgroundColor = [UIColor colorWithRed: 1. green: 1. blue: 1. alpha:1.0];
    [self addSubview: self.playheadView];
    
    self.focusBarView.userInteractionEnabled = NO;
    self.triggerBarView.userInteractionEnabled = NO;
    self.delayBarView.userInteractionEnabled = NO;
    self.intervalBarView.userInteractionEnabled = NO;
    self.exposureBarView.userInteractionEnabled = NO;
    self.playheadView.userInteractionEnabled = NO;
    
}

- (id)initWithCoder:(NSCoder *)aCoder{
    if(self = [super initWithCoder:aCoder]){
        [self initialize];
    }
    return self;
}

- (id)initWithFrame:(CGRect)rect{
    if(self = [super initWithFrame:rect]){
        [self initialize];
    }
    return self;
}


- (void) sizeViews
{
    
}

- (void) setCameraTimesForFocus:(float) focus trigger:(float)trigger delay:(float)delay buffer:(float)bufer animated:(BOOL)animated
{
    self.focusTime = focus;
    self.triggerTime = trigger;
    self.delayTime = delay;
    self.bufferTime = bufer;
    
    float exposure = focus + trigger + delay;
    float interval = exposure + bufer;
    
    if (interval <= 0.0) return;
    
    float focusPct = focus/interval;
    float triggerPct = trigger/interval;
    float delayPct = delay/interval;
    
    CGRect frame = self.focusBarView.frame;
    CGRect focusFrame = frame;
    CGRect triggerFrame = self.triggerBarView.frame;
    CGRect delayFrame = self.delayBarView.frame;
    CGRect exposureFrame = self.exposureBarView.frame;
    
    float viewWidth = self.frame.size.width;
    
    focusFrame.size.width = viewWidth * focusPct;
    triggerFrame.size.width = viewWidth * triggerPct;
    triggerFrame.origin.x = focusFrame.origin.x+focusFrame.size.width;
    delayFrame.size.width = viewWidth * delayPct;
    delayFrame.origin.x = triggerFrame.origin.x+triggerFrame.size.width;
    exposureFrame.size.width = focusFrame.size.width+triggerFrame.size.width+delayFrame.size.width;
    
    float duration = animated ? 1.0 : 0.0;
    [UIView animateWithDuration: duration
                     animations:
     ^{
         self.focusBarView.frame = focusFrame;
         self.triggerBarView.frame = triggerFrame;
         self.delayBarView.frame = delayFrame;
         self.exposureBarView.frame = exposureFrame;
     }
     completion:^(BOOL finished)
     {
         //
     }];
}

- (void) stopPlayheadAnimation
{
    self.stopped = YES;
    [self.playheadView.layer removeAllAnimations];
}

- (void) startPlayheadAnimation
{
    self.stopped = NO;
    float duration = self.focusTime + self.triggerTime + self.delayTime + self.bufferTime;
    duration /= 1000;  // convert milliseconds to seconds
    
    CGRect frame = self.playheadView.frame;
    frame.origin.x = self.frame.size.width-frame.size.width-self.layer.borderWidth;

    [UIView setAnimationBeginsFromCurrentState:NO];
    
    [UIView animateWithDuration: duration
                          delay: 0
                        options: UIViewAnimationOptionCurveLinear
                     animations:
     ^{
         self.playheadView.frame = frame;
     }
     completion:^(BOOL finished)
     {
         CGRect frame = self.playheadView.frame;
         frame.origin.x = self.layer.borderWidth;

         self.playheadView.frame = frame;
         
         if (self.stopped == NO)
         {
             [self performSelector: @selector(startPlayheadAnimation) withObject:nil afterDelay:0.005];
         }
     }];
    
}




/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */


@end
