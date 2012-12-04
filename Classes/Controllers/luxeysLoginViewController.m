//
//  luxeysLoginViewController.m
//  Latte
//
//  Created by Xuan Dung Bui on 8/7/12.
//  Copyright (c) 2012 LUXEYS. All rights reserved.
//

#import "luxeysLoginViewController.h"
#import "LatteAPIClient.h"
#import "luxeysAppDelegate.h"

@interface luxeysLoginViewController ()

@end

@implementation luxeysLoginViewController


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    //[self.navigationController setNavigationBarHidden:true];
    luxeysAppDelegate* app = (luxeysAppDelegate*)[UIApplication sharedApplication].delegate;
    
    self.textUser.text = [app.tokenItem objectForKey:(id)CFBridgingRelease(kSecAttrAccount)];
    self.textPass.text = [app.tokenItem objectForKey:(id)CFBridgingRelease(kSecValueData)];
    
    isPreload = true;
    isPreload2 = true;
    
    
    
    HUD = [[MBProgressHUD alloc] initWithView:self.view];
	[self.view addSubview:HUD];
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(sessionStateChanged:)
     name:FBSessionStateChangedNotification
     object:nil];
    
    // Check the session for a cached token to show the proper authenticated
    // UI. However, since this is not user intitiated, do not show the login UX.
    [app openSessionWithAllowLoginUI:NO];
}

- (void)sessionStateChanged:(NSNotification*)notification {
    if (FBSession.activeSession.isOpen) {
        TFLog(@"Open fb");
        [[LatteAPIClient sharedClient] postPath:@"api/user/login_facebook"
                                     parameters:[NSDictionary dictionaryWithObjectsAndKeys:
                                                 FBSession.activeSession.accessToken, @"facebook_token", nil]
                                        success:^(AFHTTPRequestOperation *operation, NSDictionary *JSON) {
                                            [self processLogin:JSON];
                                        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                            TFLog(@"Something went wrong (Facebook): %@", error.description);
                                        }];
//        [self.authButton setTitle:@"Logout" forState:UIControlStateNormal];
    } else {
        TFLog(@"Unopen fb");
//        [self.authButton setTitle:@"Login" forState:UIControlStateNormal];
    }
}

- (void)viewDidDisappear:(BOOL)animated {
//    luxeysAppDelegate* app = (luxeysAppDelegate*)[UIApplication sharedApplication].delegate;
//    [app.fbLogin setDelegate:nil];
    //[self.navigationController setNavigationBarHidden:false];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (IBAction)registerClick:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://latte.la/user/register"]];
}

- (IBAction)singleTap:(id)sender {
    [self.textUser resignFirstResponder];
    [self.textPass resignFirstResponder];
}

- (IBAction)goBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)login:(id)sender {
    [HUD show:YES];
    luxeysAppDelegate* app = (luxeysAppDelegate*)[UIApplication sharedApplication].delegate;
    [app.tokenItem setObject:self.textUser.text forKey:(id)CFBridgingRelease(kSecAttrAccount)];
    [app.tokenItem setObject:self.textPass.text forKey:(id)CFBridgingRelease(kSecValueData)];
    
    [[LatteAPIClient sharedClient] postPath:@"api/user/login"
                                 parameters:[NSDictionary dictionaryWithObjectsAndKeys:
                                             self.textUser.text, @"mail",
                                             self.textPass.text, @"password", nil]
                                    success:^(AFHTTPRequestOperation *operation, NSDictionary *JSON) {
                                        [self processLogin:JSON];
                                    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                        TFLog(@"Something went wrong (Login)");
                                    }];
}

- (IBAction)touchForgot:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://latte.la/user/reset_password"]];
}

- (IBAction)touchFacebook:(id)sender {
    [HUD show:YES];
    luxeysAppDelegate* app = (luxeysAppDelegate*)[UIApplication sharedApplication].delegate;
    [app openSessionWithAllowLoginUI:YES];
}

- (IBAction)touchTest:(id)sender {
    TFLog(@"Touched");
}

- (void)processLogin:(NSDictionary *)JSON {
    luxeysAppDelegate* app = (luxeysAppDelegate*)[UIApplication sharedApplication].delegate;
    
    if ([JSON objectForKey:@"token"] == 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"エラー"
                                                        message:@"ログイン出来ませんでした。メールアドレスとパスワードを確認して下さい。"
                                                       delegate:nil
                                              cancelButtonTitle:@"閉じる"
                                              otherButtonTitles:nil
                              ];
        [HUD hide:YES];
        [alert show];
    } else {
        [app setToken:[JSON objectForKey:@"token"]];
        app.currentUser = [User instanceFromDictionary:[JSON objectForKey:@"user"]];
        if (app.apns != nil)
            [app updateUserAPNS];
        
        [self.navigationController popViewControllerAnimated:YES];
        
        HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Checkmark.png"]];
        HUD.mode = MBProgressHUDModeCustomView;
        [HUD hide:YES afterDelay:0.3];
        
        [[NSNotificationCenter defaultCenter]
         postNotificationName:@"LoggedIn"
         object:self];
        
        [[NSNotificationCenter defaultCenter]
         postNotificationName:@"UploadedNewPicture"
         object:self];
    }
}


@end
