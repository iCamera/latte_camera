//
//  LXPrivacySettingTableViewCell.h
//  Latte camera
//
//  Created by Juan Tabares on 6/4/14.
//  Copyright (c) 2014 LUXEYS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"

@interface LXPrivacySettingTableViewCell : UITableViewCell
@property (strong, nonatomic) NSString *key;
@property (nonatomic) NSNumber *currentSetting;

- (PictureStatus)permissionStatus;
@end
