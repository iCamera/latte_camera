//
//  LXNavigationController.m
//  Latte camera
//
//  Created by Bui Xuan Dung on 3/19/13.
//  Copyright (c) 2013 LUXEYS. All rights reserved.
//

#import "LXNavigationController.h"
#import "LXAppDelegate.h"

@interface LXNavigationController ()

@end

@implementation LXNavigationController

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
    LXAppDelegate* app = [LXAppDelegate currentDelegate];
    self.delegate = app.viewMainTab;
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
