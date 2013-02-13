//
//  luxeysMypageViewController.m
//  Latte
//
//  Created by Xuan Dung Bui on 8/22/12.
//  Copyright (c) 2012 LUXEYS. All rights reserved.
//

#import "LXMyPageViewController.h"

@interface LXMyPageViewController ()

@end

@implementation LXMyPageViewController
@synthesize buttonVoteCount;
@synthesize buttonPicCount;
@synthesize buttonFriendCount;
@synthesize buttonFollowCount;
@synthesize buttonTimelineAll;
@synthesize buttonTimelineFollow;
@synthesize buttonTimelineFriend;
@synthesize buttonTimelineMe;

@synthesize buttonProfilePic;
@synthesize viewStats;
@synthesize buttonNavLeft;
@synthesize labelNickname;
@synthesize loadIndicator;

@synthesize labelTitleFav;
@synthesize labelTitlePicCount;
@synthesize labelTitleFriends;
@synthesize labelTitleVote;

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
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showTimeline:) name:@"LoggedIn" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(becomeActive:) name:@"BecomeActive" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receivedPushNotify:)
                                                 name:@"ReceivedPushNotify"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(readNotify:)
                                                 name:@"ReadNotify"
                                               object:nil];
    tableMode = kTableTimeline;
    timelineMode = kListAll;
    endedPic = false;
    endedTimeline = false;
    endedVoted = false;
    toggleSection = [[NSMutableDictionary alloc] init];
    pictures = [[NSMutableArray alloc] init];
    votes = [[NSMutableArray alloc] init];
    isEmpty = false;
    pagePic = 0;
    pageVote = 0;
    return self;
}

- (void)receivedPushNotify:(id)sender {
    [buttonNavLeft setImage:[UIImage imageNamed:@"icon_info_on.png"] forState:UIControlStateNormal];
}

- (void)readNotify:(id)sender {
    [buttonNavLeft setImage:[UIImage imageNamed:@"icon_info.png"] forState:UIControlStateNormal];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if ([UIApplication sharedApplication].applicationIconBadgeNumber > 0) {
        [buttonNavLeft setImage:[UIImage imageNamed:@"icon_info_on.png"] forState:UIControlStateNormal];
    }
    
    LXAppDelegate* app = (LXAppDelegate*)[UIApplication sharedApplication].delegate;
    [app.tracker sendView:@"Mypage Screen"];
    
    HUD = [[MBProgressHUD alloc] initWithView:self.tableView];
    [self.tableView addSubview:HUD];
    HUD.mode = MBProgressHUDModeText;
    HUD.labelText = NSLocalizedString(@"Loading...", @"Loading...") ;
    HUD.labelFont = [UIFont fontWithName:@"AvenirNextCondensed-Regular" size:16];
    HUD.margin = 10.f;
    HUD.yOffset = 150.f;
    
    UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:buttonProfilePic.bounds];
    buttonProfilePic.layer.masksToBounds = NO;
    buttonProfilePic.layer.shadowColor = [UIColor blackColor].CGColor;
    buttonProfilePic.layer.shadowOffset = CGSizeMake(0.0f, 1.0f);
    buttonProfilePic.layer.shadowOpacity = 1.0f;
    buttonProfilePic.layer.shadowRadius = 1.0f;
    buttonProfilePic.layer.shadowPath = shadowPath.CGPath;
    
    buttonProfilePic.layer.cornerRadius = 5;
    buttonProfilePic.clipsToBounds = YES;
    
    
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = CGRectMake(0, 108, 320, 10);
    gradient.colors = [NSArray arrayWithObjects:
                       (id)[[UIColor clearColor] CGColor],
                       (id)[[[UIColor blackColor] colorWithAlphaComponent:0.2f] CGColor],
                       nil];
    [viewStats.layer insertSublayer:gradient atIndex:0];
    
    refreshHeaderView = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - self.tableView.bounds.size.height, self.view.frame.size.width, self.tableView.bounds.size.height)];
    refreshHeaderView.delegate = self;
    [self.tableView addSubview:refreshHeaderView];
    
    
    self.viewStats.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg_sub_back.png"]];
    self.tableView.backgroundColor = [UIColor whiteColor];
    
    //Init sidebar
    UIPanGestureRecognizer *navigationBarPanGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:app.revealController action:@selector(revealGesture:)];
    [self.navigationController.navigationBar addGestureRecognizer:navigationBarPanGestureRecognizer];
    [buttonNavLeft addTarget:app.revealController action:@selector(revealLeft:) forControlEvents:UIControlEventTouchUpInside];
    
    
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
    [HUD show:YES];
    [loadIndicator startAnimating];
    LXAppDelegate* app = (LXAppDelegate*)[UIApplication sharedApplication].delegate;
    [[LatteAPIClient sharedClient] getPath:@"user/me/timeline"
                                parameters: [NSDictionary dictionaryWithObjectsAndKeys:
                                             [app getToken], @"token",
                                             [NSNumber numberWithInteger:timelineMode], @"listtype",
                                             nil]
                                   success:^(AFHTTPRequestOperation *operation, NSDictionary *JSON) {
                                       feeds = [Feed mutableArrayFromDictionary:JSON
                                                                        withKey:@"feeds"];
                                       isEmpty = feeds.count == 0;
                                       [self.tableView reloadData];
                                       [self doneLoadingTableViewData];
                                       [loadIndicator stopAnimating];
                                       [HUD hide:YES];
                                   } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                       [loadIndicator stopAnimating];
                                       TFLog(@"Something went wrong (Timeline)");
                                       [HUD hide:YES];
                                   }];
}

