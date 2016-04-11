//
//  CameraSettingsTimelineView.m
//  Joystick
//
//  Created by Mitch Middler on 2/3/16.
//  Copyright © 2016 Dynamic Perception. All rights reserved.
//

#import "CameraSettingsTimelineView.h"
#import "AppExecutive.h"


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
@property UIView *motorMoveView;
@property UILabel *motorMoveLabel;

@property UIView *playheadView;

@property BOOL stopped;

@property UInt32 resyncAt;

@end


@implementation CameraSettingsTimelineView

+ (UIColor *)focusColor
{
    return [UIColor colorWithRed:0.41 green:0.42 blue:0.10 alpha:1.0];
}

+ (UIColor *)triggerColor
{
    return [UIColor colorWithRed:0.42 green:0.22 blue:0.09 alpha:1.0];
}

+ (UIColor *)delayColor
{
    return [UIColor colorWithRed:0.10 green:0.41 blue:0.42 alpha:1.0];
}

+ (UIColor *)bufferColor
{
    return [UIColor colorWithRed:0.10 green:0.20 blue:0.42 alpha:1.0];
}

+ (UIColor *)intervalColor
{
    return [UIColor colorWithRed:0.86 green:0.86 blue:0.86 alpha:1.0];
}

+ (UIColor *)exposureColor
{
    return [UIColor colorWithRed:0.10 green:0.30 blue:0.42 alpha:1.0];
}

+ (UIColor *)motorMoveColor
{
    return [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];
}


