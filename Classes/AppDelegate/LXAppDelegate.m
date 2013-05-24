//
//  luxeysAppDelegate.m
//  Latte
//
//  Created by Xuan Dung Bui on 7/20/12.
//  Copyright (c) 2012 LUXEYS. All rights reserved.
//

#import "LXAppDelegate.h"
#import "LXNotifySideViewController.h"
#import "LatteAPIClient.h"

@implementation LXAppDelegate

@synthesize currentUser;
@synthesize window;
@synthesize tracker;

+ (LXAppDelegate*)currentDelegate {
    return (LXAppDelegate*)[UIApplication sharedApplication].delegate;
}

- (BOOL)application:(UIApplication *)application
             openURL:(NSURL *)url
   sourceApplication:(NSString *)sourceApplication
          annotation:(id)annotation {
     // attempt to extract a token from the url
    return [FBSession.activeSession handleOpenURL:url];
}

- (NSString*)getToken {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *token = [defaults objectForKey:@"latte_token"];
    if (token == nil)
        return @"";
    else
        return token;
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // FBSample logic
    [FBSession.activeSession closeAndClearTokenInformation];
}

- (void)setToken:(NSString *)token{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:token forKey:@"latte_token"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)checkTokenValidity {
    //FIX ME
    [[LatteAPIClient sharedClient] getPath:@"user/me"
                                parameters:[NSDictionary dictionaryWithObjectsAndKeys:
                                            [self getToken], @"token", nil]
                                   success:^(AFHTTPRequestOperation *operation, NSDictionary *JSON) {
                                       if ([[JSON objectForKey:@"status"] integerValue] == 1) {
                                           currentUser = [User instanceFromDictionary:[JSON objectForKey:@"user"]];                                           
                                           
                                           [[NSNotificationCenter defaultCenter]
                                            postNotificationName:@"LoggedIn"
                                            object:self];
                                       }
                                   } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                       TFLog(@"Something went wrong (Login check)");
                                   }];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
//#define TESTING 1
//#ifdef TESTING
//    NSString *uuid = [[UIDevice currentDevice] uniqueIdentifier];
//    [TestFlight setDeviceIdentifier:uuid];
//#endif
    
    [GAI sharedInstance].trackUncaughtExceptions = YES;
    [GAI sharedInstance].dispatchInterval = 20;
    [GAI sharedInstance].debug = NO;
    tracker = [[GAI sharedInstance] trackerWithTrackingId:@"UA-242292-26"];
    
    [TestFlight takeOff:@"7f1fb2cd-bf2d-41bc-bbf7-4a6870785c9e"];
    
    // Check user auth async
    if ([[self getToken] length] > 0) {
        [self checkTokenValidity];
    }
    
    
    // Clear notify but save badge
    [self clearNotification];

    _uploader = [[NSMutableArray alloc] init];
    
    NSDictionary *remoteNotification = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];

    if (remoteNotification) {
    }
    
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"MainStoryboard"
                                                             bundle:nil];
    
    _controllerSide = [[LXSidePanelController alloc] init];
    _viewMainTab = [mainStoryboard instantiateViewControllerWithIdentifier:@"MainTab"];
    _controllerSide.centerPanel = _viewMainTab;
    
    window.rootViewController = _controllerSide;
    [window makeKeyAndVisible];
    
    NSDictionary *remoteNotif = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    
    if(remoteNotif)
    {
        [_viewMainTab showNotify];
    }
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"preset" ofType:@"plist"];
    _arrayPreset = [NSArray arrayWithContentsOfFile:path];
    
    return YES;
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    
    NSString *apns = [[[[deviceToken description]
                                  stringByReplacingOccurrencesOfString: @"<" withString: @""]
                                 stringByReplacingOccurrencesOfString: @">" withString: @""]
                                stringByReplacingOccurrencesOfString: @" " withString: @""];
    TFLog(@"Register APNS: %@", apns);
    [[LatteAPIClient sharedClient] postPath:@"user/me/update"
                                 parameters:[NSDictionary dictionaryWithObjectsAndKeys:
                                             [self getToken], @"token",
                                             apns, @"apns",
                                             nil]
                                    success:nil
                                    failure:nil];
}

- (void)application:(UIApplication *)app didFailToRegisterForRemoteNotificationsWithError:(NSError *)err {
    TFLog(@"Error in registration. Error: %@", err);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ReceivedPushNotify" object:userInfo];
    
    if([application applicationState] == UIApplicationStateInactive)
    {
        [_viewMainTab showNotify];
    }
}

- (void)fetchPreset {    
    //-------------------------
    NSArray *documentPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentFolder = [documentPath objectAtIndex:0];
    
    //the below variable is an instance of the NSString class and is declared inteh .h file
    NSString *newPlistFile = [documentFolder stringByAppendingPathComponent:@"preset.plist"];
    NSArray *tmpPreset = [NSArray arrayWithContentsOfFile:newPlistFile];
    
    if (tmpPreset) {
        _arrayPreset = tmpPreset;
    }
    
    LatteAPIClient *api = [LatteAPIClient sharedClient];
    [api getPath:@"picture/presets"
      parameters:[NSDictionary dictionaryWithObject:[self getToken] forKey:@"token"]
         success:^(AFHTTPRequestOperation *operation, NSDictionary *JSON) {
             _arrayPreset = JSON[@"presets"];
             
             [_arrayPreset writeToFile:newPlistFile atomically:YES];
             
         } failure:nil];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application
{
    [FBSession.activeSession handleDidBecomeActive];
    
    [self clearNotification];

    [[NSNotificationCenter defaultCenter] postNotificationName:@"BecomeActive" object:self];
    
    [self fetchPreset];
}

- (void)clearNotification {
    int badgeCount = [UIApplication sharedApplication].applicationIconBadgeNumber;
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:badgeCount];
}

#pragma mark - Core Data stack


#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

@end
