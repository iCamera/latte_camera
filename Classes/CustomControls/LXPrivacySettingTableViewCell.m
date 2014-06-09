//
//  LXPrivacySettingTableViewCell.m
//  Latte camera
//
//  Created by Juan Tabares on 6/4/14.
//  Copyright (c) 2014 LUXEYS. All rights reserved.
//

#import "LXPrivacySettingTableViewCell.h"

@implementation LXPrivacySettingTableViewCell

@synthesize key;
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

- (PictureStatus)permissionStatus
{
    return (PictureStatus)[_currentSetting integerValue];
}

- (void)setCurrentSetting:(NSNumber *)currentSetting
{
   _currentSetting = currentSetting;
    if ([self permissionStatus] == PictureStatusPrivate) {
        self.detailTextLabel.text = NSLocalizedString(@"status_private", @"Only Me");
    } else if ([self permissionStatus] == PictureStatusFriendsOnly) {
        self.detailTextLabel.text = NSLocalizedString(@"status_friends", @"Mutual Follow");
    } else if ([self permissionStatus] == PictureStatusMember) {
        self.detailTextLabel.text = NSLocalizedString(@"status_members", @"Members");
    } else if ([self permissionStatus] == PictureStatusPublic) {
        self.detailTextLabel.text = NSLocalizedString(@"status_public", @"Public");
    } else {
        self.detailTextLabel.text = @"";
    }
}


@end
