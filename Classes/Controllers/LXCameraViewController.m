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

#define kAccelerometerFrequency        10.0 //Hz

@interface LXCameraViewController ()  {
    LXStillCamera *videoCamera;
    GPUImageSharpenFilter *filterSharpen;
    LXFilterPipe *pipe;
    LXFilterDetail *filter;
    LXFilterDOF *filterDOF;
    LXFilterFish *filterFish;
    GPUImageAlphaBlendFilter *filterText;
    GPUImageCropFilter *blendCrop;
    GPUImagePinchDistortionFilter *filterDistord;
    GPUImageFilter *effect;
    LXFilterScreenBlend *screenBlend;
    GPUImageAlphaBlendFilter *filterIntensity;
    UIDeviceHardware *deviceHardware;
    
    GPUImagePicture *previewFilter;
    GPUImagePicture *pictureBlend;
    GPUImageRawDataInput *pictureDOF;
    GPUImageUIElement *uiElement;
    
    UIView *uiWrap;
    UILabel *timeLabel;
    
    CGSize picSize;
    CGSize previewUISize;
    CGSize blendSize;
    
    UIActionSheet *sheet;
    UIImagePickerController *imagePicker;
    NSMutableDictionary *imageMeta;
    NSTimer *timer;
    NSInteger timerCount;
    CGSize keyboardSize;
    CGPoint posText;
    CGFloat mCurrentScale;
    CGFloat mLastScale;
    NSInteger uploadState;
    
    BOOL isEditing;
    BOOL isSaved;
    BOOL isKeyboard;
    BOOL isWatingToUpload;
    BOOL isFixedAspectBlend;
    BOOL isBackCamera;
    
    NSInteger currentEffect;
    NSInteger currentLens;
    NSInteger currentTimer;
    NSString *currentFont;
    NSString *currentText;
    NSInteger currentMask;
    NSInteger currentBlend;
    NSInteger effectNum;
    NSMutableArray *effectPreview;
    
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
@synthesize tapCloseHelp;

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
@synthesize scrollFont;
@synthesize buttonToggleFisheye;

@synthesize viewBasicControl;
@synthesize viewFocusControl;
@synthesize viewLensControl;
@synthesize viewTextControl;
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

@synthesize textText;

@synthesize buttonUploadStatus;

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
    
    // COMPLETION BLOCKS
    [laSharekit setCompletionDone:^{
        TFLog(@"Share OK");
    }];
    [laSharekit setCompletionCanceled:^{
        TFLog(@"Share Canceled");
    }];
    [laSharekit setCompletionFailed:^{
        TFLog(@"Share Failed");
    }];
    [laSharekit setCompletionSaved:^{
        TFLog(@"Share Saved");
    }];
    
    isKeyboard = NO;
    
    UIImage *imageCanvas = [[UIImage imageNamed:@"bg_canvas.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(8, 8, 8, 8)];
    viewCanvas.image = imageCanvas;
    
    deviceHardware = [[UIDeviceHardware alloc] init];
    
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
    currentEffect = 0;
    currentLens = 0;
    currentTimer = kTimerNone;
    uploadState = kUploadOK;
    
    HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:HUD];
    HUD.userInteractionEnabled = NO;
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(keyboardWillShow:) name: UIKeyboardWillShowNotification object:nil];
    [nc addObserver:self selector:@selector(keyboardWillHide:) name: UIKeyboardWillHideNotification object:nil];
    [nc addObserver:self selector:@selector(receiveLoggedIn:) name:@"LoggedIn" object:nil];
    
