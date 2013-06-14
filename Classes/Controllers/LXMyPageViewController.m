//
//  luxeysMypageViewController.m
//  Latte
//
//  Created by Xuan Dung Bui on 8/22/12.
//  Copyright (c) 2012 LUXEYS. All rights reserved.
//

#import "LXMyPageViewController.h"

#import "LXAppDelegate.h"
#import "LatteAPIClient.h"
#import "UIImageView+AFNetworking.h"
#import "LXPicCommentViewController.h"
#import "LXCellFriend.h"
#import "LXUtils.h"
#import "LXCellComment.h"
#import "UIButton+AsyncImage.h"
#import "LXPicInfoViewController.h"
#import "LXPicMapViewController.h"
#import "LXButtonBrown30.h"
#import "Feed.h"
#import "User.h"
#import "Picture.h"
#import "UIActionSheet+ButtonState.h"
#import "LXCellTimelineSingle.h"
#import "LXCellTimelineMulti.h"
#import "LXRootBuilder.h"
#import "LXVoteViewController.h"

#import "LXViewHeaderMypage.h"
#import "LXViewHeaderUserPage.h"
#import "LXCellGrid.h"
#import "LXButtonBack.h"
#import "LXCellDataField.h"
#import "NSDate+TKCategory.h"
#import "LXCaptureViewController.h"

typedef enum {
    kTimelineAll = 10,
    kTimelineFriends = 12,
    kTimelineFollowing = 13,
} LatteTimeline;

#define kModelPicture 1

@interface LXMyPageViewController ()

@end

@implementation LXMyPageViewController  {
    NSMutableSet *showSet;
    NSArray *showField;
    NSDictionary *userDict;
    NSInteger daysInMonth;
    
    MypagePhotoMode photoMode;
    NSArray *allTab;
    BOOL reloading;
    BOOL endedTimeline;
    BOOL endedPic;
    BOOL isMypage;
    
    int pagePic;
    int pageVote;
    NSMutableArray *feeds;
    NSMutableArray *pictures;
    NSMutableArray *followers;
    NSMutableArray *followings;
    NSMutableDictionary *currentMonthPics;
    NSMutableDictionary *currentDayPics;
    NSDate *selectedCalendarDate;
    NSMutableArray *currentMonthPicsFlat;
    EGORefreshTableHeaderView *refreshHeaderView;
    MBProgressHUD *HUD;
    
    LXViewHeaderMypage *viewHeaderMypage;
    LXViewHeaderUserPage *viewHeaderUserpage;
}

@synthesize currentMonth;
@synthesize loadIndicator;
@synthesize tableMode;

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
        tableMode = 0;
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    showSet = [NSMutableSet setWithObjects:@"gender", @"residence", @"age", @"birthdate", @"bloodtype", @"occupation", @"introduction", @"hobby", @"nationality", nil];
    
    if (tableMode == 0) {
        tableMode = kTablePhoto;
    }

    endedPic = false;
    endedTimeline = false;
    
    pagePic = 0;
    pageVote = 0;
    currentMonth = [NSDate date];
    
    LXAppDelegate* app = [LXAppDelegate currentDelegate];
    self.tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 120)];
    self.tableView.tableHeaderView.clipsToBounds = YES;
    
    UIStoryboard *storyComponent = [UIStoryboard storyboardWithName:@"Component"
                                                             bundle:nil];
    
    if (_user == nil) {
        if (app.currentUser == nil) {
            return;
        } else {
            _user = app.currentUser;
            viewHeaderMypage = [storyComponent instantiateViewControllerWithIdentifier:@"HeaderMypage"];
            viewHeaderMypage.user = _user;
            viewHeaderMypage.parent = self;
            [self.tableView.tableHeaderView addSubview:viewHeaderMypage.view];
            [self addChildViewController:viewHeaderMypage];
            [viewHeaderMypage didMoveToParentViewController:self];
            [app.tracker sendView:@"Mypage Screen"];
            
            photoMode = kPhotoTimeline;
            isMypage = true;
            
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showTimeline:) name:@"LoggedIn" object:nil];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(becomeActive:) name:@"BecomeActive" object:nil];
        }
        
        
        //setup left button
        UIBarButtonItem *navLeftItem = self.navigationItem.leftBarButtonItem;
        UIButton *buttonSide = (UIButton*)navLeftItem.customView;
        [buttonSide addTarget:app.controllerSide action:@selector(toggleLeftPanel:) forControlEvents:UIControlEventTouchUpInside];
        
    } else {
        viewHeaderUserpage = [storyComponent instantiateViewControllerWithIdentifier:@"HeaderUserpPage"];
        [self.tableView.tableHeaderView addSubview:viewHeaderUserpage.view];
        [self addChildViewController:viewHeaderUserpage];
        [viewHeaderUserpage didMoveToParentViewController:self];
        viewHeaderUserpage.user = _user;
        viewHeaderUserpage.parent = self;
        
        [app.tracker sendView:@"User Screen"];
        
        photoMode = kPhotoMyphoto;
        isMypage = false;
        
        // Increase count
        NSString *url = [NSString stringWithFormat:@"user/counter/%d",[_user.userId integerValue]];
        
        [[LatteAPIClient sharedClient] getPath:url
                                    parameters:[NSDictionary dictionaryWithObject:[app getToken] forKey:@"token"]
                                       success:nil
                                       failure:nil];
    }
    
    HUD = [[MBProgressHUD alloc] initWithView:app.viewMainTab.view];
    HUD.userInteractionEnabled = NO;
    [app.viewMainTab.view addSubview:HUD];
    HUD.mode = MBProgressHUDModeText;
    HUD.labelText = NSLocalizedString(@"Loading...", @"Loading...") ;
    HUD.labelFont = [UIFont fontWithName:@"HelveticaNeue-Light" size:16];
    HUD.margin = 10.f;
    HUD.yOffset = 150.f;
    
    refreshHeaderView = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - self.tableView.bounds.size.height, self.view.frame.size.width, self.tableView.bounds.size.height)];
    refreshHeaderView.delegate = self;
    [self.tableView addSubview:refreshHeaderView];
    
    self.tableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg_sub_back.png"]];
    
    [self reloadView];
}

