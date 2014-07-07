//
//  LXCellInfoTag.h
//  Latte camera
//
//  Created by Bui Xuan Dung on 3/21/13.
//  Copyright (c) 2013 LUXEYS. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "LXGalleryViewController.h"

@interface LXCellInfoTag : UITableViewCell
@property (strong, nonatomic) IBOutlet UIScrollView *scrollTag;
@property (strong, nonatomic) NSArray *tags;

@property (assign, nonatomic) BOOL isModal;
@property (weak, nonatomic) UIViewController *parent;

@end
