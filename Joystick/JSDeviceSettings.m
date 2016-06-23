//
//  JSDeviceSettings.m
//  Joystick
//
//  Created by Mitch Middler on 5/18/16.
//  Copyright © 2016 Dynamic Perception. All rights reserved.
//

#import "JSDeviceSettings.h"
#import "AppExecutive.h"

@interface JSDeviceSettings()

@property NSMutableDictionary *settings;

@end



@implementation JSDeviceSettings

- (JSDeviceSettings *)initWithDevice:(NSString *)device
{
    self = [super init];
    
    NSUserDefaults* userDefaults =  [NSUserDefaults standardUserDefaults];
    NSDictionary *dict = [userDefaults dictionaryForKey: device];
    
    if (dict)
    {
        _settings = [NSMutableDictionary dictionaryWithDictionary: dict];
    }
    else
    {
        _settings = [NSMutableDictionary new];
    }

    [_settings setValue:device forKey:@"deviceName"];

    return self;
}

- (int) integerForKey:(NSString *)key
{
    NSNumber *num = (NSNumber *)[self.settings objectForKey:key];
    if (num)
    {
        return [num intValue];
    }
    return 0;
}

- (float) floatForKey:(NSString *)key
{
    NSNumber *num = (NSNumber *)[self.settings objectForKey:key];
    if (num)
    {
        return [num floatValue];
    }
    return 0.f;
}

- (NSString*) stringForKey:(NSString *)key
{
    return (NSString *)[self.settings objectForKey:key];
}

- (NSNumber*) numberForKey:(NSString *)key
{
    return (NSNumber *)[self.settings objectForKey:key];
}

- (BOOL) boolForKey:(NSString *)key
{
    NSNumber *num = (NSNumber *)[self.settings objectForKey:key];
    if (num)
    {
        return [num intValue] > 0 ? YES : NO;
    }
    return NO;
}


- (NSArray*) arrayForKey:(NSString *)key
{
    return (NSArray *)[self.settings objectForKey:key];
}

- (NSDictionary*) dictionaryForKey:(NSString *)key
{
    NSDictionary *dict = (NSDictionary *)[self objectForKey:key];
    return dict;
}

- (id) objectForKey: (NSString *)aKey
{
    return [self.settings objectForKey:aKey];
}


- (void) setObject: (id) obj forKey: (NSString *)key
{
    if (obj == nil)
    {
        return;
    }
    [self.settings setObject:obj forKey:key];
}

- (void) setInteger: (int)value forKey: (NSString *)key
{
    NSNumber *num = [NSNumber numberWithInt:value];
    [self setObject:num forKey:key];
}

- (void) setBool: (BOOL)value forKey: (NSString *)key
{
    NSNumber *num = [NSNumber numberWithInt: (value ? 1 : 0)];
    [self setObject:num forKey:key];
    
}

- (void) synchronize
{
    NSUserDefaults* userDefaults =  [NSUserDefaults standardUserDefaults];

    NSString *devName = [_settings valueForKey:@"deviceName"];
    [userDefaults setObject:_settings forKey: devName];
    [userDefaults synchronize];
}

- (BOOL) useJoystick
{
    int val = [self integerForKey:@"useJoystick"];
    if ( val == 1 || val == 0)   // 0 => not set, default to YES
    {
        return YES;
    }
    return NO;
}

- (void) setUseJoystick:(BOOL)useJoystick
{
    [self setObject: [NSNumber numberWithInt:useJoystick?1:2] forKey: @"useJoystick"];
}

- (void) setStart3PSlideDistance:(float)start3PSlideDistance
{
    [self setObject: [NSNumber numberWithFloat: start3PSlideDistance] forKey: @"start3PSlideDistance"];
}

- (float) start3PSlideDistance
{
    return [self floatForKey: @"start3PSlideDistance"];
}

- (void) setStart3PPanDistance:(float)start3PPanDistance
{
    [self setObject: [NSNumber numberWithFloat: start3PPanDistance] forKey: @"start3PPanDistance"];
}

- (float) start3PPanDistance
{
    return [self floatForKey: @"start3PPanDistance"];
}

- (void) setStart3PTiltDistance:(float)value
{
    [self setObject: [NSNumber numberWithFloat: value] forKey: @"start3PTiltDistance"];
}

- (float) start3PTiltDistance
{
    return [self floatForKey: @"start3PTiltDistance"];
}

- (void) setMid3PSlideDistance:(float)value
{
    [self setObject: [NSNumber numberWithFloat: value] forKey: @"mid3PSlideDistance"];
}

