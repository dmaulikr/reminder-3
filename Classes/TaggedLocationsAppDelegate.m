
/*
     File: TaggedLocationsAppDelegate.m
 Abstract: Application delegate to set up the Core Data stack and configure the view and navigation controllers.
  Version: 1.1
 
 Copyright (C) 2010 LJApps. All Rights Reserved.
 
 */

#import "TaggedLocationsAppDelegate.h"
#import "RootViewController.h"
#import "SettingsViewController.h"
//#import "HistoryViewController.h"
//#import "ItemDetailViewController.h"
//#import "EventDetailViewController.h"

@implementation TaggedLocationsAppDelegate

@synthesize window;
@synthesize navigationController, rootViewController;
@synthesize settingsViewController;

#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [SSThemeManager customizeAppAppearance];
    
    // Event View Controller
    rootViewController = [[RootViewController alloc] initWithNibName:@"RootViewController" bundle:nil];
	
	NSManagedObjectContext *context = [self managedObjectContext];
	if (!context) {
		// Handle the error.
		NSLog(@"Unresolved error (no context)");
		exit(-1);  // Fail
	}
	rootViewController.managedObjectContext = context;
	
    // main
	UINavigationController *aNavigationController = [[UINavigationController alloc] initWithRootViewController:rootViewController];
	self.navigationController = aNavigationController;
	
    // History
//    EventDetailViewController *detailViewController = [[EventDetailViewController alloc] initWithNibName:@"EventDetailViewController" bundle:nil];
////    HistoryViewController *historyViewController = [[HistoryViewController alloc] initWithNibName:@"RootViewController" bundle:nil];
////    historyViewController.managedObjectContext = context;
//    UINavigationController *historyNavController = [[UINavigationController alloc] initWithRootViewController:detailViewController];
    
    // Settings
    settingsViewController = [[SettingsViewController alloc] initWithStyle:UITableViewStyleGrouped];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:settingsViewController];
    
    // TODO: can I make the following better?!
    self.tabBarController = [[UITabBarController alloc] init];
    self.tabBarController.viewControllers = @[self.navigationController, navController];

    [[self.tabBarController.tabBar.items objectAtIndex:0] setTitle:NSLocalizedString(@"List", @"")];
//    [[self.tabBarController.tabBar.items objectAtIndex:1] setTitle:NSLocalizedString(@"History", @"")];
    [[self.tabBarController.tabBar.items objectAtIndex:1] setTitle:NSLocalizedString(@"Settings", @"")];
    
    UITabBarItem *item1 = [self.navigationController tabBarItem];
    [SSThemeManager customizeTabBarItem:item1 forTab:SSThemeTabPower];
    
//    UITabBarItem *item2 = [navController tabBarItem];
//    [SSThemeManager customizeTabBarItem:item2 forTab:SSThemeTabDoor];
    
    UITabBarItem *item3 = [navController tabBarItem];
    [SSThemeManager customizeTabBarItem:item3 forTab:SSThemeTabControls];
    
    [window addSubview:self.tabBarController.view];
    
    self.window.rootViewController = self.tabBarController;
//	[window addSubview:[navigationController view]];
	[window makeKeyAndVisible];
    
    // Override point for customization after application launch
//    UILocalNotification *localNotif = [launchOptions
//                                       objectForKey:UIApplicationLaunchOptionsLocalNotificationKey];
//    
//    if (localNotif) {
//        NSString *itemName = [localNotif.userInfo objectForKey:ToDoItemKey];
//        //  [viewController displayItem:itemName]; // custom method
//        application.applicationIconBadgeNumber = localNotif.applicationIconBadgeNumber-1;
//        NSLog(@"has localNotif %@",itemName);
//    }
//    else {
//        [[UIApplication sharedApplication] cancelAllLocalNotifications];
//        NSDate *now = [NSDate date];
//        NSLog(@"now is %@",now);
//        NSDate *scheduled = [now dateByAddingTimeInterval:120] ; //get x minute after
//        NSCalendar *calendar = [NSCalendar currentCalendar];
//        
//        unsigned int unitFlags = NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit;
//        NSDateComponents *comp = [calendar components:unitFlags fromDate:scheduled];
//        
//        NSLog(@"scheduled is %@",scheduled);
//        
//        ToDoItem *todoitem = [[ToDoItem alloc] init];
//        
//        todoitem.day = [comp day];
//        todoitem.month = [comp month];
//        todoitem.year = [comp year];
//        todoitem.hour = [comp hour];
//        todoitem.minute = [comp minute];
//        todoitem.eventName = @"Testing Event";
//        
//        [self scheduleNotificationWithItem:todoitem interval:1];
//        NSLog(@"scheduleNotificationWithItem");
//    }
    [window makeKeyAndVisible];
    return YES;
}

