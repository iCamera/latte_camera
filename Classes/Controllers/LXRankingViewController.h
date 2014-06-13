//
//  luxeysRankingViewController.h
//  Latte
//
//  Created by Xuan Dung Bui on 9/4/12.
//  Copyright (c) 2012 LUXEYS. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "LXGalleryViewController.h"

@interface LXRankingViewController : UITableViewController <LXGalleryViewControllerDataSource, UIToolbarDelegate>

@property (strong, nonatomic) IBOutlet UIButton *buttonDaily;
@property (strong, nonatomic) IBOutlet UIButton *buttonWeekly;
@property (strong, nonatomic) IBOutlet UIButton *buttonMonthly;
@property (strong, nonatomic) IBOutlet UIButton *buttonCalendar;
@property (strong, nonatomic) IBOutlet UIView *viewTab;
@property (strong, nonatomic) IBOutlet UISegmentedControl *segmentView;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *loadIndicator;
@property (strong, nonatomic) IBOutlet UIButton *buttonAreaLocal;
@property (strong, nonatomic) IBOutlet UIButton *buttonAreaWorld;

- (IBAction)showMenu;
- (IBAction)touchTab:(UISegmentedControl*)sender;
- (IBAction)touchArea:(UIButton*)sender;
- (IBAction)refresh:(id)sender;
- (void)reloadView;
@end
