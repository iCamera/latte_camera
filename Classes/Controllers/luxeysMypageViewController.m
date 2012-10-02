//
//  luxeysMypageViewController.m
//  Latte
//
//  Created by Xuan Dung Bui on 8/22/12.
//  Copyright (c) 2012 LUXEYS. All rights reserved.
//

#import "luxeysMypageViewController.h"
#import "luxeysAppDelegate.h"
#import "luxeysLatteAPIClient.h"
#import "UIImageView+AFNetworking.h"
#import "luxeysPicDetailViewController.h"
#import "luxeysCellPicture.h"
#import "luxeysCellFriend.h"
#import "luxeysImageUtils.h"
#import "luxeysCellComment.h"
#import "UIButton+AsyncImage.h"
#import <luxeysSettingViewController.h>
#import "luxeysPicInfoViewController.h"
#import "luxeysUserViewController.h"
#import "luxeysTemplatePicTimeline.h"
#import "luxeysTemplateTimelinePicMulti.h"
#import "luxeysPicCommentViewController.h"
#import "LuxeysFeed.h"

@interface luxeysMypageViewController () {
    int tableMode;
    int lastFeedID;
    NSMutableArray *feeds;
    NSArray *pictures;
    NSArray *friends;
    NSMutableDictionary *toggleSection;
    NSArray *allTab;
    BOOL reloading;
    NSMutableArray *lxFeeds;
    EGORefreshTableHeaderView *refreshHeaderView;
}

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
    tableMode = 1;
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

- (void)reloadView {
    luxeysAppDelegate* app = (luxeysAppDelegate*)[UIApplication sharedApplication].delegate;
    
    [[luxeysLatteAPIClient sharedClient] getPath:@"api/user/me"
                                      parameters: [NSDictionary dictionaryWithObjectsAndKeys:[app getToken], @"token", nil]
                                         success:^(AFHTTPRequestOperation *operation, NSDictionary *JSON) {
                                             NSDictionary *dictUser = [JSON objectForKey:@"user"];
                                             LuxeysUser *user = [LuxeysUser instanceFromDictionary:dictUser];
                                             app.currentUser = dictUser;
                                             
                                             [imageProfilePic setImageWithURL:[NSURL URLWithString:user.profilePicture]];
                                             
                                             labelNickname.text = user.name;
                                             [buttonFriendCount setTitle:[user.countFriends stringValue] forState:UIControlStateNormal];
                                             [buttonVoteCount setTitle:[user.voteCount stringValue] forState:UIControlStateNormal];
                                             [buttonPicCount setTitle:[user.countPictures stringValue] forState:UIControlStateNormal];
                                             [buttonFollowCount setTitle:[user.countFollows stringValue] forState:UIControlStateNormal];
                                             
                                         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                             NSLog(@"Something went wrong (Photolist)");
                                         }];
    
    
    [[luxeysLatteAPIClient sharedClient] getPath:@"api/user/me/timeline"
                                      parameters: [NSDictionary dictionaryWithObjectsAndKeys:[app getToken], @"token", nil]
                                         success:^(AFHTTPRequestOperation *operation, NSDictionary *JSON) {
                                             feeds = [NSMutableArray arrayWithArray:[JSON objectForKey:@"feeds"]];
                                             NSDictionary *feed = feeds.lastObject;
                                             lastFeedID = [[feed objectForKey:@"id"] integerValue];
                                             if (tableMode == 1) {
                                                 [self.tableView reloadData];
                                                 [self doneLoadingTableViewData];
                                             }
                                             
                                         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                             NSLog(@"Something went wrong (Timeline)");
                                         }];
    
    
    [[luxeysLatteAPIClient sharedClient] getPath:@"api/picture/user/me"
                                      parameters: [NSDictionary dictionaryWithObjectsAndKeys:[app getToken], @"token", nil]
                                         success:^(AFHTTPRequestOperation *operation, NSDictionary *JSON) {
                                             pictures = [JSON objectForKey:@"pictures"];
                                             if (tableMode == 2) {
                                                 [self.tableView reloadData];
                                                 [self doneLoadingTableViewData];
                                             }
                                             
                                         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                             NSLog(@"Something went wrong (Photolist)");
                                         }];
    
    [[luxeysLatteAPIClient sharedClient] getPath:@"api/user/me/friend"
                                      parameters: [NSDictionary dictionaryWithObjectsAndKeys:[app getToken], @"token", nil]
                                         success:^(AFHTTPRequestOperation *operation, NSDictionary *JSON) {
                                             friends = [JSON objectForKey:@"friends"];
                                             if (tableMode == 3) {
                                                 [self.tableView reloadData];
                                                 [self doneLoadingTableViewData];
                                             }
                                             
                                         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                             NSLog(@"Something went wrong (Friendlist)");
                                         }];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (tableMode == 1) {
        return feeds.count;
    } else
        return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableMode == 1) {
        NSDictionary *feed = [feeds objectAtIndex:section];
        NSArray *targets = [feed objectForKey:@"targets"];
        if (targets.count == 1) {
            NSDictionary *pic = [targets objectAtIndex:0];
            NSInteger commentCount = [[pic objectForKey:@"comment_count"] integerValue];
            
            NSString *key = [NSString stringWithFormat:@"%d", section];
            if ([toggleSection objectForKey:key] == nil)
                return commentCount>3?3:commentCount;
            else
                return commentCount;
        } else
            return 0;
        
    }
    else if (tableMode == 2) {
        return (pictures.count/4) + (pictures.count%4>0?1:0);
    }
    else
        return friends.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableMode == 1)
    {
        NSDictionary *feed = [feeds objectAtIndex:indexPath.section];
        NSArray *targets = [feed objectForKey:@"targets"];
        NSDictionary *pic = [targets objectAtIndex:0];
        NSArray *comments = [pic objectForKey:@"comments"];
        NSDictionary *comment = [comments objectAtIndex:indexPath.row];
        
        NSString *strComment = [comment objectForKey:@"description"];
        CGSize labelSize = [strComment sizeWithFont:[UIFont systemFontOfSize:11]
                                  constrainedToSize:CGSizeMake(255.0f, MAXFLOAT)
                                      lineBreakMode:NSLineBreakByWordWrapping];
        return labelSize.height + 25;
    } else if (tableMode == 2) {
        return 78;
    }
    else
        return 50;
}

