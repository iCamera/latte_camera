//
//  luxeysMypageViewController.m
//  Latte
//
//  Created by Xuan Dung Bui on 8/22/12.
//  Copyright (c) 2012 LUXEYS. All rights reserved.
//

#import "luxeysMypageViewController.h"

@interface luxeysMypageViewController ()

@end

@implementation luxeysMypageViewController
@synthesize buttonVoteCount;
@synthesize buttonPicCount;
@synthesize buttonFriendCount;
@synthesize buttonFollowCount;
@synthesize buttonTimelineAll;
@synthesize buttonTimelineFollow;
@synthesize buttonTimelineFriend;
@synthesize buttonTimelineMe;

@synthesize imageProfilePic;
@synthesize viewStats;
@synthesize buttonNavRight;
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
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(showTimeline:)
                                                 name:@"ShowTimeline"
                                               object:nil];
    tableMode = kTableTimeline;
    timelineMode = kListAll;
    toggleSection = [[NSMutableDictionary alloc] init];
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:imageProfilePic.bounds];
    imageProfilePic.layer.masksToBounds = NO;
    imageProfilePic.layer.shadowColor = [UIColor blackColor].CGColor;
    imageProfilePic.layer.shadowOffset = CGSizeMake(0.0f, 1.0f);
    imageProfilePic.layer.shadowOpacity = 1.0f;
    imageProfilePic.layer.shadowRadius = 1.0f;
    imageProfilePic.layer.shadowPath = shadowPath.CGPath;
    
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = CGRectMake(0, 120, 320, 10);
    gradient.colors = [NSArray arrayWithObjects:
                       (id)[[UIColor clearColor] CGColor],
                       (id)[[[UIColor blackColor] colorWithAlphaComponent:0.2f] CGColor],
                       nil];
    [viewStats.layer insertSublayer:gradient atIndex:0];
    
    refreshHeaderView = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - self.tableView.bounds.size.height, self.view.frame.size.width, self.tableView.bounds.size.height)];
    refreshHeaderView.delegate = self;
    [self.tableView addSubview:refreshHeaderView];
    
    luxeysAppDelegate* app = (luxeysAppDelegate*)[UIApplication sharedApplication].delegate;
    
    
    self.viewStats.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg_sub_back.png"]];
    self.tableView.backgroundColor = [UIColor whiteColor];
    
    //Init sidebar
    UIPanGestureRecognizer *navigationBarPanGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:app.storyMain action:@selector(revealGesture:)];
    [self.navigationController.navigationBar addGestureRecognizer:navigationBarPanGestureRecognizer];
    [buttonNavRight addTarget:app.storyMain action:@selector(revealRight:) forControlEvents:UIControlEventTouchUpInside];
    
    
    allTab = [NSArray arrayWithObjects:
              buttonFriendCount,
              buttonFollowCount,
              buttonPicCount,
              buttonVoteCount,
              buttonTimelineAll,
              buttonTimelineFollow,
              buttonTimelineFriend,
              buttonTimelineMe,
              nil];
    
    [self reloadView];
}

- (void)reloadTimeline {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        
        luxeysAppDelegate* app = (luxeysAppDelegate*)[UIApplication sharedApplication].delegate;
        [[luxeysLatteAPIClient sharedClient] getPath:@"api/user/me/timeline"
                                          parameters: [NSDictionary dictionaryWithObjectsAndKeys:
                                                       [app getToken], @"token",
                                                       [NSNumber numberWithInteger:timelineMode], @"listtype",
                                                       nil]
                                             success:^(AFHTTPRequestOperation *operation, NSDictionary *JSON) {
                                                 feeds = [LuxeysFeed mutableArrayFromDictionary:JSON
                                                                                        withKey:@"feeds"];
                                                 LuxeysFeed *lastFeed = feeds.lastObject;
                                                 lastFeedID = [lastFeed.feedID integerValue];
                                                 
                                                 [self.tableView reloadData];
                                                 [self doneLoadingTableViewData];
                                                 
                                                 
                                                 dispatch_async(dispatch_get_main_queue(), ^{
                                                     [MBProgressHUD hideHUDForView:self.view animated:YES];
                                                 });
                                             } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                 NSLog(@"Something went wrong (Timeline)");
                                                 
                                                 dispatch_async(dispatch_get_main_queue(), ^{
                                                     [MBProgressHUD hideHUDForView:self.view animated:YES];
                                                 });
                                             }];
    });
}

