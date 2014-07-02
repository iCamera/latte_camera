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
#import "LXReportAbuseViewController.h"
#import "PicturePin.h"
#import <CoreLocation/CoreLocation.h>

#define METERS_PER_MILE 1609.344

@interface LXPicInfoViewController ()
@end

@implementation LXPicInfoViewController {
    NSMutableArray *keyBasic;
    NSArray *keyExif;
    NSInteger sections;
    PicturePin *pin;
    MKMapView *mapPic;
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
    keyExif = [_picture.exif allKeys];
    
    if (_picture.exif.count > 0) {
        sections += 1;
    }
    
    if (_picture.isOwner) {
        sections += 1;
    }
    
    if (_picture.latitude && _picture.longitude) {
        CLLocationCoordinate2D location;
        location.latitude = [_picture.latitude floatValue];
        location.longitude = [_picture.longitude floatValue];
        pin = [[PicturePin alloc] initWithCoordinate:location];
        
        mapPic = [[MKMapView alloc] initWithFrame:CGRectMake(0, 0, 320, 150)];
        MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(pin.coordinate, 0.5*METERS_PER_MILE, 0.5*METERS_PER_MILE);
        MKCoordinateRegion adjustedRegion = [mapPic regionThatFits:viewRegion];
        
        [mapPic addAnnotation:pin];
        [mapPic setRegion:adjustedRegion animated:YES];
        [mapPic regionThatFits:adjustedRegion];
        
        self.tableView.tableHeaderView = mapPic;
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
    UIStoryboard *storyGallery = [UIStoryboard storyboardWithName:@"Gallery" bundle:nil];
    LXReportAbuseViewController *controllerReport = [storyGallery instantiateViewControllerWithIdentifier:@"Report"];
    controllerReport.picture = _picture;
    [self.navigationController pushViewController:controllerReport animated:YES];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (((section == 1) && (keyExif.count == 0)) || (section == 2)) {
        return 5;
    }
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
            cellTag.parent = self;
            return cellTag;
        }
    
    LXCellDataField *cell = [tableView dequeueReusableCellWithIdentifier:@"Profile"];

    if (indexPath.section == 0)
    {
        NSString *key = [keyBasic objectAtIndex:indexPath.row];
        if ([key isEqualToString:@"taken_at"]) {
            
            cell.labelField.text = NSLocalizedString(@"taken_date", @"撮影月日") ;
            cell.labelDetail.text = [LXUtils dateToString:_picture.takenAt];
        }
        if ([[keyBasic objectAtIndex:indexPath.row] isEqualToString:@"created_at"]) {

            cell.labelField.text = NSLocalizedString(@"uploaded_date", @"追加月日");
            cell.labelDetail.text = [LXUtils dateToString:_picture.createdAt];
        }
    }
    if (indexPath.section == 1) {
        if (_picture.exif.count > 0) {
            cell.labelField.text = NSLocalizedString([keyExif objectAtIndex:indexPath.row], @"");
            cell.labelDetail.text = [_picture.exif objectForKey:[keyExif objectAtIndex:indexPath.row]];
        }
    }
    
    if (((indexPath.section == 1) && (_picture.exif.count == 0) && (_picture.isOwner)) ||
        (indexPath.section == 2)) {
        PictureStatus status = 0;
        NSString *text;
        switch (indexPath.row) {
            case 0:
                text = NSLocalizedString(@"Photo privacy", "");
                status = _picture.status;
                break;
            case 1:
                text = NSLocalizedString(@"Show taken date", "");
                status = _picture.showTakenAt;
                break;
            case 2:
                text = NSLocalizedString(@"Show camera EXIF", "");
                status = _picture.showEXIF;
                break;
            case 3:
                text = NSLocalizedString(@"Show location", "");
                status = _picture.showGPS;
                break;
            case 4:
                text = NSLocalizedString(@"Show original file", "");
                status = _picture.showLarge;
                break;
            default:
                break;
        }
        
        cell.labelField.text = text;
        switch (status) {
            case PictureStatusPrivate:
                cell.labelDetail.text = NSLocalizedString(@"status_private", @"");
                break;
            case PictureStatusFriendsOnly:
                cell.labelDetail.text = NSLocalizedString(@"status_friends", @"");
                break;
            case PictureStatusMember:
                cell.labelDetail.text = NSLocalizedString(@"status_members", @"");
                break;
            case PictureStatusPublic:
                cell.labelDetail.text = NSLocalizedString(@"status_public", @"");
                break;
            default:
                cell.labelDetail.text = NSLocalizedString(@"status_public", @"");
                break;
        }
    }
    
    return cell;

}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0)
        if ([[keyBasic objectAtIndex:indexPath.row] isEqualToString:@"tags"])
            return 36;
    return 30;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 1) {
        return NSLocalizedString(@"exif_info", @"カメラ情報");
    }
    
    if (((section == 1) && (_picture.exif.count == 0) && (_picture.isOwner)) || (section == 2))
    {
        return NSLocalizedString(@"privacy_setting", @"");
    }
    return NSLocalizedString(@"photo_info", @"詳細情報");
    
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    if (((section == 1) && (_picture.exif.count == 0) && (_picture.isOwner)) || (section == 2))
    {
        return NSLocalizedString(@"Only you can see this section", @"");
    }
    return nil;
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

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView *view = [[UIView alloc] init];
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 300, 30)];
    title.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:12];
    title.textColor = [UIColor colorWithRed:101.0/255.0 green:90.0/255.0 blue:56.0/255.0 alpha:1];
    title.text = [self tableView:tableView titleForFooterInSection:section];
    title.backgroundColor = [UIColor clearColor];
    [view addSubview:title];
    
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 30;
}

@end
