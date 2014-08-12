//
//  LXFollowerViewController.m
//  Latte camera
//
//  Created by Bui Xuan Dung on 7/3/14.
//  Copyright (c) 2014 LUXEYS. All rights reserved.
//

#import "LXUserListViewController.h"
#import "LatteAPIv2Client.h"
#import "LXAppDelegate.h"
#import "LXUserPageViewController.h"
#import "MZFormSheetController.h"
#import "LXCellFriend.h"
#import "AFNetworking.h"

@interface LXUserListViewController ()

@end

@implementation LXUserListViewController {
    NSMutableArray *users;
    NSInteger mode;
    NSInteger _userId;
    NSInteger page;
    BOOL loading;
    BOOL endedLoad;
    AFHTTPRequestOperation *currentRequest;
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
    users = [[NSMutableArray alloc] init];
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)loadFollowerForUser:(NSInteger)userId {
    _userId = userId;
    mode = 1;
    [self loadMore:YES];
}

- (void)loadFollowingForUser:(NSInteger)userId {
    mode = 2;
    _userId = userId;
    [self loadMore:YES];
}

- (void)loadMore:(BOOL)reset {
    NSString *url;
    if (mode == 1) {
        url = [NSString stringWithFormat:@"user/%ld/follower", (long)_userId];
    }

    if (mode == 2) {
        url = [NSString stringWithFormat:@"user/%ld/following", (long)_userId];
    }
    
    if (reset) {
        if (loading) [currentRequest cancel];
        endedLoad = false;
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        page = 1;
    } else {
        if (loading) return;
        [_loadIndicator startAnimating];
    }
    
    loading = YES;
    
    NSDictionary *params = @{@"page": [NSNumber numberWithInteger:page]};
    
    currentRequest = [[LatteAPIv2Client sharedClient] GET:url
                              parameters: params
                                 success:^(AFHTTPRequestOperation *operation, NSDictionary *JSON) {
                                     page += 1;
                                     NSMutableArray *newUser = [User mutableArrayFromDictionary:JSON
                                                                      withKey:@"profiles"];
                                     endedLoad = newUser.count == 0;
                                     
                                     if (reset) {
                                         users = newUser;
                                         [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                                     } else {
                                         if (newUser.count > 0) {
                                             
                                             NSMutableArray *arrayOfIndexPaths = [[NSMutableArray alloc] init];
                                             
                                             for(int i = 0 ; i < newUser.count ; i++)
                                             {
                                                 NSIndexPath *path = [NSIndexPath indexPathForRow:users.count+i inSection:0];
                                                 [arrayOfIndexPaths addObject:path];
                                             }
                                             
                                             [self.tableView beginUpdates];
                                             [users addObjectsFromArray:newUser];
                                             
                                             [self.tableView insertRowsAtIndexPaths:arrayOfIndexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
                                             [self.tableView endUpdates];
                                         }
                                     }
                                     
                                     [_loadIndicator stopAnimating];
                                     [self.tableView reloadData];
                                     [self.refreshControl endRefreshing];
                                     loading = NO;

                                 } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                     if (reset) {
                                         [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                                         [self.refreshControl endRefreshing];
                                     } else {
                                         [_loadIndicator stopAnimating];
                                     }
                                     loading = NO;
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

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGPoint offset = scrollView.contentOffset;
    CGRect bounds = scrollView.bounds;
    CGSize size = scrollView.contentSize;
    UIEdgeInsets inset = scrollView.contentInset;
    float y = offset.y + bounds.size.height - inset.bottom;
    float h = size.height;
    
    float reload_distance = -100;
    if(y > h + reload_distance) {
        [self loadMore:NO];
    }
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
