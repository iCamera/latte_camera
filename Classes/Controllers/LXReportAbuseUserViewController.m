//
//  LXReportAbuseViewController.m
//  Latte camera
//
//  Created by Bui Xuan Dung on 8/5/13.
//  Copyright (c) 2013 LUXEYS. All rights reserved.
//

#import "LXReportAbuseUserViewController.h"
#import "LatteAPIClient.h"
#import "UIImageView+loadProgress.h"

@interface LXReportAbuseUserViewController ()

@end

@implementation LXReportAbuseUserViewController

@synthesize textComment;
@synthesize textOriginal;

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
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    textComment.placeholder = NSLocalizedString(@"Message", @"");
    textOriginal.text = _user.name;
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    [super viewWillAppear:animated];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view delegate

- (void)viewDidUnload {
    [self setTextComment:nil];
    [super viewDidUnload];
}

- (IBAction)touchReport:(id)sender {
    NSString *path = [NSString stringWithFormat:@"user/report_abuse/%@/%ld", @"user", [_user.userId longValue]];
    
    [[LatteAPIClient sharedClient] POST:path
                             parameters:@{@"report_comment": textComment.text}
                                success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"report", @"")
                                                                                    message:NSLocalizedString(@"Report sent", @"")
                                                                                   delegate:nil
                                                                          cancelButtonTitle:NSLocalizedString(@"OK", @"")
                                                                          otherButtonTitles:nil];
                                    [alert show];
                                    [self.navigationController popViewControllerAnimated:YES];
                                }
                                failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                    NSLog(@"[HTTPClient Error]: %@", error.localizedDescription);
                                    }];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [textComment resignFirstResponder];
}

@end
