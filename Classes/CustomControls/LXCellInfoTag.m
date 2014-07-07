//
//  LXCellInfoTag.m
//  Latte camera
//
//  Created by Bui Xuan Dung on 3/21/13.
//  Copyright (c) 2013 LUXEYS. All rights reserved.
//

#import "LXCellInfoTag.h"
#import "LXTagHome.h"
#import "MZFormSheetController.h"

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
    CGSize size = CGSizeMake(6, 36);
    for (UIView *subview in scrollTag.subviews) {
        [subview removeFromSuperview];
    }
    for (NSString *tag in tags) {
        UIFont *font = [UIFont fontWithName:@"HelveticaNeue-Light" size:12];
        CGSize textSize = [tag sizeWithAttributes:@{ NSFontAttributeName : font }];
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(size.width, 8, textSize.width + 12, 22)];
        button.titleLabel.font = font;
        [button setTitle:tag forState:UIControlStateNormal];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [button setBackgroundColor:[UIColor colorWithRed:105.0/255.0 green:205.0/255.0 blue:117.0/255.0 alpha:1]];
        button.layer.cornerRadius = 3;
        size.width += textSize.width + 20;
        
        [button addTarget:self action:@selector(showNormalTag:) forControlEvents:UIControlEventTouchUpInside];
        button.tag = [tags indexOfObject:tag];
        [scrollTag addSubview:button];
    }
    scrollTag.contentSize = size;
}

- (void)showNormalTag:(UIButton*)button {
    UIStoryboard *storyMain = [UIStoryboard storyboardWithName:@"MainStoryboard"
                                                        bundle:nil];

    LXTagHome *viewTag = [storyMain instantiateViewControllerWithIdentifier:@"TagHome"];
    viewTag.tag = _tags[button.tag];
    viewTag.title = _tags[button.tag];

    if (_isModal) {
        [_parent mz_dismissFormSheetControllerAnimated:YES completionHandler:^(MZFormSheetController *formSheetController) {
            [_parent.navigationController pushViewController:viewTag animated:YES];
        }];
    } else {
        [_parent.navigationController pushViewController:viewTag animated:YES];
    }
}

@end
