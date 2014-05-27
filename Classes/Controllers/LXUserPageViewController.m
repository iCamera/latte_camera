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
#import "UIImageView+AFNetworking.h"
#import "LXCellFriend.h"
#import "LXUtils.h"
#import "UIButton+AFNetworking.h"
#import "LXPicInfoViewController.h"
#import "LXPicMapViewController.h"
#import "User.h"
#import "Picture.h"
#import "UIActionSheet+ButtonState.h"
#import "LXCellTimelineSingle.h"
#import "LXCellTimelineMulti.h"
#import "LXVoteViewController.h"
#import "MBProgressHUD.h"

#import "LXCellGrid.h"
#import "LXCellDataField.h"
#import "NSDate+TKCategory.h"

typedef enum {
    kTablePhoto = 0,
    kTableTag = 1,
    kTableFollower = 2,
    kTableFollowings = 3,
} UserTableMode;

typedef enum {
    kPhotoGrid = 0,
    kPhotoCalendar = 1,
} UserPagePhotoMode;

@interface LXUserPageViewController ()

@end

@implementation LXUserPageViewController  {
    NSMutableSet *showSet;
    NSArray *showField;
    NSDictionary *userDict;
    NSInteger daysInMonth;
    
    UserPagePhotoMode photoMode;
    NSArray *allTab;
    BOOL reloading;
    BOOL endedPic;
    
    int pagePic;
    int pageVote;
    NSMutableArray *pictures;
    NSMutableArray *followers;
    NSMutableArray *followings;
    NSMutableDictionary *currentMonthPics;
    NSMutableDictionary *currentDayPics;
    
    NSDate *currentMonth;
    NSDate *selectedCalendarDate;
    NSMutableArray *currentMonthPicsFlat;
    MBProgressHUD *HUD;
    
    UserTableMode tableMode;
    
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
    
    pagePic = 0;
    pageVote = 0;
    currentMonth = [NSDate date];
    
    LXAppDelegate* app = [LXAppDelegate currentDelegate];
    
    [app.tracker set:kGAIScreenName
               value:@"User Screen"];
    
    [app.tracker send:[[GAIDictionaryBuilder createAppView] build]];
    
    photoMode = kPhotoGrid;
    
    // Increase count
    NSString *url = [NSString stringWithFormat:@"user/counter/%ld",[_user.userId longValue]];
    
    [[LatteAPIClient sharedClient] GET:url parameters:nil success:nil failure:nil];
    
    HUD = [[MBProgressHUD alloc] initWithView:app.viewMainTab.view];
    HUD.userInteractionEnabled = NO;
    [app.viewMainTab.view addSubview:HUD];
    HUD.mode = MBProgressHUDModeText;
    HUD.labelText = NSLocalizedString(@"Loading...", @"Loading...") ;
    HUD.labelFont = [UIFont fontWithName:@"HelveticaNeue-Light" size:16];
    HUD.margin = 10.f;
    HUD.yOffset = 150.f;
    
    [self reloadView];
}



- (void)reloadProfile {    
    NSString *url = [NSString stringWithFormat:@"user/%ld", [_user.userId longValue]];
    [[LatteAPIClient sharedClient] GET:url
                                parameters: nil
                                   success:^(AFHTTPRequestOperation *operation, NSDictionary *JSON) {
                                       userDict = JSON[@"user"];
                                       User *user = [User instanceFromDictionary:userDict];
                                       UIButton *button;
                                       [button setImageForState:UIControlStateNormal withURL:[NSURL URLWithString:user.profilePicture] placeholderImage:nil];
                                       
                                       NSSet *allField = [NSSet setWithArray:[userDict allKeys]];
                                       
                                       [showSet intersectSet:allField];
                                       showField = [showSet allObjects];
                                       
                                       
                                       [self.tableView reloadData];
                                       
                                   } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                       DLog(@"Something went wrong (Profile)");
                                   }];
}


