//
//  LXCameraSettingTVC.h
//  Latte camera
//
//  Created by Bui Xuan Dung on 7/14/14.
//  Copyright (c) 2014 LUXEYS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LXCameraSettingTVC : UITableViewController
@property (strong, nonatomic) IBOutlet UISwitch *switchCamera;
@property (strong, nonatomic) IBOutlet UISwitch *switchSave;
@property (strong, nonatomic) IBOutlet UISwitch *switchOrigin;

- (IBAction)changeOrigin:(id)sender;
- (IBAction)changeCamera:(id)sender;
- (IBAction)changeSave:(id)sender;

@end
