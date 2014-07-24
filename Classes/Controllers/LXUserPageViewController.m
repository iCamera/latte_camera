//
//  luxeysMypageViewController.m
//  Latte
//
//  Created by Xuan Dung Bui on 8/22/12.
//  Copyright (c) 2012 LUXEYS. All rights reserved.
//

#import "LXUserPageViewController.h"

#import "LXAppDelegate.h"
#import "LatteAPIClient.h"
#import "LatteAPIv2Client.h"
#import "UIImageView+AFNetworking.h"
#import "LXCellFriend.h"
#import "LXUtils.h"
#import "UIButton+AFNetworking.h"
#import "LXPicInfoViewController.h"
#import "User.h"
#import "Picture.h"
#import "UIActionSheet+ButtonState.h"
#import "LXCellTimelineSingle.h"
#import "LXCellTimelineMulti.h"
#import "MBProgressHUD.h"
#import "LXPhotoGridCVC.h"
#import "LXReportAbuseUserViewController.h"

#import "LXCellGrid.h"
#import "LXCellDataField.h"
#import "NSDate+TKCategory.h"
#import "LXUserProfileViewController.h"
#import "MZFormSheetSegue.h"
#import "LXUserListViewController.h"
#import "LXSocketIO.h"

#import "UIImageView+LBBlurredImage.h"
#import "UIImage+ImageEffects.h"

CGFloat const kMGOffsetEffects = 40.0;
CGFloat const kMGOffsetBlurEffect = 2.0;

typedef enum {
    kPhotoTimeline = 0,
    kPhotoGrid = 1,
    kPhotoTag = 2,
    kPhotoCalendar = 3,
} UserPagePhotoMode;

@interface LXUserPageViewController ()

@end

@implementation LXUserPageViewController  {
    NSInteger daysInMonth;
    
    UserPagePhotoMode photoMode;
    NSDictionary *userv2;
    NSArray *allTab;
    BOOL reloading;
    BOOL endedPic;
    
    int pagePic;
    int pageVote;
    NSMutableArray *pictures;
    
    NSMutableDictionary *currentMonthPics;
    NSMutableDictionary *currentDayPics;
    NSMutableArray *feeds;
    NSArray *tags;
    
    NSDate *currentMonth;
    NSDate *selectedCalendarDate;
    NSMutableArray *currentMonthPicsFlat;
    
    AFHTTPRequestOperation *currentRequest;
    UIButton *buttonScroll;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)awakeFromNib {
    
}

