//
//  luxeysAppDelegate.h
//  Latte
//
//  Created by Xuan Dung Bui on 7/20/12.
//  Copyright (c) 2012 LUXEYS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LXMainTabViewController.h"
#import "FacebookSDK.h"
#import "TestFlight.h"
#import "GAI.h"
#import "LXSidePanelController.h"

@class User;

#define APPDELEGATE (AppDelegate *)[UIApplication sharedApplication].delegate

@interface LXAppDelegate : UIResponder <UIApplicationDelegate, UIAlertViewDelegate> {
    LXSidePanelController *revealController;
    NSString *apns;
    id<GAITracker> tracker;
}

@property(nonatomic, retain) id<GAITracker> tracker;
//@property (strong, nonatomic) LXUIRevealController *revealController;

@property (strong, nonatomic) User *currentUser;
@property (strong, nonatomic) NSString *apns;

extern NSString *const FBSessionStateChangedNotification;

- (BOOL)openSessionWithAllowLoginUI:(BOOL)allowLoginUI;

- (NSURL *)applicationDocumentsDirectory;
- (NSString*)getToken;
- (void)logOut;
- (void)setToken:(NSString*)token;
- (void)updateUserAPNS;
//- (void)toogleCamera;

+ (LXAppDelegate*)currentDelegate;

@end
