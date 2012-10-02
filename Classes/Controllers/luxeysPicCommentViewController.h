//
//  luxeysPicCommentViewController.h
//  Latte
//
//  Created by Xuan Dung Bui on 2012/09/26.
//  Copyright (c) 2012年 LUXEYS. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "luxeysButtonBrown30.h"

@interface luxeysPicCommentViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) IBOutlet UITableView *tableComment;
@property (strong, nonatomic) IBOutlet UIImageView *viewImage;
@property (strong, nonatomic) IBOutlet UILabel *labelTitle;
@property (strong, nonatomic) IBOutlet UILabel *labelAuthor;
@property (strong, nonatomic) IBOutlet UIView *viewComment;
@property (strong, nonatomic) IBOutlet luxeysButtonBrown30 *buttonSubmit;
@property (strong, nonatomic) IBOutlet UITextField *textComment;
@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *gestureTap;
@property (strong, nonatomic) IBOutlet UIView *viewHeader;
- (IBAction)touchClose:(id)sender;
- (IBAction)touchSubmit:(id)sender;
- (IBAction)tapBackground:(id)sender;
- (IBAction)changeText:(id)sender;

- (void)setPic:(NSDictionary *)aPic;

@end
