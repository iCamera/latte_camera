//
//  luxeysCellWelcomeSingle.m
//  Latte
//
//  Created by Xuan Dung Bui on 2012/11/06.
//  Copyright (c) 2012年 LUXEYS. All rights reserved.
//

#import "LXCellTimelineSingle.h"
#import "Picture.h"
#import "Comment.h"
#import "LXCellComment.h"
#import "LXAppDelegate.h"
#import "LXShare.h"
#import "UIButton+AFNetworking.h"
#import "LXUserPageViewController.h"
#import "LXPicVoteCollectionController.h"
#import "LXPicCommentViewController.h"
#import "LXPicInfoViewController.h"
#import "LXTagHome.h"

@implementation LXCellTimelineSingle {
    LXShare *lxShare;
}

@synthesize viewController;

@synthesize labelTitle;
@synthesize labelUser;
@synthesize buttonPic;
@synthesize buttonUser;

@synthesize buttonComment;
@synthesize buttonInfo;
@synthesize buttonLike;
@synthesize viewBackground;
@synthesize buttonShare;
@synthesize imageNationality;
@synthesize labelDesc;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
    }
    return self;
}

- (id)init {
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showDesc) name:@"TimelineShowDesc" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideDesc) name:@"TimelineHideDesc" object:nil];
    }
    return self;
}

- (void)awakeFromNib {
    buttonUser.layer.cornerRadius = 18;
    buttonUser.layer.shouldRasterize = YES;
    buttonUser.layer.rasterizationScale = [[UIScreen mainScreen] scale];
    
    _viewWrap.layer.cornerRadius = 3;
    _viewDescBg.layer.colors = [NSArray arrayWithObjects:(id)[[UIColor clearColor] CGColor], (id)[[UIColor colorWithWhite:0 alpha:0.5] CGColor], nil];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setFeed:(Feed *)feed {
    _feed = feed;
    
    Picture *pic = feed.targets[0];

    _contraintHeight.constant = [LXUtils heightFromWidth:304.0 width:[pic.width floatValue] height:[pic.height floatValue]];
    
    [buttonPic setBackgroundImageForState:UIControlStateNormal withURL:[NSURL URLWithString:pic.urlMedium] placeholderImage:nil];

    buttonLike.tag = [pic.pictureId integerValue];
    buttonInfo.tag = [pic.pictureId integerValue];
    
    [buttonComment setTitle:[pic.commentCount stringValue] forState:UIControlStateNormal];
    [buttonLike setTitle:[pic.voteCount stringValue] forState:UIControlStateNormal];

    LXAppDelegate* app = (LXAppDelegate*)[[UIApplication sharedApplication] delegate];
    
    buttonLike.enabled = NO;
    if (!(pic.isVoted && !app.currentUser))
        buttonLike.enabled = YES;
    buttonLike.selected = pic.isVoted;
    
    buttonComment.enabled = pic.canComment;
    
    [buttonUser setBackgroundImageForState:UIControlStateNormal withURL:[NSURL URLWithString:feed.user.profilePicture] placeholderImage:[UIImage imageNamed:@"user.gif"]];

    labelTitle.text = feed.user.name;
    labelUser.text = [LXUtils timeDeltaFromNow:feed.updatedAt];
    
    [LXUtils setNationalityOfUser:feed.user forImage:imageNationality nextToLabel:labelTitle];
    
    labelDesc.text = pic.descriptionText;
    _viewDescBg.hidden = pic.descriptionText.length == 0;
    
    // Tag
    
    CGSize size = CGSizeMake(6, 36);
    for (UIView *subview in _scrollTags.subviews) {
        [subview removeFromSuperview];
    }
    
    NSInteger idx = 0;
    for (NSString *tag in pic.tagsOld) {
        UIFont *font = [UIFont fontWithName:@"HelveticaNeue-Light" size:12];
        CGSize textSize = [tag sizeWithFont:font];
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(size.width, 8, textSize.width + 12, 22)];
        button.titleLabel.font = font;
        [button setTitle:tag forState:UIControlStateNormal];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [button setBackgroundColor:[UIColor colorWithRed:105.0/255.0 green:205.0/255.0 blue:117.0/255.0 alpha:1]];
        button.layer.cornerRadius = 3;
        size.width += textSize.width + 20;
        
        [button addTarget:self action:@selector(showNormalTag:) forControlEvents:UIControlEventTouchUpInside];
        button.tag = idx;
        idx += 1;
        [_scrollTags addSubview:button];
    }
    _scrollTags.contentSize = size;

    [self increaseCounter];
}

