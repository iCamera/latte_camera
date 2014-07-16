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
#import "LXPicCommentViewController.h"
#import "LXPicVoteCollectionController.h"
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

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    self.tabBarItem.badgeValue = nil;
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;

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
        cellNotify.parent = self;
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
    
    self.tabBarItem.badgeValue = @"";
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    [[LatteAPIClient sharedClient] POST:@"user/me/read_notify" parameters:nil success:nil failure:nil];
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
    [self reloadView];
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSMutableDictionary *notify = notifies[indexPath.row];
    notify[@"read"] = [NSNumber numberWithBool:YES];
    [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    
    NotifyTarget notifyTarget = [[notify objectForKey:@"target_model"] integerValue];
    NotifyKind notifyKind = [[notify objectForKey:@"kind"] integerValue];
    
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
                [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                
                [[LatteAPIClient sharedClient] GET:urlDetail parameters: nil success:^(AFHTTPRequestOperation *operation, NSDictionary *JSON) {
                    [MBProgressHUD hideHUDForView:self.view animated:YES];
                    
                    UIStoryboard *storyGallery = [UIStoryboard storyboardWithName:@"Gallery"
                                                                           bundle:nil];
                    LXPicCommentViewController *viewComment = [storyGallery instantiateViewControllerWithIdentifier:@"Comment"];
                    viewComment.commentId = [comment.commentId integerValue];
                    Picture *picture = [Picture instanceFromDictionary:[JSON objectForKey:@"picture"]];
                    picture.comments = [Comment mutableArrayFromDictionary:JSON withKey:@"comments"];
                    viewComment.picture = picture;
                    
                    
                    [self.navigationController pushViewController:viewComment animated:YES];
                } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                    [MBProgressHUD hideHUDForView:self.view animated:YES];
                }];
            }
            
            break;
        }
        case kNotifyTargetPicture: {
            Picture *pic = [Picture instanceFromDictionary:[notify objectForKey:@"target"]];
            
            UIStoryboard *storyGallery = [UIStoryboard storyboardWithName:@"Gallery"
                                                                   bundle:nil];
            
            if (notifyKind == kNotifyKindComment) {
                LXPicCommentViewController *viewComment = [storyGallery instantiateViewControllerWithIdentifier:@"Comment"];
                viewComment.picture = pic;
                [self.navigationController pushViewController:viewComment animated:YES];
            }
            
            if (notifyKind == kNotifyKindLike) {
                LXPicVoteCollectionController *viewVote = [storyGallery instantiateViewControllerWithIdentifier:@"Like"];
                viewVote.picture = pic;
                [self.navigationController pushViewController:viewVote animated:YES];
            }

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
        return 60;
    }
    
	// If our cell is selected, return double height
    for (NSIndexPath *path in tableView.indexPathsForSelectedRows) {
        if (indexPath.row == path.row) {
            NSDictionary *notify = [notifies objectAtIndex:indexPath.row];
            NSString *note = [notify objectForKey:@"note"];
            
            CGRect stringRect = [note boundingRectWithSize:CGSizeMake(310.0, CGFLOAT_MAX)
                                                                 options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading)
                                                              attributes:@{ NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue-Light" size:12] }
                                                                 context:nil];
            
            return stringRect.size.height + 54;
        }
    }
   
    return 90;
}

- (IBAction)switchTab:(UIButton *)sender {
    [UIView transitionWithView:self.tableView.tableHeaderView
                      duration:kGlobalAnimationSpeed
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{
                        _buttonTabAll.selected = NO;
                        _buttonTabAnnouncement.selected = NO;
                        _buttonTabComment.selected = NO;
                        _buttonTabFollow.selected = NO;
                        _buttonTabLike.selected = NO;
                        sender.selected = YES;
                    }
                    completion:nil];
    
    currentTab = sender.tag;
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
