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
    
    imageProfilePic.layer.cornerRadius = 5;
    imageProfilePic.clipsToBounds = YES;
    
    
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
    UIPanGestureRecognizer *navigationBarPanGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:app.revealController action:@selector(revealGesture:)];
    [self.navigationController.navigationBar addGestureRecognizer:navigationBarPanGestureRecognizer];
    [buttonNavRight addTarget:app.revealController action:@selector(revealRight:) forControlEvents:UIControlEventTouchUpInside];
    
    
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
    
    HUD = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
	HUD.mode = MBProgressHUDModeText;
	HUD.labelText = @"Loading...";
	HUD.margin = 10.f;
	HUD.yOffset = 150.f;
    
    [self reloadView];
}

- (void)reloadTimeline {
    [HUD show:YES];
    luxeysAppDelegate* app = (luxeysAppDelegate*)[UIApplication sharedApplication].delegate;
    [[LatteAPIClient sharedClient] getPath:@"api/user/me/timeline"
                                parameters: [NSDictionary dictionaryWithObjectsAndKeys:
                                             [app getToken], @"token",
                                             [NSNumber numberWithInteger:timelineMode], @"listtype",
                                             nil]
                                   success:^(AFHTTPRequestOperation *operation, NSDictionary *JSON) {
                                       feeds = [Feed mutableArrayFromDictionary:JSON
                                                                        withKey:@"feeds"];
                                       Feed *lastFeed = feeds.lastObject;
                                       lastFeedID = [lastFeed.feedID integerValue];
                                       
                                       [self.tableView reloadData];
                                       [self doneLoadingTableViewData];
                                       
                                       
                                       [HUD hide:YES];
                                   } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                       NSLog(@"Something went wrong (Timeline)");
                                       
                                       [HUD hide:YES];
                                   }];
}

- (void)reloadProfile {
    luxeysAppDelegate* app = (luxeysAppDelegate*)[UIApplication sharedApplication].delegate;
    
    [[LatteAPIClient sharedClient] getPath:@"api/user/me"
                                parameters: [NSDictionary dictionaryWithObjectsAndKeys:[app getToken], @"token", nil]
                                   success:^(AFHTTPRequestOperation *operation, NSDictionary *JSON) {
                                       User *user = [User instanceFromDictionary:[JSON objectForKey:@"user"]];
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
    [HUD show:YES];
    luxeysAppDelegate* app = (luxeysAppDelegate*)[UIApplication sharedApplication].delegate;
    
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        [[LatteAPIClient sharedClient] getPath:@"api/picture/user/me"
                                    parameters: [NSDictionary dictionaryWithObjectsAndKeys:[app getToken], @"token", nil]
                                       success:^(AFHTTPRequestOperation *operation, NSDictionary *JSON) {
                                           pictures = [Picture mutableArrayFromDictionary:JSON
                                                                                  withKey:@"pictures"];
                                           
                                           
                                           [self.tableView reloadData];
                                           [self doneLoadingTableViewData];
                                           
                                           [HUD hide:YES];
                                       } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                           NSLog(@"Something went wrong (Photolist)");
                                           [self doneLoadingTableViewData];
                                           [HUD hide:YES];
                                       }];
    });
}

- (void)reloadFriends {
    [HUD show:YES];
    luxeysAppDelegate* app = (luxeysAppDelegate*)[UIApplication sharedApplication].delegate;
    
    [[LatteAPIClient sharedClient] getPath:@"api/user/me/friend"
                                parameters: [NSDictionary dictionaryWithObjectsAndKeys:[app getToken], @"token", nil]
                                   success:^(AFHTTPRequestOperation *operation, NSDictionary *JSON) {
                                       friends = [User mutableArrayFromDictionary:JSON
                                                                          withKey:@"friends"];
                                       
                                       [HUD hide:YES];
                                       [self doneLoadingTableViewData];
                                       [self.tableView reloadData];
                                       
                                   } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                       NSLog(@"Something went wrong (Friendlist)");
                                       [self doneLoadingTableViewData];
                                       
                                       [HUD hide:YES];
                                   }];
}

- (void)reloadFollowings {
    [HUD show:YES];
    luxeysAppDelegate* app = (luxeysAppDelegate*)[UIApplication sharedApplication].delegate;
    
    [[LatteAPIClient sharedClient] getPath:@"api/user/me/following"
                                parameters: [NSDictionary dictionaryWithObjectsAndKeys:[app getToken], @"token", nil]
                                   success:^(AFHTTPRequestOperation *operation, NSDictionary *JSON) {
                                       followings = [User mutableArrayFromDictionary:JSON
                                                                             withKey:@"following"];
                                       
                                       [self doneLoadingTableViewData];
                                       [HUD hide:YES];
                                       [self.tableView reloadData];
                                   } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                       NSLog(@"Something went wrong (Friendlist)");
                                       [self doneLoadingTableViewData];
                                       [HUD hide:YES];
                                   }];
}

