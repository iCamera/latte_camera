//
//  luxeysUserViewController.m
//  Latte
//
//  Created by Xuan Dung Bui on 8/20/12.
//  Copyright (c) 2012 LUXEYS. All rights reserved.
//

#import "LXUserPageViewController.h"

@interface LXUserPageViewController ()
@end

@implementation LXUserPageViewController
@synthesize buttonVoteCount;
@synthesize buttonPhotoCount;
@synthesize buttonFriendCount;
@synthesize imageUser;
@synthesize viewStats;
@synthesize viewContent;
@synthesize buttonProfile;
@synthesize buttonCalendar;
//@synthesize buttonMap;
@synthesize tableProfile;
@synthesize labelNickname;
@synthesize buttonContact;
@synthesize iconFollow;
@synthesize iconFriend;
@synthesize labelTitleFriend;
@synthesize labelTitlePicCount;
@synthesize lableTitleVote;
@synthesize loadIndicator;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    
    tableMode = kTableProfile;
    currentMonth = [NSDate date];
    isEmpty = false;
    pagePhoto = 0;
    pageInterest = 0;
    endedInterest = false;
    endedPhoto = false;
    photos = [[NSMutableArray alloc] init];
    interests = [[NSMutableArray alloc] init];
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    LXAppDelegate* app = (LXAppDelegate*)[UIApplication sharedApplication].delegate;
    [app.tracker sendView:@"UserPage Screen"];
    
    // Do any additional setup after loading the view from its nib.
    // Style
    showSet = [NSMutableSet setWithObjects:@"gender", @"residence", @"age", @"birthdate", @"bloodtype", @"occupation", @"introduction", @"hobby", nil];
    
    imageUser.clipsToBounds = YES;
    imageUser.layer.cornerRadius = 5;
    
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = CGRectMake(0, 108, 320, 10);
    gradient.colors = [NSArray arrayWithObjects:
                       (id)[[UIColor clearColor] CGColor],
                       (id)[[[UIColor blackColor] colorWithAlphaComponent:0.2f] CGColor],
                       nil];
    [viewStats.layer insertSublayer:gradient atIndex:0];
    
    viewStats.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg_sub_back.png"]];
    
    allTab = [NSArray arrayWithObjects:
              buttonCalendar,
//              buttonMap,
              buttonProfile,
              buttonFriendCount,
              buttonPhotoCount,
              buttonVoteCount,
              nil];

    // Pull to refresh
    refreshHeaderView = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - tableProfile.bounds.size.height, self.view.frame.size.width, tableProfile.bounds.size.height)];
    refreshHeaderView.delegate = self;
    [tableProfile addSubview:refreshHeaderView];
    
    // Frame
    CGRect frameTable = self.view.bounds;
    frameTable.size.height -= 94;
    tableProfile.frame = frameTable;

    // Data
    [self reloadProfile];
}

- (void)reloadProfile {
    LXAppDelegate* app = (LXAppDelegate*)[[UIApplication sharedApplication] delegate];
    NSString* strURL = [NSString stringWithFormat:@"user/%d", userID];

    [[LatteAPIClient sharedClient] getPath:strURL
                                parameters: [NSDictionary dictionaryWithObjectsAndKeys:[app getToken], @"token", nil]
                                   success:^(AFHTTPRequestOperation *operation, NSDictionary *JSON) {
                                       userDict = [JSON objectForKey:@"user"];
                                       user =  [User instanceFromDictionary:userDict];
                                       labelNickname.text = user.name;
                                       [buttonFriendCount setTitle:[user.countFriends stringValue] forState:UIControlStateNormal];
                                       [buttonPhotoCount setTitle:[user.countPictures stringValue] forState:UIControlStateNormal];
                                       [buttonVoteCount setTitle:[user.voteCount stringValue] forState:UIControlStateNormal];
                                       
                                       if (user.profilePicture != nil)
                                           [self.imageUser setImageWithURL:[NSURL URLWithString:user.profilePicture]];
                                       
                                       NSSet *allField = [NSSet setWithArray:[userDict allKeys]];
                                       [showSet intersectSet:allField];
                                       showField = [showSet allObjects];
                                       [tableProfile reloadData];
                                       
                                       [self doneLoadingTableViewData];
                                       if (app.currentUser != nil) {
                                           if (![app.currentUser.userId isEqualToNumber:user.userId]) {
                                               buttonContact.hidden = false;
                                               
                                               if (user.isFriend || user.isFollowing) {
                                                   [buttonContact setImage:[UIImage imageNamed:@"icon_setting.png"] forState:UIControlStateNormal];
                                               }
                                               
                                               iconFriend.hidden = !user.isFriend;
                                               iconFollow.hidden = !user.isFollowing;
                                           }
                                       }
                                   }
                                   failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                       TFLog(@"Something went wrong (User - Profile)");
                                   }];
}

