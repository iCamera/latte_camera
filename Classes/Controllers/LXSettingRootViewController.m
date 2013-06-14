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
#import "LXUtils.h"
#import "LXShare.h"
#import "UIImageView+loadProgress.h"
#import "LXCaptureViewController.h"
#import "LXButtonBrown30.h"

@interface LXSettingRootViewController ()

@end

@implementation LXSettingRootViewController {
    LXShare *lxShare;
}

@synthesize labelVersion;
@synthesize viewHeader;
@synthesize imageProfile;
@synthesize viewWrapHeader;

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
    labelVersion.text = [[NSBundle mainBundle] objectForInfoDictionaryKey: @"CFBundleShortVersionString"];
    
    LXAppDelegate *app = [LXAppDelegate currentDelegate];
    [app.tracker sendView:@"Setting Screen"];
    lxShare = [[LXShare alloc] init];
    lxShare.controller = self;
    
    self.tableView.tableHeaderView = nil;
    
    if (app.currentUser) {
        [LXUtils globalShadow:viewHeader];
        [imageProfile loadProgess:app.currentUser.profilePicture];
        viewHeader.layer.cornerRadius = 5;
        imageProfile.layer.cornerRadius = 5;
        imageProfile.layer.masksToBounds = YES;
    }
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
                
                NSLocale *locale = [NSLocale currentLocale];
                NSString * language = [[NSLocale preferredLanguages] objectAtIndex:0];
                NSMutableArray *countryCodes = [[NSLocale ISOCountryCodes] mutableCopy];
                NSMutableDictionary *countryDict = [[NSMutableDictionary alloc] init];
                NSMutableArray *countryString = [[NSMutableArray alloc] init];

                for (NSString *countryCode in countryCodes)
                {
                    NSString *displayNameString = [locale displayNameForKey:NSLocaleCountryCode value:countryCode];
                    [countryDict setObject:displayNameString forKey:countryCode];
                }
                
                countryCodes = [[countryDict keysSortedByValueUsingSelector:@selector(localizedCompare:)] mutableCopy];
                
                if ([language isEqualToString:@"ja"]) {
                    [countryCodes removeObject:@"JP"];
                    [countryCodes insertObject:@"JP" atIndex:0];
                }
                
                for (NSString *countryCode in countryCodes)
                {
                    [countryString addObject:countryDict[countryCode]];
                }

                root = [[LXRootBuilder new]buildWithObject:data];
                [root bindToObject:data];
                QSection *section = root.sections[0];
//                QRadioElement *eleCountry = [[QRadioElement alloc] initWithDict:countriesDict selected:0 title:NSLocalizedString(@"nationality", @"Nationality")];
                QRadioElement *eleCountry = [[QRadioElement alloc] initWithItems:countryString selected:0 title:NSLocalizedString(@"nationality", @"Nationality")];
                eleCountry.values = countryCodes;
                eleCountry.key = @"nationality";
                eleCountry.controllerAction = @"handleUpdateRadio:";
                
                section.headerView = viewWrapHeader;
                
                [section addElement:eleCountry];
                break;
            }
            case 1: {
                NSString *language = [[NSLocale preferredLanguages] objectAtIndex:0];
                if ([language isEqualToString:@"ja"]) {
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://latte.la/user/setting"]];
                } else {
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://en.latte.la/user/setting"]];
                }
                
                [tableView deselectRowAtIndexPath:indexPath animated:YES];
                return;
            }
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
        [lxShare inviteFriend];
    } else if (indexPath.section == 3) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://latte.la/company/policy"]];
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    } else if (indexPath.section == 4) {
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
- (void)viewDidUnload {
    [self setImageProfile:nil];
    [self setViewHeader:nil];
    [self setViewWrapHeader:nil];
    [super viewDidUnload];
}
- (IBAction)touchSetPicture:(id)sender {
    LatteAPIClient *api = [LatteAPIClient sharedClient];
    if (api.networkReachabilityStatus == AFNetworkReachabilityStatusNotReachable) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"error", @"")
                                                        message:NSLocalizedString(@"Network connectivity is not available", @"")
                                                       delegate:nil
                                              cancelButtonTitle:NSLocalizedString(@"close", @"")
                                              otherButtonTitles:nil];
        [alert show];
        return;
    }
    UIStoryboard* storySetting = [UIStoryboard storyboardWithName:@"Camera" bundle:nil];
    UINavigationController *navCamera = [storySetting instantiateInitialViewController];
    LXCaptureViewController *controllerCamera = navCamera.viewControllers[0];
    controllerCamera.delegate = self;
    
    [self presentViewController:navCamera animated:YES completion:nil];
}

- (void)imagePickerController:(LXCanvasViewController *)picker didFinishPickingMediaWithData:(NSDictionary *)info {
    UIViewController *tmp2 = picker.navigationController.presentingViewController;
    [picker dismissModalViewControllerAnimated:NO];
    
    if (tmp2 != self.navigationController) {
        [tmp2 dismissModalViewControllerAnimated:YES];
    }
    
    LXAppDelegate* app = (LXAppDelegate*)[UIApplication sharedApplication].delegate;
    
    MBProgressHUD *progessHUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:progessHUD];
    progessHUD.removeFromSuperViewOnHide = YES;
    progessHUD.mode = MBProgressHUDModeDeterminate;
    [progessHUD show:YES];
    
    void (^createForm)(id<AFMultipartFormData>) = ^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFileData:[info objectForKey:@"data"]
                                    name:@"file"
                                fileName:@"latte.jpg"
                                mimeType:@"image/jpeg"];
    };
    
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            [app getToken], @"token", nil];
    
    NSURLRequest *request = [[LatteAPIClient sharedClient] multipartFormRequestWithMethod:@"POST"
                                                                                     path:@"user/me/profile_picture"
                                                                               parameters:params
                                                                constructingBodyWithBlock:createForm];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    void (^successUpload)(AFHTTPRequestOperation *, id) = ^(AFHTTPRequestOperation *operation, id responseObject) {
        progessHUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Checkmark.png"]];
        progessHUD.mode = MBProgressHUDModeCustomView;
        [progessHUD hide:YES afterDelay:1];
        
        imageProfile.image = [info objectForKey:@"preview"];
        
        [[LatteAPIClient sharedClient] getPath:@"user/me"
                                    parameters: [NSDictionary dictionaryWithObjectsAndKeys:[app getToken], @"token", nil]
                                       success:^(AFHTTPRequestOperation *operation, NSDictionary *JSON) {
                                           
                                           User *user = [User instanceFromDictionary:[JSON objectForKey:@"user"]];
                                           app.currentUser = user;
                                           
                                           
                                       } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                           DLog(@"Something went wrong (Profile)");
                                       }];
    };
    
    void (^failUpload)(AFHTTPRequestOperation *, NSError *) = ^(AFHTTPRequestOperation *operation, NSError *error) {
        if([operation.response statusCode] != 200){
            DLog(@"Upload Failed");
            return;
        }
        DLog(@"error: %@", [operation error]);
        progessHUD.mode = MBProgressHUDModeText;
        progessHUD.labelText = @"Error";
        progessHUD.margin = 10.f;
        progessHUD.yOffset = 150.f;
        
        [progessHUD hide:YES afterDelay:2];
    };
    
    [operation setCompletionBlockWithSuccess: successUpload failure: failUpload];
    
    [operation setUploadProgressBlock:^(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite) {
        progessHUD.progress = (float)totalBytesWritten/(float)totalBytesExpectedToWrite;
    }];
    
    [operation start];
}
@end