/**
 applicationWillTerminate: saves changes in the application's managed object context before the application terminates.
 */
- (void)applicationWillTerminate:(UIApplication *)application {
	
    NSError *error;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
			// Handle the error.
			NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
			exit(-1);  // Fail
        } 
    }
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
     If your application supports background execution, called instead of applicationWillTerminate: when the user quits.
     */
	
	// Reset the icon badge number to zero.
//	[UIApplication sharedApplication].applicationIconBadgeNumber = 0;
//	
//	if ([CLLocationManager significantLocationChangeMonitoringAvailable]) {
//		// Stop normal location updates and start significant location change updates for battery efficiency.
//        //		[viewController.locationManager stopUpdatingLocation];
//		[rootViewController.locationManager startMonitoringSignificantLocationChanges];
//        NSLog(@"location manager enter background:%@",rootViewController.locationManager);
//	}
//	else {
//		NSLog(@"Significant location change monitoring is not available.");
//	}
    
    // Handel local notification
//    NSLog(@"Application entered background state.");
    // UIBackgroundTaskIdentifier bgTask is instance variable
    // UIInvalidBackgroundTask has been renamed to UIBackgroundTaskInvalid
//    NSAssert(self->bgTask == UIBackgroundTaskInvalid, nil);
//    
//    bgTask = [application beginBackgroundTaskWithExpirationHandler: ^{
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [application endBackgroundTask:self->bgTask];
//            self->bgTask = UIBackgroundTaskInvalid;
//        });
//    }];
//    
//    dispatch_async(dispatch_get_main_queue(), ^{
//        while ([application backgroundTimeRemaining] > 1.0) {
//            NSString *friend = [self checkForIncomingChat];
//            if (friend) {
//                UILocalNotification *localNotif = [[UILocalNotification alloc] init];
//                if (localNotif) {
//                    localNotif.alertBody = [NSString stringWithFormat:
//                                            NSLocalizedString(@"%@ has a message for you.", nil), friend];
//                    localNotif.alertAction = NSLocalizedString(@"Read Msg", nil);
//                    localNotif.soundName = @"alarmsound.caf";
//                    localNotif.applicationIconBadgeNumber = 1;
//                    NSDictionary *infoDict = [NSDictionary dictionaryWithObjectsAndKeys:@"Your Background Task works",ToDoItemKey, @"Message from javacom", MessageTitleKey, nil];
//                    localNotif.userInfo = infoDict;
//                    [application presentLocalNotificationNow:localNotif];
//                    friend = nil;
//                    break;
//                }
//            }
//        }
//        [application endBackgroundTask:self->bgTask];
//        self->bgTask = UIBackgroundTaskInvalid;
//    });
    
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    /*
     Called as part of  transition from the background to the inactive state: here you can undo many of the changes made on entering the background.
     */
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
	
//	if ([CLLocationManager significantLocationChangeMonitoringAvailable]) {
//		// Stop significant location updates and start normal location updates again since the app is in the forefront.
//		[rootViewController.locationManager stopMonitoringSignificantLocationChanges];
//        //		[viewController.locationManager startUpdatingLocation];
//        NSLog(@"location manager become activie:%@",rootViewController.locationManager);
//	}
//	else {
//		NSLog(@"Significant location change monitoring is not available.");
//	}
	
//	if (!rootViewcontroller.updatesTableView.hidden) {
//		// Reload the updates table view to reflect update events that were recorded in the background.
////		[rootViewcontroller.updatesTableView reloadData];
//        
//		// Reset the icon badge number to zero.
//		[UIApplication sharedApplication].applicationIconBadgeNumber = 0;
//	}
}


- (void)applicationWillResignActive:(UIApplication *)application {
	/*
	 Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
	 Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
	 */
}


- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notif {
//    NSLog(@"application: didReceiveLocalNotification:");
//    NSString *itemName = [notif.userInfo objectForKey:ToDoItemKey];
//    NSString *messageTitle = [notif.userInfo objectForKey:MessageTitleKey];
//    // [viewController displayItem:itemName]; // custom method
//    [self _showAlert:itemName withTitle:messageTitle];
//    NSLog(@"Receive Local Notification while the app is still running...");
//    NSLog(@"current notification is %@",notif);
//    application.applicationIconBadgeNumber = notif.applicationIconBadgeNumber-1;
}