- (void)reloadProfile {
    luxeysAppDelegate* app = (luxeysAppDelegate*)[UIApplication sharedApplication].delegate;
    
    [[luxeysLatteAPIClient sharedClient] getPath:@"api/user/me"
                                      parameters: [NSDictionary dictionaryWithObjectsAndKeys:[app getToken], @"token", nil]
                                         success:^(AFHTTPRequestOperation *operation, NSDictionary *JSON) {
                                             LuxeysUser *user = [LuxeysUser instanceFromDictionary:[JSON objectForKey:@"user"]];
                                             app.currentUser = user;
                                             
                                             [imageProfilePic setImageWithURL:[NSURL URLWithString:user.profilePicture]];
                                             
                                             labelNickname.text = user.name;
                                             [buttonFriendCount setTitle:[user.countFriends stringValue] forState:UIControlStateNormal];
                                             [buttonVoteCount setTitle:[user.voteCount stringValue] forState:UIControlStateNormal];
                                             [buttonPicCount setTitle:[user.countPictures stringValue] forState:UIControlStateNormal];
                                             [buttonFollowCount setTitle:[user.countFollows stringValue] forState:UIControlStateNormal];
                                             
                                         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                             NSLog(@"Something went wrong (Profile)");
                                         }];
}

- (void)reloadPicList {
    luxeysAppDelegate* app = (luxeysAppDelegate*)[UIApplication sharedApplication].delegate;
    
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        [[luxeysLatteAPIClient sharedClient] getPath:@"api/picture/user/me"
                                          parameters: [NSDictionary dictionaryWithObjectsAndKeys:[app getToken], @"token", nil]
                                             success:^(AFHTTPRequestOperation *operation, NSDictionary *JSON) {
                                                 pictures = [LuxeysPicture mutableArrayFromDictionary:JSON
                                                                                              withKey:@"pictures"];
                                                 
                                                 
                                                 [self.tableView reloadData];
                                                 [self doneLoadingTableViewData];
                                                 
                                                 dispatch_async(dispatch_get_main_queue(), ^{
                                                     [MBProgressHUD hideHUDForView:self.view animated:YES];
                                                 });
                                             } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                 NSLog(@"Something went wrong (Photolist)");
                                                 [self doneLoadingTableViewData];
                                                 dispatch_async(dispatch_get_main_queue(), ^{
                                                     [MBProgressHUD hideHUDForView:self.view animated:YES];
                                                 });
                                             }];
    });
}

- (void)reloadFriends {
    luxeysAppDelegate* app = (luxeysAppDelegate*)[UIApplication sharedApplication].delegate;
    
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        [[luxeysLatteAPIClient sharedClient] getPath:@"api/user/me/friend"
                                          parameters: [NSDictionary dictionaryWithObjectsAndKeys:[app getToken], @"token", nil]
                                             success:^(AFHTTPRequestOperation *operation, NSDictionary *JSON) {
                                                 friends = [LuxeysUser mutableArrayFromDictionary:JSON
                                                                                          withKey:@"friends"];
                                                 
                                                 
                                                 [self.tableView reloadData];
                                                 [self doneLoadingTableViewData];
                                                 dispatch_async(dispatch_get_main_queue(), ^{
                                                     [MBProgressHUD hideHUDForView:self.view animated:YES];
                                                 });
                                                 
                                             } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                 NSLog(@"Something went wrong (Friendlist)");
                                                 [self doneLoadingTableViewData];
                                                 
                                                 dispatch_async(dispatch_get_main_queue(), ^{
                                                     [MBProgressHUD hideHUDForView:self.view animated:YES];
                                                 });
                                             }];
    });
}

