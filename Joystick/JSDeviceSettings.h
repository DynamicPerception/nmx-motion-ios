//
//  JSDeviceSettings.h
//  Joystick
//
//  Created by Mitch Middler on 5/18/16.
//  Copyright © 2016 Dynamic Perception. All rights reserved.
//

#import <Foundation/Foundation.h>

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

@end
