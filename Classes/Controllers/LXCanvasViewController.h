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
#import "LXNavBar.h"
#import "LXPicEditViewController.h"
#import "LXUtils.h"
#import "LXDrawView.h"
#import "UIImage+Resize.h"
#import "UIImage+fixOrientation.h"
#import "MBProgressHUD.h"
#import "LXStillCamera.h"
#import "LXImageTextViewController.h"

typedef enum {
    kTabPreview = 0,
    kTabEffect = 1,
    kTabBokeh = 2,
    kTabBasic = 3,
    kTabLens = 4,
    kTabFilm = 5,
    kTabBlend = 6,
    kTabPreset = 10,
} EffectTab;

typedef enum {
    kMaskBlurNone = 5,
    kMaskBlurWeak = 6,
    kMaskBlurNormal = 7,
    kMaskBlurStrong = 8,
} TypeDefMask;

typedef enum {
    kBlendNone = 0,
    kBlendWeak = 1,
    kBlendNormal = 2,
    kBlendStrong = 3,
} TypeDefBlend;

@class LXCanvasViewController;

@protocol LXImagePickerDelegate <NSObject>
@optional
- (void)imagePickerController:(LXCanvasViewController *)picker didFinishPickingMediaWithData:(NSDictionary *)info;
- (void)imagePickerControllerDidCancel:(LXCanvasViewController *)picker;
@end

@interface LXCanvasViewController : UIViewController <UIActionSheetDelegate, UIGestureRecognizerDelegate, UIScrollViewDelegate, LXDrawViewDelegate, UIAlertViewDelegate, UINavigationControllerDelegate, LXImageTextDelegate>
@property (weak, nonatomic) id <LXImagePickerDelegate> delegate;

@property (strong, nonatomic) IBOutlet UIView *viewBottomBar;
@property (strong, nonatomic) IBOutlet GPUImageView *viewCamera;

@property (strong, nonatomic) IBOutlet UIScrollView *scrollEffect;

@property (strong, nonatomic) IBOutlet UIButton *buttonYes;
@property (strong, nonatomic) IBOutlet UIButton *buttonNo;
@property (strong, nonatomic) IBOutlet UIButton *buttonReset;

@property (strong, nonatomic) IBOutlet UIPanGestureRecognizer *gesturePan;

@property (strong, nonatomic) IBOutlet UIView *viewFocusControl;
@property (strong, nonatomic) IBOutlet UIView *viewLensControl;
@property (strong, nonatomic) IBOutlet UIView *viewBasicControl;
@property (strong, nonatomic) IBOutlet UIView *viewEffectControl;
@property (strong, nonatomic) IBOutlet UIView *viewBlendControl;
@property (strong, nonatomic) IBOutlet UIView *viewFilmControl;
@property (strong, nonatomic) IBOutlet UIView *viewPresetControl;

@property (strong, nonatomic) IBOutlet UIView *viewCameraWraper;
@property (strong, nonatomic) IBOutlet LXDrawView *viewDraw;

@property (strong, nonatomic) IBOutlet UIButton *buttonToggleEffect;
@property (strong, nonatomic) IBOutlet UIButton *buttonToggleFocus;
@property (strong, nonatomic) IBOutlet UIButton *buttonToggleBasic;
@property (strong, nonatomic) IBOutlet UIButton *buttonToggleLens;
@property (strong, nonatomic) IBOutlet UIButton *buttonToggleFilm;
@property (strong, nonatomic) IBOutlet UIButton *buttonToggleBlend;
@property (strong, nonatomic) IBOutlet UIButton *buttonTogglePreset;

@property (strong, nonatomic) IBOutlet UISwitch *buttonBackgroundNatual;
@property (strong, nonatomic) IBOutlet UISwitch *switchGain;
@property (strong, nonatomic) IBOutlet UIButton *buttonBlurWeak;
@property (strong, nonatomic) IBOutlet UIButton *buttonBlurNormal;
@property (strong, nonatomic) IBOutlet UIButton *buttonBlurStrong;
@property (strong, nonatomic) IBOutlet UIButton *buttonBlurNone;

@property (strong, nonatomic) IBOutlet UIButton *buttonBlendNone;
@property (strong, nonatomic) IBOutlet UIButton *buttonBlendWeak;
@property (strong, nonatomic) IBOutlet UIButton *buttonBlendMedium;
@property (strong, nonatomic) IBOutlet UIButton *buttonBlendStrong;

@property (strong, nonatomic) IBOutlet UIButton *buttonFilmNone;
@property (strong, nonatomic) IBOutlet UIButton *buttonFilmWeak;
@property (strong, nonatomic) IBOutlet UIButton *buttonFilmMedium;
@property (strong, nonatomic) IBOutlet UIButton *buttonFilmStrong;

@property (strong, nonatomic) IBOutlet UIButton *buttonLensNormal;
@property (strong, nonatomic) IBOutlet UIButton *buttonLensWide;
@property (strong, nonatomic) IBOutlet UIButton *buttonLensFish;

@property (strong, nonatomic) IBOutlet UIView *viewTopBar;

@property (strong, nonatomic) IBOutlet UIImageView *viewCanvas;

@property (strong, nonatomic) IBOutlet UISlider *sliderExposure;
@property (strong, nonatomic) IBOutlet UISlider *sliderVignette;
@property (strong, nonatomic) IBOutlet UISlider *sliderClear;
@property (strong, nonatomic) IBOutlet UISlider *sliderSaturation;
@property (strong, nonatomic) IBOutlet UISlider *sliderFeather;
@property (strong, nonatomic) IBOutlet UISlider *sliderEffectIntensity;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollProcess;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollBlend;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollFilm;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollPreset;

@property (strong, nonatomic) IBOutlet UIButton *buttonBlackWhite;

@property (strong, nonatomic) NSDictionary *dictUpload;

- (IBAction)changeLens:(UIButton*)sender;
- (IBAction)touchSave:(id)sender;
- (IBAction)toggleControl:(UIButton*)sender;
- (IBAction)touchNo:(id)sender;
- (IBAction)touchReset:(id)sender;
- (IBAction)setMask:(UIButton*)sender;
- (IBAction)toggleMaskNatual:(UISwitch*)sender;
- (IBAction)touchOpenHelp:(id)sender;
- (IBAction)toggleGain:(UISwitch*)sender;
- (IBAction)changePen:(UISlider *)sender;
- (IBAction)updateFilter:(id)sender;
- (IBAction)toggleFisheye:(UIButton *)sender;
- (IBAction)setBlend:(UIButton *)sender;
- (IBAction)toggleMono:(id)sender;
- (IBAction)touchCrop:(id)sender;
- (IBAction)touchText:(id)sender;
- (IBAction)setFilm:(UIButton *)sender;
- (IBAction)printTemplate:(id)sender;

@property (strong, nonatomic) UIImage *imageOriginalPreview;
@property (strong, nonatomic) UIImage *imageOriginal;
@property (strong, nonatomic) NSMutableDictionary *imageMeta;
@property (strong, nonatomic) UIImage *imagePreview;
@property (strong, nonatomic) UIImage *imageThumbnail;
@property (strong, nonatomic) UIImage *imageFullsize;
@property (assign, nonatomic) CGSize imageSize;
@property (strong, nonatomic) GPUImagePicture *previewFilter;
@end
