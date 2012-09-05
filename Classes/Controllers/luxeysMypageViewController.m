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
#import "luxeysImageUtils.h"
#import <luxeysSettingViewController.h>

@interface luxeysMypageViewController ()

@end

@implementation luxeysMypageViewController
@synthesize tableTimeline;
@synthesize labelPicNum;
@synthesize labelVote;
@synthesize labelFriend;
@synthesize buttonPhoto;
@synthesize buttonCalendar;
@synthesize imageProfilePic;
@synthesize viewStats;
@synthesize buttonNavRight;
@synthesize arPhoto;
@synthesize arFeed;
@synthesize collectionView = _collectionView;

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
    [viewStats removeFromSuperview];
    tableTimeline.frame = CGRectMake(0, 0, tableTimeline.frame.size.width, tableTimeline.frame.size.height);
    
    
    luxeysAppDelegate* app = (luxeysAppDelegate*)[UIApplication sharedApplication].delegate;
    
    labelFriend.text = [[app.currentUser objectForKey:@"count_friends"] stringValue];
    labelVote.text = [[app.currentUser objectForKey:@"vote_count"] stringValue];
    labelPicNum.text = [[app.currentUser objectForKey:@"count_pictures"] stringValue];
    
    [self.imageProfilePic setImageWithURL:[NSURL URLWithString:[app.currentUser objectForKey:@"profile_picture"]]];
    self.viewStats.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg_sub_back.png"]];
    [self.navigationItem setTitle:[app.currentUser objectForKey:@"name"]];
    
    //Init sidebar
    UIPanGestureRecognizer *navigationBarPanGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:app.storyMain action:@selector(revealGesture:)];
    [self.navigationController.navigationBar addGestureRecognizer:navigationBarPanGestureRecognizer];
    [self.buttonNavRight addTarget:app.storyMain action:@selector(revealRight:) forControlEvents:UIControlEventTouchUpInside];
    
    //Timeline
    //UITableView *tableTimeline = [[UITableView alloc] initWithFrame:CGRectMake(0, 110, 320, 500) style:UITableViewStylePlain];
    
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
                                         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                             NSLog(@"Something went wrong (Timeline)");
                                         }];
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [arFeed count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *picInfo = [arFeed objectAtIndex:indexPath.row];
    float newheight = [luxeysImageUtils heightFromWidth:300
                                                  width:[[picInfo objectForKey:@"width"] floatValue]
                                                 height:[[picInfo objectForKey:@"height"] floatValue]];
    NSLog(@"%f", newheight + 100);
    return newheight + 100;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    luxeysTableViewCellPicture* cellSingle = [tableView dequeueReusableCellWithIdentifier:@"Picture"];
    
    if (nil == cellSingle) {
        cellSingle = [[luxeysTableViewCellPicture alloc] initWithStyle:UITableViewCellStyleDefault
                                                                 reuseIdentifier:@"Picture"];
    }
    
    [cellSingle setPicture:[arFeed objectAtIndex:indexPath.row]];
    
    return cellSingle;
}

- (void)loadPhotolist {
    //Photo list
    luxeysAppDelegate* app = (luxeysAppDelegate*)[UIApplication sharedApplication].delegate;
    
    _collectionView = [[SSCollectionView alloc] initWithFrame:tableTimeline.frame];
    _collectionView.extremitiesStyle = SSCollectionViewExtremitiesStyleScrolling;
    _collectionView.rowSpacing = 5;
    _collectionView.minimumColumnSpacing = 2;
    
    _collectionView.dataSource = self;
    _collectionView.delegate = self;
    
    
    [[luxeysLatteAPIClient sharedClient] getPath:@"api/picture/user/me"
                                      parameters: [NSDictionary dictionaryWithObjectsAndKeys:[app getToken], @"token", nil]
                                         success:^(AFHTTPRequestOperation *operation, NSDictionary *JSON) {
                                             arPhoto = [JSON objectForKey:@"pictures"];
                                             
                                             [_collectionView reloadData];
                                         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                             UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                                             message:@"Something went wrong (Mypage)"
                                                                                            delegate:nil
                                                                                   cancelButtonTitle:@"OK"
                                                                                   otherButtonTitles:nil
                                                                   ];
                                             [alert show];
                                         }];
    [self.view addSubview:_collectionView];
}

- (void)viewDidUnload
{
    [self setImageProfilePic:nil];
    [self setViewStats:nil];
    [self setButtonNavRight:nil];
    [self setButtonPhoto:nil];
    [self setButtonCalendar:nil];
    [self setTableTimeline:nil];
    [self setLabelPicNum:nil];
    [self setLabelVote:nil];
    [self setLabelFriend:nil];
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
            buttonCalendar.enabled = YES;
            [tableTimeline removeFromSuperview];
            [self loadPhotolist];
            break;
        case 2:
            buttonPhoto.enabled = YES;
            [_collectionView removeFromSuperview];
            [self.view addSubview:tableTimeline];
            [tableTimeline reloadData];
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
    UIStoryboard *storyPicDetail = [UIStoryboard storyboardWithName:@"PictureStoryboard"
                                                             bundle:nil];
    luxeysPicDetailViewController* viewPicDetail = (luxeysPicDetailViewController*)[storyPicDetail instantiateInitialViewController];
    viewPicDetail.picInfo = [arPhoto objectAtIndex:indexPath.row];
    [self.navigationController pushViewController:viewPicDetail animated:YES];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat sectionHeaderHeight = viewStats.frame.size.height;
    if (scrollView.contentOffset.y<=sectionHeaderHeight&&scrollView.contentOffset.y>=0) {
        scrollView.contentInset = UIEdgeInsetsMake(-scrollView.contentOffset.y, 0, 0, 0);
    } else if (scrollView.contentOffset.y>=sectionHeaderHeight) {
        scrollView.contentInset = UIEdgeInsetsMake(-sectionHeaderHeight, 0, 0, 0);
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return viewStats;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return viewStats.frame.size.height;
}

- (CGFloat)collectionView:(SSCollectionView *)aCollectionView heightForHeaderInSection:(NSUInteger)section {
    return viewStats.frame.size.height;
}

- (UIView *)collectionView:(SSCollectionView *)aCollectionView viewForHeaderInSection:(NSUInteger)section {
    return viewStats;
}

- (void)showTimeline:(NSNotification *) notification {
    
}


@end
