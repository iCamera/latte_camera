//
//  LXLeftGuestViewController.m
//  Latte camera
//
//  Created by Bui Xuan Dung on 3/22/13.
//  Copyright (c) 2013 LUXEYS. All rights reserved.
//

#import "LXLeftGuestViewController.h"
#import "LXAppDelegate.h"
#import "LXAboutViewController.h"

@interface LXLeftGuestViewController ()

@end

@implementation LXLeftGuestViewController

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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 32;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 28;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 27)];
    UIImageView *background = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 27)];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(6, 0, 320, 27)];
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:14];
    label.backgroundColor = [UIColor clearColor];
    label.text = [self tableView:tableView titleForHeaderInSection:section];
    background.image = [UIImage imageNamed:@"side_menu_bg1.png"];
    [view addSubview:background];
    [view addSubview:label];
    return view;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    LXAppDelegate *app = [LXAppDelegate currentDelegate];
    
    [app.controllerSide showCenterPanelAnimated:YES];
    if (indexPath.section == 0) {
        switch (indexPath.row) {
            case 0:
            case 1:
                app.viewMainTab.selectedIndex = 4;
                break;
            default:
                break;
        }
    } else {
        switch (indexPath.row) {
            case 0: {
                UIStoryboard *storySetting = [UIStoryboard storyboardWithName:@"Setting" bundle:nil];
                LXAboutViewController *controllerAbout = [storySetting instantiateViewControllerWithIdentifier:@"About"];
                app.viewMainTab.selectedIndex = 4;
                UINavigationController *nav = (UINavigationController*)app.viewMainTab.selectedViewController;
                [nav pushViewController:controllerAbout animated:YES];
                break;
            }
            case 1:
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://latte.la/company/policy"]];
                break;
            default:
                break;
        }
    }
}

@end
