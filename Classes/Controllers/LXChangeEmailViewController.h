//
//  LXChangePasswordViewController.h
//  Latte camera
//
//  Created by Bui Xuan Dung on 8/1/13.
//  Copyright (c) 2013 LUXEYS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LXChangeEmailViewController : UIViewController

- (IBAction)touchChange:(id)sender;
@property (strong, nonatomic) IBOutlet UITextField *textMail;
@property (strong, nonatomic) IBOutlet UITextField *textPassword;

@end