- (void)setUser:(User *)user {
    _user = user;
    _userId = [user.userId integerValue];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    feeds = [[NSMutableArray alloc] init];
    pictures = [[NSMutableArray alloc] init];
    

    endedPic = false;
    
    pagePic = 0;
    pageVote = 0;
    currentMonth = [NSDate date];
    
    LXAppDelegate* app = [LXAppDelegate currentDelegate];
    
    [app.tracker set:kGAIScreenName
               value:@"User Screen"];
    
    [app.tracker send:[[GAIDictionaryBuilder createAppView] build]];
    
    photoMode = kPhotoTimeline;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userUpdate:) name:@"user_update" object:nil];
    
    // Increase count
    NSString *url = [NSString stringWithFormat:@"user/counter/%ld", (long)_userId];
    
    
    [[LatteAPIClient sharedClient] GET:url parameters:nil success:nil failure:nil];
    
    _buttonUser.layer.cornerRadius = 30;
    _buttonUser.layer.borderWidth = 2;
    _buttonUser.layer.borderColor = [[UIColor whiteColor] CGColor];
    
    _labelUsername.text = _user.name;
    
    [self.tableView registerNib:[UINib nibWithNibName:@"LXCellTimelineSingle" bundle:nil] forCellReuseIdentifier:@"Single"];
    [self.tableView registerNib:[UINib nibWithNibName:@"LXCellTimelineMulti" bundle:nil] forCellReuseIdentifier:@"Multi"];
    [self.tableView registerNib:[UINib nibWithNibName:@"LXCellTag" bundle:nil] forCellReuseIdentifier:@"Tag"];
    
    
    if (!app.currentUser) {
        _buttonMore.hidden = YES;
    }

    if (app.currentUser && (_userId == [app.currentUser.userId integerValue])) {
        _buttonFollow.hidden = YES;
        _buttonMore.hidden = YES;
    }
    
    LXSocketIO *socket = [LXSocketIO sharedClient];
    [socket sendEvent:@"join" withData:[NSString stringWithFormat:@"user_%ld", (long)_userId]];
    
    buttonScroll = [[UIButton alloc] initWithFrame:CGRectMake(120, 10, 80, 30)];
    buttonScroll.layer.cornerRadius = 15;
    buttonScroll.layer.borderColor = [[UIColor whiteColor] CGColor];
    buttonScroll.layer.borderWidth = 2;
    [buttonScroll setTitleColor:[UIColor colorWithRed:53.0/255.0 green:48.0/255.0 blue:34.0/255.0 alpha:1] forState:UIControlStateNormal];
    buttonScroll.titleLabel.font = [UIFont fontWithName:@"Futura-CondensedMedium" size:14];
    
    buttonScroll.backgroundColor = [UIColor colorWithRed:222.0/255.0 green:238.0/255.0 blue:236.0/255.0 alpha:1];
    
    [buttonScroll setTitle:@"TOP" forState:UIControlStateNormal];
    [buttonScroll addTarget:self action:@selector(jumpToTop:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:buttonScroll];
    buttonScroll.enabled = NO;
    buttonScroll.alpha = 0;
    
    [self renderProfile];
    [self reloadProfile];
    [self loadTimeline:YES];
}

- (void)jumpToTop:(id)sender {
    [self.tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
}

- (void)viewWillAppear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    [super viewWillDisappear:animated];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)renderProfile {
    [UIView transitionWithView:self.tableView.tableHeaderView
                      duration:kGlobalAnimationSpeed
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{
                        [_buttonUser setBackgroundImageForState:UIControlStateNormal withURL:[NSURL URLWithString:_user.profilePicture]];
                        [_buttonFollower setTitle:[_user.countFollowers stringValue] forState:UIControlStateNormal];
                        [_buttonFollowing setTitle:[_user.countFollows stringValue] forState:UIControlStateNormal];
                        _labelIntro.text = _user.introduction;
                    } completion:nil];
}


- (void)reloadProfile {
    NSString *url = [NSString stringWithFormat:@"user/%ld", (long)_userId];
    LXAppDelegate* app = [LXAppDelegate currentDelegate];
    
    [[LatteAPIv2Client sharedClient] GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, NSDictionary *JSON) {
        userv2 = JSON;
        
        if (JSON[@"cover_picture"]) {
            [_imageCover setImageWithURL:[NSURL URLWithString:JSON[@"cover_picture"]]];
        } else if (JSON[@"profile_picture"]) {
            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:JSON[@"profile_picture"]]];
            [request addValue:@"image/*" forHTTPHeaderField:@"Accept"];
            
            __weak __typeof(UIImageView*)weakSelf = _imageCover;
            [_imageCover setContentMode:UIViewContentModeScaleAspectFill];
            [_imageCover setImageWithURLRequest:request
                               placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                   __strong __typeof(weakSelf)strongSelf = weakSelf;
                                   UIImage *darkBg = [image applyBlurWithRadius:5 tintColor:[UIColor colorWithWhite:0.11 alpha:0.1] saturationDeltaFactor:1.8 maskImage:nil];
                                   [strongSelf setImage:darkBg];
                                   //[strongSelf setImageToBlur:darkBg blurRadius:5.0 completionBlock:nil];
                               } failure:nil];
            
        }
        

        _labelUsername.text = JSON[@"name"];
        
        _user.profilePicture = JSON[@"profile_picture"];
        _user.countFollows = JSON[@"count_follows"];
        _user.countFollowers = JSON[@"count_followers"];
        _user.introduction = JSON[@"introduction"];
        
        [self renderProfile];

        
        if (app.currentUser) {
            _buttonFollow.enabled = ![JSON[@"is_blocking"] boolValue];
            _buttonFollow.selected = [JSON[@"is_following"] boolValue];
            if ([JSON[@"is_following"] boolValue]) {
                
                if ([JSON[@"is_followed_by"] boolValue]) {
                    [_buttonFollow setImage:[UIImage imageNamed:@"icon40-f4f.png"] forState:UIControlStateSelected];
                } else {
                    [_buttonFollow setImage:[UIImage imageNamed:@"icon40-followed.png"] forState:UIControlStateSelected];
                }
            }
            
        }
    } failure:nil];
}

