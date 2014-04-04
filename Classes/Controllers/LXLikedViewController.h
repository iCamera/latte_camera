//
//  luxeysFav2ViewController.h
//  Latte
//
//  Created by Xuan Dung Bui on 2012/11/01.
//  Copyright (c) 2012年 LUXEYS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LXGalleryViewController.h"

@interface LXLikedViewController : UITableViewController<LXGalleryViewControllerDataSource>

@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *loadIndicator;

@end
