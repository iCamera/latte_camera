//
//  luxeysUserViewController.m
//  Latte
//
//  Created by Xuan Dung Bui on 8/20/12.
//  Copyright (c) 2012 LUXEYS. All rights reserved.
//

#import "luxeysUserViewController.h"

@interface luxeysUserViewController ()
@end

@implementation luxeysUserViewController
@synthesize buttonVoteCount;
@synthesize buttonPhotoCount;
@synthesize buttonFriendCount;
@synthesize imageUser;
@synthesize viewStats;
@synthesize viewContent;
@synthesize buttonProfile;
@synthesize buttonCalendar;
@synthesize buttonMap;
@synthesize tableProfile;
@synthesize labelNickname;
@synthesize buttonContact;
@synthesize iconFollow;
@synthesize iconFriend;


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
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    // Style
    showSet = [NSMutableSet setWithObjects:@"gender", @"residence", @"age", @"birthdate", @"bloodtype", @"occupation", @"introduction", @"hobby", nil];
    HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:HUD];
    HUD.mode = MBProgressHUDModeIndeterminate;
    
    UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:imageUser.bounds];
    imageUser.layer.masksToBounds = NO;
    imageUser.layer.shadowColor = [UIColor blackColor].CGColor;
    imageUser.layer.shadowOffset = CGSizeMake(0.0f, 1.0f);
    imageUser.layer.shadowOpacity = 1.0f;
    imageUser.layer.shadowRadius = 1.0f;
    imageUser.layer.shadowPath = shadowPath.CGPath;
    
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = CGRectMake(0, 120, 320, 10);
    gradient.colors = [NSArray arrayWithObjects:
                       (id)[[UIColor clearColor] CGColor],
                       (id)[[[UIColor blackColor] colorWithAlphaComponent:0.2f] CGColor],
                       nil];
    [viewStats.layer insertSublayer:gradient atIndex:0];
    
    viewStats.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg_sub_back.png"]];
    
    allTab = [NSArray arrayWithObjects:
              buttonCalendar,
              buttonMap,
              buttonProfile,
              buttonFriendCount,
              buttonPhotoCount,
              buttonVoteCount,
              nil];

    // Pull to refresh
    refreshHeaderView = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - tableProfile.bounds.size.height, self.view.frame.size.width, tableProfile.bounds.size.height)];
    refreshHeaderView.delegate = self;
    [tableProfile addSubview:refreshHeaderView];

    // Data
    [self reloadProfile];
}

- (void)reloadProfile {
    luxeysAppDelegate* app = (luxeysAppDelegate*)[[UIApplication sharedApplication] delegate];
    NSString* strURL = [NSString stringWithFormat:@"api/user/%d", userID];

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
                                       [HUD hide:YES];
                                   }
                                   failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                       NSLog(@"Something went wrong (User - Profile)");
                                       
                                       [HUD hide:YES];
                                   }];
}

- (void)reloadFriends {
    luxeysAppDelegate* app = (luxeysAppDelegate*)[[UIApplication sharedApplication] delegate];
    
    NSString* urlFriends = [NSString stringWithFormat:@"api/user/%d/friend", userID];
    [[LatteAPIClient sharedClient] getPath:urlFriends
                                parameters: [NSDictionary dictionaryWithObjectsAndKeys:[app getToken], @"token", nil]
                                   success:^(AFHTTPRequestOperation *operation, NSDictionary *JSON) {
                                       friends = [User mutableArrayFromDictionary:JSON withKey:@"friends"];
                                       [tableProfile reloadData];
                                       
                                       [self doneLoadingTableViewData];
                                       [HUD hide:YES];
                                   } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                       NSLog(@"Something went wrong (User - Friendlist)");
                                       
                                       [HUD hide:YES];
                                   }];

}

- (void)reloadPicList {
    luxeysAppDelegate* app = (luxeysAppDelegate*)[[UIApplication sharedApplication] delegate];
    NSString* urlPhotos = [NSString stringWithFormat:@"api/picture/user/%d", userID];
    

    [[LatteAPIClient sharedClient] getPath:urlPhotos
                                parameters: [NSDictionary dictionaryWithObjectsAndKeys:[app getToken], @"token", nil]
                                   success:^(AFHTTPRequestOperation *operation, NSDictionary *JSON) {
                                       photos = [Picture mutableArrayFromDictionary:JSON withKey:@"pictures"];
                                       [tableProfile reloadData];
                                       
                                       [self doneLoadingTableViewData];
                                       [HUD hide:YES];
                                       
                                   } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                       NSLog(@"Something went wrong (User - Photolist)");
                                       [HUD hide:YES];
                                   }];
}

