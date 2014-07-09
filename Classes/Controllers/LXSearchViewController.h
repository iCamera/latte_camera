//
//  LXSearchViewController.h
//  Latte camera
//
//  Created by Bui Xuan Dung on 3/8/13.
//  Copyright (c) 2013 LUXEYS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LXGalleryViewController.h"
#import "LXButtonBrown30.h"

@interface LXSearchViewController : UITableViewController<LXGalleryViewControllerDataSource, UIScrollViewDelegate, UISearchDisplayDelegate, UISearchBarDelegate>

@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityLoad;

@end
