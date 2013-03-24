//
//  LXCellSearchConnection.m
//  Latte camera
//
//  Created by Xuan Dung Bui on 2013/03/25.
//  Copyright (c) 2013年 LUXEYS. All rights reserved.
//

#import "LXCellSearchConnection.h"
#import "LXAppDelegate.h"
#import "LXShare.h"

@implementation LXCellSearchConnection {
    LXShare *lxShare;
}

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

- (IBAction)touchInvite:(id)sender {
    lxShare = [[LXShare alloc] init];
    lxShare.controller = _controller;
    [lxShare inviteFriend];
}
@end
