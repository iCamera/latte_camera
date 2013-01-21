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
    [TestFlight submitFeedback:textForm.text];
    UIAlertView *viewOK = [[UIAlertView alloc] initWithTitle:@"Submitted"
                                                     message:@"Thank you!"
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