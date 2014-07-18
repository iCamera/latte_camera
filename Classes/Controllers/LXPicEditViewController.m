//
//  luxeysPicEditViewController.m
//  Latte
//
//  Created by Xuan Dung Bui on 2012/10/11.
//  Copyright (c) 2012年 LUXEYS. All rights reserved.
//

#import "LXPicEditViewController.h"
#import "LXAppDelegate.h"
#import "LXUploadObject.h"
#import "LXCanvasViewController.h"
#import "LXPicDumbTabViewController.h"
#import "LatteAPIv2Client.h"
#import <FacebookSDK/FacebookSDK.h>
#import "GAI.h"

@interface LXPicEditViewController ()

@property (nonatomic, strong) ACAccountStore *accountStore;
@property (nonatomic, strong) NSArray *accounts;

@end

@implementation LXPicEditViewController {
    PictureStatus imageStatus;
    PictureStatus imageGPSStatus;
    PictureStatus imageExifStatus;
    PictureStatus imageTakenAtStatus;
    PictureStatus imageShowOriginal;
    NSMutableArray *tags;
    ACAccount *accountTwitter;
}

@synthesize imagePic;
@synthesize textDesc;
@synthesize gestureTap;

@synthesize labelStatus;
@synthesize buttonDelete;
@synthesize viewDelete;
@synthesize labelTag;
@synthesize labelEXIFStatus;
@synthesize labelGPSStatus;
@synthesize labelTakenDateStatus;
@synthesize labelShowOriginalStatus;
@synthesize buttonFacebook;
@synthesize buttonTwitter;

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
    
    LXAppDelegate* app = (LXAppDelegate*)[UIApplication sharedApplication].delegate;
    
    [app.tracker set:kGAIScreenName
           value:@"Picture Edit Screen"];
    
    [app.tracker send:[[GAIDictionaryBuilder createAppView] build]];
    
        
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(keyboardWillShow:) name: UIKeyboardWillShowNotification object:nil];
    [nc addObserver:self selector:@selector(keyboardWillHide:) name: UIKeyboardWillHideNotification object:nil];
    
    textDesc.placeholder = NSLocalizedString(@"desc_placeholder", @"");
    
    if (_picture != nil) {
        [imagePic setImageWithURL:[NSURL URLWithString:_picture.urlMedium]];
        
        textDesc.text = _picture.descriptionText;
        
        imageStatus = _picture.status;
        imageGPSStatus = _picture.showGPS;
        imageExifStatus = _picture.showEXIF;
        imageTakenAtStatus = _picture.showTakenAt;
        imageShowOriginal = _picture.showLarge;
        tags = [NSMutableArray arrayWithArray:_picture.tagsOld];
        buttonDelete.hidden = false;
    } else {
        LXAppDelegate* app = (LXAppDelegate*)[UIApplication sharedApplication].delegate;
        imagePic.image = _preview;
        imageStatus = app.currentUser.pictureStatus;
        imageGPSStatus = app.currentUser.defaultShowGPS;
        imageExifStatus = app.currentUser.defaultShowEXIF;
        imageTakenAtStatus = app.currentUser.defaultShowTakenAt;
        imageShowOriginal = app.currentUser.defaultShowLarge;
        buttonFacebook.selected = app.currentUser.pictureAutoFacebookUpload;
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        buttonTwitter.selected = [defaults boolForKey:@"LatteAutoTweet"];;
        
        if (buttonTwitter.selected) {
            ACAccountStore *account = [[ACAccountStore alloc] init];
            ACAccountType *accountType = [account accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
            
            [account requestAccessToAccountsWithType:accountType options:nil completion:^(BOOL granted, NSError *error) {
                if(granted) {
                    NSArray *arrayOfAccounts = [account accountsWithAccountType:accountType];
                    
                    if ([arrayOfAccounts count] == 0) {
                        
                        dispatch_async(dispatch_get_main_queue(), ^{
                            buttonTwitter.selected = NO;
                        });
                    }
                } else {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        buttonTwitter.selected = NO;
                    });
                    
                }
                // Handle any error state here as you wish
            }];
        }
        
        tags = [[NSMutableArray alloc]init];
    }
    
    [self setStatusLabel:labelStatus status:imageStatus];
    [self setStatusLabel:labelEXIFStatus status:imageExifStatus];
    [self setStatusLabel:labelGPSStatus status:imageGPSStatus];
    [self setStatusLabel:labelTakenDateStatus status:imageTakenAtStatus];
    [self setStatusLabel:labelShowOriginalStatus status:imageShowOriginal];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    [super viewWillAppear:animated];
    labelTag.text = [tags componentsJoinedByString:@", "];
}

