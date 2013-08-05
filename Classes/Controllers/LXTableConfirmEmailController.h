//
//  LXTableConfirmEmailController.h
//  Latte camera
//
//  Created by Bui Xuan Dung on 8/1/13.
//  Copyright (c) 2013 LUXEYS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LXTableConfirmEmailController : UITableViewController
@property (strong, nonatomic) IBOutlet UILabel *labelEmail;
- (IBAction)touchClose:(id)sender;
- (IBAction)touchHelp:(id)sender;
- (IBAction)touchResend:(id)sender;

@end
