//
//  luxeysCellNotify.h
//  Latte
//
//  Created by Xuan Dung Bui on 2012/10/01.
//  Copyright (c) 2012年 LUXEYS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LuxeysUser.h"
#import "LuxeysPicture.h"

@interface luxeysCellNotify : UITableViewCell {
    LuxeysPicture *pic;
    NSArray *users;
}
@property (strong, nonatomic) IBOutlet UIImageView *viewImage;
@property (strong, nonatomic) IBOutlet UILabel *labelNotify;

- (void)setNotify:(NSDictionary *)notify;

@end
