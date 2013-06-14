//
//  luxeysCameraViewController.m
//  Latte
//
//  Created by Xuan Dung Bui on 7/20/12.
//  Copyright (c) 2012 LUXEYS. All rights reserved.
//

#import "LXCanvasViewController.h"
#import "LXAppDelegate.h"
#import "ALAssetsLibrary+CustomPhotoAlbum.h"
#import "LXFilterFish.h"
#import "LXShare.h"
#import "RDActionSheet.h"
#import "LXImageFilter.h"
#import "LXImageLens.h"
#import "LXImageCropViewController.h"
#import "LXFilterDOF.h"
#import "LXFilterDOF2.h"
#import "GPUImageFilter+reset.h"
#import "UIImage+Resize.h"

@interface LXCanvasViewController ()  {
    GPUImageFilterPipeline *pipe;
    LXImageFilter *filterMain;
    LXFilterDOF *filterDOF;
    
    UIActionSheet *sheet;
    
    BOOL isSaved;
    BOOL isWatingToUpload;
    BOOL initedPreviewPreset;
    BOOL initedPreviewTone;
    
    NSInteger currentLens;
    NSInteger currentPreset;
    NSString *currentEffect;
    NSString *currentBlend;
    NSString *currentFilm;
    UIButton* currentBlendButton;
    UIButton* currentFilmButton;

    
    NSInteger effectNum;
    NSMutableArray *arrayPreset;
    NSArray *arrayTone;
    NSMutableArray *effectPreview;
    NSMutableArray *effectPreviewPreset;
    
    NSLayoutConstraint *cameraAspect;
    NSInteger timerMode;
    
    MBProgressHUD *HUD;
    
    NSInteger currentTab;
    LXShare *laSharekit;
    
    NSData *imageFinalData;
    UIImage *imageFinalThumb;
    
    LXImageCropViewController *controllerCrop;
    LXImageTextViewController *controllerText;
}

@end

@implementation LXCanvasViewController

@synthesize scrollEffect;
@synthesize scrollProcess;
@synthesize scrollBlend;
@synthesize scrollPreset;
@synthesize scrollDetail;

@synthesize sliderEffectIntensity;
@synthesize viewCamera;

@synthesize buttonYes;
@synthesize buttonNo;
@synthesize buttonReset;

@synthesize gesturePan;
@synthesize viewBottomBar;

@synthesize buttonToggleFocus;
@synthesize buttonToggleEffect;
@synthesize buttonToggleBasic;
@synthesize buttonToggleLens;
@synthesize buttonToggleFilm;
@synthesize buttonToggleBlend;
@synthesize buttonTogglePreset;
@synthesize buttonBlendLayer1;
@synthesize buttonBlendLayer2;

@synthesize buttonBackgroundNatual;
@synthesize switchGain;

@synthesize buttonBlurNone;
@synthesize buttonBlurNormal;
@synthesize buttonBlurStrong;
@synthesize buttonBlurWeak;

@synthesize buttonLensNormal;
@synthesize buttonLensWide;
@synthesize buttonLensFish;

@synthesize viewCameraWraper;
@synthesize viewDraw;

@synthesize viewPresetControl;
@synthesize viewBasicControl;
@synthesize viewFocusControl;
@synthesize viewLensControl;
@synthesize viewEffectControl;
@synthesize viewBlendControl;

@synthesize viewCanvas;

@synthesize viewTopBar;

@synthesize sliderExposure;
@synthesize sliderVignette;
@synthesize sliderClear;
@synthesize sliderSaturation;
@synthesize sliderFeather;
@synthesize sliderSharpness;
@synthesize sliderBrightness;
@synthesize sliderContrast;
@synthesize sliderBlendIntensity;

@synthesize buttonBlackWhite;

@synthesize imageMeta;
@synthesize imagePreview;
@synthesize imageOrientation;
@synthesize imageToProcess;
@synthesize imageSize;
@synthesize previewFilter;

@synthesize imageNext;
@synthesize imagePrev;
@synthesize blendIndicator;

