//
//  LXSelectorVC.m
//  Latte camera
//
//  Created by Serkan Unal on 6/20/14.
//  Copyright (c) 2014 LUXEYS. All rights reserved.
//

#import "LXSelectorVC.h"
#import "MBProgressHUD.h"
#import "LXAppDelegate.h"
#import "MZFormSheetSegue.h"
@interface LXSelectorVC ()

@end

@implementation LXSelectorVC
@synthesize data;
@synthesize datePicker;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
  
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)initData:(NSDictionary *)_data{
  //Convert string to date.
  self.data = _data;
  
  NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
  [dateFormat setDateFormat:@"yyyy-MM-dd"];
  NSDate *date = [dateFormat dateFromString:[_data valueForKey:@"value"]];
  if (date) {
    [datePicker setDate:date animated:YES];
  }
  
  [datePicker setMaximumDate:[NSDate date]];
  
}
- (IBAction)touchChange:(id)sender {
  [self saveField:datePicker.date];
  //close modal window.
  [self mz_dismissFormSheetControllerAnimated:YES completionHandler:^(MZFormSheetController *formSheetController) {
  }];


}

#pragma mark - Save actions
- (void)saveField:(NSDate *)birthday {
  LXAppDelegate* app = [LXAppDelegate currentDelegate];
  NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObject:[app getToken] forKey:@"token"];

  MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.view];
  [self.view addSubview:HUD];
  HUD.mode = MBProgressHUDModeIndeterminate;
  [HUD show:YES];

  NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
  [dateFormat setDateFormat:@"yyyy"];
  NSString *birthday_year = [dateFormat stringFromDate:birthday];
  [dateFormat setDateFormat:@"MM"];
  NSString *birthday_month = [dateFormat stringFromDate:birthday];
  [dateFormat setDateFormat:@"dd"];
  NSString *birthday_day = [dateFormat stringFromDate:birthday];
  
  [params setObject:birthday_year forKey:@"birthday_year"];
  [params setObject:birthday_month forKey:@"birthday_month"];
  [params setObject:birthday_day forKey:@"birthday_day"];

  
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
