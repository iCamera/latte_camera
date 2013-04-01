//
//  LXAboutViewController.m
//  Latte camera
//
//  Created by Xuan Dung Bui on 2013/01/17.
//  Copyright (c) 2013年 LUXEYS. All rights reserved.
//

#import "LXAboutViewController.h"
#import "LatteAPIClient.h"
#import "TestFlight.h"
#import "LXButtonBack.h"

@interface LXAboutViewController ()

@end

@implementation LXAboutViewController

@synthesize textForm;

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
    
    LXAppDelegate* app = (LXAppDelegate*)[UIApplication sharedApplication].delegate;
    [app.tracker sendView:@"About Screen"];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)touchClose:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)touchSend:(id)sender {
    LXAppDelegate* app = (LXAppDelegate*)[UIApplication sharedApplication].delegate;
    
    NSString *senderName = @"";
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   textForm.text, @"memo",
                                   senderName, @"sender",
                                   nil];
    if (app.currentUser != nil) {
        senderName = [NSString stringWithFormat:@"%@ [ID: %d]", app.currentUser.name, [app.currentUser.userId integerValue]] ;
        [params setObject:[app getToken] forKey:@"token"];
    }
    
    
    [[LatteAPIClient sharedClient] postPath:@"user/inqury"
                                 parameters:params
                                    success:nil
                                    failure:nil];
    
    UIAlertView *viewOK = [[UIAlertView alloc] initWithTitle:@"Submitted"
                                                     message:@"Thank you! :)"
                                                    delegate:self
                                           cancelButtonTitle:nil
                                           otherButtonTitles:@"OK", nil];
    [viewOK show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewDidUnload {
    [self setTextForm:nil];
    [super viewDidUnload];
}
@end
