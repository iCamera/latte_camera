//
//  luxeysLoginViewController.m
//  Latte
//
//  Created by Xuan Dung Bui on 8/7/12.
//  Copyright (c) 2012 LUXEYS. All rights reserved.
//

#import "luxeysLoginViewController.h"
#import "luxeysLatteAPIClient.h"
#import "luxeysAppDelegate.h"

@interface luxeysLoginViewController ()

@end

@implementation luxeysLoginViewController

@synthesize keychainItemWrapper;
@synthesize delegate;

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
    //[self.navigationController setNavigationBarHidden:true];
    luxeysAppDelegate* app = (luxeysAppDelegate*)[UIApplication sharedApplication].delegate;
    self.keychainItemWrapper = app.tokenItem;
    self.textUser.text = [self.keychainItemWrapper objectForKey:(__bridge id)kSecAttrAccount];
    self.textPass.text = [self.keychainItemWrapper objectForKey:(__bridge id)kSecValueData];
}

- (void)viewDidDisappear:(BOOL)animated {
    //[self.navigationController setNavigationBarHidden:false];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)registerClick:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://latte.la/user/register"]];
}
- (void)viewDidUnload {
    [self setTextUser:nil];
    [self setTextPass:nil];
    [super viewDidUnload];
}
- (IBAction)singleTap:(id)sender {
    [self.textUser resignFirstResponder];
    [self.textPass resignFirstResponder];
    
}

- (IBAction)goBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)login:(id)sender {
//    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle: nil];
//    luxeysAppDelegate* app = (luxeysAppDelegate*)[UIApplication sharedApplication].delegate;
//    app.window.rootViewController = [mainStoryboard instantiateInitialViewController];
    
    //[self performSegueWithIdentifier:@"MainView" sender:self];
    
    //luxeysMainViewController *tabView = [[luxeysMainViewController alloc]init];
    //[self.navigationController pushViewController:tabView animated:YES];
    
    luxeysAppDelegate* app = (luxeysAppDelegate*)[UIApplication sharedApplication].delegate;
    [app.tokenItem setObject:self.textUser.text forKey:(__bridge id)kSecAttrAccount];
    [app.tokenItem setObject:self.textPass.text forKey:(__bridge id)kSecValueData];
    
    [[luxeysLatteAPIClient sharedClient] postPath:@"api/user/login"
                                       parameters:[NSDictionary dictionaryWithObjectsAndKeys:
                                                   self.textUser.text, @"mail",
                                                   self.textPass.text, @"password", nil]
                                          success:^(AFHTTPRequestOperation *operation, NSDictionary *JSON) {
                                              if ([JSON objectForKey:@"token"] == 0) {
                                                  UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                                                  message:@"Email / Password is not correct"
                                                                                                 delegate:nil
                                                                                        cancelButtonTitle:@"OK"
                                                                                        otherButtonTitles:nil
                                                                        ];
                                                  [alert show];
                                              } else {
                                                  [app setToken:[JSON objectForKey:@"token"]];
                                                  [self.navigationController popViewControllerAnimated:YES];
                                                  
                                                  // Invoke delegate
                                                  [[self delegate] userLoggedIn];

                                              }
                                          } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                              UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                                              message:@"Something went wrong (Login)"
                                                                                             delegate:nil
                                                                                    cancelButtonTitle:@"OK"
                                                                                    otherButtonTitles:nil
                                                                    ];
                                              [alert show];
                                          }];
}
@end
