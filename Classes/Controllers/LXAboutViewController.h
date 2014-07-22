//
//  LXAboutViewController.h
//  Latte camera
//
//  Created by Xuan Dung Bui on 2013/01/17.
//  Copyright (c) 2013年 LUXEYS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LXAppDelegate.h"

@interface LXAboutViewController : UITableViewController<UIAlertViewDelegate>
@property (strong, nonatomic) IBOutlet UITextView *textForm;
@property (strong, nonatomic) IBOutlet UITextField *textEmail;
@property (weak, nonatomic) IBOutlet UITextView *textIntro;

- (IBAction)touchSend:(id)sender;

@end
