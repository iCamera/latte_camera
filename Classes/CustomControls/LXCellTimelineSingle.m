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
#import "RDActionSheet.h"
#import "UIButton+AFNetworking.h"
#import "LXUserPageViewController.h"

@implementation LXCellTimelineSingle {
    LXShare *lxShare;
}

@synthesize viewController;

@synthesize labelTitle;
@synthesize labelUser;
@synthesize labelAccess;
@synthesize labelLike;
@synthesize buttonPic;
@synthesize buttonUser;

@synthesize buttonComment;
@synthesize buttonInfo;
@synthesize buttonLike;
@synthesize viewBackground;
@synthesize buttonShare;
@synthesize imageNationality;
@synthesize labelDesc;
@synthesize viewDesc;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        NSLog(@"Created");
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
    buttonUser.layer.cornerRadius = 15;
    buttonUser.layer.shouldRasterize = YES;
    buttonUser.layer.rasterizationScale = [[UIScreen mainScreen] scale];
    
    [LXUtils globalShadow:viewBackground];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setFeed:(Feed *)feed {
    _feed = feed;
    
    Picture *pic = feed.targets[0];

    [buttonPic setImageForState:UIControlStateNormal withURL:[NSURL URLWithString:pic.urlMedium] placeholderImage:nil];

    buttonLike.tag = [pic.pictureId integerValue];
    buttonInfo.tag = [pic.pictureId integerValue];
    
    [buttonComment setTitle:[pic.commentCount stringValue] forState:UIControlStateNormal];
    labelLike.text = [pic.voteCount stringValue];
    labelAccess.text = [pic.pageviews stringValue];

    LXAppDelegate* app = (LXAppDelegate*)[[UIApplication sharedApplication] delegate];
    
    buttonLike.enabled = NO;
    if (!(pic.isVoted && !app.currentUser))
        buttonLike.enabled = YES;
    buttonLike.selected = pic.isVoted;
    labelLike.highlighted = pic.isVoted;
    
    buttonComment.enabled = pic.canComment;
    
    [buttonUser setBackgroundImageForState:UIControlStateNormal withURL:[NSURL URLWithString:feed.user.profilePicture] placeholderImage:[UIImage imageNamed:@"user.gif"]];

    labelTitle.text = feed.user.name;
    labelUser.text = [LXUtils timeDeltaFromNow:feed.updatedAt];
    
    [LXUtils setNationalityOfUser:feed.user forImage:imageNationality nextToLabel:labelTitle];
    
    labelDesc.text = pic.descriptionText;
    viewDesc.hidden = pic.descriptionText.length == 0;
    

    [self increaseCounter];
}

- (void)showDesc {
    if (labelDesc.text.length > 0) {
        [UIView animateWithDuration:kGlobalAnimationSpeed animations:^{
            viewDesc.alpha = 1;
        }];
    }
}

- (void)hideDesc {
    [UIView animateWithDuration:kGlobalAnimationSpeed animations:^{
        viewDesc.alpha = 0;
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
    UINavigationController *navGalerry = [storyGallery instantiateInitialViewController];
    LXGalleryViewController *viewGallery = navGalerry.viewControllers[0];
    viewGallery.delegate = viewController;
    viewGallery.user = _feed.user;
    viewGallery.picture = pic;
    
    [viewController presentViewController:navGalerry animated:YES completion:^{
        viewGallery.currentTab = kGalleryTabComment;
    }];
}

- (IBAction)toggleLike:(id)sender {
    Picture *pic = _feed.targets[0];
    if (pic.isOwner) {
        UIStoryboard *storyGallery = [UIStoryboard storyboardWithName:@"Gallery"
                                                               bundle:nil];
        UINavigationController *navGalerry = [storyGallery instantiateInitialViewController];
        LXGalleryViewController *viewGallery = navGalerry.viewControllers[0];
        viewGallery.delegate = viewController;
        viewGallery.user = _feed.user;
        viewGallery.picture = pic;
        
        [viewController presentViewController:navGalerry animated:YES completion:^{
            viewGallery.currentTab = kGalleryTabVote;
        }];
    } else {
        [LXUtils toggleLike:buttonLike ofPicture:pic setCount:labelLike];
    }
}

- (IBAction)moreAction:(id)sender {
    Picture *pic = _feed.targets[0];
    
    RDActionSheet *actionSheet = [[RDActionSheet alloc] initWithCancelButtonTitle:NSLocalizedString(@"Cancel", @"")
                                                               primaryButtonTitle:nil
                                                           destructiveButtonTitle:nil
                                                                otherButtonTitles:@"Email", @"Twitter", @"Facebook", nil];
    
    actionSheet.callbackBlock = ^(RDActionSheetResult result, NSInteger buttonIndex)
    {
        switch (result) {
                
            case RDActionSheetButtonResultSelected: {
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
                break;
            case RDActionSheetResultResultCancelled:
                NSLog(@"Sheet cancelled");
        }
    };
    
    [actionSheet showFrom:viewController.navigationController.tabBarController.view];
}
@end
