//
//  LXSettingRootViewController.h
//  Latte camera
//
//  Created by Bui Xuan Dung on 3/2/13.
//  Copyright (c) 2013 LUXEYS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LXCanvasViewController.h"

@interface LXSettingRootViewController : UITableViewController<UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (strong, nonatomic) IBOutlet UILabel *labelVersion;
@property (strong, nonatomic) IBOutlet UIButton *buttonProfilePicture;
@property (strong, nonatomic) IBOutlet UIImageView *imageCover;

@property (strong, nonatomic) IBOutlet UIView *viewWrapHeader;

- (IBAction)touchSetPicture:(id)sender;
- (IBAction)touchSetCover:(id)sender;

@end
