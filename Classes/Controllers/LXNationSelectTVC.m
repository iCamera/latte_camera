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
    [countryCodes removeObject:@"JP"];
    [countryCodes insertObject:@"JP" atIndex:0];
    
    
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
    LXAppDelegate* app = [LXAppDelegate currentDelegate];
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    [[LatteAPIClient sharedClient] POST:@"user/me/update"
                             parameters: @{_key: countryCodes[indexPath.row]}
                                success:^(AFHTTPRequestOperation *operation, NSDictionary *JSON) {
                                    [MBProgressHUD hideHUDForView:self.view animated:YES];
                                    app.currentUser = [User instanceFromDictionary:[JSON objectForKey:@"user"]];
                                    
                                    [self mz_dismissFormSheetControllerAnimated:YES completionHandler:^(MZFormSheetController *formSheetController) {
                                    }];

                                } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                    [MBProgressHUD hideHUDForView:self.view animated:YES];
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
    
}

@end