- (void)reloadProfile {
    LXAppDelegate* app = (LXAppDelegate*)[UIApplication sharedApplication].delegate;
    
    [[LatteAPIClient sharedClient] getPath:@"user/me"
                                parameters: [NSDictionary dictionaryWithObjectsAndKeys:[app getToken], @"token", nil]
                                   success:^(AFHTTPRequestOperation *operation, NSDictionary *JSON) {
                                       User *user = [User instanceFromDictionary:[JSON objectForKey:@"user"]];
                                       app.currentUser = user;
                                       
                                       [buttonProfilePic loadBackground:user.profilePicture placeholderImage:@"user.gif"];
                                       
                                       CATransition *animation = [CATransition animation];
                                       animation.duration = 1.0;
                                       animation.type = kCATransitionFade;
                                       animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
                                       [labelNickname.layer addAnimation:animation forKey:@"changeTextTransition"];
                                       [buttonFriendCount.titleLabel.layer addAnimation:animation forKey:@"changeTextTransition"];
                                       [buttonVoteCount.titleLabel.layer addAnimation:animation forKey:@"changeTextTransition"];
                                       [buttonPicCount.titleLabel.layer addAnimation:animation forKey:@"changeTextTransition"];
                                       [buttonFollowCount.titleLabel.layer addAnimation:animation forKey:@"changeTextTransition"];

                                       labelNickname.text = user.name;
                                       [buttonFriendCount setTitle:[user.countFriends stringValue] forState:UIControlStateNormal];
                                       [buttonVoteCount setTitle:[user.voteCount stringValue] forState:UIControlStateNormal];
                                       [buttonPicCount setTitle:[user.countPictures stringValue] forState:UIControlStateNormal];
                                       [buttonFollowCount setTitle:[user.countFollows stringValue] forState:UIControlStateNormal];
                                       
                                   } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                       TFLog(@"Something went wrong (Profile)");
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
                           [NSNumber numberWithInt:40], @"limit",
                           nil];
    
    [[LatteAPIClient sharedClient] getPath:@"picture/user/me"
                                parameters: param
                                   success:^(AFHTTPRequestOperation *operation, NSDictionary *JSON) {
                                       pictures = [Picture mutableArrayFromDictionary:JSON
                                                                                      withKey:@"pictures"];
                                       
                                       endedPic = pictures.count == 0;
                                       isEmpty = pictures.count == 0;
                                       [self.tableView reloadData];
                                       [self doneLoadingTableViewData];
                                       
                                       [loadIndicator stopAnimating];
                                       
                                       pagePic += 1;
                                   } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                       [loadIndicator stopAnimating];
                                       TFLog(@"Something went wrong (Photolist)");
                                       [self doneLoadingTableViewData];
                                   }];
}

