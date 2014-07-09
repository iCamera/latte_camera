//
//  LXFollowerViewController.m
//  Latte camera
//
//  Created by Bui Xuan Dung on 7/3/14.
//  Copyright (c) 2014 LUXEYS. All rights reserved.
//

#import "LXUserListViewController.h"
#import "LatteAPIClient.h"
#import "LXAppDelegate.h"
#import "LXUserPageViewController.h"
#import "MZFormSheetController.h"
#import "LXCellFriend.h"

@interface LXUserListViewController ()

@end

@implementation LXUserListViewController {
    NSArray *users;
}

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
    self.clearsSelectionOnViewWillAppear = NO;
    [self.tableView registerNib:[UINib nibWithNibName:@"LXCellFriend" bundle:nil] forCellReuseIdentifier:@"User"];
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)loadFollowerForUser:(NSInteger)userId {
    NSString *url = [NSString stringWithFormat:@"user/%ld/follower", (long)userId];
    [[LatteAPIClient sharedClient] GET:url
                            parameters: nil
                               success:^(AFHTTPRequestOperation *operation, NSDictionary *JSON) {
                                   users = [User mutableArrayFromDictionary:JSON
                                                                    withKey:@"followers"];
                                   
                                   [self.tableView reloadData];
                                   
                                   self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
                                   [self.refreshControl endRefreshing];
                                   
                               } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                   DLog(@"Something went wrong (Follower)");
                                   self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
                               }];
}

- (void)loadFollowingForUser:(NSInteger)userId {
    NSString *url = [NSString stringWithFormat:@"user/%ld/following", (long)userId];
    [[LatteAPIClient sharedClient] GET:url
                            parameters: nil
                               success:^(AFHTTPRequestOperation *operation, NSDictionary *JSON) {
                                   users = [User mutableArrayFromDictionary:JSON
                                                                    withKey:@"following"];
                                   
                                   self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
                                   [self.tableView reloadData];
                               } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                   DLog(@"Something went wrong (Reload Following)");
                                   self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
                               }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return users.count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"MainStoryboard"
                                                             bundle:nil];
    LXUserPageViewController *viewUserPage = [mainStoryboard instantiateViewControllerWithIdentifier:@"UserPage"];
    viewUserPage.user = users[indexPath.row];
    [self mz_dismissFormSheetControllerAnimated:YES completionHandler:^(MZFormSheetController *formSheetController) {
        [formSheetController.presentingViewController.navigationController pushViewController:viewUserPage animated:YES];
    }];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    LXCellFriend *cellUser = [tableView dequeueReusableCellWithIdentifier:@"User" forIndexPath:indexPath];
    
    @try {
        cellUser.user = users[indexPath.row];
    }
    @catch (NSException *exception) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                        message:exception.debugDescription
                                                       delegate:nil
                                              cancelButtonTitle:@"Close"
                                              otherButtonTitles:nil];
        [alert show];
    }
    
    return cellUser;
}


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
