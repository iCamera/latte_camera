//
//  luxeysCell4Pics.m
//  Latte
//
//  Created by Xuan Dung Bui on 2012/09/19.
//  Copyright (c) 2012年 LUXEYS. All rights reserved.
//

#import "luxeysCell4Pics.h"

@implementation luxeysCell4Pics
@synthesize buttonPic1;
@synthesize buttonPic2;
@synthesize buttonPic3;
@synthesize buttonPic4;

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

@end