@synthesize buttonSavePreset;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        viewDraw.isEmpty = YES;
        
        // Init Crop Controller
        UIStoryboard *storyCamera = [UIStoryboard storyboardWithName:@"Camera" bundle:nil];
        controllerCrop = [storyCamera instantiateViewControllerWithIdentifier:@"Crop"];
        controllerText = [storyCamera instantiateViewControllerWithIdentifier:@"Text"];
        controllerText.delegate = self;
        
        __weak LXCanvasViewController *weakController = self;
        __weak LXImageTextViewController *weakText = controllerText;
        controllerCrop.doneCallback = ^(UIImage *editedImage, BOOL canceled){
            if(!canceled) {
                CGSize previewUISize = CGSizeMake(300.0, [LXUtils heightFromWidth:300.0 width:editedImage.size.width height:editedImage.size.height]);
                weakController.imageOrientation = UIImageOrientationUp;
                weakController.imageToProcess = [[GPUImagePicture alloc] initWithImage:editedImage];
                weakController.imageSize = editedImage.size;
                UIImage *edittedImagePreview = [LXUtils imageWithImage:editedImage scaledToSize:previewUISize];
                weakController.imagePreview = edittedImagePreview;
                [weakController resizeCameraViewWithAnimation:YES];
                weakController.previewFilter = [[GPUImagePicture alloc] initWithImage:weakController.imagePreview];
                [weakController preparePipe];
                [weakController processImage];
                
                weakText.image = edittedImagePreview;
            }
            [weakController dismissModalViewControllerAnimated:YES];
        };
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    LXAppDelegate* app = (LXAppDelegate*)[UIApplication sharedApplication].delegate;
    [app.tracker sendView:@"Camera Screen"];
    
    // LAShare
    laSharekit = [[LXShare alloc] init];
    laSharekit.controller = self;
    
    UIImage *imageCanvas = [[UIImage imageNamed:@"bg_canvas.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(8, 8, 8, 8)];
    viewCanvas.image = imageCanvas;
    
    UIBezierPath *shadowPathCamera = [UIBezierPath bezierPathWithRect:viewCameraWraper.bounds];
    viewCameraWraper.layer.masksToBounds = NO;
    viewCameraWraper.layer.shadowColor = [UIColor blackColor].CGColor;
    viewCameraWraper.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
    viewCameraWraper.layer.shadowOpacity = 1.0;
    viewCameraWraper.layer.shadowRadius = 5.0;
    viewCameraWraper.layer.shadowPath = shadowPathCamera.CGPath;
    
    viewCamera.fillMode = kGPUImageFillModeStretch;
    
    viewDraw.delegate = self;
    viewDraw.lineWidth = 10.0;
    currentTab = kTabPreview;
    
    currentLens = 0;
    
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    HUD = [[MBProgressHUD alloc] initWithView:window];
    [window addSubview:HUD];
    HUD.userInteractionEnabled = NO;
    
    scrollProcess.contentSize = CGSizeMake(436, 50);

    filterMain = [[LXImageFilter alloc] init];
    filterDOF = [[LXFilterDOF alloc] init];
    
    // Init tone
    NSString *path = [[NSBundle mainBundle] pathForResource:@"tone" ofType:@"plist"];
    NSArray *documentPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentFolder = [documentPath objectAtIndex:0];
    NSString *assetPath = [documentFolder stringByAppendingPathComponent:@"Assets"];
    NSString *tonePath = [assetPath stringByAppendingPathComponent:@"tone.plist"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:tonePath])
        arrayTone = [NSArray arrayWithContentsOfFile:path];
    else
        arrayTone = [NSArray arrayWithContentsOfFile:tonePath];
    
    effectNum = arrayTone.count;
    
    effectPreview = [[NSMutableArray alloc] init];
    for (int i=0; i < effectNum; i++) {
        UILabel *labelEffect = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 70, 12)];
        labelEffect.backgroundColor = [UIColor clearColor];
        labelEffect.textColor = [UIColor whiteColor];
        labelEffect.shadowColor = [UIColor blackColor];
        labelEffect.shadowOffset = CGSizeMake(0.0, 1.0);
        labelEffect.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:11];
        labelEffect.userInteractionEnabled = NO;
        UIButton *buttonEffect = [[UIButton alloc] initWithFrame:CGRectMake(5+75*i, 0, 70, 70)];
        
        GPUImageView *viewPreset = [[GPUImageView alloc] initWithFrame:buttonEffect.bounds];
        viewPreset.fillMode = kGPUImageFillModePreserveAspectRatioAndFill;
        viewPreset.userInteractionEnabled = NO;
        [buttonEffect addSubview:viewPreset];
        
        UIView *labelBack = [[UIView alloc] initWithFrame:CGRectMake(0, 53, 70, 20)];
        labelBack.userInteractionEnabled = NO;
        labelBack.backgroundColor = [UIColor blackColor];
        labelBack.alpha = 0.4;
        [buttonEffect addSubview:labelBack];
        
        labelEffect.center = CGPointMake(buttonEffect.center.x, 62);
        labelEffect.textAlignment = NSTextAlignmentCenter;
        
        [buttonEffect addTarget:self action:@selector(setTone:) forControlEvents:UIControlEventTouchUpInside];
        buttonEffect.layer.cornerRadius = 5;
        buttonEffect.clipsToBounds = YES;
        buttonEffect.tag = i;
        labelEffect.text = arrayTone[i][@"title"];
        [scrollEffect addSubview:buttonEffect];
        [scrollEffect addSubview:labelEffect];
        [effectPreview addObject:viewPreset];
    }
    scrollEffect.contentSize = CGSizeMake(effectNum*75+10, 70);
    
    //Init preset
    NSString *presetBuiltInPath = [[NSBundle mainBundle] pathForResource:@"preset" ofType:@"plist"];
    NSString *presetPath = [assetPath stringByAppendingPathComponent:@"preset.plist"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:presetPath])
        arrayPreset = [[NSArray arrayWithContentsOfFile:presetBuiltInPath] mutableCopy];
    else
        arrayPreset = [[NSArray arrayWithContentsOfFile:presetPath] mutableCopy];

    effectPreviewPreset = [[NSMutableArray alloc] init];
    for (int i=0; i < arrayPreset.count; i++) {
        UILabel *labelEffect = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 70, 12)];
        labelEffect.backgroundColor = [UIColor clearColor];
        labelEffect.textColor = [UIColor whiteColor];
        labelEffect.shadowColor = [UIColor blackColor];
        labelEffect.shadowOffset = CGSizeMake(0.0, 1.0);
        labelEffect.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:11];
        labelEffect.userInteractionEnabled = NO;
        UIButton *buttonEffect = [[UIButton alloc] initWithFrame:CGRectMake(5+75*i, 0, 70, 70)];
        
        GPUImageView *viewPreset = [[GPUImageView alloc] initWithFrame:buttonEffect.bounds];
        viewPreset.fillMode = kGPUImageFillModePreserveAspectRatioAndFill;
        viewPreset.userInteractionEnabled = NO;
        [buttonEffect addSubview:viewPreset];
        
        UIView *labelBack = [[UIView alloc] initWithFrame:CGRectMake(0, 53, 70, 20)];
        labelBack.userInteractionEnabled = NO;
        labelBack.backgroundColor = [UIColor blackColor];
        labelBack.alpha = 0.4;
        //[buttonEffect addSubview:labelBack];
        
        labelEffect.center = CGPointMake(buttonEffect.center.x, 62);
        labelEffect.textAlignment = NSTextAlignmentCenter;
        
        [buttonEffect addTarget:self action:@selector(setPreset:) forControlEvents:UIControlEventTouchUpInside];
        buttonEffect.layer.cornerRadius = 5;
        buttonEffect.clipsToBounds = YES;
        buttonEffect.tag = i;
        labelEffect.text = arrayPreset[i][@"title"];
        [scrollPreset addSubview:buttonEffect];
        //[scrollPreset addSubview:labelEffect];
        [effectPreviewPreset addObject:viewPreset];
    }
    
    
    scrollPreset.contentSize = CGSizeMake(arrayPreset.count*75+10, 70);
    
    // Blend
    for (int i=0; i < 9; i++) {
        UILabel *labelBlend = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 50, 10)];
        labelBlend.backgroundColor = [UIColor clearColor];
        labelBlend.textColor = [UIColor whiteColor];
        labelBlend.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:9];
        UIButton *buttonBlend = [[UIButton alloc] initWithFrame:CGRectMake(5+55*i, 5, 50, 50)];
        buttonBlend.imageView.contentMode = UIViewContentModeScaleAspectFill;
        labelBlend.center = CGPointMake(buttonBlend.center.x, 63);
        labelBlend.textAlignment = NSTextAlignmentCenter;
        UIImage *preview = [UIImage imageNamed:[NSString stringWithFormat:@"blend%d.jpg", i]];
        if (preview != nil) {
            [buttonBlend setImage:preview forState:UIControlStateNormal];
        } else {
            [buttonBlend setBackgroundColor:[UIColor grayColor]];
        }
        
        [buttonBlend addTarget:self action:@selector(toggleBlending:) forControlEvents:UIControlEventTouchUpInside];
        buttonBlend.layer.cornerRadius = 5;
        buttonBlend.clipsToBounds = YES;
        buttonBlend.tag = i;
        switch (i) {
            case 0:
                labelBlend.text = @"Lightleak";
                break;
            case 1:
                labelBlend.text = @"Circle";
                break;
            case 2:
                labelBlend.text = @"Flower";
                break;
            case 3:
                labelBlend.text = @"Star";
                break;
            case 4:
                labelBlend.text = @"Heart";
                break;
            case 5:
                labelBlend.text = @"Lightblur";
                break;
            case 6:
                labelBlend.text = @"Vintage";
                break;
            case 7:
                labelBlend.text = @"Gradient 1";
                break;
            case 8:
                labelBlend.text = @"Gradient 2";
                break;

        }
        
        [scrollBlend addSubview:buttonBlend];
        [scrollBlend addSubview:labelBlend];
    }
    scrollBlend.contentSize = CGSizeMake(9*55+10, 60);
    
    // Set Image
    imageToProcess = [[GPUImagePicture alloc] initWithImage:_imageOriginal];
    imagePreview = _imageOriginalPreview;
    imageSize = _imageOriginal.size;
    imageOrientation = _imageOriginal.imageOrientation;
    
    controllerCrop.sourceImage = _imageOriginal;
    controllerCrop.previewImage = _imageOriginalPreview;
    
    controllerText.image = _imageOriginalPreview;
    
    [self switchEditImage];
    
