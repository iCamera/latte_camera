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
#import "SSCollectionView.h"
#import "SCImageCollectionViewItem.h"
#import "luxeysPicDetailViewController.h"
#import "luxeysTableViewCellPicture.h"
#import "luxeysCellFriend.h"
#import "luxeysImageUtils.h"
#import <luxeysSettingViewController.h>

@interface luxeysMypageViewController ()

@end

@implementation luxeysMypageViewController
@synthesize tableTimeline;
@synthesize tableFriend;
@synthesize buttonVoteCount;
@synthesize buttonPicCount;
@synthesize buttonFriendCount;
@synthesize buttonPhoto;
@synthesize buttonCalendar;
@synthesize viewScroll;
@synthesize imageProfilePic;
@synthesize viewStats;
@synthesize buttonNavRight;
@synthesize arPhoto;
@synthesize arFeed;
@synthesize arFriend;
@synthesize collectionView = _collectionView;

NSInteger tablemode = 1;

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
    
    // Do any additional setup after loading the view.
    //[viewStats removeFromSuperview];
    //tableTimeline.frame = CGRectMake(0, 0, tableTimeline.frame.size.width, tableTimeline.frame.size.height);
    
    luxeysAppDelegate* app = (luxeysAppDelegate*)[UIApplication sharedApplication].delegate;
    
    [buttonFriendCount setTitle:[[app.currentUser objectForKey:@"count_friends"] stringValue] forState:UIControlStateNormal];
    [buttonVoteCount setTitle:[[app.currentUser objectForKey:@"vote_count"] stringValue] forState:UIControlStateNormal];
    [buttonPicCount setTitle:[[app.currentUser objectForKey:@"count_pictures"] stringValue] forState:UIControlStateNormal];
    
    [self.imageProfilePic setImageWithURL:[NSURL URLWithString:[app.currentUser objectForKey:@"profile_picture"]]];
    self.viewStats.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg_sub_back.png"]];
    [self.navigationItem setTitle:[app.currentUser objectForKey:@"name"]];
    
    //Init sidebar
    UIPanGestureRecognizer *navigationBarPanGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:app.storyMain action:@selector(revealGesture:)];
    [self.navigationController.navigationBar addGestureRecognizer:navigationBarPanGestureRecognizer];
    [self.buttonNavRight addTarget:app.storyMain action:@selector(revealRight:) forControlEvents:UIControlEventTouchUpInside];
    
    //Timeline
    //UITableView *tableTimeline = [[UITableView alloc] initWithFrame:CGRectMake(0, 110, 320, 500) style:UITableViewStylePlain];
    UIBezierPath *shadowPath2 = [UIBezierPath bezierPathWithRect:tableTimeline.bounds];
    tableTimeline.layer.masksToBounds = NO;
    tableTimeline.layer.shadowColor = [UIColor blackColor].CGColor;
    tableTimeline.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
    tableTimeline.layer.shadowOpacity = 0.5f;
    tableTimeline.layer.shadowRadius = 2.0f;
    tableTimeline.layer.shadowPath = shadowPath2.CGPath;
    
    [[luxeysLatteAPIClient sharedClient] getPath:@"api/user/me/timeline"
                                      parameters: [NSDictionary dictionaryWithObjectsAndKeys:[app getToken], @"token", nil]
                                         success:^(AFHTTPRequestOperation *operation, NSDictionary *JSON) {
                                             arFeed = [[NSMutableArray alloc] init];
                                             for (NSDictionary *dictFeed in [JSON objectForKey:@"feeds"]) {
                                                 if ([[dictFeed objectForKey:@"target_model"] integerValue] == 1) {
                                                     [arFeed addObjectsFromArray:[dictFeed objectForKey:@"target_data"]];
                                                 }
                                             }
                                             [tableTimeline reloadData];
                                             CGRect frameTime = tableTimeline.frame;
                                             frameTime.size = tableTimeline.contentSize;
                                             tableTimeline.frame = frameTime;
                                             viewScroll.contentSize = CGSizeMake(320, tableTimeline.contentSize.height + 100);
                                         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                             NSLog(@"Something went wrong (Timeline)");
                                         }];
    
    // Photo list
    _collectionView = [[SSCollectionView alloc] initWithFrame:tableTimeline.frame];
    _collectionView.extremitiesStyle = SSCollectionViewExtremitiesStyleScrolling;
    _collectionView.scrollView.scrollEnabled = FALSE;
    _collectionView.hidden = TRUE;
    _collectionView.rowSpacing = 5;
    _collectionView.minimumColumnSpacing = 2;
    
    _collectionView.dataSource = self;
    _collectionView.delegate = self;
    
    [viewScroll addSubview:_collectionView];

    UIBezierPath *shadowPath3 = [UIBezierPath bezierPathWithRect:_collectionView.bounds];
    _collectionView.layer.masksToBounds = NO;
    _collectionView.layer.shadowColor = [UIColor blackColor].CGColor;
    _collectionView.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
    _collectionView.layer.shadowOpacity = 0.5f;
    _collectionView.layer.shadowRadius = 2.0f;
    _collectionView.layer.shadowPath = shadowPath3.CGPath;
    
    [[luxeysLatteAPIClient sharedClient] getPath:@"api/picture/user/me"
                                      parameters: [NSDictionary dictionaryWithObjectsAndKeys:[app getToken], @"token", nil]
                                         success:^(AFHTTPRequestOperation *operation, NSDictionary *JSON) {
                                             arPhoto = [JSON objectForKey:@"pictures"];
                                             [_collectionView reloadData];
                                             CGRect frameTime = tableTimeline.frame;
                                             frameTime.size = _collectionView.scrollView.contentSize;
                                             _collectionView.frame = frameTime;

                                         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                            NSLog(@"Something went wrong (Photolist)");
                                         }];

    [[luxeysLatteAPIClient sharedClient] getPath:@"api/user/me/friend"
                                      parameters: [NSDictionary dictionaryWithObjectsAndKeys:[app getToken], @"token", nil]
                                         success:^(AFHTTPRequestOperation *operation, NSDictionary *JSON) {
                                             arFriend = [JSON objectForKey:@"friends"];
                                             [tableFriend reloadData];
                                             CGRect frameTime = tableTimeline.frame;
                                             frameTime.size = tableFriend.contentSize;
                                             tableFriend.frame = frameTime;

                                         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                            NSLog(@"Something went wrong (Friendlist)");
                                         }];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == tableTimeline)
        return [arFeed count];
    else
        return [arFriend count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == tableTimeline)
    {
        NSDictionary *picInfo = [arFeed objectAtIndex:indexPath.row];
        float newheight = [luxeysImageUtils heightFromWidth:300
                                                      width:[[picInfo objectForKey:@"width"] floatValue]
                                                     height:[[picInfo objectForKey:@"height"] floatValue]];
        return newheight + 100;
    } else
    return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == tableTimeline)
    {
        luxeysTableViewCellPicture* cellSingle = [tableView dequeueReusableCellWithIdentifier:@"Picture"];
        if (nil == cellSingle) {
            cellSingle = [[luxeysTableViewCellPicture alloc] initWithStyle:UITableViewCellStyleDefault
                                                                     reuseIdentifier:@"Picture"];
        }
        
        [cellSingle setPicture:[arFeed objectAtIndex:indexPath.row]];
        return cellSingle;
    }
    else {
        luxeysCellFriend* cellFriend = [tableView dequeueReusableCellWithIdentifier:@"Friend"];
        if (nil == cellFriend) {
            cellFriend = [[luxeysCellFriend alloc] initWithStyle:UITableViewCellStyleDefault
                                                                     reuseIdentifier:@"Friend"];
        }
        [cellFriend setUser:[arFriend objectAtIndex:indexPath.row]];
        return cellFriend;
    }
}

