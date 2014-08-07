//
//  LXMenuViewController.m
//  Latte camera
//
//  Created by Bui Xuan Dung on 5/21/14.
//  Copyright (c) 2014 LUXEYS. All rights reserved.
//

#import "LXMenuViewController.h"
#import "LXAppDelegate.h"
#import "REFrostedViewController.h"
#import "LXAppDelegate.h"
#import "MZFormSheetSegue.h"
#import "MBProgressHUD.h"
#import "LatteAPIClient.h"
#import "LatteAPIv2Client.h"
#import "LXUtils.h"
#import "User.h"

#import "LXShare.h"
#import "UIButton+AFNetworking.h"
#import "UIImageView+AFNetworking.h"

#import "LXUserPageViewController.h"
#import "LXPhotoGridCVC.h"

//#import "UIStoryboard.h"

@interface LXMenuViewController ()

@end

@implementation LXMenuViewController
@synthesize textUsername;
@synthesize menuFollowingTags;
@synthesize menuLikedPhotos;
@synthesize menuLogOut;
@synthesize menuSearch;
@synthesize menuLogin;
@synthesize menuSettings;
@synthesize menuFeedback;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated {

    LXAppDelegate *app = [LXAppDelegate currentDelegate];
    
    NSString *language = [[NSLocale preferredLanguages] objectAtIndex:0];

    if (![language isEqualToString:@"ja"]) {
        _menuBlog.hidden = YES;
    }

    

    if (app.currentUser) {
        [_buttonProfilePicture setBackgroundImageForState:UIControlStateNormal withURL:[NSURL URLWithString:app.currentUser.profilePicture]];
        textUsername.text = app.currentUser.name;
        menuFollowingTags.hidden =FALSE;
        menuLikedPhotos.hidden = FALSE;
        menuLogin.hidden = TRUE;
        menuLogOut.hidden = FALSE;
        _buttonProfilePicture.hidden = FALSE;
        textUsername.hidden = FALSE;

    } else {
        //Hide_show buttons
        menuFollowingTags.hidden = TRUE;
        menuLikedPhotos.hidden = TRUE;
        menuLogin.hidden = FALSE;
        menuLogOut.hidden = TRUE;
        _buttonProfilePicture.hidden = TRUE;
        textUsername.hidden = TRUE;
        textUsername.text = @"";
    }
     [self.tableView reloadData];
    
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    LXAppDelegate *app = [LXAppDelegate currentDelegate];
    [app.tracker set:kGAIScreenName
               value:@"Left Home Menu Screen"];
    [app.tracker send:[[GAIDictionaryBuilder createAppView] build]];
    _buttonProfilePicture.layer.cornerRadius = 50;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
 UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
 if (cell.hidden) {
     return 0;
 } else {
     return 44; //[super tableView:tableView heightForRowAtIndexPath:indexPath];
 }
}
         
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Setting
    [self.frostedViewController hideMenuViewController];
    LXAppDelegate *app = [LXAppDelegate currentDelegate];
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    UINavigationController *navCurrent = (UINavigationController*)app.viewMainTab.selectedViewController;
    UIStoryboard* storySetting = [UIStoryboard storyboardWithName:@"Setting" bundle:nil];
    
    if ([tableView cellForRowAtIndexPath:indexPath] == menuFollowingTags) {
        [navCurrent pushViewController:[mainStoryboard instantiateViewControllerWithIdentifier:@"FollowingTag"] animated:YES];
    } else if ([tableView cellForRowAtIndexPath:indexPath] ==  menuSettings) {
        
        [self presentViewController:[storySetting instantiateInitialViewController] animated:YES completion:nil];

    } else if ([tableView cellForRowAtIndexPath:indexPath] == menuLogOut) {
        [[FBSession activeSession] closeAndClearTokenInformation];
        [[LatteAPIClient sharedClient] POST:@"user/logout" parameters:nil success:nil failure:nil];
        [app setToken:@""];
        app.currentUser = nil;
        [self dismissViewControllerAnimated:YES completion:nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"LoggedOut" object:self];
    } else if ([tableView cellForRowAtIndexPath:indexPath] == menuSearch) {
        app.viewMainTab.selectedIndex = 3;
    } else if ([tableView cellForRowAtIndexPath:indexPath] == menuLikedPhotos) {
        LXPhotoGridCVC *viewLikedGrid = [mainStoryboard instantiateViewControllerWithIdentifier:@"PhotoGrid"];
        viewLikedGrid.gridType = kPhotoGridUserLiked;
        [navCurrent pushViewController:viewLikedGrid animated:YES];
    } else if ([tableView cellForRowAtIndexPath:indexPath] == menuLogin) {
        UIStoryboard* storyMain = [UIStoryboard storyboardWithName:@"Authentication" bundle:nil];
        [self presentViewController:[storyMain instantiateViewControllerWithIdentifier:@"LoginModal"] animated:YES completion:nil];
    } else if ([tableView cellForRowAtIndexPath:indexPath] == menuFeedback) {
        [navCurrent pushViewController:[storySetting instantiateViewControllerWithIdentifier:@"About"] animated:YES];
    } else if ([tableView cellForRowAtIndexPath:indexPath] == _menuBlog) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://latte.la/column/photo_camera"]];
    }
}

- (IBAction)clickShowUser:(id)sender {
    [self.frostedViewController hideMenuViewController];
    LXAppDelegate *app = [LXAppDelegate currentDelegate];
    UINavigationController *navCurrent = (UINavigationController*)app.viewMainTab.selectedViewController;
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"MainStoryboard"
                                                             bundle:nil];
    LXUserPageViewController *viewUserPage = [mainStoryboard instantiateViewControllerWithIdentifier:@"UserPage"];
    viewUserPage.user = app.currentUser;
    [navCurrent pushViewController:viewUserPage animated:YES];
}


@end
