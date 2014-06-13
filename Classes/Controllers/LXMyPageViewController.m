//
//  luxeysMypageViewController.m
//  Latte
//
//  Created by Xuan Dung Bui on 8/22/12.
//  Copyright (c) 2012 LUXEYS. All rights reserved.
//

#import "LXMyPageViewController.h"
#import "LXUserPageViewController.h"

#import "LXAppDelegate.h"
#import "LatteAPIClient.h"
#import "UIImageView+AFNetworking.h"
#import "LXCellFriend.h"
#import "LXUtils.h"
#import "LXPicInfoViewController.h"
#import "LXPicMapViewController.h"
#import "Feed.h"
#import "User.h"
#import "Picture.h"
#import "UIActionSheet+ButtonState.h"
#import "LXCellTimelineSingle.h"
#import "LXCellTimelineMulti.h"
#import "LXVoteViewController.h"
#import "MBProgressHUD.h"

#import "LXCellGrid.h"
#import "REFrostedViewController.h"

typedef enum {
    kTimelineAll = 10,
    kTimelineFriends = 12,
    kTimelineFollowing = 13,
} LatteTimeline;

#define kModelPicture 1

@interface LXMyPageViewController ()

@end

@implementation LXMyPageViewController  {
    BOOL reloading;
    BOOL endedTimeline;
    
    int pagePic;

    NSMutableArray *feeds;
    LatteTimeline timelineKind;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)init {
    self = [super init];
    if (self) {

    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    endedTimeline = false;
    
    timelineKind = kTimelineAll;
    
    LXAppDelegate* app = [LXAppDelegate currentDelegate];
    
    [app.tracker set:kGAIScreenName
               value:@"Home Screen"];
    
    [app.tracker send:[[GAIDictionaryBuilder createAppView] build]];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showTimeline:) name:@"LoggedIn" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(becomeActive:) name:@"BecomeActive" object:nil];
    
    // This will remove extra separators from tableview
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    [self reloadView];
}

- (void)reloadView {
    [self loadMore:YES];
}

- (IBAction)refresh:(id)sender {
    [self loadMore:YES];
}

- (void)loadMore:(BOOL)reset {
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:@{@"listtype": [NSNumber numberWithInteger:timelineKind]}];
    if (reset) {
        endedTimeline = false;
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    } else {
        Feed *feed = feeds.lastObject;
        if (feed) {
            [params setObject:feed.feedID forKey:@"last_id"];
        }
    }
    
    [[LatteAPIClient sharedClient] GET: @"user/me/timeline"
                            parameters: params
                               success:^(AFHTTPRequestOperation *operation, NSDictionary *JSON) {
                                  
                               } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                   DLog(@"Something went wrong (Timeline)");
                                   
                                   [self.refreshControl endRefreshing];
                               }];
    
    
    [[LatteAPIClient sharedClient] GET: @"user/me/timeline"
                                parameters: params
                                   success:^(AFHTTPRequestOperation *operation, NSDictionary *JSON) {
                                       
                                       NSMutableArray *newFeed = [Feed mutableArrayFromDictionary:JSON
                                                                                          withKey:@"feeds"];
                                       
                                       endedTimeline = newFeed.count == 0;
                                       
                                       if (reset) {
                                           feeds = newFeed;
                                           [MBProgressHUD hideHUDForView:self.view animated:YES];
                                       } else {
                                           [feeds addObjectsFromArray:newFeed];
                                       }
                                       
                                       [self.tableView reloadData];
                                       [self.refreshControl endRefreshing];
                                   } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                       DLog(@"Something went wrong (Timeline)");
                                       
                                       [self.refreshControl endRefreshing];
                                   }];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (feeds.count > 0 && !endedTimeline) {
        return feeds.count + 1;
    } else {
        return feeds.count;
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row > feeds.count - 1) {
        return 45;
    }

    Feed *feed = feeds[indexPath.row];
    if (feed.targets.count > 1) {
        return 206;
    } else if (feed.targets.count == 1) {
        Picture *pic = feed.targets[0];
        CGFloat feedHeight = [LXUtils heightFromWidth:320.0 width:[pic.width floatValue] height:[pic.height floatValue]] + 3+6+30+6+6+31+3;
        return feedHeight;
    } else
        return 1;
}