#if DEBUG
    buttonSavePreset.hidden = NO;
#endif
    scrollDetail.contentSize = CGSizeMake(320, 180);
    
    self.modalPresentationStyle = UIModalPresentationCurrentContext;
}

- (void)viewDidAppear:(BOOL)animated {
    if (!initedPreviewTone) {
        initedPreviewTone = YES;
        [self initPreviewPic];
    }
    [super viewDidAppear:animated];
}

- (void)viewWillAppear:(BOOL)animated {
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    
    [nc addObserver:self selector:@selector(receiveLoggedIn:) name:@"LoggedIn" object:nil];
    self.navigationController.navigationBarHidden = YES;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillDisappear:(BOOL)animated
{
    
    [super viewWillDisappear:animated];
}

- (void)preparePipe {
    [self preparePipe:nil];
}


- (void)preparePipe:(GPUImagePicture*)source {
    pipe = [[GPUImageFilterPipeline alloc] init];
    pipe.filters = [[NSMutableArray alloc] init];
    
    if (source != nil) {
        pipe.input = source;
        pipe.output = nil;
    }
    else {
        pipe.input = previewFilter;
        pipe.output = viewCamera;
    }
    
    if (!buttonLensWide.enabled) {
        LXImageLens *filterLens = [[LXImageLens alloc] init];
        [pipe addFilter:filterLens];
    }
    
    if (!buttonLensFish.enabled) {
        LXFilterFish *filterFish = [[LXFilterFish alloc] init];
        [pipe addFilter:filterFish];
    }
    
    if (buttonBlurNone.enabled) {
        [pipe addFilter:filterDOF];
    }
    
    [pipe addFilter:filterMain];
    
    if (source) {
        [pipe.filters[0] setInputRotation:[self rotationFromImage:imageOrientation] atIndex:0];
    }
    else {
        [pipe.filters[0] setInputRotation:[self rotationFromImage:imagePreview.imageOrientation] atIndex:0];
    }
}

- (GPUImageRotationMode)rotationFromImage:(UIImageOrientation)orientation {
    GPUImageRotationMode imageViewRotationModeIdx1 = kGPUImageNoRotation;
    switch (orientation) {
        case UIImageOrientationLeft:
            imageViewRotationModeIdx1 = kGPUImageRotateLeft;
            break;
        case UIImageOrientationRight:
            imageViewRotationModeIdx1 = kGPUImageRotateRight;
            break;
        case UIImageOrientationDown:
            imageViewRotationModeIdx1 = kGPUImageRotate180;
            break;
        case UIImageOrientationUp:
            imageViewRotationModeIdx1 = kGPUImageNoRotation;
            break;
        default:
            imageViewRotationModeIdx1 = kGPUImageNoRotation;
            break;
    }
    return imageViewRotationModeIdx1;
}

- (void)applyFilterSetting {
    filterMain.vignfade = sliderVignette.value;
    filterMain.exposure = sliderExposure.value;
    filterMain.brightness = sliderBrightness.value;
    filterMain.contrast = sliderContrast.value;
    filterMain.clearness = sliderClear.value;
    filterMain.saturation = sliderSaturation.value;
    buttonBlackWhite.selected = sliderSaturation.value == 0;
    filterMain.sharpness = sliderSharpness.value;
    
    filterMain.toneCurveIntensity = sliderEffectIntensity.value;
    
    if (!buttonBlendLayer1.enabled) {
        filterMain.blendIntensity = sliderBlendIntensity.value;
    }
    if (!buttonBlendLayer2.enabled) {
        filterMain.filmIntensity = sliderBlendIntensity.value;
    }
    
        
    if (switchGain.on)
        filterDOF.gain = 2.0;
    else
        filterDOF.gain = 0.0;
}

- (void)processImage {
    isSaved = false;
    imageFinalThumb = nil;
    imageFinalData = nil;
    buttonReset.enabled = true;
    [previewFilter processImage];
}

- (IBAction)changeLens:(UIButton*)sender {
    buttonLensFish.enabled = true;
    buttonLensNormal.enabled = true;
    buttonLensWide.enabled = true;
    
    sender.enabled = false;
    
    currentLens = sender.tag;
    [self preparePipe];
    [self processImage];
}

- (IBAction)touchSave:(id)sender {
    if (!isSaved) {
        UIWindow *window = [UIApplication sharedApplication].keyWindow;
        HUD = [[MBProgressHUD alloc] initWithView:window];
        [window addSubview:HUD];
        HUD.userInteractionEnabled = NO;
        HUD.mode = MBProgressHUDModeIndeterminate;
        HUD.dimBackground = YES;
        
        [HUD show:NO];
        
        //delay slightly for UI to update HUD
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.01 * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
            
            imageFinalThumb = [self getFinalThumb];
            imageFinalData = [self getFinalImage];
            [self saveImageToLib:imageFinalData];
            
            [[UIApplication sharedApplication] endIgnoringInteractionEvents];
            [self processSavedData];
        });
        
    } else
        [self processSavedData];
}

- (void)receiveLoggedIn:(NSNotification *)notification
{
    if (isWatingToUpload && isSaved) {
        [self processSavedData];
    }
}

