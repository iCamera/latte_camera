//
//  luxeysRankingViewController.h
//  Latte
//
//  Created by Xuan Dung Bui on 9/4/12.
//  Copyright (c) 2012 LUXEYS. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "LXGalleryViewController.h"
#import "LXTabButton.h"

@interface LXRankingViewController : UITableViewController <LXGalleryViewControllerDataSource, UIToolbarDelegate>


@property (strong, nonatomic) IBOutlet UIView *viewTab;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *loadIndicator;
@property (strong, nonatomic) IBOutlet UIImageView *imageNopict;
@property (strong, nonatomic) IBOutlet LXTabButton *buttonTabCalendar;
@property (strong, nonatomic) IBOutlet LXTabButton *buttonTabTrend;
@property (strong, nonatomic) IBOutlet LXTabButton *buttonTabDaily;
@property (strong, nonatomic) IBOutlet LXTabButton *buttonTabWeekly;

@property (strong, nonatomic) IBOutlet UIButton *buttonCountry;

- (IBAction)showMenu;
- (IBAction)touchTab:(UIButton*)sender;
- (IBAction)refresh:(id)sender;
- (void)reloadView;
@end