    scrollProcess.contentSize = CGSizeMake(384, 50);
	// Do any additional setup after loading the view.
    // Setup filter
    uiWrap = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 480, 640)];
    timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 600, 600)];
    timeLabel.textAlignment = NSTextAlignmentCenter;
    timeLabel.backgroundColor = [UIColor clearColor];
    timeLabel.textColor = [UIColor whiteColor];
    timeLabel.shadowColor = [UIColor blackColor];
    timeLabel.shadowOffset = CGSizeMake(0, 1);
    [uiWrap addSubview:timeLabel];
    
    pipe = [[LXFilterPipe alloc] init];
    pipe.filters = [[NSMutableArray alloc] init];
    
    filter = [[LXFilterDetail alloc] init];
    pictureDOF = [[GPUImageRawDataInput alloc] initWithBytes:nil size:CGSizeMake(0, 0)];

    filterText = [[GPUImageAlphaBlendFilter alloc] init];
    filterText.mix = 1.0;
    
    //    uiElement = [[GPUImageUIElement alloc] initWithView:uiWrap];
    videoCamera = [[LXStillCamera alloc] initWithSessionPreset:AVCaptureSessionPresetPhoto cameraPosition:AVCaptureDevicePositionBack];
    [videoCamera setOutputImageOrientation:UIInterfaceOrientationPortrait];
    
    imagePicker = [[UIImagePickerController alloc]init];
    [imagePicker.navigationBar setBackgroundImage:[UIImage imageNamed: @"bg_head.png"] forBarMetrics:UIBarMetricsDefault];
    
    imagePicker.delegate = (id)self;
    
    // GPS Info
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [locationManager startUpdatingLocation];
    [self performSelector:@selector(stopUpdatingLocation:) withObject:nil afterDelay:45];
    
    effectNum = 17;
    effectPreview = [[NSMutableArray alloc] initWithCapacity:effectNum];
    
    for (int i=0; i < 17; i++) {
        UILabel *labelEffect = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 70, 12)];
        labelEffect.backgroundColor = [UIColor clearColor];
        labelEffect.textColor = [UIColor whiteColor];
        labelEffect.shadowColor = [UIColor blackColor];
        labelEffect.shadowOffset = CGSizeMake(0.0, 1.0);
        labelEffect.font = [UIFont fontWithName:@"AvenirNextCondensed-Regular" size:11];
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
    
    
    for (int i=0; i < 2; i++) {
        UILabel *labelBlend = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 50, 10)];
        labelBlend.backgroundColor = [UIColor clearColor];
        labelBlend.textColor = [UIColor whiteColor];
        labelBlend.font = [UIFont fontWithName:@"AvenirNextCondensed-Regular" size:9];
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

