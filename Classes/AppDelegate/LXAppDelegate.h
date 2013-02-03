//
//  luxeysAppDelegate.h
//  Latte
//
//  Created by Xuan Dung Bui on 7/20/12.
//  Copyright (c) 2012 LUXEYS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LXUIRevealController.h"
#import "LXMainTabViewController.h"
#import <FacebookSDK/FacebookSDK.h>
#import "TestFlight.h"
#import "GAI.h"

@class User;

#define APPDELEGATE (AppDelegate *)[UIApplication sharedApplication].delegate

@interface LXAppDelegate : UIResponder <UIApplicationDelegate> {
    LXUIRevealController* revealController;
    NSString *apns;
    UIViewController *viewCamera;
    id<GAITracker> tracker;
}

@property(nonatomic, retain) id<GAITracker> tracker;
@property (strong, nonatomic) LXUIRevealController *revealController;

@property (strong, nonatomic) User *currentUser;
@property (strong, nonatomic) NSString *apns;
@property (strong, nonatomic) UIViewController *viewCamera;

extern NSString *const FBSessionStateChangedNotification;

- (BOOL)openSessionWithAllowLoginUI:(BOOL)allowLoginUI;

- (NSURL *)applicationDocumentsDirectory;
- (NSString*)getToken;
- (void)logOut;
- (void)setToken:(NSString*)token;
- (void)updateUserAPNS;
- (void)toogleCamera;

@end
