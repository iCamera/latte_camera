//
//  luxeysWelcomeViewController.m
//  Latte
//
//  Created by Xuan Dung Bui on 8/8/12.
//  Copyright (c) 2012 LUXEYS. All rights reserved.
//

#import "LXWelcomeViewController.h"
#import "LXAppDelegate.h"
#import "LXMyPageViewController.h"
#import "LXPicInfoViewController.h"
#import "LXPicCommentViewController.h"
#import "LXPicMapViewController.h"
#import "LXVoteViewController.h"
#import "LXCellGrid.h"
#import "Comment.h"

typedef enum {
    kWelcomeTableTimeline,
    kWelcomeTableGrid,
} WelcomeTableMode;

@interface LXWelcomeViewController ()
@end

@implementation LXWelcomeViewController {
    NSMutableArray *feeds;
    int pagephoto;
    BOOL loadEnded;
    BOOL reloading;
    EGORefreshTableHeaderView *refreshHeaderView;
    UIPanGestureRecognizer *navigationBarPanGestureRecognizer;
    WelcomeTableMode tableMode;
}

@synthesize tablePic;
@synthesize viewHeader;
@synthesize buttonGrid;
@synthesize buttonTimeline;
@synthesize viewBack;
@synthesize viewLogin;
@synthesize indicator;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    
    if (self) {

    }
    
    return self;
}

- (void)becomeActive:(id)sender {
    [self reloadView];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(becomeActive:)
                                                 name:@"BecomeActive" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveLoggedIn:)
                                                 name:@"LoggedIn"
                                               object:nil];
    
    loadEnded = false;
    pagephoto = 1;
    tableMode = kWelcomeTableGrid;
    
    LXAppDelegate* app = (LXAppDelegate*)[UIApplication sharedApplication].delegate;
    [app.tracker sendView:@"Welcome Screen"];
    
    tablePic.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg_sub_back.png"]];
    
    tablePic.frame = CGRectMake(0, 0, 320, self.view.frame.size.height-44);
    
    refreshHeaderView = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - tablePic.bounds.size.height, self.view.frame.size.width, tablePic.bounds.size.height)];
    refreshHeaderView.delegate = self;
    [tablePic addSubview:refreshHeaderView];
    
    [viewLogin removeFromSuperview];
    viewLogin.layer.cornerRadius = 5;
    viewLogin.layer.masksToBounds = YES;
    
    [self.navigationController.view addSubview:viewLogin];
    if ([app getToken].length == 0) {
        viewLogin.hidden = false;
    }
    
    if (app.currentUser != nil) {
        [self receiveLoggedIn:nil];
    } else {
        viewLogin.hidden = false;
        [UIView animateWithDuration:0.3 animations:^{
            viewLogin.alpha = 1;
        }];
    }

}

- (void)reloadView {
    loadEnded = false;
    pagephoto = 1;
    [indicator startAnimating];
    
    LXAppDelegate* app = [LXAppDelegate currentDelegate];
    
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setObject:[app getToken] forKey:@"token"];
    
    [[LatteAPIClient sharedClient] getPath:@"user/everyone/timeline"
                                parameters:param
                                   success:^(AFHTTPRequestOperation *operation, NSDictionary *JSON) {
                                       feeds = [Feed mutableArrayFromDictionary:JSON withKey:@"feeds"];
                                       
                                       [tablePic reloadData];
                                       
                                       [self doneLoadingTableViewData];
                                       [indicator stopAnimating];
                                       
                                   } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                    
                                       [self doneLoadingTableViewData];
                                       [indicator stopAnimating];
                                       loadEnded = true;
                                       
                                       TFLog(@"Something went wrong (Welcome)");
                                   }];
}