- (UIView *)createComment:(NSDictionary *)comment {
    NSDictionary *user = [comment objectForKey:@"user"];
    UIView *view = [[UIView alloc] init];
    UIButton *picUser = [[UIButton alloc] initWithFrame:CGRectMake(5, 5, 25, 25)];
    UILabel *labelUser = [[UILabel alloc] initWithFrame:CGRectMake(35, 5, 200, 20)];
    UILabel *labelComment = [[UILabel alloc] initWithFrame:CGRectMake(35, 25, 200, 20)];
    
    labelComment.text = [comment objectForKey:@"description"];
    labelUser.text = [user objectForKey:@"name"];
    [picUser loadBackground:[user objectForKey:@"profile_picture"]];
    
    [view addSubview:picUser];
    [view addSubview:labelUser];
    [view addSubview:labelComment];
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (tableMode == 1) {
        NSDictionary *feed = [feeds objectAtIndex:section];
        NSArray *targets = [feed objectForKey:@"targets"];
        if (targets.count == 1) {
            NSDictionary *pic = [targets objectAtIndex:0];
            NSArray *comments = [pic objectForKey:@"comments"];
            float newheight = [luxeysImageUtils heightFromWidth:300
                                                          width:[[pic objectForKey:@"width"] floatValue]
                                                         height:[[pic objectForKey:@"height"] floatValue]];
            if (comments.count > 3)
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
    if (tableMode == 1) {
        NSDictionary *feed = [feeds objectAtIndex:section];
        NSDictionary *user = [feed objectForKey:@"user"];
        NSArray *targets = [feed objectForKey:@"targets"];
        
        if (targets.count == 1) {
            NSDictionary *pic = [targets objectAtIndex:0];
            luxeysTemplatePicTimeline *viewPic = [[luxeysTemplatePicTimeline alloc] initWithPic:pic user:user section:section sender:self];
            return viewPic.view;
        }
        else {
            luxeysTemplateTimelinePicMulti *viewMultiPic = [[luxeysTemplateTimelinePicMulti alloc] initWithPics:targets user:user section:section sender:self];
            return viewMultiPic.view;
        }
    }
    else
        return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableMode == 1)
    {
        NSDictionary *feed = [feeds objectAtIndex:indexPath.section];
        NSArray *targets = [feed objectForKey:@"targets"];
        NSDictionary *pic = [targets objectAtIndex:0];
        NSArray *comments = [pic objectForKey:@"comments"];
        luxeysTableViewCellComment* cellComment = [tableView dequeueReusableCellWithIdentifier:@"Comment"];
        [cellComment setComment:[comments objectAtIndex:indexPath.row]];
        
        cellComment.backgroundView = [[UIView alloc] init];
        cellComment.backgroundView.backgroundColor = [UIColor colorWithRed:0.91f green:0.90f blue:0.88 alpha:1];
        cellComment.backgroundView.layer.cornerRadius = 5;
        cellComment.backgroundView.layer.masksToBounds = YES;
        cellComment.backgroundView.layer.borderWidth = 0.5f;
        cellComment.backgroundView.layer.borderColor = [[UIColor whiteColor] CGColor];
        
        return cellComment;
    }
    else if (tableMode == 2) {
        UITableViewCell *cellPic = [[UITableViewCell alloc] init];
        for (int i = 0; i < 4; ++i)
        {
            NSInteger index = indexPath.row*4+i;
            if (index < pictures.count) {
                NSDictionary *pic = [pictures objectAtIndex:index];
                
                UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(10+(i*77), 10, 67, 67)];
                [button loadBackground:[pic objectForKey:@"url_square"]];
                button.layer.borderColor = [[UIColor whiteColor] CGColor];
                button.layer.borderWidth = 3;
                
                UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:button.bounds];
                button.layer.masksToBounds = NO;
                button.layer.shadowColor = [UIColor blackColor].CGColor;
                button.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
                button.layer.shadowOpacity = 0.5f;
                button.layer.shadowRadius = 1.5f;
                button.layer.shadowPath = shadowPath.CGPath;
                
                button.tag = index;
                [button addTarget:self action:@selector(showDetail:) forControlEvents:UIControlEventTouchUpInside];
                [cellPic addSubview:button];
            }
        }
        cellPic.backgroundView = [[UIView alloc] initWithFrame:cellPic.bounds];
        //        cellPic.backgroundView.backgroundColor = [UIColor whiteColor];
        return cellPic;
    }
    else {
        luxeysCellFriend* cellFriend = [tableView dequeueReusableCellWithIdentifier:@"Friend"];
        [cellFriend setUser:[friends objectAtIndex:indexPath.row]];
        cellFriend.backgroundView = [[UIView alloc] initWithFrame:cellFriend.bounds];
        //        cellFriend.backgroundView.backgroundColor = [UIColor whiteColor];
        
        return cellFriend;
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

- (void)switchTimeline {
    tableMode = 1;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    [self.tableView reloadData];

}

- (IBAction)touchTab:(UIButton *)sender {
    for (UIButton *button in allTab) {
        button.enabled = YES;
    }
    
    sender.enabled = NO;
    switch (sender.tag) {
        case 1:
        case 2:
            tableMode = 2;
            self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
            [self.tableView reloadData];
            break;
        case 3:
        case 4:
            tableMode = 4;
            self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
            [self.tableView reloadData];
            break;
        case 5:
        case 6:
        case 7:
        case 8:
            [self switchTimeline];
            break;

            
    }
}

- (IBAction)touchSetting:(id)sender {
    QRootElement *root = [[QRootElement alloc] initWithJSONFile:@"lattesetting"];
    luxeysSettingViewController* viewSetting = [[luxeysSettingViewController alloc] initWithRoot:root];
    
    [self.navigationController pushViewController:viewSetting animated:YES];
}


- (void)showTimeline:(NSNotification *) notification {
    [self switchTimeline];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"PictureDetail"]) {
        luxeysPicDetailViewController* viewPicDetail = segue.destinationViewController;
        viewPicDetail.picInfo = sender;
    }
    else if ([segue.identifier isEqualToString:@"PictureInfo"]) {
        luxeysPicInfoViewController *viewInfo = segue.destinationViewController;
        UIButton *tmp = sender;
        NSDictionary *feed = [feeds objectAtIndex:tmp.tag];
        NSArray *targets = [feed objectForKey:@"targets"];
        NSDictionary *pic = [targets objectAtIndex:0];
        [viewInfo setPicture:pic];
    }
    else if ([segue.identifier isEqualToString:@"Comment"]) {
        luxeysPicCommentViewController *viewComment = segue.destinationViewController;
        [viewComment setPic:sender];
    } else if ([segue.identifier isEqualToString:@"UserProfile"]) {
        luxeysUserViewController *viewUser = segue.destinationViewController;
        viewUser.dictUser = sender;
    }
}