- (void)setStatusLabel:(UILabel*)label status:(PictureStatus)status {
    switch (status) {
        case PictureStatusPrivate:
            label.text = NSLocalizedString(@"status_private", @"非公開");
            break;
        case PictureStatusFriendsOnly:
            label.text = NSLocalizedString(@"status_friends", @"友達まで");
            break;
        case PictureStatusMember:
            label.text = NSLocalizedString(@"status_members", @"会員まで");
            break;
        case PictureStatusPublic:
            label.text = NSLocalizedString(@"status_public", @"公開");
            break;
        default:
            break;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if ((indexPath.section == 1)) {
        UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"privacy_setting", @"公開設定")
                                                           delegate:self
                                                  cancelButtonTitle:NSLocalizedString(@"cancel", @"キャンセル")
                                             destructiveButtonTitle:nil
                                                  otherButtonTitles:
                                NSLocalizedString(@"status_public", @"公開"),
                                NSLocalizedString(@"status_members", @"会員まで"),
                                NSLocalizedString(@"status_friends", @"友達まで"),
                                NSLocalizedString(@"status_private", @"非公開"), nil];
        sheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
        sheet.tag = indexPath.row;
        if (self.tabBarController != nil) {
            [sheet showFromTabBar:self.tabBarController.tabBar];
            sheet.delegate = self;
        }
        else
            [sheet showInView:self.view];
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    UILabel *label;

    
    if (actionSheet.tag < 10) {
        PictureStatus status = PictureStatusPublic;
        switch (buttonIndex) {
            case 0:
                status = PictureStatusPublic;
                break;
            case 1:
                status = PictureStatusMember;
                break;
            case 2:
                status = PictureStatusFriendsOnly;
                break;
            case 3:
                status = PictureStatusPrivate;
                break;
            default:
                return;
                break;
        }
        
        switch (actionSheet.tag) {
            case 0:
                label = labelStatus;
                imageStatus = status;
                break;
            case 1:
                label = labelTakenDateStatus;
                imageTakenAtStatus = status;
                break;
            case 2:
                label = labelEXIFStatus;
                imageExifStatus = status;
                break;
            case 3:
                label = labelGPSStatus;
                imageGPSStatus = status;
                break;
            case 4:
                label = labelShowOriginalStatus;
                imageShowOriginal = status;
                break;
            default:
                break;
        }
        
        [self setStatusLabel:label status:status];
    }
    
    if (actionSheet.tag == 10) {
        if (buttonIndex == 0) { // Remove Pic
            MBProgressHUD* HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
            [self.navigationController.view addSubview:HUD];
            HUD.mode = MBProgressHUDModeIndeterminate;
            [HUD show:YES];
            
            NSString *url = [NSString stringWithFormat:@"picture/%ld", (long)[_picture.pictureId integerValue]];
            
            [[LatteAPIv2Client sharedClient] DELETE:url
                                       parameters: nil
                                          success:^(AFHTTPRequestOperation *operation, NSDictionary *JSON) {
                                              [HUD hide:YES];
                                              [self.navigationController dismissViewControllerAnimated:YES completion:^{
                                                  if ([self.navigationController.presentingViewController respondsToSelector:@selector(reloadView)]) {
                                                      [self.navigationController.presentingViewController performSelector:@selector(reloadView)];
                                                  }
                                              }];
                                          } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                              [HUD hide:YES];
                                          }];
        }
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"Tag"]) {
        LXPicDumbTabViewController *controllerTag = segue.destinationViewController;
        controllerTag.tags = tags;
    }
}

- (IBAction)touchPost:(id)sender {
    [textDesc resignFirstResponder];
    if (_picture != nil) {
        [self updatePic];
    } else {
        [self saveImage];
    }
}

- (IBAction)touchBackground:(id)sender {
    [textDesc resignFirstResponder];
}