- (void)processSavedData {
    if (_delegate) {
        NSDictionary *info = [[NSDictionary alloc] initWithObjectsAndKeys:
                              imageFinalData, @"data",
                              imageFinalThumb, @"preview",
                              nil];
        [_delegate imagePickerController:self didFinishPickingMediaWithData:info];
        return;
    }
    
    LXAppDelegate* app = (LXAppDelegate*)[UIApplication sharedApplication].delegate;
    
    if (app.currentUser) {
        LXPicEditViewController *controllerPicEdit = [[UIStoryboard storyboardWithName:@"Gallery"
                                                                                bundle: nil] instantiateViewControllerWithIdentifier:@"PicEdit"];
        controllerPicEdit.imageData = imageFinalData;
        controllerPicEdit.preview = imageFinalThumb;
        [self.navigationController pushViewController:controllerPicEdit animated:YES];
    } else {
        RDActionSheet *actionSheet = [[RDActionSheet alloc] initWithCancelButtonTitle:NSLocalizedString(@"Cancel", @"")
                                                                   primaryButtonTitle:nil
                                                               destructiveButtonTitle:nil
                                                                    otherButtonTitles:@"Email", @"Twitter", @"Facebook", @"Latte", nil];
        
        actionSheet.callbackBlock = ^(RDActionSheetResult result, NSInteger buttonIndex)
        {
            switch (result) {
                case RDActionSheetButtonResultSelected: {
                    laSharekit.text = @"";
                    laSharekit.imageData = imageFinalData;
                    laSharekit.imagePreview = imageFinalThumb;
                    
                    switch (buttonIndex) {
                        case 0: // email
                            [laSharekit emailIt];
                            break;
                        case 1: // twitter
                            [laSharekit tweet];
                            break;
                        case 2: // facebook
                            [laSharekit facebookPost];
                            break;
                        case 3: {
                            UINavigationController *modalLogin = [[UIStoryboard storyboardWithName:@"Authentication"
                                                                                            bundle: nil] instantiateInitialViewController];
                            [self presentViewController:modalLogin animated:YES completion:^{
                                isWatingToUpload = YES;
                            }];
                            
                            break;
                        }
                            
                        default:
                            break;
                    }
                }
                    break;
                case RDActionSheetResultResultCancelled:
                    NSLog(@"Sheet cancelled");
            }
        };
        
        [actionSheet showFrom:self.view];
    }
}

- (UIImage*)getFinalThumb {
    CGImageRef cgImagePreviewFromBytes = [pipe newCGImageFromCurrentFilteredFrameWithOrientation:_imageOriginalPreview.imageOrientation];
    UIImage* ret = [UIImage imageWithCGImage:cgImagePreviewFromBytes];
    CGImageRelease(cgImagePreviewFromBytes);
    return ret;
}

- (NSData*)getFinalImage {
    NSData* ret;
//    NSDictionary *state = [self getState];
    // Prepare meta data
    if (imageMeta == nil) {
        imageMeta = [[NSMutableDictionary alloc] init];
    }
    // Add App Info
    NSMutableDictionary *dictForTIFF = [imageMeta objectForKey:(NSString *)kCGImagePropertyTIFFDictionary];
    if (dictForTIFF == nil) {
        dictForTIFF = [[NSMutableDictionary alloc] init];
    }
    NSString *appVersion = [NSString stringWithFormat:@"Latte camera %@", [[NSBundle mainBundle] objectForInfoDictionaryKey: @"CFBundleShortVersionString"]];
    [dictForTIFF setObject:appVersion forKey:(NSString *)kCGImagePropertyTIFFSoftware];
    [imageMeta setObject:dictForTIFF forKey:(NSString *)kCGImagePropertyTIFFDictionary];
    
    [dictForTIFF removeObjectForKey:(NSString *)kCGImagePropertyTIFFOrientation];
    [imageMeta removeObjectForKey:(NSString *)kCGImagePropertyOrientation];
    
    NSData *jpeg;
    // skip processing if prevew pic same size with fullsize
    if (CGSizeEqualToSize(imageSize, imagePreview.size)) {
        jpeg = UIImageJPEGRepresentation(imageFinalThumb, 0.9);
    } else {
        [self preparePipe:imageToProcess];
        
        [imageToProcess processImage];
//        if (MAX(imageSize.width, imageSize.height) > 1000) {
//            [filterMain prepareForImageCapture];
//        }
        
        // Save to Jpeg NSData
        CGImageRef cgImageFromBytes = [pipe newCGImageFromCurrentFilteredFrameWithOrientation:UIImageOrientationUp];
        UIImage *outputImage = [UIImage imageWithCGImage:cgImageFromBytes];
        jpeg = UIImageJPEGRepresentation(outputImage, 0.9);
        CGImageRelease(cgImageFromBytes);
        
//        if (MAX(imageSize.width, imageSize.height) > 1000) {
//            [filterMain resetCapture];
//        }
    
    }

    
    //[filterMain setValuesForKeysWithDictionary:state];
    
    // Write EXIF to NSData
    CGImageSourceRef source = CGImageSourceCreateWithData((__bridge CFDataRef)jpeg, NULL);
    
    CFStringRef UTI = CGImageSourceGetType(source); //this is the type of image (e.g., public.jpeg)
    
    //this will be the data CGImageDestinationRef will write into
    NSMutableData *dest_data = [NSMutableData data];
    
    CGImageDestinationRef destination = CGImageDestinationCreateWithData((__bridge CFMutableDataRef)dest_data,UTI,1,NULL);
    
    if(!destination) {
        NSLog(@"***Could not create image destination ***");
    } else {
        
        //add the image contained in the image source to the destination, overidding the old metadata with our modified metadata
        CGImageDestinationAddImageFromSource(destination,source,0, (__bridge CFDictionaryRef) imageMeta);
        
        //tell the destination to write the image data and metadata into our data object.
        //It will return false if something goes wrong
        BOOL success = NO;
        success = CGImageDestinationFinalize(destination);
        
        if(!success) {
            NSLog(@"***Could not create data from image destination ***");
        }
        
        //now we have the data ready to go, so do whatever you want with it
        //here we just write it to disk at the same path we were passed
        ret = [NSData dataWithData:dest_data];
        isSaved = true;
        
        //cleanup
        
        CFRelease(destination);
    }
    CFRelease(source);
    
    return ret;
}

- (void)saveImageToLib:(NSData*)imageData {
    if (_delegate) {
        [HUD hide:YES];
        return;
    }
    
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    
    [library writeImageDataToSavedPhotosAlbum:imageData metadata:nil completionBlock:^(NSURL *assetURL, NSError *error) {
        [library addAssetURL:assetURL toAlbum:@"Latte camera" withCompletionBlock:^(NSError *error) {
            
        }];
        if (!error) {
            HUD.mode = MBProgressHUDModeText;
            HUD.labelText = NSLocalizedString(@"saved_photo", @"Saved to Camera Roll") ;
            HUD.margin = 10.f;
            HUD.yOffset = 150.f;
            HUD.removeFromSuperViewOnHide = YES;
            HUD.dimBackground = NO;
            [HUD hide:YES afterDelay:2];
            
        } else {
            HUD.mode = MBProgressHUDModeText;
            HUD.labelText = NSLocalizedString(@"cannot_save_photo", @"Cannot save to Camera Roll") ;
            HUD.margin = 10.f;
            HUD.yOffset = 150.f;
            HUD.removeFromSuperViewOnHide = YES;
            HUD.dimBackground = NO;
            [HUD hide:YES afterDelay:3];
        }
        
        [self preparePipe];
    }];
}

