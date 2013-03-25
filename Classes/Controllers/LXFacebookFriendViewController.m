//
//  LXFacebookFriendViewController.m
//  Latte camera
//
//  Created by Bui Xuan Dung on 3/12/13.
//  Copyright (c) 2013 LUXEYS. All rights reserved.
//

#import "LXFacebookFriendViewController.h"
#import "LXAppDelegate.h"
#import "LXCellFacebook.h"
#import "LXMyPageViewController.h"
#import "LXButtonBack.h"

@interface LXFacebookFriendViewController ()

@end

@implementation LXFacebookFriendViewController {
    NSMutableArray *fbfriends;
}

@synthesize activityLoad;

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
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    self.tableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg_sub_back.png"]];
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(sessionStateChanged:)
     name:FBSessionStateChangedNotification
     object:nil];
    
    LXAppDelegate *app = [LXAppDelegate currentDelegate];
    if (FBSession.activeSession.isOpen) {
        [self loadFacebokFriend];
    } else {
        [app openSessionWithAllowLoginUI:YES];
    }
    
    UIBarButtonItem *navLeftItem = self.navigationItem.leftBarButtonItem;
    LXButtonBack *buttonBack = (LXButtonBack*)navLeftItem.customView;
    [buttonBack addTarget:self.navigationController action:@selector(popViewControllerAnimated:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)loadFacebokFriend {
    FBSession *fbsession = FBSession.activeSession;
    
    FBRequest *fbrequest = [[FBRequest alloc]initWithSession:fbsession
                                                   graphPath:@"me/friends"
                                                  parameters:[NSDictionary dictionaryWithObject:@"id,name,installed" forKey:@"fields"]
                                                  HTTPMethod:@"GET"];
    [fbrequest startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        [activityLoad stopAnimating];
        
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
                                               [self.tableView reloadData];
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
        [activityLoad stopAnimating];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return fbfriends.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"FacebookFriend";
    LXCellFacebook *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    cell.parent = self;
    cell.user = fbfriends[indexPath.row];
    
    return cell;
}

- (void)showUser:(User*)user {
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"MainStoryboard"
                                                             bundle:nil];
    LXMyPageViewController *viewUserPage = [mainStoryboard instantiateViewControllerWithIdentifier:@"UserPage"];
    viewUserPage.user = user;
    [self.navigationController pushViewController:viewUserPage animated:YES];
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 52;
}



@end