- (void)switchPhotolist {
    //Photo list
    buttonPhoto.enabled = NO;
    buttonCalendar.enabled = YES;
    buttonFriendCount.enabled = TRUE;
    _collectionView.hidden = FALSE;
    tableTimeline.hidden = TRUE;
    tableFriend.hidden = TRUE;
    viewScroll.contentSize = CGSizeMake(320, _collectionView.scrollView.contentSize.height + 100);
}

- (void)switchTimeline {
    buttonCalendar.enabled = YES;
    buttonPhoto.enabled = YES;
    buttonFriendCount.enabled = TRUE;
    tableTimeline.hidden = FALSE;
    _collectionView.hidden = TRUE;
    tableFriend.hidden = TRUE;
    viewScroll.contentSize = CGSizeMake(320, tableTimeline.contentSize.height + 100);
}

- (void)switchCalendar {
    buttonCalendar.enabled = NO;
    buttonPhoto.enabled = YES;
    buttonFriendCount.enabled = TRUE;
    tableTimeline.hidden = TRUE;
    _collectionView.hidden = TRUE;
    tableFriend.hidden = TRUE;
}

- (void)switchFriendlist {
    buttonCalendar.enabled = YES;
    buttonPhoto.enabled = YES;
    buttonFriendCount.enabled = FALSE;
    tableTimeline.hidden = TRUE;
    _collectionView.hidden = TRUE;
    tableFriend.hidden = FALSE;
    viewScroll.contentSize = CGSizeMake(320, tableFriend.contentSize.height + 100);
}