- (void)loadTimeline:(BOOL)reset {
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];

    if (reset) {
        endedPic = false;
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        
        if (currentRequest)
            [currentRequest cancel];
    } else {
        if (currentRequest.isExecuting)
            return;
        Feed *feed = feeds.lastObject;
        if (feed) {
            [params setObject:feed.feedID forKey:@"last_id"];
        }
        [_indicatorLoad startAnimating];
    }
    
    
    NSString *url = [NSString stringWithFormat:@"user/%ld/timeline", (long)_userId];
    
    currentRequest = [[LatteAPIClient sharedClient] GET: url
                            parameters: params
                               success:^(AFHTTPRequestOperation *operation, NSDictionary *JSON) {
                                   
                                   NSMutableArray *newFeed = [Feed mutableArrayFromDictionary:JSON
                                                                                      withKey:@"feeds"];
                                   
                                   endedPic = newFeed.count == 0;
                                   
                                   if (reset) {
                                       feeds = newFeed;
                                       [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                                       photoMode = kPhotoTimeline;
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
                                           
                                           [self.tableView beginUpdates];
                                           [feeds addObjectsFromArray:newFeed];
                                           [self.tableView insertRowsAtIndexPaths:arrayOfIndexPaths withRowAnimation:UITableViewRowAnimationBottom];
                                           [self.tableView endUpdates];
                                       }
                                   }
                                   
                                   [_indicatorLoad stopAnimating];
                               } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                   if (reset) {
                                       [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                                       [self.refreshControl endRefreshing];
                                   }
                                   [_indicatorLoad stopAnimating];
                               }];
}

- (void)loadTag {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    if (currentRequest)
        [currentRequest cancel];
    
    currentRequest = [[LatteAPIv2Client sharedClient] GET: @"picture"
                                               parameters: @{@"user_id": [NSNumber numberWithInteger:_userId]}
                                                success:^(AFHTTPRequestOperation *operation, NSDictionary *JSON) {
                                                    
                                                    tags = JSON[@"result"][@"facets"][@"tags"][@"terms"];
                                                    photoMode = kPhotoTag;
                                                    endedPic = YES;
                                                    
                                                    [self.tableView reloadData];
                                                    [self.refreshControl endRefreshing];
                                                    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                                                } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                                                    [self.refreshControl endRefreshing];
                                                }];
}


