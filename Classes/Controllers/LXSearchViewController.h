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
#import "LXNotificationBar.h"

typedef enum {
    kSearchPhoto,
    kSearchUser,
    kSearchTag,
} SearchView;

@interface LXSearchViewController : UITableViewController<LXGalleryViewControllerDataSource, UIScrollViewDelegate, UISearchBarDelegate>
@property (weak, nonatomic) IBOutlet UIButton *buttonPhoto;
@property (weak, nonatomic) IBOutlet UIButton *buttonUser;
@property (weak, nonatomic) IBOutlet UIButton *buttonTag;

@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityLoad;
@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;

@property (assign, nonatomic) SearchView searchView;
@property (weak, nonatomic) IBOutlet LXNotificationBar *viewNotification;

- (IBAction)switchTab:(UIButton *)sender;
- (IBAction)showMenu:(id)sender;

@end