- (void)reloadTimeline {
    [HUD show:YES];
    [loadIndicator startAnimating];
    LXAppDelegate* app = (LXAppDelegate*)[UIApplication sharedApplication].delegate;
    LatteTimeline timelineKind;
    switch (photoMode) {
        case kPhotoTimeline:
            timelineKind = kTimelineAll;
            break;
        case kPhotoFollowing:
            timelineKind = kTimelineFollowing;
            break;
        case kPhotoFriends:
            timelineKind = kTimelineFriends;
            break;
        case kPhotoCalendar:
        case kPhotoMyphoto:
            return;
    }
    
    NSString *url;
    if (isMypage)
        url = @"user/me/timeline";
    else
        url = [NSString stringWithFormat:@"user/%d/timeline", [_user.userId integerValue]];
    
    [[LatteAPIClient sharedClient] getPath:url
                                parameters: [NSDictionary dictionaryWithObjectsAndKeys:
                                             [app getToken], @"token",
                                             [NSNumber numberWithInteger:timelineKind], @"listtype",
                                             nil]
                                   success:^(AFHTTPRequestOperation *operation, NSDictionary *JSON) {
                                       feeds = [Feed mutableArrayFromDictionary:JSON
                                                                        withKey:@"feeds"];
                                       if (!isMypage) {
                                           for (Feed *feed in feeds) {
                                               feed.user = _user;
                                           }
                                       }
                                       
                                       [self.tableView reloadData];
                                       [self doneLoadingTableViewData];
                                       [loadIndicator stopAnimating];
                                       [HUD hide:YES];
                                   } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                       [self.tableView reloadData];
                                       [loadIndicator stopAnimating];
                                       DLog(@"Something went wrong (Timeline)");
                                       [HUD hide:YES];
                                   }];
}

- (void)reloadProfile {
    LXAppDelegate* app = (LXAppDelegate*)[UIApplication sharedApplication].delegate;
    
    NSString *url = [NSString stringWithFormat:@"user/%d", [_user.userId integerValue]];
    [[LatteAPIClient sharedClient] getPath:url
                                parameters: [NSDictionary dictionaryWithObjectsAndKeys:[app getToken], @"token", nil]
                                   success:^(AFHTTPRequestOperation *operation, NSDictionary *JSON) {
                                       userDict = [JSON objectForKey:@"user"];
                                       User *user = [User instanceFromDictionary:userDict];
                                       
                                       if (isMypage) {
                                           app.currentUser = user;
                                           viewHeaderMypage.user = user;
                                       } else {
                                           viewHeaderUserpage.user = user;
                                       }
                                       
                                       NSSet *allField = [NSSet setWithArray:[userDict allKeys]];
                                       
                                       [showSet intersectSet:allField];
                                       showField = [showSet allObjects];
                                       
                                       if (tableMode == kTableProfile) {
                                           [self doneLoadingTableViewData];
                                           [self.tableView reloadData];
                                       }
                                       
                                   } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                       [self doneLoadingTableViewData];
                                       DLog(@"Something went wrong (Profile)");
                                   }];
}

- (void)reloadPicList {
    pagePic = 0;
    endedPic = false;
    
    LXAppDelegate* app = (LXAppDelegate*)[UIApplication sharedApplication].delegate;
    [loadIndicator startAnimating];
    
    NSDictionary *param = [NSDictionary dictionaryWithObjectsAndKeys:
                           [app getToken], @"token",
                           [NSNumber numberWithInt:pagePic + 1], @"page",
                           [NSNumber numberWithInt:30], @"limit",
                           nil];
    NSString *url = [NSString stringWithFormat:@"picture/user/%d", [_user.userId integerValue]];
    
    [[LatteAPIClient sharedClient] getPath:url
                                parameters: param
                                   success:^(AFHTTPRequestOperation *operation, NSDictionary *JSON) {
                                       pictures = [Picture mutableArrayFromDictionary:JSON
                                                                                      withKey:@"pictures"];
                                       
                                       endedPic = pictures.count == 0;
                                       
                                       [self.tableView reloadData];
                                       [self doneLoadingTableViewData];
                                       
                                       [loadIndicator stopAnimating];
                                       
                                       pagePic += 1;
                                   } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                       [loadIndicator stopAnimating];
                                       DLog(@"Something went wrong (Photolist)");
                                       [self doneLoadingTableViewData];
                                   }];
}

- (void)loadMorePicList {
    LXAppDelegate* app = (LXAppDelegate*)[UIApplication sharedApplication].delegate;
    [loadIndicator startAnimating];

    NSDictionary *param = [NSDictionary dictionaryWithObjectsAndKeys:
        [app getToken], @"token",
        [NSNumber numberWithInt:pagePic + 1], @"page",
        [NSNumber numberWithInt:30], @"limit",
        nil];

    NSString *url = [NSString stringWithFormat:@"picture/user/%d", [_user.userId integerValue]];
    [[LatteAPIClient sharedClient] getPath:url
                                parameters: param
                                   success:^(AFHTTPRequestOperation *operation, NSDictionary *JSON) {
                                       NSArray *newPics = [Picture mutableArrayFromDictionary:JSON
                                                                              withKey:@"pictures"];

                                       endedPic = newPics.count == 0;
                                       NSInteger oldRow = [self tableView:self.tableView numberOfRowsInSection:0];
                                       [self.tableView beginUpdates];
                                       
                                       
                                       [pictures addObjectsFromArray:newPics];
                                       
                                       NSInteger newRow = [self tableView:self.tableView numberOfRowsInSection:0];
                                       for (NSInteger i = oldRow; i < newRow; i++) {
                                           [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:i inSection:0]]
                                                                 withRowAnimation:UITableViewRowAnimationAutomatic];
                                       }
                                       
                                       [self.tableView endUpdates];
                                       [self doneLoadingTableViewData];
                                       
                                       [loadIndicator stopAnimating];
                                       
                                       pagePic += 1;
                                   } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                       [loadIndicator stopAnimating];
                                       DLog(@"Something went wrong (Photolist)");
                                       [self doneLoadingTableViewData];
                                   }];
}

- (void)reloadFollower {
    LXAppDelegate* app = (LXAppDelegate*)[UIApplication sharedApplication].delegate;
    
    NSString *url = [NSString stringWithFormat:@"user/%d/follower", [_user.userId integerValue]];
    [[LatteAPIClient sharedClient] getPath:url
                                parameters: [NSDictionary dictionaryWithObjectsAndKeys:[app getToken], @"token", nil]
                                   success:^(AFHTTPRequestOperation *operation, NSDictionary *JSON) {
                                       followers = [User mutableArrayFromDictionary:JSON
                                                                          withKey:@"followers"];
                                       
                                       [self doneLoadingTableViewData];
                                       [self.tableView reloadData];
                                       
                                   } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                       DLog(@"Something went wrong (Follower)");
                                       [self doneLoadingTableViewData];
                                       [self.tableView reloadData];
                                   }];
}

- (void)reloadFollowings {
    LXAppDelegate* app = (LXAppDelegate*)[UIApplication sharedApplication].delegate;
    
    NSString *url = [NSString stringWithFormat:@"user/%d/following", [_user.userId integerValue]];
    [[LatteAPIClient sharedClient] getPath:url
                                parameters: [NSDictionary dictionaryWithObjectsAndKeys:[app getToken], @"token", nil]
                                   success:^(AFHTTPRequestOperation *operation, NSDictionary *JSON) {
                                       followings = [User mutableArrayFromDictionary:JSON
                                                                             withKey:@"following"];
                                       
                                       [self doneLoadingTableViewData];
                                       [self.tableView reloadData];
                                   } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                       DLog(@"Something went wrong (Reload Following)");
                                       [self doneLoadingTableViewData];
                                       [self.tableView reloadData];
                                   }];
}


