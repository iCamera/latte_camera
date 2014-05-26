//
//  LXPicDetailTabViewController.m
//  Latte camera
//
//  Created by Bui Xuan Dung on 3/6/13.
//  Copyright (c) 2013 LUXEYS. All rights reserved.
//

#import "LXPicDetailTabViewController.h"

#import "LXPicInfoViewController.h"
#import "LXPicCommentViewController.h"
#import "LXVoteViewController.h"



@interface LXPicDetailTabViewController () {
    NSInteger currentTab;
}

@end

@implementation LXPicDetailTabViewController {
    LXPicCommentViewController *viewComment;
    LXVoteViewController *viewVote;
    LXPicInfoViewController *viewInfo;
}

@synthesize scrollTab;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
    }
    return self;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"Vote"]) {
        viewVote = segue.destinationViewController;
        viewVote.picture = _picture;
    }
    if ([segue.identifier isEqualToString:@"Comment"]) {
        viewComment = segue.destinationViewController;
        viewComment.picture = _picture;
    }
    if ([segue.identifier isEqualToString:@"Info"]) {
        viewInfo = segue.destinationViewController;
        viewInfo.picture = _picture;
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    currentTab = 2;
    scrollTab.contentSize = CGSizeMake(960, 320);
    scrollTab.contentOffset = CGPointMake(320, 0);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)setTab:(NSInteger)tab {
    currentTab = tab;
    [scrollTab  setContentOffset:CGPointMake((tab-1)*320, 0) animated:YES];
}

- (void)viewDidUnload {
    [super viewDidUnload];
}
- (IBAction)closeModal:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

@end
