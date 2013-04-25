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
#import "LXCanvasViewController.h"
#import "User.h"

#define APPDELEGATE (AppDelegate *)[UIApplication sharedApplication].delegate

@interface LXAppDelegate : UIResponder <UIApplicationDelegate, UIAlertViewDelegate> {
    LXSidePanelController *revealController;
    id<GAITracker> tracker;
}

@property(nonatomic, retain) id<GAITracker> tracker;
@property(strong, nonatomic) LXSidePanelController *controllerSide;

@property (strong, nonatomic) User *currentUser;
@property (strong, nonatomic) LXMainTabViewController *viewMainTab;

@property (strong, nonatomic) NSMutableArray *uploader;

extern NSString *const FBSessionStateChangedNotification;

- (NSURL *)applicationDocumentsDirectory;
- (NSString*)getToken;
- (void)setToken:(NSString*)token;

+ (LXAppDelegate*)currentDelegate;

@end