- (BOOL)checkEmpty {
    return feeds.count == 0 && endedTimeline;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    if ([self checkEmpty]) {
        UIView *emptyView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 200)];
        UIImageView *emptyImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"nopict.png"]];
        emptyImage.center = emptyView.center;
        [emptyView addSubview:emptyImage];
        return emptyView;
    }
    return nil;
}


- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if ([self checkEmpty])
        return 200;
    return 0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == feeds.count) {
        [self loadMore:NO];
        return [tableView dequeueReusableCellWithIdentifier:@"Load" forIndexPath:indexPath];
    } else {
        Feed *feed = [feeds objectAtIndex:indexPath.row];
        if (feed.targets.count == 1) {
            
            LXCellTimelineSingle *cell = [tableView dequeueReusableCellWithIdentifier:@"Single" forIndexPath:indexPath];
            
            cell.viewController = self;
            cell.feed = feed;
            cell.buttonUser.tag = indexPath.row;
            
            return cell;
        } else {
            LXCellTimelineMulti *cell = [tableView dequeueReusableCellWithIdentifier:@"Multi" forIndexPath:indexPath];
            
            cell.parent = self;
            cell.feed = feed;
            cell.buttonUser.tag = indexPath.row;
            
            return cell;
        }
    }
}


- (IBAction)showSetting:(id)sender {
    UIStoryboard* storySetting = [UIStoryboard storyboardWithName:@"Setting" bundle:nil];
    [self presentViewController:[storySetting instantiateInitialViewController] animated:YES completion:nil];
}

- (IBAction)switchTimeline:(UISegmentedControl*)sender {
    switch (sender.selectedSegmentIndex) {
        case 0:
            timelineKind = kTimelineAll;
            break;
        case 1:
            timelineKind = kTimelineFollowing;
            break;
        case 2:
            timelineKind = kTimelineFriends;
            break;
        default:
            break;
            
    }
    
    [self loadMore:YES];
    
}

- (void)showTimeline:(NSNotification *) notification {
    [self reloadView];
}

- (void)becomeActive:(NSNotification *) notification {
    LXAppDelegate* app = (LXAppDelegate*)[UIApplication sharedApplication].delegate;
    if (app.currentUser != nil) {
        [self reloadView];
    }
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
    NSArray *flatPictures = [self flatPictureArray];
    NSUInteger current = [flatPictures indexOfObject:picture];
    
    if (current != NSNotFound && current < flatPictures.count-1) {
        Picture *nextPic = [flatPictures objectAtIndex:current+1];
        Feed* feed = [LXUtils feedFromPicID:[nextPic.pictureId integerValue] of:feeds];
        NSDictionary *ret = [NSDictionary dictionaryWithObjectsAndKeys:
                             nextPic, @"picture",
                             feed.user, @"user",
                             nil];
        // Loadmore
        if (current > flatPictures.count - 6)
            [self loadMore:NO];
        return ret;
    }
    return nil;
}

- (NSDictionary *)pictureBeforePicture:(Picture *)picture {
    NSArray *flatPictures = [self flatPictureArray];
    NSInteger current = [flatPictures indexOfObject:picture];
    if (current != NSNotFound && current > 0) {
        Picture *prevPic = [flatPictures objectAtIndex:current-1];
        Feed* feed = [LXUtils feedFromPicID:[prevPic.pictureId integerValue] of:feeds];
        NSDictionary *ret = [NSDictionary dictionaryWithObjectsAndKeys:
                             prevPic,  @"picture",
                             feed.user, @"user",
                             nil];
        return ret;
    }
    return nil;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    if (!decelerate) {
        [[NSNotificationCenter defaultCenter]
         postNotificationName:@"TimelineHideDesc"
         object:self];
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"TimelineShowDesc"
     object:self];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"TimelineHideDesc"
     object:self];
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
