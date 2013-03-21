//
//  LXCellInfoTag.m
//  Latte camera
//
//  Created by Bui Xuan Dung on 3/21/13.
//  Copyright (c) 2013 LUXEYS. All rights reserved.
//

#import "LXCellInfoTag.h"
#import "LXTagViewController.h"

@implementation LXCellInfoTag

@synthesize scrollTag;

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

- (void)setTags:(NSArray *)tags {
    _tags = tags;
    CGSize size = CGSizeMake(6, 40);
    for (NSString *tag in tags) {
        UIFont *font = [UIFont fontWithName:@"HelveticaNeue-Light" size:14];
        CGSize textSize = [tag sizeWithFont:font];
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(size.width, 0, textSize.width, 40)];
        button.titleLabel.font = font;
        [button setTitle:tag forState:UIControlStateNormal];
        [button setTitleColor:[UIColor colorWithRed:30.0/255.0 green:90.0/255.0 blue:136.0/255.0 alpha:1.0] forState:UIControlStateNormal];
        size.width += textSize.width + 6 + 6;
        [button addTarget:self action:@selector(showNormalTag:) forControlEvents:UIControlEventTouchUpInside];
        button.tag = [tags indexOfObject:tag];
        [scrollTag addSubview:button];
    }
    scrollTag.contentSize = size;
}

- (void)showNormalTag:(UIButton*)button {
    UIStoryboard *storyMain = [UIStoryboard storyboardWithName:@"MainStoryboard"
                                                        bundle:nil];
    LXTagViewController *viewTag = [storyMain instantiateViewControllerWithIdentifier:@"Tag"];
    viewTag.keyword = _tags[button.tag];
    [_parent.navigationController pushViewController:viewTag animated:YES];
}

@end
