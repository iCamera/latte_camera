//
//  luxeysCameraViewController.h
//  Latte
//
//  Created by Xuan Dung Bui on 7/20/12.
//  Copyright (c) 2012 LUXEYS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GPUImage.h"
#import "luxeysNavBar.h"
#import "luxeysPicEditViewController.h"

@interface luxeysCameraViewController : UIViewController <UIActionSheetDelegate, UIImagePickerControllerDelegate, UIGestureRecognizerDelegate> {
    GPUImageStillCamera *videoCamera;
    UIActionSheet *sheet;
    UIImagePickerController *imagePicker;
    UIImage *imageOrg;
    GPUImageFilterPipeline *pipeFilter;
    GPUImageCropFilter *crop;
    //UIImageView *lastFrameView;
    BOOL isEditing;
    NSInteger currentEffect;
}
@property (strong, nonatomic) IBOutlet UIImageView *imageBottom;
@property (strong, nonatomic) UIActionSheet *sheet;
@property (strong, nonatomic) IBOutlet GPUImageView *cameraView;
@property (strong, nonatomic) IBOutlet UIView *viewTimer;
- (IBAction)setEffect:(id)sender;
- (IBAction)cameraTouch:(UITapGestureRecognizer *)sender;
- (IBAction)openImagePicker:(id)sender;
- (IBAction)close:(id)sender;
- (IBAction)capture:(id)sender;
- (IBAction)changeLens:(id)sender;
- (IBAction)changeTimer:(id)sender;
- (IBAction)changeFlash:(id)sender;
- (IBAction)changeCamera:(id)sender;
- (IBAction)touchTimer:(id)sender;
- (IBAction)touchSave:(id)sender;
@property (strong, nonatomic) IBOutlet UIImageView *imageAutoFocus;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollEffect;
@property (strong, nonatomic) IBOutlet UIButton *buttonCapture;
@property (strong, nonatomic) IBOutlet UIButton *buttonYes;
@property (strong, nonatomic) IBOutlet UIButton *buttonNo;
@property (strong, nonatomic) IBOutlet UIButton *buttonTimer;
@property (strong, nonatomic) IBOutlet UIButton *buttonFlash;
@property (strong, nonatomic) IBOutlet UIButton *buttonFlip;
@property (strong, nonatomic) IBOutlet UIPanGestureRecognizer *gesturePan;
- (IBAction)touchNo:(id)sender;
- (IBAction)flipCamera:(id)sender;
- (IBAction)panTarget:(UIPanGestureRecognizer *)sender;

@end
