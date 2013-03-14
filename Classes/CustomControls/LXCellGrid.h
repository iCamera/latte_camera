//
//  LXCellGrid.h
//  Latte camera
//
//  Created by Bui Xuan Dung on 3/13/13.
//  Copyright (c) 2013 LUXEYS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LXCellGrid : UITableViewCell

@property (assign, nonatomic) id viewController;

- (void)setPictures:(NSArray *)pictures forRow:(NSInteger)row;

@end