- (void)reloadView {
    endedTimeline = false;
    endedPic = false;

    [self reloadProfile];
    
    switch (tableMode) {
        case kTablePhoto:
            if (photoMode == kPhotoMyphoto)
                [self reloadPicList];
            else if (photoMode == kPhotoCalendar)
                [self reloadCalendar];
            else
                [self reloadTimeline];
            break;
        case kTableFollowings:
            [self reloadFollowings];
            break;
        case kTableFollower:
            [self reloadFollower];
            break;
        default:
            break;
    }
}

- (void)loadMore {
    if (!loadIndicator.isAnimating) {
        if (photoMode == kPhotoMyphoto)
            [self loadMorePicList];
        else
            [self loadMoreTimeline];
    }
}

- (void)loadMoreTimeline {
    [loadIndicator startAnimating];
    Feed *feed = feeds.lastObject;
    
    LXAppDelegate* app = (LXAppDelegate*)[UIApplication sharedApplication].delegate;
    NSString *url;
    if (isMypage)
        url = @"user/me/timeline";
    else
        url = [NSString stringWithFormat:@"user/%d/timeline", [_user.userId integerValue]];
    
    LatteTimeline timelineKind;
    switch (photoMode) {
        case kPhotoTimeline:
            timelineKind = kTimelineAll;
            break;
        case kPhotoFollowing:
            timelineKind = kTimelineFollowing;
            break;
        case kPhotoFriends:
            timelineKind = kTimelineFriends;
            break;
        case kPhotoCalendar:
        case kPhotoMyphoto:
            return;
    }
    
    [[LatteAPIClient sharedClient] getPath: url
                                parameters: [NSDictionary dictionaryWithObjectsAndKeys:
                                             [app getToken], @"token",
                                             [NSNumber numberWithInteger:timelineKind], @"listtype",
                                             feed.feedID, @"last_id",
                                             nil]
                                   success:^(AFHTTPRequestOperation *operation, NSDictionary *JSON) {
                                       
                                       NSMutableArray *newFeed = [Feed mutableArrayFromDictionary:JSON
                                                                                          withKey:@"feeds"];
                                       if (!isMypage) {
                                           for (Feed *feed in newFeed) {
                                               feed.user = _user;
                                           }
                                       }
                                       
                                       if (newFeed.count == 0) {
                                           endedTimeline = true;
                                       }
                                       else {
                                           NSInteger oldRow = [self tableView:self.tableView numberOfRowsInSection:0];
                                           [self.tableView beginUpdates];
                                           [feeds addObjectsFromArray:newFeed];
                                           NSInteger newRow = [self tableView:self.tableView numberOfRowsInSection:0];
                                           for (NSInteger i = oldRow; i < newRow; i++) {
                                               [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:i inSection:0]]
                                                                     withRowAnimation:UITableViewRowAnimationAutomatic];
                                           }
                                           
                                           [self.tableView endUpdates];
                                       }
                                       
                                       [loadIndicator stopAnimating];
                                       [self doneLoadingTableViewData];
                                   } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                       DLog(@"Something went wrong (Timeline)");
                                       [loadIndicator stopAnimating];
                                   }];
}

- (void)reloadCalendar {
    selectedCalendarDate = nil;
    LXAppDelegate* app = (LXAppDelegate*)[[UIApplication sharedApplication] delegate];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyyMM"];
    
    NSString* urlPhotos = [NSString stringWithFormat:@"picture/album/by_month/%@/%d", [dateFormat stringFromDate:currentMonth], [_user.userId integerValue]];
    [HUD show:YES];
    [[LatteAPIClient sharedClient] getPath:urlPhotos
                                parameters: [NSDictionary dictionaryWithObjectsAndKeys:[app getToken], @"token", nil]
                                   success:^(AFHTTPRequestOperation *operation, NSDictionary *JSON) {
                                       currentMonthPicsFlat = [Picture mutableArrayFromDictionary:JSON withKey:@"pictures"];
                                       currentMonthPics = [[NSMutableDictionary alloc]init];
                                       currentDayPics = [[NSMutableDictionary alloc]init];
                                       NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
                                       
                                       [dateFormat setDateFormat:@"yyyyMMdd"];
                                       for (Picture *pic in currentMonthPicsFlat) {
                                           if (pic.takenAt) {
                                               NSString* key = [dateFormat stringFromDate:pic.takenAt];
                                               [currentMonthPics setObject:pic forKey:key];
                                           }
                                       }
                                       
                                       [dateFormat setDateFormat:@"yyyyMMddHH"];
                                       for (Picture *pic in currentMonthPicsFlat) {
                                           if (pic.takenAt) {
                                               NSString* key = [dateFormat stringFromDate:pic.takenAt];
                                               NSMutableArray *dayPics = [currentDayPics objectForKey:key];
                                               if (!dayPics) {
                                                   dayPics = [[NSMutableArray alloc] init];
                                               }
                                               [dayPics addObject:pic];
                                               [currentDayPics setObject:dayPics forKey:key];
                                           }
                                       }
                                       
                                       [self.tableView reloadData];
                                       
                                       [self doneLoadingTableViewData];
                                       [HUD hide:YES];
                                       
                                   } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                       DLog(@"Something went wrong (User - Calendar)");
                                       [HUD hide:YES];
                                   }];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (tableMode == kTablePhoto && photoMode == kPhotoCalendar) {
        NSArray *rangeDates = [LXUtils rangeOfDatesInMonthGrid:currentMonth startOnSunday:YES timeZone:[NSTimeZone localTimeZone]];
        NSUInteger numberOfDaysBetween = [rangeDates[0] daysBetweenDate:[rangeDates lastObject]] + 1;
        return numberOfDaysBetween/7 + 2;
    } else
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (tableMode) {
        case kTablePhoto:
            if (photoMode == kPhotoMyphoto) {
                return (pictures.count/3) + (pictures.count%3>0?1:0);
            } else if (photoMode == kPhotoCalendar) {
                if (selectedCalendarDate && section > 0) {
                    NSArray *rangeDates = [LXUtils rangeOfDatesInMonthGrid:currentMonth startOnSunday:YES timeZone:[NSTimeZone localTimeZone]];
                    
                    NSDate *dateStart = [rangeDates[0] copy];
                    dateStart = [dateStart dateByAddingTimeInterval:24*60*60*(section-1)*7];
                    NSDate *dateEnd = [dateStart dateByAddingTimeInterval:24*60*60*7];
                    
                    if (
                        (([selectedCalendarDate compare:dateStart] == NSOrderedDescending) ||
                        ([selectedCalendarDate compare:dateStart] == NSOrderedSame)) &&
                        ([selectedCalendarDate compare:dateEnd] == NSOrderedAscending))
                    {
                        return 1;
                    }
                }
                return 0;
            }
            else {
                return feeds.count;
            }
        case kTableFollowings:
            return followings.count;
        case kTableFollower:
            return followers.count;
        case kTableProfile:
            return [showField count];
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableMode == kTablePhoto)
    {
        if (photoMode == kPhotoMyphoto) {
            return 104;
        } else if (photoMode == kPhotoCalendar) {
            if (selectedCalendarDate) {
                UIView *view = [self viewForCalendarDay:selectedCalendarDate];
                return view.frame.size.height;
            } else
                return 0;

        } else {
            Feed *feed = feeds[indexPath.row];
            if (feed.targets.count > 1) {
                return 244;
            } else if (feed.targets.count == 1) {
                Picture *pic = feed.targets[0];
                CGFloat feedHeight = [LXUtils heightFromWidth:308.0 width:[pic.width floatValue] height:[pic.height floatValue]] + 3+6+30+6+6+31+3;
                return feedHeight;
            } else
                return 1;
        }
    } else if (tableMode == kTableProfile) {
        NSString* strKey = [showField objectAtIndex:indexPath.row];
        
        if ([strKey isEqualToString:@"hobby"]|| [strKey isEqualToString:@"introduction"]) {
            CGSize size = [[userDict objectForKey:strKey] sizeWithFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:12.0]
                                                     constrainedToSize:CGSizeMake(212.0, CGFLOAT_MAX)
                                                         lineBreakMode:NSLineBreakByWordWrapping];
            return size.height + 8;
        } else {
            return 22;
        }
    }
    else
        return 48;
}

