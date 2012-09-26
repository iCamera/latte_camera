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

@interface luxeysMypageViewController () {
    int tableMode;
    NSMutableArray *feeds;
    NSArray *pictures;
    NSArray *friends;
}

@end

@implementation luxeysMypageViewController
@synthesize buttonVoteCount;
@synthesize buttonPicCount;
@synthesize buttonFriendCount;
@synthesize buttonPhoto;
@synthesize buttonCalendar;
@synthesize imageProfilePic;
@synthesize viewStats;
@synthesize buttonNavRight;

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
    
    luxeysAppDelegate* app = (luxeysAppDelegate*)[UIApplication sharedApplication].delegate;
    
    [buttonFriendCount setTitle:[[app.currentUser objectForKey:@"count_friends"] stringValue] forState:UIControlStateNormal];
    [buttonVoteCount setTitle:[[app.currentUser objectForKey:@"vote_count"] stringValue] forState:UIControlStateNormal];
    [buttonPicCount setTitle:[[app.currentUser objectForKey:@"count_pictures"] stringValue] forState:UIControlStateNormal];
    
    [imageProfilePic setImageWithURL:[NSURL URLWithString:[app.currentUser objectForKey:@"profile_picture"]]];
//    self.tableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg_sub_back.png"]];
    self.viewStats.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg_sub_back.png"]];
    self.tableView.backgroundColor = [UIColor whiteColor];
    
    [self.navigationItem setTitle:[app.currentUser objectForKey:@"name"]];
    
    //Init sidebar
    UIPanGestureRecognizer *navigationBarPanGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:app.storyMain action:@selector(revealGesture:)];
    [self.navigationController.navigationBar addGestureRecognizer:navigationBarPanGestureRecognizer];
    [buttonNavRight addTarget:app.storyMain action:@selector(revealRight:) forControlEvents:UIControlEventTouchUpInside];
    
    [[luxeysLatteAPIClient sharedClient] getPath:@"api/user/me/timeline"
                                      parameters: [NSDictionary dictionaryWithObjectsAndKeys:[app getToken], @"token", nil]
                                         success:^(AFHTTPRequestOperation *operation, NSDictionary *JSON) {
                                             feeds = [[NSMutableArray alloc] init];
                                             feeds = [NSMutableArray arrayWithArray:[JSON objectForKey:@"feeds"]];
                                             [self.tableView reloadData];
                                         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                             NSLog(@"Something went wrong (Timeline)");
                                         }];
    
    
    [[luxeysLatteAPIClient sharedClient] getPath:@"api/picture/user/me"
                                      parameters: [NSDictionary dictionaryWithObjectsAndKeys:[app getToken], @"token", nil]
                                         success:^(AFHTTPRequestOperation *operation, NSDictionary *JSON) {
                                             pictures = [JSON objectForKey:@"pictures"];
                                             
                                         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                             NSLog(@"Something went wrong (Photolist)");
                                         }];
    
    [[luxeysLatteAPIClient sharedClient] getPath:@"api/user/me/friend"
                                      parameters: [NSDictionary dictionaryWithObjectsAndKeys:[app getToken], @"token", nil]
                                         success:^(AFHTTPRequestOperation *operation, NSDictionary *JSON) {
                                             friends = [JSON objectForKey:@"friends"];
                                             
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
            return commentCount>3?3:commentCount;
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
        return 35;
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
            float newheight = [luxeysImageUtils heightFromWidth:300
                                                          width:[[pic objectForKey:@"width"] floatValue]
                                                         height:[[pic objectForKey:@"height"] floatValue]];
            return newheight + 100;
        }
        else {
            return 250;
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
        
        cellComment.backgroundView = [[UIView alloc] initWithFrame:cellComment.bounds];
//        cellComment.backgroundView.backgroundColor = [UIColor whiteColor];
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

- (void)switchPhotolist {
    tableMode = 2;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView reloadData];
    buttonPhoto.enabled = NO;
    buttonCalendar.enabled = YES;
    buttonFriendCount.enabled = TRUE;
}

- (void)switchTimeline {
    tableMode = 1;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    [self.tableView reloadData];
    buttonCalendar.enabled = YES;
    buttonPhoto.enabled = YES;
    buttonFriendCount.enabled = TRUE;
}

- (void)switchCalendar {
    tableMode = 3;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView reloadData];
    buttonCalendar.enabled = NO;
    buttonPhoto.enabled = YES;
    buttonFriendCount.enabled = TRUE;
}

- (void)switchFriendlist {
    tableMode = 4;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView reloadData];
    buttonCalendar.enabled = YES;
    buttonPhoto.enabled = YES;
    buttonFriendCount.enabled = FALSE;
}

- (void)viewDidUnload
{
    [self setImageProfilePic:nil];
    [self setViewStats:nil];
    [self setButtonNavRight:nil];
    [self setButtonPhoto:nil];
    [self setButtonCalendar:nil];
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

- (IBAction)touchTab:(UIButton *)sender {
    sender.enabled = NO;
    switch (sender.tag) {
        case 2:
            [self switchPhotolist];
            break;
        case 3:
            [self switchCalendar];
            break;
    }
}

- (IBAction)touchSetting:(id)sender {
    luxeysSettingViewController* viewSetting = [[luxeysSettingViewController alloc] init];
    
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
        [viewInfo setPicture:[feeds objectAtIndex:tmp.tag]];
    }
    else if ([segue.identifier isEqualToString:@"Comment"]) {
        
    } else if ([segue.identifier isEqualToString:@"UserProfile"]) {
        luxeysUserViewController *viewUser = segue.destinationViewController;
        viewUser.dictUser = sender;
    }
}

- (IBAction)touchVoteCount:(id)sender {
}

- (IBAction)touchPicCount:(id)sender {
    [self switchPhotolist];
}

- (IBAction)touchFriendCount:(id)sender {
    [self switchFriendlist];
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
    [self performSegueWithIdentifier:@"PictureDetail" sender:pic];
//    [self performSegueWithIdentifier:@"Comment" sender:self];
}

- (void)showUser:(UIButton*)sender {
    NSDictionary *feed = [feeds objectAtIndex:sender.tag];
    NSDictionary *user = [feed objectForKey:@"user"];
    [self performSegueWithIdentifier:@"UserProfile" sender:user];
}

- (void)submitLike:(UIButton*)sender {
    NSLog(@"Submit like");
}


@end
