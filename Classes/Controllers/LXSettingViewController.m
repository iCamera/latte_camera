//
//  luxeysSettingViewController.m
//  Latte
//
//  Created by Xuan Dung Bui on 8/20/12.
//  Copyright (c) 2012 LUXEYS. All rights reserved.
//

#import "LXSettingViewController.h"
#import "LXAppDelegate.h"
#import "LXButtonBack.h"
#import "LatteAPIClient.h"
#import "User.h"

@interface LXSettingViewController ()

@end
@implementation LXSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    LXAppDelegate* app = (LXAppDelegate*)[UIApplication sharedApplication].delegate;
    [app.tracker sendView:@"Setting Screen"];
    
    //Style
    self.resizeWhenKeyboardPresented = YES;
    
    
    LXButtonBack *buttonBack = [[LXButtonBack alloc] initWithFrame:CGRectMake(0, 0, 60, 30)];
    [buttonBack addTarget:self.navigationController action:@selector(popViewControllerAnimated:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:buttonBack];
    
    //Logic
    HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:HUD];
    HUD.mode = MBProgressHUDModeIndeterminate;
    [HUD show:YES];
    
    NSDictionary *params = [NSDictionary dictionaryWithObject:[app getToken] forKey:@"token"];
    [[LatteAPIClient sharedClient] getPath:@"user/me" parameters:params  success:^(AFHTTPRequestOperation *operation, NSDictionary *JSON) {
        
        NSDictionary *userDict = [JSON objectForKey:@"user"];
        User* user = [User instanceFromDictionary:userDict];
        
        [self.root bindToObject:userDict];
        
        NSArray *permission = [NSArray arrayWithObjects:
                               @"picture_status",
                               @"gender_public",
                               @"current_residence_public",
                               @"hometown_public",
                               @"birthyear_public",
                               @"birthdate_public", nil];
        
        for (NSString *aKey in permission) {
            NSArray *status = [NSArray arrayWithObjects:@"0", @"10", @"30", @"40", nil];
            ((QRadioElement *)[self.root elementWithKey:aKey]).selected = [status indexOfObject:[[userDict objectForKey:aKey] stringValue]];
        }
        
        NSArray *gender = [NSArray arrayWithObjects:@"1", @"2", nil];
        ((QRadioElement *)[self.root elementWithKey:@"gender"]).selected = [gender indexOfObject:[[userDict objectForKey:@"gender"] stringValue]];
        
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"yyyy-MM-dd"];
        
        ((QDateTimeInlineElement *)[self.root elementWithKey:@"birthday"]).dateValue = [dateFormat dateFromString:[userDict objectForKey:@"birthdate"]];
        
        ((QBooleanElement *)[self.root elementWithKey:@"stealth_mode"]).boolValue = user.stealthMode;
        
        [self.quickDialogTableView reloadData];
        
        [HUD hide:YES];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [HUD hide:YES];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"error", "Error")
                                                        message:error.localizedDescription
                                                       delegate:nil
                                              cancelButtonTitle:NSLocalizedString(@"close", "Close")
                                              otherButtonTitles:nil];
        [alert show];
    }];
}

- (void)setQuickDialogTableView:(QuickDialogTableView *)aQuickDialogTableView {
    [super setQuickDialogTableView:aQuickDialogTableView];
    
    if (self.quickDialogTableView.style == UITableViewStyleGrouped) {
        self.quickDialogTableView.backgroundView = nil;
        self.quickDialogTableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg_sub_back.png"]];
    }
    self.quickDialogTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.quickDialogTableView.styleProvider = self;
    
    ((QEntryElement *)[self.root elementWithKey:@"name"]).delegate = self;
    ((QEntryElement *)[self.root elementWithKey:@"current_residence"]).delegate = self;
    ((QEntryElement *)[self.root elementWithKey:@"hometown"]).delegate = self;
    ((QEntryElement *)[self.root elementWithKey:@"occupation"]).delegate = self;
    ((QEntryElement *)[self.root elementWithKey:@"introduction"]).delegate = self;
    ((QEntryElement *)[self.root elementWithKey:@"hobby"]).delegate = self;
    ((QDateTimeInlineElement *)[self.root elementWithKey:@"birthday"]).mode = UIDatePickerModeDate;
    ((QDateTimeInlineElement *)[self.root elementWithKey:@"birthday"]).delegate = self;
}