- (void)loadPicture:(BOOL)reset {
    if (reset) {
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        pagePic = 1;
        
        if (currentRequest)
            [currentRequest cancel];
    } else {
        if (currentRequest.isExecuting)
            return;
        
        [_indicatorLoad startAnimating];
    }

    NSDictionary *param = @{@"page": [NSNumber numberWithInteger:pagePic],
                            @"limit": [NSNumber numberWithInt:30]};

    NSString *url = [NSString stringWithFormat:@"picture/user/%ld", (long)_userId];
    currentRequest = [[LatteAPIClient sharedClient] GET:url
                                parameters: param
                                   success:^(AFHTTPRequestOperation *operation, NSDictionary *JSON) {
                                       pagePic += 1;
                                       
                                       NSArray *newPics = [Picture mutableArrayFromDictionary:JSON
                                                                              withKey:@"pictures"];

                                       endedPic = newPics.count == 0;
                                       
                                       if (reset) {
                                           pictures = [NSMutableArray arrayWithArray:newPics];
                                           [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                                           photoMode = kPhotoGrid;
                                           [self.tableView reloadData];
                                       } else {
                                           if (newPics.count > 0) {
                                               NSInteger rowCountPrev = [self.tableView numberOfRowsInSection:0];
                                               
                                               [pictures addObjectsFromArray:newPics];
                                               
                                               NSInteger newRows = [self tableView:self.tableView numberOfRowsInSection:0] - rowCountPrev;
                                               
                                               if (newRows > 0) {
                                                   NSMutableArray *paths = [[NSMutableArray alloc] init];
                                                   for (int i = 0; i < newRows ; i++) {
                                                       [paths addObject:[NSIndexPath indexPathForRow:i+rowCountPrev inSection:0]];
                                                   }
                                                   [self.tableView insertRowsAtIndexPaths:paths withRowAnimation:UITableViewRowAnimationAutomatic];
                                               } else {
                                                   [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:rowCountPrev-1 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
                                               }

                                           }
                                       }
                                       
                                       
                                       [self.refreshControl endRefreshing];
                                       [_indicatorLoad stopAnimating];
                                   } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                       endedPic = true;
                                       if (reset) {
                                           [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                                       }
                                       [self.refreshControl endRefreshing];
                                       [_indicatorLoad stopAnimating];
                                   }];
}



- (void)reloadView {
    endedPic = false;

    if (photoMode == kPhotoTimeline) {
         [self loadTimeline:YES];
    } else if (photoMode == kPhotoGrid) {
        [self loadPicture:YES];
    } else if (photoMode == kPhotoTag) {
        [self loadTag];
    } else if (photoMode == kPhotoCalendar)
        [self reloadCalendar];
}

- (IBAction)refresh:(id)sender {
    [self reloadView];
}

- (IBAction)switchView:(UIButton*)sender {
    [UIView transitionWithView:self.tableView.tableHeaderView
                      duration:kGlobalAnimationSpeed
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{
                        _buttonTabTimeline.selected = NO;
                        _buttonTabGrid.selected = NO;
                        _buttonTabTag.selected = NO;
                        _buttonTabCalendar.selected = NO;
                        
                        sender.selected = YES;

                    }
                    completion:nil];
    
    switch (sender.tag) {
        case 0:
            [self loadTimeline:YES];
            break;
        case 1:
            [self loadPicture:YES];
            break;
        case 2:
            [self loadTag];
            break;
        case 3:
            [self reloadCalendar];
            break;
        default:
            break;
    }
}

- (IBAction)touchFollow:(id)sender {
    LXAppDelegate* app = [LXAppDelegate currentDelegate];
    if (!app.currentUser) {
        UIStoryboard *storyAuth = [UIStoryboard storyboardWithName:@"Authentication" bundle:nil];
        UIViewController *viewLogin = [storyAuth instantiateInitialViewController];
        
        [self presentViewController:viewLogin animated:YES completion:nil];
    } else {
        if (!_user.isFollowing) {
            _buttonFollow.selected = YES;
            _user.isFollowing = YES;
            
            [[LatteAPIClient sharedClient] POST:[NSString stringWithFormat:@"user/follow/%ld", (long)_userId]
                                     parameters:nil
                                        success:nil
                                        failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                            _buttonFollow.selected = NO;
                                            _user.isFollowing = NO;
                                        }];
            
        } else {
            UIActionSheet *actionUnfollow = [[UIActionSheet alloc] initWithTitle:nil
                                                                        delegate:self
                                                               cancelButtonTitle:NSLocalizedString(@"cancel", @"")
                                                          destructiveButtonTitle:NSLocalizedString(@"unfollow", @"")
                                                               otherButtonTitles:nil];
            actionUnfollow.tag = 99;
            [actionUnfollow showInView:self.view];
        }
    }
}

- (IBAction)touchMore:(id)sender {
    if ([userv2[@"is_blocking"] boolValue]) {
        UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil
                                                           delegate:self
                                                  cancelButtonTitle:NSLocalizedString(@"cancel", @"キャンセル")
                                             destructiveButtonTitle:NSLocalizedString(@"Unblock User", @"ブロックを解除")
                                                  otherButtonTitles:NSLocalizedString(@"report", @""), nil];
        [sheet showInView:self.view];
    } else {
        UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil
                                                           delegate:self
                                                  cancelButtonTitle:NSLocalizedString(@"cancel", @"キャンセル")
                                             destructiveButtonTitle:NSLocalizedString(@"Block User", @"ブロックする")
                                                  otherButtonTitles:NSLocalizedString(@"report", @""), nil];
        [sheet showInView:self.view];
    }
}

