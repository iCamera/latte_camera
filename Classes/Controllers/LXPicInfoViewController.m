//
//  luxeysPicInfoViewController.m
//  Latte
//
//  Created by Xuan Dung Bui on 9/7/12.
//  Copyright (c) 2012 LUXEYS. All rights reserved.
//

#import "LXPicInfoViewController.h"
#import "LXCellInfoTag.h"
#import "LXCellDataField.h"
#import "LatteAPIClient.h"
#import "UIImageView+AFNetworking.h"
#import "LXAppDelegate.h"
#import "AFNetworking.h"
#import "LatteAPIClient.h"

@interface LXPicInfoViewController ()
@end

@implementation LXPicInfoViewController {
    NSMutableArray *keyBasic;
    NSArray *keyExif;
    NSInteger sections;
}

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
    
    self.tableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg_sub_back.png"]];
}

- (void)viewWillAppear:(BOOL)animated {
    [self render];
}

- (void)render {
    keyBasic = [[NSMutableArray alloc] init];
    if (_picture.takenAt) {
        [keyBasic addObject:@"taken_at"];
    }
    if (_picture.createdAt) {
        [keyBasic addObject:@"created_at"];
    }
    if (_picture.tagsOld.count > 0) {
        [keyBasic addObject:@"tags"];
    }
    
    sections = 1;
    
    if (_picture.exif.count > 0) {
        sections += 1;
        keyExif = [_picture.exif allKeys];
    }
    
    [self.tableView reloadData];
}

- (void)setPicture:(Picture *)picture {
    _picture = picture;
    [self render];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (IBAction)touchReport:(id)sender {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"report", @"")
                                                    message:NSLocalizedString(@"report_confirm", @"")
                                                   delegate:self
                                          cancelButtonTitle:NSLocalizedString(@"cancel", @"")
                                          otherButtonTitles:NSLocalizedString(@"report", @"report"), nil];
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        NSString *path = [NSString stringWithFormat:@"user/report_abuse/%@/%d", @"picture", [_picture.pictureId integerValue]];
        
        [[LatteAPIClient sharedClient] postPath:path
                                     parameters:nil
                                        success:nil
                                        failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                            NSLog(@"[HTTPClient Error]: %@", error.localizedDescription);
                                        }];
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 1)
    {
        return keyExif.count;
    }
    return [keyBasic count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0)
        if ([[keyBasic objectAtIndex:indexPath.row] isEqualToString:@"tags"]) {
            LXCellInfoTag *cellTag = [tableView dequeueReusableCellWithIdentifier:@"Tag"];
            cellTag.tags = _picture.tagsOld;
            cellTag.parent = _parent;
            return cellTag;
        }
    
    LXCellDataField *cell = [tableView dequeueReusableCellWithIdentifier:@"Profile"];
    cell.imageHide.hidden = YES;
    if (indexPath.section == 0)
    {
        NSString *key = [keyBasic objectAtIndex:indexPath.row];
        if ([key isEqualToString:@"taken_at"]) {
            if (_picture.isOwner) {
                cell.imageHide.hidden = _picture.showTakenAt;
            }
            
            cell.labelField.text = NSLocalizedString(@"taken_date", @"撮影月日") ;
            cell.labelDetail.text = [LXUtils dateToString:_picture.takenAt];
        }
        if ([[keyBasic objectAtIndex:indexPath.row] isEqualToString:@"created_at"]) {
            cell.labelField.text = NSLocalizedString(@"uploaded_date", @"追加月日");
            cell.labelDetail.text = [LXUtils dateToString:_picture.createdAt];
        }
    }
    if (indexPath.section == 1) {
        if (_picture.isOwner) {
            cell.imageHide.hidden = _picture.showEXIF;
        }
        
        cell.labelField.text = [keyExif objectAtIndex:indexPath.row];
        cell.labelDetail.text = [_picture.exif objectForKey:[keyExif objectAtIndex:indexPath.row]];
    }
    
    return cell;

}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0)
        if ([[keyBasic objectAtIndex:indexPath.row] isEqualToString:@"tags"])
            return 40;
    return 30;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 1) {
        return NSLocalizedString(@"exif_info", @"カメラ情報");
    }
    return NSLocalizedString(@"photo_info", @"詳細情報");
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return sections;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *view = [[UIView alloc] init];
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 300, 30)];
    title.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:12];
    title.textColor = [UIColor colorWithRed:101.0/255.0 green:90.0/255.0 blue:56.0/255.0 alpha:1];
    title.text = [self tableView:tableView titleForHeaderInSection:section];
    title.backgroundColor = [UIColor clearColor];
    [view addSubview:title];
    
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 30;
}

@end