- (void)reloadFriends {
    LXAppDelegate* app = (LXAppDelegate*)[[UIApplication sharedApplication] delegate];
    
    NSString* urlFriends = [NSString stringWithFormat:@"user/%d/friend", userID];
    [[LatteAPIClient sharedClient] getPath:urlFriends
                                parameters: [NSDictionary dictionaryWithObjectsAndKeys:[app getToken], @"token", nil]
                                   success:^(AFHTTPRequestOperation *operation, NSDictionary *JSON) {
                                       friends = [User mutableArrayFromDictionary:JSON withKey:@"friends"];
                                       [tableProfile reloadData];
                                       
                                       [self doneLoadingTableViewData];
                                   } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                       TFLog(@"Something went wrong (User - Friendlist)");
                                   }];

}

- (void)reloadPicList {
    pagePhoto = 0;
    endedPhoto = false;
    
    [loadIndicator startAnimating];
    LXAppDelegate* app = (LXAppDelegate*)[[UIApplication sharedApplication] delegate];
    
    NSDictionary *param = [NSDictionary dictionaryWithObjectsAndKeys:
                           [app getToken], @"token",
                           [NSNumber numberWithInt:pagePhoto + 1], @"page",
                           [NSNumber numberWithInt:40], @"limit",
                           nil];
    
    NSString* urlPhotos = [NSString stringWithFormat:@"picture/user/%d", userID];
    
    
    [[LatteAPIClient sharedClient] getPath:urlPhotos
                                parameters: param
                                   success:^(AFHTTPRequestOperation *operation, NSDictionary *JSON) {
                                       photos = [Picture mutableArrayFromDictionary:JSON
                                                                                      withKey:@"pictures"];
                                       
                                       endedPhoto = photos.count == 0;
                                       isEmpty = photos.count == 0;
                                       [tableProfile reloadData];
                                       [self doneLoadingTableViewData];
                                       
                                       [loadIndicator stopAnimating];
                                       
                                       pagePhoto += 1;
                                   } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                       [loadIndicator stopAnimating];
                                       TFLog(@"Something went wrong (Photolist)");
                                       [self doneLoadingTableViewData];
                                   }];
}

- (void)loadMorePiclist {
    [loadIndicator startAnimating];
    LXAppDelegate* app = (LXAppDelegate*)[[UIApplication sharedApplication] delegate];

    NSDictionary *param = [NSDictionary dictionaryWithObjectsAndKeys:
        [app getToken], @"token",
        [NSNumber numberWithInt:pagePhoto + 1], @"page",
        [NSNumber numberWithInt:40], @"limit",
        nil];

    NSString* urlPhotos = [NSString stringWithFormat:@"picture/user/%d", userID];
    

    [[LatteAPIClient sharedClient] getPath:urlPhotos
                                parameters: param
                                   success:^(AFHTTPRequestOperation *operation, NSDictionary *JSON) {
                                       NSArray *newPics = [Picture mutableArrayFromDictionary:JSON
                                                                              withKey:@"pictures"];

                                       endedPhoto = newPics.count == 0;
                                       NSInteger oldRow = [self tableView:tableProfile numberOfRowsInSection:0];
                                       
                                       [photos addObjectsFromArray:newPics];
                                       isEmpty = photos.count == 0;
                                       NSInteger newRow = [self tableView:tableProfile numberOfRowsInSection:0];
                                       NSMutableArray *indexes = [[NSMutableArray alloc] init];
                                       
                                       for (NSInteger i = oldRow; i < newRow; i++) {
                                           [indexes addObject:[NSIndexPath indexPathForRow:i inSection:0]];
                                       }
                                       [tableProfile insertRowsAtIndexPaths:indexes
                                                           withRowAnimation:UITableViewRowAnimationAutomatic];
                                       
                                       [self doneLoadingTableViewData];
                                       
                                       [loadIndicator stopAnimating];
                                       
                                       pagePhoto += 1;
                                   } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                       [loadIndicator stopAnimating];
                                       TFLog(@"Something went wrong (Photolist)");
                                       [self doneLoadingTableViewData];
                                   }];
}

