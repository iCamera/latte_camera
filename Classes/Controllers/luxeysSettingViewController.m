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
#import "luxeysLatteAPIClient.h"

@interface luxeysSettingViewController ()

@end
@implementation luxeysSettingViewController

- (id)init {
    self = [super init];
    if (self) {
        luxeysAppDelegate *app = (luxeysAppDelegate*)[[UIApplication sharedApplication] delegate];
        
        QRootElement *root = [[QRootElement alloc] init];
        
        root.title = @"設定";
        root.grouped = YES;
        
        QSection *secPhoto = [[QSection alloc] initWithTitle:@"写真設定"];
        
        NSDictionary *dictPermission = [NSDictionary dictionaryWithObjectsAndKeys:
            [NSNumber numberWithInt:0], @"非公開",
            [NSNumber numberWithInt:10], @"友達まで",
            [NSNumber numberWithInt:30], @"会員まで",
            [NSNumber numberWithInt:40], @"全体", nil];
//        NSArray *test = [NSArray arrayWithObjects:@"非公開", @"友達まで", @"会員まで", @"全体", nil];

        QRadioElement *radioStatus = [[QRadioElement alloc] initWithDict:dictPermission
                                                                selected:3
                                                                   title:@"公開"];
        radioStatus.key = @"picture_status";
        radioStatus.controllerAction = @"handleUpdate:";
        
        [secPhoto addElement:radioStatus];
        [root addSection:secPhoto];
        
        QSection *secProfile = [[QSection alloc] initWithTitle:@"プロフィール設定"];

        QEntryElement *entryNickname = [[QEntryElement alloc] initWithTitle:@"ニックネーム" Value:[app.currentUser objectForKey:@"name"] Placeholder:@"ニックネーム"];
        entryNickname.key = @"name";
        entryNickname.delegate = self;
        
        QRadioElement *radioGender = [[QRadioElement alloc] initWithItems:[[NSArray alloc] initWithObjects:@"男性", @"女性", nil] selected:0 title:@"性別"];
        radioGender.key = @"gender";
        radioGender.controllerAction = @"handleUpdate:";
        
        QDateTimeInlineElement *pickBirth = [[QDateTimeInlineElement alloc] initWithTitle:@"生年月日" date:[NSDate date]];
        pickBirth.key = @"birthday";
        pickBirth.controllerAction = @"handleUpdate:";

        QEntryElement *entryResidence = [[QEntryElement alloc] initWithTitle:@"現住所" Value:[app.currentUser objectForKey:@"residence"] Placeholder:@"現住所"];
        entryResidence.key = @"current_residence";
        entryResidence.delegate = self;

        QEntryElement *entryHometown = [[QEntryElement alloc] initWithTitle:@"出身地" Value:[app.currentUser objectForKey:@"hometown"] Placeholder:@"出身地"];
        entryHometown.key = @"hometown";
        entryHometown.delegate = self;
        
        QEntryElement *entryOccupy = [[QEntryElement alloc] initWithTitle:@"職業" Value:[app.currentUser objectForKey:@"occupation"] Placeholder:@"職業"];
        entryOccupy.key = @"occupation";
        entryOccupy.delegate = self;

        QMultilineElement *entryIntro = [[QMultilineElement alloc] initWithTitle:@"自己紹介" value:[app.currentUser objectForKey:@"introduction"]];
        entryIntro.key = @"introduction";
        entryIntro.controllerAction = @"handleUpdate:";
        
        QMultilineElement *entryHobby = [[QMultilineElement alloc] initWithTitle:@"趣味" value:[app.currentUser objectForKey:@"hobby"]];
        entryHobby.key = @"hobby";
        entryHobby.controllerAction = @"handleUpdate:";
        
        pickBirth.mode = UIDatePickerModeDate;
        [secProfile addElement:entryNickname];
        [secProfile addElement:radioGender];
        [secProfile addElement:pickBirth];
        [secProfile addElement:entryResidence];
        [secProfile addElement:entryHometown];
        [secProfile addElement:entryOccupy];
        [secProfile addElement:entryIntro];
        [secProfile addElement:entryHobby];
        [root addSection:secProfile];
        
        QSection *subLogout = [[QSection alloc] init];
        QButtonElement *buttonLogout = [[QButtonElement alloc] initWithTitle:@"ログアウト"];
        buttonLogout.controllerAction = @"handleLogout:";
        [subLogout addElement:buttonLogout];
        [root addSection:subLogout];
        
        self.root = root;
        self.resizeWhenKeyboardPresented = YES;
        
        //Style
        self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg_sub_back.png"]];
        
        luxeysButtonBack *buttonBack = [[luxeysButtonBack alloc] initWithFrame:CGRectMake(0, 0, 60, 30)];
        [buttonBack addTarget:self.navigationController action:@selector(popViewControllerAnimated:) forControlEvents:UIControlEventTouchUpInside];
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:buttonBack];
    }
    return self;
}

