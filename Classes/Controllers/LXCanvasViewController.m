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
#import "GPUImageFilter+reset.h"

@interface LXCanvasViewController ()  {
    GPUImageFilterPipeline *pipe;
    LXImageFilter *filterMain;
    LXFilterDOF *filterDOF;
    
    
    UIActionSheet *sheet;
    
    BOOL isSaved;
    BOOL isWatingToUpload;
    
    NSString *currentEffect;
    NSInteger currentLens;
    NSString *currentBlend;
    NSString *currentFilm;
    NSInteger effectNum;
    NSMutableArray *effectPreview;
    NSMutableArray *effectCurve;
    NSArray *arrayPreset;
    
    NSLayoutConstraint *cameraAspect;
    NSInteger timerMode;
    
    MBProgressHUD *HUD;
    
    NSInteger currentTab;
    LXShare *laSharekit;
    
    NSData *imageFinalData;
    UIImage *imageFinalThumb;
    
    LXImageCropViewController *controllerCrop;
    LXImageTextViewController *controllerText;
    
    GPUImagePicture *pictureDOF;
}

@end

@implementation LXCanvasViewController

@synthesize scrollEffect;
@synthesize scrollProcess;
@synthesize scrollBlend;
@synthesize scrollFilm;
@synthesize scrollPreset;

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

@synthesize buttonBackgroundNatual;
@synthesize switchGain;

@synthesize buttonBlurNone;
@synthesize buttonBlurNormal;
@synthesize buttonBlurStrong;
@synthesize buttonBlurWeak;

@synthesize buttonBlendNone;
@synthesize buttonBlendWeak;
@synthesize buttonBlendMedium;
@synthesize buttonBlendStrong;

@synthesize buttonFilmNone;
@synthesize buttonFilmWeak;
@synthesize buttonFilmMedium;
@synthesize buttonFilmStrong;

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
@synthesize viewFilmControl;

@synthesize viewCanvas;

@synthesize viewTopBar;

@synthesize sliderExposure;
@synthesize sliderVignette;
@synthesize sliderClear;
@synthesize sliderSaturation;
@synthesize sliderFeather;

@synthesize buttonBlackWhite;

