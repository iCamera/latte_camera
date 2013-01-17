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
#import "LXNavBar.h"
#import "LXPicEditViewController.h"
#import "LXUtils.h"
#import "LXDrawView.h"
#import "UIImage+Resize.h"
#import "UIImage+fixOrientation.h"
#import "MBProgressHUD.h"
#import "LXFilterDetail.h"
#import "LXFilterDOF.h"
#import "LXFilterFish.h"
#import "LXFilterText.h"
#import "GPUImageStillCamera+captureWithMeta.h"

#define kTimerNone       0
#define kTimer5s         1
#define kTimer10s        2
#define kTimerContinuous 3

#define kTabPreview 0
#define kTabEffect 1
#define kTabBokeh 2
#define kTabBasic 3
#define kTabLens 4
#define kTabText 5
#define kTabTextEdit 51

#define kMaskBlurNone 5
#define kMaskBlurWeak 6
#define kMaskBlurNormal 7
#define kMaskBlurStrong 8

typedef enum {
    kEffect1,
    kEffect2,
    kEffect3,
    kEffect4,
    kEffect5
} EffectType;

@class LXCameraViewController;

@protocol LXImagePickerDelegate <NSObject>
@optional
- (void)imagePickerController:(LXCameraViewController *)picker didFinishPickingMediaWithData:(NSDictionary *)info;
- (void)imagePickerControllerDidCancel:(LXCameraViewController *)picker;
@end

@interface LXCameraViewController : UIViewController <UIActionSheetDelegate, UIImagePickerControllerDelegate, UIGestureRecognizerDelegate, CLLocationManagerDelegate, UIScrollViewDelegate, UIAccelerometerDelegate, LXDrawViewDelegate, UIAlertViewDelegate, UITextFieldDelegate> {
    GPUImageStillCamera *videoCamera;
    GPUImageSharpenFilter *filterSharpen;
    GPUImageFilterPipeline *pipe;
    LXFilterDetail *filter;
    LXFilterDOF *filterDOF;
    LXFilterFish *filterFish;
    LXFilterText *filterText;
    GPUImageFilter *effect;
    FilterManager *effectManager;
    
    GPUImagePicture *picture;
    GPUImagePicture *previewFilter;
    GPUImageRawDataInput *pictureDOF;
    GPUImageRawDataInput *pictureText;
    CGSize picSize;
    CGSize previewSize;
    
    UIActionSheet *sheet;
    UIImagePickerController *imagePicker;
    NSMutableDictionary *imageMeta;
    NSTimer *timer;
    NSInteger timerCount;
    CGSize keyboardSize;
    CGPoint posText;
    CGFloat mCurrentScale;
    CGFloat mLastScale;

    BOOL isEditing;
    BOOL isSaved;
    
    id <LXImagePickerDelegate> __unsafe_unretained delegate;

    NSInteger currentEffect;
    NSInteger currentLens;
    NSInteger currentTimer;
    NSString *currentFont;
    NSString *currentText;
    CGFloat currentSharpness;
    NSInteger currentMask;
    
    NSLayoutConstraint *cameraAspect;
    NSInteger timerMode;
    CLLocationManager *locationManager;
    CLLocation *bestEffortAtLocation;
    UIImageOrientation imageOrientation;
    UIImageOrientation orientationLast;
    MBProgressHUD *HUD;
    
    NSData *savedData;
    UIImage *savedPreview;
    NSInteger currentTab;
}
@property (strong, nonatomic) IBOutlet UIView *viewBottomBar;

@property (strong, nonatomic) IBOutlet GPUImageView *viewCamera;
@property (strong, nonatomic) IBOutlet UIView *viewTimer;
@property (strong, nonatomic) IBOutlet UIImageView *imageAutoFocus;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollEffect;
@property (strong, nonatomic) IBOutlet UIButton *buttonCapture;
@property (strong, nonatomic) IBOutlet UIButton *buttonYes;
@property (strong, nonatomic) IBOutlet UIButton *buttonNo;
@property (strong, nonatomic) IBOutlet UIButton *buttonTimer;
@property (strong, nonatomic) IBOutlet UIButton *buttonFlash;
@property (strong, nonatomic) IBOutlet UIButton *buttonFlip;
@property (strong, nonatomic) IBOutlet UIButton *buttonPick;
@property (strong, nonatomic) IBOutlet UIButton *buttonReset;
@property (strong, nonatomic) IBOutlet UIButton *buttonPickTop;

