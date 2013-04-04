//
//  luxeysCameraViewController.m
//  Latte
//
//  Created by Xuan Dung Bui on 7/20/12.
//  Copyright (c) 2012 LUXEYS. All rights reserved.
//

#import "LXCameraViewController.h"
#import "LXAppDelegate.h"
#import "ALAssetsLibrary+CustomPhotoAlbum.h"
#import "GPUImageFilter+saveToLibrary.h"
#import "LXUploadObject.h"
#import "UIDeviceHardware.h"
#import "UIDeviceHardware.h"
#import "LXFilterFish.h"
#import "LXShare.h"
#import "RDActionSheet.h"
#import "LXImageFilter.h"
#import "LXImageLens.h"


#define kAccelerometerFrequency        10.0 //Hz

@interface LXCameraViewController ()  {
    LXStillCamera *videoCamera;
    GPUImageSharpenFilter *filterSharpen;
    GPUImageFilterPipeline *pipe;
    LXFilterFish *filterFish;
    LXImageFilter *filterMain;
    LXImageLens *filterLens;
    
    GPUImagePicture *previewFilter;
    
    CGSize picSize;
    
    UIActionSheet *sheet;
    
    NSMutableDictionary *imageMeta;
    NSTimer *timer;
    NSInteger timerCount;
    
    BOOL isEditing;
    BOOL isSaved;
    BOOL isKeyboard;
    BOOL isWatingToUpload;
    BOOL isBackCamera;
    BOOL isPicFromCamera;
    BOOL didBackupPic;
    
    NSInteger currentLens;
    NSInteger currentTimer;
    NSInteger currentMask;
    NSInteger currentBlend;
    NSInteger effectNum;
    NSMutableArray *effectPreview;
    NSMutableArray *effectCurve;
    
    NSLayoutConstraint *cameraAspect;
    NSInteger timerMode;
    CLLocationManager *locationManager;
    CLLocation *bestEffortAtLocation;
    UIImageOrientation imageOrientation;
    UIInterfaceOrientation uiOrientation;
    UIInterfaceOrientation orientationLast;
    MBProgressHUD *HUD;
    
    NSData *savedData;
    UIImage *savedPreview;
    UIImage *capturedImage;
    NSInteger currentTab;
    
    LXShare *laSharekit;
    LXUploadObject *currentUploader;
    
    MBRoundProgressView *viewRoundProgess;
}

@end

@implementation LXCameraViewController

@synthesize videoCamera;
@synthesize scrollEffect;
@synthesize scrollProcess;
@synthesize scrollBlend;
@synthesize sliderEffectIntensity;
@synthesize viewShoot;

@synthesize viewCamera;
@synthesize viewTimer;
@synthesize buttonCapture;
@synthesize buttonYes;
@synthesize buttonNo;
@synthesize buttonTimer;
@synthesize buttonFlash;
@synthesize buttonFlash35;
@synthesize buttonFlip;
@synthesize buttonReset;
@synthesize buttonPickTop;

@synthesize gesturePan;
@synthesize viewBottomBar;
@synthesize imageAutoFocus;
@synthesize buttonPick;
@synthesize buttonSetNoTimer;
@synthesize buttonSetTimer5s;
@synthesize tapFocus;

@synthesize buttonToggleFocus;
@synthesize buttonToggleEffect;
@synthesize buttonToggleBasic;
@synthesize buttonToggleLens;
@synthesize buttonToggleText;
@synthesize buttonToggleBlend;

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

@synthesize buttonLensNormal;
@synthesize buttonLensWide;
@synthesize buttonLensFish;

@synthesize buttonClose;
@synthesize viewCameraWraper;
@synthesize viewDraw;
@synthesize buttonToggleFisheye;

@synthesize viewBasicControl;
@synthesize viewFocusControl;
@synthesize viewLensControl;
@synthesize viewEffectControl;
@synthesize viewBlendControl;

@synthesize viewCanvas;

@synthesize viewTopBar;
@synthesize viewTopBar35;

@synthesize sliderExposure;
@synthesize sliderVignette;
@synthesize sliderSharpness;
@synthesize sliderClear;
@synthesize sliderSaturation;
@synthesize sliderFeather;

@synthesize buttonUploadStatus;

