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

#ifdef DEBUG
static NSString * const kLatteSocketURLString = @"dev-latte.luxeys.co.jp";
//static NSString * const kLatteSocketURLString = @"socket.latte.la";
static NSString * const kLatteAPIBaseURLString = @"http://dev-latte.luxeys.co.jp/api";
//static NSString * const kLatteAPIBaseURLString = @"http://local-latte.la/api/";
//static NSString * const kLatteAPIBaseURLString = @"https://latte.la/api/";

static NSString * const kLatteAPIv2BaseURLString = @"http://dev-latte.luxeys.co.jp/api2/";
//static NSString * const kLatteAPIv2BaseURLString = @"http://local-latte.la/api2/";
//static NSString * const kLatteAPIv2BaseURLString = @"https://latte.la/api2/";

#else
static NSString * const kLatteSocketURLString = @"socket.latte.la";
static NSString * const kLatteAPIBaseURLString = @"http://latte.la/api/";
//static NSString * const kLatteAPIBaseURLString = @"http://beta.latte.la/api/";
static NSString * const kLatteAPIv2BaseURLString = @"http://latte.la/api2/";
//static NSString * const kLatteAPIBaseURLString = @"http://beta.latte.la/api/";

#endif

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