- (void)reloadInterest {
    pageInterest = 0;
    endedInterest = false;
    
    [loadIndicator startAnimating];
    LXAppDelegate* app = (LXAppDelegate*)[[UIApplication sharedApplication] delegate];
    
    NSDictionary *param = [NSDictionary dictionaryWithObjectsAndKeys:
                           [app getToken], @"token",
                           [NSNumber numberWithInt:pageInterest + 1], @"page",
                           [NSNumber numberWithInt:40], @"limit",
                           nil];
    
    NSString* urlPhotos = [NSString stringWithFormat:@"picture/user/interesting/%d", userID];
    
    [[LatteAPIClient sharedClient] getPath: urlPhotos
                                parameters: param
                                   success:^(AFHTTPRequestOperation *operation, NSDictionary *JSON) {
                                       interests = [Picture mutableArrayFromDictionary:JSON
                                                                                      withKey:@"pictures"];
                                       endedInterest = interests.count == 0;
                                       isEmpty = interests.count == 0;

                                           [tableProfile reloadData];
                                       [self doneLoadingTableViewData];
                                       
                                       [loadIndicator stopAnimating];
                                       
                                       pageInterest += 1;
                                       
                                   } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                       [loadIndicator stopAnimating];
                                       TFLog(@"Something went wrong (User - Interesting)");
                                       [self doneLoadingTableViewData];
                                   }];
}


- (void)loadMoreInterest {
    [loadIndicator startAnimating];
    LXAppDelegate* app = (LXAppDelegate*)[[UIApplication sharedApplication] delegate];

    NSDictionary *param = [NSDictionary dictionaryWithObjectsAndKeys:
        [app getToken], @"token",
        [NSNumber numberWithInt:pageInterest + 1], @"page",
        [NSNumber numberWithInt:40], @"limit",
        nil];

    NSString* urlPhotos = [NSString stringWithFormat:@"picture/user/interesting/%d", userID];

    [[LatteAPIClient sharedClient] getPath: urlPhotos
                                parameters: param
                                   success:^(AFHTTPRequestOperation *operation, NSDictionary *JSON) {
                                       NSArray *newPics = [Picture mutableArrayFromDictionary:JSON
                                                                              withKey:@"pictures"];

                                       endedInterest = newPics.count == 0;
                                       NSInteger oldRow = [self tableView:tableProfile numberOfRowsInSection:0];
                                       [tableProfile beginUpdates];
                                       
                                       
                                       [interests addObjectsFromArray:newPics];
                                       isEmpty = interests.count == 0;
                                       NSInteger newRow = [self tableView:tableProfile numberOfRowsInSection:0];
                                       for (NSInteger i = oldRow; i < newRow; i++) {
                                           [tableProfile insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:i inSection:0]]
                                                                 withRowAnimation:UITableViewRowAnimationAutomatic];
                                       }
                                       
                                       [tableProfile endUpdates];
                                       [self doneLoadingTableViewData];
                                       
                                       [loadIndicator stopAnimating];
                                       
                                       pageInterest += 1;
                                       
                                   } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                       [loadIndicator stopAnimating];
                                       TFLog(@"Something went wrong (User - Interesting)");
                                       [self doneLoadingTableViewData];
                                   }];
}


- (void)reloadMap {
    
}

