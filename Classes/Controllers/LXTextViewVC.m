//
//  LXTextViewVC.m
//  Latte camera
//
//  Created by Seri on 21-06-14.
//  Copyright (c) 2014 LUXEYS. All rights reserved.
//

#import "LXTextViewVC.h"
#import "MBProgressHUD.h"
#import "MZFormSheetSegue.h"
#import "LXAppDelegate.h"

@interface LXTextViewVC ()
@property (nonatomic, strong) NSDictionary *data;
@end

@implementation LXTextViewVC
@synthesize labelTitle;
@synthesize textViewContent;


-(NSDictionary *)data // Getter
{
  if(!_data) _data = [[NSDictionary alloc] init];
  return _data;
}

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

-(void)initData:(NSDictionary *)data
{
  self.data = data;
  labelTitle.text = [self.data objectForKey:@"title"];
  textViewContent.text = [self.data objectForKey:@"value"];
}

- (IBAction)touchChange:(id)sender {
  if ([self validateInput: textViewContent]) { //Validation:success
    [self saveField: textViewContent]; //save data
    //close modal window.
    [self mz_dismissFormSheetControllerAnimated:YES completionHandler:^(MZFormSheetController *formSheetController) {
    }];
  }
 
}

- (BOOL)validateInput:(UITextView *)textView {
  NSString *error;
  NSString *kind = [self.data objectForKey:@"kind"];

  if ([kind isEqualToString:@"introduction"]) {
    if (textView.text.length > 10000) {
      error = NSLocalizedString(@"register_error_introduction_length", @"自己紹介は10,000文字以下で入力してください") ;
    }
  } else if ([kind isEqualToString:@"hobby"]) {
    if (textView.text.length > 10000) {
      error = NSLocalizedString(@"register_error_hobby_length", @"趣味は10,000文字以下で入力してください") ;
    }
  }
  
  if (error != nil) {
    UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"error", @"エラー")
                                                         message:error
                                                        delegate:nil
                                               cancelButtonTitle:NSLocalizedString(@"close", @"閉じる")
                                               otherButtonTitles:nil];
    [errorAlert show];
    return false;
  } else {
    return true;
  }
  
  
}

#pragma mark - Save actions
- (void)saveField:(UITextView *)textView {
  LXAppDelegate* app = [LXAppDelegate currentDelegate];
  NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObject:[app getToken] forKey:@"token"];
  
  
  //LatteAPIClient *api = [LatteAPIClient sharedClient];
  MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.view];
  [self.view addSubview:HUD];
  HUD.mode = MBProgressHUDModeIndeterminate;
  [HUD show:YES];


  NSString *kind = [self.data objectForKey:@"kind"];
  [params setObject:textView.text forKey:kind];
  
  
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
