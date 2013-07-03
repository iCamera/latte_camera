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
#import <FacebookSDK/FacebookSDK.h>

@interface LXPicEditViewController ()

@end

@implementation LXPicEditViewController {
    PictureStatus imageStatus;
    PictureStatus imageGPSStatus;
    PictureStatus imageExifStatus;
    PictureStatus imageTakenAtStatus;
    LXShare *share;
    NSMutableArray *tags;
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
    [app.tracker sendView:@"Picture Edit Screen"];
    
    share = [[LXShare alloc] init];
    share.controller = self;
    
    
    [share setCompletionDone:^{
        MBProgressHUD *HUD2 = [[MBProgressHUD alloc] init];
        HUD2.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Checkmark.png"]];
        HUD2.mode = MBProgressHUDModeCustomView;
        [HUD2 show:YES];
        [HUD2 hide:YES afterDelay:1];
    }];
    
    self.tableView.backgroundView = nil;
    self.tableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg_sub_back.png"]];
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(keyboardWillShow:) name: UIKeyboardWillShowNotification object:nil];
    [nc addObserver:self selector:@selector(keyboardWillHide:) name: UIKeyboardWillHideNotification object:nil];
    
    imagePic.layer.cornerRadius = 7;
    imagePic.layer.masksToBounds = YES;
    
    textDesc.placeholder = NSLocalizedString(@"desc_placeholder", @"");
    
    if (_picture != nil) {
        [imagePic setImageWithURL:[NSURL URLWithString:_picture.urlMedium]];
        
        textDesc.text = _picture.descriptionText;
        
        imageStatus = _picture.status;
        imageGPSStatus = _picture.showGPS;
        imageExifStatus = _picture.showEXIF;
        imageTakenAtStatus = _picture.showTakenAt;
        tags = [NSMutableArray arrayWithArray:_picture.tagsOld];
        buttonDelete.hidden = false;
    } else {
        share.imageData = _imageData;
        share.imagePreview = _preview;
        
        LXAppDelegate* app = (LXAppDelegate*)[UIApplication sharedApplication].delegate;
        imagePic.image = _preview;
        imageStatus = app.currentUser.pictureStatus;
        imageGPSStatus = app.currentUser.defaultShowGPS;
        imageExifStatus = app.currentUser.defaultShowEXIF;
        imageTakenAtStatus = app.currentUser.defaultShowTakenAt;
        buttonFacebook.selected = app.currentUser.pictureAutoFacebookUpload;
        buttonTwitter.selected = app.currentUser.pictureAutoTweet;
        
        tags = [[NSMutableArray alloc]init];
    }
    
    [self setStatusLabel:labelStatus status:imageStatus];
    [self setStatusLabel:labelEXIFStatus status:imageExifStatus];
    [self setStatusLabel:labelGPSStatus status:imageGPSStatus];
    [self setStatusLabel:labelTakenDateStatus status:imageTakenAtStatus];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    [super viewWillAppear:animated];
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
    if ((indexPath.section == 1) && (indexPath.row > 1))
    {
        UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"privacy_setting", @"公開設定")
                                                           delegate:self
                                                  cancelButtonTitle:NSLocalizedString(@"cancel", @"キャンセル")
                                             destructiveButtonTitle:nil
                                                  otherButtonTitles:
                                NSLocalizedString(@"status_private", @"非公開"),
                                NSLocalizedString(@"status_friends", @"友達まで"),
                                NSLocalizedString(@"status_members", @"会員まで"),
                                NSLocalizedString(@"status_public", @"公開"), nil];
        sheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
        sheet.tag = indexPath.row;
        if (self.tabBarController != nil) {
            [sheet showFromTabBar:self.tabBarController.tabBar];
            sheet.delegate = self;
        }
        else
            [sheet showInView:self.view];
    } else if (indexPath.section == 2) {
        share.text = textDesc.text;
        switch (indexPath.row) {
            case 1:
                [share emailIt];
                break;
            default:
                break;
        }
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    UILabel *label;

    
    if (actionSheet.tag > 1 && actionSheet.tag < 10) {
        PictureStatus status = PictureStatusPublic;
        switch (buttonIndex) {
            case 0:
                status = PictureStatusPrivate;
                break;
            case 1:
                status = PictureStatusFriendsOnly;
                break;
            case 2:
                status = PictureStatusMember;
                break;
            case 3:
                status = PictureStatusPublic;
                break;
            default:
                break;
        }
        
        switch (actionSheet.tag) {
            case 2:
                label = labelStatus;
                imageStatus = status;
                break;
            case 3:
                label = labelEXIFStatus;
                imageExifStatus = status;
                break;
            case 4:
                label = labelGPSStatus;
                imageGPSStatus = status;
                break;
            case 5:
                label = labelTakenDateStatus;
                imageTakenAtStatus = status;
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
            LXAppDelegate* app = (LXAppDelegate*)[UIApplication sharedApplication].delegate;
            
            NSString *url = [NSString stringWithFormat:@"picture/%d/delete", [_picture.pictureId integerValue]];
            NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                                    [app getToken], @"token", nil];
            
            [[LatteAPIClient sharedClient] postPath:url
                                         parameters: params
                                            success:^(AFHTTPRequestOperation *operation, NSDictionary *JSON) {
                                                [HUD hide:YES];
                                                [self.navigationController dismissViewControllerAnimated:YES completion:^{
                                                    if ([self.navigationController.parentViewController respondsToSelector:@selector(reloadView)]) {
                                                        [self.navigationController.parentViewController performSelector:@selector(reloadView)];
                                                    }
                                                }];
                                            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                [HUD hide:YES];
                                                DLog(@"Something went wrong (Login)");
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
                                                         buttonFacebook.selected = true;
                                                         LXAppDelegate *app = [LXAppDelegate currentDelegate];
                                                         app.currentUser.pictureAutoFacebookUpload = buttonFacebook.selected;
                                                         [self updateUserInfo:@"picture_auto_facebook_upload" value:buttonFacebook.selected];
                                                     } else {
                                                         
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
                                             }
                                         }];
    } else {
        buttonFacebook.selected = false;
        LXAppDelegate *app = [LXAppDelegate currentDelegate];
        app.currentUser.pictureAutoFacebookUpload = buttonFacebook.selected;
        [self updateUserInfo:@"picture_auto_facebook_upload" value:buttonFacebook.selected];
    }
}