- (void) cell:(QEntryTableViewCell *)cell willAppearForElement:(QElement *)element atIndexPath:(NSIndexPath *)indexPath{
    if ([element isKindOfClass:[QEntryElement class]] || [element isKindOfClass:[QRadioElement class]]){
        cell.textLabel.textColor = [UIColor blackColor];
        cell.detailTextLabel.textColor = [UIColor colorWithRed:0.39 green:0.36 blue:0.23 alpha:1.0000];
        cell.textField.textColor = [UIColor colorWithRed:0.39 green:0.36 blue:0.23 alpha:1.0000];

        cell.textLabel.font = [UIFont fontWithName:@"AvenirNextCondensed-Regular" size:14];
        cell.detailTextLabel.font = [UIFont fontWithName:@"AvenirNextCondensed-Regular" size:14];
        cell.textField.font = [UIFont fontWithName:@"AvenirNextCondensed-Regular" size:14];
    }
    if ([element isKindOfClass:[QRadioItemElement class]] || [element isKindOfClass:[QBooleanElement class]]) {
        cell.textLabel.font = [UIFont fontWithName:@"AvenirNextCondensed-Regular" size:16];
        cell.detailTextLabel.font = [UIFont fontWithName:@"AvenirNextCondensed-Regular" size:16];
    }
    if ([element isKindOfClass:[QButtonElement class]]) {
        cell.textLabel.font = [UIFont fontWithName:@"AvenirNextCondensed-Medium" size:16];
        cell.textLabel.textColor = [UIColor grayColor];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleGray;
}

- (void)handleFeedback:(QButtonElement *) button {
    [self.navigationController.parentViewController performSelector:@selector(showAbout:) withObject:nil];
}

- (void)handleLogout:(QButtonElement *) button {
    [HUD show:YES];
}

- (void)updateNow {
    LXAppDelegate* app = (LXAppDelegate*)[UIApplication sharedApplication].delegate;
    NSMutableDictionary *param = [NSMutableDictionary dictionaryWithObject:[app getToken] forKey:@"token"];
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    
    [self.root fetchValueIntoObject:dict];

    NSString *msg = @"Values:";
    for (NSString *aKey in dict) {
        msg = [msg stringByAppendingFormat:@"\n- %@: %@", aKey, [dict objectForKey:aKey]];
        
        if ([aKey isEqualToString:@"birthday"]) {
            NSDate *date = [dict objectForKey:aKey];
            NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
            
            [dateFormat setDateFormat:@"yyyy"];
            NSString *year = [dateFormat stringFromDate:date];
            [param setObject:year forKey:@"birthday_year"];
            
            [dateFormat setDateFormat:@"MM"];
            NSString *month = [dateFormat stringFromDate:date];
            [param setObject:month forKey:@"birthday_month"];
            
            [dateFormat setDateFormat:@"dd"];
            NSString *day = [dateFormat stringFromDate:date];
            [param setObject:day forKey:@"birthday_day"];
        }
        else {
            [param setObject:[dict objectForKey:aKey] forKey:aKey];
        }
    }
    
    [[LatteAPIClient sharedClient] postPath:@"user/me/update"
                                       parameters: param
                                          success:^(AFHTTPRequestOperation *operation, NSDictionary *JSON) {
                                              if ([[JSON objectForKey:@"status"] integerValue] == 0) {
                                                  NSString *error = @"";
                                                  NSDictionary *errors = [JSON objectForKey:@"errors"];
                                                  for (NSString *tmp in [JSON objectForKey:@"errors"]) {
                                                      error = [error stringByAppendingFormat:@"\n%@", [errors objectForKey:tmp]];
                                                  }
                                                  UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"エラー" message:error delegate:self cancelButtonTitle:@"YES!" otherButtonTitles:nil];
                                                  [alert show];
                                              }
 
                                          } failure:^(AFHTTPRequestOperation *operation, NSError *error) { 
                                              UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"error", "Error")
                                                                                              message:error.localizedDescription
                                                                                             delegate:nil
                                                                                    cancelButtonTitle:NSLocalizedString(@"close", "Close")
                                                                                    otherButtonTitles:nil];
                                              [alert show];
                                          }];

}


