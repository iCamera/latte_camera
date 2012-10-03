//
//  luxeysUserViewController.m
//  Latte
//
//  Created by Xuan Dung Bui on 8/20/12.
//  Copyright (c) 2012 LUXEYS. All rights reserved.
//

#import "luxeysUserViewController.h"

@interface luxeysUserViewController () 
@end

@implementation luxeysUserViewController
@synthesize buttonVoteCount;
@synthesize buttonPhotoCount;
@synthesize buttonFriendCount;
@synthesize imageUser;
@synthesize viewStats;
@synthesize viewContent;
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
    
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = CGRectMake(0, 120, 320, 10);
    gradient.colors = [NSArray arrayWithObjects:
                       (id)[[UIColor clearColor] CGColor],
                       (id)[[[UIColor blackColor] colorWithAlphaComponent:0.2f] CGColor],
                       nil];
    [viewStats.layer insertSublayer:gradient atIndex:0];
    
    viewStats.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg_sub_back.png"]];
    
    // Data
    
    luxeysAppDelegate* app = (luxeysAppDelegate*)[[UIApplication sharedApplication] delegate];
    
    NSString* strURL = [NSString stringWithFormat:@"api/user/%d", userID];
    [[luxeysLatteAPIClient sharedClient] getPath:strURL
                                      parameters: [NSDictionary dictionaryWithObjectsAndKeys:[app getToken], @"token", nil]
                                         success:^(AFHTTPRequestOperation *operation, NSDictionary *JSON) {
                                             userDict = [JSON objectForKey:@"user"];
                                             user =  [LuxeysUser instanceFromDictionary:userDict];
                                             [self.navigationItem setTitle:user.name];
                                             [buttonFriendCount setTitle:[user.countFriends stringValue] forState:UIControlStateNormal];
                                             [buttonPhotoCount setTitle:[user.countPictures stringValue] forState:UIControlStateNormal];
                                             [buttonVoteCount setTitle:[user.voteCount stringValue] forState:UIControlStateNormal];
                                             
                                             [self.imageUser setImageWithURL:[NSURL URLWithString:user.profilePicture]];
                                             
                                             NSSet *allField = [NSSet setWithArray:[userDict allKeys]];
                                             [showSet intersectSet:allField];
                                             showField = [showSet allObjects];
                                             [tableProfile reloadData];
                                         }
                                         failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                            NSLog(@"Something went wrong (User - Profile)");
                                         }];
    
    NSString* urlFriends = [NSString stringWithFormat:@"api/user/%d/friend", userID];
    [[luxeysLatteAPIClient sharedClient] getPath:urlFriends
                                      parameters: [NSDictionary dictionaryWithObjectsAndKeys:[app getToken], @"token", nil]
                                         success:^(AFHTTPRequestOperation *operation, NSDictionary *JSON) {
                                             friends = [JSON objectForKey:@"friends"];

                                         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                            NSLog(@"Something went wrong (User - Friendlist)");
                                         }];

    NSString* urlPhotos = [NSString stringWithFormat:@"api/picture/user/%d", userID];
    [[luxeysLatteAPIClient sharedClient] getPath:urlPhotos
                                      parameters: [NSDictionary dictionaryWithObjectsAndKeys:[app getToken], @"token", nil]
                                         success:^(AFHTTPRequestOperation *operation, NSDictionary *JSON) {
                                             photos = [LuxeysPicture mutableArrayFromDictionary:JSON withKey:@"pictures"];

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
        
        if ([strKey isEqualToString:@"gender"]) {
            cell.labelDetail.text = [[userDict objectForKey:strKey] stringValue];
        } else {
            cell.labelDetail.text = [userDict objectForKey:strKey];
        }
        
        
        return cell;
    } else if (tableMode == 5) {
        UITableViewCell *cellPic = [[UITableViewCell alloc] init];
        for (int i = 0; i < 4; ++i)
        {
            NSInteger index = indexPath.row*4+i;
            if (index < photos.count) {
                LuxeysPicture *pic = [photos objectAtIndex:index];

                UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(10+(i*77), 10, 67, 67)];

                [button loadBackground:pic.urlSquare];
                button.tag = [pic.pictureId longValue];
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
    [self performSegueWithIdentifier:@"PictureDetail" sender:sender];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(UIButton *)sender {
    if ([segue.identifier isEqualToString:@"PictureDetail"]) {
        luxeysPicDetailViewController* viewPicDetail = segue.destinationViewController;
        [viewPicDetail setPictureID:sender.tag];
    }
}

- (void)setUserID:(int)aUserID {
    userID = aUserID;
}

@end
