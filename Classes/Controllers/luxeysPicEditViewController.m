//
//  luxeysPicEditViewController.m
//  Latte
//
//  Created by Xuan Dung Bui on 2012/10/11.
//  Copyright (c) 2012年 LUXEYS. All rights reserved.
//

#import "luxeysPicEditViewController.h"
#import "luxeysAppDelegate.h"
#import "luxeysPicDetailViewController.h"

@interface luxeysPicEditViewController ()

@end

@implementation luxeysPicEditViewController

@synthesize imagePic;
@synthesize textDesc;
@synthesize textTitle;
@synthesize gestureTap;
@synthesize switchGPS;
@synthesize labelStatus;
@synthesize picture;
@synthesize buttonDelete;

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
    HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:HUD];
    
    self.tableView.backgroundView = nil;
    self.tableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg_sub_back.png"]];
    
    imagePic.layer.borderColor = [[UIColor whiteColor] CGColor];
    imagePic.layer.borderWidth = 2;
    UIBezierPath *shadowPathPic = [UIBezierPath bezierPathWithRect:imagePic.bounds];
    imagePic.layer.masksToBounds = NO;
    imagePic.layer.shadowColor = [UIColor blackColor].CGColor;
    imagePic.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
    imagePic.layer.shadowOpacity = 0.5f;
    imagePic.layer.shadowRadius = 1.5f;
    imagePic.layer.shadowPath = shadowPathPic.CGPath;
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(keyboardWillShow:) name: UIKeyboardWillShowNotification object:nil];
    [nc addObserver:self selector:@selector(keyboardWillHide:) name: UIKeyboardWillHideNotification object:nil];
    
    if (picture != nil) {
        [imagePic setImageWithURL:[NSURL URLWithString:picture.urlSquare]];
        textDesc.text = picture.descriptionText;
        textTitle.text = picture.title;
        imageStatus = [picture.status integerValue];
//        buttonDelete.hidden = false;
        [self setStatusLabel];
    } else {
        luxeysAppDelegate* app = (luxeysAppDelegate*)[UIApplication sharedApplication].delegate;
        
        [imagePic setImage:[UIImage imageWithData:imageData]];
        imageStatus = [app.currentUser.pictureStatus integerValue];
        [self setStatusLabel];
    }
}

- (void)setStatusLabel {
    switch (imageStatus) {
        case 0:
            labelStatus.text = @"非公開";
            break;
        case 10:
            labelStatus.text = @"友達まで";
            break;
        case 30:
            labelStatus.text = @"会員まで";
            break;
        case 40:
            labelStatus.text = @"公開";
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

- (void)viewWillAppear:(BOOL)animated {
    self.navigationController.navigationBarHidden = NO;
    [super viewWillAppear:animated];
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ((indexPath.section == 1) && (indexPath.row == 1))
    {
        UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"公開"
                                                           delegate:self
                                                  cancelButtonTitle:@"キャンセル"
                                             destructiveButtonTitle:nil
                                                  otherButtonTitles:@"非公開", @"友達まで", @"会員まで", @"公開", nil];
        sheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
        if (self.tabBarController != nil) {
            [sheet showFromTabBar:self.tabBarController.tabBar];
            sheet.delegate = self;
        }
        else
            [sheet showInView:self.view];
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
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

- (IBAction)touchLatte:(id)sender {
}

- (IBAction)switchService:(UIButton *)sender {
    sender.selected = !sender.selected;
}

- (IBAction)touchDelete:(id)sender {
    
}

- (void)keyboardWillShow:(NSNotification *)notification
{
    [self.tableView addGestureRecognizer:gestureTap];
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    [self.tableView removeGestureRecognizer:gestureTap];
}

- (void)verifyImage {
}

- (void)updatePic {
    HUD.mode = MBProgressHUDModeIndeterminate;
    [HUD show:YES];
    luxeysAppDelegate* app = (luxeysAppDelegate*)[UIApplication sharedApplication].delegate;
    
    NSString *url = [NSString stringWithFormat:@"api/picture/%d/edit", [picture.pictureId integerValue]];
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            [app getToken], @"token",
                            textTitle.text, @"name",
                            textDesc.text, @"comment",
                            [NSNumber numberWithInteger:imageStatus], @"status", nil];
    
    [[LatteAPIClient sharedClient] postPath:url
                                 parameters: params
                                    success:^(AFHTTPRequestOperation *operation, NSDictionary *JSON) {
                                        [HUD hide:YES];
                                        
                                        luxeysPicDetailViewController *parent = self.navigationController.viewControllers[self.navigationController.viewControllers.count-2];
                                        [parent reloadView];
                                        [self.navigationController popViewControllerAnimated:YES];
                                    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                        [HUD hide:YES];
                                        NSLog(@"Something went wrong (Login)");
                                    }];
}

- (void)saveImage {
    HUD.mode = MBProgressHUDModeDeterminate;
    [HUD show:YES];
    
    luxeysAppDelegate* app = (luxeysAppDelegate*)[UIApplication sharedApplication].delegate;
    
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
                                                                                     path:@"api/picture/upload"
                                                                               parameters:params
                                                                constructingBodyWithBlock:createForm];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    void (^successUpload)(AFHTTPRequestOperation *, id) = ^(AFHTTPRequestOperation *operation, id responseObject) {
        HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Checkmark.png"]];
        HUD.mode = MBProgressHUDModeCustomView;
        [HUD hide:YES afterDelay:2];
        
        [self.navigationController popToRootViewControllerAnimated:YES];
    };
    
    void (^failUpload)(AFHTTPRequestOperation *, NSError *) = ^(AFHTTPRequestOperation *operation, NSError *error) {
        if([operation.response statusCode] != 200){
            NSLog(@"Upload Failed");
            return;
        }
        NSLog(@"error: %@", [operation error]);
        HUD.mode = MBProgressHUDModeText;
        HUD.labelText = @"Error";
        HUD.margin = 10.f;
        HUD.yOffset = 150.f;
        HUD.removeFromSuperViewOnHide = YES;
        
        [HUD hide:YES afterDelay:3];
    };
    
    [operation setCompletionBlockWithSuccess: successUpload failure: failUpload];
    
    [operation setUploadProgressBlock:^(NSInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite) {
        HUD.progress = (float)totalBytesWritten/(float)totalBytesExpectedToWrite;
    }];
    
    
    [operation start];
}

- (void)setData:(NSData *)aData {
    imageData = aData;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

@end