- (void)showDesc {
    if (labelDesc.text.length > 0) {
        [UIView animateWithDuration:kGlobalAnimationSpeed animations:^{
            _viewDescBg.alpha = 1;
        }];
    }
}

- (void)hideDesc {
    [UIView animateWithDuration:kGlobalAnimationSpeed animations:^{
        _viewDescBg.alpha = 0;
    }];
}

- (void)increaseCounter {
    // Increase counter
    Picture *pic = _feed.targets[0];
    NSString *urlCounter = [NSString stringWithFormat:@"picture/counter/%ld/%ld",
                            [pic.pictureId longValue],
                            [pic.userId longValue]];
    
    [[LatteAPIClient sharedClient] GET:urlCounter parameters:nil success:nil failure:nil];
}

- (IBAction)showUser:(id)sender {
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"MainStoryboard"
                                                             bundle:nil];
    LXUserPageViewController *viewUserPage = [mainStoryboard instantiateViewControllerWithIdentifier:@"UserPage"];
    
    viewUserPage.user = _feed.user;
    [viewController.navigationController pushViewController:viewUserPage animated:YES];
}

- (IBAction)showPicture:(id)sender {
    Picture *pic = _feed.targets[0];
    
    UIStoryboard *storyGallery = [UIStoryboard storyboardWithName:@"Gallery"
                                                           bundle:nil];
    UINavigationController *navGalerry = [storyGallery instantiateInitialViewController];
    LXGalleryViewController *viewGallery = navGalerry.viewControllers[0];
    viewGallery.delegate = viewController;
    viewGallery.user = _feed.user;
    viewGallery.picture = pic;
    
    [viewController presentViewController:navGalerry animated:YES completion:nil];
}

- (IBAction)showComment:(id)sender {
    Picture *pic = _feed.targets[0];
    
    UIStoryboard *storyGallery = [UIStoryboard storyboardWithName:@"Gallery"
                                                           bundle:nil];
    LXPicCommentViewController *viewComment = [storyGallery instantiateViewControllerWithIdentifier:@"Comment"];

    viewComment.picture = pic;
    
    [viewController.navigationController pushViewController:viewComment animated:YES];
}

- (IBAction)showInfo:(id)sender {
    Picture *pic = _feed.targets[0];
    
    UIStoryboard *storyGallery = [UIStoryboard storyboardWithName:@"Gallery"
                                                           bundle:nil];
    LXPicInfoViewController *viewInfo = [storyGallery instantiateViewControllerWithIdentifier:@"Info"];
    
    viewInfo.picture = pic;
    
    [viewController.navigationController pushViewController:viewInfo animated:YES];
}

- (IBAction)toggleLike:(id)sender {
    Picture *pic = _feed.targets[0];
    if (pic.isOwner) {
        UIStoryboard *storyGallery = [UIStoryboard storyboardWithName:@"Gallery"
                                                               bundle:nil];
        LXPicVoteCollectionController *viewVote = [storyGallery instantiateViewControllerWithIdentifier:@"Like"];
        
        viewVote.picture = pic;
        
        [viewController.navigationController pushViewController:viewVote animated:YES];
    } else {
        [LXUtils toggleLike:buttonLike ofPicture:pic setCount:nil];
    }
}

- (IBAction)moreAction:(id)sender {
    UIActionSheet *action = [[UIActionSheet alloc] initWithTitle:nil
                                                        delegate:self
                                               cancelButtonTitle:NSLocalizedString(@"Cancel", @"")
                                          destructiveButtonTitle:nil
                                               otherButtonTitles:@"Email", @"Twitter", @"Facebook", nil];
    [action showFromTabBar:viewController.navigationController.tabBarController.tabBar];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    Picture *pic = _feed.targets[0];
    
    lxShare = [[LXShare alloc] init];
    lxShare.controller = viewController;
    
    lxShare.url = pic.urlWeb;
    lxShare.text = pic.urlWeb;
    
    switch (buttonIndex) {
        case 0: // email
            [lxShare emailIt];
            break;
        case 1: // twitter
            [lxShare tweet];
            break;
        case 2: // facebook
            [lxShare facebookPost];
            break;
        default:
            break;
    }
}

- (void)showNormalTag:(UIButton*)button {
    Picture *pic = _feed.targets[0];
    
    UIStoryboard *storyMain = [UIStoryboard storyboardWithName:@"MainStoryboard"
                                                        bundle:nil];
    
    LXTagHome *viewTag = [storyMain instantiateViewControllerWithIdentifier:@"TagHome"];
    viewTag.tag = pic.tagsOld[button.tag];
    viewTag.title = pic.tagsOld[button.tag];
    
    [viewController.navigationController pushViewController:viewTag animated:YES];
}


@end
