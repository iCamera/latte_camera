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
    [app.tracker sendView:@"Register Screen"];
    
    HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:HUD];
    HUD.mode = MBProgressHUDModeIndeterminate;
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg_sub_back.png"]];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)touchBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
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
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"register_sent_email", @"登録確認メールを送信しました。")
                                                            message:NSLocalizedString(@"register_click_the_link", @"メールに記載されたURLをクリックして、手続きを行ってください。") delegate:nil
                                                  cancelButtonTitle:NSLocalizedString(@"close", @"閉じる")
                                                  otherButtonTitles:nil];
            [alert show];
            [self.navigationController popViewControllerAnimated:YES];
            
        };
        
        void (^failureBlock)(AFHTTPRequestOperation *, NSError *) = ^(AFHTTPRequestOperation *operation, NSError *error) {
            [HUD hide:YES];
            TFLog(@"Something went wrong (Login)");
        };
        
        [[LatteAPIClient sharedClient] postPath:@"user/register"
                                     parameters:params
                                        success:successBlock
                                        failure:failureBlock];
    }
}

- (IBAction)touchPolicy:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://latte.la/company/policy"]];

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
    [super viewDidUnload];
}

- (void)viewDidDisappear:(BOOL)animated {
    //    luxeysAppDelegate* app = (luxeysAppDelegate*)[UIApplication sharedApplication].delegate;
    //    [app.fbLogin setDelegate:nil];
    //[self.navigationController setNavigationBarHidden:false];
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
    return 30;
}
@end
