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

@property (strong, nonatomic) IBOutlet UILabel *labelVersion;
@property (strong, nonatomic) IBOutlet UIImageView *imageProfile;
@property (strong, nonatomic) IBOutlet UIView *viewHeader;
@property (strong, nonatomic) IBOutlet UIView *viewWrapHeader;

- (IBAction)touchSetPicture:(id)sender;

@end