- (void)updateUserInfo:(NSString*)field value:(BOOL)value {
    LXAppDelegate *app = [LXAppDelegate currentDelegate];
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            [app getToken], @"token",
                            [NSNumber numberWithBool:value], field, nil];

    [[LatteAPIClient sharedClient] postPath:@"user/me/update"
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

- (IBAction)touchTwitter:(id)sender {
    buttonTwitter.selected = !buttonTwitter.selected;
    LXAppDelegate *app = [LXAppDelegate currentDelegate];
    app.currentUser.pictureAutoTweet = buttonTwitter.selected;
    [self updateUserInfo:@"picture_auto_tweet" value:buttonTwitter.selected];
    
    if (buttonTwitter.selected) {
        ACAccountStore *account = [[ACAccountStore alloc] init];
        ACAccountType *accountType = [account accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
        
        [account requestAccessToAccountsWithType:accountType withCompletionHandler:^(BOOL granted, NSError *error) {
            if(granted) {
                NSArray *arrayOfAccounts = [account accountsWithAccountType:accountType];
                
                if ([arrayOfAccounts count] == 0) {
                    buttonTwitter.selected = NO;
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"error", @"")
                                                                    message:NSLocalizedString(@"error_no_twitter", @"")
                                                                   delegate:nil
                                                          cancelButtonTitle:NSLocalizedString(@"close", @"")
                                                          otherButtonTitles:nil];
                    [alert performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:YES];
                }
            } else {
                buttonTwitter.selected = NO;
                
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"error", @"")
                                                                message:NSLocalizedString(@"Please allow Latte camera to access Twitter in iPhone Setting", @"")
                                                               delegate:nil
                                                      cancelButtonTitle:NSLocalizedString(@"close", @"")
                                                      otherButtonTitles:nil];
                [alert performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:YES];
            }
            // Handle any error state here as you wish
        }];
    }
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
    LXAppDelegate* app = (LXAppDelegate*)[UIApplication sharedApplication].delegate;
    
    NSString *url = [NSString stringWithFormat:@"picture/%d/edit", [_picture.pictureId integerValue]];
    NSMutableArray *tagsPolish = [[NSMutableArray alloc] init];
    for (NSString *tag in tags)
        if (tag.length > 0)
            [tagsPolish addObject:tag];
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            [app getToken], @"token",
                            textDesc.text, @"comment",
                            [NSNumber numberWithInteger:imageExifStatus], @"show_exif",
                            [NSNumber numberWithInteger:imageGPSStatus], @"show_gps",
                            [NSNumber numberWithInteger:imageTakenAtStatus], @"show_taken_at",
                            [NSNumber numberWithInteger:imageStatus], @"status",
                            [tagsPolish componentsJoinedByString:@","], @"tags",
                            nil];
    _picture.descriptionText = textDesc.text;
    _picture.status = imageStatus;
    _picture.showEXIF = imageExifStatus;
    _picture.showGPS = imageGPSStatus;
    _picture.showTakenAt = imageTakenAtStatus;
    _picture.tagsOld = tags;
    
    [[LatteAPIClient sharedClient] postPath:url
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
    [self.navigationController dismissModalViewControllerAnimated:NO];
    
    if (tmp2 != self.navigationController) {
        [tmp2 dismissModalViewControllerAnimated:YES];
    }
}

