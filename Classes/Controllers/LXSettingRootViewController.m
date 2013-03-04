//
//  LXSettingRootViewController.m
//  Latte camera
//
//  Created by Bui Xuan Dung on 3/2/13.
//  Copyright (c) 2013 LUXEYS. All rights reserved.
//

#import "LXSettingRootViewController.h"
#import "LXSettingViewController.h"
#import "LXAppDelegate.h"
#import "LXRootBuilder.h"

@interface LXSettingRootViewController ()

@end

@implementation LXSettingRootViewController

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
    
    self.tableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg_sub_back.png"]];

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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    LXAppDelegate* app = [LXAppDelegate currentDelegate];
    if (app.currentUser == nil) {
        if (indexPath.section == 0) {
            switch (indexPath.row) {
                case 0:
                case 1:
                case 2:
                case 3:
                    return;
                    break;
                default:
                    break;
            }
        }
    }
    
    
    if (indexPath.section == 0) {
        
        NSString *filePath;
        switch (indexPath.row) {
            case 0:
                filePath = [[NSBundle mainBundle] pathForResource:@"settingprofile" ofType:@"json"];
                break;
            case 1:
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://latte.la/user/setting"]];
                [tableView deselectRowAtIndexPath:indexPath animated:YES];
                return;
                break;
            case 2:
                filePath = [[NSBundle mainBundle] pathForResource:@"settingprivacy" ofType:@"json"];
                break;
            case 3:
                [self performSegueWithIdentifier:@"Notification" sender:self];
                return;
            default:
                break;
        }
        
        Class JSONSerialization = [QRootElement JSONParserClass];
        NSAssert(JSONSerialization != NULL, @"No JSON serializer available!");
        
        NSError *jsonParsingError = nil;
        
        NSDictionary *data = [JSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:filePath] options:0 error:&jsonParsingError];
        QRootElement *root = [[LXRootBuilder new]buildWithObject:data];
        
        if (data != nil) {
            [root bindToObject:data];
        }
        LXSettingViewController* viewSetting = [[LXSettingViewController alloc] initWithRoot:root];
        
        [self.navigationController pushViewController:viewSetting animated:YES];
    } else if (indexPath.section == 1) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    } else if (indexPath.section == 3) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://latte.la/company/policy"]];
        
    } else if (indexPath.section == 4) {
        LXAppDelegate* app = (LXAppDelegate*)[UIApplication sharedApplication].delegate;
        
        [[LatteAPIClient sharedClient] postPath:@"user/logout"
                                     parameters:[NSDictionary dictionaryWithObjectsAndKeys:
                                                 [app getToken], @"token", nil]
                                        success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                            [app setToken:@""];
                                            app.currentUser = nil;
                                            self.tabBarController.selectedIndex = 0;
                                            [self dismissViewControllerAnimated:YES completion:nil];
                                            [[NSNotificationCenter defaultCenter] postNotificationName:@"LoggedOut" object:self];
                                        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"error", "Error")
                                                                                            message:error.localizedDescription
                                                                                           delegate:nil
                                                                                  cancelButtonTitle:NSLocalizedString(@"close", "Close")
                                                                                  otherButtonTitles:nil];
                                            [alert show];
                                        }];
    }
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    LXAppDelegate* app = [LXAppDelegate currentDelegate];
    if (app.currentUser == nil)
        return 4;
    else
        return 5;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    LXAppDelegate* app = [LXAppDelegate currentDelegate];
    if (app.currentUser == nil) {
        if (indexPath.section == 0) {
            switch (indexPath.row) {
                case 0:
                case 1:
                case 2:
                case 3:
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    for (UIView *view in cell.subviews)
                        view.alpha = 0.5;
                default:
                    break;
            }
        }
    }
}


- (IBAction)touchClose:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
