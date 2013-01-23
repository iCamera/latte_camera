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
@synthesize textTitle;
@synthesize gestureTap;
@synthesize switchGPS;
@synthesize labelStatus;
@synthesize picture;
@synthesize buttonDelete;
@synthesize viewDelete;
@synthesize preview;

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
    share = [[LXShare alloc] init];
    share.controller = self;
    
    [share setCompletionDone:^{
        MBProgressHUD *HUD2 = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
        HUD2.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Checkmark.png"]];
        HUD2.mode = MBProgressHUDModeCustomView;
        [HUD2 show:YES];
        [HUD2 hide:YES afterDelay:1];
    }];
    
    self.tableView.backgroundView = nil;
    self.tableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg_sub_back.png"]];
    
//    imagePic.layer.borderColor = [[UIColor whiteColor] CGColor];
//    imagePic.layer.borderWidth = 2;
//    UIBezierPath *shadowPathPic = [UIBezierPath bezierPathWithRect:imagePic.bounds];
//    imagePic.layer.masksToBounds = NO;
//    imagePic.layer.shadowColor = [UIColor blackColor].CGColor;
//    imagePic.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
//    imagePic.layer.shadowOpacity = 0.5f;
//    imagePic.layer.shadowRadius = 1.5f;
//    imagePic.layer.shadowPath = shadowPathPic.CGPath;
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(keyboardWillShow:) name: UIKeyboardWillShowNotification object:nil];
    [nc addObserver:self selector:@selector(keyboardWillHide:) name: UIKeyboardWillHideNotification object:nil];
    
    if (picture == nil) {
        share.imageData = imageData;
        share.imagePreview = preview;
    }
}

- (void)viewWillAppear:(BOOL)animated {
    if (picture != nil) {
        [imagePic setImageWithURL:[NSURL URLWithString:picture.urlSquare]];
        textDesc.text = picture.descriptionText;
        textTitle.text = picture.title;
        imageStatus = [picture.status integerValue];
        buttonDelete.hidden = false;
        [self setStatusLabel];
    } else {
        LXAppDelegate* app = (LXAppDelegate*)[UIApplication sharedApplication].delegate;

        [imagePic setImage:preview];
        imageStatus = [app.currentUser.pictureStatus integerValue];
        [self setStatusLabel];
    }
    
    self.navigationController.navigationBarHidden = NO;
    
    [super viewWillAppear:animated];
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
            
            NSString *url = [NSString stringWithFormat:@"picture/%d/delete", [picture.pictureId integerValue]];
            NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                                    [app getToken], @"token", nil];
            
            [[LatteAPIClient sharedClient] postPath:url
                                         parameters: params
                                            success:^(AFHTTPRequestOperation *operation, NSDictionary *JSON) {
                                                [HUD hide:YES];
                                                
                                                UIViewController *parent = self.navigationController.viewControllers[self.navigationController.viewControllers.count-3];
                                                [parent performSelector:@selector(reloadView)];
                                                [self.navigationController popToViewController:parent animated:YES];
                                            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                [HUD hide:YES];
                                                TFLog(@"Something went wrong (Login)");
                                            }];
        }
    }
}

- (IBAction)touchPost:(id)sender {
    [textTitle resignFirstResponder];
    [textDesc resignFirstResponder];
    if (picture != nil) {
        [self updatePic];
    } else {
        [self saveImage];
    }
}

- (IBAction)touchBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)touchBackground:(id)sender {
    [textTitle resignFirstResponder];
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
    
    NSString *url = [NSString stringWithFormat:@"picture/%d/edit", [picture.pictureId integerValue]];
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            [app getToken], @"token",
                            textTitle.text, @"name",
                            textDesc.text, @"comment",
                            [NSNumber numberWithInteger:imageStatus], @"status", nil];
    
    [[LatteAPIClient sharedClient] postPath:url
                                 parameters: params
                                    success:^(AFHTTPRequestOperation *operation, NSDictionary *JSON) {
                                        [HUD hide:YES];
                                        
                                        LXPicDetailViewController *parent = self.navigationController.viewControllers[self.navigationController.viewControllers.count-2];
                                        [parent reloadView];
                                        
                                        [self.navigationController popViewControllerAnimated:YES];
                                        
                                        
                                    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                        [HUD hide:YES];
                                        TFLog(@"Something went wrong (Login)");
                                    }];
}

