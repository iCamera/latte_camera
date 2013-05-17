//
//  LXCellUpload.h
//  Latte camera
//
//  Created by Bui Xuan Dung on 3/18/13.
//  Copyright (c) 2013 LUXEYS. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "LXUploadObject.h"

@interface LXCellUpload : UITableViewCell<UIAlertViewDelegate, LXUploadObjectDelegate, UIActionSheetDelegate>
@property (strong, nonatomic) IBOutlet UIImageView *imageupload;
@property (strong, nonatomic) IBOutlet UIProgressView *progressUpload;
@property (strong, nonatomic) IBOutlet UIButton *buttonError;

@property (strong, nonatomic) LXUploadObject *uploader;
- (IBAction)touchInfo:(id)sender;

@end
