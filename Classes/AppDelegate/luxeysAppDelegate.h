//
//  luxeysAppDelegate.h
//  Latte
//
//  Created by Xuan Dung Bui on 7/20/12.
//  Copyright (c) 2012 LUXEYS. All rights reserved.
//

#import <UIKit/UIKit.h>
// #import <FacebookSDK/FacebookSDK.h>
#import "KeychainItemWrapper.h"
#import "luxeysCameraViewController.h"
#import "luxeysTabBarViewController.h"
#import "LuxeysUser.h"

@class luxeysNavViewController;

@interface luxeysAppDelegate : UIResponder <UIApplicationDelegate, UINavigationControllerDelegate> {
    KeychainItemWrapper *tokenItem;
}

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UIViewController *storyMain;
@property (strong, nonatomic) luxeysCameraViewController *storyCamera;
@property (strong, nonatomic) luxeysNavViewController *viewMainNav;
@property (strong, nonatomic) luxeysTabBarViewController *viewMainTab;

@property (nonatomic, retain) KeychainItemWrapper *tokenItem;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

// @property (strong, nonatomic) FBSession *fbsession;
@property (strong, nonatomic) LuxeysUser *currentUser;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;
- (NSString*)getToken;
- (void)logOut;
- (void)setToken:(NSString*)token;

@end