- (void)backToCamera {
    
    LXAppDelegate* app = (LXAppDelegate*)[UIApplication sharedApplication].delegate;
    UINavigationController *navCamera = (UINavigationController*)app.viewCamera;
    
    [self.navigationController popToRootViewControllerAnimated:YES];
    LXCameraViewController *cameraView = (LXCameraViewController*)navCamera.viewControllers[0];
    [cameraView switchCamera];
}

- (void)saveImage {
    MBProgressHUD* HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:HUD];
    HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Checkmark.png"]];
    HUD.mode = MBProgressHUDModeCustomView;
    [HUD show:YES];
    [HUD hide:YES afterDelay:2];
    
    
    LXAppDelegate* app = (LXAppDelegate*)[UIApplication sharedApplication].delegate;
    
    void (^createForm)(id<AFMultipartFormData>) = ^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFileData:imageData
                                    name:@"file"
                                fileName:@"latte.jpg"
                                mimeType:@"image/jpeg"];
    };
    
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            [app getToken], @"token",
                            textTitle.text, @"name",
                            textDesc.text, @"comment",
                            [NSNumber numberWithInteger:imageStatus], @"picture_status",
                            nil];
    
    NSURLRequest *request = [[LatteAPIClient sharedClient] multipartFormRequestWithMethod:@"POST"
                                                                                     path:@"picture/upload"
                                                                               parameters:params
                                                                constructingBodyWithBlock:createForm];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    void (^successUpload)(AFHTTPRequestOperation *, id) = ^(AFHTTPRequestOperation *operation, id responseObject) {
        
/*        [app toogleCamera];
        
        [[NSNotificationCenter defaultCenter]
         postNotificationName:@"UploadedNewPicture"
         object:self];*/
        
    };
    
    void (^failUpload)(AFHTTPRequestOperation *, NSError *) = ^(AFHTTPRequestOperation *operation, NSError *error) {
        if([operation.response statusCode] != 200){
            TFLog(@"Upload Failed");
            return;
        }
        TFLog(@"error: %@", [operation error]);
        HUD.mode = MBProgressHUDModeText;
        HUD.labelText = @"Error";
        HUD.margin = 10.f;
        HUD.yOffset = 150.f;
        HUD.removeFromSuperViewOnHide = YES;
        
        [HUD show:YES];
        [HUD hide:YES afterDelay:3];
    };
    
    [operation setCompletionBlockWithSuccess: successUpload failure: failUpload];
    
    [operation setUploadProgressBlock:^(NSInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite) {
        HUD.progress = (float)totalBytesWritten/(float)totalBytesExpectedToWrite;
    }];
    
    
    [operation start];
    [self performSelector:@selector(backToCamera) withObject:nil afterDelay:1];
}



- (void)uploadTwitter {
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
				ACAccount *twitterAccount = [accountsArray objectAtIndex:0];
				
				NSURL *url =
                [NSURL URLWithString:
                 @"https://upload.twitter.com/1/statuses/update_with_media.json"];
                
                //  Create a POST request for the target endpoint
                TWRequest *request =
                [[TWRequest alloc] initWithURL:url
                                    parameters:nil
                                 requestMethod:TWRequestMethodPOST];
                
                //  self.accounts is an array of all available accounts;
                //  we use the first one for simplicity
                [request setAccount:twitterAccount];
                
                //  Add the data of the image with the
                //  correct parameter name, "media[]"
                [request addMultiPartData:imageData
                                 withName:@"media[]"
                                     type:@"multipart/form-data"];
                
                // NB: Our status must be passed as part of the multipart form data
                NSString *status = textTitle.text;
                
                //  Add the data of the status as parameter "status"
                [request addMultiPartData:[status dataUsingEncoding:NSUTF8StringEncoding]
                                 withName:@"status"
                                     type:@"multipart/form-data"];
                
                //  Perform the request.
                //    Note that -[performRequestWithHandler] may be called on any thread,
                //    so you should explicitly dispatch any UI operations to the main thread
                [request performRequestWithHandler:
                 ^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
                     NSDictionary *dict = 
                     (NSDictionary *)[NSJSONSerialization 
                                      JSONObjectWithData:responseData options:0 error:nil];
                     
                     // Log the result
                     NSLog(@"%@", dict);
                     
                     dispatch_async(dispatch_get_main_queue(), ^{
                         // perform an action that updates the UI...
                     });
                 }];
			}
        }
	}];
}

- (void)setData:(NSData *)aData {
    imageData = aData;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (picture != nil) {
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

@end
