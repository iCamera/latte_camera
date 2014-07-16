//
//  LXSettingRootViewController.m
//  Latte camera
//
//  Created by Bui Xuan Dung on 3/2/13.
//  Copyright (c) 2013 LUXEYS. All rights reserved.
//

#import "LXSettingRootViewController.h"
#import "LXAppDelegate.h"
#import "LatteAPIv2Client.h"
#import "LXUtils.h"
#import "LXShare.h"
#import "UIButton+AFNetworking.h"
#import "UIImageView+AFNetworking.h"

@interface LXSettingRootViewController ()

@end

@implementation LXSettingRootViewController {
    LXShare *lxShare;
    NSInteger photoMode;
}

@synthesize labelVersion;
@synthesize viewWrapHeader;

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
    labelVersion.text = [[NSBundle mainBundle] objectForInfoDictionaryKey: @"CFBundleShortVersionString"];
    
    LXAppDelegate *app = [LXAppDelegate currentDelegate];
    
    [app.tracker set:kGAIScreenName
               value:@"Setting Screen"];
    
    [app.tracker send:[[GAIDictionaryBuilder createAppView] build]];
    
    lxShare = [[LXShare alloc] init];
    lxShare.controller = self;
    
    _buttonProfilePicture.layer.cornerRadius = 25;
    
    if (app.currentUser) {
        [self reloadInfo];
    } else {
        self.tableView.tableHeaderView = nil;
    }
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults objectForKey:@"LatteCameraStartUp"]) {
        _switchCamera.on = [defaults boolForKey:@"LatteCameraStartUp"];
    }
    
    if ([defaults objectForKey:@"LatteSaveToAlbum"]) {
        _switchSave.on = [defaults boolForKey:@"LatteSaveToAlbum"];
    } else {
        _switchSave.on = YES;
    }
    
    if ([defaults objectForKey:@"LatteSaveOrigin"]) {
        _switchOrigin.on = [defaults boolForKey:@"LatteSaveOrigin"];
    } else {
        _switchOrigin.on = YES;
    }
}