- (void)viewDidUnload
{
    [self setImageProfilePic:nil];
    [self setViewStats:nil];
    [self setButtonNavRight:nil];
    [self setButtonPhoto:nil];
    [self setButtonCalendar:nil];
    [self setTableTimeline:nil];
    [self setViewScroll:nil];
    [self setButtonVoteCount:nil];
    [self setButtonPicCount:nil];
    [self setButtonFriendCount:nil];
    [self setTableFriend:nil];
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
        case 1:
            [self switchPhotolist];
            break;
        case 2:
            [self switchCalendar];
            break;
    }
}

- (IBAction)touchSetting:(id)sender {
    luxeysSettingViewController* viewSetting = [[luxeysSettingViewController alloc] init];
    
    [self.navigationController pushViewController:viewSetting animated:YES];
}

- (NSUInteger)collectionView:(SSCollectionView *)aCollectionView numberOfItemsInSection:(NSUInteger)section {
    return [arPhoto count];
}


- (SSCollectionViewItem *)collectionView:(SSCollectionView *)aCollectionView itemForIndexPath:(NSIndexPath *)indexPath {
    static NSString *const itemIdentifier = @"itemIdentifier";
    
    SCImageCollectionViewItem *item = (SCImageCollectionViewItem *)[aCollectionView dequeueReusableItemWithIdentifier:itemIdentifier];
    if (item == nil) {
        item = [[SCImageCollectionViewItem alloc] initWithReuseIdentifier:itemIdentifier];
    }
    

    NSDictionary* pic = [arPhoto objectAtIndex:indexPath.row];
    item.imageURL = [NSURL URLWithString:[pic objectForKey:@"url_square"]];
    
    return item;
}

- (CGSize)collectionView:(SSCollectionView *)aCollectionView itemSizeForSection:(NSUInteger)section {
    return CGSizeMake(73.0f, 73.0f);
}

- (void)collectionView:(SSCollectionView *)aCollectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [self performSegueWithIdentifier:@"PictureDetail" sender:[arPhoto objectAtIndex:indexPath.row]];
}

- (UIView *)collectionView:(SSCollectionView *)aCollectionView viewForHeaderInSection:(NSUInteger)section {
    return [[UIView alloc] init];
}

- (CGFloat)collectionView:(SSCollectionView *)aCollectionView heightForHeaderInSection:(NSUInteger)section {
    return 5;
}

- (void)showTimeline:(NSNotification *) notification {
    [self switchTimeline];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"PictureDetail"]) {
        luxeysPicDetailViewController* viewPicDetail = segue.destinationViewController;
        viewPicDetail.picInfo = sender;
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
@end