@synthesize delegate;

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
        isEditing = false;
        
        viewDraw.isEmpty = YES;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    viewRoundProgess = [[MBRoundProgressView alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    viewRoundProgess.userInteractionEnabled = false;

    [buttonUploadStatus addSubview:viewRoundProgess];
    
    isBackCamera = YES;
    orientationLast = UIInterfaceOrientationPortrait;
    LXAppDelegate* app = (LXAppDelegate*)[UIApplication sharedApplication].delegate;
    [app.tracker sendView:@"Camera Screen"];
    
    self.navigationController.modalPresentationStyle = UIModalPresentationCurrentContext;
    // LAShare
    laSharekit = [[LXShare alloc] init];
    laSharekit.controller = self;
    
    isKeyboard = NO;
    
    UIImage *imageCanvas = [[UIImage imageNamed:@"bg_canvas.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(8, 8, 8, 8)];
    viewCanvas.image = imageCanvas;
    
    UIBezierPath *shadowPathCamera = [UIBezierPath bezierPathWithRect:viewCameraWraper.bounds];
    viewCameraWraper.layer.masksToBounds = NO;
    viewCameraWraper.layer.shadowColor = [UIColor blackColor].CGColor;
    viewCameraWraper.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
    viewCameraWraper.layer.shadowOpacity = 1.0;
    viewCameraWraper.layer.shadowRadius = 5.0;
    viewCameraWraper.layer.shadowPath = shadowPathCamera.CGPath;
    
    isSaved = true;
    viewDraw.delegate = self;
    viewDraw.lineWidth = 10.0;
    currentTab = kTabPreview;
    
    currentLens = 0;
    currentTimer = kTimerNone;
    
    HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:HUD];
    HUD.userInteractionEnabled = NO;
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    
    [nc addObserver:self selector:@selector(receiveLoggedIn:) name:@"LoggedIn" object:nil];
    [nc addObserver:self selector:@selector(uploaderSuccess:) name:@"LXUploaderSuccess" object:nil];
    [nc addObserver:self selector:@selector(uploaderFail:) name:@"LXUploaderFail" object:nil];
    [nc addObserver:self selector:@selector(uploaderProgress:) name:@"LXUploaderProgress" object:nil];
    
    scrollProcess.contentSize = CGSizeMake(320, 50);

    pipe = [[GPUImageFilterPipeline alloc] init];
    pipe.filters = [[NSMutableArray alloc] init];
    filterMain = [[LXImageFilter alloc] init];
    
    videoCamera = [[LXStillCamera alloc] initWithSessionPreset:AVCaptureSessionPresetPhoto cameraPosition:AVCaptureDevicePositionBack];
    [videoCamera setOutputImageOrientation:UIInterfaceOrientationPortrait];
    
    // GPS Info
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [locationManager startUpdatingLocation];
    [self performSelector:@selector(stopUpdatingLocation:) withObject:nil afterDelay:45];
    
    effectNum = 17;
    effectPreview = [[NSMutableArray alloc] initWithCapacity:effectNum];
    effectCurve = [[NSMutableArray alloc] initWithCapacity:effectNum];
    
    for (int i=0; i < effectNum; i++) {
        [effectCurve addObject:[UIImage imageNamed:[NSString stringWithFormat:@"curve%d.JPG", i]]];
        UILabel *labelEffect = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 70, 12)];
        labelEffect.backgroundColor = [UIColor clearColor];
        labelEffect.textColor = [UIColor whiteColor];
        labelEffect.shadowColor = [UIColor blackColor];
        labelEffect.shadowOffset = CGSizeMake(0.0, 1.0);
        labelEffect.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:11];
        labelEffect.userInteractionEnabled = NO;
        UIButton *buttonEffect = [[UIButton alloc] initWithFrame:CGRectMake(5+75*i, 0, 70, 70)];
        GPUImageView *effectView = [[GPUImageView alloc] initWithFrame:CGRectMake(0, 0, 70, 70)];
        effectView.fillMode = kGPUImageFillModePreserveAspectRatioAndFill;
        effectView.userInteractionEnabled = NO;
        
        [effectPreview addObject:effectView];
        
        UIView *labelBack = [[UIView alloc] initWithFrame:CGRectMake(0, 53, 70, 20)];
        labelBack.userInteractionEnabled = NO;
        labelBack.backgroundColor = [UIColor blackColor];
        labelBack.alpha = 0.4;
        [buttonEffect addSubview:effectView];
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
            default:
                labelEffect.text = @"Original";
                break;
        }
        
        [scrollEffect addSubview:buttonEffect];
        [scrollEffect addSubview:labelEffect];
    }
    scrollEffect.contentSize = CGSizeMake(effectNum*75+10, 70);
    
    
    for (int i=0; i < 4; i++) {
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
                labelBlend.text = @"Lightblur";
                break;
            case 3:
                labelBlend.text = @"Grain";
                break;
        }
        
        [scrollBlend addSubview:buttonBlend];
        [scrollBlend addSubview:labelBlend];
    }
    scrollBlend.contentSize = CGSizeMake(2*55+10, 60);
    
    [self resizeCameraViewWithAnimation:NO];
    [self preparePipe];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        [videoCamera startCameraCapture];
    });
}

- (void)uploaderSuccess:(NSNotification *)notification {
    currentUploader = nil;
    
    [UIView animateWithDuration:0.3
                          delay:0.0
                        options:UIViewAnimationCurveEaseInOut
                     animations:^{
                         buttonUploadStatus.alpha = 0.0;
                     } completion:^(BOOL finished) {
                         buttonUploadStatus.hidden = true;
                     }];
}

- (void)uploaderFail:(NSNotification *)notification {
    viewRoundProgess.hidden = true;
    [buttonUploadStatus setImage:[UIImage imageNamed:@"bt_info.png"]
                        forState:UIControlStateNormal];
    currentUploader = notification.object;
}


