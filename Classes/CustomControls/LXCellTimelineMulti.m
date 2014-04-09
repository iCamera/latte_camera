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


@implementation LXCellTimelineMulti

@synthesize buttonUser;
@synthesize scrollPic;
@synthesize labelTitle;
@synthesize labelUserDate;
@synthesize viewController;
@synthesize viewBackground;
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
    [buttonUser loadBackground:feed.user.profilePicture placeholderImage:@"user.gif"];
    
    for(UIView *subview in [scrollPic subviews]) {
        [subview removeFromSuperview];
    }
    
    CGSize size = CGSizeMake(6, 152);
    UIStoryboard *storyComponent = [UIStoryboard storyboardWithName:@"Component"
                                                             bundle:nil];
    for (Picture *pic in feed.targets) {
        
        LXTimelineMultiItemViewController *viewPic = [storyComponent instantiateViewControllerWithIdentifier:@"TimlineMultiPhoto"];
        
        viewPic.pic = pic;
        viewPic.parent = viewController;
        viewPic.view.frame = CGRectMake(size.width, 0, 152, 152);
        [scrollPic addSubview:viewPic.view];
        
        size.width += 158;
    }
    scrollPic.contentOffset = CGPointZero;
    scrollPic.contentSize = size;
    
    labelTitle.text = feed.user.name;
    labelUserDate.text = [LXUtils timeDeltaFromNow:feed.updatedAt];
    
    
    [LXUtils setNationalityOfUser:feed.user forImage:imageNationality nextToLabel:labelTitle];

    [buttonUser addTarget:viewController action:@selector(showUser:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)drawRect:(CGRect)rect {
    UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:viewBackground.bounds];
    viewBackground.layer.masksToBounds = NO;
    viewBackground.layer.shadowColor = [UIColor blackColor].CGColor;
    viewBackground.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
    viewBackground.layer.shadowOpacity = 0.5f;
    viewBackground.layer.shadowRadius = 3.0f;
    viewBackground.layer.shadowPath = shadowPath.CGPath;
    
    UIBezierPath *shadowPathPic = [UIBezierPath bezierPathWithRect:buttonUser.bounds];
    buttonUser.layer.masksToBounds = NO;
    buttonUser.layer.shadowColor = [UIColor blackColor].CGColor;
    buttonUser.layer.shadowOffset = CGSizeMake(0.0, 0.0);
    buttonUser.layer.shadowOpacity = 0.5f;
    buttonUser.layer.shadowRadius = 1.5f;
    buttonUser.layer.shadowPath = shadowPathPic.CGPath;
    buttonUser.layer.cornerRadius = 3.0;
    
    [super drawRect:rect];
}

@end