- (void)reloadCalendar {
    LXAppDelegate* app = (LXAppDelegate*)[[UIApplication sharedApplication] delegate];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyyMM"];
    NSString* urlPhotos = [NSString stringWithFormat:@"picture/album/by_month/%@/%d", [dateFormat stringFromDate:currentMonth], userID];

    [[LatteAPIClient sharedClient] getPath:urlPhotos
                                parameters: [NSDictionary dictionaryWithObjectsAndKeys:[app getToken], @"token", nil]
                                   success:^(AFHTTPRequestOperation *operation, NSDictionary *JSON) {
                                       NSMutableArray *pics = [Picture mutableArrayFromDictionary:JSON withKey:@"pictures"];
                                       currentMonthPics = [[NSMutableDictionary alloc]init];
                                       NSDateFormatter *dayFormat = [[NSDateFormatter alloc] init];
                                       [dayFormat setDateFormat:@"dd"];
                                       
                                       for (Picture *pic in pics) {
                                           NSString* key = [dayFormat stringFromDate:pic.createdAt];
                                           [currentMonthPics setObject:pic forKey:key];
                                       }
                                       
                                       [tableProfile reloadData];
                                       
                                       [self doneLoadingTableViewData];
                                       
                                   } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                       TFLog(@"Something went wrong (User - Interesting)");
                                       
                                   }];
    //[self performSegueWithIdentifier:@"Calendar" sender:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)reloadView {
    switch (tableMode) {
        case kTableProfile:
            [self reloadProfile];
            break;
        case kTableFriends:
            [self reloadFriends];
            break;
        case kTablePicList:
            [self reloadPicList];
            break;
        case kTableVotes:
            [self reloadInterest];
            break;
        case kTableCalendar:
            [self reloadCalendar];
            break;
        default:
            break;
    }
}

- (IBAction)touchTab:(UIButton *)sender {
    for (UIButton *button in allTab) {
        button.enabled = YES;
    }
    labelTitleFriend.highlighted = NO;
    labelTitlePicCount.highlighted = NO;
    lableTitleVote.highlighted = NO;

    sender.enabled = NO;
    switch (sender.tag) {
        case 1:
            tableMode = kTableProfile;
            if (user == nil)
                [self reloadProfile];
            else
                [tableProfile reloadData];
            break;
        case 2:
            tableMode = kTableCalendar;
            [self reloadCalendar];
            break;
        case 3:
            tableMode = kTableMap;
            break;
        case 4:
            lableTitleVote.highlighted = YES;
            tableMode = kTableVotes;
            if (interests.count == 0) {
                [self reloadInterest];
            } else
                [tableProfile reloadData];
            break;
        case 5:
            labelTitlePicCount.highlighted = YES;
            tableMode = kTablePicList;
            if (photos.count == 0) {
                [self reloadPicList];
            } else
                [tableProfile reloadData];
            break;
        case 6:
            labelTitleFriend.highlighted = YES;
            tableMode = kTableFriends;
            if (friends == nil) {
                [self reloadFriends];
            } else
                [tableProfile reloadData];
            break;
    }
}