- (void)uploaderProgress:(NSNotification *)notification {
    viewRoundProgess.hidden = false;
    buttonUploadStatus.hidden = false;
    buttonUploadStatus.alpha = 0.75;
    
    [buttonUploadStatus setImage:nil
                        forState:UIControlStateNormal];
    
    LXUploadObject *uploader = notification.object;
    viewRoundProgess.progress = uploader.percent;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    UIAccelerometer* a = [UIAccelerometer sharedAccelerometer];
    a.updateInterval = 1 / kAccelerometerFrequency;
    a.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated {
    [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
    self.navigationController.navigationBarHidden = YES;
    LXAppDelegate *app = [LXAppDelegate currentDelegate];
    app.controllerCamera = self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillDisappear:(BOOL)animated
{
    UIAccelerometer* a = [UIAccelerometer sharedAccelerometer];
    a.delegate = nil;
    [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        [videoCamera stopCameraCapture];
    });
    
    [super viewWillDisappear:animated];
    
    LXAppDelegate *app = [LXAppDelegate currentDelegate];
    app.controllerCamera = nil;
}

- (void)preparePipe {
    [self preparePipe:nil];
}


- (void)preparePipe:(GPUImagePicture*)source {
    filterFish = nil;
    filterLens = nil;
    
    if (isEditing) {
        [pipe removeAllFilters];
        
        if (source != nil) {
            pipe.input = source;
            pipe.output = nil;
        }
        else {
            [previewFilter removeAllTargets];
            pipe.input = previewFilter;
            pipe.output = viewCamera;
        }
        
        if (!buttonLensWide.enabled) {
            filterLens = [[LXImageLens alloc] init];
            [pipe addFilter:filterLens];
        }
        
        if (!buttonLensFish.enabled) {
            filterFish = [[LXFilterFish alloc] init];
            [pipe addFilter:filterFish];
        }
        
        [filterMain removeAllTargets];
        [pipe addFilter:filterMain];
        
        filterSharpen = [[GPUImageSharpenFilter alloc] init];
        [pipe addFilter:filterSharpen];
        
    } else {
        pipe.input = videoCamera;
        pipe.output = viewCamera;
        [pipe removeAllFilters];
        if (buttonToggleFisheye.selected) {
            filterFish = [[LXFilterFish alloc] init];
            [pipe addFilter:filterFish];
        }
    }
}

- (void)applyFilterSetting {
    filterMain.vignfade = 0.8-sliderVignette.value;
    filterMain.brightness = sliderExposure.value;
    filterMain.clearness = sliderClear.value;
    filterMain.saturation = sliderSaturation.value;
    
    filterSharpen.sharpness = sliderSharpness.value;
    
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
        filterMain.gain = 2.0;
    else
        filterMain.gain = 0.0;
}

- (void)processImage {
    isSaved = false;
    buttonReset.enabled = true;
    [previewFilter processImage];
}

- (void)setEffect:(id)sender {
    UIButton* buttonEffect = (UIButton*)sender;
    filterMain.toneCurve = effectCurve[buttonEffect.tag];
    [self processImage];
}


- (void)updateTargetPoint {
    CGPoint point = CGPointMake(imageAutoFocus.center.x/viewCamera.frame.size.width, imageAutoFocus.center.y/viewCamera.frame.size.height);
    
    
    [self setFocusPoint:point];
    [self setMetteringPoint:point];
    //        imageAutoFocus.hidden = false;
    imageAutoFocus.alpha = 1.0;
    [UIView animateWithDuration:0.3
                          delay:1.0
                        options:UIViewAnimationCurveEaseInOut
                     animations:^{
                         imageAutoFocus.alpha = 0.0;
                     } completion:^(BOOL finished) {
                         //imageAutoFocus.hidden = true;
                     }];
}

- (void)capturePhotoAsync {
    // Save last GPS and Orientation
    [locationManager stopUpdatingLocation];
    
    [videoCamera pauseCameraCapture];
    [videoCamera capturePhotoAsSampleBufferWithCompletionHandler:^(CMSampleBufferRef imageSampleBuffer, NSError *error) {
        [videoCamera resumeCameraCapture];
        if (error) {
            TFLog(error.description);
        } else {
            [videoCamera stopCameraCapture];
            
            NSData *jpeg = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageSampleBuffer];
            imageMeta = [NSMutableDictionary dictionaryWithDictionary:videoCamera.currentCaptureMetadata];
            
            // Add GPS
            NSDictionary *location;
            if (bestEffortAtLocation != nil) {
                location = [LXUtils getGPSDictionaryForLocation:bestEffortAtLocation];
                [imageMeta setObject:location forKey:(NSString *)kCGImagePropertyGPSDictionary];
            }
            
            // Create formatted date
            NSMutableDictionary *dictForEXIF = [imageMeta objectForKey:(NSString *)kCGImagePropertyExifDictionary];
            NSMutableDictionary *dictForTIFF = [imageMeta objectForKey:(NSString *)kCGImagePropertyTIFFDictionary];
            if (dictForTIFF == nil) {
                dictForTIFF = [[NSMutableDictionary alloc] init];
            }
            if (dictForEXIF == nil) {
                dictForEXIF = [[NSMutableDictionary alloc] init];
            }
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"yyyy:MM:dd HH:mm:ss"];
            NSString *stringDate = [formatter stringFromDate:[NSDate date]];
            
            UIDeviceHardware *hardware = [[UIDeviceHardware alloc] init];
            
            [dictForEXIF setObject:stringDate forKey:(NSString *)kCGImagePropertyExifDateTimeDigitized];
            [dictForEXIF setObject:stringDate forKey:(NSString *)kCGImagePropertyExifDateTimeOriginal];
            [dictForTIFF setObject:stringDate forKey:(NSString *)kCGImagePropertyTIFFDateTime];
            [dictForTIFF setObject:@"Apple" forKey:(NSString *)kCGImagePropertyTIFFMake];
            [dictForTIFF setObject:hardware.platformString forKey:(NSString *)kCGImagePropertyTIFFModel];
            [imageMeta setObject:dictForEXIF forKey:(NSString *)kCGImagePropertyExifDictionary];
            [imageMeta setObject:dictForTIFF forKey:(NSString *)kCGImagePropertyTIFFDictionary];
            
            // Save GPS & Correct orientation
            
            capturedImage = [UIImage imageWithData:jpeg];
            imageOrientation = capturedImage.imageOrientation;
            
            picSize = capturedImage.size;
            CGSize previewUISize = CGSizeMake(300.0, [LXUtils heightFromWidth:300.0 width:capturedImage.size.width height:capturedImage.size.height]);
            
            UIImage *previewPic = [LXCameraViewController imageWithImage:capturedImage scaledToSize:previewUISize];
            savedPreview = previewPic;
            
            previewFilter = [[GPUImagePicture alloc] initWithImage:previewPic];
            
            isPicFromCamera = true;

            [self switchEditImage];
        }
        
        buttonCapture.enabled = true;
    } withOrientation:orientationLast];
}

+ (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize {
    //UIGraphicsBeginImageContext(newSize);
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

- (IBAction)cameraTouch:(UITapGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateRecognized) {
        CGPoint location = [sender locationInView:self.viewCamera];
        
        imageAutoFocus.hidden = false;
        [UIView animateWithDuration:0.1 animations:^{
            imageAutoFocus.alpha = 1;
        }];
        
        imageAutoFocus.center = location;
        
        [self updateTargetPoint];
    }
}

- (IBAction)openImagePicker:(id)sender {
    if (!isEditing) {
        [locationManager stopUpdatingLocation];
    }
    
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc]init];
    imagePicker.delegate = self;
    [imagePicker.navigationBar setBackgroundImage:[UIImage imageNamed: @"bg_head.png"] forBarMetrics:UIBarMetricsDefault];
    
    [self presentViewController:imagePicker animated:NO completion:nil];
}

- (IBAction)close:(id)sender {
    if (!isSaved) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"photo_hasnt_been_saved", @"写真が保存されていません")
                                                        message:NSLocalizedString(@"stop_camera_confirm", @"カメラを閉じますか？")
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"cancel", @"キャンセル")
                                              otherButtonTitles:NSLocalizedString(@"stop_camera", @"はい"), nil];
        alert.tag = 2;
        [alert show];
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (IBAction)capture:(id)sender {
    buttonPick.hidden = true;
    buttonCapture.enabled = false;
    if (currentTimer == kTimerNone) {
        [self capturePhotoAsync];
    } else {
        timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(countDown:) userInfo:nil repeats:YES];
    }
}