- (float) mid3PSlideDistance
{
    return [self floatForKey: @"mid3PSlideDistance"];
}

- (void) setMid3PPanDistance:(float)value
{
    [self setObject: [NSNumber numberWithFloat: value] forKey: @"mid3PPanDistance"];
}

- (float) mid3PPanDistance
{
    return [self floatForKey: @"mid3PPanDistance"];
}

- (void) setMid3PTiltDistance:(float)value
{
    [self setObject: [NSNumber numberWithFloat: value] forKey: @"mid3PTiltDistance"];
}

- (float) mid3PTiltDistance
{
    return [self floatForKey: @"mid3PTiltDistance"];
}

- (void) setEnd3PSlideDistance:(float)value
{
    [self setObject: [NSNumber numberWithFloat: value] forKey: @"end3PSlideDistance"];
}

- (float) end3PSlideDistance
{
    return [self floatForKey: @"end3PSlideDistance"];
}

- (void) setEnd3PPanDistance:(float)value
{
    [self setObject: [NSNumber numberWithFloat: value] forKey: @"end3PPanDistance"];
}

- (float) end3PPanDistance
{
    return [self floatForKey: @"end3PPanDistance"];
}

- (void) setEnd3PTiltDistance:(float)value
{
    [self setObject: [NSNumber numberWithFloat: value] forKey: @"end3PTiltDistance"];
}

- (float) end3PTiltDistance
{
    return [self floatForKey: @"end3PTiltDistance"];
}

- (void) setScaledStart3PSlideDistance:(float)value
{
    [self setObject: [NSNumber numberWithFloat: value] forKey: @"scaledStart3PSlideDistance"];
}

- (float) scaledStart3PSlideDistance
{
    return [self floatForKey: @"scaledStart3PSlideDistance"];
}


- (void) setScaledStart3PPanDistance:(float)value
{
    [self setObject: [NSNumber numberWithFloat: value] forKey: @"scaledStart3PPanDistance"];
}

- (float) scaledStart3PPanDistance
{
    return [self floatForKey: @"scaledStart3PPanDistance"];
}

- (void) setScaledStart3PTiltDistance:(float)value
{
    [self setObject: [NSNumber numberWithFloat: value] forKey: @"scaledStart3PTiltDistance"];
}

- (float) scaledStart3PTiltDistance
{
    return [self floatForKey: @"scaledStart3PTiltDistance"];
}

- (void) setScaledMid3PSlideDistance:(float)value
{
    [self setObject: [NSNumber numberWithFloat: value] forKey: @"scaledMid3PSlideDistance"];
}

- (float) scaledMid3PSlideDistance
{
    return [self floatForKey: @"scaledMid3PSlideDistance"];
}

- (void) setScaledMid3PPanDistance:(float)value
{
    [self setObject: [NSNumber numberWithFloat: value] forKey: @"scaledMid3PPanDistance"];
}

- (float) scaledMid3PPanDistance
{
    return [self floatForKey: @"scaledMid3PPanDistance"];
}

- (void) setScaledMid3PTiltDistance: (float)value
{
    [self setObject: [NSNumber numberWithFloat: value] forKey: @"scaledMid3PTiltDistance"];
}

- (float) scaledMid3PTiltDistance
{
    return [self floatForKey: @"scaledMid3PTiltDistance"];
}

- (void) setScaledEnd3PSlideDistance:(float)value
{
    [self setObject: [NSNumber numberWithFloat: value] forKey: @"scaledEnd3PSlideDistance"];
}

- (float)scaledEnd3PSlideDistance
{
    return [self floatForKey: @"scaledEnd3PSlideDistance"];
}

- (void) setScaledEnd3PPanDistance:(float)value
{
    [self setObject: [NSNumber numberWithFloat: value] forKey: @"scaledEnd3PPanDistance"];
}

- (float)scaledEnd3PPanDistance
{
    return [self floatForKey: @"scaledEnd3PPanDistance"];
}

- (void) setScaledEnd3PTiltDistance:(float)value
{
    [self setObject: [NSNumber numberWithFloat: value] forKey: @"scaledEnd3PTiltDistance"];
}

- (float)scaledEnd3PTiltDistance
{
    return [self floatForKey: @"scaledEnd3PTiltDistance"];
}

- (void) setStart2pSet:(int)start2pSet
{
    [self setObject: [NSNumber numberWithInt:start2pSet] forKey: @"start2pSet"];
}

