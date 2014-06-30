//
//  luxeysRightSideViewController.m
//  Latte
//
//  Created by Xuan Dung Bui on 8/17/12.
//  Copyright (c) 2012 LUXEYS. All rights reserved.
//

#import "LXNotifySideViewController.h"

#import "LXAppDelegate.h"
#import "LatteAPIClient.h"
#import "LXCellNotify.h"
#import "LXCellNotifyOfficial.h"
#import "LXGalleryViewController.h"
#import "LXUserPageViewController.h"
#import "Comment.h"
#import "User.h"
#import "Picture.h"
#import "MBProgressHUD.h"
#import "LXNavigationController.h"
#import "MZFormSheetController.h"

#import "REFrostedViewController.h"

@interface LXNotifySideViewController ()

@end

@implementation LXNotifySideViewController {
    NSMutableArray *notifies;
    
    NSInteger page;
    NSInteger limit;
    NSInteger currentTab;
    BOOL loadEnded;
    
    AFHTTPRequestOperation *currentRequest;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveLoggedIn:) name:@"LoggedIn" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(becomeActive:) name:@"BecomeActive" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(becomeActive:) name:@"ReceivedPushNotify" object:nil];
    
    // This will remove extra separators from tableview
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    // Do any additional setup after loading the view from its nib.

    limit = 30;
    
    [self loadNotify:YES setRead:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (notifies.count > 0 && !loadEnded) {
        return notifies.count + 1;
    } else {
        return notifies.count;
    }
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == notifies.count) {
        [self loadNotify:NO setRead:NO];
        UITableViewCell* cellNotify = [tableView dequeueReusableCellWithIdentifier:@"Load" forIndexPath:indexPath];
        return cellNotify;
    }
    
    LXCellNotify* cellNotify = nil;
    if (currentTab == 4) {
        cellNotify = [tableView dequeueReusableCellWithIdentifier:@"NotifyOfficial" forIndexPath:indexPath];
    } else {
        cellNotify = [tableView dequeueReusableCellWithIdentifier:@"Notify" forIndexPath:indexPath];
    }

    NSDictionary *notify = [notifies objectAtIndex:indexPath.row];
    [cellNotify setNotify:notify];
    return cellNotify;
}

- (void)reloadView {
    
    [self loadNotify:YES setRead:NO];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    self.tabBarItem.badgeValue = nil;
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
}

- (void)loadNotify:(BOOL)reset setRead:(BOOL)setRead {
    if (reset) {
        loadEnded = false;
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        
        page = 1;
        if (currentRequest && currentRequest.isExecuting)
            [currentRequest cancel];
    } else {
        if (currentRequest && currentRequest.isExecuting)
            return;
    }
    
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                           [NSNumber numberWithInteger:page], @"page",
                           [NSNumber numberWithInteger:limit], @"limit",
                           [NSNumber numberWithInteger:currentTab], @"tab",
                           nil];

    currentRequest = [[LatteAPIClient sharedClient] GET:@"user/me/notify"
                                      parameters: params
                                         success:^(AFHTTPRequestOperation *operation, NSDictionary *JSON) {
                                             page += 1;
                                             
                                             NSArray *newData = [JSON objectForKey:@"notifies"];
                                             
                                             loadEnded = newData.count == 0;
                                             
                                             if (reset) {
                                                 if (setRead) {
                                                     // Reset count
                                                     [[LatteAPIClient sharedClient] POST:@"user/me/read_notify" parameters:nil success:nil failure:nil];
                                                 }
                                                 
                                                 notifies = [NSMutableArray arrayWithArray:newData];
                                                 [MBProgressHUD hideHUDForView:self.view animated:YES];
                                             } else {
                                                 [notifies addObjectsFromArray:newData];
                                             }
                                             
                                             [self.tableView reloadData];

                                             [self.refreshControl endRefreshing];
                                         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                             loadEnded = true;
                                             [self.tableView reloadData];
                                             if (reset) {
                                                 [MBProgressHUD hideHUDForView:self.view animated:YES];
                                             }
                                             [self.refreshControl endRefreshing];
                                         }];
}

- (void)receiveLoggedIn:(NSNotification *) notification {
    [self reloadView];
}

