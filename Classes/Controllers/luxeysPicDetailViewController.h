//
//  luxeysPicDetailViewController.h
//  Latte
//
//  Created by Xuan Dung Bui on 8/22/12.
//  Copyright (c) 2012 LUXEYS. All rights reserved.
//

#import <UIKit/UIKit.h>

@class luxeysTableViewCellComment, luxeysButtonBrown30;

@interface luxeysPicDetailViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>

@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *gestureTap;
@property (strong, nonatomic) NSDictionary *picInfo;
@property (strong, nonatomic) IBOutlet UIView *viewTextbox;
@property (strong, nonatomic) IBOutlet UITextField *textComment;
@property (strong, nonatomic) IBOutlet luxeysButtonBrown30 *buttonSend;
@property (strong, nonatomic) IBOutlet UITableView *tablePic;
- (IBAction)touchBackground:(id)sender;
- (IBAction)touchBack:(id)sender;
- (IBAction)changeText:(id)sender;
- (IBAction)touchSend:(id)sender;

@end
