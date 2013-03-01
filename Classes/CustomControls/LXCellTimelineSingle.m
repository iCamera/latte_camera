//
//  luxeysCellWelcomeSingle.m
//  Latte
//
//  Created by Xuan Dung Bui on 2012/11/06.
//  Copyright (c) 2012年 LUXEYS. All rights reserved.
//

#import "LXCellTimelineSingle.h"

#import "LXAppDelegate.h"

@implementation LXCellTimelineSingle

@synthesize viewController;
@synthesize feed;

@synthesize labelTitle;
@synthesize labelUser;
@synthesize labelAccess;
@synthesize buttonPic;
@synthesize buttonUser;

@synthesize buttonComment;
@synthesize buttonInfo;
@synthesize buttonMap;
@synthesize buttonLike;
@synthesize viewBackground;

@synthesize isExpanded;

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

- (void)setFeed:(Feed *)aFeed {
    feed = aFeed;
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
    [buttonLike setTitle:[pic.voteCount stringValue] forState:UIControlStateNormal];
    labelAccess.text = [pic.pageviews stringValue];

    LXAppDelegate* app = (LXAppDelegate*)[[UIApplication sharedApplication] delegate];
    
    if (pic.canVote) {
        if (!(pic.isVoted && !app.currentUser))
            buttonLike.enabled = YES;
    } else {
        buttonLike.enabled = NO;
    }
    
    buttonLike.selected = pic.isVoted;
    
    if (pic.canComment) {
        buttonComment.enabled = YES;
    }
    
    if ((pic.latitude != nil) && (pic.longitude != nil)) {
        buttonMap.enabled = YES;
    }
    
    UIBezierPath *shadowPathUser = [UIBezierPath bezierPathWithRect:buttonUser.bounds];
    buttonUser.layer.masksToBounds = NO;
    buttonUser.layer.shadowColor = [UIColor blackColor].CGColor;
    buttonUser.layer.shadowOffset = CGSizeMake(0.0, 0.0);
    buttonUser.layer.shadowOpacity = 0.5f;
    buttonUser.layer.shadowRadius = 1.5f;
    buttonUser.layer.shadowPath = shadowPathUser.CGPath;
    buttonUser.layer.cornerRadius = 3.0;

    [buttonUser loadBackground:feed.user.profilePicture placeholderImage:@"user.gif"];

    labelTitle.text = feed.user.name;
    labelUser.text = [LXUtils timeDeltaFromNow:feed.updatedAt];
    
    self.clipsToBounds = NO;
    
    [buttonUser addTarget:viewController action:@selector(showUser:) forControlEvents:UIControlEventTouchUpInside];
    [buttonPic addTarget:viewController action:@selector(showPic:) forControlEvents:UIControlEventTouchUpInside];
    [buttonInfo addTarget:viewController action:@selector(showInfo:) forControlEvents:UIControlEventTouchUpInside];
    [buttonComment addTarget:viewController action:@selector(showComment:) forControlEvents:UIControlEventTouchUpInside];
    [buttonLike addTarget:viewController action:@selector(submitLike:) forControlEvents:UIControlEventTouchUpInside];
    [buttonMap addTarget:viewController action:@selector(showMap:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:viewBackground.bounds];
    viewBackground.layer.masksToBounds = NO;
    viewBackground.layer.shadowColor = [UIColor blackColor].CGColor;
    viewBackground.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
    viewBackground.layer.shadowOpacity = 0.5f;
    viewBackground.layer.shadowRadius = 1.5f;
    viewBackground.layer.shadowPath = shadowPath.CGPath;
}
@end
