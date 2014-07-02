//
//  LXNationSelectTVC.m
//  Latte camera
//
//  Created by Serkan Unal on 7/2/14.
//  Copyright (c) 2014 LUXEYS. All rights reserved.
//

#import "LXNationSelectTVC.h"
#import "MZFormSheetController.h"


#import "LXAppDelegate.h"
#import "MBProgressHUD.h"
#import "LatteAPIClient.h"
#import "LXUtils.h"

@interface LXNationSelectTVC () {
  NSMutableArray *countryCodes;
  NSMutableArray *countryString;
}

@end

@implementation LXNationSelectTVC

@synthesize data;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)initData:(NSDictionary *)_data{
    //Convert string to date.
    self.data = _data;
    
//    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
//    [dateFormat setDateFormat:@"yyyy-MM-dd"];
//    NSDate *date = [dateFormat dateFromString:[_data valueForKey:@"value"]];
//    if (date) {
//        [datePicker setDate:date animated:YES];
//    }
//    
//    [datePicker setMaximumDate:[NSDate date]];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSLocale *locale = [NSLocale currentLocale];
    countryCodes = [[NSLocale ISOCountryCodes] mutableCopy];
    NSMutableDictionary *countryDict = [[NSMutableDictionary alloc] init];
    countryString = [[NSMutableArray alloc] init];
    
    for (NSString *countryCode in countryCodes)
    {
      NSString *displayNameString = [locale displayNameForKey:NSLocaleCountryCode value:countryCode];
      [countryDict setObject:displayNameString forKey:countryCode];
    }
    
    countryCodes = [[countryDict keysSortedByValueUsingSelector:@selector(localizedCompare:)] mutableCopy];
    
    
    for (NSString *countryCode in countryCodes)
    {
      [countryString addObject:countryDict[countryCode]];
    }
   
    [self.tableView reloadData];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    //defaults setObject:countryCodes[indexPath.row] forKey:@"BrowsingCountry"];
    //object:countryCodes[indexPath.row]];
    
    //[self mz_dismissFormSheetControllerAnimated:YES completionHandler:nil];
    
    [self saveField:countryCodes[indexPath.row]];
    //close modal window.
    [self mz_dismissFormSheetControllerAnimated:YES completionHandler:^(MZFormSheetController *formSheetController) {
    }];

}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return countryCodes.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Country" forIndexPath:indexPath];
    
    NSString *countryImage = [NSString stringWithFormat:@"%@.png", countryCodes[indexPath.row]];
    cell.imageView.image = [UIImage imageNamed:countryImage];
    cell.textLabel.text = countryString[indexPath.row];
    
    return cell;
}


#pragma mark - Save actions
- (void)saveField:(NSString *)code {
    LXAppDelegate* app = [LXAppDelegate currentDelegate];
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObject:[app getToken] forKey:@"token"];
    MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:HUD];
    HUD.mode = MBProgressHUDModeIndeterminate;
    [HUD show:YES];
    
    NSLog(@"Code : %@", code);
    [params setObject:code forKey:@"nationality"];
    
    [[LatteAPIClient sharedClient] POST:@"user/me/update"
                             parameters: params
                                success:^(AFHTTPRequestOperation *operation, NSDictionary *JSON) {
                                    [HUD hide:YES];
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

@end
