//
//  JoystickViewController.m
//  joystick
//
//  Created by Mark Zykin on 10/1/14.
//  Copyright (c) 2014 Dynamic Perception. All rights reserved.
//

#import "JoystickViewController.h"
#import "JoystickView.h"
#import "JSDeviceSettings.h"
#import "AppExecutive.h"


//------------------------------------------------------------------------------

#pragma mark - Private Interface

@interface JoystickViewController ()

@property (nonatomic, readonly)	JoystickView *	joystickView;

@end


//------------------------------------------------------------------------------

#pragma mark - Implementation

@implementation JoystickViewController


#pragma mark Public Propery Synthesis

@synthesize delegate,axisLocked,vl,degreeCircle;


#pragma mark Private Propery Synthesis

@synthesize joystickView;


#pragma mark Public Propery Methods

#pragma mark Private Propery Methods


- (JoystickView *) joystickView {
    
	if (joystickView == nil)
		joystickView = (JoystickView *) self.view;

	return  joystickView;
}


//------------------------------------------------------------------------------

#pragma mark - Object Management


- (void) viewDidLoad {
    
    self.view.backgroundColor = [UIColor clearColor];
    
	[super viewDidLoad];
}

- (void) viewDidAppear: (BOOL) animated {
    
	[super viewDidAppear: animated];
    
    float hw;
    float ratio;
    
    UIImage *thumbImage;
    
    if([[UIDevice currentDevice]userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
    {
        //thumbImage = [UIImage imageNamed: @"thumb.png"];
        thumbImage = [UIImage imageNamed: @"white-joystick2.png"];
        
        hw = 195;
        
        //NSLog(@"screen width: %f, %f",[[UIScreen mainScreen] bounds].size.width,[[UIScreen mainScreen] bounds].size.height);
        
        if ([[UIScreen mainScreen] bounds].size.height <= 480)
        {
            NSLog(@"screen 480");
            
            thumbImage = [UIImage imageNamed: @"white-joystick4.png"];
            
            ratio = 35;
            rollerballImageView = [[UIImageView alloc] initWithFrame:CGRectMake(
                                                    self.view.frame.size.width/2 - hw/2 + 24,
                                                    self.view.frame.size.height/2 - hw/2 + 24,
                                                    hw*.75,
                                                    hw*.75)];
            
            degreeCircle = [[UIImageView alloc] initWithFrame:CGRectMake((
                                                  self.view.frame.size.width/2 - hw/2)-(ratio/2)+26,
                                                 (self.view.frame.size.height/2 - hw/2) - (ratio/2)+26,
                                                 rollerballImageView.frame.size.width+ratio*.9,
                                                 rollerballImageView.frame.size.height+ratio*.9)];
        }
        else if ([[UIScreen mainScreen] bounds].size.height == 568)
        {
            //NSLog(@"screen 568");
            
            thumbImage = [UIImage imageNamed: @"white-joystick5.png"];
            
            ratio = 50;
            
            rollerballImageView = [[UIImageView alloc] initWithFrame:CGRectMake(
                            self.view.frame.size.width/2 - hw/2,
                            self.view.frame.size.height/2 - hw/2+20,
                            hw,
                            hw)];
            
            degreeCircle = [[UIImageView alloc] initWithFrame:CGRectMake(
                         self.view.frame.size.width/2 - ((rollerballImageView.frame.size.width + ratio)/2),
                         rollerballImageView.frame.origin.y - (rollerballImageView.frame.size.height/8) ,
                         rollerballImageView.frame.size.width + ratio,
                         rollerballImageView.frame.size.height + ratio)];
        }
        else if ([[UIScreen mainScreen] bounds].size.height == 736 || [[UIScreen mainScreen] bounds].size.height == 667)
        {
            //NSLog(@"screen 736");
            
            //thumbImage = [UIImage imageNamed: @"thumb6.png"];
            
            thumbImage = [UIImage imageNamed: @"white-joystick6.png"];
            
            hw = 250;
            
            ratio = 50;
            
            rollerballImageView = [[UIImageView alloc] initWithFrame:CGRectMake(
                                    self.view.frame.size.width/2 - hw/2,
                                    self.view.frame.size.height/2 - hw/2+30,
                                    hw,
                                    hw)];
            
            degreeCircle = [[UIImageView alloc] initWithFrame:CGRectMake(
                                     self.view.frame.size.width/2 - ((rollerballImageView.frame.size.width + ratio)/2),
                                     rollerballImageView.frame.origin.y - (rollerballImageView.frame.size.height/10) ,
                                     rollerballImageView.frame.size.width + ratio,
                                     rollerballImageView.frame.size.height + ratio)];
        }
    }
    else
    {
        //thumbImage = [UIImage imageNamed: @"thumb5.png"];
        
        thumbImage = [UIImage imageNamed: @"white-joystickP.png"];
        
        hw = 195 * 2;
        ratio = 70;
        
        rollerballImageView = [[UIImageView alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2 - hw/2, self.view.frame.size.height/2 - hw/2, hw, hw)];
        
        degreeCircle = [[UIImageView alloc] initWithFrame:CGRectMake((self.view.frame.size.width/2 - hw/2)-(ratio/2), (self.view.frame.size.height/2 - hw/2) - (ratio/2), rollerballImageView.frame.size.width+ratio, rollerballImageView.frame.size.height+ratio)];
    }
    
    rollerballImageView.image = [UIImage imageNamed:@"rollerball.png"];
    
    if (axisLocked)
    {
        degreeCircle.image = [UIImage imageNamed:@"degree_circleAll.png"];
    }
    else
    {
        degreeCircle.image = [UIImage imageNamed:@"degree_circle2.png"];
    }
    
    UIFont *myFont = [ UIFont fontWithName: @"Arial" size: 13.0 ];
    
    float labelOffset;
    
    if ([[UIScreen mainScreen] bounds].size.height <= 480)
    {
        labelOffset = 5;
    }
    else
    {
        labelOffset = 8;
    }
    
    [self.view addSubview: degreeCircle];
    [self.view addSubview: rollerballImageView];
    
    if (!panTiltLbl)
    {
        panTiltLbl = [[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2 - 200/2, degreeCircle.frame.size.height + degreeCircle.frame.origin.y + labelOffset, 200, 18)];

        panTiltLbl.textColor = [UIColor whiteColor];
        panTiltLbl.textAlignment = NSTextAlignmentCenter;
        panTiltLbl.font = myFont;
        panTiltLbl.numberOfLines = 1;
        panTiltLbl.adjustsFontSizeToFitWidth = YES;
        panTiltLbl.lineBreakMode = NSLineBreakByClipping;
        panTiltLbl.minimumScaleFactor = .5;
        
        [self.view addSubview: panTiltLbl];
    }
    
    JSDeviceSettings *settings = [AppExecutive sharedInstance].device.settings;
    panTiltLbl.text = [NSString stringWithFormat:@"%@/%@ Control", settings.channel2Name, settings.channel3Name];
    
    halfX = (int)self.view.frame.size.width/2;
    halfY = (int)self.view.frame.size.height/2;
    
    //NSLog(@"start vals x: %f y: %f",halfX,halfY);
    
	self.joystickView.thumbImage = thumbImage;
	[self.joystickView setupTransforms];
	[self.view setNeedsDisplay];
}

//------------------------------------------------------------------------------

#pragma mark - Gestures


- (IBAction) handlePanGesture: (UIPanGestureRecognizer *) sender {
    
    
    
	switch (sender.state)
	{
		case UIGestureRecognizerStateBegan:
            [[NSNotificationCenter defaultCenter]
     postNotificationName:@"enterJSMode"
     object:nil];
            
            break;
		case UIGestureRecognizerStateChanged:
			[self updateJoystickDelegate: [sender locationInView: self.joystickView]];
			break;

		case UIGestureRecognizerStateEnded:
            
             self.joystickView.joystickPosition = CGPointZero;
            
			[self updateJoystickDelegate: self.joystickView.joystickViewPoint];
			break;

		default: break;
	}

	return;
}


//------------------------------------------------------------------------------

#pragma mark - Navigation


- (void) prepareForSegue: (UIStoryboardSegue *) segue sender: (id) sender {
	// Get the new view controller using [segue destinationViewController].
	// Pass the selected object to the new view controller.

	return;
}


//------------------------------------------------------------------------------

#pragma mark - JoystickOutput Delegate


- (void) updateJoystickDelegate: (CGPoint) viewLocation {
    
    //NSLog(@"viewLocation x: %f y: %f",viewLocation.x, viewLocation.y);
    
    distX = fabs((fabs(viewLocation.x) - fabs(halfX)));
    distY = fabs((fabs(viewLocation.y) - fabs(halfY)));
    
    //NSLog(@"distX: %f",distX);
    //NSLog(@"distY: %f",distY);
    
    vl = viewLocation;
    
    if (axisLocked)
    {
        [self handleLock:vl];
    }
    else
    {
        self.joystickView.joystickViewPoint = viewLocation;
        
        [self.joystickView setNeedsDisplay];
        
        [self.delegate joystickPosition: self.joystickView.joystickPosition];
    }
}

- (void) handleLock : (CGPoint) viewLocation {
 
    //NSLog(@"viewLocation x: %f y: %f",viewLocation.x, viewLocation.y);
    
    distX = fabs((fabs(viewLocation.x) - fabs(halfX)));
    distY = fabs((fabs(viewLocation.y) - fabs(halfY)));
    
    //NSLog(@"distX: %f",distX);
    //NSLog(@"distY: %f",distY);
    
    if (distX > 5 && distX > distY)
    {
        if (viewLocation.x > lastX)
        {
            //NSLog(@"right");
            
            viewLocation.y = halfY;
        }
        else if (viewLocation.x < lastX)
        {
            //NSLog(@"left");
            
            viewLocation.y = halfY;
        }
        
        upDown = NO;
    }
    
    if (distY > 5 && distY > distX)
    {
        if (viewLocation.y > lastY)
        {
            //NSLog(@"down");
            viewLocation.x = halfX;
        }
        else if (viewLocation.y < lastY)
        {
            //NSLog(@"up");
            viewLocation.x = halfX;
        }
        
        upDown = YES;
    }
    
    lastX = viewLocation.x;
    lastY = viewLocation.y;
    
    vl = viewLocation;
    
    //NSLog(@"viewLocation x: %f y: %f",viewLocation.x, viewLocation.y);
    
    if ((int)viewLocation.x == halfX && (int)viewLocation.y == halfY)
    {
        upDown = NO;
        
        [timer invalidate];
    }
    else
    {
        if (!timer.isValid)
        {
            timer = [NSTimer scheduledTimerWithTimeInterval:0.0001 target:self selector:@selector(lockUpdateTimer) userInfo:nil repeats:YES];
        }
    }
    
    self.joystickView.joystickViewPoint = viewLocation;
    
    [self.joystickView setNeedsDisplay];
    
    [self.delegate joystickPosition: self.joystickView.joystickPosition];
}

- (void) lockUpdateTimer {
    
    if (upDown == YES)
    {
        vl.x = halfX;
    }
    else
    {
        vl.y = halfY;
    }
    
    self.joystickView.joystickViewPoint = vl;
    
    [self.joystickView setNeedsDisplay];
    
//    NSLog(@"halfX-Y: %f, %f",halfX,halfY);
//    NSLog(@"distX-Y: %f, %f",distX,distY);
//    NSLog(@"vl: %f, %f",vl.x,vl.y);
//    NSLog(@"self.joystickPosition: %f",self.joystickView.joystickPosition.x);
    
    [self.delegate joystickPosition: self.joystickView.joystickPosition];
}

- (void) didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
}

@end