- (IBAction)toggleControl:(UIButton*)sender {
    NSArray *arrayButton = [NSArray arrayWithObjects:
                            buttonToggleEffect,
                            buttonToggleBasic,
                            buttonToggleFocus,
                            buttonToggleLens,
                            buttonToggleBlend,
                            buttonToggleFilm,
                            buttonTogglePreset,
                            nil];
    for (UIButton *button in arrayButton) {
        button.selected = false;
    }
    
    if (sender.tag == currentTab) {
        currentTab = kTabPreview;
        sender.selected = false;
    }
    else {
        currentTab = sender.tag;
        sender.selected = true;
    }
    
    if (currentTab == kTabBokeh) {
        // Firsttime
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        if (![defaults objectForKey:@"firstRunBokeh"]) {
            [defaults setObject:[NSDate date] forKey:@"firstRunBokeh"];
            [self touchOpenHelp:nil];
        }
    }
    
    if (currentTab == kTabBasic) {
        [scrollDetail flashScrollIndicators];
    }
    
    if (currentTab == kTabPreset) {
        if (!initedPreviewPreset) {
            initedPreviewPreset = YES;
            [self initPreviewPreset];
        }
    }
    
    [self resizeCameraViewWithAnimation:YES];
    
    viewDraw.hidden = currentTab != kTabBokeh;
    
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)resizeCameraViewWithAnimation:(BOOL)animation {
    CGRect screen = [[UIScreen mainScreen] bounds];
    
    CGRect frame = viewCameraWraper.frame;
    CGRect framePreset = viewPresetControl.frame;
    CGRect frameEffect = viewEffectControl.frame;
    CGRect frameBokeh = viewFocusControl.frame;
    CGRect frameBasic = viewBasicControl.frame;
    CGRect frameLens = viewLensControl.frame;
    CGRect frameTopBar = viewTopBar.frame;
    CGRect frameBlend = viewBlendControl.frame;
    CGRect frameCanvas;
    
    
    CGFloat posBottom;
    
    if (screen.size.height > 480) {
        posBottom = 568 - 50;
    }
    else {
        posBottom = 480 - 50;
    }
    
    frameEffect.origin.y = frameBokeh.origin.y = frameBasic.origin.y = frameLens.origin.y = frameBlend.origin.y = framePreset.origin.y = posBottom;
    
    switch (currentTab) {
        case kTabBokeh:
            frameBokeh.origin.y = posBottom - 110;
            break;
        case kTabEffect:
            frameEffect.origin.y = posBottom - 110;
            break;
        case kTabLens:
            frameLens.origin.y = posBottom - 110;
            break;
        case kTabBasic:
            frameBasic.origin.y = posBottom - 110;
            break;
        case kTabBlend:
            frameBlend.origin.y = posBottom - 110;
            break;
        case kTabPreset:
            framePreset.origin.y = posBottom - 110;
            break;
        case kTabPreview:
            break;
    }
    
    
    
    CGFloat height;
    if (screen.size.height > 480) {
        height = 568 - 50 - 40 - 20;
    }
    else {
        height = 480 - 50 - 40 - 20;
    }
    
    if (currentTab != kTabPreview) {
        height -= 110;
    }
    
    frameCanvas = CGRectMake(0, 40, 320, height+20);
    
    CGFloat horizontalRatio = 300.0 / imageSize.width;
    CGFloat verticalRatio = height / imageSize.height;
    CGFloat ratio;
    ratio = MIN(horizontalRatio, verticalRatio);
    
    frame.size = CGSizeMake(imageSize.width*ratio, imageSize.height*ratio);
    frame.origin = CGPointMake((320-frame.size.width)/2, (height - frame.size.height)/2 + 50.0);
    
    viewTopBar.hidden = false;
    
    viewCameraWraper.layer.shadowPath = nil;
    viewCameraWraper.layer.shadowRadius = 5.0;

    [UIView animateWithDuration:animation?0.3:0 animations:^{
        viewFocusControl.frame = frameBokeh;
        viewEffectControl.frame = frameEffect;
        viewBasicControl.frame = frameBasic;
        viewLensControl.frame = frameLens;
        viewCameraWraper.frame = frame;
        viewTopBar.frame = frameTopBar;
        viewCanvas.frame = frameCanvas;
        viewBlendControl.frame = frameBlend;
        viewPresetControl.frame = framePreset;

    } completion:^(BOOL finished) {
        UIBezierPath *shadowPathCamera = [UIBezierPath bezierPathWithRect:viewCameraWraper.bounds];
        viewCameraWraper.layer.shadowPath = shadowPathCamera.CGPath;
    }];
}

- (void)switchEditImage {
    [self resetSetting];

    isWatingToUpload = NO;

    //    isFixedAspectBlend = NO;
    
    //    uiWrap.frame = CGRectMake(0, 0, previewSize.width, previewSize.height);
    
    currentLens = 0;
    scrollProcess.hidden = NO;
    
    // Clear depth mask
    [viewDraw.drawImageView setImage:nil];
    viewDraw.currentColor = [UIColor redColor];
    viewDraw.isEmpty = YES;
    
    // Default Brush
    [self setUIMask:kMaskBlurNone];
    
    buttonToggleFocus.selected = false;
    buttonToggleBasic.selected = false;
    buttonToggleEffect.selected = true;
    buttonToggleLens.selected = false;
    buttonToggleFilm.selected = false;
    buttonToggleBlend.selected = false;
    buttonTogglePreset.selected = false;
    
    buttonReset.hidden = false;
    currentTab = kTabEffect;
    
    buttonReset.enabled = false;
    blendIndicator.hidden = true;
    
    [self resizeCameraViewWithAnimation:YES];
    
    previewFilter = [[GPUImagePicture alloc] initWithImage:imagePreview];
    
    [self preparePipe];
    [self applyFilterSetting];
    
    [self processImage];
}

- (void)initPreviewPic {
    for (NSInteger i = 0; i < effectNum; i++) {
        GPUImagePicture *gpuimagePreview = [[GPUImagePicture alloc] initWithImage:_imageThumbnail];
        GPUImageView *imageViewPreview = effectPreview[i];
        LXImageFilter *filterSample = [[LXImageFilter alloc] init];
        [filterSample setValuesForKeysWithDictionary:arrayTone[i]];
        [gpuimagePreview addTarget:filterSample];
        [filterSample addTarget:imageViewPreview atTextureLocation:0];
        [gpuimagePreview processImage];
    }
    
//    [self generatePreview];
}

