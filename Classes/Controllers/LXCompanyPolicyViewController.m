//
//  LXCompanyPolicyViewController.m
//  Latte camera
//
//  Created by Juan Tabares on 6/3/14.
//  Copyright (c) 2014 LUXEYS. All rights reserved.
//

#import "LXCompanyPolicyViewController.h"

@interface LXCompanyPolicyViewController ()
@property (weak, nonatomic) IBOutlet UIWebView *mainWebView;

@end

@implementation LXCompanyPolicyViewController

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
    NSString *language = [[NSLocale preferredLanguages] objectAtIndex:0];
    NSURL *url = nil;
    if ([language isEqualToString:@"ja"]) {
        url = [NSURL URLWithString:@"http://latte.la/company/policy"];
    } else {
        url = [NSURL URLWithString:@"http://en.latte.la/company/policy"];
    }
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [self.mainWebView loadRequest:request];
	// Do any additional setup after loading the view.
}

- (void)viewDidUnload {
    [self setMainWebView:nil];
    [super viewDidUnload];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
