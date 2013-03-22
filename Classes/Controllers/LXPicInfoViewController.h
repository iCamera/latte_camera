//
//  luxeysPicInfoViewController.h
//  Latte
//
//  Created by Xuan Dung Bui on 9/7/12.
//  Copyright (c) 2012 LUXEYS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Picture.h"
#import "LXGalleryViewController.h"

@interface LXPicInfoViewController : UITableViewController<UIAlertViewDelegate>

@property (strong, nonatomic) LXGalleryViewController *parent;
@property (strong, nonatomic) Picture *picture;
- (IBAction)touchReport:(id)sender;

- (IBAction)touchBack:(id)sender;
@end