- (void)keyboardWillShow:(NSNotification *)notification
{
    keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    isKeyboard = YES;
    [self resizeCameraViewWithAnimation:YES];
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    isKeyboard = NO;
    [self resizeCameraViewWithAnimation:YES];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

- (void)selectFont:(UIButton*)sender {
    currentFont = sender.titleLabel.text;
    [self newText];
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
}

- (void)preparePipe {
    [self preparePipe:nil];
}


- (void)preparePipe:(GPUImageOutput *)picture {
    filter = nil;
    filterText = nil;
    filterFish = nil;
    filterDOF = nil;
    filterSharpen = nil;
    filterDistord = nil;
    screenBlend = nil;
    blendCrop = nil;
    
    if (isEditing) {
        if (pictureBlend != nil) {
            [pictureBlend removeAllTargets];
        }
        if (pictureDOF != nil) {
            [pictureDOF removeAllTargets];
        }
        [previewFilter removeAllTargets];
        
        if (picture != nil) {
            [picture removeAllTargets];
            pipe.input = picture;
            pipe.output = nil;
        } else {
            pipe.input = previewFilter;
            pipe.output = viewCamera;
        }
        
        [pipe removeAllFilters];
        
        filterSharpen = [[GPUImageSharpenFilter alloc] init];
        [pipe addFilter:filterSharpen];
        
        filter = [[LXFilterDetail alloc] init];
        [pipe addFilter:filter];
        
        
        if (!buttonLensWide.enabled) {
            filterDistord = [[GPUImagePinchDistortionFilter alloc] init];
            [pipe addFilter:filterDistord];
        }
        
        if (!buttonLensFish.enabled) {
            filterFish = [[LXFilterFish alloc] init];
            [pipe addFilter:filterFish];
        }
        
        
        if (buttonBlurNone.enabled) {
            filterDOF = [[LXFilterDOF alloc] init];
            [pipe addFilter:filterDOF];
        }
        
        if (buttonBlendNone.enabled) {
            screenBlend = [[LXFilterScreenBlend alloc] init];
            if (isFixedAspectBlend) {
                blendCrop = [[GPUImageCropFilter alloc] init];
            }
            [pipe addFilter:screenBlend];
        }
        
        //Film
        NSInteger mark;
        if (currentEffect != 0) {
            mark = pipe.filters.count-1;
            [pipe addFilter:[FilterManager getEffect:currentEffect]];
            filterIntensity = [[GPUImageAlphaBlendFilter alloc] init];
            [pipe addFilter:filterIntensity];
        }
        
        if (textText.text.length > 0) {
            [pipe addFilter:filterText];
        }
        
        // AFTER THIS LINE, NO MORE ADDFILTER
        if (currentEffect != 0) {
            GPUImageFilter *tmp = pipe.filters[mark];
            [tmp addTarget:pipe.filters[mark+2]];
        }
        
        // Two input filter has to be setup at last
        GPUImageRotationMode imageViewRotationModeIdx1 = kGPUImageNoRotation;
        
        if (picture != nil) {
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
        }
        
        if (buttonBlendNone.enabled) {
            [screenBlend setInputRotation:imageViewRotationModeIdx1 atIndex:1];
            if (isFixedAspectBlend) {
                [pictureBlend addTarget:blendCrop];
                [blendCrop addTarget:screenBlend atTextureLocation:1];
            } else
                [pictureBlend addTarget:screenBlend atTextureLocation:1];
        }
        
        
        if (buttonBlurNone.enabled) {
            [filterDOF setInputRotation:imageViewRotationModeIdx1 atIndex:1];
            [pictureDOF addTarget:filterDOF atTextureLocation:1];
        }
        
        if (textText.text.length > 0) {
            [filterText setInputRotation:imageViewRotationModeIdx1 atIndex:1];
            [uiElement addTarget:filterText];
        }
    } else {
        GPUImageFilter *dummy = [[GPUImageFilter alloc] init];
        [filterFish removeAllTargets];
        pipe.input = videoCamera;
        pipe.output = viewCamera;
        [pipe removeAllFilters];
        [pipe addFilter:dummy];
        if (buttonToggleFisheye.selected) {
            filterFish = [[LXFilterFish alloc] init];
            [pipe addFilter:filterFish];
        }
        [dummy prepareForImageCapture];
    }
}

- (void)applyFilterSetting {
    filter.vignfade = 0.8-sliderVignette.value;
    filter.brightness = sliderExposure.value;
    filter.clearness = sliderClear.value;
    filter.saturation = sliderSaturation.value;
    
    filterSharpen.sharpness = sliderSharpness.value;
    
    if (currentEffect != 0) {
        filterIntensity.mix = 1.0 - sliderEffectIntensity.value;
    }
    
    if (buttonBlendNone.enabled) {
        if (isFixedAspectBlend) {
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
            
            blendCrop.cropRegion = crop;
        }
    }
    
    if (!buttonBlendMedium.enabled) {
        screenBlend.mix = 0.66;
    }
    
    if (!buttonBlendWeak.enabled) {
        screenBlend.mix = 0.40;
    }
    
    if (!buttonBlendStrong.enabled) {
        screenBlend.mix = 0.90;
    }
    
    
    if (!buttonLensWide.enabled) {
        filterDistord.scale = 0.3;
        filterDistord.radius = 1.0;
    }
    
    if (!buttonBlurNormal.enabled) {
        filterDOF.bias = 0.02;
    }
    
    if (!buttonBlurWeak.enabled) {
        filterDOF.bias = 0.01;
    }
    
    if (!buttonBlurStrong.enabled) {
        filterDOF.bias = 0.03;
    }
    
    if (switchGain.on)
        filterDOF.gain = 2.0;
    else
        filterDOF.gain = 0.0;
}

- (void)processImage {
    isSaved = false;
    buttonReset.enabled = true;
    [previewFilter processImage];
    
    if (buttonBlendNone.enabled) {
        [pictureBlend processImage];
    }
    
    if (buttonBlurNone.enabled) {
        [pictureDOF processData];
    }
    
    //    if (currentText.length > 0) {
    //        [uiElement update];
    //    }
}

- (IBAction)setEffect:(id)sender {
    UIButton* buttonEffect = (UIButton*)sender;
    currentEffect = buttonEffect.tag;
    [self preparePipe];
    [self applyFilterSetting];
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
    buttonCapture.enabled = false;
    
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
            
            [dictForEXIF setObject:stringDate forKey:(NSString *)kCGImagePropertyExifDateTimeDigitized];
            [dictForEXIF setObject:stringDate forKey:(NSString *)kCGImagePropertyExifDateTimeOriginal];
            [dictForTIFF setObject:stringDate forKey:(NSString *)kCGImagePropertyTIFFDateTime];
            [imageMeta setObject:dictForEXIF forKey:(NSString *)kCGImagePropertyExifDictionary];
            [imageMeta setObject:dictForTIFF forKey:(NSString *)kCGImagePropertyTIFFDictionary];
            
            // Save GPS & Correct orientation
            
            capturedImage = [UIImage imageWithData:jpeg];
            imageOrientation = capturedImage.imageOrientation;
            
            picSize = capturedImage.size;
            previewUISize = CGSizeMake(300.0, [LXUtils heightFromWidth:300.0 width:capturedImage.size.width height:capturedImage.size.height]);
            
            UIImage *previewPic = [LXCameraViewController imageWithImage:capturedImage scaledToSize:previewUISize];
            
            previewFilter = [[GPUImagePicture alloc] initWithImage:previewPic];
            
            [self initPreviewPic];
            [self switchEditImage];
            [self resizeCameraViewWithAnimation:YES];
            [self preparePipe];
            [self applyFilterSetting];
            [self processImage];
            buttonReset.enabled = false;
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
        [videoCamera stopCameraCapture];
    }
    
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
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        [self getFinalImage:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                buttonYes.enabled = true;
                [[UIApplication sharedApplication] endIgnoringInteractionEvents];
                [self processSavedData];
            });
        }];
    });
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
        if (_delegate == nil) {
            [self performSegueWithIdentifier:@"Edit" sender:nil];
        } else {
            NSDictionary *info = [[NSDictionary alloc] initWithObjectsAndKeys:
                                  savedData, @"data",
                                  savedPreview, @"preview",
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
                            UINavigationController *modalLogin = [[UIStoryboard storyboardWithName:@"MainStoryboard"
                                                                                            bundle: nil] instantiateViewControllerWithIdentifier:@"LoginModal"];
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
        dispatch_async(dispatch_get_main_queue(), ^{
            [HUD hide:YES];
        });
        return;
    }
    
    CGImageRef cgImagePreviewFromBytes = [pipe newCGImageFromCurrentFilteredFrameWithOrientation:imageOrientation];
    savedPreview = [UIImage imageWithCGImage:cgImagePreviewFromBytes];
    CGImageRelease(cgImagePreviewFromBytes);
    
    GPUImagePicture *picture = [[GPUImagePicture alloc] initWithImage:capturedImage];
    
    [self preparePipe:picture];
    [self applyFilterSetting];
    [(GPUImageFilter *)[pipe.filters lastObject] prepareForImageCapture];
    
    [picture processImage];
    if (buttonBlendNone.enabled) {
        [pictureBlend processImage];
    }
    if (buttonBlurNone.enabled) {
        [pictureDOF processData];
    }
    
    // Save to Jpeg NSData
    CGImageRef cgImageFromBytes = [pipe newCGImageFromCurrentFilteredFrameWithOrientation:imageOrientation];
    NSData *jpeg = UIImageJPEGRepresentation([UIImage imageWithCGImage:cgImageFromBytes], 0.9);
    CGImageRelease(cgImageFromBytes);
    
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
    
    
    CGImageSourceRef source = CGImageSourceCreateWithData((__bridge CFDataRef)jpeg, NULL);
    
    CFStringRef UTI = CGImageSourceGetType(source); //this is the type of image (e.g., public.jpeg)
    
    //this will be the data CGImageDestinationRef will write into
    NSMutableData *dest_data = [NSMutableData data];
    
    CGImageDestinationRef destination = CGImageDestinationCreateWithData((__bridge CFMutableDataRef)dest_data,UTI,1,NULL);
    
    if(!destination) {
        NSLog(@"***Could not create image destination ***");
    }
    
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
    CFRelease(source);
    
    // Save now
    block();
    
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    
    [library writeImageDataToSavedPhotosAlbum:savedData metadata:nil completionBlock:^(NSURL *assetURL, NSError *error) {
        if (!error) {
            [library addAssetURL:assetURL toAlbum:@"Latte camera" withCompletionBlock:^(NSError *error) {
                TFLog(error.localizedDescription);
            }];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                HUD.mode = MBProgressHUDModeText;
                HUD.labelText = NSLocalizedString(@"saved_photo", @"Saved to Camera Roll") ;
                HUD.margin = 10.f;
                HUD.yOffset = 150.f;
                HUD.removeFromSuperViewOnHide = YES;
                HUD.dimBackground = NO;
                [HUD hide:YES afterDelay:2];
            });
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                HUD.mode = MBProgressHUDModeText;
                HUD.labelText = NSLocalizedString(@"cannot_save_photo", @"Cannot save to Camera Roll") ;
                HUD.margin = 10.f;
                HUD.yOffset = 150.f;
                HUD.removeFromSuperViewOnHide = YES;
                HUD.dimBackground = NO;
                [HUD hide:YES afterDelay:3];
            });
        }
        
        // Return to preview mode
        [picture removeAllTargets];
        [self preparePipe];
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
    CGRect frameText = viewTextControl.frame;
    CGRect frameCanvas = viewCanvas.frame;
    CGRect frameBlend = viewBlendControl.frame;
    
    
    CGFloat posBottom;
    
    if (screen.size.height > 480) {
        posBottom = 568 - 50;
    }
    else {
        posBottom = 480 - 50;
    }
    
    frameEffect.origin.y = frameBokeh.origin.y = frameBasic.origin.y = frameLens.origin.y = frameText.origin.y = frameBlend.origin.y =  posBottom;
    
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
        case kTabText:
            if (isKeyboard)
                frameText.origin.y = posBottom - keyboardSize.height + 20;
            else
                frameText.origin.y = posBottom - 140;
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
            else if ((currentTab == kTabText) && (isKeyboard)) {
                height -= keyboardSize.height - 20;
            }
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
    
    viewCameraWraper.layer.shadowRadius = 0;
    viewCameraWraper.layer.shadowPath = nil;

    [UIView animateWithDuration:animation?0.3:0 animations:^{
        viewFocusControl.frame = frameBokeh;
        viewEffectControl.frame = frameEffect;
        viewBasicControl.frame = frameBasic;
        viewLensControl.frame = frameLens;
        viewCameraWraper.frame = frame;
        viewTextControl.frame = frameText;
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
        bestEffortAtLocation = nil;
        imageMeta = [NSMutableDictionary dictionaryWithDictionary:myasset.defaultRepresentation.metadata];
        
        capturedImage = [info objectForKey:UIImagePickerControllerOriginalImage];
        imageOrientation = capturedImage.imageOrientation;
        
        picSize = capturedImage.size;
        
        //
        previewUISize = CGSizeMake(300.0, [LXUtils heightFromWidth:300.0 width:capturedImage.size.width height:capturedImage.size.height]);
        
        UIImage *previewPic = [LXCameraViewController imageWithImage:capturedImage scaledToSize:previewUISize];
        
        previewFilter = [[GPUImagePicture alloc] initWithImage:previewPic];
        
        [self initPreviewPic];
        [self switchEditImage];
        
        [imagePicker dismissViewControllerAnimated:NO completion:nil];
        
        [self resizeCameraViewWithAnimation:NO];
        [self preparePipe];
        [self applyFilterSetting];
        [self processImage];
        buttonReset.enabled = false;
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
    
    [textText resignFirstResponder];
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
    // Reset to normal lens
    [self resetSetting];
    currentFont = @"Arial";
    posText = CGPointMake(0.1, 0.5);
    textText.text = @"";
    currentText = @"";
    isWatingToUpload = NO;
    pictureBlend = nil;
    currentBlend = kBlendNone;
    [self setBlendImpl:kBlendNone];
    //    isFixedAspectBlend = NO;
    
    //    uiWrap.frame = CGRectMake(0, 0, previewSize.width, previewSize.height);
    timeLabel.center = uiWrap.center;
    
    
    mCurrentScale = 1.0;
    mLastScale = 1.0;
    
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
}

- (void)initPreviewPic {
    [previewFilter removeAllTargets];
    for (NSInteger i = 0; i < effectNum; i++) {
        GPUImageView *effectView = effectPreview[i];
        GPUImageFilter *effectSmallPreview = [FilterManager getEffect:i];
        if (effectSmallPreview != nil) {
            [previewFilter addTarget:effectSmallPreview];
            [effectSmallPreview addTarget:effectView];
        } else {
            [previewFilter addTarget:effectView];
        }
    }
    [previewFilter processImage];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(NSDictionary *)info {
    if ([segue.identifier isEqualToString:@"Edit"]) {
        LXPicEditViewController *controllerPicEdit = segue.destinationViewController;
        controllerPicEdit.imageData = savedData;
        controllerPicEdit.preview = savedPreview;
    }
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
    sliderSharpness.value = 0.25;
    sliderVignette.value = 0.0;
    sliderFeather.value = 10.0;
    sliderEffectIntensity.value = 1.0;
    currentEffect = 0;
    [self setUIMask:kMaskBlurNone];
    
    effect = nil;
    buttonLensFish.enabled = true;
    buttonLensWide.enabled = true;
    buttonLensNormal.enabled = false;
    
    buttonBlendNone.enabled = false;
    buttonBlendMedium.enabled = true;
    buttonBlendStrong.enabled = true;
    buttonBlendWeak.enabled = true;
    textText.text = @"";
    currentText = @"";
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (alertView.tag) {
        case 1: //Touch No
            if (buttonIndex == 1)
                [self switchCamera];
            break;
        case 2:
            if (buttonIndex == 1) {
                LXAppDelegate* app = (LXAppDelegate*)[UIApplication sharedApplication].delegate;
//                [app toogleCamera];
            }
            break;
        case 3: //Retry upload
            if (buttonIndex == 1) {
                [self uploadData];
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
            break;
        case kMaskBlurWeak:
            buttonBlurWeak.enabled = false;
            break;
        case kMaskBlurNormal:
            buttonBlurNormal.enabled = false;
            break;
        case kMaskBlurStrong:
            buttonBlurStrong.enabled = false;
            break;
        default:
            break;
    }
    
    if ((currentMask == kMaskBlurNone) != (tag == kMaskBlurNone)) {
        [self preparePipe];
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

- (IBAction)textChange:(UITextField *)sender {
    [self newText];
}


- (IBAction)pinchCamera:(UIPinchGestureRecognizer *)sender {
    if (textText.text.length > 0) {
        mCurrentScale += [sender scale] - mLastScale;
        mLastScale = [sender scale];
        
        if (sender.state == UIGestureRecognizerStateEnded)
        {
            mLastScale = 1.0;
        }
        
        timeLabel.layer.transform = CATransform3DMakeScale(mCurrentScale, mCurrentScale, 1.0);
        
        //        filterText.scale = mCurrentScale-0.7;
        [self applyFilterSetting];
        [self processImage];
    }
}

- (IBAction)panCamera:(UIPanGestureRecognizer *)sender {
    if (textText.text.length > 0) {
        CGPoint translation = [sender translationInView:viewCamera];
        
        CGPoint center = CGPointMake(timeLabel.center.x + translation.x, timeLabel.center.y + translation.y);
        timeLabel.center = center;
        
        [self processImage];
        [sender setTranslation:CGPointMake(0, 0) inView:viewCamera];
    }
}

- (IBAction)toggleBlending:(UIButton *)sender {
    NSString *blendPic;
    NSInteger blendid;
    
    switch (sender.tag) {
        case 0:
            isFixedAspectBlend = NO;
            blendid = 1 + rand() % 71;
            blendPic = [NSString stringWithFormat:@"leak%d.jpg", blendid];
            break;
        case 1:
            isFixedAspectBlend = YES;
            blendid = 1 + rand() % 35;
            blendPic = [NSString stringWithFormat:@"bokehcircle-%d.jpg", blendid];
            break;
        default:
            break;
    }
    
    UIImage *imageBlend = [UIImage imageNamed:blendPic];
    blendSize = imageBlend.size;
    
    pictureBlend = [[GPUImagePicture alloc] initWithImage:imageBlend];
    
    if (!buttonBlendNone.enabled) {
        buttonBlendNone.enabled = YES;
        buttonBlendWeak.enabled = NO;
    }
    
    [self preparePipe];
    [self applyFilterSetting];
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
    switch (uploadState) {
        case kUploadOK:
            break;
        case kUploadFail:
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
        case kUploadProgress:
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
            break;
        case kBlendWeak:
            buttonBlendWeak.enabled = false;
            break;
        case kBlendNormal:
            buttonBlendMedium.enabled = false;
            break;
        case kBlendStrong:
            buttonBlendStrong.enabled = false;
            break;
        default:
            break;
    }
    
    //    if ((currentBlend == kBlendNone) != (tag == kBlendNone)) {
    [self preparePipe];
    //    }
    currentBlend = tag;
    
    [self applyFilterSetting];
    [self processImage];
}

- (void)newText {
    if (textText.text.length > 0) {
        timeLabel.text = textText.text;
        timeLabel.font = [UIFont fontWithName:currentFont size:100.0];
    }
    if ((currentText.length > 0) != (textText.text.length > 0)) {
        [self preparePipe:NO];
    }
    currentText = textText.text;
    [self applyFilterSetting];
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
    
    GLubyte *imageData = NULL;
    // For resized image, redraw
    imageData = (GLubyte *) calloc(1, (int)mask.size.width * (int)mask.size.height * 4);
    CGColorSpaceRef genericRGBColorspace = CGColorSpaceCreateDeviceRGB();
    CGContextRef imageContext = CGBitmapContextCreate(imageData, (size_t)mask.size.width, (size_t)mask.size.height, 8, (size_t)mask.size.width * 4, genericRGBColorspace,  kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
    CGContextDrawImage(imageContext, CGRectMake(0.0, 0.0, mask.size.width, mask.size.height), mask.CGImage);
    CGContextRelease(imageContext);
    CGColorSpaceRelease(genericRGBColorspace);
    
    [pictureDOF updateDataFromBytes:imageData size:mask.size];
    free(imageData);
    
    [self applyFilterSetting];
    [self processImage];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

- (void)uploadData {
    void (^createForm)(id<AFMultipartFormData>) = ^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFileData:savedData
                                    name:@"file"
                                fileName:@"latte.jpg"
                                mimeType:@"image/jpeg"];
    };
    
    NSURLRequest *request = [[LatteAPIClient sharedClient] multipartFormRequestWithMethod:@"POST"
                                                                                     path:@"picture/upload"
                                                                               parameters:_dictUpload
                                                                constructingBodyWithBlock:createForm];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    void (^successUpload)(AFHTTPRequestOperation *, id) = ^(AFHTTPRequestOperation *operation, id responseObject) {
        TFLog(@"Upload done");
        
        uploadState = kUploadOK;
        
        [UIView animateWithDuration:0.3
                              delay:0.0
                            options:UIViewAnimationCurveEaseInOut
                         animations:^{
                             buttonUploadStatus.alpha = 0.0;
                         } completion:^(BOOL finished) {
                             buttonUploadStatus.hidden = true;
                         }];
    };
    
    void (^failUpload)(AFHTTPRequestOperation *, NSError *) = ^(AFHTTPRequestOperation *operation, NSError *error) {
        TFLog(@"Upload fail");
        uploadState = kUploadFail;
        viewRoundProgess.hidden = true;
        [buttonUploadStatus setImage:[UIImage imageNamed:@"bt_info.png"]
                            forState:UIControlStateNormal];
    };
    
    [operation setCompletionBlockWithSuccess: successUpload failure: failUpload];
    
    [operation setUploadProgressBlock:^(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite) {
        viewRoundProgess.progress = (float)totalBytesWritten/(float)totalBytesExpectedToWrite;
    }];
    
    uploadState = kUploadProgress;
    viewRoundProgess.hidden = false;
    buttonUploadStatus.hidden = false;
    buttonUploadStatus.alpha = 0.75;
    viewRoundProgess.progress = 0.0;
    [buttonUploadStatus setImage:nil
                        forState:UIControlStateNormal];

    
    [operation start];
}
@end
