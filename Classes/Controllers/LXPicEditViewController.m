//
//  luxeysPicEditViewController.m
//  Latte
//
//  Created by Xuan Dung Bui on 2012/10/11.
//  Copyright (c) 2012年 LUXEYS. All rights reserved.
//

#import "LXPicEditViewController.h"
#import "LXAppDelegate.h"
#import "LXPicDetailViewController.h"

@interface LXPicEditViewController ()

@end

@implementation LXPicEditViewController

@synthesize imagePic;
@synthesize textDesc;
@synthesize gestureTap;
@synthesize switchGPS;
@synthesize labelStatus;
@synthesize buttonDelete;
@synthesize viewDelete;

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
    
    if (_picture != nil) {
        [imagePic setImageWithURL:[NSURL URLWithString:_picture.urlSquare]];
        textDesc.text = _picture.descriptionText;
        imageStatus = [_picture.status integerValue];
        buttonDelete.hidden = false;
    } else {
        share.imageData = _imageData;
        share.imagePreview = _preview;
        
        LXAppDelegate* app = (LXAppDelegate*)[UIApplication sharedApplication].delegate;
        imagePic.image = _preview;
        imageStatus = [app.currentUser.pictureStatus integerValue];
    }
    [self setStatusLabel];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    [super viewWillDisappear:animated];
}

- (void)setStatusLabel {
    switch (imageStatus) {
        case 0:
            labelStatus.text = NSLocalizedString(@"status_private", @"非公開");
            break;
        case 10:
            labelStatus.text = NSLocalizedString(@"status_friends", @"友達まで");
            break;
        case 30:
            labelStatus.text = NSLocalizedString(@"status_members", @"会員まで");
            break;
        case 40:
            labelStatus.text = NSLocalizedString(@"status_public", @"公開");
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
    if ((indexPath.section == 1) && (indexPath.row == 1))
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
        sheet.tag = 0;
        if (self.tabBarController != nil) {
            [sheet showFromTabBar:self.tabBarController.tabBar];
            sheet.delegate = self;
        }
        else
            [sheet showInView:self.view];
    } else if (indexPath.section == 2) {
        switch (indexPath.row) {
            case 0:
                [share facebookPost];
                break;
            case 1:
                [share tweet];
                break;
            case 2:
                [share emailIt];
                break;
            default:
                break;
        }
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {    
    if (actionSheet.tag == 0) {
        switch (buttonIndex) {
            case 0:
                imageStatus = 0;
                break;
            case 1:
                imageStatus = 10;
                break;
            case 2:
                imageStatus = 30;
                break;
            case 3:
                imageStatus = 40;
                break;
            default:
                break;
        }
        [self setStatusLabel];
    } else {
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
                                                [self.navigationController popViewControllerAnimated:YES];
                                            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                [HUD hide:YES];
                                                TFLog(@"Something went wrong (Login)");
                                            }];
        }
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

- (IBAction)touchBack:(id)sender {
    _imageData = nil;
    _preview = nil;
    _picture = nil;
    [self.navigationController popViewControllerAnimated:YES];
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
    sheet.tag = 1;
    sheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
    [sheet showFromTabBar:self.tabBarController.tabBar];
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
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            [app getToken], @"token",
                            textDesc.text, @"comment",
                            [NSNumber numberWithInteger:imageStatus], @"status", nil];
    
    [[LatteAPIClient sharedClient] postPath:url
                                 parameters: params
                                    success:^(AFHTTPRequestOperation *operation, NSDictionary *JSON) {
                                        [HUD hide:YES];
                                        
                                        _picture.descriptionText = textDesc.text;
                                        _picture.status = [NSNumber numberWithInteger:imageStatus];
                                        
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
//    LXAppDelegate* app = (LXAppDelegate*)[UIApplication sharedApplication].delegate;
//    UINavigationController *navCamera = (UINavigationController*)app.viewCamera;
//    
//    [self.navigationController popToRootViewControllerAnimated:YES];
//    LXCameraViewController *cameraView = (LXCameraViewController*)navCamera.viewControllers[0];
//    [cameraView switchCamera];
}

- (void)saveImage {
    MBProgressHUD* HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:HUD];
    HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Checkmark.png"]];
    HUD.mode = MBProgressHUDModeCustomView;
    [HUD show:YES];
    [HUD hide:YES afterDelay:1];
    
    LXAppDelegate* app = (LXAppDelegate*)[UIApplication sharedApplication].delegate;
    
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            [app getToken], @"token",
                            textDesc.text, @"comment",
                            [NSNumber numberWithInteger:imageStatus], @"picture_status",
                            nil];
    
    
//    UINavigationController *navCamera = (UINavigationController*)app.viewCamera;
//    LXCameraViewController *cameraView = (LXCameraViewController*)navCamera.viewControllers[0];
//    cameraView.dictUpload = params;
//    [cameraView uploadData];
    
    [self performSelector:@selector(backToCamera) withObject:nil];
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
    title.font = [UIFont fontWithName:@"AvenirNextCondensed-Regular" size:16];
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
    [super viewDidUnload];
}
@end
