//
//  LXLeftSideUserViewController.m
//  Latte camera
//
//  Created by Bui Xuan Dung on 3/22/13.
//  Copyright (c) 2013 LUXEYS. All rights reserved.
//

#import "LXLeftSideUserViewController.h"
#import "LXAppDelegate.h"
#import "UIImageView+loadProgress.h"
#import "UIButton+AsyncImage.h"
#import <FacebookSDK/FacebookSDK.h>

@interface LXLeftSideUserViewController ()

@end

@implementation LXLeftSideUserViewController {
    LXShare *lxShare;
    NSString *adsURL;
}

@synthesize labelUsername;
@synthesize imageProfilepic;
@synthesize viewBanner;
@synthesize buttonBanner;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    LXAppDelegate *app = [LXAppDelegate currentDelegate];
    labelUsername.text = app.currentUser.name;
    
    if (app.currentUser.profilePicture) {
        [imageProfilepic loadProgess:app.currentUser.profilePicture];
    }
    
    imageProfilepic.layer.cornerRadius = 5.0;
    imageProfilepic.layer.masksToBounds = YES;
    
    [self loadAds];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(becomeActive:)
                                                 name:@"BecomeActive" object:nil];
    
}

- (void)becomeActive:(id)sender {
    [self loadAds];
}


- (void)loadAds {
    LatteAPIClient *api = [LatteAPIClient sharedClient];
    NSString * language = [[NSLocale preferredLanguages] objectAtIndex:0];
    NSDictionary *params = [NSDictionary dictionaryWithObject:language forKey:@"language"];
    [api GET:@"user/ads"
      parameters:params
         success:^(AFHTTPRequestOperation *operation, NSDictionary *JSON) {
             [buttonBanner loadBackground:JSON[@"image"]];
             adsURL = JSON[@"url"];
         } failure:nil];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 32;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 28;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 27)];
    UIImageView *background = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 27)];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(6, 0, 320, 27)];
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:14];
    label.backgroundColor = [UIColor clearColor];
    label.text = [self tableView:tableView titleForHeaderInSection:section];
    background.image = [UIImage imageNamed:@"side_menu_bg1.png"];
    [view addSubview:background];
    [view addSubview:label];
    return view;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    LXAppDelegate *app = [LXAppDelegate currentDelegate];
//    [app.controllerSide showCenterPanelAnimated:YES];
    switch (indexPath.row) {
        case 0:
            app.viewMainTab.selectedIndex = 4;
            break;
        case 1: {
            app.viewMainTab.selectedIndex = 4;
            UINavigationController *nav = (UINavigationController*)app.viewMainTab.selectedViewController;
            UIStoryboard* storyMain = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
            [nav pushViewController:[storyMain instantiateViewControllerWithIdentifier:@"Liked"] animated:YES];
            break;
        }
        case 2:
            [app.viewMainTab showSetting:nil];
            break;
        case 3: {
            lxShare = [[LXShare alloc] init];
            lxShare.controller = self;
            [lxShare inviteFriend];
            break;
        }
        case 4:
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://luxeys.co.jp/recruits/"]];
            break;
        case 5: {
            [[FBSession activeSession] closeAndClearTokenInformation];
            
            LXAppDelegate* app = (LXAppDelegate*)[UIApplication sharedApplication].delegate;
            
            [app setToken:@""];
            app.currentUser = nil;
            [[NSNotificationCenter defaultCenter] postNotificationName:@"LoggedOut" object:self];
            [[LatteAPIClient sharedClient] POST:@"user/logout" parameters:nil success:nil failure:nil];
            
            break;
        }
        default:
            break;
    }
}

- (IBAction)touchBanner:(id)sender {
    NSString * language = [[NSLocale preferredLanguages] objectAtIndex:0];
    if ([language isEqualToString:@"ja"]) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://latte.la/picture/contest/2013may"]];
    } else {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://en.latte.la/picture/contest/2013may"]];
    }
}

- (void)viewDidUnload {
    [self setButtonBanner:nil];
    [super viewDidUnload];
}
@end