- (BOOL)checkEmpty {
    BOOL isEmpty = false;
    switch (tableMode) {
        case kTableFollower:
            isEmpty = followers.count == 0;
            break;
        case kTableFollowings:
            isEmpty = followings.count == 0;
            break;
        case kTablePhoto:
            if (photoMode == kPhotoMyphoto)
                isEmpty = pictures.count == 0;
            else if (photoMode != kPhotoCalendar)
                isEmpty = feeds.count == 0;
            break;
        case kTableProfile:
            return isEmpty;
    }
    return isEmpty;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if ([self checkEmpty]) {
        UIView *emptyView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 200)];
        UIImageView *emptyImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"nopict.png"]];
        //    UILabel *label = [[UILabel alloc] initWithFrame:(CGRect)]
        emptyImage.center = emptyView.center;
        [emptyView addSubview:emptyImage];
        return emptyView;
    }
    
    if ((tableMode == kTablePhoto) && (photoMode == kPhotoCalendar)) {
        NSArray *rangeDates = [LXUtils rangeOfDatesInMonthGrid:currentMonth startOnSunday:YES timeZone:[NSTimeZone localTimeZone]];
        NSUInteger numberOfDaysBetween = [rangeDates[0] daysBetweenDate:[rangeDates lastObject]] + 1;
        NSUInteger headerCount = numberOfDaysBetween/7;
        
        if (section == 0 || section == headerCount + 1) {
            UIView *view = [[UIView alloc] init];
            view.backgroundColor = [UIColor whiteColor];
            
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 5, 100, 30)];
            label.textAlignment = NSTextAlignmentCenter;
            
            UIImageView *imagePrev = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"arrow_left2.png"]];
            imagePrev.frame = CGRectMake(5, 16, 5, 8);
            UIImageView *imageNext = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"arrow_right2.png"]];
            imageNext.frame = CGRectMake(310, 16, 5, 8);
            
            UIButton *prev = [[UIButton alloc] initWithFrame:CGRectMake(5, 5, 60, 30)];
            UIButton *next = [[UIButton alloc] initWithFrame:CGRectMake(255, 5, 60, 30)];
            [prev addTarget:self action:@selector(prevMonth:) forControlEvents:UIControlEventTouchUpInside];
            [next addTarget:self action:@selector(nextMonth:) forControlEvents:UIControlEventTouchUpInside];
            [prev setTitle:@"PREV" forState:UIControlStateNormal];
            [next setTitle:@"NEXT" forState:UIControlStateNormal];
            prev.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:14];
            next.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:14];
            [prev setTitleColor:[UIColor colorWithRed:101.0/255.0	green:90.0/255.0 blue:56.0/255.0 alpha:1] forState:UIControlStateNormal];
            [next setTitleColor:[UIColor colorWithRed:101.0/255.0	green:90.0/255.0 blue:56.0/255.0 alpha:1] forState:UIControlStateNormal];
            
            label.center = CGPointMake(160, 18);
            
            
            NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
            [dateFormat setDateFormat:@"yyyy/MM"];
            label.text = [dateFormat stringFromDate:currentMonth];
            label.textColor = [UIColor colorWithRed:101.0/255.0	green:90.0/255.0 blue:56.0/255.0 alpha:1];
            label.backgroundColor = [UIColor clearColor];
            [label setFont:[UIFont fontWithName:@"HelveticaNeue-UltraLight" size:20]];
            [view addSubview:prev];
            [view addSubview:next];
            [view addSubview:label];
            [view addSubview:imagePrev];
            [view addSubview:imageNext];
            
            if (section == 0) {
                UIView* viewWeek = [[UIView alloc] initWithFrame:CGRectMake(0, 37, 320, 23)];
                UIView* viewLine = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 1)];
                viewLine.backgroundColor = [UIColor colorWithRed:191.0/255.0 green:185.0/255.0 blue:172.0/255.0 alpha:1];
                viewWeek.backgroundColor = [UIColor colorWithRed:225.0/255.0 green:223.0/255.0 blue:217.0/255.0 alpha:1];
                NSArray *weekDays = [NSArray arrayWithObjects:@"SUN", @"MON",@"TUE",@"WED",@"THU",@"FRI", @"SAT", nil];
                
                for (NSInteger i = 0; i < weekDays.count; i++) {
                    NSString *week = weekDays[i];
                    UILabel *labelWeek = [[UILabel alloc] initWithFrame:CGRectMake(6+i*44, 3, 44, 20)];

                    if (i == 0)
                        labelWeek.textColor = [UIColor colorWithRed:151.0/255.0	green:15.0/255.0 blue:20.0/255.0 alpha:1];
                    else if (i == 6)
                        labelWeek.textColor = [UIColor colorWithRed:36.0/255.0	green:87.0/255.0 blue:147.0/255.0 alpha:1];
                    else
                        labelWeek.textColor = [UIColor colorWithRed:101.0/255.0	green:90.0/255.0 blue:56.0/255.0 alpha:1];
                    
                    labelWeek.backgroundColor = [UIColor clearColor];
                    labelWeek.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:10];
                    labelWeek.text = week;
                    
                    labelWeek.textAlignment = NSTextAlignmentCenter;
                    [viewWeek addSubview:labelWeek];
                }
                [viewWeek addSubview:viewLine];
                [view addSubview:viewWeek];
            }
            return view;
        } else {
            NSDate *date = [rangeDates[0] copy];
            date = [date dateByAddingTimeInterval:24*60*60*(section-1)*7];
            UIView *view = [[UIView alloc] init];
            view.backgroundColor = [UIColor colorWithRed:225.0/255.0 green:223.0/255.0 blue:217.0/255.0 alpha:1];
            for (int i = 0; i < 7; i++) {
                NSDateComponents *components = [[NSCalendar currentCalendar] components:NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit fromDate:date];
                NSDateComponents *componentCurrent = [[NSCalendar currentCalendar] components:NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit fromDate:currentMonth];
                UIImageView *bg = [[UIImageView alloc] initWithFrame:CGRectMake(6+i*44, 0, 44, 46)];
                [view addSubview:bg];
                NSDateFormatter *dayFormat = [[NSDateFormatter alloc] init];
                [dayFormat setDateFormat:@"yyyyMMdd"];
                NSString* key = [dayFormat stringFromDate:date];
                Picture *pic = [currentMonthPics objectForKey:key];
                if (pic) {
                    bg.image = [UIImage imageNamed:@"calendar_on.png"];
                    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(i*44+11, 6, 34, 34)];
                    button.layer.cornerRadius = 5;
                    button.layer.masksToBounds = YES;
                    [button loadBackground:pic.urlSquare animated:NO];
                    button.tag = (section-1)*7 + i;
                    [button addTarget:self action:@selector(showDay:) forControlEvents:UIControlEventTouchUpInside];
                    UIImageView *medal = [[UIImageView alloc] initWithFrame:CGRectMake(i*44+16, 4, 12, 13)];
                    medal.image = [UIImage imageNamed:@"calendar_label.png"];
                    CGRect frame = medal.bounds;
                    frame.size.height -= 2;
                    UILabel *label = [[UILabel alloc] initWithFrame:frame];
                    label.text = [NSString stringWithFormat:@"%d", components.day];
                    label.textColor = [UIColor whiteColor];
                    label.textAlignment = NSTextAlignmentCenter;
                    label.backgroundColor = [UIColor clearColor];
                    label.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:7];
                    [medal addSubview:label];
                    [view addSubview:button];
                    [view addSubview:medal];
                } else {
                    UILabel *label = [[UILabel alloc] initWithFrame:bg.bounds];
                    label.textColor = [UIColor colorWithRed:101.0/255.0	green:90.0/255.0 blue:56.0/255.0 alpha:1];
                    label.textAlignment = NSTextAlignmentCenter;
                    label.backgroundColor = [UIColor clearColor];
                    label.font = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:12];
                    
                    NSDateComponents *today = [[NSCalendar currentCalendar] components:NSEraCalendarUnit|NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:[NSDate date]];
                    if([today day] == [components day] &&
                       [today month] == [components month] &&
                       [today year] == [components year]) {
                        bg.image = [UIImage imageNamed:@"calendar_today.png"];
                        label.text = NSLocalizedString(@"today", @"calendar today");
                    } else {
                        bg.image = [UIImage imageNamed:@"calendar_off.png"];
                        label.text = [NSString stringWithFormat:@"%d", components.day];
                    }
                    [bg addSubview:label];
                    if (componentCurrent.month != components.month) {
                        bg.alpha = 0.5;
                    }
                }
                
                date = [date dateByAddingTimeInterval:24*60*60];
            }
            return view;
        }
    } else if (tableMode == kTableProfile) {
        UIView *view = [[UIView alloc] init];
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(6, 5, 309, 1)];
        line.backgroundColor = [UIColor lightGrayColor];
        [view addSubview:line];
        return view;
    }
    return nil;
}