- (void)loadPicture:(BOOL)reset {
    if (reset) {
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        pagePic = 1;
        
        if (currentRequest && currentRequest.isExecuting)
            [currentRequest cancel];
    } else {
        if (currentRequest && currentRequest.isExecuting)
            return;
    }

    NSDictionary *param = @{@"page": [NSNumber numberWithInt:pagePic + 1],
                            @"limit": [NSNumber numberWithInt:30]};

    NSString *url = [NSString stringWithFormat:@"picture/user/%ld", [_user.userId longValue]];
    currentRequest = [[LatteAPIClient sharedClient] GET:url
                                parameters: param
                                   success:^(AFHTTPRequestOperation *operation, NSDictionary *JSON) {
                                       pagePic += 1;
                                       
                                       NSArray *newPics = [Picture mutableArrayFromDictionary:JSON
                                                                              withKey:@"pictures"];

                                       endedPic = newPics.count == 0;
                                       
                                       if (reset) {
                                           pictures = [NSMutableArray arrayWithArray:newPics];
                                           [MBProgressHUD hideHUDForView:self.view animated:YES];
                                       } else {
                                           [pictures addObjectsFromArray:newPics];
                                       }
                                       
                                       [self.tableView reloadData];
                                   } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                       endedPic = true;
                                       if (reset) {
                                           [MBProgressHUD hideHUDForView:self.view animated:YES];
                                       }
                                       [self.refreshControl endRefreshing];
                                   }];
}

- (void)loadFollower {
    LXAppDelegate* app = (LXAppDelegate*)[UIApplication sharedApplication].delegate;
    
    NSString *url = [NSString stringWithFormat:@"user/%ld/follower", [_user.userId longValue]];
    [[LatteAPIClient sharedClient] GET:url
                                parameters: [NSDictionary dictionaryWithObjectsAndKeys:[app getToken], @"token", nil]
                                   success:^(AFHTTPRequestOperation *operation, NSDictionary *JSON) {
                                       followers = [User mutableArrayFromDictionary:JSON
                                                                          withKey:@"followers"];
                                       
                                       [self.tableView reloadData];
                                       [self.refreshControl endRefreshing];
                                       
                                   } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                       DLog(@"Something went wrong (Follower)");
                                       [self.tableView reloadData];
                                       
                                   }];
}

- (void)loadFollowings {
    LXAppDelegate* app = (LXAppDelegate*)[UIApplication sharedApplication].delegate;
    
    NSString *url = [NSString stringWithFormat:@"user/%ld/following", [_user.userId longValue]];
    [[LatteAPIClient sharedClient] GET:url
                                parameters: [NSDictionary dictionaryWithObjectsAndKeys:[app getToken], @"token", nil]
                                   success:^(AFHTTPRequestOperation *operation, NSDictionary *JSON) {
                                       followings = [User mutableArrayFromDictionary:JSON
                                                                             withKey:@"following"];
                                       
                                       [self.tableView reloadData];
                                   } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                       DLog(@"Something went wrong (Reload Following)");
                                       [self.tableView reloadData];
                                   }];
}


- (void)reloadView {
    endedPic = false;

    [self reloadProfile];
    
    switch (tableMode) {
        case kTablePhoto:
            if (photoMode == kPhotoGrid)
                [self loadPicture:YES];
            else if (photoMode == kPhotoCalendar)
                [self reloadCalendar];
            break;
        case kTableFollowings:
            [self loadFollowings];
            break;
        case kTableFollower:
            [self loadFollower];
            break;
        default:
            break;
    }
}

- (void)loadMore {
    if (photoMode == kPhotoGrid)
        [self loadPicture:NO];
}