- (void)initPreviewPreset {
    for (NSInteger i = 0; i < arrayPreset.count; i++) {
        GPUImagePicture *gpuimagePreview = [[GPUImagePicture alloc] initWithImage:_imageThumbnail];
        GPUImageView *imageViewPreview = effectPreviewPreset[i];
        LXImageFilter *filterSample = [[LXImageFilter alloc] init];
        [filterSample setValuesForKeysWithDictionary:arrayPreset[i]];
        [gpuimagePreview addTarget:filterSample];
        [filterSample addTarget:imageViewPreview atTextureLocation:0];
        [gpuimagePreview processImage];
    }
    
    //    [self generatePreview];
}


- (void)saveImage:(UIImage*)image {
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    [library writeImageToSavedPhotosAlbum:image.CGImage metadata:nil completionBlock:^(NSURL *assetURL, NSError *error) {
        if (error) {
            NSLog(@"Fail, retry");
            [self saveImage:image];
        } else {
            NSLog(@"saved");
        }
    }];
}
- (void)generatePreview {
    for (NSInteger i = 0; i < arrayPreset.count; i++) {
        GPUImagePicture *pic = [[GPUImagePicture alloc] initWithImage:[UIImage imageNamed:@"presetsample.jpg"]];
        LXImageFilter *filterSample = [[LXImageFilter alloc] init];
        [filterSample setValuesForKeysWithDictionary:arrayPreset[i]];
        [pic addTarget:filterSample];
        [pic processImage];
        UIImage *result = [filterSample imageFromCurrentlyProcessedOutput];
        [self performSelector:@selector(saveImage:) withObject:result afterDelay:i];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(NSDictionary *)info {
    if ([segue.identifier isEqualToString:@"HelpBokeh"]) {
        
    } else if ([segue.identifier isEqualToString:@"Crop"]) {
        
    }
}

- (IBAction)touchNo:(id)sender {
    if (!isSaved) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"photo_hasnt_been_saved", @"写真が保存されていません")
                                                        message:NSLocalizedString(@"stop_camera_confirm", @"カメラを閉じますか？")
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"cancel", @"キャンセル")
                                              otherButtonTitles:NSLocalizedString(@"stop_camera", @"はい"), nil];
        alert.tag = 1;
        [alert show];
    } else {
        [self.navigationController popViewControllerAnimated:NO];
    }
}

- (IBAction)touchReset:(id)sender {
    imageToProcess = [[GPUImagePicture alloc] initWithImage:_imageOriginal];
    imagePreview = _imageOriginalPreview;
    imageSize = _imageOriginalPreview.size;
    imageOrientation = _imageOriginal.imageOrientation;
    
    [self switchEditImage];
    buttonReset.enabled = false;
}

- (void)resetSetting {
    sliderExposure.value = 0.0;
    sliderBrightness.value = 0.0;
    sliderContrast.value = 1.0;
    sliderClear.value = 0.0;
    sliderSaturation.value = 1.0;
    sliderFeather.value = 10.0;
    sliderEffectIntensity.value = 1.0;
    sliderVignette.value = 0.0;
    sliderSharpness.value = 0.0;
    
    filterMain.toneEnable = NO;
    filterMain.blendEnable = NO;
    filterMain.filmEnable = NO;
    filterMain.filmMode = 4;
    filterMain.blendMode = 4;
    
    filterMain.toneCurve = nil;
    filterMain.imageBlend = nil;
    
    filterDOF.imageDOF = nil;
    filterMain.imageFilm = nil;
    
    [self setUIMask:kMaskBlurNone];

    buttonLensFish.enabled = true;
    buttonLensWide.enabled = true;
    buttonLensNormal.enabled = false;
    sliderBlendIntensity.value = 0.0;
        
    buttonBlackWhite.selected = false;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (alertView.tag) {
        case 1: //Touch No
            if (buttonIndex == 1) {
                [self.navigationController popViewControllerAnimated:NO];
            }
            break;
        case 2:
            if (buttonIndex == 1) {
                [self.navigationController dismissModalViewControllerAnimated:YES];
            }
            break;
        default:
            break;
    }
}


- (IBAction)setMask:(UIButton*)sender {
    [self setUIMask:sender.tag];
    [self preparePipe];
    [self processImage];
}

- (IBAction)toggleMaskNatual:(UISwitch*)sender {
    if (sender.on) {
        viewDraw.backgroundType = kBackgroundNatual;
    } else {
        viewDraw.backgroundType = kBackgroundNone;
    }
}


- (IBAction)touchOpenHelp:(id)sender {
    [self performSegueWithIdentifier:@"HelpBokeh" sender:nil];
}

- (IBAction)toggleGain:(UISwitch*)sender {
    [self applyFilterSetting];
    [self processImage];
}

- (void)setUIMask:(NSInteger)tag {
    buttonBlurStrong.enabled = true;
    buttonBlurWeak.enabled = true;
    buttonBlurNormal.enabled = true;
    buttonBlurNone.enabled = true;
    
    switch (tag) {
        case kMaskBlurNone:
            buttonBlurNone.enabled = false;
            break;
        case kMaskBlurWeak:
            buttonBlurWeak.enabled = false;
            filterDOF.bias = 0.01;
            break;
        case kMaskBlurNormal:
            buttonBlurNormal.enabled = false;
            filterDOF.bias = 0.02;
            break;
        case kMaskBlurStrong:
            buttonBlurStrong.enabled = false;
            filterDOF.bias = 0.03;
            break;
        default:
            break;
    }
    
}


- (IBAction)changePen:(UISlider *)sender {
    viewDraw.lineWidth = sender.value;
    [viewDraw redraw];
}

- (IBAction)updateFilter:(id)sender {
    [self applyFilterSetting];
    [self processImage];
}