@synthesize imageMeta;
@synthesize imagePreview;
@synthesize imageFullsize;
@synthesize imageSize;
@synthesize previewFilter;

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
                weakController.imageFullsize = editedImage;
                weakController.imageSize = editedImage.size;
                weakController.imagePreview = [LXUtils imageWithImage:editedImage scaledToSize:previewUISize];
                [weakController resizeCameraViewWithAnimation:YES];
                weakController.previewFilter = [[GPUImagePicture alloc] initWithImage:weakController.imagePreview];
                [weakController preparePipe];
                [weakController processImage];
                
                weakText.image = editedImage;
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
    
    scrollProcess.contentSize = CGSizeMake(400, 50);

    filterMain = [[LXImageFilter alloc] init];
    filterDOF = [[LXFilterDOF alloc] init];
    
    effectNum = 19;
    effectPreview = [[NSMutableArray alloc] initWithCapacity:effectNum];
    effectCurve = [[NSMutableArray alloc] initWithCapacity:effectNum];
    
    for (int i=0; i < effectNum; i++) {
        [effectCurve addObject:[UIImage imageNamed:[NSString stringWithFormat:@"curve%d.png", i]]];
        UILabel *labelEffect = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 70, 12)];
        labelEffect.backgroundColor = [UIColor clearColor];
        labelEffect.textColor = [UIColor whiteColor];
        labelEffect.shadowColor = [UIColor blackColor];
        labelEffect.shadowOffset = CGSizeMake(0.0, 1.0);
        labelEffect.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:11];
        labelEffect.userInteractionEnabled = NO;
        UIButton *buttonEffect = [[UIButton alloc] initWithFrame:CGRectMake(5+75*i, 0, 70, 70)];
        GPUImageView *previewEffect = [[GPUImageView alloc] initWithFrame:buttonEffect.bounds];
        previewEffect.fillMode = kGPUImageFillModePreserveAspectRatioAndFill;
        previewEffect.userInteractionEnabled = NO;
        
        [effectPreview addObject:previewEffect];
        
        UIView *labelBack = [[UIView alloc] initWithFrame:CGRectMake(0, 53, 70, 20)];
        labelBack.userInteractionEnabled = NO;
        labelBack.backgroundColor = [UIColor blackColor];
        labelBack.alpha = 0.4;
        [buttonEffect addSubview:previewEffect];
        [buttonEffect addSubview:labelBack];
        
        labelEffect.center = CGPointMake(buttonEffect.center.x, 62);
        labelEffect.textAlignment = NSTextAlignmentCenter;
        
        [buttonEffect addTarget:self action:@selector(setEffect:) forControlEvents:UIControlEventTouchUpInside];
        buttonEffect.layer.cornerRadius = 5;
        buttonEffect.clipsToBounds = YES;
        buttonEffect.tag = i;
        switch (i) {
            case 1:
                labelEffect.text = @"Classic";
                break;
            case 2:
                labelEffect.text = @"Soft";
                break;
            case 3:
                labelEffect.text = @"Sandy";
                break;
            case 4:
                labelEffect.text = @"Lavender";
                break;
            case 5:
                labelEffect.text = @"Electrocute";
                break;
            case 6:
                labelEffect.text = @"Gummy";
                break;
            case 7:
                labelEffect.text = @"Secret";
                break;
            case 8:
                labelEffect.text = @"Cozy";
                break;
            case 9:
                labelEffect.text = @"Haze";
                break;
            case 10:
                labelEffect.text = @"Glory";
                break;
            case 11:
                labelEffect.text = @"Big times";
                break;
            case 12:
                labelEffect.text = @"Christmas";
                break;
            case 13:
                labelEffect.text = @"Dorian";
                break;
            case 14:
                labelEffect.text = @"Stingray";
                break;
            case 15:
                labelEffect.text = @"Forever";
                break;
            case 16:
                labelEffect.text = @"Alone";
                break;
            case 17:
                labelEffect.text = @"Inaka";
                break;
            case 18:
                labelEffect.text = @"Curvy";
                break;
            default:
                labelEffect.text = @"Original";
                break;
        }
        
        [scrollEffect addSubview:buttonEffect];
        [scrollEffect addSubview:labelEffect];
    }
    scrollEffect.contentSize = CGSizeMake(effectNum*75+10, 70);
    
    
    // Blend
    for (int i=0; i < 6; i++) {
        UILabel *labelBlend = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 50, 10)];
        labelBlend.backgroundColor = [UIColor clearColor];
        labelBlend.textColor = [UIColor whiteColor];
        labelBlend.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:9];
        UIButton *buttonBlend = [[UIButton alloc] initWithFrame:CGRectMake(5+55*i, 5, 50, 50)];
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
        }
        
        [scrollBlend addSubview:buttonBlend];
        [scrollBlend addSubview:labelBlend];
    }
    scrollBlend.contentSize = CGSizeMake(6*55+10, 60);
    
    // Film
    for (int i=0; i < 9; i++) {
        UIButton *buttonFilm = [[UIButton alloc] initWithFrame:CGRectMake(5+55*i, 5, 50, 50)];
        UIImage *preview = [UIImage imageNamed:[NSString stringWithFormat:@"print%d.jpg", i+1]];
        [buttonFilm setImage:preview forState:UIControlStateNormal];
        [buttonFilm addTarget:self action:@selector(toggleFilm:) forControlEvents:UIControlEventTouchUpInside];
        buttonFilm.layer.cornerRadius = 5;
        buttonFilm.clipsToBounds = YES;
        buttonFilm.tag = i+1;
        
        [scrollFilm addSubview:buttonFilm];
    }
    scrollFilm.contentSize = CGSizeMake(9*55+10, 60);
    
    // Preset
    NSString *path = [[NSBundle mainBundle] pathForResource:@"preset" ofType:@"plist"];
    arrayPreset = [NSArray arrayWithContentsOfFile:path];
    for (int i=0; i < arrayPreset.count; i++) {
        UIButton *buttonPreset = [[UIButton alloc] initWithFrame:CGRectMake(5+80*i, 5, 75, 75)];
        UILabel *labelPreset = [[UILabel alloc] initWithFrame:CGRectMake(0, 55, 73, 20)];
        labelPreset.backgroundColor = [UIColor clearColor];
        labelPreset.textColor = [UIColor whiteColor];
        labelPreset.font = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:18];
        labelPreset.textAlignment = NSTextAlignmentRight;
        labelPreset.text = [NSString stringWithFormat:@"%d", i+1];
        
        UIImage *preview = [UIImage imageNamed:[NSString stringWithFormat:@"preset-%d.JPG", i]];
        [buttonPreset setImage:preview forState:UIControlStateNormal];
        
        buttonPreset.backgroundColor = [UIColor grayColor];
        [buttonPreset addTarget:self action:@selector(setPreset:) forControlEvents:UIControlEventTouchUpInside];
        buttonPreset.layer.cornerRadius = 5;
        buttonPreset.clipsToBounds = YES;
        buttonPreset.tag = i;
        
        [buttonPreset addSubview:labelPreset];
        [scrollPreset addSubview:buttonPreset];
    }
    scrollPreset.contentSize = CGSizeMake(arrayPreset.count*80+10, 85);
    
    // Set Image
    imageFullsize = _imageOriginal;
    imagePreview = _imageOriginalPreview;
    imageSize = imageFullsize.size;
    controllerCrop.previewImage = _imageOriginalPreview;
    controllerCrop.sourceImage = _imageOriginal;
    controllerText.image = _imageOriginal;
    
    
    [self switchEditImage];
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
        [pictureDOF removeAllTargets];
        [pictureDOF addTarget:filterDOF atTextureLocation:1];
    }
    
    [pipe addFilter:filterMain];
    
    if (source) {
        [pipe.filters[0] setInputRotation:[self rotationFromImage:imageFullsize.imageOrientation] atIndex:0];
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
    filterMain.brightness = sliderExposure.value;
    filterMain.clearness = sliderClear.value;
    filterMain.saturation = sliderSaturation.value;
    
    filterMain.toneCurveIntensity = sliderEffectIntensity.value;
    
    if (!buttonBlendMedium.enabled) {
        filterMain.blendIntensity = 0.66;
    }
    
    if (!buttonBlendWeak.enabled) {
        filterMain.blendIntensity = 0.40;
    }
    
    if (!buttonBlendStrong.enabled) {
        filterMain.blendIntensity = 0.90;
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
    if (buttonBlurNone.enabled) {
        [pictureDOF processImage];
    }
}

- (void)setEffect:(id)sender {
    UIButton* buttonEffect = (UIButton*)sender;
    if (buttonEffect.tag == 0) {
        filterMain.toneEnable = NO;
        filterMain.toneCurve = nil;
    } else {
        filterMain.toneEnable = YES;
        filterMain.toneCurve = effectCurve[buttonEffect.tag];
    }
    currentEffect = [NSString stringWithFormat:@"curve%d.png", buttonEffect.tag];
    [self processImage];
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
    LXAppDelegate* app = (LXAppDelegate*)[UIApplication sharedApplication].delegate;
    
    if (app.currentUser != nil) {
        if (_delegate == nil) {
            LXPicEditViewController *controllerPicEdit = [[UIStoryboard storyboardWithName:@"Gallery"
                                                                            bundle: nil] instantiateViewControllerWithIdentifier:@"PicEdit"];
            controllerPicEdit.imageData = imageFinalData;
            controllerPicEdit.preview = imageFinalThumb;
            [self.navigationController pushViewController:controllerPicEdit animated:YES];
        } else {
            NSDictionary *info = [[NSDictionary alloc] initWithObjectsAndKeys:
                                  imageFinalData, @"data",
                                  imageFinalThumb, @"preview",
                                  nil];
            [_delegate imagePickerController:self didFinishPickingMediaWithData:info];
        }
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
    
    // If this is new photo save original pic first, and then process
//    if (imageFullsize != _imageOriginal) {
        [dictForTIFF removeObjectForKey:(NSString *)kCGImagePropertyTIFFOrientation];
        [imageMeta removeObjectForKey:(NSString *)kCGImagePropertyOrientation];
//    }
    
    GPUImagePicture *picture = [[GPUImagePicture alloc] initWithImage:imageFullsize];
    [self preparePipe:picture];
    
    [(GPUImageFilter *)[pipe.filters lastObject] destroyFilterFBO];
    [(GPUImageFilter *)[pipe.filters lastObject] deleteOutputTexture];
    [(GPUImageFilter *)[pipe.filters lastObject] prepareForImageCapture];
    
    [picture processImage];
    if (buttonBlurNone.enabled) {
        [pictureDOF processImage];
    }
    
    // Save to Jpeg NSData
    CGImageRef cgImageFromBytes = [pipe newCGImageFromCurrentFilteredFrameWithOrientation:UIImageOrientationUp];
    UIImage *outputImage = [UIImage imageWithCGImage:cgImageFromBytes];
    NSData *jpeg = UIImageJPEGRepresentation(outputImage, 0.9);
    CGImageRelease(cgImageFromBytes);
    
    [(GPUImageFilter *)[pipe.filters lastObject] resetCapture];
    
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
        // Return to preview mode
        [self preparePipe];
    }];
}