- (void)reloadFollowings {
    luxeysAppDelegate* app = (luxeysAppDelegate*)[UIApplication sharedApplication].delegate;
    
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        [[luxeysLatteAPIClient sharedClient] getPath:@"api/user/me/following"
                                          parameters: [NSDictionary dictionaryWithObjectsAndKeys:[app getToken], @"token", nil]
                                             success:^(AFHTTPRequestOperation *operation, NSDictionary *JSON) {
                                                 followings = [LuxeysUser mutableArrayFromDictionary:JSON
                                                                                             withKey:@"following"];
                                                 
                                                 [self.tableView reloadData];
                                                 [self doneLoadingTableViewData];
                                                 
                                                 dispatch_async(dispatch_get_main_queue(), ^{
                                                     [MBProgressHUD hideHUDForView:self.view animated:YES];
                                                 });
                                             } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                 NSLog(@"Something went wrong (Friendlist)");
                                                 [self doneLoadingTableViewData];
                                                 
                                                 dispatch_async(dispatch_get_main_queue(), ^{
                                                     [MBProgressHUD hideHUDForView:self.view animated:YES];
                                                 });
                                             }];
    });
}

- (void)reloadVoted {
    luxeysAppDelegate* app = (luxeysAppDelegate*)[UIApplication sharedApplication].delegate;
    
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        [[luxeysLatteAPIClient sharedClient] getPath:@"api/picture/user/interesting/me"
                                          parameters: [NSDictionary dictionaryWithObjectsAndKeys:[app getToken], @"token", nil]
                                             success:^(AFHTTPRequestOperation *operation, NSDictionary *JSON) {
                                                 votes = [LuxeysPicture mutableArrayFromDictionary:JSON
                                                                                              withKey:@"pictures"];
                                                 
                                                 [self.tableView reloadData];
                                                 [self doneLoadingTableViewData];
                                                 
                                                 dispatch_async(dispatch_get_main_queue(), ^{
                                                     [MBProgressHUD hideHUDForView:self.view animated:YES];
                                                 });
                                             } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                 NSLog(@"Something went wrong (Photolist)");
                                                 [self doneLoadingTableViewData];
                                                 dispatch_async(dispatch_get_main_queue(), ^{
                                                     [MBProgressHUD hideHUDForView:self.view animated:YES];
                                                 });
                                             }];
    });
}


- (void)reloadView {
    [self reloadProfile];
    
    switch (tableMode) {
        case kTableTimeline:
            [self reloadTimeline];
            break;
        case kTableFollowings:
            [self reloadFollowings];
            break;
        case kTablePicList:
            [self reloadPicList];
            break;
        case kTableFriends:
            [self reloadFriends];
            break;
        case kTableVoted:
            [self reloadVoted];
            break;
        default:
            break;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (tableMode == kTableTimeline) {
        return feeds.count;
    } else
        return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableMode == kTableTimeline) {
        LuxeysFeed *feed = [feeds objectAtIndex:section];
        
        if (feed.targets.count == 1) {
            LuxeysPicture *pic = [feed.targets objectAtIndex:0];
            NSInteger commentCount = [pic.commentCount integerValue];
            
            NSString *key = [NSString stringWithFormat:@"%d", section];
            if ([toggleSection objectForKey:key] == nil)
                return commentCount>3?3:commentCount;
            else
                return commentCount;
        } else
            return 0;
        
    }
    else if (tableMode == kTablePicList) {
        return (pictures.count/4) + (pictures.count%4>0?1:0);
    }
    else if (tableMode == kTableVoted) {
        return (votes.count/4) + (votes.count%4>0?1:0);
    }
    else if (tableMode == kTableFollowings) {
        return followings.count;
    }
    else if (tableMode == kTableFriends) {
        return friends.count;
    } else
        return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableMode == kTableTimeline)
    {
        LuxeysFeed *feed = [feeds objectAtIndex:indexPath.section];
        LuxeysPicture *pic = [feed.targets objectAtIndex:0];
        LuxeysComment *comment = [pic.comments objectAtIndex:indexPath.row];
        
        CGSize labelSize = [comment.descriptionText sizeWithFont:[UIFont systemFontOfSize:11]
                                               constrainedToSize:CGSizeMake(255.0f, MAXFLOAT)
                                                   lineBreakMode:NSLineBreakByWordWrapping];
        return labelSize.height + 25;
    } else if ((tableMode == kTableVoted) || (tableMode == kTablePicList)) {
        return 78;
    }
    else
        return 50;
}

