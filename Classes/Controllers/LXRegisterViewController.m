//
//  luxeysRegisterViewController.m
//  Latte
//
//  Created by Xuan Dung Bui on 2012/11/07.
//  Copyright (c) 2012年 LUXEYS. All rights reserved.
//

#import "LXRegisterViewController.h"

@interface LXRegisterViewController ()

@end

@implementation LXRegisterViewController

@synthesize textMail;
@synthesize textName;
@synthesize textPassword;
@synthesize viewText1;
@synthesize viewText2;
@synthesize scrollView;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    LXAppDelegate* app = (LXAppDelegate*)[UIApplication sharedApplication].delegate;
    [app.tracker sendView:@"Register Screen"];
    
    HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:HUD];
    HUD.mode = MBProgressHUDModeIndeterminate;
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg_sub_back.png"]];
    
    viewText1.layer.cornerRadius = 5;
    viewText2.layer.cornerRadius = 5;
    [LXUtils globalShadow:viewText1];
    [LXUtils globalShadow:viewText2];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(keyboardWillShow:) name: UIKeyboardWillShowNotification object:nil];
    [nc addObserver:self selector:@selector(keyboardWillHide:) name: UIKeyboardWillHideNotification object:nil];
    scrollView.contentSize = CGSizeMake(320, 367);
}

- (void)keyboardWillShow:(NSNotification *)notification
{
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationCurve:[[[notification userInfo] objectForKey:UIKeyboardAnimationCurveUserInfoKey] intValue]];
    [UIView setAnimationDuration:[[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue]];
    
    scrollView.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, keyboardSize.height-50, 0);
    scrollView.contentInset = UIEdgeInsetsMake(0, 0, keyboardSize.height-50, 0);
    
    
    [UIView commitAnimations];
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationCurve:[[[notification userInfo] objectForKey:UIKeyboardAnimationCurveUserInfoKey] intValue]];
    [UIView setAnimationDuration:[[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue]];
    
    scrollView.scrollIndicatorInsets = UIEdgeInsetsZero;
    scrollView.contentInset = UIEdgeInsetsZero;
    
    [UIView commitAnimations];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)touchReg:(id)sender {
    [textName resignFirstResponder];
    [textMail resignFirstResponder];
    [textPassword resignFirstResponder];
    
    if ([self validateInput]) {
        [HUD show:YES];
        NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                                textMail.text, @"mail",
                                textName.text, @"name",
                                textPassword.text, @"password",
                                textPassword.text, @"password_conf",
                                nil];
        
        void (^successBlock)(AFHTTPRequestOperation *, NSDictionary *) = ^(AFHTTPRequestOperation *operation, NSDictionary *JSON) {
            [HUD hide:YES];
            
            LXAppDelegate *app = [LXAppDelegate currentDelegate];
            [app setToken:[JSON objectForKey:@"token"]];
            app.currentUser = [User instanceFromDictionary:[JSON objectForKey:@"user"]];
                        
            UIStoryboard *storyAuth = [UIStoryboard storyboardWithName:@"Authentication"
                                                                bundle:nil];
            UIViewController *viewConfirm = [storyAuth instantiateViewControllerWithIdentifier:@"ConfirmPopup"];
            viewConfirm.view.alpha = 0;
            viewConfirm.view.frame = app.viewMainTab.view.bounds;
            [app.viewMainTab.view addSubview:viewConfirm.view];
            [app.viewMainTab addChildViewController:viewConfirm];
            [viewConfirm didMoveToParentViewController:app.viewMainTab];
            [UIView animateWithDuration:0.3 animations:^{
                viewConfirm.view.alpha = 1;
            }];
        };
        
        void (^failureBlock)(AFHTTPRequestOperation *, NSError *) = ^(AFHTTPRequestOperation *operation, NSError *error) {
            [HUD hide:NO];
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"error", "Error")
                                                            message:error.localizedDescription
                                                           delegate:nil
                                                  cancelButtonTitle:NSLocalizedString(@"close", "Close")
                                                  otherButtonTitles:nil];
            [alert show];
        };
        
        [[LatteAPIClient sharedClient] postPath:@"user/register2"
                                     parameters:params
                                        success:successBlock
                                        failure:failureBlock];
    }
}

- (IBAction)touchPolicy:(id)sender {
    NSString * language = [[NSLocale preferredLanguages] objectAtIndex:0];
    if ([language isEqualToString:@"ja"])
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://latte.la/company/policy"]];
    else
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://en.latte.la/company/policy"]];

}

- (IBAction)tapBackground:(id)sender {
    [self.view endEditing:YES];
}

- (BOOL)validateInput {
    NSString *error;
    if (textMail.text.length == 0) {
        error = NSLocalizedString(@"register_error_email_require", @"メールアドレスを入力してください") ;
    } else if (![self NSStringIsValidEmail:textMail.text]) {
        error = NSLocalizedString(@"register_error_email_format", @"メールアドレスを正しく入力してください");
    } else if (textPassword.text.length == 0) {
        error = NSLocalizedString(@"register_error_password_require", @"パスワードを入力してください");
    } else  if (textName.text.length == 0) {
        error = NSLocalizedString(@"register_error_username_require", @"ニックネームを入力してください");
    } else  if (textName.text.length == 0) {
        error = NSLocalizedString(@"register_error_username_require", @"ニックネームを入力してください");
    } else  if (textPassword.text.length < 5) {
        error = NSLocalizedString(@"Password must be at least 5 characters", "");
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

- (void)viewDidUnload {
    [self setTextMail:nil];
    [self setTextPassword:nil];
    [self setTextName:nil];
    [self setTextPassword:nil];
    [self setViewText1:nil];
    [self setViewText2:nil];
    [self setScrollView:nil];
    [super viewDidUnload];
}

- (void)viewDidDisappear:(BOOL)animated {
    //    luxeysAppDelegate* app = (luxeysAppDelegate*)[UIApplication sharedApplication].delegate;
    //    [app.fbLogin setDelegate:nil];
    //[self.navigationController setNavigationBarHidden:false];
}

@end
