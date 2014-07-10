//
//  luxeysCellWelcomeMulti.m
//  Latte
//
//  Created by Xuan Dung Bui on 2012/11/06.
//  Copyright (c) 2012年 LUXEYS. All rights reserved.
//

#import "LXCellTimelineMulti.h"
#import "User.h"
#import "Picture.h"
#import "UIButton+AsyncImage.h"
#import "LXTimelineMultiItemViewController.h"
#import "LXUserPageViewController.h"

#import "LXAppDelegate.h"
#import "LXUserPageViewController.h"
#import "LXGalleryViewController.h"
#import "LXPicVoteCollectionController.h"
#import "LXPicCommentViewController.h"


@implementation LXCellTimelineMulti {
    NSMutableArray *thumbControllers;
}

@synthesize buttonUser;
@synthesize scrollPic;
@synthesize labelTitle;
@synthesize labelUserDate;
@synthesize imageNationality;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)awakeFromNib {
    buttonUser.layer.cornerRadius = 18;
    buttonUser.layer.shouldRasterize = YES;
    buttonUser.layer.rasterizationScale = [[UIScreen mainScreen] scale];
    
    _viewWrap.layer.cornerRadius = 3;
}

- (void)setFeed:(Feed *)feed {
    _feed = feed;

    [buttonUser loadBackground:feed.user.profilePicture placeholderImage:@"user.gif"];
    
    for(UIView *subview in [scrollPic subviews]) {
        [subview removeFromSuperview];
    }
    
    CGSize size = CGSizeMake(0, 200);
    UIStoryboard *storyComponent = [UIStoryboard storyboardWithName:@"Component"
                                                             bundle:nil];
    
    NSInteger index = 0;
    thumbControllers = [[NSMutableArray alloc] init];
    for (Picture *pic in feed.targets) {
        LXTimelineMultiItemViewController *viewPic = [storyComponent instantiateViewControllerWithIdentifier:@"TimlineMultiPhoto"];
        [thumbControllers addObject:viewPic];
        
        viewPic.pic = pic;
        viewPic.parent = self;
        viewPic.index = index;

        viewPic.view.frame = CGRectMake(size.width, 0, 200, 200);
        [scrollPic addSubview:viewPic.view];
        
        size.width += 206;
        index += 1;
    }
    
    scrollPic.contentOffset = CGPointZero;
    scrollPic.contentSize = size;
    
    labelTitle.text = feed.user.name;
    labelUserDate.text = [LXUtils timeDeltaFromNow:feed.updatedAt];
    
    
    [LXUtils setNationalityOfUser:feed.user forImage:imageNationality nextToLabel:labelTitle];
}

- (IBAction)showUser:(id)sender {
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"MainStoryboard"
                                                             bundle:nil];
    LXUserPageViewController *viewUserPage = [mainStoryboard instantiateViewControllerWithIdentifier:@"UserPage"];
    
    viewUserPage.user = _feed.user;
    [_parent.navigationController pushViewController:viewUserPage animated:YES];
}

- (void)showPicture:(UIButton*)sender {
    UIStoryboard *storyGallery = [UIStoryboard storyboardWithName:@"Gallery"
                                                           bundle:nil];
    UINavigationController *navGalerry = [storyGallery instantiateInitialViewController];
    LXGalleryViewController *viewGallery = navGalerry.viewControllers[0];
    viewGallery.delegate = _parent;
    viewGallery.user = _feed.user;
    viewGallery.picture = _feed.targets[sender.tag];
    
    [_parent presentViewController:navGalerry animated:YES completion:nil];
}

- (void)showComment:(UIButton*)sender {
    UIStoryboard *storyGallery = [UIStoryboard storyboardWithName:@"Gallery"
                                                           bundle:nil];
    LXPicCommentViewController *viewComment = [storyGallery instantiateViewControllerWithIdentifier:@"Comment"];
    viewComment.picture = _feed.targets[sender.tag];
    [_parent.navigationController pushViewController:viewComment animated:YES];
}


- (void)toggleLike:(UIButton*)sender {
    Picture *picture = _feed.targets[sender.tag];
    if (picture.isOwner) {
        UIStoryboard *storyGallery = [UIStoryboard storyboardWithName:@"Gallery"
                                                               bundle:nil];
        LXPicVoteCollectionController *viewVote = [storyGallery instantiateViewControllerWithIdentifier:@"Like"];
        viewVote.picture = _feed.targets[sender.tag];
        [_parent.navigationController pushViewController:viewVote animated:YES];
    } else {
        [LXUtils toggleLike:sender ofPicture:picture];
    }
}

@end
