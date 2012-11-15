//
//  luxeysCellWelcomeSingle.m
//  Latte
//
//  Created by Xuan Dung Bui on 2012/11/06.
//  Copyright (c) 2012年 LUXEYS. All rights reserved.
//

#import "luxeysCellWelcomeSingle.h"

@implementation luxeysCellWelcomeSingle

@synthesize viewController;

@synthesize labelTitle;
@synthesize labelUser;
@synthesize labelAccess;
@synthesize buttonPic;
@synthesize buttonUser;

@synthesize labelComment;
@synthesize labelLike;
@synthesize viewStat;
@synthesize viewPic;
@synthesize buttonComment;
@synthesize buttonInfo;
@synthesize buttonMap;
@synthesize buttonLike;

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
    Picture *pic = feed.targets[0];
    CGRect frame = buttonPic.frame;
    frame.size.height = [luxeysUtils heightFromWidth:300 width:[pic.width floatValue] height:[pic.height floatValue]];
    buttonPic.frame = frame;
    buttonPic.layer.borderColor = [[UIColor whiteColor] CGColor];
    buttonPic.layer.borderWidth = 3;
    UIBezierPath *shadowPathPic = [UIBezierPath bezierPathWithRect:buttonPic.bounds];
    buttonPic.layer.masksToBounds = NO;
    buttonPic.layer.shadowColor = [UIColor blackColor].CGColor;
    buttonPic.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
    buttonPic.layer.shadowOpacity = 0.5f;
    buttonPic.layer.shadowRadius = 1.5f;
    buttonPic.layer.shadowPath = shadowPathPic.CGPath;
    [buttonPic loadBackground:pic.urlMedium];
    viewStat.frame = CGRectMake(0, 0, viewStat.frame.size.width, frame.size.height + 85);
    viewPic.frame = CGRectMake(0, 0, viewStat.frame.size.width, frame.size.height + 49);

    [viewPic setNeedsDisplay];
    [viewStat setNeedsDisplay];
    
    buttonPic.tag = [pic.pictureId integerValue];
    buttonLike.tag = [pic.pictureId integerValue];
    buttonMap.tag = [pic.pictureId integerValue];
    buttonInfo.tag = [pic.pictureId integerValue];
    buttonComment.tag = [pic.pictureId integerValue];

    labelAccess.text = [pic.pageviews stringValue];
    labelLike.text = [pic.voteCount stringValue];
    labelComment.text = [pic.commentCount stringValue];

    if (pic.canVote)
        if (!pic.isVoted)
            buttonLike.enabled = YES;
    
    if (pic.canComment) {
        buttonComment.enabled = YES;
    }
    
    if ((pic.latitude != nil) && (pic.longitude != nil)) {
        buttonMap.enabled = YES;
    }
    
    buttonUser.clipsToBounds = YES;
    buttonUser.layer.cornerRadius = 3;
    buttonUser.tag = [feed.user.userId integerValue];
    [buttonUser loadBackground:feed.user.profilePicture placeholderImage:@"user.gif"];
    if (pic.title.length > 0)
        labelTitle.text = pic.title;
    else
        labelTitle.text = @"タイトルなし";
    labelUser.text = [NSString stringWithFormat:@"photo by %@ | %@", feed.user.name, [luxeysUtils timeDeltaFromNow:feed.updatedAt]];
    
    self.clipsToBounds = NO;
    
    [buttonUser addTarget:viewController action:@selector(showUser:) forControlEvents:UIControlEventTouchUpInside];
    [buttonPic addTarget:viewController action:@selector(showPic:) forControlEvents:UIControlEventTouchUpInside];
    [buttonInfo addTarget:viewController action:@selector(showInfo:) forControlEvents:UIControlEventTouchUpInside];
    [buttonComment addTarget:viewController action:@selector(showComment:) forControlEvents:UIControlEventTouchUpInside];
    [buttonLike addTarget:viewController action:@selector(submitLike:) forControlEvents:UIControlEventTouchUpInside];
    [buttonMap addTarget:viewController action:@selector(showMap:) forControlEvents:UIControlEventTouchUpInside];
}

@end