- (IBAction)touchBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (isEmpty)
        return 0;
    if (tableMode == kTableProfile) {
        return [showField count];
    } else if (tableMode == kTablePicList) {
        return (photos.count/4) + (photos.count%4>0?1:0);
    } else if (tableMode == kTableVotes) {
        return (interests.count/4) + (interests.count%4>0?1:0);
    } else if (tableMode == kTableFriends) {
        return friends.count;
    } else if (tableMode == kTableCalendar) {
        return 1;
    } else {
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableMode == kTableProfile)
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
        } else {
            cell.labelDetail.text = [userDict objectForKey:strKey];
        }
        
        
        return cell;
    } else if ((tableMode == kTablePicList) || (tableMode == kTableVotes)) {
        UITableViewCell *cellPic = [[UITableViewCell alloc] init];
        for (int i = 0; i < 4; ++i)
        {
            UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(6+(i*77), 6, 71, 71)];
            NSInteger index = indexPath.row*4+i;
            Picture *pic;
            if (tableMode == kTablePicList) {
                if (index >= photos.count)
                    break;
                pic = [photos objectAtIndex:index];
                [button addTarget:self action:@selector(showPhotoFromUploaded:) forControlEvents:UIControlEventTouchUpInside];
            }

            if (tableMode == kTableVotes) {
                if (index >= interests.count)
                    break;
                pic = [interests objectAtIndex:index];
                [button addTarget:self action:@selector(showPhotoFromFav:) forControlEvents:UIControlEventTouchUpInside];
            }
            
            
            [button loadBackground:pic.urlSquare];
            button.tag = [pic.pictureId longValue];
            
            button.layer.borderColor = [[UIColor whiteColor] CGColor];
            button.layer.borderWidth = 3;
            
            UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:button.bounds];
            button.layer.masksToBounds = NO;
            button.layer.shadowColor = [UIColor blackColor].CGColor;
            button.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
            button.layer.shadowOpacity = 0.5f;
            button.layer.shadowRadius = 1.5f;
            button.layer.shadowPath = shadowPath.CGPath;
            
            [cellPic addSubview:button];
        }
        return cellPic;
    } else if (tableMode == kTableFriends) {
        User *friend = [friends objectAtIndex:indexPath.row];
        LXCellFriend* cellFriend = [tableProfile dequeueReusableCellWithIdentifier:@"Friend"];
        [cellFriend setUser:friend];
        [cellFriend.buttonUser addTarget:self action:@selector(showUser:) forControlEvents:UIControlEventTouchUpInside];
        cellFriend.buttonUser.tag = [friend.userId integerValue];
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 41, 320, 1)];
        line.backgroundColor = [UIColor colorWithRed:188.0/255.0 green:184.0/255.0 blue:169.0/255.0 alpha:1];
        [cellFriend addSubview:line];
        
        return cellFriend;
    } else if (tableMode == kTableCalendar) {
        UITableViewCell *cell = [[UITableViewCell alloc] init];
        
        for (int i = 0; i < daysInMonth; i++) {
            NSInteger row = i/5;
            NSInteger col = i%5;
            
            NSString *key = [NSString stringWithFormat:@"%2d", i];
            Picture *pic = [currentMonthPics objectForKey:key];
            [cell addSubview:[self viewForCalendarPic:pic atRow:row atColumn:col cellIndex:i]];
        }
        return cell;
    } else
        return [[UITableViewCell alloc] init];
}