- (int) start2pSet
{
    return (int)[self integerForKey:@"start2pSet"];
}

- (void) setEnd2pSet:(int)end2pSet
{
    [self setObject: [NSNumber numberWithInt:end2pSet] forKey: @"end2pSet"];
}

- (int) end2pSet
{
    return (int)[self integerForKey:@"end2pSet"];
}

- (void) setStart3PSet:(int)start3PSet
{
    [self setObject: [NSNumber numberWithInt:start3PSet] forKey: @"start3pSet"];
}

- (int) start3PSet
{
    return (int)[self integerForKey:@"start3pSet"];
}

- (void) setMid3PSet:(int)mid3PSet
{
    [self setObject: [NSNumber numberWithInt:mid3PSet] forKey: @"mid3pSet"];
}

- (int) mid3PSet
{
    return (int)[self integerForKey:@"mid3pSet"];
}

- (void) setEnd3PSet:(int)end3PSet
{
    [self setObject: [NSNumber numberWithInt:end3PSet] forKey: @"end3pSet"];
}

- (int) end3PSet
{
    return (int)[self integerForKey:@"end3pSet"];
}

- (void) setSlide3PVal1 :(float)value
{
    [self setObject: [NSNumber numberWithFloat: value] forKey: @"slide3PVal1"];
}

- (float)slide3PVal1
{
    float val = [self floatForKey: @"slide3PVal1"];
    if (val == 0.f)
    {
        [self setSlide3PVal1:1];
        val = 1;
    }
    return val;
}

- (void) setSlide3PVal2 :(float)value
{
    [self setObject: [NSNumber numberWithFloat: value] forKey: @"slide3PVal2"];
}

- (float)slide3PVal2
{
    float val = [self floatForKey: @"slide3PVal2"];
    if (val == 0.f)
    {
        val = [[AppExecutive sharedInstance].frameCountNumber floatValue]/2.f;
        [self setSlide3PVal2:val];
    }
    return val;
}

- (void) setSlide3PVal3 :(float)value
{
    [self setObject: [NSNumber numberWithFloat: value] forKey: @"slide3PVal3"];
}

- (float)slide3PVal3
{
    float val = [self floatForKey: @"slide3PVal3"];
    if (val == 0.f)
    {
        val = [[AppExecutive sharedInstance].frameCountNumber floatValue];
        [self setSlide3PVal3:val];
    }
    return val;
}

- (void) setVoltageLow :(float)value
{
    [self setObject: [NSNumber numberWithFloat: value] forKey: @"voltageLow"];
}

- (float)voltageLow
{
    float val = [self floatForKey: @"voltageLow"];
    if (0 == val)
    {
        val = 10.5;
        [self setVoltageLow: val];
    }
    return val;
}

- (void) setVoltageHigh :(float)value
{
    [self setObject: [NSNumber numberWithFloat: value] forKey: @"voltageHigh"];
}

- (float)voltageHigh
{
    float val = [self floatForKey: @"voltageHigh"];
    if (0 == val)
    {
        val = 12.5;
        [self setVoltageHigh: val];
    }

    return val;
}

- (void) setVoltage :(float)value
{
    [self setObject: [NSNumber numberWithFloat: value] forKey: @"voltage"];
}

- (float)voltage
{
    float val = [self floatForKey: @"voltage"];
    return val;
}

- (void) setMicrostep1 :(int)value
{
    [self setObject: [NSNumber numberWithInt:value] forKey: @"MotorSledMicrosteps"];
}

- (int)microstep1
{
    int val = (int)[self integerForKey:@"MotorSledMicrosteps"];
    if (0 == val)
    {
        [self setMicrostep1:4];
        val = 4;
    }
    return  val;
}

- (void) setMicrostep2 :(int)value
{
    [self setObject: [NSNumber numberWithInt:value] forKey: @"MotorPanMicrosteps"];
}

- (int)microstep2
{
    int val = (int)[self integerForKey:@"MotorPanMicrosteps"];
    if (0 == val)
    {
        [self setMicrostep2:16];
        return 16;
    }
    return  val;

}

- (void) setMicrostep3 :(int)value
{
    [self setObject: [NSNumber numberWithInt:value] forKey: @"MotorTiltMicrosteps"];
}

- (int)microstep3
{
    int val = (int)[self integerForKey:@"MotorTiltMicrosteps"];
    if (0 == val)
    {
        [self setMicrostep3:16];
        return 16;
    }
    return  val;
    
}

