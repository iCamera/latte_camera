//
//  luxeysAppDelegate.h
//  Latte
//
//  Created by Xuan Dung Bui on 7/20/12.
//  Copyright (c) 2012 LUXEYS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KeychainItemWrapper.h"
#import "LXUIRevealController.h"
#import "LXMainTabViewController.h"
#import <FacebookSDK/FacebookSDK.h>
#import "TestFlight.h"

@class User;

#define APPDELEGATE (AppDelegate *)[UIApplication sharedApplication].delegate

@interface LXAppDelegate : UIResponder <UIApplicationDelegate> {
    KeychainItemWrapper *tokenItem;
    LXUIRevealController* revealController;
    NSString *apns;
}

@property (strong, nonatomic) LXUIRevealController *revealController;
@property (nonatomic, retain) KeychainItemWrapper *tokenItem;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (strong, nonatomic) User *currentUser;
@property (strong, nonatomic) NSString *apns;

extern NSString *const FBSessionStateChangedNotification;

- (BOOL)openSessionWithAllowLoginUI:(BOOL)allowLoginUI;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;
- (NSString*)getToken;
- (void)logOut;
- (void)setToken:(NSString*)token;
- (void)updateUserAPNS;
//- (void)closeSession;
- (void)switchRoot;

@end
