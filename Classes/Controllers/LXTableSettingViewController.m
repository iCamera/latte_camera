//
//  LXSettingTableViewController.m
//  Latte camera
//
//  Created by Juan Tabares on 6/4/14.
//  Copyright (c) 2014 LUXEYS. All rights reserved.
//

#import "LXTableSettingViewController.h"
#import "LXPrivacySettingTableViewCell.h"
#import "LXAppDelegate.h"
#import "LatteAPIClient.h"
#import "User.h"


@interface LXTableSettingViewController ()
@property (strong, nonatomic) User *user;
@property (nonatomic) BOOL forceReload;
@end

@implementation LXTableSettingViewController
@synthesize user;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    self.forceReload = NO;
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self refreshUserSettings];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (self.forceReload)
        [self refreshUserSettings];
}

- (void)refreshUserSettings
{
    LXAppDelegate* app = (LXAppDelegate*)[UIApplication sharedApplication].delegate;
    self.user = app.currentUser;
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"OpenPrivacySetting"]){
        if([segue.destinationViewController respondsToSelector:@selector(setPrivacy:)]) {
            self.forceReload = YES;
            LXPrivacySettingTableViewCell *cell = (LXPrivacySettingTableViewCell *)sender;
            [segue.destinationViewController performSelector:@selector(setPrivacy:)
                                                  withObject:cell];
        }
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (!self.user)
        return 0;
    return 2;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if(section == 0) {
        return NSLocalizedString(@"Profile Privacy Settings", @"Profile Privacy Settings");
    } else if (section == 1) {
        return NSLocalizedString(@"Photo Privacy Settings", @"Photo Privacy Settings");
    }
    return @"";
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (!self.user)
        return 0;
    if(section == 0) {
        return 7;
    } else if (section == 1) {
        return 5;
    }
    return 0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    LXPrivacySettingTableViewCell *cell = (LXPrivacySettingTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"PrivacySettingCell"];

    NSString *title = @"";
    NSNumber *currentPermission = [[NSNumber alloc] initWithInt:0];
    NSString *key = @"";
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            title = NSLocalizedString(@"gender", @"Gender");
            currentPermission = user.genderPublic;
            key = @"gender_public";
        } else if (indexPath.row == 1) {
            title = NSLocalizedString(@"bloodtype", @"Blood type");
            currentPermission = user.bloodTypePublic;
            key = @"bloodtype_public";
        } else if (indexPath.row == 2) {
            title = NSLocalizedString(@"current_residence", @"Current address");
            currentPermission = user.currentResidencePublic;
            key = @"current_residence_public";
        } else if (indexPath.row == 3) {
            title = NSLocalizedString(@"hometown", @"Hometown");
            currentPermission = user.hometownPublic;
            key = @"hometown_public";
        } else if (indexPath.row == 4) {
            title = NSLocalizedString(@"age", @"Age");
            currentPermission = user.birthyearPublic;
            key = @"birthyear_public";
        } else if (indexPath.row == 5) {
            title = NSLocalizedString(@"birthdate", @"Birthday");
            currentPermission = user.birthdatePublic;
            key = @"birthdate_public";
        } else if (indexPath.row == 6) {
            title = NSLocalizedString(@"nationality", @"Nationality");
            currentPermission = user.nationalityPublic;
            key = @"nationality_public";
        }
    } else {
        if (indexPath.row == 0) {
            title = NSLocalizedString(@"Photo", @"Photo");
            currentPermission = [[NSNumber alloc] initWithInt:(int)user.pictureStatus];
            key = @"picture_status";
        } else if (indexPath.row == 1) {
            title = NSLocalizedString(@"Show taken date", @"Show taken date");
            currentPermission = [[NSNumber alloc] initWithInt:(int)user.defaultShowTakenAt];
            key = @"default_show_taken_at";
        } else if (indexPath.row == 2) {
            title = NSLocalizedString(@"Show camera EXIF", @"Show camera EXIF");
            currentPermission = [[NSNumber alloc] initWithInt:user.defaultShowEXIF];
            key = @"default_show_exif";
        } else if (indexPath.row == 3) {
            title = NSLocalizedString(@"Show location", @"Show location");
            currentPermission = [[NSNumber alloc] initWithInt:user.defaultShowGPS];
            key = @"default_show_gps";
        } else if (indexPath.row == 4) {
            title = NSLocalizedString(@"Show original file", @"Show original file");
            currentPermission = [[NSNumber alloc] initWithInt:user.defaultShowLarge];
            key = @"default_show_large";
        }
    }
    cell.textLabel.text = title;
    cell.currentSetting = currentPermission;
    cell.key = key;
    return cell;
}


-(void)refreshList
{
    HUD = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:HUD];
    HUD.mode = MBProgressHUDModeIndeterminate;
    [HUD show:YES];
    
    LXAppDelegate* app = (LXAppDelegate*)[UIApplication sharedApplication].delegate;
    NSDictionary *params = [NSDictionary dictionaryWithObject:[app getToken] forKey:@"token"];


    [[LatteAPIClient sharedClient] GET:@"user/me" parameters:params  success:^(AFHTTPRequestOperation *operation, NSDictionary *JSON) {
        NSMutableDictionary *userDict = [NSMutableDictionary dictionaryWithDictionary:[JSON objectForKey:@"user"]];
        if ([userDict objectForKey:@"current_residence"] == nil) {
            [userDict setObject:@"" forKey:@"current_residence"];
        }
        if ([userDict objectForKey:@"hometown"] == nil) {
            [userDict setObject:@"" forKey:@"hometown"];
        }
        NSLog(@"%@", userDict);
        [self.tableView reloadData];
        [HUD hide:YES];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [HUD hide:YES];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"error", "Error")
                                                                                      message:error.localizedDescription
                                                                                     delegate:nil
                                                                            cancelButtonTitle:NSLocalizedString(@"close", "Close")
                                                                            otherButtonTitles:nil];
        [alert show];
    }];
}


@end
