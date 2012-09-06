//
//  luxeysUserViewController.m
//  Latte
//
//  Created by Xuan Dung Bui on 8/20/12.
//  Copyright (c) 2012 LUXEYS. All rights reserved.
//

#import "luxeysUserViewController.h"
#import "UIImageView+AFNetworking.h"
#import "luxeysLatteAPIClient.h"
#import "luxeysAppDelegate.h"
#import "luxeysCellProfile.h"

@interface luxeysUserViewController () {
@private
    NSMutableSet *showSet;
    NSArray *showField;
    NSDictionary *userDetail;
}
@end

@implementation luxeysUserViewController
@synthesize buttonVoteCount;
@synthesize buttonPhotoCount;
@synthesize buttonFriendCount;
@synthesize viewScroll;
@synthesize imageUser;
@synthesize viewStats;
@synthesize viewContent;
@synthesize dictUser;
@synthesize buttonProfile;
@synthesize buttonCalendar;
@synthesize buttonMap;
@synthesize tableProfile;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    // Style
    showSet = [NSMutableSet setWithObjects:@"gender", @"residence", @"age", @"birthdate", @"bloodtype", @"occupation", @"introduction", @"hobby", nil];
    
    UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:imageUser.bounds];
    imageUser.layer.masksToBounds = NO;
    imageUser.layer.shadowColor = [UIColor blackColor].CGColor;
    imageUser.layer.shadowOffset = CGSizeMake(0.0f, 1.0f);
    imageUser.layer.shadowOpacity = 1.0f;
    imageUser.layer.shadowRadius = 1.0f;
    imageUser.layer.shadowPath = shadowPath.CGPath;

    UIBezierPath *shadowPath2 = [UIBezierPath bezierPathWithRect:tableProfile.bounds];
    tableProfile.layer.masksToBounds = NO;
    tableProfile.layer.shadowColor = [UIColor blackColor].CGColor;
    tableProfile.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
    tableProfile.layer.shadowOpacity = 0.5f;
    tableProfile.layer.shadowRadius = 2.0f;
    tableProfile.layer.shadowPath = shadowPath2.CGPath;
    
    self.viewScroll.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg_sub_back.png"]];
    
    // Data
    [self.imageUser setImageWithURL:[NSURL URLWithString:[dictUser objectForKey:@"profile_picture"]]];
    [self.navigationItem setTitle:[dictUser objectForKey:@"name"]];
    
    luxeysAppDelegate* app = (luxeysAppDelegate*)[[UIApplication sharedApplication] delegate];
    
    NSString* strURL = [NSString stringWithFormat:@"api/user/%d", [[dictUser objectForKey:@"id"] integerValue]];
    [[luxeysLatteAPIClient sharedClient] getPath:strURL
                                      parameters: [NSDictionary dictionaryWithObjectsAndKeys:[app getToken], @"token", nil]
                                         success:^(AFHTTPRequestOperation *operation, NSDictionary *JSON) {
                                             userDetail = [JSON objectForKey:@"user"];
                                             [buttonFriendCount setTitle:[[userDetail objectForKey:@"count_friends"] stringValue] forState:UIControlStateNormal];
                                             [buttonPhotoCount setTitle:[[userDetail objectForKey:@"count_pictures"] stringValue] forState:UIControlStateNormal];
                                             [buttonVoteCount setTitle:[[userDetail objectForKey:@"vote_count"] stringValue] forState:UIControlStateNormal];
                                             
                                             NSSet *allField = [NSSet setWithArray:[userDetail allKeys]];
                                             [showSet intersectSet:allField];
                                             showField = [showSet allObjects];
                                             [tableProfile reloadData];
                                             
                                             CGRect frame = tableProfile.frame;
                                             frame.size = tableProfile.contentSize;
                                             tableProfile.frame = frame;
                                             
                                             viewScroll.contentSize = CGSizeMake(320, viewStats.frame.size.height + tableProfile.contentSize.height);
                                         }
                                         failure:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setImageUser:nil];
    [self setViewStats:nil];
    [self setViewContent:nil];
    [self setButtonProfile:nil];
    [self setButtonCalendar:nil];
    [self setButtonMap:nil];
    [self setViewScroll:nil];
    [self setTableProfile:nil];
    [self setButtonVoteCount:nil];
    [self setButtonPhotoCount:nil];
    [self setButtonFriendCount:nil];
    [super viewDidUnload];
}

- (IBAction)touchTab:(UIButton *)sender {
    sender.enabled = NO;
    switch (sender.tag) {
        case 1:
            buttonCalendar.enabled = YES;
            buttonMap.enabled = YES;
            break;
        case 2:
            buttonProfile.enabled = YES;
            buttonMap.enabled = YES;
            break;
        case 3:
            buttonCalendar.enabled = YES;
            buttonProfile.enabled = YES;
            break;
    }
}

- (IBAction)touchBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [showField count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Profile";
    luxeysCellProfile *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    NSString* strKey = [showField objectAtIndex:indexPath.row];
    if ([strKey isEqualToString:@"gender"]) {
        cell.labelField.text = @"性別";
    } else if ([strKey isEqualToString:@"residence"]) {
        cell.labelField.text = @"現住所";
    } else if ([strKey isEqualToString:@"hometown"]) {
        cell.labelField.text = @"出身地";
    } else if ([strKey isEqualToString:@"age"]) {
        cell.labelField.text = @"年齢";
    } else if ([strKey isEqualToString:@"birthdate"]) {
        cell.labelField.text = @"誕生日";
    } else if ([strKey isEqualToString:@"bloodtype"]) {
        cell.labelField.text = @"血液型";
    } else if ([strKey isEqualToString:@"occupation"]) {
        cell.labelField.text = @"職業";
    } else if ([strKey isEqualToString:@"hobby"]) {
        cell.labelField.text = @"趣味";
    } else if ([strKey isEqualToString:@"introduction"]) {
        cell.labelField.text = @"自己紹介";
    }
    
    cell.labelDetail.text = [userDetail objectForKey:strKey];
    
    return cell;
}

- (IBAction)touchVoteCount:(id)sender {
}

- (IBAction)touchPicCount:(id)sender {
}

- (IBAction)touchFriendCount:(id)sender {
}
@end
