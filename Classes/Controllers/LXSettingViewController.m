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
    
    
    //Logic
    HUD = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:HUD];
    HUD.mode = MBProgressHUDModeIndeterminate;
    [HUD show:YES];
    
    NSDictionary *params = [NSDictionary dictionaryWithObject:[app getToken] forKey:@"token"];
    [[LatteAPIClient sharedClient] GET:@"user/me" parameters:params  success:^(AFHTTPRequestOperation *operation, NSDictionary *JSON) {
        
        NSMutableDictionary *userDict = [NSMutableDictionary dictionaryWithDictionary:[JSON objectForKey:@"user"]];
        // Fixbug
        if ([userDict objectForKey:@"current_residence"] == nil) {
            [userDict setObject:@"" forKey:@"current_residence"];
        }
        if ([userDict objectForKey:@"hometown"] == nil) {
            [userDict setObject:@"" forKey:@"hometown"];
        }
        User* user = [User instanceFromDictionary:userDict];
        
        [self.root bindToObject:userDict];
        
        NSArray *permission = [NSArray arrayWithObjects:
                               @"picture_status",
                               @"gender_public",
                               @"current_residence_public",
                               @"hometown_public",
                               @"birthyear_public",
                               @"birthdate_public",
                               @"nationality_public",
                               @"default_show_exif",
                               @"default_show_gps",
                               @"default_show_taken_at",
                               @"default_show_large"
                               , nil];
        

        for (NSString *aKey in permission) {
            NSArray *status = [NSArray arrayWithObjects:@"40", @"30", @"10", @"0", nil];
            ((QRadioElement *)[self.root elementWithKey:aKey]).selected = [status indexOfObject:[[userDict objectForKey:aKey] stringValue]];
        }
        
        NSArray *gender = [NSArray arrayWithObjects:@"1", @"2", nil];
        NSInteger genderIndex = [gender indexOfObject:[[userDict objectForKey:@"gender"] stringValue]];
        ((QRadioElement *)[self.root elementWithKey:@"gender"]).selected = genderIndex;
        
        ((QRadioElement *)[self.root elementWithKey:@"nationality"]).selectedValue = user.nationality;
        
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
    
    self.quickDialogTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.quickDialogTableView.styleProvider = self;
    
    ((QEntryElement *)[self.root elementWithKey:@"name"]).delegate = self;
    ((QEntryElement *)[self.root elementWithKey:@"current_residence"]).delegate = self;
    ((QEntryElement *)[self.root elementWithKey:@"hometown"]).delegate = self;
    ((QEntryElement *)[self.root elementWithKey:@"occupation"]).delegate = self;
    ((QMultilineElement *)[self.root elementWithKey:@"introduction"]).delegate = self;
    ((QMultilineElement *)[self.root elementWithKey:@"hobby"]).delegate = self;
    ((QDateTimeInlineElement *)[self.root elementWithKey:@"birthday"]).mode = UIDatePickerModeDate;
    ((QDateTimeInlineElement *)[self.root elementWithKey:@"birthday"]).delegate = self;
}

- (void) cell:(QEntryTableViewCell *)cell willAppearForElement:(QElement *)element atIndexPath:(NSIndexPath *)indexPath{
    if ([element isKindOfClass:[QEntryElement class]] || [element isKindOfClass:[QRadioElement class]]){
        cell.textLabel.textColor = [UIColor blackColor];
        cell.detailTextLabel.textColor = [UIColor colorWithRed:0.39 green:0.36 blue:0.23 alpha:1.0000];
        cell.textField.textColor = [UIColor colorWithRed:0.39 green:0.36 blue:0.23 alpha:1.0000];

        cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:14];
        cell.detailTextLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:14];
        cell.textField.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:14];
    }
    if ([element isKindOfClass:[QRadioItemElement class]] || [element isKindOfClass:[QBooleanElement class]]) {
        cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:14];
        cell.detailTextLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:14];
    }
    if ([element isKindOfClass:[QButtonElement class]]) {
        cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Regular" size:14];
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

- (void)sectionHeaderWillAppearForSection:(QSection *)section atIndex:(NSInteger)indexPath {
    if (section.headerView) {
        return;
    }
    if (section.title == nil) {
        return;
    }
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 30)];
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 300, 30)];
    title.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:16];
    title.textColor = [UIColor colorWithRed:101.0/255.0 green:90.0/255.0 blue:56.0/255.0 alpha:1];
    title.text = section.title;
    [view addSubview:title];
    title.backgroundColor = [UIColor clearColor];
    view.backgroundColor = [UIColor clearColor];
    section.headerView = view;
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
    
    /*if ([dict objectForKey:@"default_show_exif"]) {
        app.currentUser.defaultShowEXIF = [[dict objectForKey:@"default_show_exif"] boolValue];
    }
    
    if ([dict objectForKey:@"default_show_gps"]) {
        app.currentUser.defaultShowGPS= [[dict objectForKey:@"default_show_gps"] boolValue];
    }
    
    if ([dict objectForKey:@"default_show_taken_at"]) {
        app.currentUser.defaultShowTakenAt = [[dict objectForKey:@"default_show_taken_at"] boolValue];
    }*/
    
    [[LatteAPIClient sharedClient] POST:@"user/me/update"
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
                                        } else {
                                            app.currentUser = [User instanceFromDictionary:[JSON objectForKey:@"user"]];
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
        if (date != nil) {
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
    if ([element.key isEqualToString:@"introduction"] || [element.key isEqualToString:@"hobby"]) {
        NSMutableDictionary *param = [NSMutableDictionary dictionaryWithObject:element.textValue
                                                                        forKey:element.key];
        [self submitUpdate:param];
    }
}

- (void)sectionFooterWillAppearForSection:(QSection *)section atIndex:(NSInteger)indexPath {
    UIFont *font = [UIFont fontWithName:@"HelveticaNeue-Light" size:11];
    CGSize size = [section.footer sizeWithFont:font constrainedToSize:CGSizeMake(300, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, size.height + 20)];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 20, 300, size.height)];
    label.font = font;
    label.lineBreakMode = NSLineBreakByWordWrapping;
    label.numberOfLines = 0;
    label.backgroundColor = [UIColor clearColor];
    label.text = section.footer;
    [view addSubview:label];
    section.footerView = view;
}

@end
