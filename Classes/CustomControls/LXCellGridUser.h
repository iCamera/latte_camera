//
//  LXCellGridUser.h
//  Latte camera
//
//  Created by Bui Xuan Dung on 4/16/13.
//  Copyright (c) 2013 LUXEYS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LXCellGridUser : UITableViewCell

@property (assign, nonatomic) id viewController;

- (void)setUsers:(NSArray *)users forRow:(NSInteger)row;

@end
