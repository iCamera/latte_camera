//
//  luxeysPicEditViewController.h
//  Latte
//
//  Created by Xuan Dung Bui on 2012/10/11.
//  Copyright (c) 2012年 LUXEYS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface luxeysPicEditViewController : UITableViewController <UIActionSheetDelegate>
@property (strong, nonatomic) IBOutlet UIImageView *imagePic;
@property (strong, nonatomic) IBOutlet UITextField *textTitle;
@property (strong, nonatomic) IBOutlet UITextField *textDesc;
@property (strong, nonatomic) IBOutlet UISwitch *switchGPS;
@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *gestureTap;
- (IBAction)touchPost:(id)sender;
- (IBAction)touchBack:(id)sender;
- (IBAction)touchBackground:(id)sender;

@end
