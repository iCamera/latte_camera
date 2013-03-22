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
#import "LatteAPIClient.h"

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
    
    LXAppDelegate *app = [LXAppDelegate currentDelegate];
    [app.tracker sendView:@"Setting Screen"];
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
        
        QRootElement *root;
        switch (indexPath.row) {
            case 0: {
                NSString *filePath = [[NSBundle mainBundle] pathForResource:@"settingprofile" ofType:@"json"];

                NSDictionary *data = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:filePath] options:0 error:nil];
                
                NSMutableDictionary *countriesDict = [[NSMutableDictionary alloc] init];
                NSLocale *locale = [NSLocale currentLocale];
                
                NSArray *countryArray = [NSLocale ISOCountryCodes];
                for (NSString *countryCode in countryArray)
                {
                    NSString *displayNameString = [locale displayNameForKey:NSLocaleCountryCode value:countryCode];
                    [countriesDict setObject:countryCode forKey:displayNameString];
                }
                
                root = [[LXRootBuilder new]buildWithObject:data];
                [root bindToObject:data];
                QSection *section = root.sections[0];
                QRadioElement *eleCountry = [[QRadioElement alloc] initWithDict:countriesDict selected:0 title:NSLocalizedString(@"nationality", @"Nationality")];
                eleCountry.key = @"nationality";
                eleCountry.controllerAction = @"handleUpdateRadio:";                
                
                [section addElement:eleCountry];
                break;
            }
            case 1:
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://latte.la/user/setting"]];
                [tableView deselectRowAtIndexPath:indexPath animated:YES];
                return;
                break;
            case 2: {
                NSString *filePath = [[NSBundle mainBundle] pathForResource:@"settingprivacy" ofType:@"json"];
                NSDictionary *data = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:filePath] options:0 error:nil];
                root = [[LXRootBuilder new]buildWithObject:data];
                [root bindToObject:data];
                break;
            }
            case 3:
                [self performSegueWithIdentifier:@"Notification" sender:self];
                return;
            default:
                break;
        }
        
        
        LXSettingViewController* viewSetting = [[LXSettingViewController alloc] initWithRoot:root];
        
        [self.navigationController pushViewController:viewSetting animated:YES];
    } else if (indexPath.section == 1) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    } else if (indexPath.section == 2) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://latte.la/company/policy"]];
        
    } else if (indexPath.section == 3) {
        LXAppDelegate* app = (LXAppDelegate*)[UIApplication sharedApplication].delegate;
        
        [[LatteAPIClient sharedClient] postPath:@"user/logout"
                                     parameters:[NSDictionary dictionaryWithObjectsAndKeys:
                                                 [app getToken], @"token", nil]
                                        success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                            [app setToken:@""];
                                            app.currentUser = nil;
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
        return 3;
    else
        return 4;
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
