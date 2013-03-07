//
//  LXPicDetailTabViewController.m
//  Latte camera
//
//  Created by Bui Xuan Dung on 3/6/13.
//  Copyright (c) 2013 LUXEYS. All rights reserved.
//

#import "LXPicDetailTabViewController.h"

#import "LXPicInfoViewController.h"
#import "LXVoteViewController.h"
#import "LXPicCommentViewController.h"


@interface LXPicDetailTabViewController () {
    NSInteger currentTab;
}

@end

@implementation LXPicDetailTabViewController {
    LXVoteViewController *viewVote;
    LXPicMapViewController *viewMap;
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

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    currentTab = 2;
//    scrollTab.contentOffset = CGPointMake(320, 0);
//    scrollTab.contentSize = CGSizeMake(960, 480);
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"Vote"]) {
        viewVote = segue.destinationViewController;
        viewVote.picture = _picture;
    } else if ([segue.identifier isEqualToString:@"Comment"]) {
        _viewComment = segue.destinationViewController;
        _viewComment.picture = _picture;
    } else if ([segue.identifier isEqualToString:@"Info"]) {
        viewInfo = segue.destinationViewController;
        viewInfo.picture = _picture;
    }
}

- (void)setPicture:(Picture *)picture {
    _picture = picture;
    viewVote.picture = picture;
    _viewComment.picture = picture;
    viewInfo.picture = picture;
    
    // Switch to comment
    if (!_picture.isOwner && currentTab == 1) {
        [self setTab:2];
    }
}

- (void)setComments:(NSMutableArray *)comments {
    _viewComment.comments = comments;
}

- (void)setTab:(NSInteger)tab {
    currentTab = tab;
    [scrollTab setContentOffset:CGPointMake((tab-1)*320, 0) animated:YES];
}

@end