- (void)loadMorePicList {
    LXAppDelegate* app = (LXAppDelegate*)[UIApplication sharedApplication].delegate;
    [loadIndicator startAnimating];

    NSDictionary *param = [NSDictionary dictionaryWithObjectsAndKeys:
        [app getToken], @"token",
        [NSNumber numberWithInt:pagePic + 1], @"page",
        [NSNumber numberWithInt:40], @"limit",
        nil];

    [[LatteAPIClient sharedClient] getPath:@"picture/user/me"
                                parameters: param
                                   success:^(AFHTTPRequestOperation *operation, NSDictionary *JSON) {
                                       NSArray *newPics = [Picture mutableArrayFromDictionary:JSON
                                                                              withKey:@"pictures"];

                                       endedPic = newPics.count == 0;
                                       NSInteger oldRow = [self tableView:self.tableView numberOfRowsInSection:0];
                                       [self.tableView beginUpdates];
                                       
                                       
                                       [pictures addObjectsFromArray:newPics];
                                       isEmpty = pictures.count == 0;
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
                                       TFLog(@"Something went wrong (Photolist)");
                                       [self doneLoadingTableViewData];
                                   }];
}

- (void)reloadFriends {
    LXAppDelegate* app = (LXAppDelegate*)[UIApplication sharedApplication].delegate;
    
    [[LatteAPIClient sharedClient] getPath:@"user/me/friend"
                                parameters: [NSDictionary dictionaryWithObjectsAndKeys:[app getToken], @"token", nil]
                                   success:^(AFHTTPRequestOperation *operation, NSDictionary *JSON) {
                                       friends = [User mutableArrayFromDictionary:JSON
                                                                          withKey:@"friends"];
                                       isEmpty = friends.count == 0;
                                       [self doneLoadingTableViewData];
                                       [self.tableView reloadData];
                                       
                                   } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                       TFLog(@"Something went wrong (Friendlist)");
                                       [self doneLoadingTableViewData];
                                   }];
}

- (void)reloadFollowings {
    LXAppDelegate* app = (LXAppDelegate*)[UIApplication sharedApplication].delegate;
    
    [[LatteAPIClient sharedClient] getPath:@"user/me/following"
                                parameters: [NSDictionary dictionaryWithObjectsAndKeys:[app getToken], @"token", nil]
                                   success:^(AFHTTPRequestOperation *operation, NSDictionary *JSON) {
                                       followings = [User mutableArrayFromDictionary:JSON
                                                                             withKey:@"following"];
                                       isEmpty = followings.count == 0;
                                       [self doneLoadingTableViewData];
                                       [self.tableView reloadData];
                                   } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                       TFLog(@"Something went wrong (Friendlist)");
                                       [self doneLoadingTableViewData];
                                   }];
}

- (void)reloadVoted {
    endedVoted = false;
    pageVote = 0;
    
    LXAppDelegate* app = (LXAppDelegate*)[UIApplication sharedApplication].delegate;
    [loadIndicator startAnimating];
    
    NSDictionary *param = [NSDictionary dictionaryWithObjectsAndKeys:
                           [app getToken], @"token",
                           [NSNumber numberWithInt:pageVote + 1], @"page",
                           [NSNumber numberWithInt:40], @"limit",
                           nil];
    
    [[LatteAPIClient sharedClient] getPath:@"picture/user/interesting/me"
                                parameters: param
                                   success:^(AFHTTPRequestOperation *operation, NSDictionary *JSON) {
                                       votes = [Picture mutableArrayFromDictionary:JSON
                                                                                       withKey:@"pictures"];
                                       endedVoted = votes.count == 0;
                                       isEmpty = votes.count == 0;
                                       
                                       [self.tableView reloadData];
                                       
                                       [self doneLoadingTableViewData];
                                       
                                       pageVote += 1;
                                       [loadIndicator stopAnimating];
                                   } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                       TFLog(@"Something went wrong (Photolist)");
                                       [self doneLoadingTableViewData];
                                       
                                       [loadIndicator stopAnimating];
                                   }];
}

