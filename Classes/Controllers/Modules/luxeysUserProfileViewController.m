//
//  luxeysUserProfileViewController.m
//  Latte
//
//  Created by Xuan Dung Bui on 8/27/12.
//  Copyright (c) 2012 LUXEYS. All rights reserved.
//

#import "luxeysUserProfileViewController.h"
#import "luxeysCellProfile.h"

@interface luxeysUserProfileViewController ()

@end

@implementation luxeysUserProfileViewController

@synthesize arData;

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
    self.tableView.backgroundColor = [UIColor whiteColor];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [arData count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Profile";
    luxeysCellProfile *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    NSDictionary* dictData = [arData objectAtIndex:indexPath.row];
    NSString* strKey = [dictData objectForKey:@"key"];
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
    
    cell.labelDetail.text = [dictData objectForKey:@"value"];
    
    // Configure the cell...
    
    return cell;
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
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
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

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView* tmp = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    return tmp;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

@end
