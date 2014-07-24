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

- (void)setFollowingTags:(NSArray *)followingTags {
    _followingTags = followingTags;
    scrollTag.followingTags = _followingTags;
}

- (void)setTags:(NSArray *)tags {
    _tags = tags;
    scrollTag.parent = self;
    scrollTag.tags = tags;
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