- (void)showInfo:(UIButton*)sender {
    [self performSegueWithIdentifier:@"PictureInfo" sender:sender];
}

- (void)showDetail:(UIButton*)sender {
    [self performSegueWithIdentifier:@"PictureDetail" sender:[pictures objectAtIndex:sender.tag]];
}

- (void)showComment:(UIButton*)sender {
    NSLog(@"Show comment");
    NSDictionary *feed = [feeds objectAtIndex:sender.tag];
    NSArray *targets = [feed objectForKey:@"targets"];
    NSDictionary *pic = [targets objectAtIndex:0];    
    [self performSegueWithIdentifier:@"Comment" sender:pic];
}

- (void)showUser:(UIButton*)sender {
    NSDictionary *feed = [feeds objectAtIndex:sender.tag];
    NSDictionary *user = [feed objectForKey:@"user"];
    [self performSegueWithIdentifier:@"UserProfile" sender:user];
}

- (void)submitLike:(UIButton*)sender {
    NSLog(@"Submit like");
}

- (void)showPicWithID:(UIButton*)sender {
    for (NSDictionary *feed in feeds) {
        for (NSDictionary *pic in [feed objectForKey:@"targets"]) {
            if ([[pic objectForKey:@"id"] integerValue] == sender.tag) {
                [self performSegueWithIdentifier:@"PictureDetail" sender:pic];
            }
        }
    }
}

- (void)toggleComment:(UIButton*)sender {
    NSInteger section = sender.tag;
    
    NSMutableArray *indexes = [[NSMutableArray alloc] init];
    NSDictionary *feed = [feeds objectAtIndex:section];
    NSArray *targets = [feed objectForKey:@"targets"];
    NSDictionary *pic = [targets objectAtIndex:0];
    NSArray *comments = [pic objectForKey:@"comments"];
    for (int i = 3; i < comments.count; i++) {
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


@end