- (void)becomeActive:(NSNotification *) notification {
    [[LatteAPIClient sharedClient] GET:@"user/me/unread_notify" parameters: nil success:^(AFHTTPRequestOperation *operation, NSDictionary *JSON) {
        NSInteger count = [JSON[@"notify_count"] integerValue];
        if (count > 0) {
            self.tabBarItem.badgeValue = [JSON[@"notify_count"] stringValue];
            [self reloadView];
        } else {
            self.tabBarItem.badgeValue = nil;
        }
        
    } failure: nil];
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *notify = notifies[indexPath.row];
    NotifyTarget notifyTarget = [[notify objectForKey:@"target_model"] integerValue];
    
    if (currentTab == 4 && !notifyTarget) {
                //For Animation
        [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        return;
    }
    
    switch (notifyTarget) {
        case kNotifyTargetComment: {
            Comment *comment = [Comment instanceFromDictionary:[notify objectForKey:@"target"]];
            
            if (comment.pictureId != nil) {
                NSString *urlDetail = [NSString stringWithFormat:@"picture/%ld", [comment.pictureId longValue]];
                MBProgressHUD *hud = [[MBProgressHUD alloc]initWithView:self.view];

                hud.mode = MBProgressHUDModeIndeterminate;
                [hud show:YES];
                
                [[LatteAPIClient sharedClient] GET:urlDetail parameters: nil success:^(AFHTTPRequestOperation *operation, NSDictionary *JSON) {
                    [hud hide:YES];
                    
                    UIStoryboard *storyGallery = [UIStoryboard storyboardWithName:@"Gallery"
                                                                           bundle:nil];
                    UINavigationController *navGalerry = [storyGallery instantiateInitialViewController];
                    LXGalleryViewController *viewGallery = navGalerry.viewControllers[0];
                    
                    viewGallery.user = [User instanceFromDictionary:[JSON objectForKey:@"user"]];
                    viewGallery.picture = [Picture instanceFromDictionary:[JSON objectForKey:@"picture"]];
                    viewGallery.delegate = self;
                } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                    [hud hide:YES];
                    DLog(@"Something went wrong Notify Gallery");
                    
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"error", "Error")
                                                                    message:error.localizedDescription
                                                                   delegate:nil
                                                          cancelButtonTitle:NSLocalizedString(@"close", "Close")
                                                          otherButtonTitles:nil];
                    [alert show];
                }];
            }
            
            break;
        }
        case kNotifyTargetPicture: {
            Picture *pic = [Picture instanceFromDictionary:[notify objectForKey:@"target"]];
            
            UIStoryboard *storyGallery = [UIStoryboard storyboardWithName:@"Gallery"
                                                                   bundle:nil];
            UINavigationController *navGalerry = [storyGallery instantiateInitialViewController];
            LXGalleryViewController *viewGallery = navGalerry.viewControllers[0];
            viewGallery.picture = pic;
            viewGallery.delegate = self;
            [self presentViewController:navGalerry animated:YES completion:nil];
            break;
        }
        case kNotifyTargetUser: {
            LXAppDelegate *app = [LXAppDelegate currentDelegate];
            UINavigationController *currentNav = (UINavigationController*)app.viewMainTab.selectedViewController;
            User *user = [User instanceFromDictionary:[notify objectForKey:@"target"]];
            
            UIStoryboard *storyGallery = [UIStoryboard storyboardWithName:@"MainStoryboard"
                                                                   bundle:nil];
            LXUserPageViewController  *viewMypage = [storyGallery instantiateViewControllerWithIdentifier:@"UserPage"];
            viewMypage.user = user;
            [currentNav pushViewController:viewMypage animated:YES];
            break;
        }
        default:
            break;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (currentTab != 4) {
        return 45;
    }
    
	// If our cell is selected, return double height
    for (NSIndexPath *path in tableView.indexPathsForSelectedRows) {
        if (indexPath.row == path.row) {
            NSDictionary *notify = [notifies objectAtIndex:indexPath.row];
            NSString *note = [notify objectForKey:@"note"];
            CGSize labelSize = [note sizeWithFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:11]
                                constrainedToSize:CGSizeMake(310.0, MAXFLOAT)
                                    lineBreakMode:NSLineBreakByTruncatingTail];
            
            if (labelSize.height > 90) {
                return labelSize.height + 75;
            }
        }
    }
   
    return 90;
}

- (IBAction)switchTab:(UISegmentedControl *)sender {
    currentTab = sender.selectedSegmentIndex;
    [self loadNotify:YES setRead:YES];
}

- (IBAction)refresh:(id)sender {
    [self loadNotify:YES setRead:YES];
}

- (IBAction)showSetting:(id)sender {
    UIStoryboard *storySetting = [UIStoryboard storyboardWithName:@"Setting" bundle:nil];
    UIViewController *settingNotification = [storySetting instantiateViewControllerWithIdentifier:@"Notification"];
    
    // present form sheet with view controller
    MZFormSheetController *formSheet = [[MZFormSheetController alloc] initWithViewController:settingNotification];
    
    formSheet.cornerRadius = 0;
    formSheet.shouldDismissOnBackgroundViewTap = YES;
    
    [self mz_presentFormSheetController:formSheet animated:YES completionHandler:^(MZFormSheetController *formSheetController) {
        //do sth
    }];
}

- (IBAction)showMenu
{
    // Dismiss keyboard (optional)
    //
    [self.view endEditing:YES];
    [self.frostedViewController.view endEditing:YES];
    
    // Present the view controller
    //
    [self.frostedViewController presentMenuViewController];
}

@end
