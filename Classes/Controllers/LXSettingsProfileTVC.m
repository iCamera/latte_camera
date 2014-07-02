//
//  LXSettingsProfileTVC.m
//  Latte camera
//
//  Created by Serkan Unal on 6/20/14.
//  Copyright (c) 2014 LUXEYS. All rights reserved.
//

#import "LXSettingsProfileTVC.h"
#import "LXCellSelectItem.h"
#import "LXCellDatePicker.h"
#import "LXCellTextView.h"
#import "LXCellPicker.h"
#import "MZFormSheetSegue.h"
#import "LXAppDelegate.h"

@interface LXSettingsProfileTVC ()
@property (nonatomic, strong) NSDictionary *data;
@end

@implementation LXSettingsProfileTVC

-(NSDictionary *)data // Getter
{
  if(!_data) _data = [[NSDictionary alloc] init];
  return _data;
}

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
    
    // This will remove extra separators from tableview
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mart - Initilize
-(void)initData:(NSDictionary *)data
{
  self.data = data;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
  // Return the number of sections.
  NSString *kind = [self.data objectForKey:@"kind"];
  if (kind) {
    return 1;
  }
  return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  // Return the number of rows in the section.
  NSString *kind = [self.data objectForKey:@"kind"];
  NSInteger count = 0;
  if ([kind isEqualToString:@"gender"]) {
    count = 2;
  } else if ([kind isEqualToString:@"bloodtype"]) {
    count = 4;
  }
  return count;
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *kind = [self.data objectForKey:@"kind"];
    NSString *title = @"";
    if ([kind isEqualToString:@"gender"]) {
      title = NSLocalizedString(@"gender", @"Gender");
    } else if ([kind isEqualToString:@"bloodtype"]) {
      title = NSLocalizedString(@"bloodtype", @"Blood type");
    }
    return title;
  
}

#pragma mark - Auto cell height
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  return 44;
}

#pragma mark - Toogle Checkbox
-(NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  //Toggle Check (Umchecks previous selection
  NSIndexPath *oldIndex = [tableView indexPathForSelectedRow];
  [tableView cellForRowAtIndexPath:oldIndex].accessoryType = UITableViewCellAccessoryNone;
  [tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryCheckmark;
  
  UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
  [self saveField:cell.tag];
  //close modal window.
  [self mz_dismissFormSheetControllerAnimated:YES completionHandler:^(MZFormSheetController *formSheetController) {
  }];

  return indexPath;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  NSString *kind = [self.data objectForKey:@"kind"];
  UITableViewCell *cell;
  NSNumber *value = [self.data valueForKey:@"value"];
  
  if ([kind isEqualToString:@"gender"]) {
    LXCellSelectItem *cellSelect = (LXCellSelectItem *)[tableView dequeueReusableCellWithIdentifier:@"cellSelect"];
    
    switch (indexPath.row) {
      case 0:
        cellSelect.labelField.text = NSLocalizedString(@"male", @"Male");
        cellSelect.tag = 1;
        break;
      case 1:
        cellSelect.labelField.text = NSLocalizedString(@"female", @"Female");
        cellSelect.tag = 2;
        break;
      default:
        break;
    }
    //Set check
    NSNumber *targetValue = [NSNumber numberWithInteger:(indexPath.row + 1)];
    if (value && [targetValue isEqualToNumber:value]) {
      [tableView selectRowAtIndexPath:indexPath
                             animated:YES
                       scrollPosition:UITableViewScrollPositionMiddle];
      cellSelect.accessoryType = UITableViewCellAccessoryCheckmark;
      NSLog(@"cellSelect.accessoryType");
    }
    return cellSelect;
  } else if ([kind isEqualToString:@"bloodtype"]) {
    LXCellSelectItem *cellSelect = (LXCellSelectItem *)[tableView dequeueReusableCellWithIdentifier:@"cellSelect"];
    switch (indexPath.row) {
      case 0:
        cellSelect.labelField.text = @"A";
        cellSelect.tag = 1;
        break;
      case 1:
        cellSelect.labelField.text = @"B";
        cellSelect.tag = 2;
        break;
      case 2:
        cellSelect.labelField.text = @"AB";
        cellSelect.tag = 3;
        break;
      case 3:
        cellSelect.labelField.text = @"O";
        cellSelect.tag = 4;
        break;
      default:
        break;
    }
    //Set checkbox
    if ([cellSelect.labelField.text isEqualToString:[self.data valueForKey:@"value"]]) {
      [tableView selectRowAtIndexPath:indexPath
                             animated:YES
                       scrollPosition:UITableViewScrollPositionMiddle];
      cellSelect.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    return cellSelect;
  }
  return cell;
}


#pragma mark - Save actions
- (void)saveField:(NSInteger *)value {
  NSString *kind = [self.data objectForKey:@"kind"];
  
  LXAppDelegate* app = [LXAppDelegate currentDelegate];
  NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObject:[app getToken] forKey:@"token"];
  
  MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.view];
  [self.view addSubview:HUD];
  HUD.mode = MBProgressHUDModeIndeterminate;
  [HUD show:YES];
  
  [params setObject:[NSString stringWithFormat:@"%d", (int)value] forKey:kind];
  
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