- (IBAction)toggleControl:(UIButton*)sender {
    NSArray *arrayButton = [NSArray arrayWithObjects:
                            buttonTogglePreset,
                            buttonToggleEffect,
                            buttonToggleBasic,
                            buttonToggleFocus,
                            buttonToggleLens,
                            buttonToggleBlend,
                            buttonToggleFilm, nil];
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
    CGRect frameFilm = viewFilmControl.frame;
    CGRect frameCanvas;
    
    
    CGFloat posBottom;
    
    if (screen.size.height > 480) {
        posBottom = 568 - 50;
    }
    else {
        posBottom = 480 - 50;
    }
    
    frameEffect.origin.y = frameBokeh.origin.y = frameBasic.origin.y = frameLens.origin.y = frameBlend.origin.y = frameFilm.origin.y = framePreset.origin.y = posBottom;
    
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
        case kTabFilm:
            frameFilm.origin.y = posBottom - 110;
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
        viewFilmControl.frame = frameFilm;
        viewPresetControl.frame = framePreset;

    } completion:^(BOOL finished) {
        UIBezierPath *shadowPathCamera = [UIBezierPath bezierPathWithRect:viewCameraWraper.bounds];
        viewCameraWraper.layer.shadowPath = shadowPathCamera.CGPath;
    }];
}

