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
#import "LXUIRevealController.h"

@interface luxeysAppDelegate : UIResponder <UIApplicationDelegate, UINavigationControllerDelegate> {
    KeychainItemWrapper *tokenItem;
    LXUIRevealController* revealController;
    NSString *apns;
}

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) luxeysCameraViewController *storyCamera;
@property (strong, nonatomic) luxeysTabBarViewController *viewMainTab;
@property (strong, nonatomic) LXUIRevealController *revealController;

@property (nonatomic, retain) KeychainItemWrapper *tokenItem;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

// @property (strong, nonatomic) FBSession *fbsession;
@property (strong, nonatomic) User *currentUser;
@property (strong, nonatomic) NSString *apns;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;
- (NSString*)getToken;
- (void)logOut;
- (void)setToken:(NSString*)token;
- (void)updateUserAPNS;

@end
