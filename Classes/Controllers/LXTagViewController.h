//
//  LXTagViewController.h
//  Latte camera
//
//  Created by Bui Xuan Dung on 3/13/13.
//  Copyright (c) 2013 LUXEYS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LXGalleryViewController.h"

@interface LXTagViewController : UITableViewController<LXGalleryViewControllerDataSource, UIScrollViewDelegate>

@property (strong, nonatomic) NSString *keyword;

@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityLoad;

@end
