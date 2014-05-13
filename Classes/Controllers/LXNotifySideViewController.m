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
#import "UIButton+AsyncImage.h"
#import "LXGalleryViewController.h"
#import "LXMyPageViewController.h"
#import "Comment.h"
#import "User.h"
#import "Picture.h"
#import "MBProgressHUD.h"
#import "LXNavigationController.h"

@interface LXNotifySideViewController ()

@end

@implementation LXNotifySideViewController {
    NSMutableArray *notifies;
    
    NSInteger page;
    NSInteger limit;
    NSInteger currentTab;
    BOOL loadEnded;
    
    AFHTTPRequestOperation *currentRequest;
}

@synthesize buttonAnnounce;
@synthesize webAnnounce;


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
    
    // Do any additional setup after loading the view from its nib.
    loadEnded = false;

    limit = 30;
    currentTab = 0;
    
    [self reloadView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (loadEnded) {
        return notifies.count;
    } else {
        return notifies.count + 1;
    }
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == notifies.count) {
        [self loadNotify:NO];
        UITableViewCell* cellNotify = [tableView dequeueReusableCellWithIdentifier:@"Load" forIndexPath:indexPath];
        return cellNotify;
    }
    
    LXCellNotify* cellNotify = [tableView dequeueReusableCellWithIdentifier:@"Notify" forIndexPath:indexPath];
    NSDictionary *notify = [notifies objectAtIndex:indexPath.row];
    [cellNotify setNotify:notify];
    return cellNotify;
}

- (void)reloadView {
    
    [self loadNotify:YES];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    self.tabBarItem.badgeValue = nil;
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
}

- (void)loadNotify:(BOOL)reset {
    if (reset) {
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        
        page = 1;
        if (currentRequest && currentRequest.isExecuting)
            [currentRequest cancel];
    } else {
        if (currentRequest && currentRequest.isExecuting)
            return;
    }
    
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                           [NSNumber numberWithInteger:page], @"page",
                           [NSNumber numberWithInteger:limit], @"limit",
                           [NSNumber numberWithInteger:currentTab], @"tab",
                           nil];

    currentRequest = [[LatteAPIClient sharedClient] GET:@"user/me/notify"
                                      parameters: params
                                         success:^(AFHTTPRequestOperation *operation, NSDictionary *JSON) {
                                             page += 1;
                                             
                                             NSArray *newData = [JSON objectForKey:@"notifies"];
                                             
                                             loadEnded = newData.count == 0;
                                             
                                             if (reset) {
                                                 // Reset count
                                                 [[LatteAPIClient sharedClient] POST:@"user/me/read_notify" parameters:nil success:nil failure:nil];
                                                 
                                                 notifies = [NSMutableArray arrayWithArray:newData];
                                                 [MBProgressHUD hideHUDForView:self.view animated:YES];
                                             } else {
                                                 [notifies addObjectsFromArray:newData];
                                             }
                                             
                                             [self.tableView reloadData];

                                             [self.refreshControl endRefreshing];
                                         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                             if (reset) {
                                                 [MBProgressHUD hideHUDForView:self.view animated:YES];
                                             }
                                         }];
}

- (void)receiveLoggedIn:(NSNotification *) notification {
    [self reloadView];
}

- (void)receiveLoggedOut:(NSNotification *)notification {
    notifies = nil;
    [self.tableView reloadData];
}

- (void)becomeActive:(NSNotification *) notification {
    [[LatteAPIClient sharedClient] GET:@"user/me/unread_notify" parameters: nil success:^(AFHTTPRequestOperation *operation, NSDictionary *JSON) {
        NSInteger count = [JSON[@"notify_count"] integerValue];
        if (count > 0) {
            self.tabBarItem.badgeValue = [JSON[@"notify_count"] stringValue];
        } else {
            self.tabBarItem.badgeValue = nil;
        }
        
    } failure: nil];
    
    [self reloadView];
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *notify = notifies[indexPath.row];
    NotifyTarget notifyTarget = [[notify objectForKey:@"target_model"] integerValue];
    switch (notifyTarget) {
        case kNotifyTargetComment: {
            Comment *comment = [Comment instanceFromDictionary:[notify objectForKey:@"target"]];
            
            if (comment.pictureId != nil) {
                NSString *urlDetail = [NSString stringWithFormat:@"picture/%d", [comment.pictureId integerValue]];
                MBProgressHUD *hud = [[MBProgressHUD alloc]initWithView:self.view];

                hud.mode = MBProgressHUDModeIndeterminate;
                [hud show:YES];
                
                [[LatteAPIClient sharedClient] GET:urlDetail parameters: nil success:^(AFHTTPRequestOperation *operation, NSDictionary *JSON) {
                    [hud hide:YES];
                    
                    UIStoryboard *storyGallery = [UIStoryboard storyboardWithName:@"Gallery"
                                                                           bundle:nil];
                    UINavigationController *navGalerry = [storyGallery instantiateInitialViewController];
                    LXGalleryViewController *viewGallery = navGalerry.viewControllers[0];
                    
                    viewGallery.user = [User instanceFromDictionary:[JSON objectForKey:@"user"]];
                    viewGallery.picture = [Picture instanceFromDictionary:[JSON objectForKey:@"picture"]];
                } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                    [hud hide:YES];
                    DLog(@"Something went wrong Notify Gallery");
                    
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
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 45;
    NSString *stringNotify = [LXUtils stringFromNotify:notifies[indexPath.row]];
    
    CGSize labelSize = [stringNotify sizeWithFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:11]
                                constrainedToSize:CGSizeMake(255.0, MAXFLOAT)
                                    lineBreakMode:NSLineBreakByWordWrapping];
    
    return labelSize.height + 26;
}

- (void)scrollViewDidScroll:(UIScrollView *)aScrollView {
    CGPoint offset = aScrollView.contentOffset;
    CGRect bounds = aScrollView.bounds;
    CGSize size = aScrollView.contentSize;
    UIEdgeInsets inset = aScrollView.contentInset;
    float y = offset.y + bounds.size.height - inset.bottom;
    float h = size.height;
    
    float reload_distance = -100;
    if(y > h + reload_distance) {
        [self loadNotify:NO];
    }
}

- (IBAction)switchTab:(UISegmentedControl *)sender {
    currentTab = sender.selectedSegmentIndex;
    [self reloadView];
}

- (IBAction)touchInfo:(id)sender {
    webAnnounce.hidden = NO;
    //tableNotify.hidden = YES;
    LatteAPIClient *api = [LatteAPIClient sharedClient];
    NSURLRequest* request = [api.requestSerializer requestWithMethod:@"GET"
                                                           URLString:[[NSURL URLWithString:@"user/announce" relativeToURL:api.baseURL] absoluteString]
                                                          parameters:nil
                                                               error:nil];
    [webAnnounce loadRequest:request];
}

- (IBAction)refresh:(id)sender {
    [self reloadView];
}

@end