- (void)loadMore {
    [indicator startAnimating];
    LXAppDelegate* app = [LXAppDelegate currentDelegate];
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setObject:[app getToken] forKey:@"token"];
    
    [param setObject:[NSNumber numberWithInt:pagephoto+1] forKey:@"page"];
    
    [[LatteAPIClient sharedClient] getPath:@"user/everyone/timeline"
                                parameters: param
                                   success:^(AFHTTPRequestOperation *operation, NSDictionary *JSON) {
                                       
                                       pagephoto += 1;
                                       NSMutableArray *newFeeds = [Feed mutableArrayFromDictionary:JSON withKey:@"feeds"];
                                       
                                       if (newFeeds.count > 0) {
                                           NSInteger oldRow = [self tableView:tablePic numberOfRowsInSection:0];
                                           [tablePic beginUpdates];
                                           [feeds addObjectsFromArray:newFeeds];
                                           NSInteger newRow = [self tableView:tablePic numberOfRowsInSection:0];
                                           for (NSInteger i = oldRow; i < newRow; i++) {
                                               [tablePic insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:i inSection:0]]
                                                               withRowAnimation:UITableViewRowAnimationAutomatic];
                                           }

                                           [tablePic endUpdates];
                                       } else {
                                           loadEnded = true;
                                       }
                                       
                                       [indicator stopAnimating];
                                       
                                   } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                       TFLog(@"Something went wrong (Welcome)");
                                       [indicator stopAnimating];
                                   }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableMode == kWelcomeTableTimeline)
        return feeds.count;
    else
        return feeds.count/3 + (feeds.count%3>0?1:0);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableMode == kWelcomeTableTimeline) {
        Feed *feed = feeds[indexPath.row];
        if (feed.targets.count == 1) {
            LXCellTimelineSingle *cell = [tableView dequeueReusableCellWithIdentifier:@"Single" forIndexPath:indexPath];
            if (nil == cell) {
                cell = [[LXCellTimelineSingle alloc] initWithStyle:UITableViewCellStyleDefault
                                                   reuseIdentifier:@"Single"];
            }
            
            cell.viewController = self;
            cell.feed = feed;
            cell.buttonUser.tag = indexPath.row;

            return cell;
        } else {
            LXCellTimelineMulti *cell = [tableView dequeueReusableCellWithIdentifier:@"Multi" forIndexPath:indexPath];
            if (nil == cell) {
                cell = [[LXCellTimelineMulti alloc] initWithStyle:UITableViewCellStyleDefault
                                                      reuseIdentifier:@"Multi"];
            }
            
            cell.viewController = self;
            cell.feed = feed;
            cell.buttonUser.tag = indexPath.row;
            
            return cell;
        }
    
    } else {
        LXCellGrid *cell = [tableView dequeueReusableCellWithIdentifier:@"Grid" forIndexPath:indexPath];
    
        NSMutableArray *pictures = [[NSMutableArray alloc] init];
        for (Feed *feed in feeds) {
            if (feed.targets.count > 0) {
                [pictures addObject:feed.targets[0]];
            }
        }
        cell.viewController = self;
        [cell setPictures:pictures forRow:indexPath.row];
        return cell;
    }
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableMode == kWelcomeTableTimeline) {
        Feed *feed = feeds[indexPath.row];
        if (feed.targets.count > 1) {
            return 244;
        } else if (feed.targets.count == 1) {
            Picture *pic = feed.targets[0];
            CGFloat feedHeight = [LXUtils heightFromWidth:308.0 width:[pic.width floatValue] height:[pic.height floatValue]] + 3+6+30+6+6+31+3;
            return feedHeight;
        } else
            return 1;
    } else
        return 104;
}

- (void)showPic:(UIButton*)sender withTab:(GalleryTab)tab {
    UIStoryboard *storyGallery = [UIStoryboard storyboardWithName:@"Gallery"
                                                             bundle:nil];
    UINavigationController *navGalerry = [storyGallery instantiateInitialViewController];
    LXGalleryViewController *viewGallery = navGalerry.viewControllers[0];
    viewGallery.delegate = self;
    
    if (tableMode == kWelcomeTableTimeline) {
        Feed *feed = [LXUtils feedFromPicID:sender.tag of:feeds];
        Picture *picture = [LXUtils picFromPicID:sender.tag of:feeds];
        viewGallery.user = feed.user;
        viewGallery.picture = picture;
    } else {
        Feed *feed = feeds[sender.tag];
        Picture *picture = feed.targets[0];
        viewGallery.user = feed.user;
        viewGallery.picture = picture;
    }
    
    [self presentViewController:navGalerry animated:YES completion:^{
        switch (tab) {
            case kGalleryTabComment:
            case kGalleryTabInfo:
            case kGalleryTabVote:
                viewGallery.currentTab = tab;
                break;
            default:
                break;
        }
    }];
}

- (void)showPic:(UIButton*)sender {
    [self showPic:sender withTab:kGalleryTabNone];
}

- (void)showInfo:(UIButton*)sender {
    [self showPic:sender withTab:kGalleryTabInfo];
}

- (void)showLike:(UIButton*)sender {
    [self showPic:sender withTab:kGalleryTabVote];
}

- (void)showComment:(UIButton*)sender {
    [self showPic:sender withTab:kGalleryTabComment];
}

- (void)showMap:(UIButton*)sender {
    UIStoryboard *storyGallery = [UIStoryboard storyboardWithName:@"Gallery"
                                                           bundle:nil];
    LXPicMapViewController *viewPicMap = [storyGallery instantiateViewControllerWithIdentifier:@"Map"];
    Picture *picture = [LXUtils picFromPicID:sender.tag of:feeds];
    viewPicMap.picture = picture;
    [self.navigationController pushViewController:viewPicMap animated:YES];
}

- (void)showUser:(UIButton*)sender {
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"MainStoryboard"
                                                             bundle:nil];
    LXMyPageViewController *viewUserPage = [mainStoryboard instantiateViewControllerWithIdentifier:@"UserPage"];
    Feed *feed = feeds[sender.tag];
    viewUserPage.user = feed.user;
    [self.navigationController pushViewController:viewUserPage animated:YES];
}


- (NSMutableArray*)flatPictureArray {
    NSMutableArray *ret = [[NSMutableArray alloc] init];
    for (Feed *feed in feeds) {
        for (Picture *picture in feed.targets) {
            [ret addObject:picture];
        }
    }
    return ret;
}