- (void)toggleBlending:(UIButton *)sender {
    NSInteger blendid;
    switch (sender.tag) {
        case 0:
            blendid = 1 + rand() % 71;
            currentBlend = [NSString stringWithFormat:@"leak%d.jpg", blendid];
            break;
        case 1:
            blendid = 1 + rand() % 35;
            currentBlend = [NSString stringWithFormat:@"bokehcircle-%d.jpg", blendid];
            break;
        case 2:
            blendid = 1 + rand() % 20;
            currentBlend = [NSString stringWithFormat:@"flower-%d.jpg", blendid];
            break;
        case 3:
            blendid = 1 + rand() % 20;
            currentBlend = [NSString stringWithFormat:@"star-%d.jpg", blendid];
            break;
        case 4:
            blendid = 1 + rand() % 22;
            currentBlend = [NSString stringWithFormat:@"heart-%d.jpg", blendid];
            break;
        case 5:
            blendid = 1 + rand() % 25;
            currentBlend = [NSString stringWithFormat:@"lightblur-%d.JPG", blendid];
            break;
        case 6:
            blendid = 1 + rand() % 25;
            currentBlend = [NSString stringWithFormat:@"print%d.jpg", blendid];
            break;
        case 7:
            blendid = 1 + rand() % 88;
            currentBlend = [NSString stringWithFormat:@"gradient1-%d.png", blendid];
            break;
        case 8:
            blendid = 1 + rand() % 50;
            currentBlend = [NSString stringWithFormat:@"gradient2-%d.png", blendid];
            break;

        default:
            break;
    }
    
    UIImage *imageBlend = [UIImage imageNamed:currentBlend];
    if (0 == sender.tag || sender.tag > 5) {
        [sender setImage:imageBlend forState:UIControlStateNormal];
    }
    
    CGSize blendSize = imageBlend.size;
    
    CGFloat ratioWidth = blendSize.width / imageSize.width;
    CGFloat ratioHeight = blendSize.height / imageSize.height;
    CGRect crop;
    
    CGFloat ratio = MIN(ratioWidth, ratioHeight);
    CGSize newSize = CGSizeMake(blendSize.width / ratio, blendSize.height / ratio);
    if (newSize.width > imageSize.width) {
        CGFloat sub = (newSize.width - imageSize.width) / newSize.width;
        crop = CGRectMake(sub/2.0, 0.0, 1.0-sub, 1.0);
    } else {
        CGFloat sub = (newSize.height - imageSize.height) / newSize.height;
        crop = CGRectMake(0.0, sub/2.0, 1.0, 1.0-sub);
    }
    if (sliderBlendIntensity.value == 0.0) {
        sliderBlendIntensity.value = 0.4;
    }
    
    if (!buttonBlendLayer1.enabled) {
        filterMain.imageBlend = imageBlend;
        filterMain.blendRegion = crop;
        
        filterMain.blendIntensity = sliderBlendIntensity.value;
        filterMain.blendEnable = YES;
        currentBlendButton = sender;
    }
    
    if (!buttonBlendLayer2.enabled) {
        filterMain.imageFilm = imageBlend;
        filterMain.filmRegion = crop;
        
        filterMain.filmIntensity = sliderBlendIntensity.value;
        filterMain.filmEnable = YES;
        currentFilmButton = sender;
    }
    blendIndicator.hidden = NO;
    
    [UIView animateWithDuration:kGlobalAnimationSpeed animations:^{
        CGPoint center = sender.center;
        blendIndicator.center = CGPointMake(center.x, blendIndicator.center.y);
    }];
    
    [self processImage];
}

- (IBAction)setBlend:(UIButton *)sender {
    if (sender.tag == 1) {
        buttonBlendLayer1.enabled = false;
        buttonBlendLayer2.enabled = true;
        sliderBlendIntensity.value = filterMain.blendIntensity;
        blendIndicator.hidden = !filterMain.blendEnable;
        blendIndicator.center = CGPointMake(currentBlendButton.center.x, blendIndicator.center.y);
    } else {
        buttonBlendLayer1.enabled = true;
        buttonBlendLayer2.enabled = false;
        sliderBlendIntensity.value = filterMain.filmIntensity;
        blendIndicator.hidden = !filterMain.filmEnable;
        blendIndicator.center = CGPointMake(currentFilmButton.center.x, blendIndicator.center.y);
    }
}

- (IBAction)printTemplate:(id)sender {
    [self SavePreset];
    /*NSLog(@"<key>toneEnable</key>%@", filterMain.toneEnable?@"<true/>":@"<false/>");
    NSLog(@"<key>toneImage</key><string>%@</string>", currentEffect);
    NSLog(@"<key>toneCurveIntensity</key><real>%f</real>", filterMain.toneCurveIntensity);
    NSLog(@"<key>brightness</key><real>%f</real>", filterMain.brightness);
    NSLog(@"<key>saturation</key><real>%f</real>", filterMain.saturation);
    NSLog(@"<key>clearness</key><real>%f</real>", filterMain.clearness);
    NSLog(@"<key>vignfade</key><real>%f</real>", filterMain.vignfade);
    NSLog(@"<key>blendEnable</key>%@", filterMain.blendEnable?@"<true/>":@"<false/>");
    NSLog(@"<key>blendImage</key><string>%@</string>", currentBlend);
    NSLog(@"<key>blendIntensity</key><real>%f</real>", filterMain.blendIntensity);
    NSLog(@"<key>filmEnable</key>%@", filterMain.filmEnable?@"<true/>":@"<false/>");
    NSLog(@"<key>filmImage</key><string>%@</string>", currentFilm);
    NSLog(@"<key>filmIntensity</key><real>%f</real>", filterMain.filmIntensity);*/
}

- (NSDictionary*)getState {
    NSMutableDictionary *ret = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                         [NSNumber numberWithBool:filterMain.toneEnable], @"toneEnable",
                         [NSNumber numberWithFloat:filterMain.toneCurveIntensity], @"toneCurveIntensity",
                         [NSNumber numberWithFloat:filterMain.exposure], @"exposure",
                         [NSNumber numberWithFloat:filterMain.contrast], @"contrast",
                         [NSNumber numberWithFloat:filterMain.brightness], @"brightness",
                         [NSNumber numberWithFloat:filterMain.saturation], @"saturation",
                         [NSNumber numberWithFloat:filterMain.exposure], @"exposure",
                         [NSNumber numberWithFloat:filterMain.contrast], @"contrast",
                         [NSNumber numberWithFloat:filterMain.clearness], @"clearness",
                         [NSNumber numberWithFloat:filterMain.vignfade], @"vignfade",
                         [NSNumber numberWithBool:filterMain.blendEnable], @"blendEnable",
                         [NSNumber numberWithFloat:filterMain.blendIntensity], @"blendIntensity",
                         [NSNumber numberWithBool:filterMain.filmEnable], @"filmEnable",
                         [NSNumber numberWithFloat:filterMain.filmIntensity], @"filmIntensity",
                         nil];
    
    if (currentEffect)
        ret[@"toneImage"] = currentEffect;
    if (currentBlend)
        ret[@"blendImage"] = currentBlend;
    if (currentFilm)
        ret[@"filmImage"] = currentFilm;
    return ret;
}


- (IBAction)toggleFisheye:(UIButton *)sender {
    sender.selected = !sender.selected;
    buttonLensNormal.enabled = sender.selected;
    buttonLensFish.enabled = !sender.selected;
    buttonLensWide.enabled = true;
    [self preparePipe];
}

- (IBAction)toggleMono:(id)sender {
    buttonBlackWhite.selected = !buttonBlackWhite.selected;
    if (buttonBlackWhite.selected) {
        filterMain.saturation = 0;
        sliderSaturation.value = 0;
    }
    else {
        filterMain.saturation = 1;
        sliderSaturation.value = 1;
    }
    [self processImage];
}

- (IBAction)touchCrop:(id)sender {
    [self presentModalViewController:controllerCrop animated:YES];
}

- (IBAction)touchText:(id)sender {
    [self presentModalViewController:controllerText animated:YES];
}

