//
//  LXCellNotifyOfficial.h
//  Latte camera
//
//  Created by Serkan Unal on 6/4/14.
//  Copyright (c) 2014 LUXEYS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"
#import "Picture.h"

@interface LXCellNotifyOfficial : UITableViewCell
@property (strong, nonatomic) IBOutlet UIImageView *viewImage;
@property (strong, nonatomic) IBOutlet UILabel *labelDate;
@property (strong, nonatomic) IBOutlet UILabel *labelTitle;
@property (strong, nonatomic) IBOutlet UILabel *labelNote;

- (void)setNotify:(NSDictionary *)notify;

@end



