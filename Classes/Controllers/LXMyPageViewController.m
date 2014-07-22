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
#import "LatteAPIv2Client.h"
#import "UIImageView+AFNetworking.h"
#import "LXCellFriend.h"
#import "LXUtils.h"
#import "LXPicInfoViewController.h"
#import "Feed.h"
#import "User.h"
#import "Picture.h"
#import "UIActionSheet+ButtonState.h"
#import "LXCellTimelineSingle.h"
#import "LXCellTimelineMulti.h"
#import "MBProgressHUD.h"

#import "LXCellGrid.h"
#import "REFrostedViewController.h"

typedef enum {
    kTimelineAll = 10,
    kTimelineFriends = 12,
    kTimelineFollowing = 13,
    kTimelineMe = 11
} LatteTimeline;

typedef enum {
    kHomeUser = 1,
    kHomeTag = 2
} LatteHomeTab;

#define kModelPicture 1

@interface LXMyPageViewController ()

@end

@implementation LXMyPageViewController  {
    BOOL reloading;
    BOOL endedTimeline;
    
    NSInteger pagePic;

    NSMutableArray *feeds;
    LatteTimeline timelineKind;
    LatteHomeTab homeTab;
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
    homeTab = kHomeUser;
    
    LXAppDelegate* app = [LXAppDelegate currentDelegate];
    
    [app.tracker set:kGAIScreenName
               value:@"Home Screen"];
    
    [app.tracker send:[[GAIDictionaryBuilder createAppView] build]];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showTimeline:) name:@"LoggedIn" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(becomeActive:) name:@"BecomeActive" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userUpdate:) name:@"user_update" object:nil];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"LXCellTimelineSingle" bundle:nil] forCellReuseIdentifier:@"Single"];
    [self.tableView registerNib:[UINib nibWithNibName:@"LXCellTimelineMulti" bundle:nil] forCellReuseIdentifier:@"Multi"];
    
    _labelMessage.layer.cornerRadius = 7;
    
    [self reloadView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self reloadProfile];
}

- (void)reloadProfile {
    LXAppDelegate* app = [LXAppDelegate currentDelegate];
    
    [[LatteAPIv2Client sharedClient] GET:@"user/me" parameters:nil success:^(AFHTTPRequestOperation *operation, NSDictionary *JSON) {
        if (app.currentUser) {
            NSInteger messageCount = [JSON[@"unread_message"] integerValue];
            _labelMessage.hidden = messageCount == 0;
            _labelMessage.text = [NSString stringWithFormat:@"%ld", (long)messageCount];
            
        }
    } failure:nil];
}


- (void)reloadView {
    if (homeTab == kHomeUser) {
        [self loadMore:YES];
    } else {
        [self loadMoreTag:YES];
    }
    
}

- (IBAction)refresh:(id)sender {
    if (homeTab == kHomeUser) {
        [self loadMore:YES];
    } else {
        [self loadMoreTag:YES];
    }
}

- (void)loadMore:(BOOL)reset {
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:@{@"listtype": [NSNumber numberWithInteger:timelineKind]}];
    if (reset) {
        if (currentRequest.isExecuting) [currentRequest cancel];
        endedTimeline = false;
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    } else {
        if (currentRequest.isExecuting) return;
        Feed *feed = feeds.lastObject;
        if (feed) {
            [params setObject:feed.feedID forKey:@"last_id"];
        }
        [_loadIndicator startAnimating];
        
    }
    
    
    currentRequest = [[LatteAPIClient sharedClient] GET: @"user/me/timeline" parameters: params success:^(AFHTTPRequestOperation *operation, NSDictionary *JSON) {
        
        NSMutableArray *newFeed = [Feed mutableArrayFromDictionary:JSON
                                                           withKey:@"feeds"];
        
        endedTimeline = newFeed.count == 0;
        
        if (reset) {
            feeds = newFeed;
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            [self.tableView reloadData];
            [self.refreshControl endRefreshing];
        } else {
            if (newFeed.count > 0) {
                NSMutableArray *arrayOfIndexPaths = [[NSMutableArray alloc] init];
                
                for(int i = 0 ; i < newFeed.count ; i++)
                {
                    NSIndexPath *path = [NSIndexPath indexPathForRow:feeds.count+i inSection:0];
                    [arrayOfIndexPaths addObject:path];
                }
                
                [feeds addObjectsFromArray:newFeed];
                
                [self.tableView insertRowsAtIndexPaths:arrayOfIndexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
            }
            [_loadIndicator stopAnimating];
        }

    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (reset) {
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            [self.refreshControl endRefreshing];
        } else {
            [_loadIndicator stopAnimating];
        }
    }];
}

