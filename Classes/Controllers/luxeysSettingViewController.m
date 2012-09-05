//
//  luxeysSettingViewController.m
//  Latte
//
//  Created by Xuan Dung Bui on 8/20/12.
//  Copyright (c) 2012 LUXEYS. All rights reserved.
//

#import "luxeysSettingViewController.h"
#import "luxeysAppDelegate.h"

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
        QRadioElement *radioStatus = [[QRadioElement alloc] initWithItems:[[NSArray alloc]
                                                                           initWithObjects:@"全体", @"会員まで", @"友達まで", @"非公開",nil]
                                                                 selected:0
                                                                    title:@"公開"];
        radioStatus.key = @"picture_status";
        radioStatus.controllerAction = @"handleUpdate:";
        
        [secPhoto addElement:radioStatus];
        [root addSection:secPhoto];
        
        QSection *secProfile = [[QSection alloc] initWithTitle:@"プロフィール設定"];
        QEntryElement *entryNickname = [[QEntryElement alloc] initWithTitle:@"ニックネーム" Value:[app.currentUser objectForKey:@"name"] Placeholder:@"ニックネーム"];
        entryNickname.key = @"name";
        entryNickname.controllerAction = @"handleUpdate:";
        
        QRadioElement *radioGender = [[QRadioElement alloc] initWithItems:[[NSArray alloc] initWithObjects:@"男性", @"女性", nil] selected:0 title:@"性別"];
        radioGender.key = @"gender";
        radioGender.controllerAction = @"handleUpdate:";
        
        QDateTimeInlineElement *pickBirth = [[QDateTimeInlineElement alloc] initWithTitle:@"生年月日" date:[NSDate date]];
        pickBirth.key = @"birthday";
        pickBirth.controllerAction = @"handleUpdate:";
        
        QEntryElement *entryOccupy = [[QEntryElement alloc] initWithTitle:@"職業" Value:[app.currentUser objectForKey:@"name"] Placeholder:@"職業"];
        entryOccupy.key = @"occupation";
        entryOccupy.controllerAction = @"handleUpdate:";
        
        pickBirth.mode = UIDatePickerModeDate;
        [secProfile addElement:entryNickname];
        [secProfile addElement:radioGender];
        [secProfile addElement:pickBirth];
        [root addSection:secProfile];
        
        QSection *subLogout = [[QSection alloc] init];
        QButtonElement *buttonLogout = [[QButtonElement alloc] initWithTitle:@"ログアウト"];
        buttonLogout.controllerAction = @"handleLogout:";
        [subLogout addElement:buttonLogout];
        [root addSection:subLogout];
        
        self.root = root;
        self.resizeWhenKeyboardPresented =YES;
        self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg_sub_back.png"]];
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
    NSLog(@"Change key:%@ to", element.key);
}

@end
