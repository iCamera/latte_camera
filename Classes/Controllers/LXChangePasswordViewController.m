//
//  LXChangePasswordViewController.m
//  Latte camera
//
//  Created by Bui Xuan Dung on 8/1/13.
//  Copyright (c) 2013 LUXEYS. All rights reserved.
//

#import "LXChangePasswordViewController.h"
#import "LXUtils.h"
#import "LatteAPIClient.h"
#import "MBProgressHUD.h"

@interface LXChangePasswordViewController ()

@end

@implementation LXChangePasswordViewController

@synthesize viewSub;
@synthesize textConfirmPassword;
@synthesize textCurrentPassword;
@synthesize textNewPassword;

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
    [LXUtils globalShadow:viewSub];
    viewSub.layer.cornerRadius = 5;
	// Do any additional setup after loading the view.
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(keyboardWillShow:) name: UIKeyboardWillShowNotification object:nil];
}

- (void)keyboardWillShow:(NSNotification *)notification
{
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    
    CGRect frame = self.viewSub.frame;
    frame.origin.y = (self.view.bounds.size.height - keyboardSize.height - self.viewSub.bounds.size.height) / 2;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationCurve:[[[notification userInfo] objectForKey:UIKeyboardAnimationCurveUserInfoKey] intValue]];
    [UIView setAnimationDuration:[[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue]];
    
    self.viewSub.frame = frame;
    
    [UIView commitAnimations];

}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)tapBackground:(id)sender {
    [self hide];
}

- (void)hide {
    [UIView animateWithDuration:0.3 animations:^{
        self.view.alpha = 0;
    } completion:^(BOOL finished) {
        [self.view removeFromSuperview];
        [self removeFromParentViewController];
    }];
}

- (void)viewDidUnload {
    [self setViewSub:nil];
    [self setTextCurrentPassword:nil];
    [self setTextNewPassword:nil];
    [self setTextConfirmPassword:nil];
    [super viewDidUnload];
}

- (IBAction)touchChange:(id)sender {
    if ([self validateInput]) {
        LatteAPIClient *api = [LatteAPIClient sharedClient];
        MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.view];
        [self.view addSubview:HUD];
        HUD.mode = MBProgressHUDModeIndeterminate;
        [HUD show:YES];
        NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                                textNewPassword.text, @"password",
                                textCurrentPassword.text,  @"cur_password",
                                nil];
        
        [api postPath:@"user/change_password" parameters:params success:^(AFHTTPRequestOperation *operation, NSDictionary *JSON) {
            [HUD hide:YES];
            if ([JSON[@"status"] boolValue] == true) {
                UIAlertView* alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Password", @"")
                                                                message:NSLocalizedString(@"New password saved", @"") delegate:nil
                                                      cancelButtonTitle:NSLocalizedString(@"close", @"閉じる")
                                                      otherButtonTitles:nil];
                [alert show];
                [self hide];
            } else {
                UIAlertView* alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"error", @"エラー")
                                                                message:NSLocalizedString(@"Please enter your current password again", @"") delegate:nil
                                                      cancelButtonTitle:NSLocalizedString(@"close", @"閉じる")
                                                      otherButtonTitles:nil];
                [alert show];
            }
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
}

- (BOOL)validateInput {
    NSString *error;
    if (textCurrentPassword.text.length == 0) {
        error = NSLocalizedString(@"register_error_password_require", @"パスワードを入力してください");
    } else if (textNewPassword.text.length == 0) {
        error = NSLocalizedString(@"register_error_password_require", @"パスワードを入力してください");
    } else if (textConfirmPassword.text.length == 0) {
        error = NSLocalizedString(@"register_error_password_require", @"パスワードを入力してください");
    } else if (![textConfirmPassword.text isEqualToString:textNewPassword.text]) {
        error = NSLocalizedString(@"register_error_password_require", @"パスワードを入力してください");
    }
    
    if (error != nil) {
        UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"error", @"エラー")
                                                             message:error
                                                            delegate:nil
                                                   cancelButtonTitle:NSLocalizedString(@"close", @"閉じる")
                                                   otherButtonTitles:nil];
        [errorAlert show];
        return false;
    } else {
        return true;
    }
}


@end