- (void)loadMoreTag:(BOOL)reset {
    if (reset) {
        if (currentRequest.isExecuting) [currentRequest cancel];
        endedTimeline = false;
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        pagePic = 1;
    } else {
        if (currentRequest.isExecuting) return;
        [_loadIndicator startAnimating];
    }
    
    
    currentRequest = [[LatteAPIv2Client sharedClient] GET: @"picture" parameters: @{@"follow_tag": @"True", @"page": [NSNumber numberWithInteger:pagePic]} success:^(AFHTTPRequestOperation *operation, NSDictionary *JSON) {
        
        pagePic += 1;

        NSMutableArray *newFeed = [Feed mutableArrayFromPictures:[Picture mutableArrayFromDictionary:JSON withKey:@"pictures"]];
        
        endedTimeline = newFeed.count == 0;
        
        if (reset) {
            feeds = newFeed;
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        } else {
            if (newFeed.count > 0) {
                
                NSMutableArray *arrayOfIndexPaths = [[NSMutableArray alloc] init];
                
                for(int i = 0 ; i < newFeed.count ; i++)
                {
                    NSIndexPath *path = [NSIndexPath indexPathForRow:feeds.count+i inSection:0];
                    [arrayOfIndexPaths addObject:path];
                }
                
                [feeds addObjectsFromArray:newFeed];
                
                [self.tableView insertRowsAtIndexPaths:arrayOfIndexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
            }
        }
        
        [_loadIndicator stopAnimating];
        [self.tableView reloadData];
        [self.refreshControl endRefreshing];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (reset) {
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            [self.refreshControl endRefreshing];
        } else {
            [_loadIndicator stopAnimating];
        }
        
    }];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return feeds.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    Feed *feed = feeds[indexPath.row];
    if (feed.targets.count > 1) {
        CGFloat feedHeight = 260;
        if (feed.tags.count > 0) {
            feedHeight += 36;
        }
        return feedHeight;
    } else if (feed.targets.count == 1) {
        Picture *pic = feed.targets[0];
        CGFloat feedHeight = [LXUtils heightFromWidth:304.0 width:[pic.width floatValue] height:[pic.height floatValue]] +8+52+34;
        if (pic.tagsOld.count > 0) {
            feedHeight += 36;
        }
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

- (IBAction)showSetting:(id)sender {
    UIStoryboard* storySetting = [UIStoryboard storyboardWithName:@"Setting" bundle:nil];
    [self presentViewController:[storySetting instantiateInitialViewController] animated:YES completion:nil];
}

- (IBAction)switchTab:(UIButton*)sender {
    if (_buttonUser.selected && sender.tag == 0) {
        UIActionSheet *actionSwitchTimeline = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Timeline", @"")
                                                                          delegate:self
                                                                 cancelButtonTitle:NSLocalizedString(@"Close", @"")
                                                            destructiveButtonTitle:nil
                                                                 otherButtonTitles:NSLocalizedString(@"All", @""), NSLocalizedString(@"Follow", @""), NSLocalizedString(@"Mutual Follow", @""), NSLocalizedString(@"Me Only", @""), nil];
        [actionSwitchTimeline showFromTabBar:self.tabBarController.tabBar];
    } else {
        [UIView transitionWithView:self.tableView.tableHeaderView
                          duration:kGlobalAnimationSpeed
                           options:UIViewAnimationOptionTransitionCrossDissolve
                        animations:^{
                            _buttonTag.selected = NO;
                            _buttonUser.selected = NO;
                            sender.selected = YES;
                        }
                        completion:nil];
        
        switch (sender.tag) {
            case 0:
                homeTab = kHomeUser;
                [self loadMore:YES];
                
                break;
            case 1:
                homeTab = kHomeTag;
                [self loadMoreTag:YES];
                break;
            default:
                break;
                
        }
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (buttonIndex) {
        case 0:
            timelineKind = kTimelineAll;
            break;
        case 1:
            timelineKind = kTimelineFollowing;
            break;
        case 2:
            timelineKind = kTimelineFriends;
            break;
        case 3:
            timelineKind = kTimelineMe;
            break;
        default:
            return;
            break;
            
    }
    
    [self loadMore:YES];
}


- (IBAction)touchRightBar:(UISegmentedControl*)sender {
    if (sender.selectedSegmentIndex == 0) {
        [self performSegueWithIdentifier:@"Chat" sender:self];
    }
    if (sender.selectedSegmentIndex == 1) {
        UIStoryboard* storySetting = [UIStoryboard storyboardWithName:@"Setting" bundle:nil];
        [self presentViewController:[storySetting instantiateInitialViewController] animated:YES completion:nil];
    }

}

- (void)showTimeline:(NSNotification *) notification {
    [self reloadView];
}

- (void)becomeActive:(NSNotification *) notification {
    [self reloadView];
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
        if (current > flatPictures.count - 6) {
            if (homeTab == kHomeUser) {
                [self loadMore:NO];
            } else {
                [self loadMoreTag:NO];
            }
            
        }
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

- (void)userUpdate:(NSNotification *)notification {
    NSDictionary *rawUser = notification.object;
    if (rawUser[@"unread_message"]) {
        LXAppDelegate* app = [LXAppDelegate currentDelegate];
        if (app.currentUser) {
            if ([app.currentUser.userId integerValue] == [rawUser[@"id"] integerValue]) {
                NSInteger messageCount = [rawUser[@"unread_message"] integerValue];
                _labelMessage.hidden = messageCount == 0;
                _labelMessage.text = [NSString stringWithFormat:@"%ld", (long)messageCount];
            }
        }
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGPoint offset = scrollView.contentOffset;
    CGRect bounds = scrollView.bounds;
    CGSize size = scrollView.contentSize;
    UIEdgeInsets inset = scrollView.contentInset;
    float y = offset.y + bounds.size.height - inset.bottom;
    float h = size.height;
    
    float reload_distance = -100;
    if(y > h + reload_distance) {
        if (homeTab == kHomeUser) {
            [self loadMore:NO];
        } else {
            [self loadMoreTag:NO];
        }

    }
}

@end