- (void)reloadCalendar {
    selectedCalendarDate = nil;
    LXAppDelegate* app = (LXAppDelegate*)[[UIApplication sharedApplication] delegate];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyyMM"];
    
    NSString* urlPhotos = [NSString stringWithFormat:@"picture/album/by_month/%@/%d", [dateFormat stringFromDate:currentMonth], [_user.userId integerValue]];
    [HUD show:YES];
    [[LatteAPIClient sharedClient] GET:urlPhotos
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
            if (photoMode == kPhotoGrid) {
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
        case kTableFollowings:
            return followings.count;
        case kTableFollower:
            return followers.count;
        case kTableTag:
            return 0;
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableMode == kTablePhoto)
    {
        if (photoMode == kPhotoGrid) {
            return 104;
        } else if (photoMode == kPhotoCalendar) {
            if (selectedCalendarDate) {
                UIView *view = [self viewForCalendarDay:selectedCalendarDate];
                return view.frame.size.height;
            } else
                return 0;

        }
//    } else if (tableMode == kTableProfile) {
//        if (indexPath.row == showField.count) {
//            return 22;
//        }
//        NSString* strKey = [showField objectAtIndex:indexPath.row];
//        
//        if ([strKey isEqualToString:@"hobby"]|| [strKey isEqualToString:@"introduction"]) {
//            CGSize size = [[userDict objectForKey:strKey] sizeWithFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:12.0]
//                                                     constrainedToSize:CGSizeMake(212.0, CGFLOAT_MAX)
//                                                         lineBreakMode:NSLineBreakByWordWrapping];
//            return size.height + 8;
//        } else {
//            return 22;
//        }
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
            if (photoMode == kPhotoGrid)
                isEmpty = pictures.count == 0;
            break;
        case kTableTag:
            break;
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
    }
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
            if (photoMode == kPhotoGrid) {
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
                labelStart.text = [NSString stringWithFormat:@"%02ld:00", head];
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

- (void)touchTab:(UserTableMode)mode {
    tableMode = mode;
    switch (mode) {
        case kTablePhoto:
            [self.tableView reloadData];
            break;
        case kTableFollower:
            if (followers == nil)
                [self loadFollower];
            else
                [self.tableView reloadData];
            break;
        case kTableFollowings:
            if (followings == nil)
                [self loadFollowings];
            else
                [self.tableView reloadData];

            break;
    }
}

- (void)touchPhoto:(UserPagePhotoMode)mode {
    switch (mode) {
        case kPhotoGrid:
            photoMode = mode;
            if (pictures.count == 0) {
                [self loadPicture:YES];
            } else
                [self.tableView reloadData];
            break;
        case kPhotoCalendar:
            photoMode = mode;
            [self reloadCalendar];
            break;
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


- (void)didPresentActionSheet:(UIActionSheet *)actionSheet {
    LXAppDelegate* app = (LXAppDelegate*)[UIApplication sharedApplication].delegate;
    if (app.currentUser.profilePicture == nil) {
        [actionSheet setButton:0 toState:false];
    }
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
    
    if (self.navigationController.presentingViewController) {
        [self.navigationController pushViewController:viewGallery animated:YES];
    } else {
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
}

- (void)showPic:(UIButton*)sender {
    [self showPic:sender withTab:kGalleryTabNone];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"MainStoryboard"
                                                             bundle:nil];
    LXUserPageViewController *viewUserPage = [mainStoryboard instantiateViewControllerWithIdentifier:@"UserPage"];
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


- (NSDictionary *)pictureAfterPicture:(Picture *)picture {
    switch (photoMode) {
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
    }
    return nil;
}

- (NSDictionary *)pictureBeforePicture:(Picture *)picture {    
    switch (photoMode) {
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
    }
    return nil;
}

- (void)showUser:(UIButton*)sender {
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"MainStoryboard"
                                                             bundle:nil];
    LXUserPageViewController *viewUserPage = [mainStoryboard instantiateViewControllerWithIdentifier:@"UserPage"];
    switch (tableMode) {
        case kTableFollower:
            
            break;
        case kTableFollowings:
            viewUserPage.user = followings[sender.tag];
            break;
        default:
            break;
    }
    [self.navigationController pushViewController:viewUserPage animated:YES];

}


- (void)showUser:(User *)user fromGallery:(LXGalleryViewController *)gallery {
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"MainStoryboard"
                                                             bundle:nil];
    LXUserPageViewController *viewUserPage = [mainStoryboard instantiateViewControllerWithIdentifier:@"UserPage"];
    viewUserPage.user = user;
    [self.navigationController pushViewController:viewUserPage animated:YES];
}

@end