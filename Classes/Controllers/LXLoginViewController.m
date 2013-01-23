//
//  luxeysLoginViewController.m
//  Latte
//
//  Created by Xuan Dung Bui on 8/7/12.
//  Copyright (c) 2012 LUXEYS. All rights reserved.
//

#import "LXLoginViewController.h"
#import "LatteAPIClient.h"
#import "LXAppDelegate.h"

@interface LXLoginViewController ()

@end

@implementation LXLoginViewController


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
    LXAppDelegate* app = (LXAppDelegate*)[UIApplication sharedApplication].delegate;
    
    self.textUser.text = [app.tokenItem objectForKey:(id)CFBridgingRelease(kSecAttrAccount)];
    self.textPass.text = [app.tokenItem objectForKey:(id)CFBridgingRelease(kSecValueData)];
    
    isPreload = true;
    isPreload2 = true;
    
    
    
    HUD = [[MBProgressHUD alloc] initWithView:self.view];
	[self.view addSubview:HUD];
    
    
    
    // Check the session for a cached token to show the proper authenticated
    // UI. However, since this is not user intitiated, do not show the login UX.
    // [app openSessionWithAllowLoginUI:NO];
}

- (void)sessionStateChanged:(NSNotification*)notification {
    if (FBSession.activeSession.isOpen) {
        TFLog(@"Open fb");
        [[LatteAPIClient sharedClient] postPath:@"user/login_facebook"
                                     parameters:[NSDictionary dictionaryWithObjectsAndKeys:
                                                 FBSession.activeSession.accessToken, @"facebook_token", nil]
                                        success:^(AFHTTPRequestOperation *operation, NSDictionary *JSON) {
                                            [self processLogin:JSON];
                                        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                            TFLog(@"Something went wrong (Facebook): %@", error.description);
                                            // Clear FBsession to be sure
                                            [FBSession.activeSession closeAndClearTokenInformation];
                                        }];
//        [self.authButton setTitle:@"Logout" forState:UIControlStateNormal];
    } else {
        [HUD hide:YES];
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
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)login:(id)sender {
    [HUD show:YES];
    LXAppDelegate* app = (LXAppDelegate*)[UIApplication sharedApplication].delegate;
    [app.tokenItem setObject:self.textUser.text forKey:(id)CFBridgingRelease(kSecAttrAccount)];
    [app.tokenItem setObject:self.textPass.text forKey:(id)CFBridgingRelease(kSecValueData)];
    
    [[LatteAPIClient sharedClient] postPath:@"user/login"
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

    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(sessionStateChanged:)
     name:FBSessionStateChangedNotification
     object:nil];
    
    LXAppDelegate* app = (LXAppDelegate*)[UIApplication sharedApplication].delegate;
    [app openSessionWithAllowLoginUI:YES];
}

- (IBAction)touchTwitter:(id)sender {
    // Create an account store object.
	ACAccountStore *accountStore = [[ACAccountStore alloc] init];
	
	// Create an account type that ensures Twitter accounts are retrieved.
    ACAccountType *accountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
	
	// Request access from the user to use their Twitter accounts.
    [accountStore requestAccessToAccountsWithType:accountType withCompletionHandler:^(BOOL granted, NSError *error) {
        if(granted) {
			// Get the list of Twitter accounts.
            NSArray *accountsArray = [accountStore accountsWithAccountType:accountType];
			
			// For the sake of brevity, we'll assume there is only one Twitter account present.
			// You would ideally ask the user which account they want to tweet from, if there is more than one Twitter account present.
			if ([accountsArray count] > 0) {
				// Grab the initial Twitter account to tweet from.
//				ACAccount *twitterAccount = [accountsArray objectAtIndex:0];
				
				TFLog(@"Got account");
			} else {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"error", @"エラー")
                                                                message:NSLocalizedString(@"error_no_twitter", @"Please add one Twitter account in Setting")
                                                               delegate:nil
                                                      cancelButtonTitle:NSLocalizedString(@"close", @"閉じる")
                                                      otherButtonTitles:nil
                                      ];
                [alert show];
            }
        }
	}];

}

- (void)processLogin:(NSDictionary *)JSON {
    LXAppDelegate* app = (LXAppDelegate*)[UIApplication sharedApplication].delegate;
    
    if ([JSON objectForKey:@"token"] == nil) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"error", @"エラー")
                                                        message:NSLocalizedString(@"error_login_fail", @"ログイン出来ませんでした。メールアドレスとパスワードを確認して下さい。")
                                                       delegate:nil
                                              cancelButtonTitle:NSLocalizedString(@"close", @"閉じる")
                                              otherButtonTitles:nil
                              ];
        [HUD hide:YES];
        [alert show];
    } else {
        [app setToken:[JSON objectForKey:@"token"]];
        [[LatteAPIClient sharedClient] getPath:@"user/me"
                                    parameters:[NSDictionary dictionaryWithObjectsAndKeys:
                                                [app getToken], @"token", nil]
                                       success:^(AFHTTPRequestOperation *operation, NSDictionary *JSON) {
                                           if ([[JSON objectForKey:@"status"] integerValue] == 1) {
                                               app.currentUser = [User instanceFromDictionary:[JSON objectForKey:@"user"]];
                                               
                                               if (app.apns != nil)
                                                   [app updateUserAPNS];
                                               
                                               [self.navigationController popViewControllerAnimated:YES];
                                               [self.navigationController dismissViewControllerAnimated:YES completion:nil];
                                               
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
                                       } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                           TFLog(@"Something went wrong (Login check 2)");
                                       }];
    }
}


@end