- (IBAction)touchBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)loadMore {
    if (photoMode == kPhotoTimeline) {
        [self loadTimeline:NO];
    } else if (photoMode == kPhotoGrid)
        [self loadPicture:NO];
}

- (void)reloadCalendar {
    selectedCalendarDate = nil;
    LXAppDelegate* app = (LXAppDelegate*)[[UIApplication sharedApplication] delegate];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyyMM"];
    
    NSString* urlPhotos = [NSString stringWithFormat:@"picture/album/by_month/%@/%ld", [dateFormat stringFromDate:currentMonth], (long)_userId];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    if (currentRequest) {
        [currentRequest cancel];
    }

    currentRequest = [[LatteAPIClient sharedClient] GET:urlPhotos
                                parameters: [NSDictionary dictionaryWithObjectsAndKeys:[app getToken], @"token", nil]
                                   success:^(AFHTTPRequestOperation *operation, NSDictionary *JSON) {
                                       photoMode = kPhotoCalendar;
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
                                       
                                       [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                                       
                                   } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                       DLog(@"Something went wrong (User - Calendar)");
                                       [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                                   }];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (photoMode == kPhotoCalendar) {
        NSArray *rangeDates = [LXUtils rangeOfDatesInMonthGrid:currentMonth startOnSunday:YES timeZone:[NSTimeZone localTimeZone]];
        NSUInteger numberOfDaysBetween = [rangeDates[0] daysBetweenDate:[rangeDates lastObject]] + 1;
        return numberOfDaysBetween/7 + 2;
    } else
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (photoMode == kPhotoTimeline) {
        return feeds.count;
    } else if (photoMode == kPhotoGrid) {
        return (pictures.count/3) + (pictures.count%3>0?1:0);
    } else if (photoMode == kPhotoTag) {
        return tags.count;
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
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (photoMode == kPhotoTimeline) {
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
    
    if (photoMode == kPhotoTag) {
        return 44;
    }

    if (photoMode == kPhotoGrid) {
        return 104;
    }
    
    if (photoMode == kPhotoCalendar) {
        if (selectedCalendarDate) {
            UIView *view = [self viewForCalendarDay:selectedCalendarDate];
            return view.frame.size.height;
        } else
            return 0;
        
    }
    
    return 22;
}

- (BOOL)checkEmpty {
    BOOL isEmpty = false;
    if (photoMode == kPhotoTimeline) {
        isEmpty = feeds.count == 0 && endedPic;
    }
    if (photoMode == kPhotoGrid) {
        isEmpty = pictures.count == 0 && endedPic;
    }
    return isEmpty;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if ([self checkEmpty]) {
        UIView *emptyView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 200)];
        UIImageView *emptyImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"nopict.png"]];
        emptyImage.center = emptyView.center;
        [emptyView addSubview:emptyImage];
        return emptyView;
    }
    
    if (photoMode == kPhotoCalendar) {
        NSArray *rangeDates = [LXUtils rangeOfDatesInMonthGrid:currentMonth startOnSunday:YES timeZone:[NSTimeZone localTimeZone]];
        NSUInteger numberOfDaysBetween = [rangeDates[0] daysBetweenDate:[rangeDates lastObject]] + 1;
        NSUInteger headerCount = numberOfDaysBetween/7;
        
        if (section == 0 || section == headerCount + 1) {
            UIView *view = [[UIView alloc] init];
            view.backgroundColor = [UIColor whiteColor];
            
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 5, 100, 30)];
            label.textAlignment = NSTextAlignmentCenter;
            
            UIImageView *imagePrev = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"arrow_left2.png"]];
            imagePrev.frame = CGRectMake(5, 14, 5, 8);
            UIImageView *imageNext = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"arrow_right2.png"]];
            imageNext.frame = CGRectMake(310, 14, 5, 8);
            
            UIButton *prevYear = [[UIButton alloc] initWithFrame:CGRectMake(50, 3, 60, 30)];
            UIButton *nextYear = [[UIButton alloc] initWithFrame:CGRectMake(205, 3, 60, 30)];
            [prevYear setImage:[UIImage imageNamed:@"arrow_left3.png"] forState:UIControlStateNormal];
            [nextYear setImage:[UIImage imageNamed:@"arrow_right3.png"] forState:UIControlStateNormal];
            [prevYear addTarget:self action:@selector(prevYear:) forControlEvents:UIControlEventTouchUpInside];
            [nextYear addTarget:self action:@selector(nextYear:) forControlEvents:UIControlEventTouchUpInside];
            
            UIButton *prev = [[UIButton alloc] initWithFrame:CGRectMake(5, 3, 60, 30)];
            UIButton *next = [[UIButton alloc] initWithFrame:CGRectMake(255, 3, 60, 30)];
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
//            [view addSubview:prevYear];
//            [view addSubview:nextYear];
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
                    
                    [button setBackgroundImageForState:UIControlStateNormal withURL:[NSURL URLWithString:pic.urlSquare]];
                    
                    button.tag = (section-1)*7 + i;
                    [button addTarget:self action:@selector(showDay:) forControlEvents:UIControlEventTouchUpInside];
                    UIImageView *medal = [[UIImageView alloc] initWithFrame:CGRectMake(i*44+16, 4, 12, 13)];
                    medal.image = [UIImage imageNamed:@"calendar_label.png"];
                    CGRect frame = medal.bounds;
                    frame.size.height -= 2;
                    UILabel *label = [[UILabel alloc] initWithFrame:frame];
                    label.text = [NSString stringWithFormat:@"%ld", (long)components.day];
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
                        label.text = [NSString stringWithFormat:@"%ld", (long)components.day];
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

