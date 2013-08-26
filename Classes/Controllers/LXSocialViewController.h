//
//  LXSocialViewController.h
//  Latte camera
//
//  Created by Bui Xuan Dung on 8/26/13.
//  Copyright (c) 2013 LUXEYS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LXSocialViewController : UITableViewController
@property (strong, nonatomic) IBOutlet UISwitch *swtichFacebook;
@property (strong, nonatomic) IBOutlet UISwitch *switchTwitter;
- (IBAction)toggleFacebook:(id)sender;
- (IBAction)toggleTwitter:(id)sender;

@end
