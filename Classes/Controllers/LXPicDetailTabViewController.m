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
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    scrollTab.contentSize = CGSizeMake(960, screenRect.size.height);
    scrollTab.contentOffset = CGPointMake(320, 0);
}

- (void)updateContent {
    CGPoint frameOrigin = self.view.frame.origin;
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat height = screenRect.size.height - frameOrigin.y;
    if (height == 0) {
        return;
    }
    CGRect frameVote = viewVote.view.frame;
    CGRect frameComment = _viewComment.view.frame;
    CGRect frameInfo = viewInfo.view.frame;
    
    frameVote.size.height = height;
    frameComment.size.height = height;
    frameInfo.size.height = height;
    
    [UIView animateWithDuration:kGlobalAnimationSpeed
                     animations:^{
                         viewVote.view.frame = frameVote;
                         _viewComment.view.frame = frameComment;
                         viewInfo.view.frame = frameInfo;
                     }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
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
    [scrollTab  setContentOffset:CGPointMake((tab-1)*320, 0) animated:YES];
}

@end