- (IBAction)touchDelete:(id)sender {
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"cancel", @"キャンセル")
                                         destructiveButtonTitle:NSLocalizedString(@"delete_photo", @"この写真を削除する")
                                              otherButtonTitles:nil];
    sheet.tag = 10;
    sheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
    [sheet showInView:self.navigationController.view];
}

- (IBAction)touchFacebook:(id)sender {
    if (!buttonFacebook.selected) {
        buttonFacebook.selected = true;
        LXAppDelegate* app = [LXAppDelegate currentDelegate];
        app.currentUser.pictureAutoFacebookUpload = true;
        [FBSession openActiveSessionWithPublishPermissions:[NSArray arrayWithObject:@"publish_actions"]
                                           defaultAudience:FBSessionDefaultAudienceFriends
                                              allowLoginUI:YES
                                         completionHandler:^(FBSession *session, FBSessionState state, NSError *error) {
                                             switch (state) {
                                                 case FBSessionStateOpen:
                                                     if (!error) {
                                                         // We have a valid session
                                                         FBAccessTokenData *tokenData = FBSession.activeSession.accessTokenData;
                                                         
                                                         [[LatteAPIv2Client sharedClient] POST:@"user/login_facebook"
                                                                                    parameters:@{@"access_token": tokenData.accessToken,
                                                                                                 @"connect_only": @"true"}
                                                                                       success:^(AFHTTPRequestOperation *operation, NSDictionary *JSON) {
                                                                                           
                                                                                           [[LatteAPIv2Client sharedClient] POST:@"user/me"
                                                                                                                    parameters:@{@"picture_auto_facebook_upload": [NSNumber numberWithBool:true]}
                                                                                                                       success:nil failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                                                                                           buttonFacebook.selected = false;
                                                                                                                       }];
                                                                                       } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                                                           buttonFacebook.selected = false;
                                                                                       }];
                                                         
                                                     }
                                                     break;
                                                 case FBSessionStateClosed:
                                                 case FBSessionStateClosedLoginFailed:
                                                     buttonFacebook.selected = false;
                                                     [FBSession.activeSession closeAndClearTokenInformation];
                                                     [FBSession renewSystemCredentials:^(ACAccountCredentialRenewResult result, NSError *error) {}];
                                                     break;
                                                 default:
                                                     break;
                                             }
                                             
                                             if (error) {
                                                 [LXUtils showFBAuthError:error];
                                                 buttonFacebook.selected = false;
                                             }
                                         }];
    } else {
        [[LatteAPIv2Client sharedClient] POST:@"user/me"
                                   parameters:@{@"picture_auto_facebook_upload": @""}
                                      success:nil failure:nil];
        buttonFacebook.selected = false;
        LXAppDelegate* app = [LXAppDelegate currentDelegate];
        app.currentUser.pictureAutoFacebookUpload = false;
    }
    
}

- (IBAction)touchTwitter:(id)sender {
    if (!buttonTwitter.selected) {
        BOOL twitterAvailable = [SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter];
        
        if (!twitterAvailable) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"error", @"")
                                                            message:NSLocalizedString(@"error_no_twitter", @"")
                                                           delegate:nil
                                                  cancelButtonTitle:NSLocalizedString(@"CLOSE", @"")
                                                  otherButtonTitles:nil];
            [alert show];
        } else {
            [self _obtainAccessToAccountsWithBlock:^(BOOL granted) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (granted) {
                        accountTwitter = _accounts[0];
                        buttonTwitter.selected = YES;
                        
                        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                        [defaults setBool:true forKey:@"LatteAutoTweet"];
                        [defaults synchronize];

                    } else {
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"error", @"")
                                                                        message:NSLocalizedString(@"Please allow Latte camera to access Twitter in iPhone Setting", @"")
                                                                       delegate:nil
                                                              cancelButtonTitle:NSLocalizedString(@"close", @"")
                                                              otherButtonTitles:nil];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [alert show];
                            buttonTwitter.selected = NO;
                        });
                    }
                });
            }];
        }
    } else {
        buttonTwitter.selected = false;
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setBool:false forKey:@"LatteAutoTweet"];
        [defaults synchronize];}
}

