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
    NSLog(@"VIEW viewWillAppear ");

    NSLog(@"  app.currentUser : %@  profile_picture: %@", app.currentUser, app.currentUser.profilePicture);
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
    _buttonProfilePicture.layer.cornerRadius = 37;
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
    if ([tableView cellForRowAtIndexPath:indexPath] == menuFollowingTags) {
       [self.frostedViewController hideMenuViewController];
        LXAppDelegate *app = [LXAppDelegate currentDelegate];
        app.viewMainTab.selectedIndex = 4;
        UINavigationController *navCurrent = (UINavigationController*)app.viewMainTab.selectedViewController;
        UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"MainStoryboard"                                                                bundle:nil];
        [navCurrent pushViewController:[mainStoryboard instantiateViewControllerWithIdentifier:@"TagHome"] animated:YES];
    } else if ([tableView cellForRowAtIndexPath:indexPath] ==  menuSettings) {
        [self.frostedViewController hideMenuViewController];
        UIStoryboard* storySetting = [UIStoryboard storyboardWithName:@"Setting" bundle:nil];
        [self presentViewController:[storySetting instantiateInitialViewController] animated:YES completion:nil];

    } else if ([tableView cellForRowAtIndexPath:indexPath] == menuLogOut) {
        [self.frostedViewController hideMenuViewController];
        LXAppDelegate *app = [LXAppDelegate currentDelegate];
        [[FBSession activeSession] closeAndClearTokenInformation];
        [[LatteAPIClient sharedClient] POST:@"user/logout" parameters:nil success:nil failure:nil];
        [app setToken:@""];
        app.currentUser = nil;
        [self dismissViewControllerAnimated:YES completion:nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"LoggedOut" object:self];
    } else if ([tableView cellForRowAtIndexPath:indexPath] == menuLikedPhotos) {
        [self.frostedViewController hideMenuViewController];
        LXAppDelegate *app = [LXAppDelegate currentDelegate];
        app.viewMainTab.selectedIndex = 4;
        UINavigationController *navCurrent = (UINavigationController*)app.viewMainTab.selectedViewController;
        UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"MainStoryboard"                                                                bundle:nil];
        [navCurrent pushViewController:[mainStoryboard instantiateViewControllerWithIdentifier:@"LikedPhotos"] animated:YES];

    } else if ([tableView cellForRowAtIndexPath:indexPath] == menuLogin) {
        [self.frostedViewController hideMenuViewController];
        UIStoryboard* storyMain = [UIStoryboard storyboardWithName:@"Authentication" bundle:nil];
        [self presentViewController:[storyMain instantiateInitialViewController] animated:YES completion:nil];
    }
}

- (IBAction)clickShowUser:(id)sender {
    [self.frostedViewController hideMenuViewController];
    LXAppDelegate *app = [LXAppDelegate currentDelegate];
    UINavigationController *navCurrent = (UINavigationController*)app.viewMainTab.selectedViewController;
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"MainStoryboard"
                                                             bundle:nil];
    LXUserPageViewController *viewUserPage = [mainStoryboard instantiateViewControllerWithIdentifier:@"UserPage"];
    [navCurrent pushViewController:viewUserPage animated:YES];
}

/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
