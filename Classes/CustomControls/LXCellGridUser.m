//
//  LXCellGridUser.m
//  Latte camera
//
//  Created by Bui Xuan Dung on 4/16/13.
//  Copyright (c) 2013 LUXEYS. All rights reserved.
//

#import "LXCellGridUser.h"
#import "User.h"
#import "UIButton+AsyncImage.h"
#import "LXUtils.h"

@implementation LXCellGridUser

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

- (void)setUsers:(NSArray *)users forRow:(NSInteger)row {
    for(UIView *subview in [self subviews]) {
        [subview removeFromSuperview];
    }
    
    for (int i = 0; i < 5; ++i)
    {
        NSInteger index = row*5+i;
        
        User *user;
        if (index >= users.count)
            break;
        user = users[index];
        
        UIView *viewWrap = [[UIView alloc] initWithFrame:CGRectMake(6 + 64*i, 3, 50, 50)];
        UIButton *button = [[UIButton alloc] initWithFrame:viewWrap.bounds];
        
        [button loadBackground:user.profilePicture placeholderImage:@"user.gif"];
        
        button.tag = index;
        [button addTarget:_viewController action:@selector(showUser:) forControlEvents:UIControlEventTouchUpInside];
        
        UIView *viewBg = [[UIView alloc] initWithFrame:CGRectMake(0, 34, 50, 16)];
        viewBg.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
        viewBg.userInteractionEnabled = NO;
        
        UILabel *labelUser = [[UILabel alloc] initWithFrame:CGRectMake(3, 34, 44, 16)];
        labelUser.textAlignment = NSTextAlignmentCenter;
        labelUser.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:10];
        labelUser.textColor = [UIColor whiteColor];
        labelUser.shadowColor = [UIColor blackColor];
        labelUser.shadowOffset = CGSizeMake(0, 1);
        labelUser.backgroundColor = [UIColor clearColor];
        labelUser.minimumFontSize = 5;
        labelUser.userInteractionEnabled = NO;
        
        labelUser.text = user.name;
        
        [viewWrap addSubview:button];
        [viewWrap addSubview:viewBg];
        [viewWrap addSubview:labelUser];
        viewWrap.layer.masksToBounds = YES;
        [LXUtils globalShadow:viewWrap];
        viewWrap.layer.cornerRadius = 5.0;
        
        [self addSubview:viewWrap];
    }
}


@end