- (void)sectionHeaderWillAppearForSection:(QSection *)section atIndex:(NSInteger)indexPath {
    if (section.title == nil) {
        return;
    }
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 30)];
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 300, 30)];
    title.font = [UIFont fontWithName:@"AvenirNextCondensed-Regular" size:16];
    title.textColor = [UIColor colorWithRed:101.0/255.0 green:90.0/255.0 blue:56.0/255.0 alpha:1];
    title.text = section.title;
    [view addSubview:title];
    title.backgroundColor = [UIColor clearColor];
    view.backgroundColor = [UIColor clearColor];
    section.headerView = view;
}

- (void)displayViewController:(UIViewController *)newController {
    [super displayViewController:newController];
    
    LXButtonBack *buttonBack = [[LXButtonBack alloc] initWithFrame:CGRectMake(0, 0, 60, 30)];
    [buttonBack addTarget:newController.navigationController action:@selector(popViewControllerAnimated:) forControlEvents:UIControlEventTouchUpInside];
    newController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:buttonBack];
}

-(void)handleUpdateRadio:(QRadioElement *)element {
    NSMutableDictionary *param = [NSMutableDictionary dictionaryWithObject:element.selectedValue
                                                                    forKey:element.key];
    [self submitUpdate:param];
}

-(void)handleUpdateEntry:(QEntryElement *)element {
    NSMutableDictionary *param = [NSMutableDictionary dictionaryWithObject:element.textValue
                                                                    forKey:element.key];
    [self submitUpdate:param];
}

-(void)handleUpdateBool:(QBooleanElement *)element {
    NSMutableDictionary *param = [NSMutableDictionary dictionaryWithObject:[NSNumber numberWithBool:element.boolValue]
                                                                    forKey:element.key];
    [self submitUpdate:param];
}


-(void)submitUpdate:(NSMutableDictionary*)dict {
    LXAppDelegate* app = [LXAppDelegate currentDelegate];
    [dict setObject:[app getToken] forKey:@"token"];
    
    [[LatteAPIClient sharedClient] postPath:@"user/me/update"
                                 parameters: dict
                                    success:^(AFHTTPRequestOperation *operation, NSDictionary *JSON) {
                                        if ([[JSON objectForKey:@"status"] integerValue] == 0) {
                                            NSString *error = @"";
                                            NSDictionary *errors = [JSON objectForKey:@"errors"];
                                            for (NSString *tmp in [JSON objectForKey:@"errors"]) {
                                                error = [error stringByAppendingFormat:@"\n%@", [errors objectForKey:tmp]];
                                            }
                                            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"エラー" message:error delegate:self cancelButtonTitle:@"YES!" otherButtonTitles:nil];
                                            [alert show];
                                        }
                                        
                                    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"error", "Error")
                                                                                        message:error.localizedDescription
                                                                                       delegate:nil
                                                                              cancelButtonTitle:NSLocalizedString(@"close", "Close")
                                                                              otherButtonTitles:nil];
                                        [alert show];
                                    }];
}



- (void)QEntryDidEndEditingElement:(QDateTimeInlineElement *)element andCell:(QEntryTableViewCell *)cell {
    if ([element.key isEqualToString:@"birthday"]) {
        NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
        
        NSDate *date = element.dateValue;
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        
        [dateFormat setDateFormat:@"yyyy"];
        NSString *year = [dateFormat stringFromDate:date];
        [param setObject:year forKey:@"birthday_year"];
        
        [dateFormat setDateFormat:@"MM"];
        NSString *month = [dateFormat stringFromDate:date];
        [param setObject:month forKey:@"birthday_month"];
        
        [dateFormat setDateFormat:@"dd"];
        NSString *day = [dateFormat stringFromDate:date];
        [param setObject:day forKey:@"birthday_day"];
        
        [self submitUpdate:param];
    }
}

@end
