//
//  LXImageCropViewController.h
//  Latte camera
//
//  Created by Bui Xuan Dung on 4/25/13.
//  Copyright (c) 2013 LUXEYS. All rights reserved.
//

#import "HFImageEditorViewController.h"
#import "HFImageEditorFrameView.h"

@interface LXImageCropViewController : HFImageEditorViewController

@property (strong, nonatomic) IBOutlet UIImageView *imageCropSize;

- (IBAction)panSize:(UIPanGestureRecognizer *)sender;
- (IBAction)setCropRatio:(UIButton*)sender;
- (IBAction)noCrop:(id)sender;

@end