- (void)switchEditImage {
    [self resetSetting];

    isWatingToUpload = NO;

    [self setBlendImpl:kBlendNone];
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
    
    buttonTogglePreset.selected = true;
    buttonToggleFocus.selected = false;
    buttonToggleBasic.selected = false;
    buttonToggleEffect.selected = false;
    buttonToggleLens.selected = false;
    buttonToggleFilm.selected = false;
    buttonToggleBlend.selected = false;
    
    buttonReset.hidden = false;
    currentTab = kTabPreset;
    
    buttonReset.enabled = false;
    
    [self resizeCameraViewWithAnimation:YES];
    
    previewFilter = [[GPUImagePicture alloc] initWithImage:imagePreview];
    [self preparePipe];
    [self applyFilterSetting];
    
    [self processImage];
    [self initPreviewPic];
    filterMain.toneEnable = NO;
}

- (void)initPreviewPic {
    GPUImagePicture *gpuimagePreview = [[GPUImagePicture alloc] initWithImage:_imageThumbnail];
    
    for (NSInteger i = 0; i < effectNum; i++) {
        GPUImageView *imageViewPreview = effectPreview[i];
        LXImageFilter *filterSample = [[LXImageFilter alloc] init];
        filterSample.toneCurve = effectCurve[i];
        filterSample.toneEnable = YES;
        [gpuimagePreview addTarget:filterSample];
        [filterSample addTarget:imageViewPreview atTextureLocation:0];
    }
    [gpuimagePreview processImage];
    
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
    imageFullsize = _imageOriginal;
    imagePreview = _imageOriginalPreview;
    imageSize = _imageOriginalPreview.size;
    
    [self switchEditImage];
    buttonReset.enabled = false;
}

