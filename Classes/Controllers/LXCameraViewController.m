//
//  luxeysCameraViewController.m
//  Latte
//
//  Created by Xuan Dung Bui on 7/20/12.
//  Copyright (c) 2012 LUXEYS. All rights reserved.
//

#import "LXCameraViewController.h"
#import "LXAppDelegate.h"

#define kAccelerometerFrequency        10.0 //Hz

@interface LXCameraViewController ()

@end

@implementation LXCameraViewController

@synthesize scrollEffect;
@synthesize viewCamera;
@synthesize viewTimer;
@synthesize buttonCapture;
@synthesize buttonYes;
@synthesize buttonNo;
@synthesize buttonTimer;
@synthesize buttonFlash;
@synthesize buttonFlip;
@synthesize buttonReset;

@synthesize gesturePan;
@synthesize tapDoubleEditText;
@synthesize viewBottomBar;
@synthesize imageAutoFocus;
@synthesize buttonPick;
@synthesize delegate;
@synthesize buttonSetNoTimer;
@synthesize buttonSetTimer5s;
@synthesize tapFocus;
@synthesize tapCloseHelp;

@synthesize buttonToggleFocus;
@synthesize buttonToggleEffect;
@synthesize buttonToggleBasic;
@synthesize buttonToggleLens;
@synthesize buttonToggleText;

@synthesize buttonBackgroundNatual;
@synthesize switchGain;

@synthesize buttonBlurNone;
@synthesize buttonBlurNormal;
@synthesize buttonBlurStrong;
@synthesize buttonBlurWeak;

@synthesize buttonLensNormal;
@synthesize buttonLensWide;
@synthesize buttonLensFish;

@synthesize buttonClose;
@synthesize viewHelp;
@synthesize viewPopupHelp;
@synthesize viewCameraWraper;
@synthesize viewDraw;
@synthesize scrollFont;

@synthesize viewBasicControl;
@synthesize viewFocusControl;
@synthesize viewLensControl;
@synthesize viewTextControl;
@synthesize viewEffectControl;

@synthesize viewCanvas;

@synthesize viewTopBar;
@synthesize viewTopBar35;

@synthesize sliderExposure;
@synthesize sliderVignette;
@synthesize sliderSharpness;
@synthesize sliderClear;
@synthesize sliderSaturation;

@synthesize textText;

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
    
    UIImage *imageCanvas = [[UIImage imageNamed:@"bg_canvas.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(8, 8, 8, 8)];
    viewCanvas.image = imageCanvas;
    
    viewPopupHelp.layer.cornerRadius = 10.0;
    viewPopupHelp.layer.borderWidth = 1.0;
    viewPopupHelp.layer.borderColor = [[UIColor colorWithWhite:1.0 alpha:0.25] CGColor];
    
    viewCameraWraper.layer.masksToBounds = NO;
    viewCameraWraper.layer.shadowColor = [UIColor blackColor].CGColor;
    viewCameraWraper.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
    viewCameraWraper.layer.shadowOpacity = 1.0;
    viewCameraWraper.layer.shadowRadius = 5.0;
    
    isSaved = true;
    viewDraw.delegate = self;
    viewDraw.lineWidth = 10.0;
    currentTab = kTabPreview;
    currentEffect = 0;
    currentLens = 0;
    currentTimer = kTimerNone;
    
    HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:HUD];
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(keyboardWillShow:) name: UIKeyboardWillShowNotification object:nil];
    [nc addObserver:self selector:@selector(keyboardWillHide:) name: UIKeyboardWillHideNotification object:nil];
    
	// Do any additional setup after loading the view.
    // Setup filter
    pipe = [[GPUImageFilterPipeline alloc] init];
    pipe.filters = [[NSMutableArray alloc] init];
    pipe.output = viewCamera;
    filter = [[LXFilterDetail alloc] init];
    filterSharpen = [[GPUImageSharpenFilter alloc] init];
    filterFish = [[LXFilterFish alloc] init];
    filterDOF = [[LXFilterDOF alloc] init];
    filterText = [[LXFilterText alloc] init];
    
