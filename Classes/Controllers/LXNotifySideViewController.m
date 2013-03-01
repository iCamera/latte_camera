//
//  luxeysRightSideViewController.m
//  Latte
//
//  Created by Xuan Dung Bui on 8/17/12.
//  Copyright (c) 2012 LUXEYS. All rights reserved.
//

#import "LXNotifySideViewController.h"

@interface LXNotifySideViewController ()

@end

@implementation LXNotifySideViewController
@synthesize tableNotify;
@synthesize segmentTab;

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
        
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveLoggedIn:) name:@"LoggedIn" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(becomeActive:) name:@"BecomeActive" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(becomeActive:) name:@"ReceivedPushNotify" object:nil];
    
    page = 1;
    limit = 12;
    tableMode = 0;
    
    // Do any additional setup after loading the view from its nib.
    UIFont *font = [UIFont fontWithName:@"AvenirNextCondensed-Regular" size:12];
    NSDictionary *attributes = [NSDictionary dictionaryWithObject:font
                                                           forKey:UITextAttributeFont];
    [segmentTab setTitleTextAttributes:attributes
                                    forState:UIControlStateNormal];
    
    refreshHeaderView = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - tableNotify.bounds.size.height, tableNotify.frame.size.width, tableNotify.bounds.size.height)];
    refreshHeaderView.delegate = self;
    [tableNotify addSubview:refreshHeaderView];
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(sessionStateChanged:)
     name:FBSessionStateChangedNotification
     object:nil];
    
    LXAppDelegate* app = (LXAppDelegate*)[UIApplication sharedApplication].delegate;
    if (app.currentUser != nil) {
        [self receiveLoggedIn:nil];
        
        if (FBSession.activeSession.isOpen) {
            [self loadFacebokFriend];
        }
    }
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
    else {
        if (FBSession.activeSession.isOpen) {
            return 3;
        } else {
            return 2;
        }
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableMode == 0) {
      return notifies.count;
    } else {
        switch (section) {
            case 0:
                return requests.count;
                break;
            case 1:
                return ignores.count;
                break;
            case 2:
                return fbfriends.count;
                break;
            default:
                return 0;
                break;
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableMode == 0) {
        LXCellNotify* cellNotify = [tableView dequeueReusableCellWithIdentifier:@"Notify"];
        NSDictionary *notify = [notifies objectAtIndex:indexPath.row];
        [cellNotify setNotify:notify];
        return cellNotify;
    } else {        
        LXCellFriendRequest *cellRequest;
        User *user;
        if (indexPath.section == 0) {
            cellRequest = [tableView dequeueReusableCellWithIdentifier:@"Request"];
            user = [requests objectAtIndex:indexPath.row];
        } else if (indexPath.section == 1) {
            cellRequest = [tableView dequeueReusableCellWithIdentifier:@"Ignore"];
            user = [ignores objectAtIndex:indexPath.row];
        } else {
            cellRequest = [tableView dequeueReusableCellWithIdentifier:@"Ignore"];
            user = [fbfriends objectAtIndex:indexPath.row];
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
            if (FBSession.activeSession.isOpen) {
                [self loadFacebokFriend];
            }
            break;
    }
}

- (void)reloadNotify {
    LXAppDelegate* app = (LXAppDelegate*)[UIApplication sharedApplication].delegate;
    [[LatteAPIClient sharedClient] getPath:@"user/me/notify"
                                      parameters: [NSDictionary dictionaryWithObjectsAndKeys:
                                                   [app getToken], @"token",
                                                   nil]
                                         success:^(AFHTTPRequestOperation *operation, NSDictionary *JSON) {
                                             notifies = [NSMutableArray arrayWithArray:[JSON objectForKey:@"notifies"]];
                                             [tableNotify reloadData];
                                             [self doneLoadingTableViewData];
                                         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                             TFLog(@"Something went wrong (Notify)");
                                             UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"error", "Error")
                                                                                             message:error.localizedDescription
                                                                                            delegate:nil
                                                                                   cancelButtonTitle:NSLocalizedString(@"close", "Close")
                                                                                   otherButtonTitles:nil];
                                             [alert show];
                                             [self doneLoadingTableViewData];
                                         }];
}

