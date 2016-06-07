//
//  JSDeviceSettings.m
//  Joystick
//
//  Created by Mitch Middler on 5/18/16.
//  Copyright © 2016 Dynamic Perception. All rights reserved.
//

#import "JSDeviceSettings.h"

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

@end
