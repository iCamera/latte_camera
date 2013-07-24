//
//  LXFAQViewController.m
//  Latte camera
//
//  Created by Bui Xuan Dung on 7/24/13.
//  Copyright (c) 2013 LUXEYS. All rights reserved.
//

#import "LXFAQViewController.h"
#import "LatteAPIClient.h"

@interface LXFAQViewController ()

@end

@implementation LXFAQViewController

@synthesize viewWeb;

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
    LatteAPIClient *api = [LatteAPIClient sharedClient];
    [super viewDidLoad];
    [viewWeb loadRequest:[api requestWithMethod:@"GET" path:@"user/help" parameters:nil]];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setViewWeb:nil];
    [super viewDidUnload];
}
@end
