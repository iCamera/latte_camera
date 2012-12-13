//
//  luxeysCellProfile.m
//  Latte
//
//  Created by Xuan Dung Bui on 8/27/12.
//  Copyright (c) 2012 LUXEYS. All rights reserved.
//

#import "LXCellDataField.h"

@implementation LXCellDataField
@synthesize labelField;
@synthesize labelDetail;

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
