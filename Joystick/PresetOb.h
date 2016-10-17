//
//  PresetOb.h
//  
//
//  Created by Randall Ridley on 8/26/15.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface PresetOb : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * exposure;
@property (nonatomic, retain) NSNumber * buffer;
@property (nonatomic, retain) NSNumber * interval;
@property (nonatomic, retain) NSNumber * shotduration;
@property (nonatomic, retain) NSNumber * frames;
@property (nonatomic, retain) NSNumber * videolength;
@property (nonatomic, retain) NSNumber * fps;
@property (nonatomic, retain) NSNumber * focus;
@property (nonatomic, retain) NSNumber * trigger;
@property (nonatomic, retain) NSNumber * delay;
@property (nonatomic, retain) NSNumber * smscontinuous;
@property (nonatomic, retain) NSNumber * timelapsevideo;

@end
