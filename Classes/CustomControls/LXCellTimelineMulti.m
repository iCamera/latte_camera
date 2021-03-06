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
#import "LXTagHome.h"

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

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        
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
    
    _scrollTags.parent = self;
    
    if (_feed.tags.count > 0) {
        _scrollTags.followingTags = _feed.followingTags;
        _scrollTags.tags = _feed.tags;
        _scrollTags.hidden = NO;
    } else {
        _scrollTags.hidden = YES;
    }
    
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
    LXGalleryViewController *viewGallery = [storyGallery instantiateInitialViewController];
    viewGallery.delegate = _parent;
    viewGallery.user = _feed.user;
    viewGallery.picture = _feed.targets[sender.tag];
    
    [_parent.navigationController pushViewController:viewGallery animated:YES];
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
        LXAppDelegate* app = [LXAppDelegate currentDelegate];
        if (!app.currentUser) {
            UIStoryboard *storyAuth = [UIStoryboard storyboardWithName:@"Authentication" bundle:nil];
            UIViewController *viewLogin = [storyAuth instantiateInitialViewController];
            
            [_parent presentViewController:viewLogin animated:YES completion:nil];
        } else {
            [LXUtils toggleLike:sender ofPicture:picture];
        }
    }
}

- (void)showNormalTag:(UIButton*)button {
    NSString *tag = _feed.tags[button.tag];
    
    UIStoryboard *storyMain = [UIStoryboard storyboardWithName:@"MainStoryboard"
                                                        bundle:nil];
    
    LXTagHome *viewTag = [storyMain instantiateViewControllerWithIdentifier:@"TagHome"];
    viewTag.tag = tag;
    
    [_parent.navigationController pushViewController:viewTag animated:YES];
}

@end