- (void)reloadRequest {
    LXAppDelegate* app = (LXAppDelegate*)[UIApplication sharedApplication].delegate;
    [[LatteAPIClient sharedClient] getPath:@"user/me/friendrequest"
                                      parameters: [NSDictionary dictionaryWithObjectsAndKeys:
                                                   [app getToken], @"token",
                                                   nil]
                                         success:^(AFHTTPRequestOperation *operation, NSDictionary *JSON) {
                                             requests = [User mutableArrayFromDictionary:JSON withKey:@"requests"];
                                             ignores = [User mutableArrayFromDictionary:JSON withKey:@"ignores"];
                                             [tableNotify reloadData];
                                             [self doneLoadingTableViewData];
                                         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                             TFLog(@"Something went wrong (Notify Request)");
                                             UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"error", "Error")
                                                                                             message:error.localizedDescription
                                                                                            delegate:nil
                                                                                   cancelButtonTitle:NSLocalizedString(@"close", "Close")
                                                                                   otherButtonTitles:nil];
                                             [alert show];
                                             [self doneLoadingTableViewData];
                                         }];
}

- (void)loadFacebokFriend {
    FBSession *fbsession = FBSession.activeSession;
    
    FBRequest *fbrequest = [[FBRequest alloc]initWithSession:fbsession
                                                   graphPath:@"me/friends"
                                                  parameters:[NSDictionary dictionaryWithObject:@"id,name,installed" forKey:@"fields"]
                                                  HTTPMethod:@"GET"];
    [fbrequest startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        NSMutableArray *tmp = [[NSMutableArray alloc]init];
        for (NSDictionary* friend in [(NSDictionary*)result objectForKey:@"data"]) {
            if ([friend objectForKey:@"installed"] != nil) {
                [tmp addObject:[friend objectForKey:@"id"]];
            }
        }
        
        if (tmp.count > 0) {
            LXAppDelegate* app = (LXAppDelegate*)[UIApplication sharedApplication].delegate;
            [[LatteAPIClient sharedClient] getPath:@"user/friends/facebook_unadded_friend"
                                        parameters: [NSDictionary dictionaryWithObjectsAndKeys:
                                                     [app getToken], @"token",
                                                     [tmp componentsJoinedByString:@","], @"fbids",
                                                     nil]
                                           success:^(AFHTTPRequestOperation *operation, NSDictionary *JSON) {
                                               fbfriends = [User mutableArrayFromDictionary:JSON withKey:@"users"];
                                               //[tableNotify reloadSections:[NSIndexSet indexSetWithIndex:2] withRowAnimation:UITableViewRowAnimationAutomatic];
                                               if (tableMode == 1) {                                                                                                  [tableNotify reloadData];
                                               }
                                           } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                               TFLog(@"Something went wrong (FB Friends)");
                                           }];
        }
        
    }];
}

- (void)sessionStateChanged:(NSNotification*)notification {
    if (FBSession.activeSession.isOpen) {
        [self loadFacebokFriend];
    } else {
        fbfriends = nil;
    }
}


- (void)receiveLoggedIn:(NSNotification *) notification {
    requests = nil;
    ignores = nil;
    notifies = nil;
    [self reloadView];
}

- (void)becomeActive:(NSNotification *) notification {
    LXAppDelegate* app = (LXAppDelegate*)[UIApplication sharedApplication].delegate;
    if (app.currentUser != nil) {
        requests = nil;
        ignores = nil;
        notifies = nil;
        [self reloadView];
    }
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
    
    LXAppDelegate* app = (LXAppDelegate*)[[UIApplication sharedApplication] delegate];
    
    NSString *url = [NSString stringWithFormat:@"user/friend/request/%d", sender.tag];
    [[LatteAPIClient sharedClient] postPath:url
                                 parameters: [NSDictionary dictionaryWithObjectsAndKeys:[app getToken], @"token", nil]
                                    success: nil
                                    failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                        sender.enabled = true;
                                        if (buttonIgnore != nil)
                                            buttonIgnore.enabled = true;
                                        TFLog(@"Something went wrong (RightMenu - Approve/Request)");
                                        
                                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"error", "Error")
                                                                                        message:error.localizedDescription
                                                                                       delegate:nil
                                                                              cancelButtonTitle:NSLocalizedString(@"close", "Close")
                                                                              otherButtonTitles:nil];
                                        [alert show];
                                    }];
}

