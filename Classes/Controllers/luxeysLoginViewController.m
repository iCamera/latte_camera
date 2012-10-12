//
//  luxeysLoginViewController.m
//  Latte
//
//  Created by Xuan Dung Bui on 8/7/12.
//  Copyright (c) 2012 LUXEYS. All rights reserved.
//

#import "luxeysLoginViewController.h"
#import "LatteAPIClient.h"
#import "luxeysAppDelegate.h"

@interface luxeysLoginViewController ()

@end

@implementation luxeysLoginViewController

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
    self.textUser.text = [app.tokenItem objectForKey:(id)CFBridgingRelease(kSecAttrAccount)];
    self.textPass.text = [app.tokenItem objectForKey:(id)CFBridgingRelease(kSecValueData)];
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
    luxeysAppDelegate* app = (luxeysAppDelegate*)[UIApplication sharedApplication].delegate;
    [app.tokenItem setObject:self.textUser.text forKey:(id)CFBridgingRelease(kSecAttrAccount)];
    [app.tokenItem setObject:self.textPass.text forKey:(id)CFBridgingRelease(kSecValueData)];
    
    [[LatteAPIClient sharedClient] postPath:@"api/user/login"
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
                                                  app.currentUser = [JSON objectForKey:@"user"];
                                                  [self.navigationController popViewControllerAnimated:YES];
                                                  
                                                  [[NSNotificationCenter defaultCenter]
                                                   postNotificationName:@"LoggedIn"
                                                   object:self];
                                              }
                                          } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                            NSLog(@"Something went wrong (Login)");
                                          }];
}

@end
