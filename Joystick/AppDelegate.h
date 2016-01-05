//
//  AppDelegate.h
//  joystick
//
//  Created by Mark Zykin on 10/1/14.
//  Copyright (c) 2014 Dynamic Perception. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TestFairy.h"
#import <CoreData/CoreData.h>
#import "AppExecutive.h"
#import "Reachability.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate> {

    bool reachable;
}

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (readonly, strong, nonatomic) UINavigationController *nav;

@property UIColor *appBlue;

@property bool isHome;

@property (strong, nonatomic) Reachability *internetReachableFoo;
@property (strong, nonatomic) Reachability *hostReachableFoo;
@property BOOL internetActive;
@property BOOL hostActive;

@end

