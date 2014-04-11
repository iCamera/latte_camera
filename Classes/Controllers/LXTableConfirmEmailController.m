//
//  LXTableConfirmEmailController.m
//  Latte camera
//
//  Created by Bui Xuan Dung on 8/1/13.
//  Copyright (c) 2013 LUXEYS. All rights reserved.
//

#import "LXTableConfirmEmailController.h"
#import "LXAppDelegate.h"

@interface LXTableConfirmEmailController ()

@end

@implementation LXTableConfirmEmailController

@synthesize labelEmail;

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
    
    LXAppDelegate *app = [LXAppDelegate currentDelegate];
    labelEmail.text = app.currentUser.mail;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1) {
        UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Setting"
                                                                 bundle:nil];
        UIViewController *viewChangePassword = [mainStoryboard instantiateViewControllerWithIdentifier:@"ChangeEmail"];
        viewChangePassword.view.alpha = 0;
        viewChangePassword.view.frame = self.view.bounds;
        [self.view addSubview:viewChangePassword.view];
        [self addChildViewController:viewChangePassword];
        [viewChangePassword didMoveToParentViewController:self];
        [UIView animateWithDuration:0.3 animations:^{
            viewChangePassword.view.alpha = 1;
        }];
    }
}

- (IBAction)touchClose:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)touchHelp:(id)sender {
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Setting"
                                                             bundle:nil];
    UIViewController *viewConfirm = [mainStoryboard instantiateViewControllerWithIdentifier:@"WebFAQ"];
    [self.navigationController pushViewController:viewConfirm animated:YES];
    
}

- (IBAction)touchResend:(id)sender {
    LatteAPIClient *api = [LatteAPIClient sharedClient];
    MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:HUD];
    HUD.mode = MBProgressHUDModeIndeterminate;
    [HUD show:YES];
    
    [api POST:@"user/resend_confirm" parameters:nil success:^(AFHTTPRequestOperation *operation, NSDictionary *JSON) {
        [HUD hide:YES];
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"register_sent_email", @"登録確認メールを送信しました。")
                                                        message:NSLocalizedString(@"register_click_the_link", @"メールに記載されたURLをクリックして、手続きを行ってください。") delegate:nil
                                              cancelButtonTitle:NSLocalizedString(@"close", @"閉じる")
                                              otherButtonTitles:nil];
        [alert show];
        [self dismissViewControllerAnimated:YES completion:nil];
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

- (void)viewDidUnload {
    [self setLabelEmail:nil];
    [super viewDidUnload];
}
@end
