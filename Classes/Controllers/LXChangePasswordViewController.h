//
//  LXChangePasswordViewController.h
//  Latte camera
//
//  Created by Bui Xuan Dung on 8/1/13.
//  Copyright (c) 2013 LUXEYS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LXChangePasswordViewController : UIViewController
- (IBAction)tapBackground:(id)sender;
@property (strong, nonatomic) IBOutlet UIView *viewSub;
- (IBAction)touchChange:(id)sender;
@property (strong, nonatomic) IBOutlet UITextField *textCurrentPassword;
@property (strong, nonatomic) IBOutlet UITextField *textNewPassword;
@property (strong, nonatomic) IBOutlet UITextField *textConfirmPassword;

@end
