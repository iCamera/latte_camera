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
@synthesize apns;
@synthesize window;
@synthesize tracker;

NSString *const FBSessionStateChangedNotification = @"com.luxeys.latte:FBSessionStateChangedNotification";

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
    [FBSession.activeSession close];
}

//- (void) closeSession {
//    [FBSession.activeSession closeAndClearTokenInformation];
//}

- (void)setToken:(NSString *)token{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:token forKey:@"latte_token"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)logOut{
    
}

- (void)checkTokenValidity {
    //FIX ME
    [[LatteAPIClient sharedClient] getPath:@"user/me"
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
    // Register for Push Notification
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
    
    // Check user auth async
    if ([[self getToken] length] > 0) {
        [self checkTokenValidity];
    }
    
    
    // Clear notify but save badge
    [self clearNotification];
    [FBSession openActiveSessionWithAllowLoginUI:NO];

    _uploader = [[NSMutableArray alloc] init];
    
    NSDictionary *remoteNotification = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];

    if (remoteNotification) {
    }
    
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"MainStoryboard"
                                                             bundle:nil];
    
    LXSidePanelController *controllerSide = [[LXSidePanelController alloc] init];
    _viewMainTab = [mainStoryboard instantiateViewControllerWithIdentifier:@"MainTab"];
    controllerSide.centerPanel = _viewMainTab;
    
    window.rootViewController = controllerSide;
    [window makeKeyAndVisible];
    
    return YES;
}


- (void)updateUserAPNS {
    [[LatteAPIClient sharedClient] postPath:@"user/me/update"
                                parameters:[NSDictionary dictionaryWithObjectsAndKeys:
                                            [self getToken], @"token",
                                            apns, @"apns",
                                            nil]
                                    success:nil
                                    failure:nil];
}

/*
 * Callback for session changes.
 */
- (void)sessionStateChanged:(FBSession *)session
                      state:(FBSessionState) state
                      error:(NSError *)error
{
    switch (state) {
        case FBSessionStateOpen:
            if (!error) {
                // We have a valid session
                TFLog(@"User session found");
            }
            break;
        case FBSessionStateClosed:
        case FBSessionStateClosedLoginFailed:
            [FBSession.activeSession closeAndClearTokenInformation];
            break;
        default:
            break;
    }
    
    [[NSNotificationCenter defaultCenter]
     postNotificationName:FBSessionStateChangedNotification
     object:session];
    
    if (error) {
        TFLog(error.localizedDescription);
    }
}

/*
 * Opens a Facebook session and optionally shows the login UX.
 */
- (BOOL)openSessionWithAllowLoginUI:(BOOL)allowLoginUI {
    NSArray *permissions = [[NSArray alloc] initWithObjects:
                            @"email",
                            @"user_photos",
                            nil];
    return [FBSession openActiveSessionWithReadPermissions:permissions
                                              allowLoginUI:allowLoginUI
                                         completionHandler:^(FBSession *session,
                                                             FBSessionState state,
                                                             NSError *error) {
                                   [self sessionStateChanged:session
                                                                 state:state
                                                       error:error];
                               }];
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
    TFLog(@"Error in registration. Error: %@", err);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ReceivedPushNotify" object:userInfo];
    
//    NSDictionary *aps = [userInfo objectForKey:@"aps"];
//    NSDictionary *alert = [aps objectForKey:@"alert"];
//    NSString *action = [alert objectForKey:@"loc-key"];
//    
//    if ([action isEqualToString:@"apns_friend_request"]) {
//        
//    }
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    
    [_controllerCamera.videoCamera pauseCameraCapture];
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
    [_controllerCamera.videoCamera resumeCameraCapture];
    [FBSession.activeSession handleDidBecomeActive];
    
    [self clearNotification];

    [[NSNotificationCenter defaultCenter] postNotificationName:@"BecomeActive" object:self];
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