- (void)reloadVoted {
    [HUD show:YES];
    luxeysAppDelegate* app = (luxeysAppDelegate*)[UIApplication sharedApplication].delegate;
    
    [[LatteAPIClient sharedClient] getPath:@"api/picture/user/interesting/me"
                                parameters: [NSDictionary dictionaryWithObjectsAndKeys:[app getToken], @"token", nil]
                                   success:^(AFHTTPRequestOperation *operation, NSDictionary *JSON) {
                                       votes = [Picture mutableArrayFromDictionary:JSON
                                                                           withKey:@"pictures"];
                                       
                                       [self.tableView reloadData];
                                       [self doneLoadingTableViewData];
                                       
                                       [HUD hide:YES];
                                   } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                       NSLog(@"Something went wrong (Photolist)");
                                       [self doneLoadingTableViewData];
                                       [HUD hide:YES];
                                   }];
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
        Feed *feed = [feeds objectAtIndex:section];
        
        if (feed.targets.count == 1) {
            Picture *pic = [feed.targets objectAtIndex:0];
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
        Feed *feed = [feeds objectAtIndex:indexPath.section];
        Picture *pic = [feed.targets objectAtIndex:0];
        Comment *comment = [pic.comments objectAtIndex:indexPath.row];
        
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

- (UIView *)createComment:(Comment *)comment {
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
        Feed *feed = [feeds objectAtIndex:section];
        if (feed.targets.count == 1) {
            Picture *pic = [feed.targets objectAtIndex:0];
            float newheight = [luxeysUtils heightFromWidth:300
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
        return 1;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (tableMode == kTableTimeline) {
        Feed *feed = [feeds objectAtIndex:section];
        
        if (feed.targets.count == 1) {
            Picture *pic = [feed.targets objectAtIndex:0];
            luxeysTemplatePicTimeline *viewPic = [[luxeysTemplatePicTimeline alloc] initWithPic:pic user:feed.user section:section sender:self];
            return viewPic.view;
        }
        else {
            luxeysTemplateTimelinePicMulti *viewMultiPic = [[luxeysTemplateTimelinePicMulti alloc] initWithFeed:feed section:section sender:self];
            return viewMultiPic.view;
        }
    }
    else
        return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableMode == kTableTimeline)
    {
        Feed *feed = [feeds objectAtIndex:indexPath.section];
        Picture *pic = [feed.targets objectAtIndex:0];
        luxeysTableViewCellComment* cellComment = [tableView dequeueReusableCellWithIdentifier:@"Comment"];
        
        Comment *comment = [pic.comments objectAtIndex:indexPath.row];
        [cellComment setComment:comment];
        
        cellComment.buttonUser.tag = [comment.user.userId integerValue];
        [cellComment.buttonUser addTarget:self action:@selector(showUser:) forControlEvents:UIControlEventTouchUpInside];
        
        cellComment.backgroundView = [[UIView alloc] init];
        cellComment.backgroundView.backgroundColor = [UIColor colorWithRed:0.91f green:0.90f blue:0.88 alpha:1];
        // cellComment.backgroundView.layer.cornerRadius = 5;
        // cellComment.backgroundView.layer.masksToBounds = YES;
        cellComment.backgroundView.layer.borderWidth = 0.5f;
        cellComment.backgroundView.layer.borderColor = [[UIColor whiteColor] CGColor];
        
        return cellComment;
    }
    else if ((tableMode == kTableVoted) || (tableMode == kTablePicList)) {
        UITableViewCell *cellPic = [[UITableViewCell alloc] init];
        for (int i = 0; i < 4; ++i)
        {
            NSInteger index = indexPath.row*4+i;
            
            Picture *pic;
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
        User *user;
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
    for (UIButton *button in allTab) {
        button.enabled = YES;
    }
    buttonTimelineAll.enabled = NO;
    
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
        Feed *feed = [self feedFromPicID:button.tag];
        Picture *pic = [self picFromPicID:button.tag];
        
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
    Feed *feed = [self feedFromPicID:sender.tag];
    Picture *pic = [self picFromPicID:sender.tag];
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
    [[LatteAPIClient sharedClient] postPath:url
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
    Feed *feed = [feeds objectAtIndex:section];
    Picture *pic = [feed.targets objectAtIndex:0];
    for (int i = 3; i < pic.comments.count; i++) {
        [indexes addObject:[NSIndexPath indexPathForItem:i inSection:section]];
    }
    
    NSString *key = [NSString stringWithFormat:@"%d", section];
    NSNumber *check = [NSNumber numberWithBool:TRUE];
    if ([toggleSection objectForKey:key] == nil) {
        [toggleSection setObject:check forKey:key];
        [self.tableView insertRowsAtIndexPaths:indexes withRowAnimation:UITableViewRowAnimationAutomatic];
        
        NSIndexPath *path = [NSIndexPath indexPathForRow:0 inSection:section];
        CGRect rect = [self.tableView rectForRowAtIndexPath:path];
        rect.origin.y -= 30;
        [self.tableView setContentOffset:rect.origin animated:YES];
        
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

- (void)submitComment:(Picture *)pic {
    long section = [feeds indexOfObject:[self feedFromPicID:[pic.pictureId longValue]]];
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:section] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (Feed *)feedFromPicID:(long)picID {
    for (Feed *feed in feeds) {
        if ([feed.model integerValue] == kModelPicture) {
            for (Picture *pic in feed.targets) {
                if ([pic.pictureId integerValue] == picID) {
                    return feed;
                }
            }
        }
    }
    return nil;
}

- (Picture *)picFromPicID:(long)picID {
    for (Feed *feed in feeds) {
        if ([feed.model integerValue] == kModelPicture) {
            for (Picture *pic in feed.targets) {
                if ([pic.pictureId integerValue] == picID) {
                    return pic;
                }
            }
        }
    }
    return nil;
}



@end
