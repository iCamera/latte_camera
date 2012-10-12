//
//  luxeysSettingViewController.m
//  Latte
//
//  Created by Xuan Dung Bui on 8/20/12.
//  Copyright (c) 2012 LUXEYS. All rights reserved.
//

#import "luxeysSettingViewController.h"
#import "luxeysAppDelegate.h"
#import "luxeysButtonBack.h"
#import "LatteAPIClient.h"

@interface luxeysSettingViewController ()

@end
@implementation luxeysSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //Style
    self.resizeWhenKeyboardPresented = YES;
    
    
    luxeysButtonBack *buttonBack = [[luxeysButtonBack alloc] initWithFrame:CGRectMake(0, 0, 60, 30)];
    [buttonBack addTarget:self.navigationController action:@selector(popViewControllerAnimated:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:buttonBack];
    
    //Logic
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
    
    luxeysAppDelegate *app = (luxeysAppDelegate*)[[UIApplication sharedApplication] delegate];
    
    [[LatteAPIClient sharedClient] getPath:@"api/user/me"
                                       parameters: [NSDictionary dictionaryWithObject:[app getToken] forKey:@"token"]
                                          success:^(AFHTTPRequestOperation *operation, NSDictionary *JSON) {
                                              
                                              NSDictionary *user = [JSON objectForKey:@"user"];
                                              
                                              [self.root bindToObject:user];
                                              
                                              NSArray *permission = [NSArray arrayWithObjects:
                                                                     @"picture_status",
                                                                     @"gender_public",
                                                                     @"current_residence_public",
                                                                     @"hometown_public",
                                                                     @"birthyear_public",
                                                                     @"birthdate_public", nil];
                                              
                                              for (NSString *aKey in permission) {
                                                  NSArray *status = [NSArray arrayWithObjects:@"0", @"10", @"30", @"40", nil];
                                                  ((QRadioElement *)[self.root elementWithKey:aKey]).selected = [status indexOfObject:[[user objectForKey:aKey] stringValue]];
                                              }
                                              
                                              NSArray *gender = [NSArray arrayWithObjects:@"1", @"2", nil];
                                              ((QRadioElement *)[self.root elementWithKey:@"gender"]).selected = [gender indexOfObject:[[user objectForKey:@"gender"] stringValue]];
                                              
                                              NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
                                              [dateFormat setDateFormat:@"yyyy-MM-dd"];
                                              
                                              ((QDateTimeInlineElement *)[self.root elementWithKey:@"birthday"]).dateValue = [dateFormat dateFromString:[user objectForKey:@"birthdate"]];

                                              
                                              [self.quickDialogTableView reloadData];

                                              dispatch_async(dispatch_get_main_queue(), ^{
                                                     [MBProgressHUD hideHUDForView:self.view animated:YES];
                                                 });
                                              
                                          } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                              NSLog(@"Something went wrong (Load setting)");
                                              dispatch_async(dispatch_get_main_queue(), ^{
                                                     [MBProgressHUD hideHUDForView:self.view animated:YES];
                                                 });
                                          }];
    });
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
        cell.textLabel.font = [UIFont boldSystemFontOfSize:14];
        cell.detailTextLabel.font = [UIFont systemFontOfSize:14];
        cell.textLabel.textColor = [UIColor blackColor];
        cell.detailTextLabel.textColor = [UIColor colorWithRed:0.39 green:0.36 blue:0.23 alpha:1.0000];
        cell.textField.font = [UIFont systemFontOfSize:14];
        cell.textField.textColor = [UIColor colorWithRed:0.39 green:0.36 blue:0.23 alpha:1.0000];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleGray;
}

- (void)handleLogout:(QButtonElement *) button {
    luxeysAppDelegate* app = (luxeysAppDelegate*)[UIApplication sharedApplication].delegate;
    [app setToken:@""];
    app.currentUser = nil;
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"LoggedOut"
     object:self];
    self.tabBarController.selectedIndex = 0;
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)updateNow {
    [self loading:YES];
    luxeysAppDelegate* app = (luxeysAppDelegate*)[UIApplication sharedApplication].delegate;
    NSMutableDictionary *param = [NSMutableDictionary dictionaryWithObject:[app getToken] forKey:@"token"];
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    
    [self.root fetchValueIntoObject:dict];
    NSString *msg = @"Values:";
    for (NSString *aKey in dict){
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
    
    [[LatteAPIClient sharedClient] postPath:@"api/user/me/update"
                                       parameters: param
                                          success:^(AFHTTPRequestOperation *operation, NSDictionary *JSON) {
                                              [self loading:NO];
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
                                              NSLog(@"Something went wrong (Setting)");
                                              [self loading:NO];
                                          }];

}


- (void)sectionHeaderWillAppearForSection:(QSection *)section atIndex:(NSInteger)indexPath {
    if (section.title == nil) {
        return;
    }
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 30)];
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 300, 30)];
    [title setFont:[UIFont boldSystemFontOfSize:12]];
    title.textColor = [UIColor colorWithRed:101.0/255.0 green:90.0/255.0 blue:56.0/255.0 alpha:1];
    title.text = section.title;
    [view addSubview:title];
    title.backgroundColor = [UIColor clearColor];
    view.backgroundColor = [UIColor clearColor];
    section.headerView = view;
}

- (void)displayViewController:(UIViewController *)newController {
    [super displayViewController:newController];
    
    luxeysButtonBack *buttonBack = [[luxeysButtonBack alloc] initWithFrame:CGRectMake(0, 0, 60, 30)];
    [buttonBack addTarget:newController.navigationController action:@selector(popViewControllerAnimated:) forControlEvents:UIControlEventTouchUpInside];
    newController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:buttonBack];
}

-(void)handleUpdate:(QRadioElement *)element {
    [self updateNow];
}


- (void)QEntryDidEndEditingElement:(QEntryElement *)element andCell:(QEntryTableViewCell *)cell {
    [self updateNow];
}


@end
