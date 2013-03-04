//
//  luxeysRightSideViewController.m
//  Latte
//
//  Created by Xuan Dung Bui on 8/17/12.
//  Copyright (c) 2012 LUXEYS. All rights reserved.
//

#import "LXNotifySideViewController.h"

#import "LXGalleryViewController.h"

@interface LXNotifySideViewController ()

@end

@implementation LXNotifySideViewController
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

    
    // Do any additional setup after loading the view from its nib.
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


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return notifies.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    LXCellNotify* cellNotify = [tableView dequeueReusableCellWithIdentifier:@"Notify"];
    NSDictionary *notify = [notifies objectAtIndex:indexPath.row];
    [cellNotify setNotify:notify];
    return cellNotify;
}

- (void)reloadView {
    [self reloadNotify];
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
    notifies = nil;
    [self reloadView];
}

- (void)becomeActive:(NSNotification *) notification {
    LXAppDelegate* app = (LXAppDelegate*)[UIApplication sharedApplication].delegate;
    if (app.currentUser != nil) {
        notifies = nil;
        [self reloadView];
    }
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *notify = notifies[indexPath.row];
    
    Picture *pic = [Picture instanceFromDictionary:[notify objectForKey:@"target"]];
    
    UIStoryboard *storyGallery = [UIStoryboard storyboardWithName:@"Gallery"
                                                           bundle:nil];
    UINavigationController *navGalerry = [storyGallery instantiateInitialViewController];
    LXGalleryViewController *viewGallery = navGalerry.viewControllers[0];
    viewGallery.picture = pic;
    [self presentViewController:navGalerry animated:YES completion:nil];

    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *stringNotify = [LXUtils stringFromNotify:notifies[indexPath.row]];
    
    CGSize labelSize = [stringNotify sizeWithFont:[UIFont fontWithName:@"AvenirNextCondensed-Regular" size:11]
                                constrainedToSize:CGSizeMake(180.0, MAXFLOAT)
                                    lineBreakMode:NSLineBreakByWordWrapping];
    
    return labelSize.height + 26;
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
    [super viewDidUnload];
}
@end