- (void)reloadInterest {
    luxeysAppDelegate* app = (luxeysAppDelegate*)[[UIApplication sharedApplication] delegate];
    NSString* urlPhotos = [NSString stringWithFormat:@"api/picture/user/interesting/%d", userID];

    [[LatteAPIClient sharedClient] getPath:urlPhotos
                                parameters: [NSDictionary dictionaryWithObjectsAndKeys:[app getToken], @"token", nil]
                                   success:^(AFHTTPRequestOperation *operation, NSDictionary *JSON) {
                                       interests = [Picture mutableArrayFromDictionary:JSON withKey:@"pictures"];
                                       [tableProfile reloadData];
                                       
                                       [self doneLoadingTableViewData];
                                       [HUD hide:YES];
                                       
                                   } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                       NSLog(@"Something went wrong (User - Interesting)");
                                       [HUD hide:YES];
                                   }];
}

- (void)reloadMap {
    
}

- (void)reloadCalendar {
    luxeysAppDelegate* app = (luxeysAppDelegate*)[[UIApplication sharedApplication] delegate];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyyMM"];
    NSString* urlPhotos = [NSString stringWithFormat:@"api/picture/album/by_month/%@/%d", [dateFormat stringFromDate:currentMonth], userID];

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
                                       [HUD hide:YES];
                                       
                                   } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                       NSLog(@"Something went wrong (User - Interesting)");
                                       
                                       [HUD hide:YES];
                                   }];
    //[self performSegueWithIdentifier:@"Calendar" sender:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setImageUser:nil];
    [self setViewStats:nil];
    [self setViewContent:nil];
    [self setButtonProfile:nil];
    [self setButtonCalendar:nil];
    [self setButtonMap:nil];
    [self setTableProfile:nil];
    [self setButtonVoteCount:nil];
    [self setButtonPhotoCount:nil];
    [self setButtonFriendCount:nil];
    [super viewDidUnload];
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
            tableMode = kTableVotes;
            if (interests == nil) {
                [HUD show:YES];
                [self reloadInterest];
            } else
                [tableProfile reloadData];
            break;
        case 5:
            tableMode = kTablePicList;
            if (photos == nil) {
                [HUD show:YES];
                [self reloadPicList];
            } else
                [tableProfile reloadData];
            break;
        case 6:
            tableMode = kTableFriends;
            if (friends == nil) {
                [HUD show:YES];
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
        luxeysCellProfile *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        NSString* strKey = [showField objectAtIndex:indexPath.row];
        if ([strKey isEqualToString:@"gender"]) {
            cell.labelField.text = @"性別";
        } else if ([strKey isEqualToString:@"residence"]) {
            cell.labelField.text = @"現住所";
        } else if ([strKey isEqualToString:@"hometown"]) {
            cell.labelField.text = @"出身地";
        } else if ([strKey isEqualToString:@"age"]) {
            cell.labelField.text = @"年齢";
        } else if ([strKey isEqualToString:@"birthdate"]) {
            cell.labelField.text = @"誕生日";
        } else if ([strKey isEqualToString:@"bloodtype"]) {
            cell.labelField.text = @"血液型";
        } else if ([strKey isEqualToString:@"occupation"]) {
            cell.labelField.text = @"職業";
        } else if ([strKey isEqualToString:@"hobby"]) {
            cell.labelField.text = @"趣味";
        } else if ([strKey isEqualToString:@"introduction"]) {
            cell.labelField.text = @"自己紹介";
        }
        
        if ([strKey isEqualToString:@"gender"]) {
            cell.labelDetail.text = [[userDict objectForKey:strKey] stringValue];
        } else {
            cell.labelDetail.text = [userDict objectForKey:strKey];
        }
        
        
        return cell;
    } else if ((tableMode == kTablePicList) || (tableMode == kTableVotes)) {
        UITableViewCell *cellPic = [[UITableViewCell alloc] init];
        for (int i = 0; i < 4; ++i)
        {
            NSInteger index = indexPath.row*4+i;
            Picture *pic;
            if (tableMode == kTablePicList) {
                if (index >= photos.count)
                    break;
                pic = [photos objectAtIndex:index];
            }

            if (tableMode == kTableVotes) {
                if (index >= interests.count)
                    break;
                pic = [interests objectAtIndex:index];
            }
            
            UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(10+(i*77), 10, 67, 67)];
            [button loadBackground:pic.urlSquare];
            button.tag = [pic.pictureId longValue];
            [button addTarget:self action:@selector(showPhoto:) forControlEvents:UIControlEventTouchUpInside];
            
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
        luxeysCellFriend* cellFriend = [tableProfile dequeueReusableCellWithIdentifier:@"Friend"];
        [cellFriend setUser:friend];
        [cellFriend.buttonUser addTarget:self action:@selector(showUser:) forControlEvents:UIControlEventTouchUpInside];
        cellFriend.buttonUser.tag = [friend.userId integerValue];
        
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
    
    [labelBig setFont:[UIFont systemFontOfSize:15]];
    labelBig.text = [NSString stringWithFormat:@"%d", cellIndex+1];
    labelSmall.text = [NSString stringWithFormat:@"%d", cellIndex+1];
    [labelSmall setFont:[UIFont systemFontOfSize:11]];
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
        button.tag = [pic.pictureId integerValue];
        [button addTarget:self action:@selector(showPhoto:) forControlEvents:UIControlEventTouchUpInside];
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
        return 50;
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

- (void)showPhoto:(UIButton*)sender {
    [self performSegueWithIdentifier:@"PictureDetail" sender:sender];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(UIButton *)sender {
    if ([segue.identifier isEqualToString:@"PictureDetail"]) {
        luxeysPicDetailViewController* viewPicDetail = segue.destinationViewController;
        [viewPicDetail setPictureID:sender.tag];
    }
    if ([segue.identifier isEqualToString:@"Calendar"]) {
        luxeysUserCalendarViewController* viewCalendar = segue.destinationViewController;
        [viewCalendar setUserID:userID];
    }
}

- (void)setUserID:(int)aUserID {
    userID = aUserID;
}

- (IBAction)touchContact:(id)sender {
    
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"友達から外す"
                                                       delegate:self
                                              cancelButtonTitle:nil
                                         destructiveButtonTitle:nil
                                              otherButtonTitles:nil];
    
    if (user.isFriend) {
        [sheet addButtonWithTitle:@"友達から外す"];
    } else {
        if (user.requestToMe != nil) {
            if ([user.requestToMe integerValue] != kUserRequestAccepted) {
                [sheet addButtonWithTitle:@"Approve"];
            }
        }
        if (user.requestToUser != nil) {
            if ([user.requestToMe integerValue] != kUserRequestAccepted) {
                [sheet addButtonWithTitle:@"友達申請中"];
            }
        }
        if ((user.requestToMe == nil) && (user.requestToUser == nil)) {
            [sheet addButtonWithTitle:@"友達に追加"];
        }
    }
    
    if (user.isFollowing) {
        [sheet addButtonWithTitle:@"お気に入りから外す"];
    } else {
        [sheet addButtonWithTitle:@"お気に入りに追加"];
    }
    [sheet addButtonWithTitle:@"キャンセル"];
    
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
    [HUD show:YES];
    if (user.requestToMe != nil) {
        if ([user.requestToMe integerValue] != kUserRequestAccepted) {
            
            luxeysAppDelegate* app = (luxeysAppDelegate*)[[UIApplication sharedApplication] delegate];
            
            NSString *url = [NSString stringWithFormat:@"/api/user/friend/approve/%d", [user.userId integerValue]];
            [[LatteAPIClient sharedClient] postPath:url
                                         parameters: [NSDictionary dictionaryWithObjectsAndKeys:[app getToken], @"token", nil]
                                            success:^(AFHTTPRequestOperation *operation, NSDictionary *JSON) {
                                                [self reloadProfile];
                                            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                NSLog(@"Something went wrong (User - Approve)");
                                                [HUD hide:YES];
                                            }];
        }
    }
    if ((user.requestToMe == nil) && (user.requestToUser == nil)) {
        
        luxeysAppDelegate* app = (luxeysAppDelegate*)[[UIApplication sharedApplication] delegate];
        
        NSString *url = [NSString stringWithFormat:@"/api/user/friend/request/%d", [user.userId integerValue]];
        [[LatteAPIClient sharedClient] postPath:url
                                     parameters: [NSDictionary dictionaryWithObjectsAndKeys:[app getToken], @"token", nil]
                                        success:^(AFHTTPRequestOperation *operation, NSDictionary *JSON) {
                                            [self reloadProfile];
                                        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                            NSLog(@"Something went wrong (User - Send request)");
                                            [HUD hide:YES];
                                        }];
    }
}

- (void)toggleFollow {
    [HUD show:YES];
    luxeysAppDelegate* app = (luxeysAppDelegate*)[[UIApplication sharedApplication] delegate];
    if (user.isFollowing) {
        NSString *url = [NSString stringWithFormat:@"/api/user/unfollow/%d", [user.userId integerValue]];
        [[LatteAPIClient sharedClient] postPath:url
                                    parameters: [NSDictionary dictionaryWithObjectsAndKeys:[app getToken], @"token", nil]
                                       success:^(AFHTTPRequestOperation *operation, NSDictionary *JSON) {
                                           [self reloadProfile];
                                       } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                           NSLog(@"Something went wrong (User - Unfollow)");
                                           [HUD hide:YES];
                                       }];
    } else {
        NSString *url = [NSString stringWithFormat:@"/api/user/follow/%d", [user.userId integerValue]];
        [[LatteAPIClient sharedClient] postPath:url
                                    parameters: [NSDictionary dictionaryWithObjectsAndKeys:[app getToken], @"token", nil]
                                       success:^(AFHTTPRequestOperation *operation, NSDictionary *JSON) {
                                           [self reloadProfile];
                                       } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                           NSLog(@"Something went wrong (User - Follow)");
                                           [HUD hide:YES];
                                       }];
    }
}