- (IBAction)changeLens:(UIButton*)sender {
    buttonLensFish.enabled = true;
    buttonLensNormal.enabled = true;
    buttonLensWide.enabled = true;
    
    sender.enabled = false;
    
    currentLens = sender.tag;
    [self preparePipe];
    [self applyFilterSetting];
    [self processImage];
}

- (IBAction)changeFlash:(id)sender {
    buttonFlash.selected = !buttonFlash.selected;
    buttonFlash35.selected = !buttonFlash35.selected;
    [self setFlash:buttonFlash.selected];
}

- (IBAction)touchTimer:(id)sender {
    // wait for time before begin
    [viewTimer setHidden:!viewTimer.isHidden];
}

- (IBAction)touchSave:(id)sender {
    buttonYes.enabled = false;
    HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:HUD];
    HUD.userInteractionEnabled = NO;
    HUD.mode = MBProgressHUDModeIndeterminate;
    HUD.dimBackground = YES;
    
    [HUD show:NO];
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    
    [self getFinalImage:^{
        buttonYes.enabled = true;
        [[UIApplication sharedApplication] endIgnoringInteractionEvents];
        [self processSavedData];
    }];
}

- (void)receiveLoggedIn:(NSNotification *)notification
{
    if (isEditing && isWatingToUpload && isSaved) {
        [self processSavedData];
    }
}

