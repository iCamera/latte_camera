//
//  luxeysCellNotify.h
//  Latte
//
//  Created by Xuan Dung Bui on 2012/10/01.
//  Copyright (c) 2012年 LUXEYS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"
#import "Picture.h"

@interface luxeysCellNotify : UITableViewCell
@property (strong, nonatomic) IBOutlet UIImageView *viewImage;
@property (strong, nonatomic) IBOutlet UILabel *labelNotify;

- (void)setNotify:(NSDictionary *)notify;

@end