- (void)showDay:(UIButton*)sender {
    NSArray *rangeDates = [LXUtils rangeOfDatesInMonthGrid:currentMonth startOnSunday:YES timeZone:[NSTimeZone localTimeZone]];
    NSDate *dateStart = rangeDates[0];
    dateStart = [dateStart dateByAddingTimeInterval:24*60*60*sender.tag];
    [self.tableView beginUpdates];
    if (selectedCalendarDate) {
        NSInteger days = [rangeDates[0] daysBetweenDate:selectedCalendarDate];
        [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:days/7 + 1]] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    
    if (([selectedCalendarDate compare:dateStart] != NSOrderedSame) || (selectedCalendarDate == nil)) {
        selectedCalendarDate = dateStart;
        
        [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:sender.tag/7 + 1]] withRowAnimation:UITableViewRowAnimationAutomatic];
    } else {
        selectedCalendarDate = nil;
    }
    
    [self.tableView endUpdates];
}

- (void)nextMonth:(id)sender {
    NSDateComponents* dateComponents = [[NSDateComponents alloc]init];
    [dateComponents setMonth:1];
    NSCalendar* calendar = [NSCalendar currentCalendar];
    currentMonth = [calendar dateByAddingComponents:dateComponents toDate:currentMonth options:0];
    [self reloadCalendar];
}

