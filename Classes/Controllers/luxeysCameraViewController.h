//
//  luxeysCameraViewController.h
//  Latte
//
//  Created by Xuan Dung Bui on 7/20/12.
//  Copyright (c) 2012 LUXEYS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GPUImage.h"

@interface luxeysCameraViewController : UIViewController <UIActionSheetDelegate> {
    GPUImageStillCamera *videoCamera;
    UIActionSheet *sheet;
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
@property (strong, nonatomic) IBOutlet UIImageView *imageAutoFocus;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollEffect;
@property (strong, nonatomic) IBOutlet UIButton *buttonCapture;
@property (strong, nonatomic) IBOutlet UIButton *buttonYes;
@property (strong, nonatomic) IBOutlet UIButton *buttonNo;
- (IBAction)touchNo:(id)sender;
- (IBAction)touchYes:(id)sender;
- (IBAction)flipCamera:(id)sender;

@end
