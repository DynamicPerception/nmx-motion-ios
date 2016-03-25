//
//  HSpline.m
//  Joystick
//
//  Created by Mitch Middler on 3/15/16.
//  Copyright © 2016 Dynamic Perception. All rights reserved.
//

#import "HSpline.h"


@implementation KeyFrameModel


@end


@interface HSpline()
{
    float _function, _deriv, _secondDeriv;
    NSArray<NSNumber *> *_xn, *_fn, *_dn;
}

@end


@implementation HSpline

- (HSpline *) init
{
    self = [super init];
    
    if (self)
    {
        _velocityIncrement = 0.1;
    }
    
    return self;
}



/** Loads the values to be interpolated
 *
 * @param xn Array of abscissas
 * @param fn Array of function values at each abscissa
 * @param dn Array of derivative values at each abscissa
 */
- (void) init: (NSArray<NSNumber *> *) x fn:(NSArray<NSNumber *> *) f dn:(NSArray<NSNumber *> *) d
{
    _xn = x;
    _fn = f;
    _dn = d;
}


/** Sets the function (f), derivative (d), and second derivative (s)
 *  values at a given x along a cubic function defined by the end points,
 *  x1, f1, d1, and x2, f2, d2.
 *
 * @param x1 Abscissa of point 1
 * @param f1 Function value of point 1
 * @param d1 Derivative of point 1
 * @param x2 Abscissa of point 2
 * @param f2 Function value of point 2
 * @param d2 Derivative of point 2
 * @param x  Value from 0.0-1.0 representing position along curve as percent
 */
- (void) cubicValue:(float) x1 f1:(float) f1 d1:(float)d1 x2:(float) x2 f2:(float) f2 d2:(float) d2 x:(float) x
{
    float c2;
    float c3;
    float df;
    float h;
    
    h = x2 - x1;
    df = (f2 - f1) / h;
    
    c2 = -((float)2.0 * d1 - (float)3.0 * df + d2) / h;
    c3 = (d1 - (float)2.0 * df + d2) / h / h;
    
    _function = f1 + (x - x1) * (d1 + (x - x1) * (c2 + (x - x1) *   c3));
    _deriv = d1 + (x - x1) * ((float)2.0 * c2 + (x - x1) * (float)3.0 * c3);
    _secondDeriv = (float)2.0 * c2 + (x - x1) * (float)6.0 * c3;
    
}


/** Sets the function (f), derivative (d), and second derivative (s)
 *  values at a given x along a cubic spline. The cubic function segment
 *  of the spline is automatically selected.
 *
 * @param x
 */
- (void) cubicSplineValue: (float) x
{
    // If the requested position is beyond the extents of the key frames, simply return the position at the nearest extent
    if(x > _xn[[_xn count] - 1].floatValue)
    {
        x = _xn[[_xn count] - 1].floatValue;
    }
    else if(x < _xn[0].floatValue)
    {
        x = _xn[0].floatValue;
    }
    
    int curve = [self findCurve: x];
    
    [self cubicValue: _xn[curve].floatValue f1: _fn[curve].floatValue d1: _dn[curve].floatValue
                  x2: _xn[curve + 1].floatValue f2: _fn[curve + 1].floatValue d2: _dn[curve + 1].floatValue x: x];
}

/**
 *
 * @return The value of the function at the calculated x value
 */
- (float) getFunctionVal
{
    return _function;
}

/**
 *
 * @return The value of the derivative at the calculated x value
 */
- (float) getDeriv
{
    return _deriv;
}

/**
 *
 * @return The value of the second derivative at the calculated x value
 */
- (float) getSecondDeriv
{
    return _secondDeriv;
}

/**
 *
 * @return On which curve segment of the composite spline the requested x value is located
 */
- (int) findCurve :(float) x
{
    int which = 0;
    
    for(int i = 0; i < [_xn count]; i++)
    {
        if(x >= _xn[i].floatValue && x <= _xn[i+1].floatValue)
            return i;
    }
    
    return which;
}

/*
 public class SplineChecker {
 HermiteSpline hermite = null;
 private List<KeyFrameModel> keyFrames = null;
 private float[] xn;
 private float[] fn;
 private float[] dn;
 */
