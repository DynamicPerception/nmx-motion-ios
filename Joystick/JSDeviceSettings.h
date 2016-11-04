//
//  JSDeviceSettings.h
//  Joystick
//
//  Created by Mitch Middler on 5/18/16.
//  Copyright © 2016 Dynamic Perception. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum
{
    kLeftRightLabel,
    kClockwiseCounterClockwiseLabel,
    kUpDownLabel,
    kInOutLabel,
} DirectionLabels;


@interface JSDeviceSettings : NSObject

- (JSDeviceSettings *)initWithDevice:(NSString *)device;

- (int) integerForKey:(NSString *)key;
- (float) floatForKey:(NSString *)key;
- (NSString*) stringForKey:(NSString *)key;
- (NSNumber*) numberForKey:(NSString *)key;
- (NSArray*) arrayForKey:(NSString *)key;
- (BOOL) boolForKey:(NSString *)key;
- (NSDictionary*) dictionaryForKey:(NSString *)key;

- (id)   objectForKey: (NSString *)aKey;
- (void) setObject: (id) obj forKey: (NSString *)key;
- (void) setInteger: (int)value forKey: (NSString *)key;
- (void) setBool: (BOOL)value forKey: (NSString *)key;
- (void) synchronize;

- (void) restoreDefaults;

@property float voltageLow;
@property float voltageHigh;
@property float voltage;

@property int startPoint1;
@property int endPoint1;
@property int startPoint2;
@property int endPoint2;
@property int startPoint3;
@property int endPoint3;

@property (nonatomic) int microstep1;
@property (nonatomic) int microstep2;
@property (nonatomic) int microstep3;

@property float slide3PVal1;
@property float slide3PVal2;
@property float slide3PVal3;

@property float start3PSlideDistance;
@property float mid3PSlideDistance;
@property float end3PSlideDistance;

@property float start3PPanDistance;
@property float mid3PPanDistance;
@property float end3PPanDistance;

@property float scaledStart3PSlideDistance;
@property float scaledMid3PSlideDistance;
@property float scaledEnd3PSlideDistance;

@property float scaledStart3PPanDistance;
@property float scaledMid3PPanDistance;
@property float scaledEnd3PPanDistance;

@property float scaledStart3PTiltDistance;
@property float scaledMid3PTiltDistance;
@property float scaledEnd3PTiltDistance;

@property float start3PTiltDistance;
@property float mid3PTiltDistance;
@property float end3PTiltDistance;

@property BOOL useJoystick;
@property BOOL lockAxis;

@property int start2pSet;
@property int end2pSet;
@property int start3PSet;
@property int mid3PSet;
@property int end3PSet;

@property int slideGear;
@property int slideMotor;

@property int panGear;
@property int panMotor;

@property int tiltGear;
@property int tiltMotor;

@property float slideMotorCustomValue;
@property float panMotorCustomValue;
@property float tiltMotorCustomValue;

@property float slideSensitivity;
@property float panSensitivity;
@property float tiltSensitivity;

@property NSString *slideDirection;
@property NSString *panDirection;
@property NSString *tiltDirection;

@property NSNumber *slideDirectionMode;   // CW/CCW, In/Out, etc.
@property NSNumber *panDirectionMode;     // CW/CCW, In/Out, etc.
@property NSNumber *tiltDirectionMode;    // CW/CCW, In/Out, etc.

@property NSString *channel1Name;
@property NSString *channel2Name;
@property NSString *channel3Name;


// Ramping Settings

@property (nonatomic, strong)		NSArray *			panIncreaseValues;
@property (nonatomic, strong)		NSArray *			panDecreaseValues;
@property (nonatomic, strong)		NSArray *			tiltIncreaseValues;
@property (nonatomic, strong)		NSArray *			tiltDecreaseValues;
@property (nonatomic, strong)		NSArray *			slideIncreaseValues;
@property (nonatomic, strong)		NSArray *			slideDecreaseValues;

@end