- (UIView *)viewForCalendarPic:(Picture *)pic atRow:(NSInteger)row atColumn:(NSInteger)col cellIndex:(NSInteger)cellIndex {
    UIView *viewDate = [[UIView alloc] initWithFrame:CGRectMake(col*63, row*63, 61, 61)];
    
    UIImageView *imageLabel = [[UIImageView alloc] init];
    UILabel *labelBig = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 50, 15)];
    UILabel *labelSmall = [[UILabel alloc] init];
    labelSmall.backgroundColor = [UIColor clearColor];
    labelSmall.backgroundColor = [UIColor clearColor];
    labelSmall.textAlignment = NSTextAlignmentCenter;
    labelBig.backgroundColor = [UIColor clearColor];
    labelBig.textAlignment = NSTextAlignmentCenter;
    
    [labelBig setFont:[UIFont fontWithName:@"AvenirNextCondensed-DemiBold" size:15]];
    labelBig.text = [NSString stringWithFormat:@"%d", cellIndex+1];
    labelSmall.text = [NSString stringWithFormat:@"%d", cellIndex+1];
    [labelSmall setFont:[UIFont fontWithName:@"AvenirNextCondensed-DemiBold" size:11]];
    labelSmall.textColor = [UIColor whiteColor];
    
    if (cellIndex < 9) {
        imageLabel.frame = CGRectMake(10, 0, 15, 20);
        labelSmall.frame =  CGRectMake(5, 4, 16, 11);
        [imageLabel setImage:[UIImage imageNamed:@"deco_calender.png"]];
    } else {
        imageLabel.frame = CGRectMake(10, 0, 22, 20);
        labelSmall.frame =  CGRectMake(8, 4, 20, 11);
        [imageLabel setImage:[UIImage imageNamed:@"deco_calender_wide.png"]];
    }
    
    UIView *border = [[UIView alloc] initWithFrame:CGRectMake(5, 3, 58, 58)];
    border.backgroundColor = [UIColor colorWithRed:188.0/255.0 green:184.0/255.0 blue:169.0/255.0 alpha:1];
    UIView *bg = [[UIView alloc] initWithFrame:CGRectMake(2, 2, 54, 54)];
    bg.backgroundColor = [UIColor colorWithRed:228.0/255.0 green:226.0/255.0 blue:220.0/255.0 alpha:1];
    
    [labelBig setCenter:bg.center];
    [labelBig setFont:[UIFont fontWithName:@"Baskerville-Bold" size:14]];
    labelBig.textColor = [UIColor colorWithRed:187.0/255.0 green:184.0/255.0 blue:169.0/255.0 alpha:1];
    
    [border addSubview:bg];
    [viewDate addSubview:border];
    
    if (pic != nil) {
        [viewDate addSubview:imageLabel];
        [viewDate addSubview:labelSmall];
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(1, 1, 52, 52)];
        [button loadBackground:pic.urlSquare];
        button.tag = cellIndex;
        [button addTarget:self action:@selector(showPhotoFromCalendar:) forControlEvents:UIControlEventTouchUpInside];
        [bg addSubview:button];
    } else {
        [border addSubview:labelBig];
    }
    
    return viewDate;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableMode == kTableProfile) {
        return 30;
    } else if (tableMode == kTableFriends) {
        return 42;
    } else if ((tableMode == kTablePicList) || (tableMode == kTableVotes)) {
        return 78;
    } else if (tableMode == kTableCalendar) {
        NSCalendar *calendar = [NSCalendar currentCalendar];
        NSRange days = [calendar rangeOfUnit:NSDayCalendarUnit
                                      inUnit:NSMonthCalendarUnit
                                     forDate:currentMonth];
        daysInMonth = days.length;
        return (daysInMonth/5 + (daysInMonth%5>0?1:0)) * 63;
    }
    else
        return 0;
}

- (void)showPhotoFromFav:(UIButton*)sender {
    Picture *pic = [[interests filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:[NSString stringWithFormat:@"pictureId == %d", sender.tag]]] lastObject];
    [self showPhoto:pic];
}

- (void)showPhotoFromUploaded:(UIButton*)sender {
    Picture *pic = [[photos filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:[NSString stringWithFormat:@"pictureId == %d", sender.tag]]] lastObject];
    [self showPhoto:pic];
}

- (void)showPhotoFromCalendar:(UIButton*)sender {
    Picture *pic = [currentMonthPics objectForKey:[NSString stringWithFormat:@"%2d", sender.tag]];
    [self showPhoto:pic];
}



- (void)showPhoto:(Picture*)pic {
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"MainStoryboard"
                                                             bundle:nil];
    LXPicDetailViewController *viewPicDetail = [mainStoryboard instantiateViewControllerWithIdentifier:@"PictureDetail"];
    viewPicDetail.pic = pic;
    [self.navigationController pushViewController:viewPicDetail animated:YES];
}

- (void)setUserID:(int)aUserID {
    userID = aUserID;
}

- (IBAction)touchContact:(id)sender {
    
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"friend_setting", @"友達設定") 
                                                       delegate:self
                                              cancelButtonTitle:nil
                                         destructiveButtonTitle:nil
                                              otherButtonTitles:nil];
    
    if (user.isFriend) {
        [sheet addButtonWithTitle:NSLocalizedString(@"remove_friend", @"友達から外す")];
    } else {
        if (user.requestToMe != nil) {
            if ([user.requestToMe integerValue] != kUserRequestAccepted) {
                [sheet addButtonWithTitle:NSLocalizedString(@"approve_friend", @"承認")];
            }
        }
        if (user.requestToUser != nil) {
            if ([user.requestToMe integerValue] != kUserRequestAccepted) {
                [sheet addButtonWithTitle:NSLocalizedString(@"pending_request", @"友達申請中")];
            }
        }
        if ((user.requestToMe == nil) && (user.requestToUser == nil)) {
            [sheet addButtonWithTitle:NSLocalizedString(@"add_friend", @"友達に追加")];
        }
    }
    
    if (user.isFollowing) {
        [sheet addButtonWithTitle:NSLocalizedString(@"unfollow", @"お気に入りから外す")];
    } else {
        [sheet addButtonWithTitle:NSLocalizedString(@"follow", @"お気に入りに追加")];
    }
    [sheet addButtonWithTitle:NSLocalizedString(@"cancel", @"キャンセル")];
    
    sheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
    sheet.delegate = self;
    [sheet showFromTabBar:self.tabBarController.tabBar];
}

