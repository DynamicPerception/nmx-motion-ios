//
//  NSNumber+ASI.h
//  ASI Library
//
//  Created by Dave Koziol on 1/12/15.
//  Copyright (c) 2015 Arbormoon Software, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSNumber (ASI)

+ (NSNumber *) numberWithUInt8: (UInt8) inNumber;
+ (NSNumber *) numberWithSInt8: (SInt8) inNumber;
+ (NSNumber *) numberWithUInt16: (UInt16) inNumber;
+ (NSNumber *) numberWithSInt16: (UInt16) inNumber;
+ (NSNumber *) numberWithUInt32: (UInt32) inNumber;
+ (NSNumber *) numberWithSInt32: (UInt32) inNumber;

- (UInt8) UInt8Value;
- (SInt8) SInt8Value;
- (UInt16) UInt16Value;
- (SInt16) SInt16Value;
- (UInt32) UInt32Value;
- (SInt32) SInt32Value;

@end