- (void)processSavedData {
    LXAppDelegate* app = (LXAppDelegate*)[UIApplication sharedApplication].delegate;
    
    if (app.currentUser != nil) {
        if (delegate == nil) {
            LXPicEditViewController *controllerPicEdit = [[UIStoryboard storyboardWithName:@"Gallery"
                                                                            bundle: nil] instantiateViewControllerWithIdentifier:@"PicEdit"];
            controllerPicEdit.imageData = savedData;
            controllerPicEdit.preview = savedPreview;
            [self.navigationController pushViewController:controllerPicEdit animated:YES];
        } else {
            NSDictionary *info = [[NSDictionary alloc] initWithObjectsAndKeys:
                                  savedData, @"data",
                                  savedPreview, @"preview",
                                  nil];
            [delegate imagePickerController:self didFinishPickingMediaWithData:info];
            [self dismissViewControllerAnimated:YES completion:nil];
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
                    laSharekit.imageData = savedData;
                    laSharekit.imagePreview = savedPreview;
                    
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

- (void)getFinalImage:(void(^)())block {
    if (isSaved) {
        block();
        
        [HUD hide:YES];
        return;
    }
    
    // Prepare meta data
    if (imageMeta == nil) {
        imageMeta = [[NSMutableDictionary alloc] init];
    }
    // Add App Info
    NSMutableDictionary *dictForTIFF = [imageMeta objectForKey:(NSString *)kCGImagePropertyTIFFDictionary];
    if (dictForTIFF == nil) {
        dictForTIFF = [[NSMutableDictionary alloc] init];
    }
    [dictForTIFF setObject:@"Latte camera" forKey:(NSString *)kCGImagePropertyTIFFSoftware];
    [imageMeta setObject:dictForTIFF forKey:(NSString *)kCGImagePropertyTIFFDictionary];
    
    // If this is new photo save original pic first, and then process
    if (isPicFromCamera && !didBackupPic) {
        ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
        [library writeImageToSavedPhotosAlbum:capturedImage.CGImage metadata:imageMeta completionBlock:^(NSURL *assetURL, NSError *error) {
            didBackupPic = true;
            [self processRawAndSave:^{
                block();
            }];
        }];
    } else {
        [self processRawAndSave:^{
            block();
        }];
    }
}

- (void)processRawAndSave:(void(^)())block {
    CGImageRef cgImagePreviewFromBytes = [pipe newCGImageFromCurrentFilteredFrameWithOrientation:imageOrientation];
    savedPreview = [UIImage imageWithCGImage:cgImagePreviewFromBytes];
    CGImageRelease(cgImagePreviewFromBytes);
    
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    
    GPUImagePicture *picture = [[GPUImagePicture alloc] initWithImage:capturedImage];
    [self preparePipe:picture];
    [self applyFilterSetting];

    GPUImageRotationMode imageViewRotationModeIdx1 = kGPUImageNoRotation;

    switch (imageOrientation) {
        case UIImageOrientationLeft:
            imageViewRotationModeIdx1 = kGPUImageRotateRight;
            break;
        case UIImageOrientationRight:
            imageViewRotationModeIdx1 = kGPUImageRotateLeft;
            break;
        case UIImageOrientationDown:
            imageViewRotationModeIdx1 = kGPUImageRotate180;
            break;
        case UIImageOrientationUp:
            imageViewRotationModeIdx1 = kGPUImageNoRotation;
            break;
        default:
            imageViewRotationModeIdx1 = kGPUImageRotateLeft;
            break;
    }
    filterMain.blendRotation = imageViewRotationModeIdx1;

    [(GPUImageFilter *)[pipe.filters lastObject] prepareForImageCapture];
    
    [picture processImage];
    
    // Save to Jpeg NSData
    CGImageRef cgImageFromBytes = [pipe newCGImageFromCurrentFilteredFrameWithOrientation:imageOrientation];
    UIImage *outputImage = [UIImage imageWithCGImage:cgImageFromBytes];
    NSData *jpeg = UIImageJPEGRepresentation(outputImage, 0.9);
    CGImageRelease(cgImageFromBytes);
    
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
        savedData = [NSData dataWithData:dest_data];
        isSaved = true;
        
        //cleanup
        
        CFRelease(destination);
    }
    CFRelease(source);
    
    // Save now
    block();
    
    
    
    [library writeImageDataToSavedPhotosAlbum:savedData metadata:nil completionBlock:^(NSURL *assetURL, NSError *error) {
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
        [self applyFilterSetting];
        [self processImage];
        filterMain.blendRotation = kGPUImageNoRotation;
    }];
    
}

- (IBAction)toggleControl:(UIButton*)sender {
    // Disable Text
    if (sender.tag == kTabText) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"error", @"Error")
                                                        message:NSLocalizedString(@"feature_not_available", @"Feature Not Available")
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"close", @"Close")
                                              otherButtonTitles: nil];
        [alert show];
        return;
    }
    
    if (sender.tag == currentTab) {
        currentTab = kTabPreview;
        sender.selected = false;
    }
    else {
        currentTab = sender.tag;
        sender.selected = true;
    }
    
    switch (currentTab) {
        case kTabEffect:
            buttonToggleFocus.selected = false;
            buttonToggleBasic.selected = false;
            buttonToggleLens.selected = false;
            buttonToggleText.selected = false;
            buttonToggleBlend.selected = false;
            //            buttonTo
            break;
        case kTabBasic:
            buttonToggleFocus.selected = false;
            buttonToggleEffect.selected = false;
            buttonToggleLens.selected = false;
            buttonToggleText.selected = false;
            buttonToggleBlend.selected = false;
            break;
        case kTabLens:
            buttonToggleFocus.selected = false;
            buttonToggleEffect.selected = false;
            buttonToggleBasic.selected = false;
            buttonToggleText.selected = false;
            buttonToggleBlend.selected = false;
            break;
        case kTabText:
            buttonToggleFocus.selected = false;
            buttonToggleEffect.selected = false;
            buttonToggleBasic.selected = false;
            buttonToggleLens.selected = false;
            buttonToggleBlend.selected = false;
            break;
        case kTabBlend:
            buttonToggleFocus.selected = false;
            buttonToggleEffect.selected = false;
            buttonToggleBasic.selected = false;
            buttonToggleLens.selected = false;
            buttonToggleText.selected = false;
            break;
        case kTabBokeh: {
            buttonToggleEffect.selected = false;
            buttonToggleBasic.selected = false;
            buttonToggleLens.selected = false;
            buttonToggleText.selected = false;
            buttonToggleBlend.selected = false;
            
            // Firsttime
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            if (![defaults objectForKey:@"firstRunBokeh"]) {
                [defaults setObject:[NSDate date] forKey:@"firstRunBokeh"];
                [self touchOpenHelp:nil];
            }
        }
            break;
        default:
            buttonToggleEffect.selected = false;
            buttonToggleFocus.selected = false;
            buttonToggleBasic.selected = false;
            buttonToggleText.selected = false;
            buttonToggleLens.selected = false;
            buttonToggleBlend.selected = false;
            break;
    }
    
    [self resizeCameraViewWithAnimation:YES];
    
    viewDraw.hidden = currentTab != kTabBokeh;
    
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)resizeCameraViewWithAnimation:(BOOL)animation {
    CGRect screen = [[UIScreen mainScreen] bounds];
    
    CGRect frame = viewCameraWraper.frame;
    CGRect frameEffect = viewEffectControl.frame;
    CGRect frameBokeh = viewFocusControl.frame;
    CGRect frameBasic = viewBasicControl.frame;
    CGRect frameLens = viewLensControl.frame;
    CGRect frameTopBar = viewTopBar.frame;
    CGRect frameCanvas;
    CGRect frameBlend = viewBlendControl.frame;
    
    
    CGFloat posBottom;
    
    if (screen.size.height > 480) {
        posBottom = 568 - 50;
    }
    else {
        posBottom = 480 - 50;
    }
    
    frameEffect.origin.y = frameBokeh.origin.y = frameBasic.origin.y = frameLens.origin.y = frameBlend.origin.y =  posBottom;
    
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
        case kTabPreview:
            break;
    }
    
    
    if (isEditing) {
        CGFloat height;
        if (screen.size.height > 480) {
            height = 568 - 50 - 40 - 20;
        }
        else {
            height = 480 - 50 - 40 - 20;
        }
        
        if (currentTab != kTabPreview) {
            if ((currentTab == kTabText) && (!isKeyboard))
                height -= 140;
            else
                height -= 110;
        }
        
        frameCanvas = CGRectMake(0, 40, 320, height+20);
        
        CGFloat horizontalRatio = 300.0 / picSize.width;
        CGFloat verticalRatio = height / picSize.height;
        CGFloat ratio;
        ratio = MIN(horizontalRatio, verticalRatio);
        
        frame.size = CGSizeMake(picSize.width*ratio, picSize.height*ratio);
        frame.origin = CGPointMake((320-frame.size.width)/2, (height - frame.size.height)/2 + 50.0);
        
        viewTopBar.hidden = false;
        viewTopBar35.hidden = true;
        
    } else {
        if (screen.size.height > 480) {
            frame = CGRectMake(10, 79, 300, 400);
            frameCanvas = CGRectMake(0, 40, 320, 568-40-50);
        }
        else {
            frame = CGRectMake(10, 15, 300, 400);
            frameCanvas = CGRectMake(0, 0, 320, 430);
        }
        
        if (screen.size.height > 480) {
            viewTopBar.hidden = false;
            viewTopBar35.hidden = true;
        }
        else {
            viewTopBar.hidden = true;
            viewTopBar35.hidden = false;
        }
    }
    
//    viewCameraWraper.layer.shadowRadius = 5.0;
    viewCameraWraper.layer.shadowPath = nil;

    [UIView animateWithDuration:animation?0.3:0 animations:^{
        viewFocusControl.frame = frameBokeh;
        viewEffectControl.frame = frameEffect;
        viewBasicControl.frame = frameBasic;
        viewLensControl.frame = frameLens;
        viewCameraWraper.frame = frame;
        viewTopBar.frame = frameTopBar;
        viewCanvas.frame = frameCanvas;
        viewBlendControl.frame = frameBlend;

    } completion:^(BOOL finished) {
        viewCameraWraper.layer.shadowRadius = 5.0;
        UIBezierPath *shadowPathCamera = [UIBezierPath bezierPathWithRect:viewCameraWraper.bounds];
        viewCameraWraper.layer.shadowPath = shadowPathCamera.CGPath;
    }];
}

