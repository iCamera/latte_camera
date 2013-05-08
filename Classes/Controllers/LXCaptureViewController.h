//
//  LXCameraViewController.h
//  Latte camera
//
//  Created by Bui Xuan Dung on 4/25/13.
//  Copyright (c) 2013 LUXEYS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GPUImage.h"
#import "LXCamCaptureManager.h"
#import "LXCanvasViewController.h"

@interface LXCaptureViewController : UIViewController <CLLocationManagerDelegate, UIAccelerometerDelegate, LXCamCaptureManagerDelegate, UIGestureRecognizerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (strong, nonatomic) IBOutlet UIView *viewCamera;
@property (strong, nonatomic) IBOutlet UIView *viewTopBar;
@property (strong, nonatomic) IBOutlet UIView *viewTimer;
@property (strong, nonatomic) IBOutlet UIImageView *imageAutoFocus;
@property (strong, nonatomic) IBOutlet UIButton *buttonCapture;
@property (strong, nonatomic) IBOutlet UIButton *buttonFlash;
@property (strong, nonatomic) IBOutlet UIButton *buttonFlash35;
@property (strong, nonatomic) IBOutlet UIButton *buttonPick;
@property (strong, nonatomic) IBOutlet UIImageView *imagePreview;
@property (strong, nonatomic) IBOutlet UIView *viewFlash;

@property (strong, nonatomic) IBOutlet UIButton *buttonSetNoTimer;
@property (strong, nonatomic) IBOutlet UIButton *buttonSetTimer5s;

@property (strong, nonatomic) IBOutlet UIView *viewCameraWraper;

@property (strong, nonatomic) IBOutlet UIView *viewTopBar35;
@property (strong, nonatomic) IBOutlet UIImageView *viewCanvas;
@property (strong, nonatomic) IBOutlet UIButton *buttonQuick;

@property (weak, nonatomic) id <LXImagePickerDelegate> delegate;

- (IBAction)changeFlash:(id)sender;
- (IBAction)touchTimer:(id)sender;
- (IBAction)capture:(id)sender;
- (IBAction)close:(id)sender;
- (IBAction)flipCamera:(id)sender;
- (IBAction)setTimer:(id)sender;
- (IBAction)touchQuick:(UIButton *)sender;
- (IBAction)touchPick:(id)sender;

- (void)capturePhotoAsync;

@end
