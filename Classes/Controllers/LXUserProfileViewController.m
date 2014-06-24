//
//  LXUserProfileViewController.m
//  Latte camera
//
//  Created by Bui Xuan Dung on 6/23/14.
//  Copyright (c) 2014 LUXEYS. All rights reserved.
//

#import "LXUserProfileViewController.h"
#import "LXAppDelegate.h"

@interface LXUserProfileViewController () {
    NSMutableSet *showSet;
    NSArray *showField;
    NSDictionary *userDict;

}

@end

@implementation LXUserProfileViewController

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
    
    showSet = [NSMutableSet setWithObjects:@"gender", @"residence", @"age", @"birthdate", @"bloodtype", @"occupation", @"introduction", @"hobby", @"nationality", nil];

    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}


- (void)setUser:(User *)user {
    _user = user;
    NSString *url = [NSString stringWithFormat:@"user/%ld", [_user.userId longValue]];
    [[LatteAPIClient sharedClient] GET:url
                            parameters: nil
                               success:^(AFHTTPRequestOperation *operation, NSDictionary *JSON) {
                                   userDict = [JSON objectForKey:@"user"];
                                   
                                   NSSet *allField = [NSSet setWithArray:[userDict allKeys]];
                                   
                                   [showSet intersectSet:allField];
                                   showField = [showSet allObjects];
                                   
                                   [self.tableView reloadData];
                               } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                   DLog(@"Something went wrong (Profile)");
                               }];
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
    return [showField count] + 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Profile" forIndexPath:indexPath];
    
    if (indexPath.row == showField.count) {
        cell.textLabel.text = @"URL";
        NSString * language = [[NSLocale preferredLanguages] objectAtIndex:0];
        if ([language isEqualToString:@"ja"]) {
            cell.detailTextLabel.text = [NSString stringWithFormat:@"http://latte.la/photo/%d", [_user.userId integerValue]];
        } else {
            cell.detailTextLabel.text = [NSString stringWithFormat:@"http://en.latte.la/photo/%d", [_user.userId integerValue]];
        }
        cell.detailTextLabel.highlighted = YES;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.selectionStyle = UITableViewCellSelectionStyleDefault;
        return cell;
    } else {
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.detailTextLabel.highlighted = NO;
    }
    
    NSString* strKey = [showField objectAtIndex:indexPath.row];
    if ([strKey isEqualToString:@"gender"]) {
        cell.textLabel.text = NSLocalizedString(@"gender", @"性別");
    } else if ([strKey isEqualToString:@"residence"]) {
        cell.textLabel.text = NSLocalizedString(@"current_residence", @"現住所");
    } else if ([strKey isEqualToString:@"hometown"]) {
        cell.textLabel.text = NSLocalizedString(@"hometown", @"出身地");
    } else if ([strKey isEqualToString:@"age"]) {
        cell.textLabel.text = NSLocalizedString(@"age", @"年齢");
    } else if ([strKey isEqualToString:@"birthdate"]) {
        cell.textLabel.text = NSLocalizedString(@"birthdate", @"誕生日");
    } else if ([strKey isEqualToString:@"bloodtype"]) {
        cell.textLabel.text = NSLocalizedString(@"bloodtype", @"血液型");
    } else if ([strKey isEqualToString:@"occupation"]) {
        cell.textLabel.text = NSLocalizedString(@"occupation", @"職業");
    } else if ([strKey isEqualToString:@"hobby"]) {
        cell.textLabel.text = NSLocalizedString(@"hobby", @"趣味");
    } else if ([strKey isEqualToString:@"introduction"]) {
        cell.textLabel.text = NSLocalizedString(@"introduction", @"自己紹介");
    } else if ([strKey isEqualToString:@"nationality"]) {
        cell.textLabel.text = NSLocalizedString(@"nationality", @"国籍");
    }
    
    if ([strKey isEqualToString:@"gender"]) {
        switch ([[userDict objectForKey:strKey] integerValue]) {
            case 1:
                cell.detailTextLabel.text = NSLocalizedString(@"male", @"男性");
                break;
            case 2:
                cell.detailTextLabel.text = NSLocalizedString(@"female", @"女性");
                break;
        }
    } else if ([strKey isEqualToString:@"nationality"]) {
        NSLocale *locale = [NSLocale currentLocale];
        NSString *countryCode = [userDict objectForKey:strKey];
        NSString *displayNameString = [locale displayNameForKey:NSLocaleCountryCode value:countryCode];
        cell.detailTextLabel.text = displayNameString;
    } else {
        cell.detailTextLabel.text = [userDict objectForKey:strKey];
    }
    
//    CGRect frame = cell.detailTextLabel.frame;
//    CGSize size = [cell.detailTextLabel.text sizeWithFont:cell.labelDetail.font
//                                    constrainedToSize:CGSizeMake(212.0, CGFLOAT_MAX)
//                                        lineBreakMode:NSLineBreakByWordWrapping];
//    frame.size.height = size.height;
//    cell.labelDetail.frame = frame;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == showField.count) {
        return 44;
    }
    NSString* strKey = [showField objectAtIndex:indexPath.row];
    
    if ([strKey isEqualToString:@"hobby"] || [strKey isEqualToString:@"introduction"]) {
        CGSize size = [[userDict objectForKey:strKey] sizeWithFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:14.0]
                                                 constrainedToSize:CGSizeMake(153.0, CGFLOAT_MAX)
                                                     lineBreakMode:NSLineBreakByWordWrapping];
        return size.height + 27;
    } else {
        return 44;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == showField.count) {
        NSString * language = [[NSLocale preferredLanguages] objectAtIndex:0];
        if ([language isEqualToString:@"ja"]) {
            NSString *url = [NSString stringWithFormat:@"http://latte.la/photo/%d", [_user.userId integerValue]];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
        } else {
            NSString *url = [NSString stringWithFormat:@"http://en.latte.la/photo/%d", [_user.userId integerValue]];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
        }
    }
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
