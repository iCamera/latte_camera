//
//  LXPicDumbTabViewController.h
//  Latte camera
//
//  Created by Bui Xuan Dung on 3/21/13.
//  Copyright (c) 2013 LUXEYS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Picture.h"

@interface LXPicDumbTabViewController : UITableViewController<UISearchBarDelegate>

@property (strong, nonatomic) NSMutableArray *tags;
@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;
- (IBAction)touchDone:(id)sender;

@end