- (void)nextYear:(id)sender {
    NSDateComponents* dateComponents = [[NSDateComponents alloc]init];
    [dateComponents setYear:1];
    NSCalendar* calendar = [NSCalendar currentCalendar];
    currentMonth = [calendar dateByAddingComponents:dateComponents toDate:currentMonth options:0];
    [self reloadCalendar];
}

- (void)prevYear:(id)sender {
    NSDateComponents* dateComponents = [[NSDateComponents alloc]init];
    [dateComponents setYear:-1];
    NSCalendar* calendar = [NSCalendar currentCalendar];
    currentMonth = [calendar dateByAddingComponents:dateComponents toDate:currentMonth options:0];
    [self reloadCalendar];
}



- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if ([self checkEmpty])
        return 200;
    if (photoMode == kPhotoCalendar) {
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
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (photoMode == kPhotoTimeline) {
        Feed *feed = [feeds objectAtIndex:indexPath.row];
        if (feed.targets.count == 1) {
            
            LXCellTimelineSingle *cell = [tableView dequeueReusableCellWithIdentifier:@"Single" forIndexPath:indexPath];
            
            cell.viewController = self;
            feed.user = _user;
            cell.feed = feed;
            cell.buttonUser.tag = indexPath.row;
            
            return cell;
        } else {
            LXCellTimelineMulti *cell = [tableView dequeueReusableCellWithIdentifier:@"Multi" forIndexPath:indexPath];
            
            cell.parent = self;
            feed.user = _user;
            cell.feed = feed;
            cell.buttonUser.tag = indexPath.row;
            
            return cell;
        }
    } else if (photoMode == kPhotoGrid) {
        LXCellGrid *cellPic = [tableView dequeueReusableCellWithIdentifier:@"Grid" forIndexPath:indexPath];
        
        cellPic.viewController = self;
        [cellPic setPictures:pictures forRow:indexPath.row];
        
        return cellPic;
    } else if (photoMode == kPhotoTag) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Tag" forIndexPath:indexPath];
        cell.textLabel.text = tags[indexPath.row][@"term"];
        cell.detailTextLabel.text = [tags[indexPath.row][@"count"] stringValue];
        return cell;
    } else if (photoMode == kPhotoCalendar) {
        UITableViewCell *cell = [[UITableViewCell alloc] init];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        [cell addSubview:[self viewForCalendarDay:selectedCalendarDate]];
        return cell;
    }
    return nil;
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
        NSString* key = [NSString stringWithFormat:@"%@%02ld", [dateFormat stringFromDate:date], (long)i];
        UIFont *font = [UIFont fontWithName:@"HelveticaNeue-Light" size:10];
    
        if ([currentDayPics objectForKey:key] || i == 24) {
            if (head < i - 1) {
                UILabel *labelStart = [[UILabel alloc] initWithFrame:CGRectMake(6, height + 6, 50, 16)];
                labelStart.text = [NSString stringWithFormat:@"%02ld:00", (long)head];
                UILabel *labelEnd = [[UILabel alloc] initWithFrame:CGRectMake(6, height + 33, 50, 16)];
                labelEnd.text = [NSString stringWithFormat:@"%02ld:00", (long)i-1];
                
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
                labelStart.text = [NSString stringWithFormat:@"%02ld:00", (long)head];
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
            labelStart.text = [NSString stringWithFormat:@"%02ld:00", (long)i];
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
                
                [button setBackgroundImageForState:UIControlStateNormal withURL:[NSURL URLWithString:pic.urlSquare]];
                
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

- (void)becomeActive:(NSNotification *) notification {
    LXAppDelegate* app = (LXAppDelegate*)[UIApplication sharedApplication].delegate;
    if (app.currentUser != nil) {
        [self reloadView];
    }
}


- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (actionSheet.tag == 99) {
        if (buttonIndex == 0) {
            _buttonFollow.selected = NO;
            _user.isFollowing = NO;
            
            [[LatteAPIClient sharedClient] POST:[NSString stringWithFormat:@"user/unfollow/%ld", (long)_userId]
                                     parameters:nil
                                        success:nil
                                        failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                            _buttonFollow.selected = !_buttonFollow.selected;
                                            _user.isFollowing = _buttonFollow.selected;
                                        }];
        }
    } else {
        switch (buttonIndex) {
            case 0: {
                if ([userv2[@"is_blocking"] boolValue]) {
                    NSString *url = [NSString stringWithFormat:@"user/%ld/unblock", (long)_userId];
                    [[LatteAPIv2Client sharedClient] POST:url parameters:nil success:^(AFHTTPRequestOperation *operation, NSDictionary *JSON) {
                        [self reloadProfile];
                    } failure:nil];
                } else {
                    NSString *url = [NSString stringWithFormat:@"user/%ld/block", (long)_userId];
                    [[LatteAPIv2Client sharedClient] POST:url parameters:nil success:^(AFHTTPRequestOperation *operation, NSDictionary *JSON) {
                        [self reloadProfile];
                    } failure:nil];
                }
            }
                break;
            case 1: {
                UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
                LXReportAbuseUserViewController *viewReport = [mainStoryboard instantiateViewControllerWithIdentifier:@"ReportUser"];
                
                viewReport.user = _user;
                
                [self.navigationController pushViewController:viewReport animated:YES];
            }
            default:
                break;
        }
    }
}

