//
//  LXCellPicker.m
//  Latte camera
//
//  Created by Serkan Unal on 6/20/14.
//  Copyright (c) 2014 LUXEYS. All rights reserved.
//

#import "LXCellPicker.h"

@implementation LXCellPicker

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