- (void)resetSetting {
    sliderExposure.value = 0.0;
    sliderClear.value = 0.0;
    sliderSaturation.value = 1.0;
    sliderFeather.value = 10.0;
    sliderEffectIntensity.value = 1.0;
    
    filterMain.toneEnable = NO;
    filterMain.blendEnable = NO;
    filterMain.filmEnable = NO;
    
    filterMain.toneCurve = nil;
    filterMain.imageBlend = nil;
    
    pictureDOF = nil;
    filterMain.imageFilm = nil;
    
    [self setUIMask:kMaskBlurNone];
    
    buttonLensFish.enabled = true;
    buttonLensWide.enabled = true;
    buttonLensNormal.enabled = false;
    
    buttonBlendNone.enabled = false;
    buttonBlendMedium.enabled = true;
    buttonBlendStrong.enabled = true;
    buttonBlendWeak.enabled = true;

    buttonFilmNone.enabled = false;
    buttonFilmMedium.enabled = true;
    buttonFilmStrong.enabled = true;
    buttonFilmWeak.enabled = true;
    
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
            filterDOF.dofEnable = NO;
            break;
        case kMaskBlurWeak:
            buttonBlurWeak.enabled = false;
            filterDOF.dofEnable = YES;
            filterDOF.bias = 0.01;
            break;
        case kMaskBlurNormal:
            buttonBlurNormal.enabled = false;
            filterDOF.dofEnable = YES;
            filterDOF.bias = 0.02;
            break;
        case kMaskBlurStrong:
            buttonBlurStrong.enabled = false;
            filterDOF.dofEnable = YES;
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
            blendid = 1 + rand() % 30;
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
        default:
            break;
    }
    
    UIImage *imageBlend = [UIImage imageNamed:currentBlend];
    filterMain.imageBlend = imageBlend;
    
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
    
    filterMain.blendRegion = crop;
    
    if (!buttonBlendNone.enabled) {
        buttonBlendNone.enabled = YES;
        buttonBlendWeak.enabled = NO;
        filterMain.blendIntensity = 0.40;
        filterMain.blendEnable = YES;
    }
    
    
    [self processImage];
}


- (void)toggleFilm:(UIButton *)sender {
    currentFilm = [NSString stringWithFormat:@"print%d.jpg", sender.tag];
    UIImage *imageFilm = [UIImage imageNamed:currentFilm];
    filterMain.imageFilm = imageFilm;
    
    CGSize blendSize = imageFilm.size;
    
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
    
    filterMain.filmRegion = crop;
    
    if (!buttonFilmNone.enabled) {
        buttonFilmNone.enabled = YES;
        buttonFilmWeak.enabled = NO;
        filterMain.filmIntensity = 0.30;
        filterMain.filmEnable = YES;
    }
    
    [self processImage];
}

- (IBAction)setBlend:(UIButton *)sender {
    [self setBlendImpl:sender.tag];
    [self processImage];
}

- (IBAction)setFilm:(UIButton *)sender {
    [self setFilmImpl:sender.tag];
    [self processImage];
}

