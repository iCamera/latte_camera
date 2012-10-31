//
//  luxeysRightSideViewController.m
//  Latte
//
//  Created by Xuan Dung Bui on 8/17/12.
//  Copyright (c) 2012 LUXEYS. All rights reserved.
//

#import "luxeysRightSideViewController.h"

@interface luxeysRightSideViewController ()

@end

@implementation luxeysRightSideViewController
@synthesize tableNotify;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(receiveLoggedIn:)
                                                     name:@"LoggedIn"
                                                   object:nil];
        page = 1;
        limit = 12;
        tableMode = 0;
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    refreshHeaderView = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - tableNotify.bounds.size.height, tableNotify.frame.size.width, tableNotify.bounds.size.height)];
    refreshHeaderView.delegate = self;
    [tableNotify addSubview:refreshHeaderView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (tableMode == 0) {
        return 1;
    }
    else
        return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableMode == 0) {
      return notifies.count;
    } else {
        if (section == 0) {
            return requests.count;
        } else {
            return ignores.count;
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableMode == 0) {
        luxeysCellNotify* cellNotify = [tableView dequeueReusableCellWithIdentifier:@"Notify"];
        NSDictionary *notify = [notifies objectAtIndex:indexPath.row];
        [cellNotify setNotify:notify];
        return cellNotify;
    } else {        
        luxeysCellFriendRequest *cellRequest;
        User *user;
        if (indexPath.section == 0) {
            cellRequest = [tableView dequeueReusableCellWithIdentifier:@"Request"];
            user = [requests objectAtIndex:indexPath.row];
        } else if (indexPath.section == 1) {
            cellRequest = [tableView dequeueReusableCellWithIdentifier:@"Ignore"];
            user = [ignores objectAtIndex:indexPath.row];
        }
        [cellRequest setUser:user];
        
        [cellRequest.buttonAdd addTarget:self action:@selector(addRequest:) forControlEvents:UIControlEventTouchUpInside];
        [cellRequest.buttonIgnore addTarget:self action:@selector(ingoreRequest:) forControlEvents:UIControlEventTouchUpInside];
        cellRequest.buttonAdd.tag = [user.userId integerValue];
        cellRequest.buttonIgnore.tag = -[user.userId integerValue];
        
        return cellRequest;        
    }
}

- (void)reloadView {
    switch (tableMode) {
        case 0:
            [self reloadNotify];
            break;
        case 1:
            [self reloadRequest];
            break;
    }
}

- (void)reloadNotify {
    luxeysAppDelegate* app = (luxeysAppDelegate*)[UIApplication sharedApplication].delegate;
    [[LatteAPIClient sharedClient] getPath:@"api/user/me/notify"
                                      parameters: [NSDictionary dictionaryWithObjectsAndKeys:
                                                   [app getToken], @"token",
                                                   nil]
                                         success:^(AFHTTPRequestOperation *operation, NSDictionary *JSON) {
                                             notifies = [NSMutableArray arrayWithArray:[JSON objectForKey:@"notifies"]];
                                             [tableNotify reloadData];
                                             [self doneLoadingTableViewData];
                                         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                             NSLog(@"Something went wrong (Notify)");
                                             [self doneLoadingTableViewData];
                                         }];
}

- (void)reloadRequest {
    luxeysAppDelegate* app = (luxeysAppDelegate*)[UIApplication sharedApplication].delegate;
    [[LatteAPIClient sharedClient] getPath:@"api/user/me/friendrequest"
                                      parameters: [NSDictionary dictionaryWithObjectsAndKeys:
                                                   [app getToken], @"token",
                                                   nil]
                                         success:^(AFHTTPRequestOperation *operation, NSDictionary *JSON) {
                                             requests = [User mutableArrayFromDictionary:JSON withKey:@"requests"];
                                             ignores = [User mutableArrayFromDictionary:JSON withKey:@"ignores"];
                                             [tableNotify reloadData];
                                             [self doneLoadingTableViewData];
                                         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                             NSLog(@"Something went wrong (Notify)");
                                             [self doneLoadingTableViewData];
                                         }];
}

- (void)receiveLoggedIn:(NSNotification *) notification {
    requests = nil;
    ignores = nil;
    notifies = nil;
    [self reloadView];
}