- (UIImageOrientation) imageOrientationForUI:(UIInterfaceOrientation)orientation
{
	switch (orientation) {
		case UIInterfaceOrientationPortrait:
			return UIImageOrientationUp;
		case UIInterfaceOrientationLandscapeLeft:
			return UIImageOrientationUp;
		case UIInterfaceOrientationLandscapeRight:
			return UIImageOrientationUp;
		case UIInterfaceOrientationPortraitUpsideDown:
			return UIImageOrientationRight;
		default:
			return UIImageOrientationLeft;
	}
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [locationManager stopUpdatingLocation];
    
    ALAssetsLibraryAssetForURLResultBlock resultblock = ^(ALAsset *myasset)
    {
        [picker dismissViewControllerAnimated:NO completion:nil];
        
        bestEffortAtLocation = nil;
        imageMeta = [NSMutableDictionary dictionaryWithDictionary:myasset.defaultRepresentation.metadata];
        
        capturedImage = [info objectForKey:UIImagePickerControllerOriginalImage];
        imageOrientation = capturedImage.imageOrientation;
        
        picSize = capturedImage.size;
        
        //
        CGSize previewUISize = CGSizeMake(300.0, [LXUtils heightFromWidth:300.0 width:capturedImage.size.width height:capturedImage.size.height]);
        UIImage *previewPic = [LXCameraViewController imageWithImage:capturedImage scaledToSize:previewUISize];
        savedPreview = previewPic;
        
        previewFilter = [[GPUImagePicture alloc] initWithImage:previewPic];
        isPicFromCamera = false;

        [self switchEditImage];
    };
    
    //
    ALAssetsLibraryAccessFailureBlock failureblock  = ^(NSError *myerror)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"error", @"Error")
                                                        message:[myerror localizedDescription]
                                                       delegate:nil
                                              cancelButtonTitle:NSLocalizedString(@"cancel", @"Error")
                                              otherButtonTitles:nil];
        [alert show];
    };
    
    ALAssetsLibrary* assetslibrary = [[ALAssetsLibrary alloc] init];
    [assetslibrary assetForURL:[info objectForKey:UIImagePickerControllerReferenceURL]
                   resultBlock:resultblock
                  failureBlock:failureblock];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:NO completion:nil];
    if (!isEditing) {
        [self switchCamera];
    }
}

- (void)switchCamera {
    isSaved = true;
    // Clear memory/blur mode
    previewFilter = nil;
    capturedImage = nil;
    
    // Set to normal lens
    currentLens = 0;
    currentTab = kTabPreview;
    viewDraw.hidden = true;
    viewDraw.isEmpty = true;
    
    buttonBlurNone.enabled = false;
    
    [locationManager startUpdatingLocation];
    
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        [videoCamera startCameraCapture];
    });
    
    
    buttonNo.hidden = YES;
    buttonYes.hidden = YES;
    
    buttonFlash.hidden = NO;
    buttonTimer.hidden = NO;
    buttonFlip.hidden = NO;
    imageAutoFocus.hidden = NO;
    buttonReset.hidden = YES;
    buttonPickTop.hidden = YES;
    
    buttonPick.hidden = NO;
    tapFocus.enabled = true;
    
    scrollEffect.hidden = false;
    
    scrollProcess.hidden = YES;
    viewShoot.hidden = NO;
    
    buttonClose.hidden = NO;
    isEditing = NO;
    
    [self resizeCameraViewWithAnimation:NO];
    [self preparePipe];
}

- (void)switchEditImage {
    [self resetSetting];
    [self initPreviewPic];

    isWatingToUpload = NO;
    didBackupPic = NO;

    currentBlend = kBlendNone;
    [self setBlendImpl:kBlendNone];
    //    isFixedAspectBlend = NO;
    
    //    uiWrap.frame = CGRectMake(0, 0, previewSize.width, previewSize.height);
    
    currentLens = 0;
    currentMask = kMaskBlurNone;
    
    isEditing = YES;
    
    buttonNo.hidden = NO;
    buttonYes.hidden = NO;
    buttonFlash.hidden = YES;
    buttonTimer.hidden = YES;
    buttonFlip.hidden = YES;

    buttonPickTop.hidden = NO;

    viewShoot.hidden = YES;
    scrollProcess.hidden = NO;
    
    buttonClose.hidden = YES;
    imageAutoFocus.hidden = YES;
    viewTimer.hidden = YES;
    tapFocus.enabled = false;
    isSaved = FALSE;
    
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
    buttonToggleText.selected = false;
    buttonToggleBlend.selected = false;
    
    buttonReset.hidden = false;
    currentTab = kTabEffect;
    
    buttonReset.enabled = false;
    
    [self resizeCameraViewWithAnimation:YES];
    [self preparePipe];
    [self applyFilterSetting];
    [self processImage];
    
    //Hacky
    [self preparePipe];
    [self applyFilterSetting];
    [self processImage];
}

- (void)initPreviewPic {
    [previewFilter removeAllTargets];
    for (NSInteger i = 0; i < effectNum; i++) {
        LXImageFilter *filterSample = [[LXImageFilter alloc] init];
        filterSample.toneCurve = effectCurve[i];

        GPUImageView *effectView = effectPreview[i];
        [previewFilter addTarget:filterSample];
        [filterSample addTarget:effectView];
    }
    [previewFilter processImage];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(NSDictionary *)info {
    if ([segue.identifier isEqualToString:@"HelpBokeh"]) {
        
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
    } else
        [self switchCamera];
}

- (IBAction)touchReset:(id)sender {
    [self resetSetting];
    
    [self preparePipe];
    [self applyFilterSetting];
    [self processImage];
    buttonReset.enabled = false;
}

- (void)resetSetting {
    sliderExposure.value = 0.0;
    sliderClear.value = 0.0;
    sliderSaturation.value = 1.0;
    sliderSharpness.value = 0.0;
    sliderVignette.value = 0.0;
    sliderFeather.value = 10.0;
    sliderEffectIntensity.value = 1.0;
    
    filterMain.toneCurve = effectCurve[0];
    filterMain.imageBlend = nil;
    filterMain.dofEnable = NO;
    filterMain.imageDOF = nil;
    
    [self setUIMask:kMaskBlurNone];
    
    buttonLensFish.enabled = true;
    buttonLensWide.enabled = true;
    buttonLensNormal.enabled = false;
    
    buttonBlendNone.enabled = false;
    buttonBlendMedium.enabled = true;
    buttonBlendStrong.enabled = true;
    buttonBlendWeak.enabled = true;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (alertView.tag) {
        case 1: //Touch No
            if (buttonIndex == 1)
                [self switchCamera];
            break;
        case 2:
            if (buttonIndex == 1) {
                [self.navigationController dismissViewControllerAnimated:YES completion:nil];
            }
            break;
        case 3: //Retry upload
            if (buttonIndex == 1) {
                [currentUploader upload];
            }
        default:
            break;
    }
}


- (IBAction)flipCamera:(id)sender {
    isBackCamera = !isBackCamera;
    [videoCamera rotateCamera];
}

- (IBAction)panTarget:(UIPanGestureRecognizer *)sender {
    CGPoint translation = [sender translationInView:viewCamera];
    CGPoint center = CGPointMake(sender.view.center.x + translation.x,
                                 sender.view.center.y + translation.y);
    center.x = center.x<0?0:(center.x>320?320:center.x);
    center.y = center.y<0?0:(center.y>viewCamera.frame.size.height?viewCamera.frame.size.height:center.y);
    sender.view.center = center;
    [sender setTranslation:CGPointMake(0, 0) inView:viewCamera];
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        [self updateTargetPoint];
    }
}

