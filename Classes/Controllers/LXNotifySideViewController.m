//
//  luxeysRightSideViewController.m
//  Latte
//
//  Created by Xuan Dung Bui on 8/17/12.
//  Copyright (c) 2012 LUXEYS. All rights reserved.
//

#import "LXNotifySideViewController.h"

#import "LXAppDelegate.h"
#import "LatteAPIClient.h"
#import "LXCellFriendRequest.h"
#import "LXCellNotify.h"
#import "UIButton+AsyncImage.h"
#import "LXGalleryViewController.h"
#import "LXMyPageViewController.h"
#import "Comment.h"
#import "User.h"
#import "Picture.h"

@interface LXNotifySideViewController ()

@end

@implementation LXNotifySideViewController {
    NSMutableArray *notifies;
    
    int page;
    int limit;
    EGORefreshTableHeaderView *refreshHeaderView;
    BOOL reloading;
    BOOL loadEnded;
}
@synthesize tableNotify;
@synthesize activityLoad;

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

    tableNotify.layer.cornerRadius = 5.0;
    tableNotify.layer.masksToBounds = YES;
    
    // Do any additional setup after loading the view from its nib.
    refreshHeaderView = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - tableNotify.bounds.size.height, tableNotify.frame.size.width, tableNotify.bounds.size.height)];
    refreshHeaderView.delegate = self;
    [tableNotify addSubview:refreshHeaderView];
    loadEnded = false;
    page = 1;
    limit = 30;

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        LXAppDelegate *app = [LXAppDelegate currentDelegate];
        return app.uploader.count;
    }
    return notifies.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    LXCellNotify* cellNotify = [tableView dequeueReusableCellWithIdentifier:@"Notify"];
    NSDictionary *notify = [notifies objectAtIndex:indexPath.row];
    [cellNotify setNotify:notify];
    return cellNotify;
}

- (void)reloadView {
    page = 0;
    [self loadNotify];
}

- (void)loadNotify {
    LXAppDelegate* app = (LXAppDelegate*)[UIApplication sharedApplication].delegate;
    page += 1;
    [activityLoad startAnimating];
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                           [app getToken], @"token",
                           [NSNumber numberWithInt:page], @"page",
                           [NSNumber numberWithInt:limit], @"limit",
                           nil];

    [[LatteAPIClient sharedClient] getPath:@"user/me/notify"
                                      parameters: params
                                         success:^(AFHTTPRequestOperation *operation, NSDictionary *JSON) {
                                             if (page == 1) {
                                                 notifies = [NSMutableArray arrayWithArray:[JSON objectForKey:@"notifies"]];
                                             } else {
                                                 [notifies addObjectsFromArray:[JSON objectForKey:@"notifies"]];
                                             }
                                             
                                             [tableNotify reloadData];
                                             [self doneLoadingTableViewData];
                                             [activityLoad stopAnimating];
                                         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                             TFLog(@"Something went wrong (Notify)");
                                             UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"error", "Error")
                                                                                             message:error.localizedDescription
                                                                                            delegate:nil
                                                                                   cancelButtonTitle:NSLocalizedString(@"close", "Close")
                                                                                   otherButtonTitles:nil];
                                             [alert show];
                                             [self doneLoadingTableViewData];
                                             [activityLoad stopAnimating];
                                         }];
}


- (void)receiveLoggedIn:(NSNotification *) notification {
    [self reloadView];
}

- (void)receiveLoggedOut:(NSNotification *)notification {
    notifies = nil;
    [tableNotify reloadData];
}

- (void)becomeActive:(NSNotification *) notification {
    LXAppDelegate* app = [LXAppDelegate currentDelegate];
    if (app.currentUser) {
        [self reloadView];
    }
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *notify = notifies[indexPath.row];
    NotifyTarget notifyTarget = [[notify objectForKey:@"target_model"] integerValue];
    switch (notifyTarget) {
        case kNotifyTargetComment: {
            Comment *comment = [Comment instanceFromDictionary:[notify objectForKey:@"target"]];
            break;
        }
        case kNotifyTargetPicture: {
            Picture *pic = [Picture instanceFromDictionary:[notify objectForKey:@"target"]];
            
            UIStoryboard *storyGallery = [UIStoryboard storyboardWithName:@"Gallery"
                                                                   bundle:nil];
            UINavigationController *navGalerry = [storyGallery instantiateInitialViewController];
            LXGalleryViewController *viewGallery = navGalerry.viewControllers[0];
            viewGallery.picture = pic;
            [self presentViewController:navGalerry animated:YES completion:nil];
            break;
        }
        case kNotifyTargetUser: {
            LXAppDelegate *app = [LXAppDelegate currentDelegate];
            UINavigationController *currentNav = (UINavigationController*)app.viewMainTab.selectedViewController;
            User *user = [User instanceFromDictionary:[notify objectForKey:@"target"]];
            
            UIStoryboard *storyGallery = [UIStoryboard storyboardWithName:@"MainStoryboard"
                                                                   bundle:nil];
            LXMyPageViewController  *viewMypage = [storyGallery instantiateViewControllerWithIdentifier:@"UserPage"];
            viewMypage.user = user;
            [currentNav pushViewController:viewMypage animated:YES];
            
            break;
        }
        default:
            break;
    }

    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return 20;
    }
    NSString *stringNotify = [LXUtils stringFromNotify:notifies[indexPath.row]];
    
    CGSize labelSize = [stringNotify sizeWithFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:11]
                                constrainedToSize:CGSizeMake(230.0, MAXFLOAT)
                                    lineBreakMode:NSLineBreakByWordWrapping];
    
    return labelSize.height + 26;
}

- (void)scrollViewDidScroll:(UIScrollView *)aScrollView {
    [refreshHeaderView egoRefreshScrollViewDidScroll:aScrollView];
    
    if (loadEnded)
        return;
    CGPoint offset = aScrollView.contentOffset;
    CGRect bounds = aScrollView.bounds;
    CGSize size = aScrollView.contentSize;
    UIEdgeInsets inset = aScrollView.contentInset;
    float y = offset.y + bounds.size.height - inset.bottom;
    float h = size.height;
    
    float reload_distance = -100;
    if(y > h + reload_distance) {
        if (!activityLoad.isAnimating) {
            [self loadNotify];
        }
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

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
	[refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
}


- (void)viewDidUnload {
    [super viewDidUnload];
}
@end
