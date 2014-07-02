//
//  LXProfileSettingTableViewController.m
//  Latte camera
//
//  Created by Serkan Unal on 6/18/14.
//  Copyright (c) 2014 LUXEYS. All rights reserved.
//

#import "LXProfileSettingTableViewController.h"
#import "LXSelectorVC.h"
#import "LXTextViewVC.h"

#import "LXSettingsProfileTVC.h"
#import "LXProfileSettingTableViewCell.h"
#import "LXAppDelegate.h"
#import "MZFormSheetSegue.h"
#import "MBProgressHUD.h"
#import "LatteAPIClient.h"
#import "LXUtils.h"
#import "User.h"

@interface LXProfileSettingTableViewController ()
@property (strong, nonatomic) User *user;
@property (nonatomic, getter = isEditing) BOOL editing;
@end

@implementation LXProfileSettingTableViewController

@synthesize user;
@synthesize textUsername;
@synthesize textGender;
@synthesize textBloodType;
@synthesize textCurrentAddress;
@synthesize textBirthday;
@synthesize textHobby;
@synthesize textHometown;
@synthesize textIntroduction;
@synthesize textNationality;
@synthesize textOccupation;
@synthesize editing;

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
    [self setupCells];
    
    // This will remove extra separators from tableview
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - user functions
-(void)setupCells {
    LXAppDelegate* app = (LXAppDelegate*)[UIApplication sharedApplication].delegate;
    self.user = app.currentUser;
    [self.tableView reloadData];
    keys = [NSArray arrayWithObjects:@"name", @"gender", @"bloodtype", @"birthday", @"current_residence", @"hometown", @"occupation", @"introduction", @"hobby", @"nationality", nil];
    //Username
    textUsername.tag = 0;
    textUsername.text = user.name;
    //Gender
    genders = [NSArray arrayWithObjects:NSLocalizedString(@"Male", @"Male"), NSLocalizedString(@"Female", @"Female"), nil];
    textGender.tag = 1;
    if (user.gender) {
        textGender.text = genders[[user.gender integerValue] - 1];
    }
    //Blood type
    textBloodType.tag = 2;
    textBloodType.text = user.bloodType;
    //birthday - add...
    
    textCurrentAddress.tag = 4;
    textCurrentAddress.text = user.currentResidence;
    
    textBirthday.tag = 4;
    if (user.birthdate.length) {
        //Convert string to date.
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"yyyy-MM-dd"];
        NSDate *date = [dateFormat dateFromString:user.birthdate];
        
        NSString *formatString = [NSDateFormatter dateFormatFromTemplate:@"EydMMM" options:0
                                                                  locale:[NSLocale currentLocale]];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:formatString];
        
        //Localized date.
        textBirthday.text =[dateFormatter stringFromDate:date];
        
    }
    textHometown.tag = 5;
    textHometown.text = user.hometown;
    
    textOccupation.tag = 6;
    textOccupation.text = user.occupation;
    
    textIntroduction.tag = 7;
    textIntroduction.text = user.introduction;
    
    textHobby.tag = 8;
    textHobby.text = user.hobby;
    
    textNationality.tag = 9;
    textNationality.text = user.nationality;
    
}

#pragma mark - textField
-(void)textFieldDidBeginEditing:(UITextField *)textField {
    editing = TRUE;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder]; //Close the keyboard
    return NO;
}

-(BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    return ([self validateInput:textField]);
}
-(void)textFieldDidEndEditing:(UITextField *)textField {
    if (editing) {
        [self saveField:textField];
    }
    editing = FALSE;
}

#pragma mark - Validations
- (BOOL)validateInput:(UITextField *)textField {
    NSString *error;
    
    if (textField.tag == 0) {
        if (textField.text.length == 0) { // Username
            error = NSLocalizedString(@"register_error_username_require", @"ニックネームを入力してください") ;
        } else if (textField.text.length > 20 ) {
            error = NSLocalizedString(@"register_error_username_length", @"ニックネームは20文字以下で入力してください") ;
        }
    } else if (textField.tag == 6) { // Occupation
        if (textField.text.length > 100 ) {
            error = NSLocalizedString(@"register_error_occupation_length", @"職業は100文字以下で入力してください") ;
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
- (void)saveField:(UITextField *)textField {
    LXAppDelegate* app = [LXAppDelegate currentDelegate];
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObject:[app getToken] forKey:@"token"];
    MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:HUD];
    HUD.mode = MBProgressHUDModeIndeterminate;
    [HUD show:YES];
    
    [params setObject:textField.text forKey:keys[textField.tag]];
    
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

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    if (editing) {
        //return NO; //Cancel segue if (textview) editing other field. // <- Not sure if we want to that.
    }
    return YES;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    MZFormSheetSegue *sheet = (MZFormSheetSegue*)segue;
    sheet.formSheetController.cornerRadius = 3;
    sheet.formSheetController.movementWhenKeyboardAppears = MZFormSheetWhenKeyboardAppearsCenterVertically;
    sheet.formSheetController.shouldDismissOnBackgroundViewTap = YES;
    sheet.formSheetController.shouldCenterVertically = TRUE;
    int height = 300;
    NSDictionary *data;
    
    if ([[segue identifier] isEqualToString:@"gender"]){  //NSNumber
        NSNumber *zero = [NSNumber numberWithInt:0];
        data = @{
                 @"value" : self.user.gender ? self.user.gender : zero,
                 @"kind": segue.identifier
                 };
    } else if ([[segue identifier] isEqualToString:@"bloodtype"]){  //NSString
        data = @{
                 @"value" : self.user.bloodType ? self.user.bloodType : @"",
                 @"kind": segue.identifier
                 };
    } else if ([[segue identifier] isEqualToString:@"birthday"]){
        data = @{
                 @"value" : self.user.birthdate ? self.user.birthdate : @"",
                 @"kind": segue.identifier
                 };
        
    } else if ([[segue identifier] isEqualToString:@"introduction"]){
        data = @{
                 @"value" : self.user.introduction ? self.user.introduction : @"",
                 @"title": NSLocalizedString(@"introduction", @"自己紹介"),
                 @"kind": segue.identifier
                 };
        height = 210;
    } else if ([[segue identifier] isEqualToString:@"hobby"]){
        data = @{
                 @"value" : self.user.hobby ? self.user.hobby : @"",
                 @"title": NSLocalizedString(@"hobby", @"趣味"),
                 @"kind": segue.identifier
                 };
        height = 210;
    } else if ([[segue identifier] isEqualToString:@"nationality"]){
        data = @{ @"value" : self.user.nationality ? self.user.nationality : @"" };
    }
    
    sheet.formSheetController.presentedFormSheetSize = CGSizeMake(300, height);
    sheet.formSheetController.didDismissCompletionHandler = ^(UIViewController *vc){
        [self updateData]; //Call after return from sheet.
    };
    
    //all segues will call same setup function.
    if([segue.destinationViewController respondsToSelector:@selector(initData:)]) {
        [segue.destinationViewController performSelector:@selector(initData:)
                                              withObject:data];
    }
}

-(void)updateData {
    // refresh User after return from seque.
    [self setupCells];
}

@end