- (IBAction)setTimer:(UIButton *)sender {
    buttonSetNoTimer.enabled = true;
    buttonSetTimer5s.enabled = true;
    buttonSetNoTimer.alpha = 0.4;
    buttonSetTimer5s.alpha = 0.4;
    
    sender.enabled = false;
    sender.alpha = 0.9;
    
    switch (sender.tag) {
        case 0:
            timerCount = 0;
            currentTimer = kTimerNone;
            break;
        case 1:
            currentTimer = kTimer5s;
            timerCount = 5;
            break;
        case 2:
            timerCount = 10;
            currentTimer = kTimer10s;
            break;
        case 3:
            currentTimer = kTimerContinuous;
            break;
        default:
            break;
    }
}


- (IBAction)setMask:(UIButton*)sender {
    [self setUIMask:sender.tag];
    [self applyFilterSetting];
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
            filterMain.dofEnable = NO;
            break;
        case kMaskBlurWeak:
            buttonBlurWeak.enabled = false;
            filterMain.dofEnable = YES;
            filterMain.bias = 0.01;
            break;
        case kMaskBlurNormal:
            buttonBlurNormal.enabled = false;
            filterMain.dofEnable = YES;
            filterMain.bias = 0.02;
            break;
        case kMaskBlurStrong:
            buttonBlurStrong.enabled = false;
            filterMain.dofEnable = YES;
            filterMain.bias = 0.03;
            break;
        default:
            break;
    }
    
    currentMask = tag;
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
    NSString *blendPic;
    NSInteger blendid;
    BOOL isFixedAspectBlend = NO;
    switch (sender.tag) {
        case 0:
            blendid = 1 + rand() % 71;
            blendPic = [NSString stringWithFormat:@"leak%d.jpg", blendid];
            break;
        case 1:
            isFixedAspectBlend = YES;
            blendid = 1 + rand() % 35;
            blendPic = [NSString stringWithFormat:@"bokehcircle-%d.jpg", blendid];
            break;
        case 2:
            isFixedAspectBlend = YES;
            blendid = 1 + rand() % 25;
            blendPic = [NSString stringWithFormat:@"lightblur-%d.JPG", blendid];
            break;

        case 3:
            isFixedAspectBlend = YES;
            blendid = 1 + rand() % 4;
            blendPic = [NSString stringWithFormat:@"print%d.jpg", blendid];
            break;

        default:
            break;
    }
    
    UIImage *imageBlend = [UIImage imageNamed:blendPic];
    filterMain.imageBlend = [UIImage imageNamed:blendPic];
    
    if (isFixedAspectBlend) {
        CGSize blendSize = imageBlend.size;
        
        CGFloat ratioWidth = blendSize.width / picSize.width;
        CGFloat ratioHeight = blendSize.height / picSize.height;
        CGRect crop;
        
        CGFloat ratio = MIN(ratioWidth, ratioHeight);
        CGSize newSize = CGSizeMake(blendSize.width / ratio, blendSize.height / ratio);
        if (newSize.width > picSize.width) {
            CGFloat sub = (newSize.width - picSize.width) / newSize.width;
            crop = CGRectMake(sub/2.0, 0.0, 1.0-sub, 1.0);
        } else {
            CGFloat sub = (newSize.height - picSize.height) / newSize.height;
            crop = CGRectMake(0.0, sub/2.0, 1.0, 1.0-sub);
        }
        
        filterMain.blendRegion = crop;
    }
    
    if (!buttonBlendNone.enabled) {
        buttonBlendNone.enabled = YES;
        buttonBlendWeak.enabled = NO;
        filterMain.blendIntensity = 0.40;
    }
    
    
    [self processImage];
}

- (IBAction)setBlend:(UIButton *)sender {
    [self setBlendImpl:sender.tag];
}

- (IBAction)toggleFisheye:(UIButton *)sender {
    sender.selected = !sender.selected;
    buttonLensNormal.enabled = sender.selected;
    buttonLensFish.enabled = !sender.selected;
    buttonLensWide.enabled = true;
    [self preparePipe];
}

- (IBAction)touchUploadStatus:(id)sender {
    switch (currentUploader.uploadState) {
        case kUploadStateSuccess:
            break;
        case kUploadStateFail:
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"error", @"Error")
                                                            message:NSLocalizedString(@"cannot_upload", @"")
                                                           delegate:self
                                                  cancelButtonTitle:NSLocalizedString(@"close", "Close")
                                                  otherButtonTitles:NSLocalizedString(@"retry_upload", "Retry"), nil];
            alert.tag = 3;
            [alert show];
        }
            break;
        case kUploadStateProgress:
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                            message:NSLocalizedString(@"uploading", @"Uploading :)")
                                                           delegate:nil
                                                  cancelButtonTitle:NSLocalizedString(@"close", "Close")
                                                  otherButtonTitles:nil];
            [alert show];
        }
            break;
        default:
            break;
    }
}