- (IBAction)printTemplate:(id)sender {
    NSLog(@"<key>toneEnable</key>%@", filterMain.toneEnable?@"<true/>":@"<false/>");
    NSLog(@"<key>toneImage</key><string>%@</string>", currentEffect);
    NSLog(@"<key>toneCurveIntensity</key><real>%f</real>", filterMain.toneCurveIntensity);
    NSLog(@"<key>brightness</key><real>%f</real>", filterMain.brightness);
    NSLog(@"<key>saturation</key><real>%f</real>", filterMain.saturation);
    NSLog(@"<key>clearness</key><real>%f</real>", filterMain.clearness);
    NSLog(@"<key>vignfade</key><real>%f</real>", filterMain.vignfade);
    NSLog(@"<key>blendEnable</key>%@", filterMain.filmEnable?@"<true/>":@"<false/>");
    NSLog(@"<key>blendImage</key><string>%@</string>", currentBlend);
    NSLog(@"<key>blendIntensity</key><real>%f</real>", filterMain.blendIntensity);
    NSLog(@"<key>filmEnable</key>%@", filterMain.filmEnable?@"<true/>":@"<false/>");
    NSLog(@"<key>filmImage</key><string>%@</string>", currentFilm);
    NSLog(@"<key>filmIntensity</key><real>%f</real>", filterMain.filmIntensity);
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

- (void)setBlendImpl:(NSInteger)tag {
    buttonBlendNone.enabled = true;
    buttonBlendStrong.enabled = true;
    buttonBlendWeak.enabled = true;
    buttonBlendMedium.enabled = true;
    
    switch (tag) {
        case kBlendNone:
            buttonBlendNone.enabled = false;
            filterMain.blendEnable = NO;
            filterMain.blendIntensity = 0;
            break;
        case kBlendWeak:
            buttonBlendWeak.enabled = false;
            filterMain.blendEnable = YES;
            filterMain.blendIntensity = 0.4;
            break;
        case kBlendNormal:
            buttonBlendMedium.enabled = false;
            filterMain.blendEnable = YES;
            filterMain.blendIntensity = 0.66;
            break;
        case kBlendStrong:
            buttonBlendStrong.enabled = false;
            filterMain.blendEnable = YES;
            filterMain.blendIntensity = 0.90;
            break;
        default:
            break;
    }
}

- (void)setFilmImpl:(NSInteger)tag {
    buttonFilmNone.enabled = true;
    buttonFilmStrong.enabled = true;
    buttonFilmWeak.enabled = true;
    buttonFilmMedium.enabled = true;
    
    switch (tag) {
        case kBlendNone:
            buttonFilmNone.enabled = false;
            filterMain.filmEnable = NO;
            filterMain.filmIntensity = 0;
            break;
        case kBlendWeak:
            buttonFilmWeak.enabled = false;
            filterMain.filmEnable = YES;
            filterMain.filmIntensity = 0.30;
            break;
        case kBlendNormal:
            buttonFilmMedium.enabled = false;
            filterMain.filmEnable = YES;
            filterMain.filmIntensity = 0.60;
            break;
        case kBlendStrong:
            buttonFilmStrong.enabled = false;
            filterMain.filmEnable = YES;
            filterMain.filmIntensity = 0.90;
            break;
        default:
            break;
    }
}

- (void)newMask:(UIImage *)mask {
    if (!buttonBlurNone.enabled) {
        [self setUIMask:kMaskBlurNormal];
    }
    
    pictureDOF = [[GPUImagePicture alloc] initWithImage:mask];
    
    [self preparePipe];
    [self processImage];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

- (void)newTextImage:(UIImage *)textImage {
    filterMain.imageBlend = textImage;
    filterMain.blendIntensity = 1.0;
    filterMain.blendEnable = YES;
    [self processImage];
}

- (void)setPreset:(UIButton*)button {
    NSDictionary *preset = arrayPreset[button.tag];
    [filterMain setValuesForKeysWithDictionary:preset];
    
    sliderClear.value = [preset[@"clearness"] floatValue];
    sliderEffectIntensity.value = [preset[@"toneCurveIntensity"] floatValue];
    sliderExposure.value = [preset[@"brightness"] floatValue];
    sliderSaturation.value = [preset[@"saturation"] floatValue];
    sliderVignette.value = [preset[@"vignfade"] floatValue];
    
    currentBlend = preset[@"blendImage"];
    currentEffect = preset[@"toneImage"];
    currentFilm = preset[@"filmImage"];

    [self processImage];
}

- (void)viewDidUnload {
    [self setScrollFilm:nil];
    [self setViewFilmControl:nil];
    [self setButtonFilmNone:nil];
    [self setButtonFilmWeak:nil];
    [self setButtonFilmMedium:nil];
    [self setButtonFilmStrong:nil];
    [self setButtonTogglePreset:nil];
    [self setViewPresetControl:nil];
    [self setScrollPreset:nil];
    [super viewDidUnload];
}
@end