- (void)ingoreRequest:(UIButton *)sender {
    sender.enabled = false;
    UIButton *buttonAdd = (id)[tableNotify viewWithTag:-sender.tag];
    buttonAdd.enabled = false;
    
    LXAppDelegate* app = (LXAppDelegate*)[[UIApplication sharedApplication] delegate];
    NSString *url = [NSString stringWithFormat:@"user/friend/ignore/%d", -sender.tag];
    [[LatteAPIClient sharedClient] postPath:url
                                 parameters: [NSDictionary dictionaryWithObjectsAndKeys:[app getToken], @"token", nil]
                                    success: nil
                                    failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                        sender.enabled = true;
                                        buttonAdd.enabled = true;
                                        TFLog(@"Something went wrong (RightMenu - ignore)");
                                        
                                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"error", "Error")
                                                                                        message:error.localizedDescription
                                                                                       delegate:nil
                                                                              cancelButtonTitle:NSLocalizedString(@"close", "Close")
                                                                              otherButtonTitles:nil];
                                        [alert show];
                                    }];
}

- (void)showRequestUser:(UIButton*)sender {
    User *user = [requests objectAtIndex:sender.tag];
    
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"ShowUser"
     object:user];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {    
    if (tableMode == 0) {
        NSDictionary *notify = [notifies objectAtIndex:indexPath.row];
        
        Picture *pic = [Picture instanceFromDictionary:[notify objectForKey:@"target"]];
        if (pic.pictureId != nil) {
            [[NSNotificationCenter defaultCenter]
             postNotificationName:@"ShowPic"
             object:pic];
        }
    } else {
        User* user;
        switch (indexPath.section) {
            case 0: {
                user = requests[indexPath.row];
            }
                break;
            case 1: {
                user = ignores[indexPath.row];
            }
                break;
            case 2: {
                user = fbfriends[indexPath.row];
            }
                break;
                
            default:
                break;
        }
        
        [[NSNotificationCenter defaultCenter]
         postNotificationName:@"ShowUser"
         object:user];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (tableMode == 1) {
        switch (section) {
            case 0:
                return NSLocalizedString(@"request_pending", @"友達申請");
                break;
            case 1:
                return NSLocalizedString(@"request_ignored", @"保存");
                break;
            case 2:
                return NSLocalizedString(@"request_facebook", @"Facebookの知り合い");
                break;
            default:
                break;
        }
    }
    return nil;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (tableMode == 1) {
        UIView *view = [[UIView alloc] init];

        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 260, 30)];
        label.text = [self tableView:tableView titleForHeaderInSection:section];
        label.font = [UIFont fontWithName:@"AvenirNextCondensed-Regular" size:14];
        label.shadowOffset = CGSizeMake(0, 1);
        label.textColor = [UIColor whiteColor];
        label.shadowColor = [UIColor blackColor];
        label.backgroundColor = [UIColor clearColor];
        view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bt_menu_title.png"]];
        [view addSubview:label];
        return view;
    }
    else
        return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (tableMode == 1)
        return 30;
    else
        return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableMode == 0) {
        NSString *stringNotify = [LXUtils stringFromNotify:notifies[indexPath.row]];
        
        CGSize labelSize = [stringNotify sizeWithFont:[UIFont fontWithName:@"AvenirNextCondensed-Regular" size:11]
                                        constrainedToSize:CGSizeMake(180.0, MAXFLOAT)
                                            lineBreakMode:NSLineBreakByWordWrapping];
        
        return labelSize.height + 26;
    } else {
        return 40;
    }
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


- (void)viewDidUnload {
    [self setSegmentTab:nil];
    [super viewDidUnload];
}
@end
