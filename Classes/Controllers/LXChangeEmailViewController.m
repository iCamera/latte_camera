//
//  LXChangePasswordViewController.m
//  Latte camera
//
//  Created by Bui Xuan Dung on 8/1/13.
//  Copyright (c) 2013 LUXEYS. All rights reserved.
//

#import "LXChangeEmailViewController.h"
#import "LXUtils.h"
#import "LatteAPIClient.h"
#import "MBProgressHUD.h"

@interface LXChangeEmailViewController ()

@end

@implementation LXChangeEmailViewController

@synthesize textMail;
@synthesize textPassword;

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
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setTextMail:nil];
    [self setTextPassword:nil];
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
                               textMail.text, @"mail",
                               textPassword.text, @"cur_password",
                               nil];
        [api POST:@"user/change_mail" parameters:params success:^(AFHTTPRequestOperation *operation, NSDictionary *JSON) {
            [HUD hide:YES];
            if ([JSON[@"status"] boolValue] == true) {
                UIAlertView* alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"register_sent_email", @"登録確認メールを送信しました。")
                                                                message:NSLocalizedString(@"register_click_the_link", @"メールに記載されたURLをクリックして、手続きを行ってください。") delegate:nil
                                                      cancelButtonTitle:NSLocalizedString(@"close", @"閉じる")
                                                      otherButtonTitles:nil];
                [alert show];
                [self.navigationController popViewControllerAnimated:YES];
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
    if (textMail.text.length == 0) {
        error = NSLocalizedString(@"register_error_email_require", @"メールアドレスを入力してください") ;
    } else if (![self NSStringIsValidEmail:textMail.text]) {
        error = NSLocalizedString(@"register_error_email_format", @"メールアドレスを正しく入力してください");
    } else if (textPassword.text.length == 0) {
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

-(BOOL) NSStringIsValidEmail:(NSString *)checkString
{
    BOOL stricterFilter = YES; // Discussion http://blog.logichigh.com/2010/09/02/validating-an-e-mail-address/
    NSString *stricterFilterString = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSString *laxString = @".+@.+\\.[A-Za-z]{2}[A-Za-z]*";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:checkString];
}
@end
