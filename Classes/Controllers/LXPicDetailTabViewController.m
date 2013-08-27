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


@interface LXPicDetailTabViewController () {
    NSInteger currentTab;
}

@end

@implementation LXPicDetailTabViewController {
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
        UIStoryboard *storyGallery = [UIStoryboard storyboardWithName:@"Gallery" bundle:nil];
        _viewVote = [storyGallery instantiateViewControllerWithIdentifier:@"Vote"];
        _viewComment = [storyGallery instantiateViewControllerWithIdentifier:@"Comment"];
        viewInfo = [storyGallery instantiateViewControllerWithIdentifier:@"Info"];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    _viewVote.view.frame = CGRectMake(0, 0, 320, 320);
    [scrollTab addSubview:_viewVote.view];
    [self addChildViewController:_viewVote];
    [_viewVote didMoveToParentViewController:self];
    
    _viewComment.view.frame = CGRectMake(320, 0, 320, 320);
    [scrollTab addSubview:_viewComment.view];
    [self addChildViewController:_viewComment];
    [_viewComment didMoveToParentViewController:self];
    
    viewInfo.view.frame = CGRectMake(640, 0, 320, 320);
    [scrollTab addSubview:viewInfo.view];
    [self addChildViewController:viewInfo];
    [viewInfo didMoveToParentViewController:self];
    
    currentTab = 2;
    scrollTab.contentSize = CGSizeMake(960, 320);
    scrollTab.contentOffset = CGPointMake(320, 0);
    
    viewInfo.parent = _parent;
    _viewComment.parent = _parent;
    if (_picture != nil) {
        viewInfo.picture = _picture;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)setPicture:(Picture *)picture {
    _picture = picture;
    _viewComment.picture = picture;
    viewInfo.picture = picture;
    
    // Switch to comment
    if (!_picture.isOwner && currentTab == 1) {
        [self setTab:2];
    }
}

- (void)setTab:(NSInteger)tab {
    currentTab = tab;
    [scrollTab  setContentOffset:CGPointMake((tab-1)*320, 0) animated:YES];
}

- (void)viewDidUnload {
    [super viewDidUnload];
}
@end
