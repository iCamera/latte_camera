//
//  luxeysCellWelcomeMulti.m
//  Latte
//
//  Created by Xuan Dung Bui on 2012/11/06.
//  Copyright (c) 2012年 LUXEYS. All rights reserved.
//

#import "luxeysCellWelcomeMulti.h"

@implementation luxeysCellWelcomeMulti

@synthesize buttonUser;
@synthesize scrollPic;
@synthesize labelTitle;
@synthesize labelUserDate;
@synthesize viewController;

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
    
    CGSize size = CGSizeMake(6, 202);
    for (Picture *pic in feed.targets) {
        UIButton *buttonPic = [[UIButton alloc] initWithFrame:CGRectMake(size.width, 6, 190, 190)];
        buttonPic.layer.borderColor = [[UIColor whiteColor] CGColor];
        buttonPic.layer.borderWidth = 3;
        UIBezierPath *shadowPathPic = [UIBezierPath bezierPathWithRect:buttonPic.bounds];
        buttonPic.layer.masksToBounds = NO;
        buttonPic.layer.shadowColor = [UIColor blackColor].CGColor;
        buttonPic.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
        buttonPic.layer.shadowOpacity = 0.5f;
        buttonPic.layer.shadowRadius = 1.5f;
        buttonPic.layer.shadowPath = shadowPathPic.CGPath;
        
        [buttonPic loadBackground:pic.urlSquare];
        buttonPic.tag = [pic.pictureId integerValue];
        
        [buttonPic addTarget:viewController action:@selector(showPic:) forControlEvents:UIControlEventTouchUpInside];
        
        [scrollPic addSubview:buttonPic];
        size.width += 196;
    }
    scrollPic.contentSize = size;
    scrollPic.clipsToBounds = NO;
    buttonUser.clipsToBounds = YES;
    buttonUser.layer.cornerRadius = 3;
    buttonUser.tag = [feed.user.userId integerValue];
    
    labelTitle.text = [NSString stringWithFormat:@"写真を%d枚追加しました", feed.targets.count];
    labelUserDate.text = [NSString stringWithFormat:@"photo by %@ | %@", feed.user.name, [luxeysUtils timeDeltaFromNow:feed.updatedAt]];

    [buttonUser addTarget:viewController action:@selector(showUser:) forControlEvents:UIControlEventTouchUpInside];
}

@end