- (void)prevMonth:(id)sender {
    NSDateComponents* dateComponents = [[NSDateComponents alloc]init];
    [dateComponents setMonth:-1];
    NSCalendar* calendar = [NSCalendar currentCalendar];
    currentMonth = [calendar dateByAddingComponents:dateComponents toDate:currentMonth options:0];
    [self reloadCalendar];
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if ([self checkEmpty])
        return 200;
    if ((tableMode == kTablePhoto) && (photoMode == kPhotoCalendar)) {
        NSArray *rangeDates = [LXUtils rangeOfDatesInMonthGrid:currentMonth startOnSunday:YES timeZone:[NSTimeZone localTimeZone]];
        NSUInteger numberOfDaysBetween = [rangeDates[0] daysBetweenDate:[rangeDates lastObject]] + 1;
        NSUInteger headerCount = numberOfDaysBetween/7;
        if (section == 0)
            return 60;
        else if (section == headerCount + 1)
            return 40;
        else {
            return 46;
        }

    } else if (tableMode == kTableProfile)
        return 6;
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (tableMode) {
        case kTableFollower:
        case kTableFollowings: {
            LXCellFriend* cellUser;
            User *user;
            
            cellUser = [tableView dequeueReusableCellWithIdentifier:@"User"];
            
            @try {
                if (tableMode == kTableFollower) {
                    user = followers[indexPath.row];
                } else if (tableMode == kTableFollowings) {
                    user = followings[indexPath.row];
                }
                cellUser.user = user;
            }
            @catch (NSException *exception) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                message:exception.debugDescription
                                                               delegate:nil
                                                      cancelButtonTitle:@"Close"
                                                      otherButtonTitles:nil];
                [alert show];
            }
            
            return cellUser;
        }
            break;
        case kTablePhoto:    {
            if (photoMode == kPhotoMyphoto) {
                LXCellGrid *cellPic = [tableView dequeueReusableCellWithIdentifier:@"Grid"];

                cellPic.viewController = self;
                [cellPic setPictures:pictures forRow:indexPath.row];

                return cellPic;
            } else if (photoMode == kPhotoCalendar) {
                UITableViewCell *cell = [[UITableViewCell alloc] init];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;

                [cell addSubview:[self viewForCalendarDay:selectedCalendarDate]];
                return cell;
            }
            else {
                Feed *feed = [feeds objectAtIndex:indexPath.row];
                if (feed.targets.count == 1)
                {
                    LXCellTimelineSingle *cell = [tableView dequeueReusableCellWithIdentifier:@"Single"];
                    
                    cell.viewController = self;
                    cell.feed = feed;
                    cell.buttonUser.tag = indexPath.row;
                    
                    return cell;
                } else {
                    LXCellTimelineMulti *cell = [tableView dequeueReusableCellWithIdentifier:@"Multi"];
                    
                    cell.viewController = self;
                    cell.feed = feed;
                    cell.buttonUser.tag = indexPath.row;
                    
                    return cell;
                }
                
            }
        }
            break;
        case kTableProfile:
        {
            static NSString *CellIdentifier = @"Profile";
            LXCellDataField *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (cell == nil) {
                cell = [[LXCellDataField alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            }
            
            NSString* strKey = [showField objectAtIndex:indexPath.row];
            if ([strKey isEqualToString:@"gender"]) {
                cell.labelField.text = NSLocalizedString(@"gender", @"性別");
            } else if ([strKey isEqualToString:@"residence"]) {
                cell.labelField.text = NSLocalizedString(@"current_residence", @"現住所");
            } else if ([strKey isEqualToString:@"hometown"]) {
                cell.labelField.text = NSLocalizedString(@"hometown", @"出身地");
            } else if ([strKey isEqualToString:@"age"]) {
                cell.labelField.text = NSLocalizedString(@"age", @"年齢");
            } else if ([strKey isEqualToString:@"birthdate"]) {
                cell.labelField.text = NSLocalizedString(@"birthdate", @"誕生日");
            } else if ([strKey isEqualToString:@"bloodtype"]) {
                cell.labelField.text = NSLocalizedString(@"bloodtype", @"血液型");
            } else if ([strKey isEqualToString:@"occupation"]) {
                cell.labelField.text = NSLocalizedString(@"occupation", @"職業");
            } else if ([strKey isEqualToString:@"hobby"]) {
                cell.labelField.text = NSLocalizedString(@"hobby", @"趣味");
            } else if ([strKey isEqualToString:@"introduction"]) {
                cell.labelField.text = NSLocalizedString(@"introduction", @"自己紹介");
            } else if ([strKey isEqualToString:@"nationality"]) {
                cell.labelField.text = NSLocalizedString(@"nationality", @"国籍");
            }
            
            if ([strKey isEqualToString:@"gender"]) {
                switch ([[userDict objectForKey:strKey] integerValue]) {
                    case 1:
                        cell.labelDetail.text = NSLocalizedString(@"male", @"男性");
                        break;
                    case 2:
                        cell.labelDetail.text = NSLocalizedString(@"female", @"女性");
                        break;
                }
            } else if ([strKey isEqualToString:@"nationality"]) {
                NSLocale *locale = [NSLocale currentLocale];
                NSString *countryCode = [userDict objectForKey:strKey];
                NSString *displayNameString = [locale displayNameForKey:NSLocaleCountryCode value:countryCode];
                cell.labelDetail.text = displayNameString;
            } else {
                cell.labelDetail.text = [userDict objectForKey:strKey];
            }
            
            CGRect frame = cell.labelDetail.frame;
            CGSize size = [cell.labelDetail.text sizeWithFont:cell.labelDetail.font
                                            constrainedToSize:CGSizeMake(212.0, CGFLOAT_MAX)
                                                lineBreakMode:NSLineBreakByWordWrapping];
            frame.size.height = size.height;
            cell.labelDetail.frame = frame;
            
            return cell;
        }
            break;
    }
}

- (UIView *)viewForCalendarDay:(NSDate*)date {
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 100)];
    UIView *viewBg = [[UIView alloc] initWithFrame:CGRectMake(6, 3, 308, 100)];
    [view addSubview:viewBg];
    viewBg.backgroundColor = [UIColor whiteColor];
    viewBg.layer.cornerRadius = 5;
    viewBg.layer.masksToBounds = YES;
    view.backgroundColor = [UIColor colorWithRed:225.0/255.0 green:223.0/255.0 blue:217.0/255.0 alpha:1];
    NSInteger head = 0;
    CGFloat height = 0;
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(210, 2, 100, 50)];
    title.textColor = [UIColor colorWithRed:101.0/255.0	green:90.0/255.0 blue:56.0/255.0 alpha:0.5];
    title.backgroundColor = [UIColor clearColor];
    title.font = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:50];
    title.textAlignment = NSTextAlignmentRight;
    
    dateFormat.dateFormat = @"d";
    title.text = [dateFormat stringFromDate:date];
    
    [view addSubview:title];
    
    for (NSInteger i = 0; i < 25; i++) {
        [dateFormat setDateFormat:@"yyyyMMdd"];
        NSString* key = [NSString stringWithFormat:@"%@%02d", [dateFormat stringFromDate:date], i];
        UIFont *font = [UIFont fontWithName:@"HelveticaNeue-Light" size:10];
    
        if ([currentDayPics objectForKey:key] || i == 24) {
            if (head < i - 1) {
                UILabel *labelStart = [[UILabel alloc] initWithFrame:CGRectMake(6, height + 6, 50, 16)];
                labelStart.text = [NSString stringWithFormat:@"%02d:00", head];
                UILabel *labelEnd = [[UILabel alloc] initWithFrame:CGRectMake(6, height + 33, 50, 16)];
                labelEnd.text = [NSString stringWithFormat:@"%02d:00", i-1];
                
                labelEnd.textAlignment = NSTextAlignmentCenter;
                labelStart.textAlignment = NSTextAlignmentCenter;
                labelEnd.alpha = 0.5;
                labelStart.alpha = 0.5;
                labelEnd.font = font;
                labelStart.font = font;
                labelEnd.backgroundColor = [UIColor clearColor];
                labelStart.backgroundColor = [UIColor clearColor];
                
                [view addSubview:labelStart];
                [view addSubview:labelEnd];
                
                UIView *line = [[UIView alloc] initWithFrame:CGRectMake(30, height + 22, 1, 10)];
                line.backgroundColor = [UIColor colorWithWhite:0 alpha:0.4];
                
                [view addSubview:line];
                height += 52;
                
                UIImageView *sp = [[UIImageView alloc] initWithFrame:CGRectMake(12, height, 296, 1)];
                sp.image = [UIImage imageNamed:@"dotted_line.png"];
                sp.contentMode = UIViewContentModeCenter;
                [view addSubview:sp];
            } else if (head == i-1) {
                UILabel *labelStart = [[UILabel alloc] initWithFrame:CGRectMake(6, height + 6, 50, 16)];
                labelStart.text = [NSString stringWithFormat:@"%02d:00", head];
                labelStart.textAlignment = NSTextAlignmentCenter;
                labelStart.font = font;
                labelStart.backgroundColor = [UIColor clearColor];
                [view addSubview:labelStart];
                height += 45;
            }
        }
        
        if ([currentDayPics objectForKey:key]) {
            head += i+1;
            UILabel *labelStart = [[UILabel alloc] initWithFrame:CGRectMake(6, height + 6, 50, 16)];
            labelStart.text = [NSString stringWithFormat:@"%02d:00", i];
            labelStart.textAlignment = NSTextAlignmentCenter;
            labelStart.font = font;
            labelStart.backgroundColor = [UIColor clearColor];
            [view addSubview:labelStart];
            
            UIScrollView *scroll = [[UIScrollView alloc] initWithFrame:CGRectMake(62, height+8, 246, 80)];
            scroll.showsHorizontalScrollIndicator = NO;
            NSArray *pics = [currentDayPics objectForKey:key];
            for (NSInteger j = 0; j < pics.count; j++) {
                UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(j*82, 0, 80, 80)];
                button.layer.cornerRadius = 5;
                button.layer.masksToBounds = YES;
                Picture *pic = pics[j];
                button.tag = [pic.pictureId integerValue];
                [button loadBackground:pic.urlSquare];
                [button addTarget:self action:@selector(showPic:) forControlEvents:UIControlEventTouchUpInside];
                [scroll addSubview:button];
            }
            scroll.contentSize = CGSizeMake(pics.count*82-2, 80);
            [view addSubview:scroll];
            
            height += 95;
            
            UIImageView *sp = [[UIImageView alloc] initWithFrame:CGRectMake(12, height, 296, 1)];
            sp.image = [UIImage imageNamed:@"dotted_line.png"];
            sp.contentMode = UIViewContentModeCenter;
            [view addSubview:sp];
        }
    }
    height += 6;
    CGRect frame = view.frame;
    frame.size.height = height;
    view.frame = frame;
    
    frame = viewBg.frame;
    frame.size.height = height - 6;
    viewBg.frame = frame;
    return view;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)switchTimeline:(MypagePhotoMode)mode {
    if (photoMode != mode) {
        photoMode = mode;
        [self reloadTimeline];
    } else
        [self.tableView reloadData];
    
}

