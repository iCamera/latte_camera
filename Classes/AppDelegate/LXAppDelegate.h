//
//  luxeysAppDelegate.h
//  Latte
//
//  Created by Xuan Dung Bui on 7/20/12.
//  Copyright (c) 2012 LUXEYS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LXMainTabViewController.h"
#import <FacebookSDK/FacebookSDK.h>
#import "GAI.h"
#import "LXCanvasViewController.h"
#import "User.h"

#define APPDELEGATE (AppDelegate *)[UIApplication sharedApplication].delegate

@interface LXAppDelegate : UIResponder <UIApplicationDelegate, UIAlertViewDelegate> {
    id<GAITracker> tracker;
}

@property(nonatomic, retain) id<GAITracker> tracker;

@property (strong, nonatomic) User *currentUser;
@property (strong, nonatomic) LXMainTabViewController *viewMainTab;

@property (strong, nonatomic) NSMutableArray *uploader;

extern NSString *const FBSessionStateChangedNotification;

- (NSURL *)applicationDocumentsDirectory;
- (NSString*)getToken;
- (void)setToken:(NSString*)token;


+ (LXAppDelegate*)currentDelegate;

@end
