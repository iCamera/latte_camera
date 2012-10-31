//
//  luxeysLoginViewController.h
//  Latte
//
//  Created by Xuan Dung Bui on 8/7/12.
//  Copyright (c) 2012 LUXEYS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>
#import "User.h"
#import "MBProgressHUD.h"

@class KeychainItemWrapper;

@interface luxeysLoginViewController : UIViewController<FBLoginViewDelegate> {
    MBProgressHUD *HUD;
    BOOL isPreload;
    BOOL isPreload2;
}

@property (strong, nonatomic) IBOutlet UITextField *textPass;
@property (strong, nonatomic) IBOutlet UITextField *textUser;
@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *tapView;

- (IBAction)registerClick:(id)sender;
- (IBAction)singleTap:(id)sender;
- (IBAction)goBack:(id)sender;
- (IBAction)login:(id)sender;

@end
