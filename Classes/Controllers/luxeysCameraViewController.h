//
//  luxeysCameraViewController.h
//  Latte
//
//  Created by Xuan Dung Bui on 7/20/12.
//  Copyright (c) 2012 LUXEYS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "GPUImage.h"
#import "FilterManager.h"
#import "luxeysNavBar.h"
#import "luxeysPicEditViewController.h"
#import "GPUImageStillCamera+captureWithMeta.h"
#import "luxeysUtils.h"
#import "LXDrawView.h"
#import "UIImage+Resize.h"
#import "UIImage+fixOrientation.h"

#define kTimerNone       0
#define kTimer5s         1
#define kTimer10s        2
#define kTimerContinuous 3

#define kBokehModeFull 1
#define kBokehModeDisable 0

#define kBokehTabMask 1
#define kBokehTabBlur 2

#define kMaskBackgroundNone 6
#define kMaskBackgroundRound 7
#define kMaskBackgroundNatual 8

typedef enum {
    kEffect1,
    kEffect2,
    kEffect3,
    kEffect4,
    kEffect5
} EffectType;

@class luxeysCameraViewController;

@protocol LXImagePickerDelegate <NSObject>
@optional
- (void)imagePickerController:(luxeysCameraViewController *)picker didFinishPickingMediaWithData:(NSDictionary *)info;
- (void)imagePickerControllerDidCancel:(luxeysCameraViewController *)picker;
@end

@interface luxeysCameraViewController : UIViewController <UIActionSheetDelegate, UIImagePickerControllerDelegate, UIGestureRecognizerDelegate, CLLocationManagerDelegate, UIScrollViewDelegate, UIAccelerometerDelegate, LXDrawViewDelegate, UIAlertViewDelegate> {
    GPUImageStillCamera *videoCamera;
    
    GPUImagePicture *picture;
    GPUImagePicture *previewFilter;
    FilterManager *filter;
    UIActionSheet *sheet;
    UIImagePickerController *imagePicker;
    NSMutableDictionary *imageMeta;
    NSTimer *timer;
    NSInteger timerCount;

    BOOL isEditing;
    BOOL isCrop;
    BOOL isReady;
    BOOL isFinishedProcessing;
    BOOL isSaved;
    
    int bokehMode;
    int currentFocusTab;
    
    id <LXImagePickerDelegate> __unsafe_unretained delegate;

    NSInteger currentEffect;
    NSInteger currentLens;
    NSInteger currentTimer;
    NSLayoutConstraint *cameraAspect;
    NSInteger timerMode;
    CLLocationManager *locationManager;
    CLLocation *bestEffortAtLocation;
    UIImageOrientation imageOrientation;
    UIInterfaceOrientation orientationLast;
}
@property (strong, nonatomic) IBOutlet UIView *viewBottomBar;
@property (strong, nonatomic) IBOutlet UIImageView *imageBottom;
@property (strong, nonatomic) IBOutlet GPUImageView *cameraView;
@property (strong, nonatomic) IBOutlet UIView *viewTimer;
@property (strong, nonatomic) IBOutlet UIImageView *imageAutoFocus;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollEffect;
@property (strong, nonatomic) IBOutlet UIButton *buttonCapture;
@property (strong, nonatomic) IBOutlet UIButton *buttonYes;
@property (strong, nonatomic) IBOutlet UIButton *buttonNo;
@property (strong, nonatomic) IBOutlet UIButton *buttonTimer;
@property (strong, nonatomic) IBOutlet UIButton *buttonFlash;
@property (strong, nonatomic) IBOutlet UIButton *buttonFlip;
@property (strong, nonatomic) IBOutlet UIPanGestureRecognizer *gesturePan;
@property (strong, nonatomic) IBOutlet UIButton *buttonCrop;
@property (strong, nonatomic) IBOutlet UIButton *buttonPick;
@property (strong, nonatomic) IBOutlet UIButton *buttonScroll;
@property (strong, nonatomic) IBOutlet UIButton *buttonSetNoTimer;
@property (strong, nonatomic) IBOutlet UIButton *buttonSetTimer5s;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollCamera;
@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *tapFocus;
@property (strong, nonatomic) IBOutlet UIView *viewFocusControl;
@property (strong, nonatomic) IBOutlet UIButton *buttonToggleFocus;
@property (strong, nonatomic) IBOutlet UIView *viewCameraWraper;
@property (strong, nonatomic) IBOutlet LXDrawView *viewDraw;
@property (strong, nonatomic) IBOutlet UIButton *buttonChangeLens;
@property (strong, nonatomic) IBOutlet UIView *viewMask;
@property (strong, nonatomic) IBOutlet UIView *viewBlur;
@property (strong, nonatomic) IBOutlet UIView *viewFocal;
@property (strong, nonatomic) IBOutlet UIImageView *imageMaskRect;
@property (strong, nonatomic) IBOutlet UIImageView *imageMaskCircle;


@property (strong, nonatomic) IBOutlet UIButton *buttonMove;
@property (strong, nonatomic) IBOutlet UIButton *buttonPaintMask;
@property (strong, nonatomic) IBOutlet UIButton *buttonFocal;
@property (strong, nonatomic) IBOutlet UIButton *buttonBackground;
@property (strong, nonatomic) IBOutlet UIButton *buttonBackgroundRound;
@property (strong, nonatomic) IBOutlet UIButton *buttonBackgroundNatual;
@property (strong, nonatomic) IBOutlet UIButton *buttonBackgroundNone;

@property (unsafe_unretained) id <LXImagePickerDelegate> delegate;

- (IBAction)setEffect:(id)sender;
- (IBAction)cameraTouch:(UITapGestureRecognizer *)sender;
- (IBAction)openImagePicker:(id)sender;
- (IBAction)close:(id)sender;
- (IBAction)capture:(id)sender;
- (IBAction)changeLens:(id)sender;
- (IBAction)changeFlash:(id)sender;
- (IBAction)changeCamera:(id)sender;
- (IBAction)touchTimer:(id)sender;
- (IBAction)touchSave:(id)sender;
- (IBAction)toggleCrop:(id)sender;
- (IBAction)toggleEffect:(UIButton*)sender;
- (IBAction)touchNo:(id)sender;
- (IBAction)flipCamera:(id)sender;
- (IBAction)panTarget:(UIPanGestureRecognizer *)sender;
- (IBAction)setTimer:(id)sender;
- (IBAction)touchFocusTab:(UIButton*)sender;
- (IBAction)setMask:(UIButton*)sender;
- (IBAction)changeBlur:(UISlider*)sender;
- (IBAction)changeHighlight:(UISlider*)sender;
- (IBAction)changePen:(UISlider *)sender;
- (IBAction)pinchMask:(UIPinchGestureRecognizer *)sender;
- (IBAction)rotateMask:(UIRotationGestureRecognizer *)sender;
- (IBAction)panMask:(UIPanGestureRecognizer *)sender;

@end