#pragma mark - helper method
//- (void) _showAlert:(NSString*)pushmessage withTitle:(NSString*)title
//{
//    
//    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:title message:pushmessage delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
//    [alertView show];
//   
//}


//- (void)scheduleNotificationWithItem:(ToDoItem *)item interval:(int)minutesBefore {
//    NSCalendar *calendar = [NSCalendar autoupdatingCurrentCalendar];
//    NSDateComponents *dateComps = [[NSDateComponents alloc] init];
//    [dateComps setDay:item.day];
//    [dateComps setMonth:item.month];
//    [dateComps setYear:item.year];
//    [dateComps setHour:item.hour];
//    [dateComps setMinute:item.minute];
//    NSDate *itemDate = [calendar dateFromComponents:dateComps];
//    
//    UILocalNotification *localNotif = [[UILocalNotification alloc] init];
//    if (localNotif == nil)
//        return;
//    localNotif.fireDate = [itemDate dateByAddingTimeInterval:-(minutesBefore*60)];
//    NSLog(@"fireDate is %@",localNotif.fireDate);
//    localNotif.timeZone = [NSTimeZone defaultTimeZone];
//    
//    localNotif.alertBody = [NSString stringWithFormat:NSLocalizedString(@"%@ in %i minutes.", nil),
//                            item.eventName, minutesBefore];
//    localNotif.alertAction = NSLocalizedString(@"View Details", nil);
//    
//    localNotif.soundName = UILocalNotificationDefaultSoundName;
//    localNotif.applicationIconBadgeNumber = 1;
//    //  NSDictionary *infoDict = [NSDictionary dictionaryWithObject:item.eventName forKey:ToDoItemKey];
//    NSDictionary *infoDict = [NSDictionary dictionaryWithObjectsAndKeys:item.eventName,ToDoItemKey, @"Local Push received while running", MessageTitleKey, nil];
//    localNotif.userInfo = infoDict;
//    
//    [[UIApplication sharedApplication] scheduleLocalNotification:localNotif];
//    NSLog(@"scheduledLocalNotifications are %@", [[UIApplication sharedApplication] scheduledLocalNotifications]);
//}
//
//- (NSString *) checkForIncomingChat {
//    return @"javacom";
//};

#pragma mark -
#pragma mark Saving

/**
 Performs the save action for the application, which is to send the save:
 message to the application's managed object context.
 */
- (IBAction)saveAction:(id)sender {
	
    NSError *error;
    if (![[self managedObjectContext] save:&error]) {
		// Handle the error.
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		exit(-1);  // Fail
    }
}


#pragma mark -
#pragma mark Core Data stack

/**
 Returns the managed object context for the application.
 If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
 */
- (NSManagedObjectContext *) managedObjectContext {
	
    if (managedObjectContext != nil) {
        return managedObjectContext;
    }
	
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        managedObjectContext = [[NSManagedObjectContext alloc] init];
        [managedObjectContext setPersistentStoreCoordinator: coordinator];
    }
    return managedObjectContext;
}


/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created by merging all of the models found in the application bundle.
 */
- (NSManagedObjectModel *)managedObjectModel {
	
    if (managedObjectModel != nil) {
        return managedObjectModel;
    }
    managedObjectModel = [NSManagedObjectModel mergedModelFromBundles:nil];    
    return managedObjectModel;
}


/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
	
    if (persistentStoreCoordinator != nil) {
        return persistentStoreCoordinator;
    }
	
    NSURL *storeUrl = [NSURL fileURLWithPath: [[self applicationDocumentsDirectory] stringByAppendingPathComponent: @"Locations.sqlite"]];
	
	NSError *error;
    persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel: [self managedObjectModel]];
    if (![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeUrl options:nil error:&error]) {
		// Handle the error.
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		exit(-1);  // Fail
    }    
	
    return persistentStoreCoordinator;
}


#pragma mark -
#pragma mark Application's documents directory

/**
 Returns the path to the application's documents directory.
 */
- (NSString *)applicationDocumentsDirectory {
	
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? paths[0] : nil;
    return basePath;
}


#pragma mark -
#pragma mark Memory management



@end