- (void) initSpline: (NSMutableArray<KeyFrameModel *> *)keyframes
{
    NSUInteger pointCount = keyframes.count;
    
    NSMutableArray<NSNumber *> *xn = [NSMutableArray arrayWithCapacity:pointCount];
    NSMutableArray<NSNumber *> *fn = [NSMutableArray arrayWithCapacity:pointCount];
    NSMutableArray<NSNumber *> *dn = [NSMutableArray arrayWithCapacity:pointCount];
    
    for(int i = 0; i < pointCount; i++){
        KeyFrameModel *thisFrame = keyframes[i];
        xn[i] = [NSNumber numberWithFloat: thisFrame.time];
        fn[i] = [NSNumber numberWithFloat: thisFrame.position];
        dn[i] = [NSNumber numberWithFloat: thisFrame.velocity];
    }
    
    [self init:xn fn:fn dn:dn];
}

/**
 * Determines whether the spline reverses direction between
 * the two given key points.
 * @param keyFrame Which key frame to check against
 * @return Whether the spline segment ever reverses direction
 */
- (BOOL) reverses: (NSMutableArray<KeyFrameModel *> *)keyframes point0:(int) point0 point1:(int) point1
{
    [self initSpline :keyframes];
    
    // Can't do the calculations if one or both of the requested points don't exist
    NSUInteger kfCount = keyframes.count;
    if(point0 < 0 || point1 > kfCount)
        return false;
    
    int SAMPLES = 100;
    float startX = keyframes[point0].time;
    float stopX = keyframes[point1].time;
    float startY = keyframes[point0].position;
    float stopY = keyframes[point1].position;
    
    BOOL positiveDir = (stopY - startY) >= 0 ? true : false;
    
    float increment = (stopX - startX) / SAMPLES;
    for(int i = 0; i < SAMPLES; i++)
    {
        [self cubicSplineValue: startX + i * increment];
        float vel = [self getDeriv];
        
        if((positiveDir && vel < 0) || (!positiveDir && vel > 0))
        {
            //NSLog(@"Offending location: x -- %g  vel: %g", (i * increment), vel);
            return YES;
        }
    }
    return NO;
}

- (void) optimizePointVel: (KeyFrameModel *)thisFrame timeTime:(float)time beforePos:(float) beforePos pos: (float) pos afterPos: (float) afterPos
                     axis:(NSMutableArray<KeyFrameModel *> *)keyframes index:(int)index
{
    // Optimize point
    
    float velIncrement = (afterPos - beforePos) >= 0 ? _velocityIncrement : -_velocityIncrement;
    BOOL optimize = true;
    
    // KeyAxisModel *thisAxis = KeyAxisModel.getKFAbsAxis(thisPoint.axisAbsolute);
    float thisVel = 0;
    
    NSUInteger counter = 0;
    NSUInteger MAX_ITERATIONS = 100000;
    
    while(optimize && counter < MAX_ITERATIONS)
    {
        counter++;
        thisVel += velIncrement;
        thisFrame.velocity = thisVel;
        
        if([self reverses: keyframes point0: index-1  point1: index+1])
        {
            //Set the new velocity to thisVel - velIncrement
            thisFrame.velocity = thisVel - velIncrement;
            optimize = false;
        }
    }
}

- (void) optimizePointVelForAxis:(NSMutableArray<KeyFrameModel *> *)keyframes
{
    //NSLog(@"Optimizing point");
    
    NSUInteger kfCount = keyframes.count;
    
    for (int kf = 0; kf < kfCount; kf++)
    {
        //List<KeyFrameModel> frames = axisModel.getKeyFrames();
        if(kf != 0 && kfCount > 2 && kf < kfCount - 1)
        {
            KeyFrameModel *thisFrame = keyframes[kf];
            
            float thisTime = thisFrame.time;
            float beforePos = keyframes[kf-1].position;
            float pos = keyframes[kf].position;
            float afterPos = keyframes[kf+1].position;
            // Don't optimize if the middle point is the same as the one before or after
            // Don't optimize if the middle point is not positionally between the point before and the point after
            if(beforePos == pos || afterPos == pos ||
               (beforePos > pos && afterPos > pos) || (beforePos < pos && afterPos < pos) )
            {
                continue;
            }
            else
            {
                // Otherwise find the best velocity for point smoothing
                [self optimizePointVel:thisFrame timeTime:thisTime beforePos:beforePos pos:pos afterPos:afterPos axis:keyframes index:kf];
            }
        }
    }
}

