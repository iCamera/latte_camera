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
#import "LXAppDelegate.h"



@interface LXPicDetailTabViewController () {
    NSInteger currentTab;
}

@end

@implementation LXPicDetailTabViewController {
    LXPicCommentViewController *viewComment;
    LXVoteViewController *viewVote;
    LXPicInfoViewController *viewInfo;
}

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
    
    _constraintTab.constant = -(_tab-1)*320;
    
    _labelComment.text = [_picture.commentCount stringValue];
    _labelLike.text = [_picture.voteCount stringValue];
    
    _buttonLike.enabled = NO;
    LXAppDelegate *app = [LXAppDelegate currentDelegate];
    if (!(_picture.isVoted && !app.currentUser))
        _buttonLike.enabled = YES;
    _buttonLike.selected = _picture.isVoted;
    _labelLike.highlighted = _picture.isVoted;
}

- (void)awakeFromNib {
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
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

- (IBAction)toggleLike:(id)sender {
    if (_picture.isOwner) {
        _constraintTab.constant = 0;
        
        [UIView animateWithDuration:kGlobalAnimationSpeed animations:^{
            [self.view layoutIfNeeded];
        }];
    } else {
        [LXUtils toggleLike:sender ofPicture:_picture setCount:_labelLike];
    }
}

- (IBAction)touchComment:(id)sender {
    _constraintTab.constant = -320;

    [UIView animateWithDuration:kGlobalAnimationSpeed animations:^{
        [self.view layoutIfNeeded];
    }];
}

- (IBAction)touchInfo:(id)sender {
    _constraintTab.constant = -640;

    [UIView animateWithDuration:kGlobalAnimationSpeed animations:^{
        [self.view layoutIfNeeded];
    }];
}
@end
