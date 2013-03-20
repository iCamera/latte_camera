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
#import "LXCellNotify.h"
#import "LXCellUpload.h"
#import "UIButton+AsyncImage.h"
#import "LXGalleryViewController.h"
#import "LXMyPageViewController.h"
#import "Comment.h"
#import "User.h"
#import "Picture.h"
#import "MBProgressHUD.h"

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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(uploadSuccess:) name:@"LXUploaderSuccess" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(uploadStart:) name:@"LXUploaderStart" object:nil];
    
    tableNotify.layer.cornerRadius = 5.0;
    tableNotify.layer.masksToBounds = YES;
    
    // Do any additional setup after loading the view from its nib.
    refreshHeaderView = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - tableNotify.bounds.size.height, tableNotify.frame.size.width, tableNotify.bounds.size.height)];
    refreshHeaderView.delegate = self;
    [tableNotify addSubview:refreshHeaderView];
    loadEnded = false;

    limit = 30;

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        LXAppDelegate *app = [LXAppDelegate currentDelegate];
        return app.uploader.count;
    } else
        return notifies.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    LXAppDelegate *app = [LXAppDelegate currentDelegate];
    if (indexPath.section == 0) {
        LXCellUpload* cellUpload = [tableView dequeueReusableCellWithIdentifier:@"Upload"];
        cellUpload.uploader = app.uploader[indexPath.row];
        return cellUpload;
    } if (indexPath.section == 1) {
        LXCellNotify* cellNotify = [tableView dequeueReusableCellWithIdentifier:@"Notify"];
        NSDictionary *notify = [notifies objectAtIndex:indexPath.row];
        [cellNotify setNotify:notify];
        return cellNotify;
    } else
        return nil;
}

- (void)reloadView {
    page = 0;
    loadEnded = false;
    [self loadNotify];
}

- (void)loadNotify {
    LXAppDelegate* app = [LXAppDelegate currentDelegate];
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
                                             NSArray *newData = [JSON objectForKey:@"notifies"];
                                             if (newData.count == 0) {
                                                 loadEnded = true;
                                             }
                                             
                                             if (page == 1) {
                                                 notifies = [NSMutableArray arrayWithArray:newData];
                                             } else {
                                                 [notifies addObjectsFromArray:newData];
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

- (void)uploadStart:(NSNotification *) notification {
    [tableNotify reloadData];
}

- (void)uploadSuccess:(NSNotification *) notification {
    LXUploadObject *uploader = notification.object;
    LXAppDelegate* app = [LXAppDelegate currentDelegate];
    [app.uploader removeObject:uploader];
    [tableNotify reloadData];
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
    if (indexPath.section == 1) {
        
        NSDictionary *notify = notifies[indexPath.row];
        NotifyTarget notifyTarget = [[notify objectForKey:@"target_model"] integerValue];
        switch (notifyTarget) {
            case kNotifyTargetComment: {
                Comment *comment = [Comment instanceFromDictionary:[notify objectForKey:@"target"]];
                
                if (comment.pictureId != nil) {
                    LXAppDelegate *app = [LXAppDelegate currentDelegate];
                    NSString *urlDetail = [NSString stringWithFormat:@"picture/%d", [comment.pictureId integerValue]];
                    MBProgressHUD *hud = [[MBProgressHUD alloc]initWithView:_parent.view];
                    [_parent.view addSubview:hud];
                    hud.mode = MBProgressHUDModeIndeterminate;
                    [hud show:YES];

                    [[LatteAPIClient sharedClient] getPath:urlDetail
                                                parameters: [NSDictionary dictionaryWithObjectsAndKeys:[app getToken], @"token", nil]
                                                   success:^(AFHTTPRequestOperation *operation, NSDictionary *JSON) {
                                                       [hud hide:YES];
                                                       
                                                       
                                                       UIStoryboard *storyGallery = [UIStoryboard storyboardWithName:@"Gallery"
                                                                                                              bundle:nil];
                                                       UINavigationController *navGalerry = [storyGallery instantiateInitialViewController];
                                                       LXGalleryViewController *viewGallery = navGalerry.viewControllers[0];
                                                       
                                                       viewGallery.user = [User instanceFromDictionary:[JSON objectForKey:@"user"]];
                                                       viewGallery.picture = [Picture instanceFromDictionary:[JSON objectForKey:@"picture"]];
                                                       
                                                       
                                                       [self presentViewController:navGalerry animated:YES completion:nil];
                                                       
                                                   } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                       [hud hide:YES];
                                                       TFLog(@"Something went wrong Notify Gallery");
                                                       
                                                       UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"error", "Error")
                                                                                                       message:error.localizedDescription
                                                                                                      delegate:nil
                                                                                             cancelButtonTitle:NSLocalizedString(@"close", "Close")
                                                                                             otherButtonTitles:nil];
                                                       [alert show];
                                                   }];
                }
                
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
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return 42;
    }
    
    NSString *stringNotify = [LXUtils stringFromNotify:notifies[indexPath.row]];
    
    CGSize labelSize = [stringNotify sizeWithFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:11]
                                constrainedToSize:CGSizeMake(215.0, MAXFLOAT)
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


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
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


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return NSLocalizedString(@"upload_status", @"");
            break;
        case 1:
            return NSLocalizedString(@"notification", @"");
            break;
        default:
            break;
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

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
	[refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 30;
}


- (void)viewDidUnload {
    [super viewDidUnload];
}
@end