//    [filterDOF disableSecondFrameCheck];
//    [filterText disableSecondFrameCheck];
    effectManager = [[FilterManager alloc] init];
    
    videoCamera = [[GPUImageStillCamera alloc] initWithSessionPreset:AVCaptureSessionPresetPhoto cameraPosition:AVCaptureDevicePositionBack];
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
    
    for (int i=0; i < 16; i++) {
        UILabel *labelEffect = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 50, 10)];
        labelEffect.backgroundColor = [UIColor clearColor];
        labelEffect.textColor = [UIColor whiteColor];
        labelEffect.font = [UIFont fontWithName:@"AvenirNextCondensed-Regular" size:9];
        UIButton *buttonEffect = [[UIButton alloc] initWithFrame:CGRectMake(5+55*i, 5, 50, 50)];
        labelEffect.center = CGPointMake(buttonEffect.center.x, 63);
        labelEffect.textAlignment = NSTextAlignmentCenter;
        UIImage *preview = [UIImage imageNamed:[NSString stringWithFormat:@"sample%d.jpg", i]];
        if (preview != nil) {
            [buttonEffect setImage:preview forState:UIControlStateNormal];
        } else {
            [buttonEffect setBackgroundColor:[UIColor grayColor]];
        }
        
        [buttonEffect addTarget:self action:@selector(setEffect:) forControlEvents:UIControlEventTouchUpInside];
        buttonEffect.layer.cornerRadius = 5;
        buttonEffect.clipsToBounds = YES;
        buttonEffect.tag = i;
        switch (i) {
            case 1:
                labelEffect.text = @"Classic";
                break;
            case 2:
                labelEffect.text = @"Gummy";
                break;
            case 3:
                labelEffect.text = @"Maccha";
                break;
            case 4:
                labelEffect.text = @"Forest";
                break;
            case 5:
                labelEffect.text = @"Electrocute";
                break;
            case 6:
                labelEffect.text = @"Glory";
                break;
            case 7:
                labelEffect.text = @"Big time";
                break;
            case 8:
                labelEffect.text = @"Cozy";
                break;
            case 9:
                labelEffect.text = @"Haze";
                break;
            case 10:
                labelEffect.text = @"Autumn";
                break;
            case 11:
                labelEffect.text = @"Dreamy";
                break;
            case 12:
                labelEffect.text = @"Purple";
                break;
            case 13:
                labelEffect.text = @"Dorian";
                break;
            case 14:
                labelEffect.text = @"Stingray";
                break;
            case 15:
                labelEffect.text = @"Aussie";
                break;

            default:
                labelEffect.text = @"Original";
                break;
        }

        [scrollEffect addSubview:buttonEffect];
        [scrollEffect addSubview:labelEffect];
    }
    scrollEffect.contentSize = CGSizeMake(16*55+10, 60);
    
    // get font family
    NSArray *fontFamilyNames = [UIFont familyNames];
    
    // loop
    NSInteger i = 0;
    for (NSString *familyName in fontFamilyNames) {
        NSArray *fontNames = [UIFont fontNamesForFamilyName:familyName];

        CGRect frame = CGRectMake(0, i * 30, 320, 30);
        UIButton *buttonFont = [[UIButton alloc] initWithFrame:frame];
        buttonFont.titleLabel.text = familyName;
        buttonFont.titleLabel.textAlignment = NSTextAlignmentLeft;
        buttonFont.titleLabel.font = [UIFont fontWithName:fontNames[0] size:20];
        [buttonFont setTitle:familyName forState:UIControlStateNormal];
        buttonFont.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        [buttonFont addTarget:self action:@selector(selectFont:) forControlEvents:UIControlEventTouchUpInside];
        
        i++;
        [scrollFont addSubview:buttonFont];

    }
    scrollFont.contentSize = CGSizeMake(320, i * 30);
    
    [self resizeCameraViewWithAnimation:NO];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        [videoCamera startCameraCapture];
        [self applyCurrentFilters];
    });
}

- (void)keyboardWillShow:(NSNotification *)notification
{
    currentTab = kTabTextEdit;
    keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    [self resizeCameraViewWithAnimation:YES];
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    currentTab = kTabText;
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
    
    if (isEditing) {
        isSaved = false;
        savedData = nil;
        savedPreview = nil;
    }
    // Dispose of any resources that can be recreated.
}

