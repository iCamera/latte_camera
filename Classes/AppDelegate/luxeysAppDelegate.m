//
//  luxeysAppDelegate.m
//  Latte
//
//  Created by Xuan Dung Bui on 7/20/12.
//  Copyright (c) 2012 LUXEYS. All rights reserved.
//

#import "luxeysAppDelegate.h"
#import "luxeysSideMenuViewController.h"
#import "luxeysRightSideViewController.h"
#import <Security/Security.h>
#import "luxeysTabBarViewController.h"
#import "LatteAPIClient.h"

@implementation luxeysAppDelegate

@synthesize currentUser;
@synthesize apns;
@synthesize window;
@synthesize tokenItem;
@synthesize viewMainTab;
@synthesize revealController;

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;
// @synthesize fbsession = _fbsession;

// Facebook
// - (BOOL)application:(UIApplication *)application
//             openURL:(NSURL *)url
//   sourceApplication:(NSString *)sourceApplication
//          annotation:(id)annotation {
//     // attempt to extract a token from the url
//     return [self.fbsession handleOpenURL:url];
// }
// FBSample logic

void uncaughtExceptionHandler(NSException *exception) {
    NSLog(@"CRASH: %@", exception);
    NSLog(@"Stack Trace: %@", [exception callStackSymbols]);
    // Internal error reporting
}

- (NSString*)getToken {
    return [tokenItem objectForKey:(id)CFBridgingRelease(kSecAttrService)];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    [self saveContext];
    // FBSample logic
    // [self.fbsession close];
}

- (void)setToken:(NSString *)token{
    [tokenItem setObject:token forKey:(id)CFBridgingRelease(kSecAttrService)];
}

- (void)logOut{
    
}

- (void)checkTokenValidity {
    //FIX ME
    [[LatteAPIClient sharedClient] getPath:@"api/user/me"
                                       parameters:[NSDictionary dictionaryWithObjectsAndKeys:
                                                   [self getToken], @"token", nil]
                                          success:^(AFHTTPRequestOperation *operation, NSDictionary *JSON) {
                                              if ([[JSON objectForKey:@"status"] integerValue] == 1) {
                                                  currentUser = [User instanceFromDictionary:[JSON objectForKey:@"user"]];
                                                  if (apns != nil)
                                                      [self updateUserAPNS];
                                                  
                                                  [[NSNotificationCenter defaultCenter]
                                                   postNotificationName:@"LoggedIn"
                                                   object:self];
                                              }
                                          } failure:nil];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    NSSetUncaughtExceptionHandler(&uncaughtExceptionHandler);
    // Normal launch stuff
    
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"MainStoryboard"
                                                             bundle:nil];
    viewMainTab = (luxeysTabBarViewController*)[mainStoryboard instantiateInitialViewController];
    luxeysRightSideViewController *rightViewController = [mainStoryboard instantiateViewControllerWithIdentifier:@"RightSide"];
    
    revealController = [[LXUIRevealController alloc]initWithFrontViewController:(UIViewController*)viewMainTab
                                                             leftViewController:nil
                                                            rightViewController:rightViewController];
    
    luxeysCameraViewController *viewCapture = [[UIStoryboard storyboardWithName:@"CameraStoryboard"
                                                                         bundle: nil] instantiateInitialViewController];    
    window.rootViewController = viewCapture;
    [window makeKeyAndVisible];
    
    // Register for Push Notification
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
    
    // Check user auth async
	tokenItem = [[KeychainItemWrapper alloc] initWithIdentifier:@"Token" accessGroup:nil];
    if ([[self getToken] length] > 0) {
        [self checkTokenValidity];
    }
    
    // Clear notify but save badge
    [self clearNotification];
    
    return YES;
}

- (void)updateUserAPNS {
    [[LatteAPIClient sharedClient] postPath:@"api/user/me/update"
                                parameters:[NSDictionary dictionaryWithObjectsAndKeys:
                                            [self getToken], @"token",
                                            apns, @"apns",
                                            nil]
                                   success:^(AFHTTPRequestOperation *operation, NSDictionary *JSON) {
                                       if ([[JSON objectForKey:@"status"] integerValue] == 1) {
                                           self.currentUser = [User instanceFromDictionary:[JSON objectForKey:@"user"]];
                                           
                                           [[NSNotificationCenter defaultCenter]
                                            postNotificationName:@"LoggedIn"
                                            object:self];
                                       }
                                   } failure:nil];
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    apns = [[[[deviceToken description]
                                  stringByReplacingOccurrencesOfString: @"<" withString: @""]
                                 stringByReplacingOccurrencesOfString: @">" withString: @""]
                                stringByReplacingOccurrencesOfString: @" " withString: @""];
    if (currentUser != nil) {
        [self updateUserAPNS];
    }
}

- (void)application:(UIApplication *)app didFailToRegisterForRemoteNotificationsWithError:(NSError *)err {
    NSLog(@"Error in registration. Error: %@", err);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo{
    NSLog(@"received push");
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    NSLog(@"Resign active");
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    NSLog(@"Enter Background");
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    NSLog(@"Enter Foregound");
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application
{
    NSLog(@"Become active");
    [self clearNotification];
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)clearNotification {
    int badgeCount = [UIApplication sharedApplication].applicationIconBadgeNumber;
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:badgeCount];
}


- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
             // Replace this implementation with code to handle the error appropriately.
             // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        } 
    }
}

#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
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

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Latte" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Latte.sqlite"];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }    
    
    return _persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

@end
