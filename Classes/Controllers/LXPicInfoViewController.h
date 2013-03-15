//
//  luxeysPicInfoViewController.h
//  Latte
//
//  Created by Xuan Dung Bui on 9/7/12.
//  Copyright (c) 2012 LUXEYS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LXCellDataField.h"
#import "LatteAPIClient.h"
#import "UIImageView+AFNetworking.h"
#import "LXAppDelegate.h"
#import "Picture.h"

@interface LXPicInfoViewController : UITableViewController

@property (strong, nonatomic) Picture *picture;

- (IBAction)touchBack:(id)sender;
@end
