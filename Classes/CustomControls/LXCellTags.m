//
//  LXCellags.m
//  Latte camera
//
//  Created by Bui Xuan Dung on 3/26/13.
//  Copyright (c) 2013 LUXEYS. All rights reserved.
//

#import "LXCellTags.h"
#import "STTweetLabel.h"
#import "LXUtils.h"

@implementation LXCellTags

@synthesize buttonTag;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)drawRect:(CGRect)rect {
    [LXUtils globalShadow:buttonTag];
    buttonTag.layer.cornerRadius = 5.0;
    [super drawRect:rect];
}


@end