- (void)didPresentActionSheet:(UIActionSheet *)actionSheet {
    if (!user.isFriend) {
        if (user.requestToUser != nil) {
            if ([user.requestToMe integerValue] != kUserRequestAccepted) {
                [actionSheet setButton:0 toState:false];
            }
        }
    }
}

- (void)sendFriendRequest {
    if (user.requestToMe != nil) {
        if ([user.requestToMe integerValue] != kUserRequestAccepted) {
            
            LXAppDelegate* app = (LXAppDelegate*)[[UIApplication sharedApplication] delegate];
            
            NSString *url = [NSString stringWithFormat:@"user/friend/approve/%d", [user.userId integerValue]];
            [[LatteAPIClient sharedClient] postPath:url
                                         parameters: [NSDictionary dictionaryWithObjectsAndKeys:[app getToken], @"token", nil]
                                            success:^(AFHTTPRequestOperation *operation, NSDictionary *JSON) {
                                                [self reloadProfile];
                                            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                TFLog(@"Something went wrong (User - Approve)");
                                            }];
        }
    }
    if ((user.requestToMe == nil) && (user.requestToUser == nil)) {
        
        LXAppDelegate* app = (LXAppDelegate*)[[UIApplication sharedApplication] delegate];
        
        NSString *url = [NSString stringWithFormat:@"user/friend/request/%d", [user.userId integerValue]];
        [[LatteAPIClient sharedClient] postPath:url
                                     parameters: [NSDictionary dictionaryWithObjectsAndKeys:[app getToken], @"token", nil]
                                        success:^(AFHTTPRequestOperation *operation, NSDictionary *JSON) {
                                            [self reloadProfile];
                                        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                            TFLog(@"Something went wrong (User - Send request)");
                                        }];
    }
}

- (void)toggleFollow {
    LXAppDelegate* app = (LXAppDelegate*)[[UIApplication sharedApplication] delegate];
    if (user.isFollowing) {
        NSString *url = [NSString stringWithFormat:@"user/unfollow/%d", [user.userId integerValue]];
        [[LatteAPIClient sharedClient] postPath:url
                                    parameters: [NSDictionary dictionaryWithObjectsAndKeys:[app getToken], @"token", nil]
                                       success:^(AFHTTPRequestOperation *operation, NSDictionary *JSON) {
                                           [self reloadProfile];
                                       } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                           TFLog(@"Something went wrong (User - Unfollow)");
                                       }];
    } else {
        NSString *url = [NSString stringWithFormat:@"user/follow/%d", [user.userId integerValue]];
        [[LatteAPIClient sharedClient] postPath:url
                                    parameters: [NSDictionary dictionaryWithObjectsAndKeys:[app getToken], @"token", nil]
                                       success:^(AFHTTPRequestOperation *operation, NSDictionary *JSON) {
                                           [self reloadProfile];
                                       } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                           TFLog(@"Something went wrong (User - Follow)");
                                       }];
    }
}

- (void)removeFriend {
    LXAppDelegate* app = (LXAppDelegate*)[[UIApplication sharedApplication] delegate];
    NSString *url = [NSString stringWithFormat:@"user/friend/remove/%d", [user.userId integerValue]];
    [[LatteAPIClient sharedClient] postPath:url
                                 parameters: [NSDictionary dictionaryWithObjectsAndKeys:[app getToken], @"token", nil]
                                    success:^(AFHTTPRequestOperation *operation, NSDictionary *JSON) {
                                        [self reloadProfile];
                                    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                        TFLog(@"Something went wrong (User - Remove friend)");
                                    }];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (buttonIndex) {
        case 0:
            if (!user.isFriend) {
                [self sendFriendRequest];
            } else {
                [self removeFriend];
            }
            break;
        case 1:
            [self toggleFollow];
            break;
        default:
            break;
    }
}