- (void)loadMoreVotes {
    LXAppDelegate* app = (LXAppDelegate*)[UIApplication sharedApplication].delegate;
    [loadIndicator startAnimating];
    
    NSDictionary *param = [NSDictionary dictionaryWithObjectsAndKeys:
                           [app getToken], @"token",
                           [NSNumber numberWithInt:pageVote + 1], @"page",
                           [NSNumber numberWithInt:40], @"limit",
                           nil];
    
    [[LatteAPIClient sharedClient] getPath:@"picture/user/interesting/me"
                                parameters: param
                                   success:^(AFHTTPRequestOperation *operation, NSDictionary *JSON) {
                                       NSArray *newVotes = [Picture mutableArrayFromDictionary:JSON
                                                                           withKey:@"pictures"];
                                       endedVoted = newVotes.count == 0;
                                       
                                       NSInteger oldRow = [self tableView:self.tableView numberOfRowsInSection:0];
                                       [self.tableView beginUpdates];
                                       [votes addObjectsFromArray:newVotes];

                                       isEmpty = votes.count == 0;
                                       NSInteger newRow = [self tableView:self.tableView numberOfRowsInSection:0];
                                       for (NSInteger i = oldRow; i < newRow; i++) {
                                           [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:i inSection:0]]
                                                                 withRowAnimation:UITableViewRowAnimationAutomatic];
                                       }
                                       
                                       [self.tableView endUpdates];
                                       
                                       [self doneLoadingTableViewData];
                                       
                                       pageVote += 1;
                                       [loadIndicator stopAnimating];
                                   } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                       TFLog(@"Something went wrong (Photolist)");
                                       [self doneLoadingTableViewData];
                                       
                                       [loadIndicator stopAnimating];
                                   }];
}