- (void)setQuickDialogTableView:(QuickDialogTableView *)aQuickDialogTableView {
    [super setQuickDialogTableView:aQuickDialogTableView];
    
    self.quickDialogTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.quickDialogTableView.styleProvider = self;
    
    ((QEntryElement *)[self.root elementWithKey:@"profile_nickname"]).delegate = self;
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

-(void)handleUpdate:(QElement *) element {
    luxeysAppDelegate* app = (luxeysAppDelegate*)[UIApplication sharedApplication].delegate;
    NSMutableDictionary *param = [NSMutableDictionary dictionaryWithObject:[app getToken] forKey:@"token"];
    
    NSLog(@"Class %@", NSStringFromClass([element class]));

    if ([element isKindOfClass:[QEntryElement class]])
    {
        QEntryElement *tmp = (id)element;
        [param setValue:tmp.textValue forKey:tmp.key];
    }
    if ([element isKindOfClass:[QRadioElement class]])
    {
        QRadioElement *tmp = (id)element;
        [param setValue:tmp.selectedValue forKey:tmp.key];
    }
    
    [[luxeysLatteAPIClient sharedClient] postPath:@"api/user/me/update"
                                      parameters: param
                                         success:^(AFHTTPRequestOperation *operation, NSDictionary *JSON) {
                                             
                                         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                             NSLog(@"Something went wrong (Setting)");
                                         }];
    
    //QRadioElement* test = (QRadioElement*)element;
    //NSNumber* test2 = (id)test.selectedValue;
    //NSLog(@"Change key:%@ to %d", element.key, [test2 integerValue]);
}

- (void)displayViewController:(UIViewController *)newController {
    luxeysButtonBack *buttonBack = [[luxeysButtonBack alloc] initWithFrame:CGRectMake(0, 0, 60, 30)];
    [buttonBack addTarget:newController.navigationController action:@selector(popViewControllerAnimated:) forControlEvents:UIControlEventTouchUpInside];
    newController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:buttonBack];
    [super displayViewController:newController];
}

- (void)QEntryDidEndEditingElement:(QEntryElement *)element andCell:(QEntryTableViewCell *)cell {
    luxeysAppDelegate* app = (luxeysAppDelegate*)[UIApplication sharedApplication].delegate;
    NSMutableDictionary *param = [NSMutableDictionary dictionaryWithObject:[app getToken] forKey:@"token"];
    
    if ([element.key isEqualToString:@"name"]) {
        if (element.textValue.length == 0) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                            message:@"Name must not be empty"
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
            return;
        }
    }
    
    [param setValue:element.textValue forKey:element.key];
    
    [[luxeysLatteAPIClient sharedClient] postPath:@"api/user/me/update"
                                       parameters: param
                                          success:^(AFHTTPRequestOperation *operation, NSDictionary *JSON) {
                                              
                                          } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                              NSLog(@"Something went wrong (Setting)");
                                          }];
}

@end