- (IBAction)touchTab:(UISegmentedControl*)sender {
    tableMode = sender.selectedSegmentIndex;
    
    switch (tableMode) {
        case 0:
            if (notifies == nil) {
                [self reloadNotify];
            } else {
                [tableNotify reloadData];
            }
            break;
        case 1:
            if ((requests == nil) || (ignores == nil)) {
                [self reloadRequest];
            } else {
                [tableNotify reloadData];
            }
            
            break;
    }
}

- (void)addRequest:(UIButton *)sender {
    sender.enabled = false;
    UIButton *buttonIgnore = (id)[tableNotify viewWithTag:-sender.tag];
    if (buttonIgnore != nil)
        buttonIgnore.enabled = false;
    
    luxeysAppDelegate* app = (luxeysAppDelegate*)[[UIApplication sharedApplication] delegate];
    
    NSString *url = [NSString stringWithFormat:@"/api/user/friend/approve/%d", sender.tag];
    [[LatteAPIClient sharedClient] postPath:url
                                 parameters: [NSDictionary dictionaryWithObjectsAndKeys:[app getToken], @"token", nil]
                                    success: nil
                                    failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                        NSLog(@"Something went wrong (RightMenu - Approve)");
                                    }];
    
}

- (void)ingoreRequest:(UIButton *)sender {
    sender.enabled = false;
    UIButton *buttonAdd = (id)[tableNotify viewWithTag:-sender.tag];
    buttonAdd.enabled = false;
    
    luxeysAppDelegate* app = (luxeysAppDelegate*)[[UIApplication sharedApplication] delegate];
    NSString *url = [NSString stringWithFormat:@"/api/user/friend/ignore/%d", -sender.tag];
    [[LatteAPIClient sharedClient] postPath:url
                                 parameters: [NSDictionary dictionaryWithObjectsAndKeys:[app getToken], @"token", nil]
                                    success: nil
                                    failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                        NSLog(@"Something went wrong (RightMenu - ignore)");
                                    }];
}

- (void)showRequestUser:(UIButton*)sender {
    luxeysAppDelegate* app = (luxeysAppDelegate*)[UIApplication sharedApplication].delegate;
    
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"MainStoryboard"
                                                             bundle:nil];
    luxeysUserViewController *viewUser = [mainStoryboard instantiateViewControllerWithIdentifier:@"UserProfile"];
    
    User *user = [requests objectAtIndex:sender.tag];
    [viewUser setUserID:[user.userId integerValue]];
    UINavigationController *nav = (id)app.viewMainTab.selectedViewController;
    [nav pushViewController:viewUser animated:YES];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    luxeysAppDelegate* app = (luxeysAppDelegate*)[UIApplication sharedApplication].delegate;
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"MainStoryboard"
                                                             bundle:nil];
    
    if (tableMode == 0) {
        NSDictionary *notify = [notifies objectAtIndex:indexPath.row];
        
        luxeysPicDetailViewController *viewPic = [mainStoryboard instantiateViewControllerWithIdentifier:@"Picture"];
        Picture *pic = [Picture instanceFromDictionary:[notify objectForKey:@"target"]];
        [viewPic setPictureID:[pic.pictureId integerValue]];
        app.viewMainTab.selectedIndex = 4; // Switch to mypage
        UINavigationController *nav = (UINavigationController *)app.viewMainTab.selectedViewController;
        [nav pushViewController:viewPic animated:YES];
    } else {
        luxeysUserViewController *viewUser = [mainStoryboard instantiateViewControllerWithIdentifier:@"UserProfile"];
        if (indexPath.section == 0) {
            User *request = requests[indexPath.row];
            [viewUser setUserID:[request.userId integerValue]];
        } else {
            User *ignore = ignores[indexPath.row];
            [viewUser setUserID:[ignore.userId integerValue]];
        }
        app.viewMainTab.selectedIndex = 4; // Switch to mypage
        UINavigationController *nav = (UINavigationController *)app.viewMainTab.selectedViewController;
        [nav pushViewController:viewUser animated:YES];
    }
    
    [app.revealController performSelector:@selector(revealRight:) withObject:self];

    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (tableMode == 1) {
        switch (section) {
            case 0:
                return @"友達申請";
                break;
            case 1:
                return @"保存";
                break;
            default:
                break;
        }
    }
    return nil;
}

- (void)reloadTableViewDataSource{
	//  should be calling your tableviews data source model to reload
	//  put here just for demo
	reloading = YES;
}

- (void)doneLoadingTableViewData{
	//  model should call this when its done loading
	reloading = NO;
	[refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.tableNotify];
	
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