- (void) setSlideGear :(int)value
{
    [self setObject: [NSNumber numberWithInt:value] forKey: @"slideGear"];
}

- (int)slideGear
{
    int val = [self integerForKey:@"slideGear"];
    return  val;
    
}

- (void) setSlideMotor :(int)value
{
    [self setObject: [NSNumber numberWithInt:value] forKey: @"slideMotor"];
}

- (int)slideMotor
{
    int val = [self integerForKey:@"slideMotor"];
    return  val;
    
}

- (void) setPanGear :(int)value
{
    [self setObject: [NSNumber numberWithInt:value] forKey: @"panGear"];
}

- (int)panGear
{
    int val = [self integerForKey:@"panGear"];
    return  val;
    
}

- (void) setPanMotor :(int)value
{
    [self setObject: [NSNumber numberWithInt:value] forKey: @"panMotor"];
}

- (int)panMotor
{
    int val = [self integerForKey:@"panMotor"];
    return  val;
    
}

- (void) setTiltGear:(int)value
{
    [self setObject: [NSNumber numberWithInt:value] forKey: @"tiltGear"];
}

- (int)tiltGear
{
    int val = [self integerForKey:@"tiltGear"];
    return  val;
    
}

- (void) setTiltMotor:(int)value
{
    [self setObject: [NSNumber numberWithInt:value] forKey: @"tiltMotor"];
}

- (int)tiltMotor
{
    int val = [self integerForKey:@"tiltMotor"];
    return  val;
    
}

- (void) setSlideMotorCustomValue :(float)value
{
    [self setObject: [NSNumber numberWithFloat: value] forKey: @"slideMotorCustomValue"];
}

- (float)slideMotorCustomValue
{
    float val = [self floatForKey: @"slideMotorCustomValue"];
    return val;
}

- (void) setPanMotorCustomValue :(float)value
{
    [self setObject: [NSNumber numberWithFloat: value] forKey: @"panMotorCustomValue"];
}

- (float)panMotorCustomValue
{
    float val = [self floatForKey: @"panMotorCustomValue"];
    return val;
}

- (void) setTiltMotorCustomValue :(float)value
{
    [self setObject: [NSNumber numberWithFloat: value] forKey: @"tiltMotorCustomValue"];
}

- (float)tiltMotorCustomValue
{
    float val = [self floatForKey: @"tiltMotorCustomValue"];
    return val;
}

- (void) setSlideDirection:(NSString *)str
{
    [self setObject: str forKey: @"slideDirection"];
}

- (NSString *)slideDirection
{
    NSString *str = [self objectForKey:@"slideDirection"];
    if (nil == str)
    {
        str = @"R";
    }
    return str;
}

- (void) setPanDirection:(NSString *)str
{
    [self setObject: str forKey: @"panDirection"];
}

- (NSString *)panDirection
{
    NSString *str = [self objectForKey:@"panDirection"];
    if (nil == str)
    {
        str = @"CCW";
    }
    return str;

}

- (void) setTiltDirection:(NSString *)str
{
    [self setObject: str forKey: @"tiltDirection"];
}

- (NSString *)tiltDirection
{
    NSString *str = [self objectForKey:@"tiltDirection"];
    if (nil == str)
    {
        str = @"UP";
    }
    return str;

}

- (void) setSlideDirectionMode:(NSNumber *)num
{
    [self setObject: num forKey: @"slideDirectionMode"];
}

- (NSNumber *)slideDirectionMode
{
    NSNumber *num = [self objectForKey:@"slideDirectionMode"];
    if (nil == num)
    {
        num = [NSNumber numberWithInt:kLeftRightLabel];
    }
    
    return num;
}

- (void) setPanDirectionMode:(NSNumber *)num
{
    [self setObject: num forKey: @"panDirectionMode"];
}

- (NSNumber *)panDirectionMode
{
    NSNumber *num = [self objectForKey:@"panDirectionMode"];
    if (nil == num)
    {
        num = [NSNumber numberWithInt:kClockwiseCounterClockwiseLabel];
    }
    
    return num;

}

- (void) setTiltDirectionMode:(NSNumber *)num
{
    [self setObject: num forKey: @"tiltDirectionMode"];
}

- (NSNumber *)tiltDirectionMode
{
    NSNumber *num =  [self objectForKey:@"tiltDirectionMode"];
    if (nil == num)
    {
        num = [NSNumber numberWithInt:kUpDownLabel];
    }
    
    return num;

}


@end