- (UIView *)createComment:(LuxeysComment *)comment {
    UIView *view = [[UIView alloc] init];
    UIButton *picUser = [[UIButton alloc] initWithFrame:CGRectMake(5, 5, 25, 25)];
    UILabel *labelUser = [[UILabel alloc] initWithFrame:CGRectMake(35, 5, 200, 20)];
    UILabel *labelComment = [[UILabel alloc] initWithFrame:CGRectMake(35, 25, 200, 20)];
    
    labelComment.text = comment.descriptionText;
    labelUser.text = comment.user.name;
    [picUser loadBackground:comment.user.profilePicture];
    
    [view addSubview:picUser];
    [view addSubview:labelUser];
    [view addSubview:labelComment];
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (tableMode == kTableTimeline) {
        LuxeysFeed *feed = [feeds objectAtIndex:section];
        if (feed.targets.count == 1) {
            LuxeysPicture *pic = [feed.targets objectAtIndex:0];
            float newheight = [luxeysImageUtils heightFromWidth:300
                                                          width:[pic.width floatValue]
                                                         height:[pic.height floatValue]];
            if ([pic.commentCount integerValue] > 3)
                return newheight + 115;
            else
                return newheight + 90;
        }
        else {
            return 245;
        }
    } else
        return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (tableMode == kTableTimeline) {
        LuxeysFeed *feed = [feeds objectAtIndex:section];
        
        if (feed.targets.count == 1) {
            LuxeysPicture *pic = [feed.targets objectAtIndex:0];
            luxeysTemplatePicTimeline *viewPic = [[luxeysTemplatePicTimeline alloc] initWithPic:pic user:feed.user section:section sender:self];
            return viewPic.view;
        }
        else {
            luxeysTemplateTimelinePicMulti *viewMultiPic = [[luxeysTemplateTimelinePicMulti alloc] initWithPics:feed.targets user:feed.user section:section sender:self];
            return viewMultiPic.view;
        }
    }
    else
        return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableMode == kTableTimeline)
    {
        LuxeysFeed *feed = [feeds objectAtIndex:indexPath.section];
        LuxeysPicture *pic = [feed.targets objectAtIndex:0];
        luxeysTableViewCellComment* cellComment = [tableView dequeueReusableCellWithIdentifier:@"Comment"];
        
        LuxeysComment *comment = [pic.comments objectAtIndex:indexPath.row];
        [cellComment setComment:comment];
        
        cellComment.buttonUser.tag = [comment.user.userId integerValue];
        [cellComment.buttonUser addTarget:self action:@selector(showUser:) forControlEvents:UIControlEventTouchUpInside];
        
        cellComment.backgroundView = [[UIView alloc] init];
        cellComment.backgroundView.backgroundColor = [UIColor colorWithRed:0.91f green:0.90f blue:0.88 alpha:1];
        cellComment.backgroundView.layer.cornerRadius = 5;
        cellComment.backgroundView.layer.masksToBounds = YES;
        cellComment.backgroundView.layer.borderWidth = 0.5f;
        cellComment.backgroundView.layer.borderColor = [[UIColor whiteColor] CGColor];
        
        return cellComment;
    }
    else if ((tableMode == kTableVoted) || (tableMode == kTablePicList)) {
        UITableViewCell *cellPic = [[UITableViewCell alloc] init];
        for (int i = 0; i < 4; ++i)
        {
            NSInteger index = indexPath.row*4+i;
            
            LuxeysPicture *pic;
            if (tableMode == kTableVoted) {
                if (index >= votes.count)
                    break;
                pic = [votes objectAtIndex:index];
            }
            if (tableMode == kTablePicList) {
                if (index >= pictures.count)
                    break;
                pic = [pictures objectAtIndex:index];
            }
            
            
            UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(10+(i*77), 10, 67, 67)];
            [button loadBackground:pic.urlSquare];
            button.layer.borderColor = [[UIColor whiteColor] CGColor];
            button.layer.borderWidth = 3;
            
            UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:button.bounds];
            button.layer.masksToBounds = NO;
            button.layer.shadowColor = [UIColor blackColor].CGColor;
            button.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
            button.layer.shadowOpacity = 0.5f;
            button.layer.shadowRadius = 1.5f;
            button.layer.shadowPath = shadowPath.CGPath;
            
            button.tag = [pic.pictureId integerValue];
            [button addTarget:self action:@selector(showDetail:) forControlEvents:UIControlEventTouchUpInside];
            [cellPic addSubview:button];
            
        }
        cellPic.backgroundView = [[UIView alloc] initWithFrame:cellPic.bounds];
        
        return cellPic;
    }
    else {
        luxeysCellFriend* cellUser;
        LuxeysUser *user;
        if (tableMode == kTableFriends) {
            cellUser = [tableView dequeueReusableCellWithIdentifier:@"Friend"];
            user = [friends objectAtIndex:indexPath.row];
        } else if (tableMode == kTableFollowings) {
            cellUser = [tableView dequeueReusableCellWithIdentifier:@"Following"];
            user = [followings objectAtIndex:indexPath.row];
        }
        
        [cellUser setUser:user];
        cellUser.buttonUser.tag = [user.userId integerValue];
        [cellUser.buttonUser addTarget:self action:@selector(showUser:) forControlEvents:UIControlEventTouchUpInside];
        cellUser.backgroundView = [[UIView alloc] initWithFrame:cellUser.bounds];
        
        return cellUser;
    }
}


