//
//  LXCountrySelectViewController.m
//  Latte camera
//
//  Created by Bui Xuan Dung on 6/25/14.
//  Copyright (c) 2014 LUXEYS. All rights reserved.
//

#import "LXCountrySelectViewController.h"
#import "MZFormSheetController.h"

@interface LXCountrySelectViewController () {
    NSMutableArray *countryCodes;
    NSMutableArray *countryString;
}

@end

@implementation LXCountrySelectViewController

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
    
    [countryCodes insertObject:@"World" atIndex:0];
    [countryString insertObject:@"World" atIndex:0];
    
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (indexPath.row == 0) {
        [defaults removeObjectForKey:@"BrowsingCountry"];
    } else {
        [defaults setObject:countryCodes[indexPath.row] forKey:@"BrowsingCountry"];
    }
    [defaults synchronize];
    
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"ChangedBrowsingCountry"
     object:countryCodes[indexPath.row]];
    
    [self mz_dismissFormSheetControllerAnimated:YES completionHandler:nil];
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

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
