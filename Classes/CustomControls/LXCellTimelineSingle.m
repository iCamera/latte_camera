//
//  luxeysCellWelcomeSingle.m
//  Latte
//
//  Created by Xuan Dung Bui on 2012/11/06.
//  Copyright (c) 2012年 LUXEYS. All rights reserved.
//

#import "LXCellTimelineSingle.h"
#import "Picture.h"
#import "UIButton+AsyncImage.h"
#import "Comment.h"
#import "LXCellComment.h"
#import "LXAppDelegate.h"
#import "LXShare.h"
#import "RDActionSheet.h"

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
@synthesize buttonMap;
@synthesize buttonLike;
@synthesize viewBackground;
@synthesize buttonShare;
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

- (void)setFeed:(Feed *)feed {
    _feed = feed;
    
    Picture *pic = feed.targets[0];
    CGRect frame = buttonPic.frame;
    frame.size.height = [LXUtils heightFromWidth:308.0 width:[pic.width floatValue] height:[pic.height floatValue]];
    buttonPic.frame = frame;
    UIBezierPath *shadowPathPic = [UIBezierPath bezierPathWithRect:buttonPic.bounds];
    buttonPic.layer.masksToBounds = NO;
    buttonPic.layer.shadowColor = [UIColor blackColor].CGColor;
    buttonPic.layer.shadowOffset = CGSizeMake(0.0, 0.0);
    buttonPic.layer.shadowOpacity = 0.5f;
    buttonPic.layer.shadowRadius = 1.5f;
    buttonPic.layer.shadowPath = shadowPathPic.CGPath;
    [buttonPic loadBackground:pic.urlMedium];
        
    buttonPic.tag = [pic.pictureId integerValue];
    buttonLike.tag = [pic.pictureId integerValue];
    buttonMap.tag = [pic.pictureId integerValue];
    buttonInfo.tag = [pic.pictureId integerValue];
    buttonComment.tag = [pic.pictureId integerValue];
    
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
    
    if ((pic.latitude != nil) && (pic.longitude != nil)) {
        buttonMap.enabled = YES;
    } else {
        buttonMap.enabled = NO;
    }
    
    
    [buttonUser loadBackground:feed.user.profilePicture placeholderImage:@"user.gif"];

    labelTitle.text = feed.user.name;
    labelUser.text = [LXUtils timeDeltaFromNow:feed.updatedAt];
    
    self.clipsToBounds = NO;
    
    [buttonUser addTarget:viewController action:@selector(showUser:) forControlEvents:UIControlEventTouchUpInside];
    [buttonPic addTarget:viewController action:@selector(showPic:) forControlEvents:UIControlEventTouchUpInside];
    [buttonInfo addTarget:viewController action:@selector(showInfo:) forControlEvents:UIControlEventTouchUpInside];
    [buttonComment addTarget:viewController action:@selector(showComment:) forControlEvents:UIControlEventTouchUpInside];
    
    [buttonMap addTarget:viewController action:@selector(showMap:) forControlEvents:UIControlEventTouchUpInside];
    
    [buttonLike removeTarget:nil
                       action:NULL
             forControlEvents:UIControlEventAllEvents];
    if (pic.isOwner) {
        [buttonLike addTarget:viewController action:@selector(showLike:) forControlEvents:UIControlEventTouchUpInside];
    } else {
        [buttonLike addTarget:self action:@selector(submitLike:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    [buttonShare addTarget:self action:@selector(sharePic:) forControlEvents:UIControlEventTouchUpInside];
    
    [LXUtils setNationalityOfUser:feed.user forImage:imageNationality nextToLabel:labelTitle];
    
    // Increase counter
    NSString *urlCounter = [NSString stringWithFormat:@"picture/counter/%d/%d",
                            [pic.pictureId integerValue],
                            [pic.userId integerValue]];
    
    [[LatteAPIClient sharedClient] getPath:urlCounter parameters:nil success:nil failure:nil];
}

- (void)submitLike:(id)sender {
    Picture *pic = _feed.targets[0];
    [LXUtils toggleLike:buttonLike ofPicture:pic setCount:labelLike];
}

- (void)sharePic:(id)sender {
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

- (void)drawRect:(CGRect)rect {
    UIBezierPath *shadowPathUser = [UIBezierPath bezierPathWithRect:buttonUser.bounds];
    buttonUser.layer.masksToBounds = NO;
    buttonUser.layer.shadowColor = [UIColor blackColor].CGColor;
    buttonUser.layer.shadowOffset = CGSizeMake(0.0, 0.0);
    buttonUser.layer.shadowOpacity = 0.5f;
    buttonUser.layer.shadowRadius = 1.5f;
    buttonUser.layer.shadowPath = shadowPathUser.CGPath;
    buttonUser.layer.cornerRadius = 3.0;
    
    [LXUtils globalShadow:viewBackground];
    [super drawRect:rect];
}
@end