- (void)viewWillDisappear:(BOOL)animated
{
    UIAccelerometer* a = [UIAccelerometer sharedAccelerometer];
    a.delegate = nil;
    [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
    
    [videoCamera pauseCameraCapture];
    [videoCamera stopCameraCapture];
    
    [super viewWillDisappear:animated];
}

- (void)viewDidUnload {
    [self setViewCamera:nil];
    [self setScrollEffect:nil];
    [self setImageAutoFocus:nil];
    [self setViewTimer:nil];
    
    videoCamera = nil;
    
    [self setButtonSetNoTimer:nil];
    [self setButtonSetTimer5s:nil];
    [self setTapFocus:nil];
    [self setViewFocusControl:nil];
    [self setButtonToggleFocus:nil];
    [self setViewCameraWraper:nil];
    [self setViewDraw:nil];
    [self setButtonBackgroundNatual:nil];
    [self setButtonBlurWeak:nil];
    [self setButtonBlurNormal:nil];
    [self setButtonBlurStrong:nil];
    [self setButtonBlurNone:nil];
    [self setViewHelp:nil];
    [self setViewPopupHelp:nil];
    [self setViewBasicControl:nil];
    [self setButtonClose:nil];
    [self setButtonToggleBasic:nil];
    [self setButtonToggleLens:nil];
    [self setViewLensControl:nil];
    [self setButtonToggleText:nil];
    [self setButtonLensNormal:nil];
    [self setButtonLensWide:nil];
    [self setButtonLensFish:nil];
    [self setViewTopBar:nil];
    [self setTapCloseHelp:nil];
    [self setViewTextControl:nil];
    [self setViewEffectControl:nil];
    [self setViewTopBar35:nil];
    [self setViewCanvas:nil];
    [self setSliderExposure:nil];
    [self setSliderVignette:nil];
    [self setSliderSharpness:nil];
    [self setSliderClear:nil];
    [self setSliderSaturation:nil];
    [self setButtonReset:nil];
    [self setSwitchGain:nil];
    [self setScrollFont:nil];
    [self setTapDoubleEditText:nil];
    [self setTextText:nil];
    [super viewDidUnload];
}


- (void)applyCurrentFilters {
    [self applyCurrentFilters:NO];
}

- (void)applyCurrentFilters:(BOOL)saving {
    if (isEditing) {
        isSaved = false;
        savedData = nil;
        savedPreview = nil;
        
        if (saving) {
            pipe.input = picture;
        } else {
            pipe.input = previewFilter;
        }
        
        [filter removeAllTargets];
        [filterText removeAllTargets];
        [filterFish removeAllTargets];
        [filterDOF removeAllTargets];
        [filterSharpen removeAllTargets];
        [pictureDOF removeAllTargets];
        [pictureText removeAllTargets];
        
        filter.vignfade = 0.8-sliderVignette.value;
        filter.brightness = sliderExposure.value;
        filter.clearness = sliderClear.value;
        filter.saturation = sliderSaturation.value;
        
        filterSharpen.sharpness = sliderSharpness.value;
        
        [pipe removeAllFilters];
        if (sliderSharpness.value > 0) {
            [pipe addFilter:filterSharpen];
        }
        
        [pipe addFilter:filter];
        
        if (!buttonLensFish.enabled) {
            [pipe addFilter:filterFish];
        }
        
        if (buttonBlurNone.enabled && (pictureDOF != nil)) {
            [pipe addFilter:filterDOF];
            
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
                filterDOF.gain = 1.0;
            else
                filterDOF.gain = 0.0;

        }
        
        if (effect != nil) {
            [pipe addFilter:effect];
        }
        
        if (textText.text.length > 0) {
            [pipe addFilter:filterText];
        }

        
        // Two input filter has to be setup at last
        GPUImageRotationMode imageViewRotationMode = kGPUImageNoRotation;
        switch (imageOrientation) {
            case UIImageOrientationLeft:
                imageViewRotationMode = kGPUImageRotateRight;
                break;
            case UIImageOrientationRight:
                imageViewRotationMode = kGPUImageRotateLeft;
                break;
            case UIImageOrientationDown:
                imageViewRotationMode = kGPUImageRotate180;
                break;
            case UIImageOrientationUp:
                imageViewRotationMode = kGPUImageNoRotation;
                break;
            default:
                imageViewRotationMode = kGPUImageRotateLeft;
        }

        
        if (buttonBlurNone.enabled && (pictureDOF != nil)) {            
            [filterDOF setInputRotation:imageViewRotationMode atIndex:1];
            [pictureDOF processImage];
            [pictureDOF addTarget:filterDOF atTextureLocation:1];
        }
        
        if (textText.text.length > 0) {
            [filterText setInputRotation:imageViewRotationMode atIndex:1];
            [pictureText processImage];
            [pictureText addTarget:filterText];
        }
        
        
        // seems like atIndex is ignored by GPUImageView...
        [viewCamera setInputRotation:imageViewRotationMode atIndex:0];
        
        // UI is more responsive with dispatch
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            [previewFilter processImage];
        });


    } else {
        GPUImageFilter *dummy = [[GPUImageFilter alloc] init];
        pipe.input = videoCamera;
        [pipe removeAllFilters];
        [pipe addFilter:dummy];
    }
    
    
}