- (NSDictionary *)pictureAfterPicture:(Picture *)picture {
    if (tableMode == kWelcomeTableGrid) {
        Feed *feed = [LXUtils feedFromPicID:[picture.pictureId longValue] of:feeds];
        NSUInteger current = [feeds indexOfObject:feed];
        if (current == feeds.count-1) {
            return nil;
        }
        Feed *feedNext = feeds[current+1];
        NSDictionary *ret = [NSDictionary dictionaryWithObjectsAndKeys:
                             feedNext.targets[0], @"picture",
                             feedNext.user, @"user",
                             nil];
        return ret;
    } else if (tableMode == kWelcomeTableTimeline) {
        NSArray *flatPictures = [self flatPictureArray];
        NSUInteger current = [flatPictures indexOfObject:picture];
        if (current < flatPictures.count-1) {
            Picture *nextPic = flatPictures[current+1];
            Feed* feed = [LXUtils feedFromPicID:[nextPic.pictureId integerValue] of:feeds];
            NSDictionary *ret = [NSDictionary dictionaryWithObjectsAndKeys:
                                 nextPic,  @"picture",
                                 feed.user, @"user",
                                 nil];
            return ret;
        }
    }
    return nil;
}

- (NSDictionary *)pictureBeforePicture:(Picture *)picture {
    if (tableMode == kWelcomeTableGrid) {
        Feed *feed = [LXUtils feedFromPicID:[picture.pictureId longValue] of:feeds];
        NSUInteger current = [feeds indexOfObject:feed];
        if (current == 0) {
            return nil;
        }
        Feed *feedPrev = feeds[current-1];
        NSDictionary *ret = [NSDictionary dictionaryWithObjectsAndKeys:
                             feedPrev.targets[0], @"picture",
                             feedPrev.user, @"user",
                             nil];
        return ret;
    } else if (tableMode == kWelcomeTableTimeline) {
        NSArray *flatPictures = [self flatPictureArray];
        NSUInteger current = [flatPictures indexOfObject:picture];
        if (current > 0) {
            Picture *prevPic = flatPictures[current-1];
            Feed* feed = [LXUtils feedFromPicID:[prevPic.pictureId integerValue] of:feeds];
            NSDictionary *ret = [NSDictionary dictionaryWithObjectsAndKeys:
                                 prevPic,  @"picture",
                                 feed.user, @"user",
                                 nil];

            return ret;
        }
    }
    return nil;
}


- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSUInteger)section {
    return 60.0f;
}


- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView *view = [[UIView alloc] init];
    [view addSubview:indicator];
    return view;
}


- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self hideLoginPanel];
}

- (void)receiveLoggedIn:(NSNotification *) notification {
    [self hideLoginPanel];
}

- (void)loginPressed:(id)sender {
    self.navigationController.tabBarController.selectedIndex = 4;
}

- (IBAction)touchTab:(UIButton*)sender {
    buttonGrid.selected = false;
    buttonTimeline.selected = false;
    sender.selected = true;
    
    switch (sender.tag) {
        case 0:
            tableMode = kWelcomeTableGrid;
            break;
        case 1:
            tableMode = kWelcomeTableTimeline;
            break;
    }
    [tablePic reloadData];
}

- (void)hideLoginPanel {
    [UIView animateWithDuration:0.3 animations:^{
        viewLogin.alpha = 0;
    } completion:^(BOOL finished) {
        viewLogin.hidden = true;
    }];
}
- (IBAction)touchCloseLogin:(id)sender {
    [self hideLoginPanel];
}


- (IBAction)touchReg:(id)sender {
    [self performSegueWithIdentifier:@"Register" sender:nil];
}

- (IBAction)touchLogin:(id)sender {
    self.navigationController.tabBarController.selectedIndex = 4;
}

- (void)scrollViewDidScroll:(UIScrollView *)aScrollView {
    [refreshHeaderView egoRefreshScrollViewDidScroll:aScrollView];

    if (loadEnded)
        return;
    CGPoint offset = aScrollView.contentOffset;
    CGRect bounds = aScrollView.bounds;
    CGSize size = aScrollView.contentSize;
    UIEdgeInsets inset = aScrollView.contentInset;
    float y = offset.y + bounds.size.height - inset.bottom;
    float h = size.height;
    
    float reload_distance = -100;
    if(y > h + reload_distance) {
        if (!indicator.isAnimating) {
            [self loadMore];
        }
    }
}

- (void)reloadTableViewDataSource{
    reloading = YES;
}

- (void)doneLoadingTableViewData{
    reloading = NO;
    [refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:tablePic];
}

- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view{
    [self reloadTableViewDataSource];
    
    [self reloadView];
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view{
    return reloading; // should return if data source model is reloading
}

- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view{
    return [NSDate date]; // should return date data source was last changed
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    [refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setTablePic:nil];
    [self setButtonGrid:nil];
    [self setButtonTimeline:nil];
    [self setViewHeader:nil];
    [self setViewBack:nil];
    [self setViewLogin:nil];
    [self setIndicator:nil];
    [super viewDidUnload];
}
@end