- (void)showPic:(UIButton*)sender {
    UIStoryboard *storyGallery = [UIStoryboard storyboardWithName:@"Gallery"
                                                           bundle:nil];
    UINavigationController *navGalerry = [storyGallery instantiateInitialViewController];
    LXGalleryViewController *viewGallery = navGalerry.viewControllers[0];
    viewGallery.delegate = self;
    switch (photoMode) {
        case kPhotoGrid:
            viewGallery.picture = pictures[sender.tag];
            viewGallery.user = _user;
            break;
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
    
    [self presentViewController:navGalerry animated:YES completion:nil];
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
        case kPhotoTimeline:{
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
                    [self loadTimeline:NO];
                return ret;
            }
            
            break;
        }
            
        case kPhotoGrid: {
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
        default:
            return nil;
    }
    return nil;
}

- (NSDictionary *)pictureBeforePicture:(Picture *)picture {    
    switch (photoMode) {
        case kPhotoTimeline:{
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
        case kPhotoGrid: {
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
        default:
            return nil;
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (photoMode == kPhotoTag) {
        UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
        LXPhotoGridCVC *viewLikedGrid = [mainStoryboard instantiateViewControllerWithIdentifier:@"PhotoGrid"];
        viewLikedGrid.keyword = tags[indexPath.row][@"term"];
        viewLikedGrid.userId = _userId;
        viewLikedGrid.gridType = kPhotoGridUserTag;
        [self.navigationController pushViewController:viewLikedGrid animated:YES];
    }
}

- (void)showUser:(User *)user fromGallery:(LXGalleryViewController *)gallery {
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"MainStoryboard"
                                                             bundle:nil];
    LXUserPageViewController *viewUserPage = [mainStoryboard instantiateViewControllerWithIdentifier:@"UserPage"];
    viewUserPage.user = user;
    [self.navigationController pushViewController:viewUserPage animated:YES];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"Profile"]) {
        LXUserProfileViewController *view = segue.destinationViewController;
        view.user = _user;
    }
    
    if ([segue.identifier isEqualToString:@"Follower"]) {
        LXUserListViewController *view = segue.destinationViewController;
        [view loadFollowerForUser:[_user.userId integerValue]];
    }
    
    if ([segue.identifier isEqualToString:@"Following"]) {
        LXUserListViewController *view = segue.destinationViewController;
        [view loadFollowingForUser:[_user.userId integerValue]];
    }
    
    MZFormSheetSegue *sheet = (MZFormSheetSegue*)segue;
    sheet.formSheetController.transitionStyle = MZFormSheetTransitionStyleSlideFromBottom;
    sheet.formSheetController.cornerRadius = 0;
    sheet.formSheetController.shouldDismissOnBackgroundViewTap = YES;
    sheet.formSheetController.presentedFormSheetSize = CGSizeMake(320, self.view.bounds.size.height - sheet.formSheetController.portraitTopInset);
}


