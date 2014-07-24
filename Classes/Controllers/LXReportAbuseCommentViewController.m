//
//  LXReportAbuseViewController.m
//  Latte camera
//
//  Created by Bui Xuan Dung on 8/5/13.
//  Copyright (c) 2013 LUXEYS. All rights reserved.
//

#import "LXReportAbuseCommentViewController.h"
#import "LatteAPIClient.h"
#import "UIImageView+loadProgress.h"

@interface LXReportAbuseCommentViewController ()

@end

@implementation LXReportAbuseCommentViewController

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
    textOriginal.text = _comment.descriptionText;
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
    NSString *path = [NSString stringWithFormat:@"user/report_abuse/%@/%ld", @"comment", [_comment.commentId longValue]];
    
    [[LatteAPIClient sharedClient] POST:path
                                 parameters:[NSDictionary dictionaryWithObject:textComment.text forKey:@"report_comment"]
                                    success:nil
                                    failure:nil];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"report", @"")
                                                    message:NSLocalizedString(@"Report sent", @"")
                                                   delegate:nil
                                          cancelButtonTitle:NSLocalizedString(@"OK", @"")
                                          otherButtonTitles:nil];
    [alert show];
    [self.navigationController popViewControllerAnimated:YES];

}

@end
