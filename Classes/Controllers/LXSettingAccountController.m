//
//  LXSettingAccountController.m
//  Latte camera
//
//  Created by Bui Xuan Dung on 7/31/13.
//  Copyright (c) 2013 LUXEYS. All rights reserved.
//

#import "LXSettingAccountController.h"
#import "LXAppDelegate.h"

@interface LXSettingAccountController ()

@end

@implementation LXSettingAccountController
@synthesize textEmail;

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

    // Uncomment the following line to preserve selection between presentations.
    self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    LXAppDelegate *app = [LXAppDelegate currentDelegate];
    textEmail.text = app.currentUser.mail;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view delegate

- (void)viewDidUnload {
    [self setTextEmail:nil];
    [super viewDidUnload];
}
@end