- (void)showUser:(UIButton *)button {
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"MainStoryboard"
                                                             bundle:nil];
    LXUserPageViewController *viewUser = [mainStoryboard instantiateViewControllerWithIdentifier:@"UserPage"];
    [viewUser setUserID:button.tag];
    [self.navigationController pushViewController:viewUser animated:YES];
}

- (void)reloadTableViewDataSource{
    reloading = YES;
}

- (void)doneLoadingTableViewData{
    reloading = NO;
    [refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:tableProfile];
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
        case kTableProfile:
            return;
            break;
        case kTableFriends:
            return;
            break;
        case kTableCalendar:
            return;
            break;
        case kTableMap:
            return;
            break;
        case kTablePicList:
            if (endedPhoto)
                return;
            break;
        case kTableVotes:
            if (endedInterest)
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
        if (!loadIndicator.isAnimating) {
            switch (tableMode) {
                case kTablePicList:
                    [self loadMorePiclist];
                    break;
                case kTableVotes:
                    [self loadMoreInterest];
                    break;
                default:
                    break;
            }
            
        }
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    [refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (isEmpty) {
        UIView *emptyView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 200)];
        UIImageView *emptyImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"nopict.png"]];
        //    UILabel *label = [[UILabel alloc] initWithFrame:(CGRect)]
        emptyImage.center = emptyView.center;
        [emptyView addSubview:emptyImage];
        return emptyView;
    }

    if (tableMode == kTableCalendar) {
        UIView *view = [[UIView alloc] init];
        view.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.8];
        
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
        prev.titleLabel.font = [UIFont fontWithName:@"AvenirNextCondensed-Medium" size:16];
        next.titleLabel.font = [UIFont fontWithName:@"AvenirNextCondensed-Medium" size:16];
        [prev setTitleColor:[UIColor colorWithRed:101.0/255.0	green:90.0/255.0 blue:56.0/255.0 alpha:1] forState:UIControlStateNormal];
        [next setTitleColor:[UIColor colorWithRed:101.0/255.0	green:90.0/255.0 blue:56.0/255.0 alpha:1] forState:UIControlStateNormal];
        
        label.center = CGPointMake(160, 20);
        
        
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"yyyy/MM"];
        label.text = [dateFormat stringFromDate:currentMonth];
        label.textColor = [UIColor colorWithRed:101.0/255.0	green:90.0/255.0 blue:56.0/255.0 alpha:1];
        label.backgroundColor = [UIColor clearColor];
        [label setFont:[UIFont fontWithName:@"AvenirNextCondensed-Medium" size:20]];
        [view addSubview:prev];
        [view addSubview:next];
        [view addSubview:label];
        [view addSubview:imagePrev];
        [view addSubview:imageNext];
        return view;
    } else if (tableMode == kTableProfile) {
        UIView *view = [[UIView alloc] init];
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(6, 5, 308, 1)];
        line.backgroundColor = [UIColor lightGrayColor];
        [view addSubview:line];
        return view;
    }
    return nil;
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
    if (isEmpty)
        return 200;

    if (tableMode == kTableCalendar) {
        return 40;
    } else  if (tableMode == kTableProfile)
        return 6;
    return 0;
}


- (void)viewWillDisappear:(BOOL)animated
{
    if ([self.navigationController.viewControllers[self.navigationController.viewControllers.count-1] isKindOfClass:[LXPicDetailViewController class]]) {
        [[NSNotificationCenter defaultCenter]
         postNotificationName:@"TabbarHide"
         object:self];
    }
    
    [super viewWillDisappear:animated];
}


- (void)viewDidUnload {
    [self setLableTitleVote:nil];
    [self setLabelTitlePicCount:nil];
    [self setLabelTitleFriend:nil];
    [super viewDidUnload];
}
@end
