//
//  LXSocialViewController.m
//  Latte camera
//
//  Created by Bui Xuan Dung on 8/26/13.
//  Copyright (c) 2013 LUXEYS. All rights reserved.
//

#import "LXSocialViewController.h"
#import "LXAppDelegate.h"
#import <FacebookSDK/FacebookSDK.h>

@interface LXSocialViewController ()

@end

@implementation LXSocialViewController

@synthesize switchTwitter;
@synthesize swtichFacebook;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    LXAppDelegate *app = [LXAppDelegate currentDelegate];
    switchTwitter.on = app.currentUser.pictureAutoTweet;
    swtichFacebook.on = app.currentUser.pictureAutoFacebookUpload;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)toggleFacebook:(id)sender {
    if (swtichFacebook.on) {
        [FBSession openActiveSessionWithPublishPermissions:[NSArray arrayWithObject:@"publish_actions"]
                                           defaultAudience:FBSessionDefaultAudienceFriends
                                              allowLoginUI:YES
                                         completionHandler:^(FBSession *session,
                                                             FBSessionState state,
                                                             NSError *error) {
                                             switch (state) {
                                                 case FBSessionStateOpen:
                                                     if (!error) {
                                                         // We have a valid session
                                                         LXAppDelegate *app = [LXAppDelegate currentDelegate];
                                                         app.currentUser.pictureAutoFacebookUpload = swtichFacebook.on;
                                                         [self updateUserInfo:@"picture_auto_facebook_upload" value:swtichFacebook.on];
                                                     } else {
                                                         swtichFacebook.on = false;
                                                     }
                                                     break;
                                                 case FBSessionStateClosed:
                                                 case FBSessionStateClosedLoginFailed:
                                                     [FBSession.activeSession closeAndClearTokenInformation];
                                                     [FBSession renewSystemCredentials:^(ACAccountCredentialRenewResult result, NSError *error) {}];
                                                     break;
                                                 default:
                                                     break;
                                             }
                                             
                                             if (error) {
                                                 [LXUtils showFBAuthError:error];
                                                 swtichFacebook.on = false;
                                             }
                                         }];
    } else {
        LXAppDelegate *app = [LXAppDelegate currentDelegate];
        app.currentUser.pictureAutoFacebookUpload = swtichFacebook.on;
        [self updateUserInfo:@"picture_auto_facebook_upload" value:swtichFacebook.on];
    }
}

- (IBAction)toggleTwitter:(id)sender {

    
    if (switchTwitter.on) {
        ACAccountStore *account = [[ACAccountStore alloc] init];
        ACAccountType *accountType = [account accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
        
        [account requestAccessToAccountsWithType:accountType withCompletionHandler:^(BOOL granted, NSError *error) {
            if(granted) {
                NSArray *arrayOfAccounts = [account accountsWithAccountType:accountType];
                
                if ([arrayOfAccounts count] == 0) {
                    
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"error", @"")
                                                                    message:NSLocalizedString(@"error_no_twitter", @"")
                                                                   delegate:nil
                                                          cancelButtonTitle:NSLocalizedString(@"close", @"")
                                                          otherButtonTitles:nil];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [alert show];
                        switchTwitter.on = NO;
                    });
                } else {
                    LXAppDelegate *app = [LXAppDelegate currentDelegate];
                    app.currentUser.pictureAutoTweet = switchTwitter.on;
                    [self updateUserInfo:@"picture_auto_tweet" value:switchTwitter.on];
                }
            } else {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"error", @"")
                                                                message:NSLocalizedString(@"Please allow Latte camera to access Twitter in iPhone Setting", @"")
                                                               delegate:nil
                                                      cancelButtonTitle:NSLocalizedString(@"close", @"")
                                                      otherButtonTitles:nil];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [alert show];
                    switchTwitter.on = NO;
                });
                
            }
            // Handle any error state here as you wish
        }];
    } else {
        LXAppDelegate *app = [LXAppDelegate currentDelegate];
        app.currentUser.pictureAutoTweet = switchTwitter.on;
        [self updateUserInfo:@"picture_auto_tweet" value:switchTwitter.on];
    }
}

- (void)updateUserInfo:(NSString*)field value:(BOOL)value {
    LXAppDelegate *app = [LXAppDelegate currentDelegate];
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            [NSNumber numberWithBool:value], field, nil];
    
    [[LatteAPIClient sharedClient] POST:@"user/me/update"
                                 parameters: params
                                    success:^(AFHTTPRequestOperation *operation, NSDictionary *JSON) {
                                        if ([[JSON objectForKey:@"status"] integerValue] == 0) {
                                            NSString *error = @"";
                                            NSDictionary *errors = [JSON objectForKey:@"errors"];
                                            for (NSString *tmp in [JSON objectForKey:@"errors"]) {
                                                error = [error stringByAppendingFormat:@"\n%@", [errors objectForKey:tmp]];
                                            }
                                            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"エラー"
                                                                                            message:error
                                                                                           delegate:nil
                                                                                  cancelButtonTitle:@"Close"
                                                                                  otherButtonTitles:nil];
                                            [alert show];
                                        } else {
                                            app.currentUser = [User instanceFromDictionary:[JSON objectForKey:@"user"]];
                                        }
                                    } failure:nil];
}

- (void)viewDidUnload {
    [self setSwtichFacebook:nil];
    [self setSwitchTwitter:nil];
    [super viewDidUnload];
}
@end
