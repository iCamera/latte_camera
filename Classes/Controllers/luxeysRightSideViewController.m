//
//  luxeysRightSideViewController.m
//  Latte
//
//  Created by Xuan Dung Bui on 8/17/12.
//  Copyright (c) 2012 LUXEYS. All rights reserved.
//

#import "luxeysRightSideViewController.h"
#import "luxeysAppDelegate.h"
#import "luxeysLatteAPIClient.h"
#import "luxeysCellFriendRequest.h"
#import "UIImageView+AFNetworking.h"
#import "luxeysUserViewController.h"

@interface luxeysRightSideViewController () {
    NSMutableArray *notifies;
    NSArray *requests;
    NSArray *ignores;
    int tableMode;
    int page;
    int limit;
}

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
        tableMode = 1;
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
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
        UITableViewCell* cellSingle = [tableView dequeueReusableCellWithIdentifier:@"Notify"];
        return cellSingle;
    } else {
        luxeysAppDelegate* app = (luxeysAppDelegate*)[UIApplication sharedApplication].delegate;
        
        if (indexPath.section == 0) {
            luxeysCellFriendRequest *cellRequest = [tableView dequeueReusableCellWithIdentifier:@"Request"];
            NSDictionary *user = [requests objectAtIndex:indexPath.row];
            cellRequest.userName.text = [user objectForKey:@"name"];

            NSURLRequest *theRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:[user objectForKey:@"profile_picture"]]
                                                            cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                        timeoutInterval:60.0];
                
            UIImageView* imageFirst = [[UIImageView alloc] init];
            [imageFirst setImageWithURLRequest:theRequest
                              placeholderImage:nil
                                       success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                               [cellRequest.buttonProfile setBackgroundImage:image forState:UIControlStateNormal];
                                           }
                                       failure:nil
            ];
            
            cellRequest.buttonProfile.tag = indexPath.row;
            
            [cellRequest.buttonAdd addTarget:self action:@selector(addRequest:) forControlEvents:UIControlEventTouchUpInside];
            [cellRequest.buttonIgnore addTarget:self action:@selector(ingoreRequest:) forControlEvents:UIControlEventTouchUpInside];
            [cellRequest.buttonProfile addTarget:self action:@selector(showRequestUser:) forControlEvents:UIControlEventTouchUpInside];
            [cellRequest.buttonProfile addTarget:app.storyMain action:@selector(revealRight:) forControlEvents:UIControlEventTouchUpInside];
            
            return cellRequest;
        } else {
            luxeysCellFriendRequest *cellIgnore = [tableView dequeueReusableCellWithIdentifier:@"Ignore"];
            NSDictionary *user = [ignores objectAtIndex:indexPath.row];
            cellIgnore.userName.text = [user objectForKey:@"name"];
            
            NSURLRequest *theRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:[user objectForKey:@"profile_picture"]]
                                                        cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                    timeoutInterval:60.0];
            
            UIImageView* imageFirst = [[UIImageView alloc] init];
            [imageFirst setImageWithURLRequest:theRequest
                              placeholderImage:nil
                                       success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                           [cellIgnore.buttonProfile setBackgroundImage:image forState:UIControlStateNormal];
                                       }
                                       failure:nil
             ];
            
            return cellIgnore;
        }
    }
}

- (void)receiveLoggedIn:(NSNotification *) notification {
    luxeysAppDelegate* app = (luxeysAppDelegate*)[UIApplication sharedApplication].delegate;
    [[luxeysLatteAPIClient sharedClient] getPath:@"api/user/me/notify"
                                     parameters: [NSDictionary dictionaryWithObjectsAndKeys:
                                                  [app getToken], @"token",
                                                  nil]
                                        success:^(AFHTTPRequestOperation *operation, NSDictionary *JSON) {
                                            //[tableNotify reloadData];
                                        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                            NSLog(@"Something went wrong (Notify)");
                                        }];
    
    [[luxeysLatteAPIClient sharedClient] getPath:@"api/user/me/friendrequest"
                                      parameters: [NSDictionary dictionaryWithObjectsAndKeys:
                                                   [app getToken], @"token",
                                                   nil]
                                         success:^(AFHTTPRequestOperation *operation, NSDictionary *JSON) {
                                             requests = [JSON objectForKey:@"requests"];
                                             ignores = [JSON objectForKey:@"ignores"];
                                         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                             NSLog(@"Something went wrong (Notify)");
                                         }];
}

- (IBAction)touchTab:(UISegmentedControl*)sender {
    tableMode = sender.selectedSegmentIndex;
    [tableNotify reloadData];
}

- (void)addRequest:(id)sender {
    
}

- (void)ingoreRequest:(id)sender {
    
}

- (void)showRequestUser:(UIButton*)sender {
    luxeysAppDelegate* app = (luxeysAppDelegate*)[UIApplication sharedApplication].delegate;
    
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"MainStoryboard"
                                                             bundle:nil];
    luxeysUserViewController *viewUser = [mainStoryboard instantiateViewControllerWithIdentifier:@"UserProfile"];
    viewUser.dictUser = [requests objectAtIndex:sender.tag];
    UINavigationController *nav = (id)app.viewMainTab.selectedViewController;
    [nav pushViewController:viewUser animated:YES];
}

@end
