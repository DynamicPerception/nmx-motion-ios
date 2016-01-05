//
//  AppDelegate.m
//  joystick
//
//  Created by Mark Zykin on 10/1/14.
//  Copyright (c) 2014 Dynamic Perception. All rights reserved.
//

#import <CocoaLumberjack/CocoaLumberjack.h>

#import "AppDelegate.h"
#import "GAI.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

@synthesize isHome,appBlue,nav,window;

@synthesize internetActive,internetReachableFoo,hostActive,hostReachableFoo;

//testfairy? Rocky2098

//wifi burn0101

- (BOOL) application: (UIApplication *) application didFinishLaunchingWithOptions: (NSDictionary *) launchOptions {

	// Override point for customization after application launch.
    
    [TestFairy begin:@"ec963cd05b830146b2cf9039a57ee8bf80b07863"];

	[[UIApplication sharedApplication] setStatusBarStyle: UIStatusBarStyleLightContent];

	[DDLog addLogger:[DDASLLogger sharedInstance]];
	[DDLog addLogger:[DDTTYLogger sharedInstance]];

	DDFileLogger *fileLogger = [[DDFileLogger alloc] init];

	fileLogger.rollingFrequency = 60 * 60 * 24; // 24 hours rolling
	fileLogger.logFileManager.maximumNumberOfLogFiles = 7; // keep files for seven days
	[DDLog addLogger: fileLogger];
    
    // Setup Google Analytics
    [GAI sharedInstance].trackUncaughtExceptions = YES;
    [[GAI sharedInstance] trackerWithTrackingId:@"UA-62513179-1"];
    
    appBlue = [UIColor colorWithRed:98.0/255 green:170.0/255 blue:246.0/255 alpha:1];
    
    nav = (UINavigationController *)window.rootViewController;
    
    //NSLog(@"nav: %@",nav);
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkNetworkStatus:) name:kReachabilityChangedNotification object:nil];
    
    [self checkNetwork];
    
    
	return YES;
}

- (void) checkNetwork {
    
    internetReachableFoo = [Reachability reachabilityForInternetConnection];
    [internetReachableFoo startNotifier];
    
    hostReachableFoo = [Reachability reachabilityWithHostname:@"www.google.com"];
    [hostReachableFoo startNotifier];
}

- (void) checkNetworkStatus:(NSNotification *)notice {
    
    NetworkStatus internetStatus = [internetReachableFoo currentReachabilityStatus];
    switch (internetStatus)
    {
        case NotReachable:
        {
            //NSLog(@"The internet is down.");
            self.internetActive = NO;
            
            break;
        }
        case ReachableViaWiFi:
        {
            //NSLog(@"The internet is working via WIFI.");
            self.internetActive = YES;
            
            break;
        }
        case ReachableViaWWAN:
        {
            //NSLog(@"The internet is working via WWAN.");
            self.internetActive = YES;
            
            break;
        }
    }
    
    NetworkStatus hostStatus = [hostReachableFoo currentReachabilityStatus];
    switch (hostStatus)
    {
        case NotReachable:
        {
            //NSLog(@"A gateway to the host server is down.");
            self.hostActive = NO;
            
            break;
        }
        case ReachableViaWiFi:
        {
            //NSLog(@"A gateway to the host server is working via WIFI.");
            self.hostActive = YES;
            
            break;
            
        }
        case ReachableViaWWAN:
        {
            //NSLog(@"A gateway to the host server is working via WWAN.");
            self.hostActive = YES;
            
            break;
        }
    }
    
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"hasConnection"
     object:nil];
}


#pragma mark - Core Data stack

- (NSManagedObjectContext *)managedObjectContext {
    
    if (_managedObjectContext != nil) {
        
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    
    if (coordinator != nil) {
        
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

- (NSManagedObjectModel *)managedObjectModel {
    
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"NMXMotion" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"b.sqlite"];
    
    NSError *error = nil;
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}

- (NSURL *)applicationDocumentsDirectory {
    
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (void) applicationWillResignActive: (UIApplication *) application {

	// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
	// Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void) applicationDidEnterBackground: (UIApplication *) application {

    [AppExecutive sharedInstance].device.inBackground = YES;
    
    NSLog(@"in background");
    
    
	// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
	// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void) applicationWillEnterForeground: (UIApplication *) application {

	// Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void) applicationDidBecomeActive: (UIApplication *) application {

	// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    [AppExecutive sharedInstance].device.inBackground = NO;
    
    //NSLog(@"not in background");
}

- (void) applicationWillTerminate: (UIApplication *) application {

	// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