- (void)reloadView {
    endedTimeline = false;
    endedVoted = false;
    endedPic = false;

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

- (void)loadMore {
    if (tableMode == kTableTimeline) {
        [loadIndicator startAnimating];
        Feed *feed = feeds.lastObject;
        
        LXAppDelegate* app = (LXAppDelegate*)[UIApplication sharedApplication].delegate;
        [[LatteAPIClient sharedClient] getPath:@"user/me/timeline"
                                    parameters: [NSDictionary dictionaryWithObjectsAndKeys:
                                                 [app getToken], @"token",
                                                 [NSNumber numberWithInteger:timelineMode], @"listtype",
                                                 feed.feedID, @"last_id",
                                                 nil]
                                       success:^(AFHTTPRequestOperation *operation, NSDictionary *JSON) {
                                           NSMutableArray *newFeed = [Feed mutableArrayFromDictionary:JSON
                                                                                              withKey:@"feeds"];

                                           
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
                                           TFLog(@"Something went wrong (Timeline)");
                                           [loadIndicator stopAnimating];
                                       }];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (isEmpty)
        return 0;
    
    if (tableMode == kTableTimeline) {
        return feeds.count;
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
        Feed *feed = feeds[indexPath.row];
        if (feed.targets.count > 1) {
            return 202.0 + 42.0 + 12.0;
        } else if (feed.targets.count == 1) {
            Picture *pic = feed.targets[0];
            CGFloat feedHeight = [LXUtils heightFromWidth:308.0 width:[pic.width floatValue] height:[pic.height floatValue]] + 85.0 + 6.0 + 6.0;
            
            if (pic.comments.count > 0) {
                
                for (NSInteger i = 0; i < pic.comments.count; i++) {
                    if ([toggleSection objectForKey:[NSString stringWithFormat:@"%d", [feed.feedID integerValue]]] == nil)
                        if (i >= 3)
                            break;
                    
                    Comment* comment = pic.comments[i];
                    CGSize commentSize = [comment.descriptionText sizeWithFont:[UIFont fontWithName:@"AvenirNextCondensed-Regular" size:11]
                                                             constrainedToSize:CGSizeMake(255.0f, MAXFLOAT)
                                                                 lineBreakMode:NSLineBreakByWordWrapping];
                    feedHeight += MAX(commentSize.height + 24.0, 36.0);
                }
            }
            
            if (pic.comments.count > 3)
                feedHeight += 25.0;
            
            return feedHeight;
        } else
            return 1;
    } else if ((tableMode == kTableVoted) || (tableMode == kTablePicList)) {
        return 78 + (indexPath.row==0?3:0);
    }
    else
        return 42;
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
    if (isEmpty)
        return 200;
    
    return 0;
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
    
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableMode == kTableTimeline)
    {
        Feed *feed = [feeds objectAtIndex:indexPath.row];
        if (feed.targets.count == 1)
        {
            LXCellTimelineSingle *cell = [tableView dequeueReusableCellWithIdentifier:@"Single"];
            if (cell == nil) {
                cell = [[LXCellTimelineSingle alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Single"];
            }
            
            if ([toggleSection objectForKey:[NSString stringWithFormat:@"%d", [feed.feedID integerValue]]] != nil)
                cell.isExpanded = true;
            else
                cell.isExpanded = false;
            
            cell.viewController = self;
            cell.feed = feed;
            
            return cell;
        } else {
            LXCellTimelineMulti *cell = [tableView dequeueReusableCellWithIdentifier:@"Multi"];
            if (cell == nil) {
                cell = [[LXCellTimelineMulti alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Multi"];
            }
            
            cell.showControl = true;
            cell.viewController = self;
            cell.feed = feed;
            return cell;
        }
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
            
            
            UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(6+(i*78), indexPath.row==0?6:3, 72, 72)];

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
            [button addTarget:self action:@selector(showPic:) forControlEvents:UIControlEventTouchUpInside];
            [cellPic addSubview:button];
            
        }
        cellPic.backgroundView = [[UIView alloc] initWithFrame:cellPic.bounds];
        
        return cellPic;
    }
    else {
        LXCellFriend* cellUser;
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
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 42, 320, 1)];
        line.backgroundColor = [UIColor colorWithRed:188.0/255.0 green:184.0/255.0 blue:169.0/255.0 alpha:1];
        [cellUser addSubview:line];
        return cellUser;
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)switchTimeline:(int)mode {
    tableMode = kTableTimeline;
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
    labelTitleFav.highlighted = NO;
    labelTitlePicCount.highlighted = NO;
    labelTitleFriends.highlighted = NO;
    labelTitleVote.highlighted = NO;
    
    sender.enabled = NO;
    switch (sender.tag) {
        case 1:
            labelTitleVote.highlighted = YES;
            tableMode = kTableVoted;
            if (votes.count == 0){
                [self reloadVoted];
            }else
                [self.tableView reloadData];
            break;
        case 2:
            labelTitlePicCount.highlighted = YES;
            tableMode = kTablePicList;
            if (pictures.count == 0) {
                [self reloadPicList];
            } else
                [self.tableView reloadData];
            break;
        case 3:
            labelTitleFriends.highlighted = YES;
            tableMode = kTableFriends;
            if (friends == nil) {
                [self reloadFriends];
            } else
                [self.tableView reloadData];
            break;
        case 4:
            labelTitleFav.highlighted = YES;
            tableMode = kTableFollowings;
            if (followings == nil) {
                [self reloadFollowings];
            } else
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
    Class JSONSerialization = [QRootElement JSONParserClass];
    NSAssert(JSONSerialization != NULL, @"No JSON serializer available!");
    
    NSError *jsonParsingError = nil;
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"lattesetting" ofType:@"json"];
    NSDictionary *data = [JSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:filePath] options:0 error:&jsonParsingError];
    
    QRootElement *root = [[LXRootBuilder new]buildWithObject:data];
    if (data != nil) {
        [root bindToObject:data];
    }
    LXSettingViewController* viewSetting = [[LXSettingViewController alloc] initWithRoot:root];
    
    [self.navigationController pushViewController:viewSetting animated:YES];
}

- (IBAction)touchSetProfilePic:(id)sender {
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"change_profile_pic", @"プロフィール")
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"cancel", @"キャンセル")
                                         destructiveButtonTitle:NSLocalizedString(@"remove_profile_pic", @"削除する")
                                              otherButtonTitles:NSLocalizedString(@"select_profile_pic", @"写真を選択する"), NSLocalizedString(@"my_profile", @"自分のプロフィール"), nil];
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
        case 2: {
            LXAppDelegate* app = (LXAppDelegate*)[UIApplication sharedApplication].delegate;
            UIButton *tmp = [[UIButton alloc] init];
            tmp.tag = [app.currentUser.userId integerValue];
            [self showUser:tmp];
            break;
        }
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
                                        [buttonProfilePic setBackgroundImage:[UIImage imageNamed:@"user.gif"] forState:UIControlStateNormal];
                                    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                        TFLog(@"Something went wrong (Delete profile pic)");
                                    }];

}