- (void)expandHeader {
    UIView *viewHeader = self.tableView.tableHeaderView;
    viewHeader.frame = CGRectMake(0, 0, 320, 120);
    self.tableView.tableHeaderView = viewHeader;
}

- (void)collapseHeader {
    UIView *viewHeader = self.tableView.tableHeaderView;
    viewHeader.frame = CGRectMake(0, 0, 320, 82);
    self.tableView.tableHeaderView = viewHeader;
}

- (void)touchTab:(MypageTableMode)mode {
    tableMode = mode;
    switch (mode) {
        case kTablePhoto:
            [self.tableView reloadData];
            break;
        case kTableProfile:
            [self.tableView reloadData];
            break;
        case kTableFollower:
            if (followers == nil)
                [self reloadFollower];
            else
                [self.tableView reloadData];
            break;
        case kTableFollowings:
            if (followings == nil)
                [self reloadFollowings];
            else
                [self.tableView reloadData];

            break;
    }
}

- (void)touchPhoto:(MypagePhotoMode)mode {
    switch (mode) {
        case kPhotoMyphoto:
            photoMode = mode;
            if (pictures.count == 0) {
                [self reloadPicList];
            } else
                [self.tableView reloadData];
            break;
        case kPhotoCalendar:
            photoMode = mode;
            [self reloadCalendar];
            break;
        case kPhotoFollowing:
        case kPhotoFriends:
        case kPhotoTimeline:
            [self switchTimeline:mode];
    }
}

- (void)touchSetProfilePic {
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"change_profile_pic", @"プロフィール")
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"cancel", @"キャンセル")
                                         destructiveButtonTitle:NSLocalizedString(@"remove_profile_pic", @"削除する")
                                              otherButtonTitles:NSLocalizedString(@"select_profile_pic", @"写真を選択する"), nil];
    [sheet showFromTabBar:self.tabBarController.tabBar];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (buttonIndex) {
        case 0:
            [self deleteProfilePic];
            break;
        case 1:
            [self pickPhoto];
            break;
        default:
            break;
    }
}

- (void)didPresentActionSheet:(UIActionSheet *)actionSheet {
    LXAppDelegate* app = (LXAppDelegate*)[UIApplication sharedApplication].delegate;
    if (app.currentUser.profilePicture == nil) {
        [actionSheet setButton:0 toState:false];
    }
}


- (void)deleteProfilePic {
    LXAppDelegate* app = (LXAppDelegate*)[UIApplication sharedApplication].delegate;
    
    [[LatteAPIClient sharedClient] postPath:@"user/me/profile_picture_delete"
                                 parameters:[NSDictionary dictionaryWithObjectsAndKeys:
                                             [app getToken], @"token", nil]
                                    success:^(AFHTTPRequestOperation *operation, NSDictionary *JSON) {
                                        [viewHeaderMypage.buttonProfilePic loadBackground:@"" placeholderImage:@"user.gif"];
                                    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                        DLog(@"Something went wrong (Delete profile pic)");
                                    }];

}

- (void)pickPhoto {
    LatteAPIClient *api = [LatteAPIClient sharedClient];
    if (api.networkReachabilityStatus == AFNetworkReachabilityStatusNotReachable) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"error", @"")
                                                        message:NSLocalizedString(@"Network connectivity is not available", @"")
                                                       delegate:nil
                                              cancelButtonTitle:NSLocalizedString(@"close", @"")
                                              otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    UIStoryboard* storySetting = [UIStoryboard storyboardWithName:@"Camera" bundle:nil];
    UINavigationController *navCamera = [storySetting instantiateInitialViewController];

    LXCaptureViewController *controllerCamera = navCamera.viewControllers[0];
    controllerCamera.delegate = self;
    
    [self presentViewController:navCamera animated:YES completion:nil];
}

- (void)imagePickerController:(LXCanvasViewController *)picker didFinishPickingMediaWithData:(NSDictionary *)info {
    UIViewController *tmp2 = picker.navigationController.presentingViewController;    
    [picker dismissModalViewControllerAnimated:NO];
    [tmp2 dismissModalViewControllerAnimated:YES];
    
    LXAppDelegate* app = (LXAppDelegate*)[UIApplication sharedApplication].delegate;
    
    MBProgressHUD *progessHUD = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:progessHUD];
    
    progessHUD.mode = MBProgressHUDModeDeterminate;
    [progessHUD show:YES];
    
    void (^createForm)(id<AFMultipartFormData>) = ^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFileData:[info objectForKey:@"data"]
                                    name:@"file"
                                fileName:@"latte.jpg"
                                mimeType:@"image/jpeg"];
    };
    
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            [app getToken], @"token", nil];
    
    NSURLRequest *request = [[LatteAPIClient sharedClient] multipartFormRequestWithMethod:@"POST"
                                                                                     path:@"user/me/profile_picture"
                                                                               parameters:params
                                                                constructingBodyWithBlock:createForm];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    void (^successUpload)(AFHTTPRequestOperation *, id) = ^(AFHTTPRequestOperation *operation, id responseObject) {
        progessHUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Checkmark.png"]];
        progessHUD.mode = MBProgressHUDModeCustomView;
        [progessHUD hide:YES afterDelay:1];
        
        [self reloadProfile];
    };
    
    void (^failUpload)(AFHTTPRequestOperation *, NSError *) = ^(AFHTTPRequestOperation *operation, NSError *error) {
        if([operation.response statusCode] != 200){
            DLog(@"Upload Failed");
            return;
        }
        DLog(@"error: %@", [operation error]);
        progessHUD.mode = MBProgressHUDModeText;
        progessHUD.labelText = @"Error";
        progessHUD.margin = 10.f;
        progessHUD.yOffset = 150.f;
        progessHUD.removeFromSuperViewOnHide = YES;
        
        [progessHUD hide:YES afterDelay:2];
    };
    
    [operation setCompletionBlockWithSuccess: successUpload failure: failUpload];
    
    [operation setUploadProgressBlock:^(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite) {
        progessHUD.progress = (float)totalBytesWritten/(float)totalBytesExpectedToWrite;
    }];
    
    [operation start];
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


