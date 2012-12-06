
/*
     File: TaggedLocationsAppDelegate.h
 Abstract: Application delegate to set up the Core Data stack and configure the view and navigation controllers.
  Version: 1.1
 
 Copyright (C) 2010 LJApps. All Rights Reserved.
 
 */
@class RootViewController;
@class SettingsViewController;
@class HistoryViewController;
@interface TaggedLocationsAppDelegate : NSObject <UIApplicationDelegate, UITabBarControllerDelegate> {
    
    UIWindow *window;
    UINavigationController *navigationController;
	
    NSPersistentStoreCoordinator *persistentStoreCoordinator;
    NSManagedObjectModel *managedObjectModel;
    NSManagedObjectContext *managedObjectContext;
    
//    UIBackgroundTaskIdentifier bgTask;
}

@property (nonatomic, strong) IBOutlet UIWindow *window;
@property (nonatomic, strong) UINavigationController *navigationController;
@property (nonatomic, strong) RootViewController *rootViewController;
@property (nonatomic, strong) SettingsViewController *settingsViewController;
@property (nonatomic, strong) HistoryViewController *historyViewController;

@property (strong, nonatomic) UITabBarController *tabBarController;

- (IBAction)saveAction:sender;

@property (nonatomic, strong, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, strong, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (weak, nonatomic, readonly) NSString *applicationDocumentsDirectory;

@end
