//
//  luxeysButtonNormal.m
//  Latte
//
//  Created by Xuan Dung Bui on 8/10/12.
//  Copyright (c) 2012 LUXEYS. All rights reserved.
//

#import "LXButtonNormal.h"

@implementation LXButtonNormal

- (void)setButtonFont {
    self.titleLabel.textColor = [UIColor whiteColor];
    self.titleLabel.shadowColor = [UIColor colorWithRed:0.4 green:0.36 blue:0.21 alpha:1];
    self.titleLabel.shadowOffset = CGSizeMake(1.0, 1.0);
}


- (void)awakeFromNib
{
    [super awakeFromNib];
    [self setButtonFont];
    
    UIImage *stateNormal = [[UIImage imageNamed:@"bt_normal.png"] stretchableImageWithLeftCapWidth:5 topCapHeight:5];
    [self setBackgroundImage:stateNormal forState:UIControlStateNormal];
    
    UIImage *stateHighlight = [[UIImage imageNamed:@"bt_normal_on.png"] stretchableImageWithLeftCapWidth:5 topCapHeight:5];
    [self setBackgroundImage:stateHighlight forState:UIControlStateHighlighted];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id)init {
    self = [super init];
    if (self) {
        
        [self setButtonFont];
    }
    return self;
}

@end