- (void)showInfo:(UIButton*)sender {
    [self showPic:sender withTab:kGalleryTabInfo];
}

- (void)showPic:(UIButton*)sender withTab:(GalleryTab)tab {
    UIStoryboard *storyGallery = [UIStoryboard storyboardWithName:@"Gallery"
                                                           bundle:nil];
    UINavigationController *navGalerry = [storyGallery instantiateInitialViewController];
    LXGalleryViewController *viewGallery = navGalerry.viewControllers[0];
    viewGallery.delegate = self;
    switch (photoMode) {
        case kPhotoMyphoto:
            viewGallery.picture = pictures[sender.tag];
            viewGallery.user = _user;
            break;
        case kPhotoFollowing:
        case kPhotoTimeline:
        case kPhotoFriends: {
            Feed *feed = [LXUtils feedFromPicID:sender.tag of:feeds];
            if (isMypage)
                viewGallery.user = feed.user;
            else
                viewGallery.user = _user;
            viewGallery.picture = [LXUtils picFromPicID:sender.tag of:feeds];
            break;
        }
        case kPhotoCalendar:
            for (Picture *pic in currentMonthPicsFlat) {
                if ([pic.pictureId integerValue] == sender.tag) {
                    viewGallery.picture = pic;
                    viewGallery.user = _user;
                    break;
                }
            }
            
            break;
        default:
            break;
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"MainStoryboard"
                                                             bundle:nil];
    LXMyPageViewController *viewUserPage = [mainStoryboard instantiateViewControllerWithIdentifier:@"UserPage"];
    switch (tableMode) {
        case kTableFollower:
            viewUserPage.user = followers[indexPath.row];
            break;
        case kTableFollowings:
            viewUserPage.user = followings[indexPath.row];
            break;
        default:
            return;
    }
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
    switch (photoMode) {
        case kPhotoMyphoto: {
            NSUInteger current = [pictures indexOfObject:picture];
            if (current != NSNotFound && current < pictures.count-1) {
                NSDictionary *ret = [NSDictionary dictionaryWithObjectsAndKeys:
                                     pictures[current+1], @"picture",
                                     _user, @"user",
                                     nil];
                
                // Loadmore
                if (current > pictures.count - 6)
                    [self loadMore];
                return ret;
            }
            break;
        }
        case kPhotoFollowing:
        case kPhotoFriends:
        case kPhotoTimeline: {
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
                    [self loadMore];
                return ret;
            }
            break;
        };
        case kPhotoCalendar:{
            NSInteger current = [currentMonthPicsFlat indexOfObject:picture];
            if (current != NSNotFound && current < currentMonthPicsFlat.count-1) {
                NSDictionary *ret = [NSDictionary dictionaryWithObjectsAndKeys:
                                     currentMonthPicsFlat[current+1], @"picture",
                                     _user, @"user",
                                     nil];
                return ret;
            }
            break;
        }
    }
    return nil;
}

- (NSDictionary *)pictureBeforePicture:(Picture *)picture {    
    switch (photoMode) {
        case kPhotoMyphoto: {
            NSUInteger current = [pictures indexOfObject:picture];
            if (current != NSNotFound && current > 0) {
                NSDictionary *ret = [NSDictionary dictionaryWithObjectsAndKeys:
                                     pictures[current-1], @"picture",
                                     _user, @"user",
                                     nil];
                return ret;
            }
            break;
        }
        case kPhotoFollowing:
        case kPhotoFriends:
        case kPhotoTimeline: {
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

            break;
        }
        case kPhotoCalendar: {
            NSInteger current = [currentMonthPicsFlat indexOfObject:picture];
            if (current != NSNotFound && current > 0) {
                NSDictionary *ret = [NSDictionary dictionaryWithObjectsAndKeys:
                                     currentMonthPicsFlat[current-1], @"picture",
                                     _user, @"user",
                                     nil];
                return ret;
            }
            break;
        }
    }
    return nil;
}

- (void)showLike:(UIButton*)sender {
    [self showPic:sender withTab:kGalleryTabVote];
}


- (void)showComment:(UIButton*)sender {
    [self showPic:sender withTab:kGalleryTabComment];
}

- (void)showUser:(UIButton*)sender {
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"MainStoryboard"
                                                             bundle:nil];
    LXMyPageViewController *viewUserPage = [mainStoryboard instantiateViewControllerWithIdentifier:@"UserPage"];
    switch (tableMode) {
        case kTableFollower:
            
            break;
        case kTableFollowings:
            viewUserPage.user = followings[sender.tag];
            break;
        case kTablePhoto: {
            Feed *feed = feeds[sender.tag];
            viewUserPage.user = feed.user;
            break;
        }
        default:
            break;
    }
    [self.navigationController pushViewController:viewUserPage animated:YES];

}

- (void)showMap:(UIButton*)sender {
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Gallery"
                                                             bundle:nil];
    LXPicMapViewController *viewPicMap = [mainStoryboard instantiateViewControllerWithIdentifier:@"Map"];
    
    Feed *feed = [LXUtils feedFromPicID:sender.tag of:feeds];
    Picture *pic = feed.targets[0];
    viewPicMap.picture = pic;
    
    [self.navigationController pushViewController:viewPicMap animated:YES];
}

- (void)submitLike:(UIButton*)sender {
    Picture *pic = [LXUtils picFromPicID:sender.tag of:feeds];
    [LXUtils toggleLike:sender ofPicture:pic];
}

- (void)reloadTableViewDataSource{
    reloading = YES;
}

- (void)doneLoadingTableViewData{
    reloading = NO;
    [refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.tableView];
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

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    [refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
    
    //Load more
    switch (tableMode) {
        case kTablePhoto:
            if (photoMode == kPhotoMyphoto) {
                if (endedPic)
                    return;
            } if (photoMode == kPhotoCalendar) {
                return;
            } else if (endedTimeline)
                return;
            break;
        default:
            return;
            break;
    }
    
    CGPoint offset = scrollView.contentOffset;
    CGRect bounds = scrollView.bounds;
    CGSize size = scrollView.contentSize;
    UIEdgeInsets inset = scrollView.contentInset;
    float y = offset.y + bounds.size.height - inset.bottom;
    float h = size.height;
    
    float reload_distance = -100;
    if(y > h + reload_distance) {
        [self loadMore];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:NO animated:animated];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    [refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
}

@end