-(UIImage *)imageFromText:(NSString *)text
{
    // set the font type and size
    UIFont *font = [UIFont fontWithName:currentFont size:currentFontSize];
    CGSize size  = [text sizeWithFont:font];
    
    // shadow
    size.height += 10;
    size.width += 10;
    
    // check if UIGraphicsBeginImageContextWithOptions is available (iOS is 4.0+)
    if (UIGraphicsBeginImageContextWithOptions != NULL)
        UIGraphicsBeginImageContextWithOptions(size,NO,0.0);
    else
        // iOS is < 4.0
        UIGraphicsBeginImageContext(size);
    
    // optional: add a shadow, to avoid clipping the shadow you should make the context size bigger
    //
    // CGContextRef ctx = UIGraphicsGetCurrentContext();
    // CGContextSetShadowWithColor(ctx, CGSizeMake(1.0, 1.0), 5.0, [[UIColor grayColor] CGColor]);
    
    // draw in context, you can use also drawInRect:withFont:
    CGContextRef context = UIGraphicsGetCurrentContext();
    
	CGContextSetShadowWithColor(context, CGSizeMake(0, 1.0f), 1.0f, [UIColor blackColor].CGColor);
    
    CGContextSetRGBFillColor(context, 1.0, 1.0, 1.0, 1);
    [text drawAtPoint:CGPointMake(5.0, 5.0) withFont:font];
    
    // transfer image
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}


- (IBAction)setEffect:(id)sender {
    UIButton* buttonEffect = (UIButton*)sender;
    currentEffect = buttonEffect.tag;
    effect = [effectManager getEffect:currentEffect];
    [self applyCurrentFilters];
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
    imageOrientation = orientationLast;
    [videoCamera capturePhotoAsImageProcessedUpToFilter:pipe.filters[0]
                                        withOrientation:imageOrientation
                                  withCompletionHandler:^(UIImage *processedImage, NSError *error) {
                                      [locationManager stopUpdatingLocation];
                                      [videoCamera stopCameraCapture];
                                      imageMeta = [NSMutableDictionary dictionaryWithDictionary:videoCamera.currentCaptureMetadata];
                                      
                                      CGFloat scale = [[UIScreen mainScreen] scale];
                                      CGFloat width = 300.0;
                                      
                                      NSInteger height = [LXUtils heightFromWidth:width width:processedImage.size.width height:processedImage.size.height];
                                      
                                      picture = [[GPUImagePicture alloc] initWithImage:processedImage];
                                      
                                      CGSize size;
                                      
                                      if (imageOrientation == UIImageOrientationLeft || imageOrientation == UIImageOrientationRight) {
                                          size = CGSizeMake(height*scale, width*scale);
                                      }
                                      else {
                                          size = CGSizeMake(width*scale, height*scale);
                                      }
                                      picSize = processedImage.size;
                                      
                                      UIImage *previewPic = [processedImage
                                                             resizedImage: size
                                                             interpolationQuality:kCGInterpolationHigh];
                                      
                                      previewFilter = [[GPUImagePicture alloc] initWithImage:previewPic];
                                      
                                      [self switchEditImage];
                                      [self resizeCameraViewWithAnimation:NO];
                                      [self applyCurrentFilters];

                                  }];
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
        [videoCamera pauseCameraCapture];
        [videoCamera stopCameraCapture];
//        [filter clearTargetWithCamera:videoCamera andPicture:previewFilter];
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
        [self dismissViewControllerAnimated:NO completion:nil];
        LXAppDelegate* app = (LXAppDelegate*)[UIApplication sharedApplication].delegate;
        [app switchRoot];
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
    [self applyCurrentFilters];
}