- (void)scrollViewDidScroll:(UIScrollView *)aScrollView {
    CGRect floatingButtonFrame = buttonScroll.frame;
    floatingButtonFrame.origin.y = aScrollView.contentOffset.y + 10;
    buttonScroll.frame = floatingButtonFrame;
    
    if (aScrollView.contentOffset.y > self.tableView.bounds.size.height) {
        buttonScroll.enabled = YES;
        [UIView animateWithDuration:kGlobalAnimationSpeed animations:^{
            buttonScroll.alpha = 1;
        }];
    } else {
        buttonScroll.enabled = NO;
        [UIView animateWithDuration:kGlobalAnimationSpeed animations:^{
            buttonScroll.alpha = 0;
        }];
    }
    
    if (photoMode == kPhotoGrid || photoMode == kPhotoTimeline) {
        if (endedPic)
            return;
        CGPoint offset = aScrollView.contentOffset;
        CGRect bounds = aScrollView.bounds;
        CGSize size = aScrollView.contentSize;
        UIEdgeInsets inset = aScrollView.contentInset;
        float y = offset.y + bounds.size.height - inset.bottom;
        float h = size.height;
        
        float reload_distance = -100;
        if(y > h + reload_distance) {
            [self loadMore];
        }
    }
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

- (void)userUpdate:(NSNotification*)notify {
    NSDictionary *raw = notify.object;
    if (_userId == [raw[@"id"] longValue]) {
        
    }
}

@end