- (void)setBlendImpl:(NSInteger)tag {
    buttonBlendNone.enabled = true;
    buttonBlendStrong.enabled = true;
    buttonBlendWeak.enabled = true;
    buttonBlendMedium.enabled = true;
    
    switch (tag) {
        case kBlendNone:
            buttonBlendNone.enabled = false;
            filterMain.blendIntensity = 0;
            break;
        case kBlendWeak:
            buttonBlendWeak.enabled = false;
            filterMain.blendIntensity = 0.4;
            break;
        case kBlendNormal:
            buttonBlendMedium.enabled = false;
            filterMain.blendIntensity = 0.66;
            break;
        case kBlendStrong:
            buttonBlendStrong.enabled = false;
            filterMain.blendIntensity = 0.90;
            break;
        default:
            break;
    }
    
    currentBlend = tag;
    [self processImage];
}


- (void)countDown:(id)sender {
    if (timerCount == 0) {
        switch (currentTimer) {
            case kTimerNone:
                timerCount = 0;
                break;
            case kTimer5s:
                timerCount = 5;
                break;
            case kTimer10s:
                timerCount = 10;
                break;
            case kTimerContinuous:
                currentTimer = kTimerContinuous;
                break;
            default:
                break;
        }
        
        [timer invalidate];
        [self capturePhotoAsync];
    } else {
        MBProgressHUD *count = [[MBProgressHUD alloc] initWithView:self.view];
        [self.view addSubview:count];
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
        label.text = [NSString stringWithFormat:@"%d", timerCount];
        label.textColor = [UIColor whiteColor];
        label.backgroundColor = [UIColor clearColor];
        label.font = [UIFont systemFontOfSize:100];
        label.textAlignment = NSTextAlignmentCenter;
        count.customView = label;
        count.mode = MBProgressHUDModeCustomView;
        
        [count show:YES];
        [count hide:YES afterDelay:0.5];
        count.removeFromSuperViewOnHide = YES;
    }
    timerCount--;
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    NSTimeInterval locationAge = -[newLocation.timestamp timeIntervalSinceNow];
    if (locationAge > 5.0) return;
    
    if (newLocation.horizontalAccuracy < 0) return;
    
    if (bestEffortAtLocation == nil || bestEffortAtLocation.horizontalAccuracy > newLocation.horizontalAccuracy) {
        bestEffortAtLocation = newLocation;
        if (newLocation.horizontalAccuracy <= locationManager.desiredAccuracy) {
            [locationManager stopUpdatingLocation];
        }
    }
}

- (void)stopUpdatingLocation:(id)sender {
    [locationManager stopUpdatingLocation];
    locationManager.delegate = nil;
}

- (void)setFlash:(BOOL)flash {
    AVCaptureDevice *device = videoCamera.inputCamera;
    
    NSError *error;
    if ([device lockForConfiguration:&error]) {
        if ([device isFlashAvailable]) {
            if (flash)
                [device setFlashMode:AVCaptureFlashModeOn];
            else
                [device setFlashMode:AVCaptureFlashModeOff];
            [device unlockForConfiguration];
        }
    } else {
        TFLog(@"ERROR = %@", error);
    }
}

- (void)setFocusPoint:(CGPoint)point {
    AVCaptureDevice *device = videoCamera.inputCamera;
    
    CGPoint pointOfInterest;
    
    pointOfInterest = CGPointMake(point.y, 1.0 - point.x);
    
    NSError *error;
    if ([device lockForConfiguration:&error]) {
        if ([device isFocusPointOfInterestSupported] && [device isFocusModeSupported:AVCaptureFocusModeAutoFocus]) {
            [device setFocusPointOfInterest:pointOfInterest];
            [device setFocusMode:AVCaptureFocusModeAutoFocus];
            [device unlockForConfiguration];
        }
    } else {
        TFLog(@"ERROR = %@", error);
    }
}


- (void)setMetteringPoint:(CGPoint)point {
    AVCaptureDevice *device = videoCamera.inputCamera;
    
    CGPoint pointOfInterest;
    pointOfInterest = CGPointMake(point.y, 1.0 - point.x);
    
    NSError *error;
    if ([device lockForConfiguration:&error]) {;
        if([device isExposurePointOfInterestSupported] && [device isExposureModeSupported:AVCaptureExposureModeContinuousAutoExposure])
        {
            [device setExposurePointOfInterest:pointOfInterest];
            [device setExposureMode:AVCaptureExposureModeContinuousAutoExposure];
        }
        [device unlockForConfiguration];
    } else {
        TFLog(@"ERROR = %@", error);
    }
}

#ifdef DEBUG
+(NSString*)orientationToText:(const UIInterfaceOrientation)ORIENTATION {
    switch (ORIENTATION) {
        case UIInterfaceOrientationPortrait:
            return @"UIInterfaceOrientationPortrait";
        case UIInterfaceOrientationPortraitUpsideDown:
            return @"UIInterfaceOrientationPortraitUpsideDown";
        case UIInterfaceOrientationLandscapeLeft:
            return @"UIInterfaceOrientationLandscapeLeft";
        case UIInterfaceOrientationLandscapeRight:
            return @"UIInterfaceOrientationLandscapeRight";
    }
    return @"Unknown orientation!";
}
#endif

#pragma mark UIAccelerometerDelegate
-(void)accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration {
    UIInterfaceOrientation orientationNew;
    if (acceleration.x >= 0.75) {
        orientationNew = UIInterfaceOrientationLandscapeLeft;
    }
    else if (acceleration.x <= -0.75) {
        orientationNew = UIInterfaceOrientationLandscapeRight;
    }
    else if (acceleration.y <= -0.75) {
        orientationNew = UIInterfaceOrientationPortrait;
    }
    else if (acceleration.y >= 0.75) {
        orientationNew = UIInterfaceOrientationPortraitUpsideDown;
    }
    else {
        // Consider same as last time
        return;
    }
    
    if (orientationNew == orientationLast)
        return;
#ifdef DEBUG
    TFLog(@"Going from %@ to %@!", [[self class] orientationToText:orientationLast], [[self class] orientationToText:orientationNew]);
#endif
    orientationLast = orientationNew;
}
#pragma mark -

- (void)newMask:(UIImage *)mask {
    if (!buttonBlurNone.enabled) {
        [self setUIMask:kMaskBlurNormal];
    }
    
    filterMain.imageDOF = mask;
    
    [self processImage];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

@end