- (void)_obtainAccessToAccountsWithBlock:(void (^)(BOOL))block
{
    _accountStore = [[ACAccountStore alloc] init];
    ACAccountType *twitterType = [_accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    ACAccountStoreRequestAccessCompletionHandler handler = ^(BOOL granted, NSError *error) {
        if (granted) {
            self.accounts = [_accountStore accountsWithAccountType:twitterType];
        }
        
        block(granted);
    };
    [_accountStore requestAccessToAccountsWithType:twitterType options:NULL completion:handler];
}

- (void)keyboardWillShow:(NSNotification *)notification
{
    [self.tableView addGestureRecognizer:gestureTap];
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    [self.tableView removeGestureRecognizer:gestureTap];
}

- (void)updatePic {
    MBProgressHUD* HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:HUD];
    HUD.mode = MBProgressHUDModeIndeterminate;
    [HUD show:YES];
    
    NSString *url = [NSString stringWithFormat:@"picture/%ld", (long)[_picture.pictureId integerValue]];
    NSMutableArray *tagsPolish = [[NSMutableArray alloc] init];
    for (NSString *tag in tags)
        if (tag.length > 0)
            [tagsPolish addObject:tag];
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            textDesc.text, @"comment",
                            [NSNumber numberWithInteger:imageExifStatus], @"show_exif",
                            [NSNumber numberWithInteger:imageGPSStatus], @"show_gps",
                            [NSNumber numberWithInteger:imageTakenAtStatus], @"show_taken_at",
                            [NSNumber numberWithInteger:imageShowOriginal], @"show_large",
                            [NSNumber numberWithInteger:imageStatus], @"status",
                            [tagsPolish componentsJoinedByString:@","], @"tags",
                            nil];
    _picture.descriptionText = textDesc.text;
    _picture.status = imageStatus;
    _picture.showEXIF = imageExifStatus;
    _picture.showGPS = imageGPSStatus;
    _picture.showTakenAt = imageTakenAtStatus;
    _picture.showLarge = imageShowOriginal;
    _picture.tagsOld = tags;
    
    [[LatteAPIv2Client sharedClient] POST:url
                               parameters: params
                                  success:^(AFHTTPRequestOperation *operation, NSDictionary *JSON) {
                                      [HUD hide:YES];
                                      
                                      [self.navigationController popViewControllerAnimated:YES];
                                      
                                      
                                  } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                      [HUD hide:YES];
                                      
                                      UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"error", "Error")
                                                                                      message:error.localizedDescription
                                                                                     delegate:nil
                                                                            cancelButtonTitle:NSLocalizedString(@"close", "Close")
                                                                            otherButtonTitles:nil];
                                      [alert show];
                                  }];
}

- (void)backToCamera {
    UIViewController *tmp2 = self.navigationController.presentingViewController;
    [self.navigationController dismissViewControllerAnimated:NO completion:nil];
    
    if (tmp2 != self.navigationController) {
        [tmp2 dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)saveImage {
    LXAppDelegate* app = (LXAppDelegate*)[UIApplication sharedApplication].delegate;
    
    LXUploadObject *uploadLatte = [[LXUploadObject alloc]init];
    uploadLatte.imageFile = _imageData;
    uploadLatte.imagePreview = _preview;
    uploadLatte.imageDescription = textDesc.text;
    uploadLatte.showEXIF = imageExifStatus;
    uploadLatte.showGPS = imageGPSStatus;
    uploadLatte.showTakenAt = imageTakenAtStatus;
    uploadLatte.showLarge = imageShowOriginal;
    uploadLatte.tags = tags;
    uploadLatte.status = imageStatus;
    
    [app.uploader addObject:uploadLatte];
    [uploadLatte upload];
    
    if (buttonTwitter.selected) {
        LXUploadObject *uploader = [[LXUploadObject alloc]init];
        uploader.imageFile = _imageData;
        uploader.imagePreview = _preview;
        uploader.imageDescription = textDesc.text;
        
        [app.uploader addObject:uploader];
        [uploader uploadTwitter:accountTwitter];
    }
    
    [self backToCamera];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (_picture)
        return 2;
    else
        return 3;
}


- (void)viewDidUnload {
    [self setTextDesc:nil];
    [self setButtonFacebook:nil];
    [self setButtonTwitter:nil];
    [self setLabelGPSStatus:nil];
    [self setLabelEXIFStatus:nil];
    [self setLabelTakenDateStatus:nil];
    [self setLabelShowOriginalStatus:nil];
    [super viewDidUnload];
}
@end