- (void)viewDidUnload
{
    [self setImageProfilePic:nil];
    [self setViewStats:nil];
    [self setButtonNavRight:nil];
    [self setButtonVoteCount:nil];
    [self setButtonPicCount:nil];
    [self setButtonFriendCount:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)switchTimeline:(int)mode {
    tableMode = kTableTimeline;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    if (timelineMode != mode) {
        timelineMode = mode;
        [self reloadTimeline];
    } else
        [self.tableView reloadData];
    
}

- (IBAction)touchTab:(UIButton *)sender {
    for (UIButton *button in allTab) {
        button.enabled = YES;
    }
    
    sender.enabled = NO;
    switch (sender.tag) {
        case 1:
            tableMode = kTableVoted;
            if (votes == nil)
                [self reloadVoted];
            else
                [self.tableView reloadData];
            break;
        case 2:
            tableMode = kTablePicList;
            if (pictures == nil)
                [self reloadPicList];
            else
                [self.tableView reloadData];
            break;
        case 3:
            tableMode = kTableFriends;
            if (friends == nil)
                [self reloadFriends];
            else
                [self.tableView reloadData];
            break;
        case 4:
            tableMode = kTableFollowings;
            if (followings == nil)
                [self reloadFollowings];
            else
                [self.tableView reloadData];
            break;
        case 5:
            [self switchTimeline:kListAll];
            break;
        case 6:
            [self switchTimeline:kListMe];
            break;
        case 7:
            [self switchTimeline:kListFriend];
            break;
        case 8:
            [self switchTimeline:kListFollow];
            break;
    }
}

- (IBAction)touchSetting:(id)sender {
    QRootElement *root = [[QRootElement alloc] initWithJSONFile:@"lattesetting"];
    luxeysSettingViewController* viewSetting = [[luxeysSettingViewController alloc] initWithRoot:root];
    
    [self.navigationController pushViewController:viewSetting animated:YES];
}


- (void)showTimeline:(NSNotification *) notification {
    [self switchTimeline:kListAll];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(UIButton *)button {
    if ([segue.identifier isEqualToString:@"PictureDetail"]) {
        luxeysPicDetailViewController* viewPicDetail = segue.destinationViewController;
        [viewPicDetail setPictureID:button.tag];
    }
    else if ([segue.identifier isEqualToString:@"PictureInfo"]) {
        luxeysPicInfoViewController *viewInfo = segue.destinationViewController;
        [viewInfo setPictureID:button.tag];
    }
    else if ([segue.identifier isEqualToString:@"Comment"]) {
        LuxeysFeed *feed = [self feedFromPicID:button.tag];
        LuxeysPicture *pic = [self picFromPicID:button.tag];
        
        luxeysPicCommentViewController *viewComment = segue.destinationViewController;
        [viewComment setPic:pic withUser:feed.user withParent:self];
    } else if ([segue.identifier isEqualToString:@"UserProfile"]) {
        luxeysUserViewController *viewUser = segue.destinationViewController;
        [viewUser setUserID:button.tag];
    }
}

- (void)showInfo:(UIButton*)sender {
    [self performSegueWithIdentifier:@"PictureInfo" sender:sender];
}

- (void)showDetail:(UIButton*)sender {
    [self performSegueWithIdentifier:@"PictureDetail" sender:sender];
}

- (void)showComment:(UIButton*)sender {
    [self performSegueWithIdentifier:@"Comment" sender:sender];
}

- (void)showUser:(UIButton*)sender {
    [self performSegueWithIdentifier:@"UserProfile" sender:sender];
}

- (void)submitLike:(UIButton*)sender {
    sender.enabled = FALSE;
    LuxeysFeed *feed = [self feedFromPicID:sender.tag];
    LuxeysPicture *pic = [self picFromPicID:sender.tag];
    pic.isVoted = TRUE;
    if ([feed.count integerValue] > 1) {
        NSInteger likeCount = [sender.titleLabel.text integerValue];
        NSNumber *num = [NSNumber numberWithInteger:likeCount + 1];
        [sender setTitle:[num stringValue] forState:UIControlStateDisabled];
    } else {
        pic.voteCount = [NSNumber numberWithInteger:[pic.voteCount integerValue] + 1];
        long section = [feeds indexOfObject:feed];
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:section] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    
    luxeysAppDelegate* app = (luxeysAppDelegate*)[UIApplication sharedApplication].delegate;
    NSDictionary *param = [NSDictionary dictionaryWithObjectsAndKeys:
                           [app getToken], @"token",
                           @"1", @"vote_type",
                           nil];
    
    NSString *url = [NSString stringWithFormat:@"api/picture/%d/vote_post", sender.tag];
    [[luxeysLatteAPIClient sharedClient] postPath:url
                                       parameters:param
                                          success:^(AFHTTPRequestOperation *operation, NSDictionary *JSON) {
                                                 NSLog(@"Submited like"); 
                                          } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                              NSLog(@"Something went wrong (Vote)");
                                          }];
}

- (void)showPicWithID:(UIButton*)sender {
    [self performSegueWithIdentifier:@"PictureDetail" sender:sender];
}

- (void)toggleComment:(UIButton*)sender {
    NSInteger section = sender.tag;
    
    NSMutableArray *indexes = [[NSMutableArray alloc] init];
    LuxeysFeed *feed = [feeds objectAtIndex:section];
    LuxeysPicture *pic = [feed.targets objectAtIndex:0];
    for (int i = 3; i < pic.comments.count; i++) {
        [indexes addObject:[NSIndexPath indexPathForItem:i inSection:section]];
    }
    
    NSString *key = [NSString stringWithFormat:@"%d", section];
    NSNumber *check = [NSNumber numberWithBool:TRUE];
    if ([toggleSection objectForKey:key] == nil) {
        [toggleSection setObject:check forKey:key];
        [self.tableView insertRowsAtIndexPaths:indexes withRowAnimation:UITableViewRowAnimationAutomatic];
        
    } else {
        [toggleSection removeObjectForKey:key];
        [self.tableView deleteRowsAtIndexPaths:indexes withRowAnimation:UITableViewRowAnimationAutomatic];
    }
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
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    [refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
}

- (void)submitComment:(LuxeysPicture *)pic {
    long section = [feeds indexOfObject:[self feedFromPicID:[pic.pictureId longValue]]];
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:section] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (LuxeysFeed *)feedFromPicID:(long)picID {
    for (LuxeysFeed *feed in feeds) {
        if ([feed.model integerValue] == kModelPicture) {
            for (LuxeysPicture *pic in feed.targets) {
                if ([pic.pictureId integerValue] == picID) {
                    return feed;
                }
            }
        }
    }
    return nil;
}

- (LuxeysPicture *)picFromPicID:(long)picID {
    for (LuxeysFeed *feed in feeds) {
        if ([feed.model integerValue] == kModelPicture) {
            for (LuxeysPicture *pic in feed.targets) {
                if ([pic.pictureId integerValue] == picID) {
                    return pic;
                }
            }
        }
    }
    return nil;
}



@end
