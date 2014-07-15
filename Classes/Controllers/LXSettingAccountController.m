//
//  LXSettingAccountController.m
//  Latte camera
//
//  Created by Bui Xuan Dung on 7/31/13.
//  Copyright (c) 2013 LUXEYS. All rights reserved.
//

#import "LXSettingAccountController.h"
#import "LXAppDelegate.h"
#import "MZFormSheetSegue.h"
#import "LXNationSelectTVC.h"
#import "MZFormSheetController.h"
#import "User.h"

@interface LXSettingAccountController ()

@end

@implementation LXSettingAccountController
@synthesize textEmail;

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
    self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    LXAppDelegate *app = [LXAppDelegate currentDelegate];
    User *user = app.currentUser;
    
    textEmail.text = app.currentUser.mail;
    
    
    
    if (user.country && [user.country length]) {
        NSLocale *locale = [NSLocale currentLocale];
        NSString *countryImage = [NSString stringWithFormat:@"%@.png", user.country];
        _cellCountry.imageView.image = [UIImage imageNamed:countryImage];
        NSString *displayNameString = [locale displayNameForKey:NSLocaleCountryCode value:user.nationality];
        _cellCountry.textLabel.text = displayNameString;
    } else {
        _cellCountry.textLabel.text = @"";
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view delegate

- (void)viewDidUnload {
    [self setTextEmail:nil];
    [super viewDidUnload];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    MZFormSheetSegue *sheet = (MZFormSheetSegue*)segue;
    sheet.formSheetController.cornerRadius = 0;
    sheet.formSheetController.shouldDismissOnBackgroundViewTap = YES;
    sheet.formSheetController.presentedFormSheetSize = CGSizeMake(300, 200);
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1) {
        UIStoryboard *storySetting = [UIStoryboard storyboardWithName:@"Setting" bundle:nil];
        LXNationSelectTVC *settingCountry = [storySetting instantiateViewControllerWithIdentifier:@"NationSelect"];
        settingCountry.key = @"country";

        MZFormSheetController *formSheet = [[MZFormSheetController alloc] initWithViewController:settingCountry];
        
        formSheet.cornerRadius = 0;
        formSheet.shouldDismissOnBackgroundViewTap = YES;
        
        [self mz_presentFormSheetController:formSheet animated:YES completionHandler:^(MZFormSheetController *formSheetController) {
            //do sth
        }];
    }
}

@end