- (IBAction)changeFlash:(id)sender {
    buttonFlash.selected = !buttonFlash.selected;
    [self setFlash:buttonFlash.selected];
}

- (IBAction)touchTimer:(id)sender {
    // wait for time before begin
    [viewTimer setHidden:!viewTimer.isHidden];
}

- (IBAction)touchSave:(id)sender {
    [self saveImage];
}

- (IBAction)toggleControl:(UIButton*)sender {
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
            break;
        case kTabBasic:
            buttonToggleFocus.selected = false;
            buttonToggleEffect.selected = false;
            buttonToggleLens.selected = false;
            buttonToggleText.selected = false;
            break;
        case kTabLens:
            buttonToggleFocus.selected = false;
            buttonToggleEffect.selected = false;
            buttonToggleBasic.selected = false;
            buttonToggleText.selected = false;
            break;
        case kTabText:
            buttonToggleFocus.selected = false;
            buttonToggleEffect.selected = false;
            buttonToggleBasic.selected = false;
            buttonToggleLens.selected = false;
            break;
        case kTabBokeh: {
            buttonToggleEffect.selected = false;
            buttonToggleBasic.selected = false;
            buttonToggleLens.selected = false;
            buttonToggleText.selected = false;
            
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
            break;
    }
    
    [self resizeCameraViewWithAnimation:YES];
    
    viewDraw.hidden = currentTab != kTabBokeh;
    tapDoubleEditText.enabled = buttonToggleText.selected;
        
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

    
    CGFloat posBottom;
    
    if (screen.size.height > 480) {
        posBottom = 568 - 50;
    }
    else {
        posBottom = 480 - 50;
    }
    
    frameEffect.origin.y = frameBokeh.origin.y = frameBasic.origin.y = frameLens.origin.y = frameText.origin.y =  posBottom;
    
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
            frameText.origin.y = posBottom - 140;
            break;
        case kTabTextEdit:
            frameText.origin.y = posBottom - keyboardSize.height + 20;
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
            if (currentTab == kTabText)
                height -= 140;
            else if (currentTab == kTabTextEdit) {
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
    
    CABasicAnimation *theAnimation = [CABasicAnimation animationWithKeyPath:@"shadowPath"];
    theAnimation.duration = 0.3;
    theAnimation.toValue = [UIBezierPath bezierPathWithRect:frame];
    [viewCameraWraper.layer addAnimation:theAnimation forKey:@"animateShadowPath"];
    
    [UIView animateWithDuration:animation?0.3:0 animations:^{
        viewFocusControl.frame = frameBokeh;
        viewEffectControl.frame = frameEffect;
        viewBasicControl.frame = frameBasic;
        viewLensControl.frame = frameLens;
        viewCameraWraper.frame = frame;
        viewTextControl.frame = frameText;
        viewTopBar.frame = frameTopBar;
        viewCanvas.frame = frameCanvas;
    } completion:^(BOOL finished) {
        
        
    }];
}

- (void)processSavedData {
    LXAppDelegate* app = (LXAppDelegate*)[UIApplication sharedApplication].delegate;
    if (app.currentUser != nil) {
        NSDictionary *info = [[NSDictionary alloc] initWithObjectsAndKeys:
                              savedData, @"data",
                              savedPreview, @"preview",
                              nil];
        if (delegate == nil) {
            [self performSegueWithIdentifier:@"Edit" sender:info];
        } else {
            [delegate imagePickerController:self didFinishPickingMediaWithData:info];
        }
        [HUD hide:YES];
    } else {
        [self switchCamera];
        HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Checkmark.png"]];
        HUD.mode = MBProgressHUDModeCustomView;
        [HUD hide:YES afterDelay:1];
    }
}

- (void)saveImage {
    if (isSaved) {
        [self processSavedData];
        return;
    }
        
    void (^saveImage)(ALAsset *, UIImage *) = ^(ALAsset *asset, UIImage *preview) {
        ALAssetRepresentation *rep = [asset defaultRepresentation];
        Byte *buffer = (Byte*)malloc(rep.size);
        NSUInteger buffered = [rep getBytes:buffer fromOffset:0.0 length:rep.size error:nil];
        savedData = [NSData dataWithBytesNoCopy:buffer length:buffered freeWhenDone:YES];
        savedPreview = preview;
        isSaved = true;
        
        [self processSavedData];
    };
    
    HUD.mode = MBProgressHUDModeIndeterminate;
    [HUD show:YES];
    [self applyCurrentFilters:YES];
    [picture processImage];
    [self saveImage:saveImage];
}

- (void)saveImage:(void(^)(ALAsset *asset, UIImage *preview))block {
    
    if (imageMeta == nil) {
        imageMeta = [[NSMutableDictionary alloc] init];
    }
    
    NSNumber *orientation = [NSNumber numberWithInteger:[self metadataOrientationForUIImageOrientation:imageOrientation]];
    
    [imageMeta setObject:orientation forKey:(NSString *)kCGImagePropertyOrientation];
    
    // Add GPS
    NSDictionary *location;
    if (bestEffortAtLocation != nil) {
        location = [LXUtils getGPSDictionaryForLocation:bestEffortAtLocation];
        [imageMeta setObject:location forKey:(NSString *)kCGImagePropertyGPSDictionary];
    }
    
    // Add App Info
    NSMutableDictionary *dictForTIFF = [imageMeta objectForKey:(NSString *)kCGImagePropertyTIFFDictionary];
    if (dictForTIFF == nil) {
        dictForTIFF = [[NSMutableDictionary alloc] init];
        [imageMeta setObject:dictForTIFF forKey:(NSString *)kCGImagePropertyTIFFDictionary];
    }
    
    [dictForTIFF setObject:@"Latte camera" forKey:(NSString *)kCGImagePropertyTIFFSoftware];
    
    [imageMeta setObject:dictForTIFF forKey:(NSString *)kCGImagePropertyTIFFDictionary];
    
    [pipe saveImageFromCurrentlyProcessedOutputWithMeta:imageMeta
                                         andOrientation:imageOrientation
                                             onComplete:^(NSURL *assetURL, NSError *error, UIImage *preview) {
                                                 ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
                                                 [library assetForURL:assetURL
                                                          resultBlock:^(ALAsset *asset) {
                                                              block(asset, preview);
                                                          }
                                                         failureBlock:nil];
                                             }];
}

- (int) metadataOrientationForUIImageOrientation:(UIImageOrientation)orientation
{
	switch (orientation) {
		case UIImageOrientationUp: // the picture was taken with the home button is placed right
			return 1;
		case UIImageOrientationRight: // bottom (portrait)
			return 6;
		case UIImageOrientationDown: // left
			return 3;
		case UIImageOrientationLeft: // top
			return 8;
		default:
			return 1;
	}
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [locationManager stopUpdatingLocation];
    
    ALAssetsLibraryAssetForURLResultBlock resultblock = ^(ALAsset *myasset)
    {
        ALAssetRepresentation *rep = [myasset defaultRepresentation];
        bestEffortAtLocation = nil;
        imageMeta = [NSMutableDictionary dictionaryWithDictionary:myasset.defaultRepresentation.metadata];
    
        UIImage *tmp = [info objectForKey:UIImagePickerControllerOriginalImage];
        picture = [[GPUImagePicture alloc] initWithCGImage:rep.fullResolutionImage];
        imageOrientation = tmp.imageOrientation;
        
        [imagePicker dismissViewControllerAnimated:NO completion:nil];
        
        CGFloat scale = [[UIScreen mainScreen] scale];
        
        NSInteger height = [LXUtils heightFromWidth:300.0 width:tmp.size.width height:tmp.size.height];
        picSize = tmp.size;
        
        //
        CGSize size;
        
        if (imageOrientation == UIImageOrientationLeft || imageOrientation == UIImageOrientationRight) {
            size = CGSizeMake(height*scale, 300.0*scale);
        }
        else {
            size = CGSizeMake(300.0*scale, height*scale);
        }
        
        UIImage *previewPic = [tmp
                               resizedImage: size
                               interpolationQuality:kCGInterpolationHigh];
        
        previewFilter = [[GPUImagePicture alloc] initWithImage:previewPic];

        [self switchEditImage];
        [self resizeCameraViewWithAnimation:NO];
        [self applyCurrentFilters];
    };
    
    //
    ALAssetsLibraryAccessFailureBlock failureblock  = ^(NSError *myerror)
    {
        TFLog(@"booya, cant get image - %@",[myerror localizedDescription]);
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
    savedData = nil;
    savedPreview = nil;
    // Clear memory/blur mode
    picture = nil;
    previewFilter = nil;
    
    // Set to normal lens
    currentLens = 0;
    currentTab = kTabPreview;
    viewDraw.hidden = true;
    viewDraw.isEmpty = true;
    
    buttonBlurNone.enabled = false;
    
    [locationManager startUpdatingLocation];
    [videoCamera resumeCameraCapture];
    [videoCamera startCameraCapture];

    buttonNo.hidden = YES;
    buttonYes.hidden = YES;
    buttonCapture.hidden = NO;
    buttonFlash.hidden = NO;
    buttonTimer.hidden = NO;
    buttonFlip.hidden = NO;
    imageAutoFocus.hidden = NO;
    buttonReset.hidden = YES;
    
    buttonPick.hidden = NO;
    tapFocus.enabled = true;
    
    scrollEffect.hidden = false;
    buttonPick.hidden = NO;
    
    buttonToggleEffect.hidden = YES;
    buttonToggleFocus.hidden = YES;
    buttonToggleBasic.hidden = YES;
    buttonToggleLens.hidden = YES;
    buttonToggleText.hidden = YES;
    
    buttonClose.hidden = NO;
    isEditing = NO;
    
    [self resizeCameraViewWithAnimation:NO];
    [self applyCurrentFilters];
}

- (void)switchEditImage {
    // Reset to normal lens
    currentFont = @"Arial";
    posText = CGPointMake(0.1, 0.5);
    currentFontSize = 50.0;
    textText.text = @"";

    currentLens = 0;
    
    isEditing = YES;
    buttonCapture.hidden = YES;
    buttonNo.hidden = NO;
    buttonYes.hidden = NO;
    buttonFlash.hidden = YES;
    buttonTimer.hidden = YES;
    buttonFlip.hidden = YES;
    buttonPick.hidden = YES;
    
    buttonToggleFocus.hidden = NO;
    buttonToggleBasic.hidden = NO;
    buttonToggleLens.hidden = NO;
    buttonToggleText.hidden = NO;
    buttonToggleEffect.hidden = NO;
    
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
    buttonToggleEffect.selected = false;
    buttonToggleLens.selected = false;
    buttonToggleText.selected = false;
    
    buttonReset.hidden = false;
    currentTab = kTabPreview;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(NSDictionary *)info {
    if ([segue.identifier isEqualToString:@"Edit"]) {
        LXPicEditViewController *controllerPicEdit = segue.destinationViewController;
        [controllerPicEdit setData:[info objectForKey:@"data"]];
        [controllerPicEdit setPreview:[info objectForKey:@"preview"]];
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
    sliderExposure.value = 0.0;
    sliderClear.value = 0.0;
    sliderSaturation.value = 1.0;
    sliderSharpness.value = 0.0;
    sliderVignette.value = 0.0;
    effect = nil;
    [self applyCurrentFilters];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (alertView.tag) {
        case 1: //Touch No
            if (buttonIndex == 1)
                [self switchCamera];
            break;
        case 2:
            if (buttonIndex == 1) {
                [self dismissViewControllerAnimated:NO completion:nil];
                LXAppDelegate* app = (LXAppDelegate*)[UIApplication sharedApplication].delegate;
                [app switchRoot];
            }
            break;
        default:
            break;
    }
}


- (IBAction)flipCamera:(id)sender {
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
    [self applyCurrentFilters];
}

- (IBAction)toggleMaskNatual:(UISwitch*)sender {
    if (sender.on) {
        viewDraw.backgroundType = kBackgroundNatual;
    } else {
        viewDraw.backgroundType = kBackgroundNone;
    }
}

- (IBAction)touchCloseHelp:(id)sender {
    [UIView animateWithDuration:0.3 animations:^{
        viewHelp.alpha = 0.0;
    } completion:^(BOOL finished) {
        viewHelp.hidden = true;
        tapCloseHelp.enabled = false;
    }];

}

- (IBAction)touchOpenHelp:(id)sender {
    viewHelp.hidden = false;
    [UIView animateWithDuration:0.3 animations:^{
        viewHelp.alpha = 1.0;
    } completion:^(BOOL finished) {
        tapCloseHelp.enabled = true;
    }];
}

- (IBAction)toggleGain:(UISwitch*)sender {
    [self applyCurrentFilters];
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
//            filter.maxblur = 5.0;
            buttonBlurWeak.enabled = false;
            break;
        case kMaskBlurNormal:
            buttonBlurNormal.enabled = false;
//            filter.maxblur = 7.0;
            break;
        case kMaskBlurStrong:
//            filter.maxblur = 15.0;
            buttonBlurStrong.enabled = false;
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
    [self applyCurrentFilters];
}

- (IBAction)textChange:(UITextField *)sender {
    [self newText];
}

- (IBAction)doubleTapEdit:(UITapGestureRecognizer *)sender {
}

- (IBAction)pinchCamera:(UIPinchGestureRecognizer *)sender {
    static CGFloat mCurrentScale;
    static CGFloat mLastScale;
    mCurrentScale += [sender scale] - mLastScale;
    mLastScale = [sender scale];
    
    if (sender.state == UIGestureRecognizerStateEnded)
    {
        mLastScale = 1.0;
    }
    currentFontSize = mCurrentScale * 100.0;
    [self newText];
}

- (IBAction)panCamera:(UIPanGestureRecognizer *)sender {
    CGPoint translation = [sender translationInView:viewCamera];

    posText.x += translation.x/viewCamera.frame.size.width;
    posText.y += translation.y/viewCamera.frame.size.height;
    
    filterText.position = posText;
    //[filterText disableFirstFrameCheck];
    //[pictureText processImage];
    [self applyCurrentFilters];
    
    [sender setTranslation:CGPointMake(0, 0) inView:viewCamera];
}

- (void)newText {
    if (textText.text.length > 0) {
        UIImage *imageText = [self imageFromText:textText.text];
        pictureText = [[GPUImagePicture alloc] initWithImage:imageText];
        filterText.aspect = CGPointMake(picSize.width/imageText.size.width, picSize.height/imageText.size.height);
    }
    [self applyCurrentFilters];
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
+(NSString*)orientationToText:(const UIImageOrientation)ORIENTATION {
    switch (ORIENTATION) {
        case UIImageOrientationUp:
            return @"UIImageOrientationUp";
        case UIImageOrientationDown:
            return @"UIImageOrientationDown";
        case UIImageOrientationLeft:
            return @"UIImageOrientationLeft";
        case UIImageOrientationRight:
            return @"UIImageOrientationRight";
        default:
            return @"Unknown orientation!";
    }
}
#endif

#pragma mark UIAccelerometerDelegate
-(void)accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration {
    UIImageOrientation orientationNew;
    if (acceleration.x >= 0.75) {
        orientationNew = UIImageOrientationRight;
    }
    else if (acceleration.x <= -0.75) {
        orientationNew = UIImageOrientationLeft;
    }
    else if (acceleration.y <= -0.75) {
        orientationNew = UIImageOrientationUp;
    }
    else if (acceleration.y >= 0.75) {
        orientationNew = UIImageOrientationDown;
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
    pictureDOF = [[GPUImagePicture alloc] initWithImage:mask];
    if (!buttonBlurNone.enabled) {
        [self setMask:buttonBlurNormal];
    }
    else
        [self applyCurrentFilters];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}
@end