- (void) testIt
{
    NSMutableArray *keyframeArrays;
    
    keyframeArrays = [NSMutableArray arrayWithCapacity:6];
    
    for (int axis = 0; axis < 6; axis++)
    {
        [keyframeArrays addObject: [NSMutableArray arrayWithCapacity:3]];
        
        for (int point = 0; point < 3; point++)
        {
            KeyFrameModel *kfm = [KeyFrameModel new];
            [keyframeArrays[axis] addObject: kfm];
        }
    }
    
    KeyFrameModel *kfm = keyframeArrays[0][0];
    kfm.time = 0;
    kfm.position = 20000;
    kfm.velocity = 0;
    kfm = keyframeArrays[0][1];
    kfm.time = 29;
    kfm.position = 19000;
    kfm.velocity = 0;
    kfm = keyframeArrays[0][2];
    kfm.time = 100;
    kfm.position = 3000;
    kfm.velocity = 0;
    
    kfm = keyframeArrays[1][0];
    kfm.time = 0;
    kfm.position = 20000;
    kfm.velocity = 0;
    kfm = keyframeArrays[1][1];
    kfm.time = 70;
    kfm.position = 8704;
    kfm.velocity = 0;
    kfm = keyframeArrays[1][2];
    kfm.time = 100;
    kfm.position = 3000;
    kfm.velocity = 0;
    
    kfm = keyframeArrays[2][0];
    kfm.time = 12;
    kfm.position = 2067;
    kfm.velocity = 0;
    kfm = keyframeArrays[2][1];
    kfm.time = 84;
    kfm.position = 9411;
    kfm.velocity = 0;
    kfm = keyframeArrays[2][2];
    kfm.time = 97;
    kfm.position = 19692;
    kfm.velocity = 0;
    
    
    
    kfm = keyframeArrays[3][0];
    kfm.time = 0;
    kfm.position = 0;
    kfm.velocity = 0;
    kfm = keyframeArrays[3][1];
    kfm.time = 26000;
    kfm.position = 11000;
    kfm.velocity = 0;
    kfm = keyframeArrays[3][2];
    kfm.time = 30000;
    kfm.position = 44000;
    kfm.velocity = 0;
    
    kfm = keyframeArrays[4][0];
    kfm.time = 0;
    kfm.position = 0;
    kfm.velocity = 0;
    kfm = keyframeArrays[4][1];
    kfm.time = 8000;
    kfm.position = 29000;
    kfm.velocity = 0;
    kfm = keyframeArrays[4][2];
    kfm.time = 30000;
    kfm.position = 44000;
    kfm.velocity = 0;
    
    kfm = keyframeArrays[5][0];
    kfm.time = 0;
    kfm.position = 0;
    kfm.velocity = 0;
    kfm = keyframeArrays[5][1];
    kfm.time = 25000;
    kfm.position = 35000;
    kfm.velocity = 0;
    kfm = keyframeArrays[5][2];
    kfm.time = 30000;
    kfm.position = 44000;
    kfm.velocity = 0;
    
    for (int axis = 0; axis < 6; axis++)
    {
        NSLog(@"BEFORE AXIS = %d", axis);
        for (int point = 0; point < 3; point++)
        {
            KeyFrameModel *kfm = keyframeArrays[axis][point];
            NSLog(@"POINT = %d   t=%g   pos=%g   vel=%g", point, kfm.time, kfm.position, kfm.velocity);
        }
    }
    
    
    [self optimizePointVelForAxis:keyframeArrays[0]];
    [self optimizePointVelForAxis:keyframeArrays[1]];
    [self optimizePointVelForAxis:keyframeArrays[2]];
    [self optimizePointVelForAxis:keyframeArrays[3]];
    [self optimizePointVelForAxis:keyframeArrays[4]];
    [self optimizePointVelForAxis:keyframeArrays[5]];
    
    for (int axis = 0; axis < 6; axis++)
    {
        NSLog(@"AFTER AXIS = %d", axis);
        for (int point = 0; point < 3; point++)
        {
            KeyFrameModel *kfm = keyframeArrays[axis][point];
            NSLog(@"POINT = %d   t=%g   pos=%g   vel=%g", point, kfm.time, kfm.position, kfm.velocity);
        }
    }
    
    
}


@end