- (void)initialize
{
    self.stopped = YES;
    
    float borderWidth = 1.f;
    self.backgroundColor = [CameraSettingsTimelineView bufferColor];
    
    self.layer.borderColor = [UIColor colorWithRed:0.38 green:0.66 blue:0.96 alpha:1.0].CGColor;       // self.tintColor.CGColor;
    self.layer.borderWidth = borderWidth;
    
    self.clipsToBounds = YES;
    
    float exposureHtPct = 0.40;
    float subExposureDefPct = 0.20;
    CGSize size = self.frame.size;
    
    self.focusBarView = [[UIView alloc] initWithFrame:CGRectMake(0, borderWidth, size.width*subExposureDefPct, size.height*exposureHtPct)];
    self.focusBarView.backgroundColor = [CameraSettingsTimelineView focusColor];
    [self addSubview: self.focusBarView];
    
    self.triggerBarView = [[UIView alloc] initWithFrame:CGRectMake(self.focusBarView.frame.origin.x+self.focusBarView.frame.size.width,
                                                                   borderWidth,
                                                                   size.width*subExposureDefPct,
                                                                   self.focusBarView.frame.size.height)];
    self.triggerBarView.backgroundColor = [CameraSettingsTimelineView triggerColor];
    [self addSubview: self.triggerBarView];
    
    self.delayBarView = [[UIView alloc] initWithFrame:CGRectMake(self.triggerBarView.frame.origin.x+self.triggerBarView.frame.size.width, borderWidth,
                                                                 size.width*subExposureDefPct, self.focusBarView.frame.size.height)];
    self.delayBarView.backgroundColor = [CameraSettingsTimelineView delayColor];
    [self addSubview: self.delayBarView];
    
    self.exposureBarView = [[UIView alloc] initWithFrame:CGRectMake(self.focusBarView.frame.origin.x, self.focusBarView.frame.origin.y+self.focusBarView.frame.size.height,
                                                                    self.focusBarView.frame.size.width+self.triggerBarView.frame.size.width+self.delayBarView.frame.size.width,
                                                                    self.focusBarView.frame.size.height)];
    self.exposureBarView.backgroundColor = [CameraSettingsTimelineView exposureColor];
    [self addSubview: self.exposureBarView];

    self.intervalBarView = [[UIView alloc] initWithFrame:CGRectMake(0,
                                                                    self.exposureBarView.frame.origin.y+self.exposureBarView.frame.size.height,
                                                                    size.width,
                                                                    size.height*(1.-2*exposureHtPct))];
    self.intervalBarView.backgroundColor = [CameraSettingsTimelineView intervalColor];
    [self addSubview: self.intervalBarView];

    float motorMoveWidth = 2;
    self.motorMoveView = [[UIView alloc] initWithFrame:CGRectMake(self.exposureBarView.frame.origin.x+self.exposureBarView.frame.size.width,
                                                                  borderWidth,
                                                                  motorMoveWidth,
                                                                  self.intervalBarView.frame.origin.y-borderWidth)];
    self.motorMoveView.backgroundColor = [CameraSettingsTimelineView motorMoveColor];
    [self addSubview: self.motorMoveView];
    
    self.motorMoveLabel = [UILabel new];
    self.motorMoveLabel.frame = CGRectMake(self.motorMoveView.frame.origin.x + 10,
                                           self.motorMoveView.frame.origin.y + 1,
                                           50, self.frame.size.height-3-self.intervalBarView.frame.size.height);
    self.motorMoveLabel.text = @"Motors Move";
    self.motorMoveLabel.textColor = [UIColor whiteColor];
    self.motorMoveLabel.adjustsFontSizeToFitWidth = YES;
    self.motorMoveLabel.numberOfLines = 0;
    [self addSubview: self.motorMoveLabel];
    
    float playheadWidth = 4;
    self.playheadView = [[UIView alloc] initWithFrame:CGRectMake(0, borderWidth, playheadWidth, self.intervalBarView.frame.origin.y-borderWidth)];
    self.playheadView.backgroundColor = [UIColor colorWithRed: 1. green: 1. blue: 1. alpha:1.0];
    [self addSubview: self.playheadView];
    
    self.focusBarView.userInteractionEnabled = NO;
    self.triggerBarView.userInteractionEnabled = NO;
    self.delayBarView.userInteractionEnabled = NO;
    self.intervalBarView.userInteractionEnabled = NO;
    self.exposureBarView.userInteractionEnabled = NO;
    self.motorMoveView.userInteractionEnabled = NO;
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
    CGRect intervalFrame = self.intervalBarView.frame;
    CGRect motorMoveFrame = self.motorMoveView.frame;
    CGRect motorMoveLabelFrame = self.motorMoveLabel.frame;
    
    float viewWidth = self.frame.size.width;
    
    focusFrame.size.width = viewWidth * focusPct;
    triggerFrame.size.width = viewWidth * triggerPct;
    triggerFrame.origin.x = focusFrame.origin.x+focusFrame.size.width;
    delayFrame.size.width = viewWidth * delayPct;
    delayFrame.origin.x = triggerFrame.origin.x+triggerFrame.size.width;
    exposureFrame.size.width = focusFrame.size.width+triggerFrame.size.width+delayFrame.size.width;
    motorMoveFrame.origin.x = exposureFrame.origin.x + exposureFrame.size.width;
    motorMoveLabelFrame.origin.x = motorMoveFrame.origin.x + 3;
    intervalFrame.size.width = self.frame.size.width;
    
    float duration = animated ? 1.0 : 0.0;
    [UIView animateWithDuration: duration
                     animations:
     ^{
         self.focusBarView.frame = focusFrame;
         self.triggerBarView.frame = triggerFrame;
         self.delayBarView.frame = delayFrame;
         self.exposureBarView.frame = exposureFrame;
         self.intervalBarView.frame = intervalFrame;
         self.motorMoveLabel.frame = motorMoveLabelFrame;
         self.motorMoveView.frame = motorMoveFrame;
         
         //NSLog(@"Frame self = %@     focus = %@  trigger = %@   delay = %@   exp = %@  interv = %@",
         //      NSStringFromCGRect(self.frame), NSStringFromCGRect(focusFrame), NSStringFromCGRect(triggerFrame),
         //      NSStringFromCGRect(delayFrame), NSStringFromCGRect(exposureFrame), NSStringFromCGRect(intervalFrame));
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
         if (self.resyncAt > 0)   // We end up here if we stop animation because we need to resync the playhead
         {
             
             // Calculate a new duration to animate to the end of the timeline to catch up with the device
             float duration = MAX(0,self.focusTime + self.triggerTime + self.delayTime + self.bufferTime-self.resyncAt);
             duration /= 1000;  // convert milliseconds to seconds
             
             self.resyncAt = 0;
             
             CGRect frame = self.playheadView.frame;
             frame.origin.x = self.frame.size.width-frame.size.width-self.layer.borderWidth;

             [UIView animateWithDuration: duration
                                   delay: 0
                                 options: UIViewAnimationOptionCurveLinear
                              animations:
              ^{
                  self.playheadView.frame = frame;
              }
              completion:^(BOOL finished)
              {
                  // Continue animation, should should now be sync'ed with the device
                  [self performSelector: @selector(startPlayheadAnimation) withObject:nil afterDelay:0.005];
              }];

         }
         else
         {
             CGRect frame = self.playheadView.frame;
             frame.origin.x = self.layer.borderWidth;
             
             self.playheadView.frame = frame;
             
             if (self.stopped == NO || self.resyncAt > 0)
             {
                 [self performSelector: @selector(startPlayheadAnimation) withObject:nil afterDelay:0.005];
             }
         }
     }];
    
}

- (UInt32) getPlayheadTime
{
    CGPoint presentationPosition = [[self.playheadView.layer presentationLayer] position];
    float pct = presentationPosition.x / self.frame.size.width;
    
    float exposure = self.focusTime + self.triggerTime + self.delayTime;
    float interval = exposure + self.bufferTime;

    return pct * interval;
}

- (BOOL) playheadOutOfSync: (UInt32)newPlayheadTime
{
    long outOfSyncTime = 300;  // resync if we are 300ms different between playheads
    
    long playheadTime = (long)[self getPlayheadTime];
    long diff = labs((long)newPlayheadTime-playheadTime);

    float interval = [self getTotalIntervalTime];
    
    if (diff > outOfSyncTime && diff < interval-outOfSyncTime)
    {
        CGRect frame = [[self.playheadView.layer presentationLayer] frame];
        self.playheadView.frame = frame;
        
        return YES;
    }
    
    return NO;
}

- (float) getTotalIntervalTime
{
    return self.focusTime + self.triggerTime + self.delayTime + self.bufferTime;
}

- (void) syncPlayheadToTime: (UInt32)newPlayheadTime
{
    if ([self playheadOutOfSync:newPlayheadTime])
    {
        self.resyncAt = newPlayheadTime;
        
        [self stopPlayheadAnimation];
    }
}


/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */


@end
