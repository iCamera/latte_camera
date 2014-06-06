//
//  LXTableSettingItemViewController.m
//  Latte camera
//
//  Created by Juan Tabares on 6/5/14.
//  Copyright (c) 2014 LUXEYS. All rights reserved.
//

#import "LXTableSettingItemViewController.h"
#import "LatteAPIClient.h"
#import "LXAppDelegate.h"
#import "User.h"

@interface LXTableSettingItemViewController ()

@end

@implementation LXTableSettingItemViewController

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
    self.tableView.delegate = self;
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setPrivacy:(LXPrivacySettingTableViewCell *)privacy
{
    _privacy = privacy;
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 4;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return self.privacy.textLabel.text;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"PrivacySettingItem"];
    BOOL is_selected = FALSE;
    PictureStatus currentPermission = self.privacy.permissionStatus;
    if (indexPath.row == 0) {
        cell.textLabel.text = NSLocalizedString(@"status_private", @"Only Me");
        if(currentPermission == PictureStatusPrivate) is_selected = TRUE;
    } else if (indexPath.row == 1) {
        cell.textLabel.text = NSLocalizedString(@"status_friends", @"Mutual Follow");
        if(currentPermission == PictureStatusFriendsOnly) is_selected = TRUE;
    } else if (indexPath.row == 2) {
        cell.textLabel.text = NSLocalizedString(@"status_members", @"Members");
        if(currentPermission == PictureStatusMember) is_selected = TRUE;
    } else if (indexPath.row == 3) {
        cell.textLabel.text = NSLocalizedString(@"status_public", @"Public");
        if(currentPermission == PictureStatusPublic) is_selected = TRUE;
    }
    cell.accessoryType = UITableViewCellAccessoryNone;
    if (is_selected) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    PictureStatus newPermission = PictureStatusPrivate;
    if (indexPath.row == 1) {
        newPermission = PictureStatusFriendsOnly;
    } else if (indexPath.row == 2) {
        newPermission = PictureStatusMember;
    } else if (indexPath.row == 3) {
        newPermission = PictureStatusPublic;
    }
    if (newPermission != self.privacy.permissionStatus) {
        self.privacy.currentSetting = [[NSNumber alloc] initWithInt:newPermission];
        [self.tableView reloadData];
        [self updatePermission];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)updatePermission
{
    [User updatePermission:self.privacy.currentSetting
                 forObject:self.privacy.key success:^(NSDictionary *JSON) {
                     LXAppDelegate* app = [LXAppDelegate currentDelegate];
                     app.currentUser = [User instanceFromDictionary:[JSON objectForKey:@"user"]];
                     [self.navigationController popViewControllerAnimated:YES];
                 } failure:^(NSError *error) {
                     UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"error", "Error")
                                                                     message:error.localizedDescription
                                                                    delegate:nil
                                                           cancelButtonTitle:NSLocalizedString(@"close", "Close")
                                                           otherButtonTitles:nil];
                     [alert show];
                 }
     ];
}

@end
