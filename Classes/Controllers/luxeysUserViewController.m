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
#import "luxeysPicDetailViewController.h"

@interface luxeysUserViewController () {
@private
    NSMutableSet *showSet;
    NSArray *showField;
    NSArray *friends;
    NSArray *photos;
    NSDictionary *userDetail;
    int tableMode;
}
@end

@implementation luxeysUserViewController
@synthesize buttonVoteCount;
@synthesize buttonPhotoCount;
@synthesize buttonFriendCount;
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

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    
    tableMode = 1;
    
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

    // UIBezierPath *shadowPath2 = [UIBezierPath bezierPathWithRect:tableProfile.bounds];
    // tableProfile.layer.masksToBounds = NO;
    // tableProfile.layer.shadowColor = [UIColor blackColor].CGColor;
    // tableProfile.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
    // tableProfile.layer.shadowOpacity = 0.5f;
    // tableProfile.layer.shadowRadius = 2.0f;
    // tableProfile.layer.shadowPath = shadowPath2.CGPath;
    
    viewStats.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg_sub_back.png"]];
    
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
                                         }
                                         failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                            NSLog(@"Something went wrong (User - Profile)");
                                         }];
    
    NSString* urlFriends = [NSString stringWithFormat:@"api/user/%d/friend", [[dictUser objectForKey:@"id"] integerValue]];
    [[luxeysLatteAPIClient sharedClient] getPath:urlFriends
                                      parameters: [NSDictionary dictionaryWithObjectsAndKeys:[app getToken], @"token", nil]
                                         success:^(AFHTTPRequestOperation *operation, NSDictionary *JSON) {
                                             friends = [JSON objectForKey:@"friends"];

                                         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                            NSLog(@"Something went wrong (User - Friendlist)");
                                         }];

    NSString* urlPhotos = [NSString stringWithFormat:@"api/picture/user/%d", [[dictUser objectForKey:@"id"] integerValue]];
    [[luxeysLatteAPIClient sharedClient] getPath:urlPhotos
                                      parameters: [NSDictionary dictionaryWithObjectsAndKeys:[app getToken], @"token", nil]
                                         success:^(AFHTTPRequestOperation *operation, NSDictionary *JSON) {
                                             photos = [JSON objectForKey:@"pictures"];

                                         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                            NSLog(@"Something went wrong (User - Photolist)");
                                         }];
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
    [self setTableProfile:nil];
    [self setButtonVoteCount:nil];
    [self setButtonPhotoCount:nil];
    [self setButtonFriendCount:nil];
    [super viewDidUnload];
}

- (void)switchProfile {
    //tableProfile.style = UITableViewStyleGrouped;
    buttonCalendar.enabled = YES;
    buttonMap.enabled = YES;
    buttonVoteCount.enabled = YES;
    buttonPhotoCount.enabled = YES;
    buttonFriendCount.enabled = YES;
}

- (void)switchCalendar {
    buttonProfile.enabled = YES;
    buttonMap.enabled = YES;
    buttonVoteCount.enabled = YES;
    buttonPhotoCount.enabled = YES;
    buttonFriendCount.enabled = YES;
}

- (void)switchMap {
    buttonCalendar.enabled = YES;
    buttonProfile.enabled = YES;
    buttonVoteCount.enabled = YES;
    buttonPhotoCount.enabled = YES;
    buttonFriendCount.enabled = YES;
}

- (void)switchVote {
    buttonCalendar.enabled = YES;
    buttonProfile.enabled = YES;
    buttonMap.enabled = YES;
    buttonPhotoCount.enabled = YES;
    buttonFriendCount.enabled = YES;
}

- (void)switchFriend {
    buttonProfile.enabled = YES;
    buttonCalendar.enabled = YES;
    buttonProfile.enabled = YES;
    buttonVoteCount.enabled = YES;
    buttonPhotoCount.enabled = YES;
}

- (void)switchPhoto {
    buttonProfile.enabled = YES;
    buttonCalendar.enabled = YES;
    buttonProfile.enabled = YES;
    buttonVoteCount.enabled = YES;
    buttonFriendCount.enabled = YES;
}

- (IBAction)touchTab:(UIButton *)sender {
    sender.enabled = NO;
    tableMode = sender.tag;
    switch (sender.tag) {
        case 1:
            [self switchProfile];
            break;
        case 2:
            [self switchCalendar];
            break;
        case 3:
            [self switchMap];
            break;
        case 4:
            [self switchVote];
            break;
        case 5:
            [self switchPhoto];
            break;
        case 6:
            [self switchFriend];
            break;
    }
    [tableProfile reloadData];
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
    if (tableMode == 1)
    {
        return [showField count];
    } else if (tableMode == 5) {
        return (photos.count/4) + (photos.count%4>0?1:0);
    } else {
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableMode == 1)
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
    } else if (tableMode == 5) {
        UITableViewCell *cellPic = [[UITableViewCell alloc] init];
        for (int i = 0; i < 4; ++i)
        {
            NSInteger index = indexPath.row*4+i;
            if (index < photos.count) {
                NSDictionary *pic = [photos objectAtIndex:index];

                UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(10+(i*77), 10, 67, 67)];
                NSURLRequest *theRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:[pic objectForKey:@"url_square"]]
                                                            cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                        timeoutInterval:60.0];
                
                UIImageView* imageFirst = [[UIImageView alloc] init];
                [imageFirst setImageWithURLRequest:theRequest
                                  placeholderImage:nil
                                           success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                               [button setBackgroundImage:image forState:UIControlStateNormal];
                                           }
                                           failure:nil
                 ];
                button.tag = index;
                [button addTarget:self action:@selector(showPhoto:) forControlEvents:UIControlEventTouchUpInside];
                [cellPic addSubview:button];
            }
        }
        return cellPic;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableMode == 1)
    {
        return 50;
    } else if (tableMode == 5) {
        return 78;
    }
}

- (void)showPhoto:(UIButton*)sender {
    [self performSegueWithIdentifier:@"PictureDetail" sender:[photos objectAtIndex:sender.tag]];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"PictureDetail"]) {
        luxeysPicDetailViewController* viewPicDetail = segue.destinationViewController;
        viewPicDetail.picInfo = sender;
    }
}

@end