- (void)reloadInfo {
    [[LatteAPIv2Client sharedClient] GET:@"user/me"
                              parameters: nil
                                 success:^(AFHTTPRequestOperation *operation, NSDictionary *JSON) {
                                     [_buttonProfilePicture setBackgroundImageForState:UIControlStateNormal withURL:[NSURL URLWithString:JSON[@"profile_picture"]]];
                                     [_imageCover setImageWithURL:[NSURL URLWithString:JSON[@"cover_picture"]]];
                                     _labelLike.text = [JSON[@"vote_count"] stringValue];
                                     _labelPV.text = [JSON[@"page_views"] stringValue];
                                     
                                 } failure:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    LXAppDelegate* app = [LXAppDelegate currentDelegate];
    if (app.currentUser == nil) {
        if (indexPath.section == 0) {
            switch (indexPath.row) {
                case 0:
                case 1:
                case 2:
                case 3:
                case 4:
                    return;
                    break;
                default:
                    break;
            }
        }
    }
    
    
    if (indexPath.section == 3) {
        [lxShare inviteFriend];
    }
    
    if (indexPath.section == 5) {
        LXAppDelegate* app = (LXAppDelegate*)[UIApplication sharedApplication].delegate;
        
        [[FBSession activeSession] closeAndClearTokenInformation];
        
        [[LatteAPIClient sharedClient] POST:@"user/logout" parameters:nil success:nil failure:nil];
        [app setToken:@""];
        app.currentUser = nil;
        [self dismissViewControllerAnimated:YES completion:nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"LoggedOut" object:self];
    }
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    LXAppDelegate* app = [LXAppDelegate currentDelegate];
    if (app.currentUser == nil)
        return 4;
    else
        return 5;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    LXAppDelegate* app = [LXAppDelegate currentDelegate];
    if (app.currentUser == nil) {
        if (indexPath.section == 0) {
            switch (indexPath.row) {
                case 0:
                case 1:
                case 2:
                case 3:
                case 4:
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    for (UIView *view in cell.subviews)
                        view.alpha = 0.5;
                default:
                    break;
            }
        }
    }
}

- (void)viewDidUnload {
    [self setViewWrapHeader:nil];
    [super viewDidUnload];
}

- (IBAction)touchSetPicture:(id)sender {
    photoMode = 1;
    UIActionSheet *actionUpload = [[UIActionSheet alloc] initWithTitle:@""
                                                              delegate:self
                                                     cancelButtonTitle:NSLocalizedString(@"Cancel", @"")
                                                destructiveButtonTitle:NSLocalizedString(@"remove_profile_pic", @"削除する")
                                                     otherButtonTitles:NSLocalizedString(@"Camera", @""), NSLocalizedString(@"Photo Library", @""), nil];
    
    [actionUpload showInView:self.view];
}

- (IBAction)touchSetCover:(id)sender {
    photoMode = 2;
    UIActionSheet *actionUpload = [[UIActionSheet alloc] initWithTitle:@""
                                                              delegate:self
                                                     cancelButtonTitle:NSLocalizedString(@"Cancel", @"")
                                                destructiveButtonTitle:NSLocalizedString(@"remove_profile_pic", @"削除する")
                                                     otherButtonTitles:NSLocalizedString(@"Camera", @""), NSLocalizedString(@"Photo Library", @""), nil];
    
    [actionUpload showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        if (photoMode == 1) {
            [_buttonProfilePicture setBackgroundImage:[UIImage imageNamed:@"user.gif"] forState:UIControlStateNormal];
            [[LatteAPIv2Client sharedClient] DELETE:@"user/me/profile_picture" parameters:nil success:^(AFHTTPRequestOperation *operation, NSDictionary *JSON) {
                [self reloadInfo];
            } failure:nil];
        }
        
        if (photoMode == 2) {
            [_imageCover setImage:[UIImage imageNamed:@"default-cover.gif"]];
            [[LatteAPIv2Client sharedClient] DELETE:@"user/me/cover_picture" parameters:nil success:^(AFHTTPRequestOperation *operation, NSDictionary *JSON) {
                [self reloadInfo];
            } failure:nil];
        }

    } else if (buttonIndex == 1) {
        
        if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            
            UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                  message:@"Device has no camera"
                                                                 delegate:nil
                                                        cancelButtonTitle:@"OK"
                                                        otherButtonTitles: nil];
            
            [myAlertView show];
            
        } else {
            UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
            
            imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
            imagePicker.delegate = self;
            
            [self presentViewController:imagePicker animated:YES completion:nil];
        }
    } else if (buttonIndex == 2) {
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
        
        imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        imagePicker.delegate = self;
        
        [self presentViewController:imagePicker animated:YES completion:nil];
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [picker dismissViewControllerAnimated:NO completion:nil];
    
    void (^createForm)(id<AFMultipartFormData>) = ^(id<AFMultipartFormData> formData) {
        NSData *imageData = UIImageJPEGRepresentation(info[UIImagePickerControllerOriginalImage], 1);
        [formData appendPartWithFileData:imageData
                                    name:@"file"
                                fileName:@"latte.jpg"
                                mimeType:@"image/jpeg"];
    };
    
    LatteAPIv2Client *api2 = [LatteAPIv2Client sharedClient];
    
    if (photoMode == 1) {
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        
        [api2 POST:@"user/me/profile_picture" parameters:nil constructingBodyWithBlock:createForm success:^(AFHTTPRequestOperation *operation, NSDictionary *JSON) {
            [_buttonProfilePicture setBackgroundImageForState:UIControlStateNormal withURL:[NSURL URLWithString:JSON[@"profile_picture"]]];
            LXAppDelegate *app = [LXAppDelegate currentDelegate];
            app.currentUser.profilePicture = JSON[@"profile_picture"];
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        }];

    }
    
    if (photoMode == 2) {
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        
        [api2 POST:@"user/me/cover_picture" parameters:nil constructingBodyWithBlock:createForm success:^(AFHTTPRequestOperation *operation, NSDictionary *JSON) {
            [_imageCover setImageWithURL:[NSURL URLWithString:JSON[@"cover_picture"]]];
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        }];
        
    }

}

- (IBAction)changeOrigin:(id)sender {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:_switchOrigin.on forKey:@"LatteSaveOrigin"];
    [defaults synchronize];
}

- (IBAction)changeCamera:(id)sender {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:_switchCamera.on forKey:@"LatteCameraStartUp"];
    [defaults synchronize];
}

- (IBAction)changeSave:(id)sender {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:_switchSave.on forKey:@"LatteSaveToAlbum"];
    [defaults synchronize];
}


- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}
@end
