//
//  luxeysRegisterViewController.m
//  Latte
//
//  Created by Xuan Dung Bui on 2012/11/07.
//  Copyright (c) 2012年 LUXEYS. All rights reserved.
//

#import "luxeysRegisterViewController.h"

@interface luxeysRegisterViewController ()

@end

@implementation luxeysRegisterViewController

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
        [[LatteAPIClient sharedClient] postPath:@"/api/user/register"
                                     parameters:params
                                        success:^(AFHTTPRequestOperation *operation, NSDictionary *JSON) {
                                            [HUD hide:YES];
                                            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@""
                                                                                            message:@"Please check mail and login." delegate:nil
                                                                                  cancelButtonTitle:@"OK"
                                                                                  otherButtonTitles:nil];
                                            [alert show];
                                            [self.navigationController popViewControllerAnimated:YES];

                                        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                            [HUD hide:YES];
                                            NSLog(@"Something went wrong (Login)");
                                        }];
    }
}

- (IBAction)touchPolicy:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://latte.la/company/policy"]];

}

- (BOOL)validateInput {
    NSString *error;
    if (textMail.text.length == 0) {
        error = @"You can't leave the email empty!";
    } else if (![self NSStringIsValidEmail:textMail.text]) {
        error = @"Email is not correct format!";
    } else if (textPassword.text.length == 0) {
        error = @"You can't leave the password empty!";
    } else  if (textName.text.length == 0) {
        error = @"You can't leave the name empty!";
    }
    
    if (error != nil) {
        UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"エラー"
                                                             message:error
                                                            delegate:nil
                                                   cancelButtonTitle:@"OK"
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
    [title setFont:[UIFont boldSystemFontOfSize:12]];
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