- (void)saveImage {
    if (buttonFacebook.selected) {
        [FBSession openActiveSessionWithPublishPermissions:[NSArray arrayWithObject:@"publish_actions"]
                                           defaultAudience:FBSessionDefaultAudienceFriends
                                              allowLoginUI:YES
                                         completionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
                                             if (error) {
                                                 [LXUtils showFBAuthError:error];
                                             }
                                         }];
    }
    
    MBProgressHUD* HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:HUD];
    HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Checkmark.png"]];
    HUD.mode = MBProgressHUDModeCustomView;
    [HUD show:YES];
    [HUD hide:YES afterDelay:1];
    
    LXAppDelegate* app = (LXAppDelegate*)[UIApplication sharedApplication].delegate;
    
    LXUploadObject *uploadLatte = [[LXUploadObject alloc]init];
    uploadLatte.facebook = buttonFacebook.selected;
    uploadLatte.imageFile = _imageData;
    uploadLatte.imagePreview = _preview;
    uploadLatte.imageDescription = textDesc.text;
    uploadLatte.showEXIF = imageExifStatus;
    uploadLatte.showGPS = imageGPSStatus;
    uploadLatte.showTakenAt = imageTakenAtStatus;
    uploadLatte.tags = tags;
    uploadLatte.status = imageStatus;
    
    [app.uploader addObject:uploadLatte];
    [uploadLatte upload];
    
    
    if (buttonTwitter.selected) {
        LXUploadObject *uploadFacebook = [[LXUploadObject alloc]init];
        uploadFacebook.imageFile = _imageData;
        uploadFacebook.imagePreview = _preview;
        uploadFacebook.imageDescription = textDesc.text;
        
        [app.uploader addObject:uploadFacebook];
        [uploadFacebook uploadTwitter];
    }
    
    [self backToCamera];
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (_picture != nil) {
        return 2;
    } else {
        return 3;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 30)];
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 300, 30)];
    title.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:16];
    title.textColor = [UIColor colorWithRed:101.0/255.0 green:90.0/255.0 blue:56.0/255.0 alpha:1];
    title.text = [self tableView:tableView titleForHeaderInSection:section];
    [view addSubview:title];
    title.backgroundColor = [UIColor clearColor];
    view.backgroundColor = [UIColor clearColor];
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    NSString *title = [self tableView:tableView titleForHeaderInSection:section];
    if (title.length > 0)
        return 30;
    else
        return 0;

}

- (void)viewDidUnload {
    [self setTextDesc:nil];
    [self setButtonFacebook:nil];
    [self setButtonTwitter:nil];
    [self setLabelGPSStatus:nil];
    [self setLabelEXIFStatus:nil];
    [self setLabelTakenDateStatus:nil];
    [super viewDidUnload];
}
@end