- (void)pickPhoto {
    LXAppDelegate* app = (LXAppDelegate*)[UIApplication sharedApplication].delegate;
    
    LXCameraViewController *viewCapture = ((UINavigationController*)app.viewCamera).viewControllers[0];
    viewCapture.delegate = self;
    [app toogleCamera];
}

- (void)imagePickerController:(LXCameraViewController *)picker didFinishPickingMediaWithData:(NSDictionary *)info {
    LXAppDelegate* app = (LXAppDelegate*)[UIApplication sharedApplication].delegate;
    UINavigationController* navCamera = (id)app.viewCamera;
    LXCameraViewController *viewCapture = navCamera.viewControllers[0];
    [navCamera popToRootViewControllerAnimated:NO];
    [viewCapture switchCamera];
    viewCapture.delegate = nil;
    [app toogleCamera];

    
    MBProgressHUD *progessHUD = [[MBProgressHUD alloc] initWithView:picker.view];
    [picker.view addSubview:progessHUD];
    
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
        
        [picker dismissViewControllerAnimated:NO completion:nil];
        [self reloadProfile];
    };
    
    void (^failUpload)(AFHTTPRequestOperation *, NSError *) = ^(AFHTTPRequestOperation *operation, NSError *error) {
        if([operation.response statusCode] != 200){
            TFLog(@"Upload Failed");
            return;
        }
        TFLog(@"error: %@", [operation error]);
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
    [self reloadView];
}


- (void)showInfo:(UIButton*)sender {
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"MainStoryboard"
                                                             bundle:nil];
    LXPicInfoViewController *viewPicInfo = [mainStoryboard instantiateViewControllerWithIdentifier:@"PictureInfo"];
    [viewPicInfo setPictureID:sender.tag];
    [self.navigationController pushViewController:viewPicInfo animated:YES];
}

- (void)showPic:(UIButton*)sender {
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"MainStoryboard"
                                                             bundle:nil];
    LXPicDetailViewController *viewPicDetail = [mainStoryboard instantiateViewControllerWithIdentifier:@"PictureDetail"];
    
    viewPicDetail.pic = [self picFromPicID:sender.tag];
    viewPicDetail.picID = sender.tag;

    [self.navigationController pushViewController:viewPicDetail animated:YES];
}

- (void)showComment:(UIButton*)sender {
    Feed *feed = [self feedFromPicID:sender.tag];
    Picture *pic = [self picFromPicID:sender.tag];
    
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"MainStoryboard"
                                                             bundle:nil];
    LXPicCommentViewController *viewPicComment = [mainStoryboard instantiateViewControllerWithIdentifier:@"PictureComment"];
    [viewPicComment setPic:pic withUser:feed.user withParent:self];
    [self.navigationController pushViewController:viewPicComment animated:YES];
}

- (void)showUser:(UIButton*)sender {
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"MainStoryboard"
                                                             bundle:nil];
    LXUserPageViewController *viewUserPage = [mainStoryboard instantiateViewControllerWithIdentifier:@"UserPage"];
    [viewUserPage setUserID:sender.tag];
    [self.navigationController pushViewController:viewUserPage animated:YES];

}

- (void)showMap:(UIButton*)sender {
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"MainStoryboard"
                                                             bundle:nil];
    LXPicMapViewController *viewPicMap = [mainStoryboard instantiateViewControllerWithIdentifier:@"PictureMap"];
    
    Feed *feed = [self feedFromPicID:sender.tag];
    Picture *pic = feed.targets[0];
    [viewPicMap setPointWithLongitude:[pic.longitude floatValue] andLatitude:[pic.latitude floatValue]];
    
    [self.navigationController pushViewController:viewPicMap animated:YES];
}

