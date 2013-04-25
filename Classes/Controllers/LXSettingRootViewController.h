//
//  LXSettingRootViewController.h
//  Latte camera
//
//  Created by Bui Xuan Dung on 3/2/13.
//  Copyright (c) 2013 LUXEYS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LXCanvasViewController.h"

@interface LXSettingRootViewController : UITableViewController<LXImagePickerDelegate>
- (IBAction)touchClose:(id)sender;
@property (strong, nonatomic) IBOutlet UILabel *labelVersion;
@property (strong, nonatomic) IBOutlet UIImageView *imageProfile;
- (IBAction)touchSetPicture:(id)sender;
@property (strong, nonatomic) IBOutlet UIView *viewHeader;

@end