- (void)removeFriend {
    [HUD show:YES];
    luxeysAppDelegate* app = (luxeysAppDelegate*)[[UIApplication sharedApplication] delegate];
    NSString *url = [NSString stringWithFormat:@"/api/user/friend/remove/%d", [user.userId integerValue]];
    [[LatteAPIClient sharedClient] postPath:url
                                 parameters: [NSDictionary dictionaryWithObjectsAndKeys:[app getToken], @"token", nil]
                                    success:^(AFHTTPRequestOperation *operation, NSDictionary *JSON) {
                                        [self reloadProfile];
                                    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                        NSLog(@"Something went wrong (User - Remove friend)");
                                        [HUD hide:YES];
                                    }];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (buttonIndex) {
        case 0:
            [self sendFriendRequest];
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
    luxeysUserViewController *viewUser = [mainStoryboard instantiateViewControllerWithIdentifier:@"UserProfile"];
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
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    [refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (tableMode == kTableCalendar) {
        UIView *view = [[UIView alloc] init];
        view.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.8];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 3, 100, 30)];
        label.textAlignment = NSTextAlignmentCenter;
        
        luxeysButtonBrown30 *prev = [[luxeysButtonBrown30 alloc] initWithFrame:CGRectMake(5, 5, 60, 30)];
        luxeysButtonBrown30 *next = [[luxeysButtonBrown30 alloc] initWithFrame:CGRectMake(255, 5, 60, 30)];
        [prev addTarget:self action:@selector(prevMonth:) forControlEvents:UIControlEventTouchUpInside];
        [next addTarget:self action:@selector(nextMonth:) forControlEvents:UIControlEventTouchUpInside];
        [prev setTitle:@"Prev" forState:UIControlStateNormal];
        [next setTitle:@"Next" forState:UIControlStateNormal];
        label.center = CGPointMake(160, 15);
        
        
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"yyyy/MM"];
        label.text = [dateFormat stringFromDate:currentMonth];
        label.textColor = [UIColor colorWithRed:101.0/255.0	green:90.0/255.0 blue:56.0/255.0 alpha:1];
        label.backgroundColor = [UIColor clearColor];
        [label setFont:[UIFont fontWithName:@"Baskerville-SemiBold" size:16]];
        [view addSubview:prev];
        [view addSubview:next];
        [view addSubview:label];
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
    if (tableMode == kTableCalendar) {
        return 40;
    }
    return 0;
}


@end
