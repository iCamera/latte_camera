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
#import "ZipArchive.h"
#import "TestFlight.h"
#import "MTStatusBarOverlay.h"

@implementation LXAppDelegate

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
                                parameters:nil
                                   success:^(AFHTTPRequestOperation *operation, NSDictionary *JSON) {
                                       if ([[JSON objectForKey:@"status"] integerValue] == 1) {
                                           self.currentUser = [User instanceFromDictionary:[JSON objectForKey:@"user"]];
                                           
                                           [[NSNotificationCenter defaultCenter]
                                            postNotificationName:@"LoggedIn"
                                            object:self];
                                       } else {
                                           
                                       }
                                   } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                       DLog(@"Something went wrong (Login check)");
                                   }];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [GAI sharedInstance].trackUncaughtExceptions = YES;
    [GAI sharedInstance].dispatchInterval = 20;
    [GAI sharedInstance].debug = NO;
    tracker = [[GAI sharedInstance] trackerWithTrackingId:@"UA-242292-26"];
    [TestFlight takeOff:@"7f91e13e-a760-4471-aa7f-8168d62aa690"];
    
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
    
    [self fetchPreset];
    
    return YES;
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    
    NSString *apns = [[[[deviceToken description]
                                  stringByReplacingOccurrencesOfString: @"<" withString: @""]
                                 stringByReplacingOccurrencesOfString: @">" withString: @""]
                                stringByReplacingOccurrencesOfString: @" " withString: @""];
    DLog(@"Register APNS: %@", apns);
    [[LatteAPIClient sharedClient] postPath:@"user/me/update"
                                 parameters:[NSDictionary dictionaryWithObjectsAndKeys:
                                             [self getToken], @"token",
                                             apns, @"apns",
                                             nil]
                                    success:nil
                                    failure:nil];
}

- (void)application:(UIApplication *)app didFailToRegisterForRemoteNotificationsWithError:(NSError *)err {
    DLog(@"Error in registration. Error: %@", err);
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
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://latte.la/static/appassets.zip"]];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentFolder = [paths objectAtIndex:0];
    NSString *path = [documentFolder stringByAppendingPathComponent:@"assets.zip"];
    operation.outputStream = [NSOutputStream outputStreamToFileAtPath:path append:NO];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, NSData* data) {
        NSString *dataPath = [documentFolder stringByAppendingPathComponent:@"Assets"];
        NSError *error;
        if (![[NSFileManager defaultManager] fileExistsAtPath:dataPath])
            [[NSFileManager defaultManager] createDirectoryAtPath:dataPath withIntermediateDirectories:NO attributes:nil error:&error]; //Create folder
        
        ZipArchive *zipArchive = [[ZipArchive alloc] init];
        [zipArchive UnzipOpenFile:path];
        [zipArchive UnzipFileTo:dataPath overWrite:YES];
        [zipArchive UnzipCloseFile];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        DLog(@"Error: %@", error);
    }];
    
    [operation start];
}

- (void)setCurrentUser:(User *)currentUser {
    _currentUser = currentUser;
    MTStatusBarOverlay *overlay = [MTStatusBarOverlay sharedInstance];
    
    if (currentUser) {
        if (!_currentUser.verified) {
            [overlay postImmediateErrorMessage:NSLocalizedString(@"Your registration has not been completed yet", @"") duration:9999 animated:YES];
        } else {
            [overlay hide];
        }
    } else {
        [overlay hide];
    }
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
    
    if (_currentUser) {
        [[LatteAPIClient sharedClient] getPath:@"user/me"
                                    parameters:nil
                                       success:^(AFHTTPRequestOperation *operation, NSDictionary *JSON) {
                                           self.currentUser = [User instanceFromDictionary:[JSON objectForKey:@"user"]];
                                       } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                           DLog(@"Something went wrong (Login check)");
                                       }];
    }
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