- (void)updatePhotoVoteCount:(UIButton*)sender increase:(BOOL)increase {
    sender.enabled = increase;
    Feed *feed = [self feedFromPicID:sender.tag];
    Picture *pic = [self picFromPicID:sender.tag];
    pic.isVoted = increase;
    if (feed.targets.count > 1) {
        NSInteger likeCount = [sender.titleLabel.text integerValue];
        NSNumber *num = [NSNumber numberWithInteger:likeCount + increase?1:-1];
        [sender setTitle:[num stringValue] forState:UIControlStateDisabled];
    } else {
        pic.voteCount = [NSNumber numberWithInteger:[pic.voteCount integerValue] + increase?1:-1];
        
        long row = [feeds indexOfObject:feed];
        
        NSArray *rowIndexes = [NSArray arrayWithObject:[NSIndexPath indexPathForRow:row inSection:0]];
        [self.tableView reloadRowsAtIndexPaths:rowIndexes
                              withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

- (void)submitLike:(UIButton*)sender {
    [self updatePhotoVoteCount:sender increase:true];
    
    LXAppDelegate* app = (LXAppDelegate*)[UIApplication sharedApplication].delegate;
    NSDictionary *param = [NSDictionary dictionaryWithObjectsAndKeys:
                           [app getToken], @"token",
                           @"1", @"vote_type",
                           nil];
    
    NSString *url = [NSString stringWithFormat:@"picture/%d/vote_post", sender.tag];
    [[LatteAPIClient sharedClient] postPath:url
                                 parameters:param
                                    success:^(AFHTTPRequestOperation *operation, NSDictionary *JSON) {
                                        TFLog(@"Submited like");
                                    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                        [self updatePhotoVoteCount:sender increase:false];
                                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"error", "Error")
                                                                                        message:error.localizedDescription
                                                                                       delegate:nil
                                                                              cancelButtonTitle:NSLocalizedString(@"close", "Close")
                                                                              otherButtonTitles:nil];
                                        [alert show];
                                        TFLog(@"Something went wrong (Vote)");
                                    }];
}

- (void)toggleComment:(UIButton*)sender {
    Feed *feed = [self feedFromPicID:sender.tag];
    
    NSString *key = [NSString stringWithFormat:@"%d", [feed.feedID integerValue]];
    NSNumber *check = [NSNumber numberWithBool:TRUE];
    if ([toggleSection objectForKey:key] == nil) {
        [toggleSection setObject:check forKey:key];
        
        NSInteger row = [feeds indexOfObject:feed];
        NSIndexPath *path = [NSIndexPath indexPathForRow:row inSection:0];
        CGRect rect = [self.tableView rectForRowAtIndexPath:path];
        Picture *pic = feed.targets[0];
        NSInteger picHeight = [LXUtils heightFromWidth:30.0 width:[pic.width floatValue] height:[pic.height floatValue]];
        rect.origin.y += 85.0 + picHeight + 200;
        [self.tableView setContentOffset:rect.origin animated:YES];
    } else {
        [toggleSection removeObjectForKey:key];
    }
    
    NSInteger row = [feeds indexOfObject:feed];
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:row inSection:0]]
                          withRowAnimation:UITableViewRowAnimationAutomatic];
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
        case kTableTimeline:
            if (endedTimeline)
                return;
            break;
        case kTableFriends:
            return;
            break;
        case kTableFollowings:
            return;
            break;
        case kTableVoted:
            if (endedVoted)
                return;
            break;
        case kTablePicList:
            if (endedPic)
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
                case kTableTimeline:
                    [self loadMore];
                    break;
                case kTablePicList:
                    [self loadMorePicList];
                    break;
                case kTableVoted:
                    [self loadMoreVotes];
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

- (void)submitComment:(Picture *)pic {
    long row = [feeds indexOfObject:[self feedFromPicID:[pic.pictureId longValue]]];
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:row inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
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


- (void)viewDidUnload {
    [self setLabelTitleVote:nil];
    [self setLabelTitlePicCount:nil];
    [self setLabelTitleFriends:nil];
    [self setLabelTitleFav:nil];
    [super viewDidUnload];
}
@end
