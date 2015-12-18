//
//  NSNumber+ASI.m
//  ASI Library
//
//  Created by Dave Koziol on 1/12/15.
//  Copyright (c) 2015 Arbormoon Software, Inc. All rights reserved.
//

#import "NSNumber+ASI.h"

@implementation NSNumber (ASI)

+ (NSNumber *) numberWithUInt8: (UInt8) inNumber {

    return [self numberWithUnsignedChar: inNumber];
}

+ (NSNumber *) numberWithSInt8: (SInt8) inNumber {

    return [self numberWithChar: inNumber];
}

+ (NSNumber *) numberWithUInt16: (UInt16) inNumber {

    return [self numberWithUnsignedShort: inNumber];
}

+ (NSNumber *) numberWithSInt16: (UInt16) inNumber {

    return [self numberWithShort: inNumber];
}

+ (NSNumber *) numberWithUInt32: (UInt32) inNumber {

#if __LP64__
    return [NSNumber numberWithUnsignedInt: inNumber];
#else
    return [NSNumber numberWithUnsignedLong: inNumber];
#endif
}

+ (NSNumber *) numberWithSInt32: (UInt32) inNumber {

#if __LP64__
    return [NSNumber numberWithInt: inNumber];
#else
    return [NSNumber numberWithUnsignedLong: inNumber];
#endif
}

- (UInt8) UInt8Value {

    return [self unsignedCharValue];
}

- (SInt8) SInt8Value {

    return [self charValue];
}

- (UInt16) UInt16Value {

    return [self unsignedShortValue];
}

- (SInt16) SInt16Value {

    return [self shortValue];
}

- (UInt32) UInt32Value {

#if __LP64__
    return [self unsignedIntValue];
#else
    return [self unsignedLongValue];
#endif
}

- (SInt32) SInt32Value {

#if __LP64__
    return [self intValue];
#else
    return [self longValue];
#endif
}



@end