- (void)newMask:(UIImage *)mask {
    if (!buttonBlurNone.enabled) {
        [self setUIMask:kMaskBlurNormal];
    }
    
    filterDOF.imageDOF = mask;
    
    [self preparePipe];
    [self processImage];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

- (void)newTextImage:(UIImage *)textImage {
    filterMain.imageText = textImage;
    filterMain.textEnable = YES;
    [self processImage];
}

- (void)setTone:(UIButton*)button {
    NSDictionary *preset = arrayTone[button.tag];
    [filterMain setValuesForKeysWithDictionary:preset];
    [self processImage];
}

- (void)setPreset:(UIButton*)button {
    currentPreset = button.tag;
    NSDictionary *preset = arrayPreset[button.tag];
    [filterMain setValuesForKeysWithDictionary:preset];
    
    if ([preset objectForKey:@"clearness"]) {
        sliderClear.value = [preset[@"clearness"] floatValue];
    }
    
    if ([preset objectForKey:@"toneCurveIntensity"]) {
        sliderEffectIntensity.value = [preset[@"toneCurveIntensity"] floatValue];
    }
    
    if ([preset objectForKey:@"brightness"]) {
        sliderBrightness.value = [preset[@"brightness"] floatValue];
    }
    
    if ([preset objectForKey:@"exposure"]) {
        sliderExposure.value = [preset[@"exposure"] floatValue];
    }
    
    if ([preset objectForKey:@"contrast"]) {
        sliderContrast.value = [preset[@"contrast"] floatValue];
    }
    
    if ([preset objectForKey:@"saturation"]) {
        sliderSaturation.value = [preset[@"saturation"] floatValue];
    }
    
    if ([preset objectForKey:@"saturation"]) {
        buttonBlackWhite.selected = [[preset objectForKey:@"saturation"] floatValue] == 0.0;
    }
    
    if ([preset objectForKey:@"vignfade"]) {
        sliderVignette.value = [preset[@"vignfade"] floatValue];
    }
    
    if ([preset objectForKey:@"blendImage"]) {
        currentBlend = preset[@"blendImage"];
    }

    if ([preset objectForKey:@"toneImage"]) {
        currentEffect = preset[@"toneImage"];
    }

    if ([preset objectForKey:@"filmImage"]) {
        currentFilm = preset[@"filmImage"];
    }
    
    if ([preset objectForKey:@"blendIntensity"]) {
        CGFloat blendIntensity = [preset[@"blendIntensity"] floatValue];
        sliderBlendIntensity.value = blendIntensity;
    }
    
    if ([preset objectForKey:@"filmIntensity"]) {
        CGFloat filmIntensity = [preset[@"filmIntensity"] floatValue];
        sliderBlendIntensity.value = filmIntensity;
    }

    [self processImage];
}



- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView.contentOffset.x  < 50) {
        [UIView animateWithDuration:kGlobalAnimationSpeed
                              delay:0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             imagePrev.alpha = 0;
                         }
                         completion:nil];
    } else {
        [UIView animateWithDuration:kGlobalAnimationSpeed
                              delay:0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             imagePrev.alpha = 1;
                         }
                         completion:nil];
    }
    
    if (scrollView.contentOffset.x  > scrollView.contentSize.width-scrollView.bounds.size.width-50) {
        [UIView animateWithDuration:kGlobalAnimationSpeed
                              delay:0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             imageNext.alpha = 0;
                         }
                         completion:nil];
    } else {
        [UIView animateWithDuration:kGlobalAnimationSpeed
                              delay:0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             imageNext.alpha = 1;
                         }
                         completion:nil];
    }
}

- (void)SavePreset
{
    arrayPreset[currentPreset] = [self getState];
    NSArray *documentPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentFolder = [documentPath objectAtIndex:0];
    NSString *assetPath = [documentFolder stringByAppendingPathComponent:@"Assets"];
    NSString *newPlistFile = [assetPath stringByAppendingPathComponent:@"preset.plist"];
    
    BOOL OK = [arrayPreset writeToFile:newPlistFile atomically:YES];
    NSLog(@"write %d %@", OK, newPlistFile);
}

- (void)viewDidUnload {
    [self setViewPresetControl:nil];
    [self setScrollPreset:nil];
    [self setImagePrev:nil];
    [self setImageNext:nil];
    [self setButtonSavePreset:nil];
    [self setSliderSharpness:nil];
    [self setScrollDetail:nil];
    [self setSliderBrightness:nil];
    [self setSliderContrast:nil];
    [self setButtonTogglePreset:nil];
    [self setSliderBlendIntensity:nil];
    [self setBlendIndicator:nil];
    [super viewDidUnload];
}
- (IBAction)touchBlendSetting:(id)sender {
    RDActionSheet *actionSheet = [[RDActionSheet alloc] initWithCancelButtonTitle:NSLocalizedString(@"Cancel", @"")
                                                               primaryButtonTitle:nil
                                                           destructiveButtonTitle:nil
                                                                otherButtonTitles:
                                  NSLocalizedString(@"Soft Light", @""),
                                  NSLocalizedString(@"Overlay", @""),
                                  NSLocalizedString(@"Color Dodge", @""),
                                  NSLocalizedString(@"Screen", @""),
                                  NSLocalizedString(@"Lighten", @""),
                                  NSLocalizedString(@"Normal", @""),
                                  nil];
    
    actionSheet.callbackBlock = ^(RDActionSheetResult result, NSInteger buttonIndex)
    {
        switch (result) {
            case RDActionSheetButtonResultSelected:{
                NSInteger blendMode = 4;
                switch (buttonIndex) {
                    case 0: // Softlight
                        blendMode = 7;
                        break;
                    case 1: // Overlay
                        blendMode = 6;
                        break;
                    case 2: // Color Dodge
                        blendMode = 5;
                        break;
                    case 3: // Screen
                        blendMode = 4;
                        break;
                    case 4: // Lighten
                        blendMode = 3;
                        break;
                    case 5: // Normal
                        blendMode = 11;
                        break;
                }
                if (!buttonBlendLayer1.enabled)
                    filterMain.blendMode = blendMode;
                if (!buttonBlendLayer2.enabled)
                    filterMain.filmMode = blendMode;
                [self processImage];
            }
                break;
            case RDActionSheetResultResultCancelled:
                NSLog(@"Sheet cancelled");
        }
    };
    
    [actionSheet showFrom:self.view];
}

- (IBAction)changeBlendIntensity:(id)sender {
    if (!buttonBlendLayer1.enabled) {
        filterMain.blendIntensity = sliderBlendIntensity.value;
        filterMain.blendEnable = sliderBlendIntensity.value > 0;
    }
    if (!buttonBlendLayer2.enabled) {
        filterMain.filmIntensity = sliderBlendIntensity.value;
        filterMain.filmEnable = sliderBlendIntensity.value > 0;
    }
    [self processImage];
}
@end