@property (strong, nonatomic) IBOutlet UIPanGestureRecognizer *gesturePan;
@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *tapFocus;
@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *tapCloseHelp;
@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *tapDoubleEditText;

@property (strong, nonatomic) IBOutlet UIButton *buttonSetNoTimer;
@property (strong, nonatomic) IBOutlet UIButton *buttonSetTimer5s;

@property (strong, nonatomic) IBOutlet UIView *viewFocusControl;
@property (strong, nonatomic) IBOutlet UIView *viewLensControl;
@property (strong, nonatomic) IBOutlet UIView *viewBasicControl;
@property (strong, nonatomic) IBOutlet UIView *viewTextControl;
@property (strong, nonatomic) IBOutlet UIView *viewEffectControl;

@property (strong, nonatomic) IBOutlet UIView *viewCameraWraper;
@property (strong, nonatomic) IBOutlet LXDrawView *viewDraw;

@property (strong, nonatomic) IBOutlet UIButton *buttonToggleEffect;
@property (strong, nonatomic) IBOutlet UIButton *buttonToggleFocus;
@property (strong, nonatomic) IBOutlet UIButton *buttonToggleBasic;
@property (strong, nonatomic) IBOutlet UIButton *buttonToggleLens;
@property (strong, nonatomic) IBOutlet UIButton *buttonToggleText;

@property (strong, nonatomic) IBOutlet UISwitch *buttonBackgroundNatual;
@property (strong, nonatomic) IBOutlet UISwitch *switchGain;
@property (strong, nonatomic) IBOutlet UIButton *buttonBlurWeak;
@property (strong, nonatomic) IBOutlet UIButton *buttonBlurNormal;
@property (strong, nonatomic) IBOutlet UIButton *buttonBlurStrong;
@property (strong, nonatomic) IBOutlet UIButton *buttonBlurNone;

@property (strong, nonatomic) IBOutlet UIButton *buttonLensNormal;
@property (strong, nonatomic) IBOutlet UIButton *buttonLensWide;
@property (strong, nonatomic) IBOutlet UIButton *buttonLensFish;

@property (strong, nonatomic) IBOutlet UIButton *buttonClose;
@property (strong, nonatomic) IBOutlet UIView *viewHelp;
@property (strong, nonatomic) IBOutlet UIView *viewPopupHelp;
@property (strong, nonatomic) IBOutlet UIView *viewTopBar;
@property (strong, nonatomic) IBOutlet UIView *viewTopBar35;

@property (strong, nonatomic) IBOutlet UIImageView *viewCanvas;

@property (unsafe_unretained) id <LXImagePickerDelegate> delegate;

@property (strong, nonatomic) IBOutlet UISlider *sliderExposure;
@property (strong, nonatomic) IBOutlet UISlider *sliderVignette;
@property (strong, nonatomic) IBOutlet UISlider *sliderSharpness;
@property (strong, nonatomic) IBOutlet UISlider *sliderClear;
@property (strong, nonatomic) IBOutlet UISlider *sliderSaturation;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollFont;
@property (strong, nonatomic) IBOutlet UITextField *textText;

- (IBAction)cameraTouch:(UITapGestureRecognizer *)sender;
- (IBAction)openImagePicker:(id)sender;
- (IBAction)close:(id)sender;
- (IBAction)capture:(id)sender;
- (IBAction)changeLens:(UIButton*)sender;
- (IBAction)changeFlash:(id)sender;
- (IBAction)touchTimer:(id)sender;
- (IBAction)touchSave:(id)sender;
- (IBAction)toggleControl:(UIButton*)sender;
- (IBAction)touchNo:(id)sender;
- (IBAction)touchReset:(id)sender;
- (IBAction)flipCamera:(id)sender;
- (IBAction)panTarget:(UIPanGestureRecognizer *)sender;
- (IBAction)setTimer:(id)sender;
- (IBAction)setMask:(UIButton*)sender;
- (IBAction)toggleMaskNatual:(UISwitch*)sender;
- (IBAction)touchCloseHelp:(id)sender;
- (IBAction)touchOpenHelp:(id)sender;
- (IBAction)toggleGain:(UISwitch*)sender;
- (IBAction)changePen:(UISlider *)sender;
- (IBAction)updateFilter:(id)sender;
- (IBAction)textChange:(UITextField *)sender;
- (IBAction)doubleTapEdit:(UITapGestureRecognizer *)sender;
- (IBAction)pinchCamera:(UIPinchGestureRecognizer *)sender;
- (IBAction)panCamera:(UIPanGestureRecognizer *)sender;
@end