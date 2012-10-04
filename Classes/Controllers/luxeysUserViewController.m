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
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    // Style
    showSet = [NSMutableSet setWithObjects:@"gender", @"residence", @"age", @"birthdate", @"bloodtype", @"occupation", @"introduction", @"hobby", nil];
    
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
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        [[luxeysLatteAPIClient sharedClient] getPath:strURL
                                          parameters: [NSDictionary dictionaryWithObjectsAndKeys:[app getToken], @"token", nil]
                                             success:^(AFHTTPRequestOperation *operation, NSDictionary *JSON) {
                                                 userDict = [JSON objectForKey:@"user"];
                                                 user =  [LuxeysUser instanceFromDictionary:userDict];
                                                 labelNickname.text = user.name;
                                                 [buttonFriendCount setTitle:[user.countFriends stringValue] forState:UIControlStateNormal];
                                                 [buttonPhotoCount setTitle:[user.countPictures stringValue] forState:UIControlStateNormal];
                                                 [buttonVoteCount setTitle:[user.voteCount stringValue] forState:UIControlStateNormal];
                                                 
                                                 [self.imageUser setImageWithURL:[NSURL URLWithString:user.profilePicture]];
                                                 
                                                 NSSet *allField = [NSSet setWithArray:[userDict allKeys]];
                                                 [showSet intersectSet:allField];
                                                 showField = [showSet allObjects];
                                                 [tableProfile reloadData];
                                                 
                                                 [self doneLoadingTableViewData];
                                                 dispatch_async(dispatch_get_main_queue(), ^{
                                                     [MBProgressHUD hideHUDForView:self.view animated:YES];
                                                 });
                                             }
                                             failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                 NSLog(@"Something went wrong (User - Profile)");
                                                 
                                                 dispatch_async(dispatch_get_main_queue(), ^{
                                                     [MBProgressHUD hideHUDForView:self.view animated:YES];
                                                 });
                                             }];
    });
}

- (void)reloadFriends {
    luxeysAppDelegate* app = (luxeysAppDelegate*)[[UIApplication sharedApplication] delegate];
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        NSString* urlFriends = [NSString stringWithFormat:@"api/user/%d/friend", userID];
        [[luxeysLatteAPIClient sharedClient] getPath:urlFriends
                                          parameters: [NSDictionary dictionaryWithObjectsAndKeys:[app getToken], @"token", nil]
                                             success:^(AFHTTPRequestOperation *operation, NSDictionary *JSON) {
                                                 friends = [LuxeysUser mutableArrayFromDictionary:JSON withKey:@"friends"];
                                                 [tableProfile reloadData];

                                                 [self doneLoadingTableViewData];
                                                 dispatch_async(dispatch_get_main_queue(), ^{
                                                     [MBProgressHUD hideHUDForView:self.view animated:YES];
                                                 });
                                                 
                                             } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                 NSLog(@"Something went wrong (User - Friendlist)");
                                                 
                                                 dispatch_async(dispatch_get_main_queue(), ^{
                                                     [MBProgressHUD hideHUDForView:self.view animated:YES];
                                                 });
                                             }];
    });
}

- (void)reloadPicList {
    luxeysAppDelegate* app = (luxeysAppDelegate*)[[UIApplication sharedApplication] delegate];
    NSString* urlPhotos = [NSString stringWithFormat:@"api/picture/user/%d", userID];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        [[luxeysLatteAPIClient sharedClient] getPath:urlPhotos
                                          parameters: [NSDictionary dictionaryWithObjectsAndKeys:[app getToken], @"token", nil]
                                             success:^(AFHTTPRequestOperation *operation, NSDictionary *JSON) {
                                                 photos = [LuxeysPicture mutableArrayFromDictionary:JSON withKey:@"pictures"];
                                                 [tableProfile reloadData];

                                                 [self doneLoadingTableViewData];
                                                 dispatch_async(dispatch_get_main_queue(), ^{
                                                     [MBProgressHUD hideHUDForView:self.view animated:YES];
                                                 });
                                                 
                                             } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                 NSLog(@"Something went wrong (User - Photolist)");
                                                 
                                                 dispatch_async(dispatch_get_main_queue(), ^{
                                                     [MBProgressHUD hideHUDForView:self.view animated:YES];
                                                 });
                                             }];
    });
}

- (void)reloadInterest {
    luxeysAppDelegate* app = (luxeysAppDelegate*)[[UIApplication sharedApplication] delegate];
    NSString* urlPhotos = [NSString stringWithFormat:@"api/picture/user/interesting/%d", userID];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        [[luxeysLatteAPIClient sharedClient] getPath:urlPhotos
                                          parameters: [NSDictionary dictionaryWithObjectsAndKeys:[app getToken], @"token", nil]
                                             success:^(AFHTTPRequestOperation *operation, NSDictionary *JSON) {
                                                 interests = [LuxeysPicture mutableArrayFromDictionary:JSON withKey:@"pictures"];
                                                 [tableProfile reloadData];

                                                 [self doneLoadingTableViewData];
                                                 dispatch_async(dispatch_get_main_queue(), ^{
                                                     [MBProgressHUD hideHUDForView:self.view animated:YES];
                                                 });
                                                 
                                             } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                 NSLog(@"Something went wrong (User - Interesting)");
                                                 
                                                 dispatch_async(dispatch_get_main_queue(), ^{
                                                     [MBProgressHUD hideHUDForView:self.view animated:YES];
                                                 });
                                             }];
    });
}

- (void)reloadMap {
    
}

- (void)reloadCalendar {
    
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
            break;
        case 3:
            tableMode = kTableMap;
            break;
        case 4:
            tableMode = kTableVotes;
            if (interests == nil)
                [self reloadInterest];
            else
                [tableProfile reloadData];
            break;
        case 5:
            tableMode = kTablePicList;
            if (photos == nil)
                [self reloadPicList];
            else
                [tableProfile reloadData];
            break;
        case 6:
            tableMode = kTableFriends;
            if (friends == nil)
                [self reloadFriends];
            else
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
            LuxeysPicture *pic;
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
        LuxeysUser *friend = [friends objectAtIndex:indexPath.row];
        luxeysCellFriend* cellFriend = [tableProfile dequeueReusableCellWithIdentifier:@"Friend"];
        [cellFriend setUser:friend];
        [cellFriend.buttonUser addTarget:self action:@selector(showUser:) forControlEvents:UIControlEventTouchUpInside];
        cellFriend.buttonUser.tag = [friend.userId integerValue];
        
        return cellFriend;
    } else
        return [[UITableViewCell alloc] init];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableMode == kTableProfile) {
        return 30;
    } else if (tableMode == kTableFriends) {
        return 50;
    } else if ((tableMode == kTablePicList) || (tableMode == kTableVotes)) {
        return 78;
    } else
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
}

- (void)setUserID:(int)aUserID {
    userID = aUserID;
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

@end
