//
//  LXCellFont.m
//  Latte camera
//
//  Created by Bui Xuan Dung on 5/17/13.
//  Copyright (c) 2013 LUXEYS. All rights reserved.
//

#import "LXCellFont.h"

@implementation LXCellFont

@synthesize labelFontName;
@synthesize labelSample;

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
    [UIView animateWithDuration:0.3 animations:^{
        _viewSelectIndicator.alpha = selected;
    }];
    // Configure the view for the selected state
}

- (void)setFontInfo:(NSDictionary *)fontInfo {
    _fontInfo = fontInfo;
    labelSample.font = [UIFont fontWithName:fontInfo[@"font"] size:22];
    if (fontInfo[@"title2"]) {
        labelSample.text = fontInfo[@"title2"];
    } else
        labelSample.text = fontInfo[@"title"];
    labelFontName.text = fontInfo[@"title"];
}

@end
