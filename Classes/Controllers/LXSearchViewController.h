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

@interface LXSearchViewController : UITableViewController<LXGalleryViewControllerDataSource, UIScrollViewDelegate>
@property (strong, nonatomic) IBOutlet UIButton *buttonSearchPeople;
@property (strong, nonatomic) IBOutlet UIButton *buttonSearchPhoto;
@property (strong, nonatomic) IBOutlet LXButtonBrown30 *buttonSearch;
@property (strong, nonatomic) IBOutlet UITextField *textKeyword;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityLoad;
@property (strong, nonatomic) IBOutlet UIButton *buttonSearchTrend;
@property (strong, nonatomic) IBOutlet UIButton *buttonSearchLatest;
@property (strong, nonatomic) IBOutlet UIButton *buttonSearchCamera;
@property (strong, nonatomic) IBOutlet UIButton *buttonSearchLens;
@property (strong, nonatomic) IBOutlet UIView *viewHeader;

- (IBAction)touchTab:(UIButton *)sender;
- (IBAction)textChanged:(id)sender;
- (IBAction)editChanged:(id)sender;
- (IBAction)switchTab:(UIButton *)sender;

@end
