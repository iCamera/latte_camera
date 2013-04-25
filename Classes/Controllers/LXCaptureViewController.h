//
//  LXCameraViewController.h
//  Latte camera
//
//  Created by Bui Xuan Dung on 4/25/13.
//  Copyright (c) 2013 LUXEYS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GPUImage.h"

@interface LXCaptureViewController : UIViewController<CLLocationManagerDelegate, UIAccelerometerDelegate>

@property (strong, nonatomic) IBOutlet GPUImageView *viewCamera;
@property (strong, nonatomic) IBOutlet UIView *viewTopBar;
@property (strong, nonatomic) IBOutlet UIView *viewTimer;
@property (strong, nonatomic) IBOutlet UIImageView *imageAutoFocus;
@property (strong, nonatomic) IBOutlet UIButton *buttonCapture;
@property (strong, nonatomic) IBOutlet UIButton *buttonTimer;
@property (strong, nonatomic) IBOutlet UIButton *buttonFlash;
@property (strong, nonatomic) IBOutlet UIButton *buttonFlash35;
@property (strong, nonatomic) IBOutlet UIButton *buttonFlip;
@property (strong, nonatomic) IBOutlet UIButton *buttonPick;
@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *tapFocus;

@property (strong, nonatomic) IBOutlet UIButton *buttonSetNoTimer;
@property (strong, nonatomic) IBOutlet UIButton *buttonSetTimer5s;

@property (strong, nonatomic) IBOutlet UIView *viewCameraWraper;

@property (strong, nonatomic) IBOutlet UIView *viewTopBar35;
@property (strong, nonatomic) IBOutlet UIImageView *viewCanvas;

- (IBAction)cameraTouch:(UITapGestureRecognizer *)sender;
- (IBAction)changeFlash:(id)sender;
- (IBAction)touchTimer:(id)sender;
- (IBAction)capture:(id)sender;
- (IBAction)close:(id)sender;
- (IBAction)flipCamera:(id)sender;
- (IBAction)setTimer:(id)sender;

@end
