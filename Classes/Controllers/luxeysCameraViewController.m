//
//  luxeysCameraViewController.m
//  Latte
//
//  Created by Xuan Dung Bui on 7/20/12.
//  Copyright (c) 2012 LUXEYS. All rights reserved.
//

#import "luxeysCameraViewController.h"
#import "luxeysAppDelegate.h"

#define kAccelerometerFrequency        10.0 //Hz

@interface luxeysCameraViewController ()

@end

@implementation luxeysCameraViewController

@synthesize scrollEffect;
@synthesize cameraView;
@synthesize viewTimer;
@synthesize imageBottom;
@synthesize buttonCapture;
@synthesize buttonYes;
@synthesize buttonNo;
@synthesize buttonTimer;
@synthesize buttonFlash;
@synthesize buttonFlip;
@synthesize buttonCrop;
@synthesize gesturePan;
@synthesize viewBottomBar;
@synthesize imageAutoFocus;
@synthesize buttonPick;
@synthesize buttonScroll;
@synthesize delegate;
@synthesize buttonSetNoTimer;
@synthesize buttonSetTimer5s;
@synthesize scrollCamera;
@synthesize tapFocus;
@synthesize viewFocusControl;
@synthesize buttonToggleFocus;
@synthesize buttonChangeLens;
@synthesize viewCameraWraper;
@synthesize viewDraw;
@synthesize buttonBackgroundNatual;
@synthesize buttonBlurNone;
@synthesize buttonBlurNormal;
@synthesize buttonBlurStrong;
@synthesize buttonBlurWeak;
@synthesize viewHelp;
@synthesize viewPopupHelp;

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
    viewPopupHelp.layer.cornerRadius = 10.0;
    viewPopupHelp.layer.borderWidth = 1.0;
    viewPopupHelp.layer.borderColor = [[UIColor colorWithWhite:1.0 alpha:0.25] CGColor];
    
    isSaved = true;
    viewDraw.delegate = self;
    viewDraw.lineWidth = 10.0;
    currentTab = kTabEffect;
    
    filter = [[FilterManager alloc] init];
    HUD = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:HUD];
    HUD.mode = MBProgressHUDModeIndeterminate;
    
	// Do any additional setup after loading the view.
    UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:imageBottom.bounds];
	imageBottom.layer.masksToBounds = NO;
	imageBottom.layer.shadowColor = [UIColor blackColor].CGColor;
	imageBottom.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
	imageBottom.layer.shadowOpacity = 1.0f;
	imageBottom.layer.shadowRadius = 2.5f;
	imageBottom.layer.shadowPath = shadowPath.CGPath;
    
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
    
    currentEffect = 0;
    currentLens = 0;
    currentTimer = kTimerNone;
    
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
    
    [self resizeCameraViewWithAnimation:NO];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        [videoCamera startCameraCapture];
        [self applyCurrentEffect];
    });
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
    [videoCamera pauseCameraCapture];
    [videoCamera stopCameraCapture];
    
    UIAccelerometer* a = [UIAccelerometer sharedAccelerometer];
    a.delegate = nil;
    [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
    
    [super viewWillDisappear:animated];
}

- (void)viewDidUnload {
    [self setCameraView:nil];
    [self setScrollEffect:nil];
    [self setImageAutoFocus:nil];
    [self setImageBottom:nil];
    [self setViewTimer:nil];
    
    videoCamera = nil;
    filter = nil;
    
    [self setButtonSetNoTimer:nil];
    [self setButtonSetTimer5s:nil];
    [self setScrollCamera:nil];
    [self setTapFocus:nil];
    [self setViewFocusControl:nil];
    [self setButtonToggleFocus:nil];
    [self setViewCameraWraper:nil];
    [self setViewDraw:nil];
    [self setButtonChangeLens:nil];
    [self setButtonBackgroundNatual:nil];
    [self setButtonBlurWeak:nil];
    [self setButtonBlurNormal:nil];
    [self setButtonBlurStrong:nil];
    [self setButtonBlurNone:nil];
    [self setViewHelp:nil];
    [self setViewPopupHelp:nil];
    [super viewDidUnload];
}

- (void)showStillImage {
    
    GPUImageRotationMode imageViewRotationMode = kGPUImageNoRotation;
    switch (imageOrientation) {
        case UIImageOrientationLeft:
            imageViewRotationMode = kGPUImageRotateLeft;
            break;
        case UIImageOrientationRight:
            imageViewRotationMode = kGPUImageRotateRight;
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
    
    // seems like atIndex is ignored by GPUImageView...
    [cameraView setInputRotation:imageViewRotationMode atIndex:0];
    
    [previewFilter processImage];
}


- (void)applyCurrentEffect {

        if (isEditing) {
            isSaved = false;
            savedData = nil;
            savedPreview = nil;
            
            filter.isDOF = (buttonBlurNone.enabled) && (!viewDraw.isEmpty);
            [filter changeFiltertoLens:currentLens andEffect:currentEffect input:previewFilter output:cameraView isPicture:YES];
            [self showStillImage];
        } else {
            filter.isDOF = false;
            [filter changeFiltertoLens:currentLens andEffect:currentEffect input:videoCamera output:cameraView isPicture:false];
        }
//    });
}


- (IBAction)setEffect:(id)sender {
    UIButton* buttonEffect = (UIButton*)sender;
    currentEffect = buttonEffect.tag;
    [self applyCurrentEffect];
}


- (void)updateTargetPoint {
    CGPoint point = CGPointMake(imageAutoFocus.center.x/cameraView.frame.size.width, imageAutoFocus.center.y/cameraView.frame.size.height);
    
    
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
    [videoCamera capturePhotoAsImageProcessedUpToFilterWithMeta:[filter getDummy]
                                          withCompletionHandler:^(UIImage *processedImage, NSMutableDictionary *meta, NSError *error) {
                                              [locationManager stopUpdatingLocation];
                                              [videoCamera stopCameraCapture];
                                              
                                              imageMeta = meta;

                                              CGFloat scale = [[UIScreen mainScreen] scale];
                                              CGFloat width = 320.0;

                                              NSInteger height = [luxeysUtils heightFromWidth:width width:processedImage.size.width height:processedImage.size.height];
                                                                                            
                                              filter.frameSize = processedImage.size;
                                              filter.dofOrientation = imageOrientation;
                                              picture = [[GPUImagePicture alloc] initWithImage:processedImage];
                                              
                                              CGSize size;
                                              CGRect screen = [[UIScreen mainScreen] bounds];
                                              
                                              if (imageOrientation == UIImageOrientationLeft || imageOrientation == UIImageOrientationRight) {
                                                  viewCameraWraper.frame = CGRectMake(0, 0, 320, 240);
                                              }
                                              else {
                                                  viewCameraWraper.frame = CGRectMake(0, 0, 320, 425);
                                              }
                                              [self resizeCameraViewWithAnimation:NO];
                                              
                                              if (screen.size.height == 480) {
                                                  size = CGSizeMake(width*scale, height*scale);
                                              }
                                              else {
                                                  
                                                  size = CGSizeMake(width*scale, height*scale);
                                              }
                                              
                                              
                                              UIImage *previewPic = [processedImage
                                                                     resizedImage: size
                                                                     interpolationQuality:kCGInterpolationHigh];
                                              
                                              previewFilter = [[GPUImagePicture alloc] initWithImage:previewPic];
                                              
                                              [self switchEditImage];
                                              [self applyCurrentEffect];
    }];
}

- (IBAction)cameraTouch:(UITapGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateRecognized) {
        CGPoint location = [sender locationInView:self.cameraView];

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
        [filter clearTargetWithCamera:videoCamera andPicture:previewFilter];
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
        luxeysAppDelegate* app = (luxeysAppDelegate*)[UIApplication sharedApplication].delegate;
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

- (IBAction)changeLens:(id)sender {
    sheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"change_lens", @"レンズ交換")
                                        delegate:self
                               cancelButtonTitle:NSLocalizedString(@"cancel", @"キャンセル")
                          destructiveButtonTitle:nil
                               otherButtonTitles:NSLocalizedString(@"lens_normal", @"普通"), NSLocalizedString(@"lens_wide", @"ワイド"), NSLocalizedString(@"lens_fisheye", @"魚眼レンズ"), nil];
    [sheet setTag:0];
    sheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
    [sheet showInView:self.view];
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

- (IBAction)toggleEffect:(UIButton*)sender {
    switch (sender.tag) {
        case 1:
            if (currentTab == kTabEffect)
                currentTab = kTabPreview;
            else
                currentTab = kTabEffect;
            break;
        case 2:
            if (currentTab == kTabBokeh)
                currentTab = kTabPreview;
            else
                currentTab = kTabBokeh;
            break;
        default:
            currentTab = kTabPreview;
            break;
    }

    switch (currentTab) {
        case kTabEffect:
            buttonScroll.selected = true;
            buttonToggleFocus.selected = false;
            break;
        case kTabPreview:
            buttonScroll.selected = false;
            buttonToggleFocus.selected = false;
            break;
        case kTabBokeh:
            buttonScroll.selected = false;
            buttonToggleFocus.selected = true;
            
            // Firsttime
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            if (![defaults objectForKey:@"firstRunBokeh"]) {
                [defaults setObject:[NSDate date] forKey:@"firstRunBokeh"];
                [self touchOpenHelp:nil];
            }

            break;
    }
    
    scrollCamera.scrollEnabled = true;
    [self resizeCameraViewWithAnimation:YES];
    
    viewDraw.hidden = currentTab != kTabBokeh;
    scrollCamera.scrollEnabled = (currentTab != kTabBokeh) && isEditing;
        
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)resizeCameraViewWithAnimation:(BOOL)animation {
    scrollCamera.zoomScale = 1.0;
    CGRect screen = [[UIScreen mainScreen] bounds];

    CGRect frame = scrollCamera.frame;
    CGRect frame2 = viewCameraWraper.frame;
    CGRect frameEffect = scrollEffect.frame;
    CGRect frameBokeh = viewFocusControl.frame;
    
    if (screen.size.height > 480) {
        switch (currentTab) {
            case kTabBokeh:
                frame.size.height = 568 - 40 - 50 - 110;
                frameEffect.origin.y = 568 - 50;
                frameBokeh.origin.y = 568 - 50 - 110;
                break;
            case kTabEffect:
                frame.size.height = 568 - 40 - 50 - 72;
                frameEffect.origin.y = 568 - 50 - 72;
                frameBokeh.origin.y = 568 - 50;
                break;
            case kTabPreview:
                frame.size.height = 568 - 40 - 50;
                frameEffect.origin.y = 568 - 50;
                frameBokeh.origin.y = 568 - 50;
                break;
                
            default:
                break;
        }            
    } else {
        switch (currentTab) {
            case kTabBokeh:
                frame.size.height = 480 - 40 - 50 - 110;
                frameEffect.origin.y = 480 - 50;
                frameBokeh.origin.y = 480 - 50 - 110;
                break;
            case kTabEffect:
                frame.size.height = 480 - 40 - 50;
                frameEffect.origin.y = 480 - 50 - 72;
                frameBokeh.origin.y = 480 - 50;
                break;
            case kTabPreview:
                frame.size.height = 480 - 40 - 50;
                frameEffect.origin.y = 480 - 50;
                frameBokeh.origin.y = 480 - 50;
                break;
                
            default:
                break;
        }
    }

    CGFloat horizontalRatio = frame.size.width / frame2.size.width;
    CGFloat verticalRatio = frame.size.height / frame2.size.height;
    CGFloat ratio;
    ratio = MIN(horizontalRatio, verticalRatio);
    
    frame2.size = CGSizeMake(frame2.size.width*ratio, frame2.size.height*ratio);
    frame2.origin.x = (frame.size.width - frame2.size.width)/2;
    frame2.origin.y = (frame.size.height - frame2.size.height)/2;
    
    if (animation) {
        [UIView animateWithDuration:animation?0.3:0 animations:^{
            viewFocusControl.frame = frameBokeh;
            scrollEffect.frame = frameEffect;
        }];
    } else {
        viewFocusControl.frame = frameBokeh;
        scrollEffect.frame = frameEffect;
        
    }
    scrollCamera.frame = frame;
    scrollCamera.zoomScale = ratio;
    [self scrollViewDidZoom:scrollCamera];
}

- (void)processSavedData {
    luxeysAppDelegate* app = (luxeysAppDelegate*)[UIApplication sharedApplication].delegate;
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
    } else {
        [self switchCamera];
    }
}

- (void)saveImage {
    if (isSaved) {
        [self processSavedData];
        return;
    }
    
    NSDictionary *location;
    if (bestEffortAtLocation != nil) {
        location = [luxeysUtils getGPSDictionaryForLocation:bestEffortAtLocation];
        [imageMeta setObject:location forKey:(NSString *)kCGImagePropertyGPSDictionary];
    }
    
    void (^saveImage)(ALAsset *, UIImage *) = ^(ALAsset *asset, UIImage *preview) {
        ALAssetRepresentation *rep = [asset defaultRepresentation];
        Byte *buffer = (Byte*)malloc(rep.size);
        NSUInteger buffered = [rep getBytes:buffer fromOffset:0.0 length:rep.size error:nil];
        savedData = [NSData dataWithBytesNoCopy:buffer length:buffered freeWhenDone:YES];
        savedPreview = preview;
        isSaved = true;
        
        [self processSavedData];
        [HUD hide:YES];
    };
    
    [HUD show:YES];
    [filter changeFiltertoLens:currentLens andEffect:currentEffect input:picture output:nil isPicture:YES];
    [picture processImage];
    [filter saveImage:location orientation:imageOrientation withMeta:imageMeta onComplete:saveImage];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 3) { // Cancel
        return;
    }

    currentLens = buttonIndex;
    [self applyCurrentEffect];
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
        filter.dofOrientation = imageOrientation;
        
        [imagePicker dismissViewControllerAnimated:NO completion:nil];
        
        CGFloat scale = [[UIScreen mainScreen] scale];
        
        NSInteger height = [luxeysUtils heightFromWidth:320.0 width:tmp.size.width height:tmp.size.height];
        
        CGRect frame = scrollCamera.frame;
        
        CGFloat horizontalRatio = frame.size.width / 320.0;
        CGFloat verticalRatio = frame.size.height / height;
        CGFloat ratio;
        ratio = MIN(horizontalRatio, verticalRatio);
        
        CGRect frame2;
        frame2.size = CGSizeMake(320.0*ratio, height*ratio);
        frame2.origin.x = (frame.size.width - frame2.size.width)/2;
        frame2.origin.y = (frame.size.height - frame2.size.height)/2;
        
        viewCameraWraper.frame = frame2;
        [self resizeCameraViewWithAnimation:NO];
        
        //
        CGSize size;
                    CGRect screen = [[UIScreen mainScreen] bounds];
        
        if (imageOrientation == UIImageOrientationLeft || imageOrientation == UIImageOrientationRight) {

            
            if (screen.size.height == 480)
                size = CGSizeMake(height, 320.0);
            else
                size = CGSizeMake(height*scale, 320.0*scale);
            filter.frameSize = CGSizeMake(tmp.size.height*tmp.scale, tmp.size.width*tmp.scale);
        }
        else {
            if (screen.size.height == 480)
                size = CGSizeMake(320.0, height);
            else
                size = CGSizeMake(320.0*scale, height*scale);
            filter.frameSize = CGSizeMake(tmp.size.width*tmp.scale, tmp.size.height*tmp.scale);
        }
        
        UIImage *previewPic = [tmp
                               resizedImage: size
                               interpolationQuality:kCGInterpolationHigh];
        
        previewFilter = [[GPUImagePicture alloc] initWithImage:previewPic];

        [self switchEditImage];
        [self applyCurrentEffect];
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
    currentTab = kTabEffect;
    viewDraw.hidden = true;
    viewDraw.isEmpty = true;
    
    // Zoom to normal size
    scrollCamera.zoomScale = 1.0;
    
    viewCameraWraper.frame = CGRectMake(0, 0, 320, 425);
    scrollCamera.contentSize = viewCameraWraper.frame.size;
    
    buttonBlurNone.enabled = false;
    [self resizeCameraViewWithAnimation:YES];
    
    [locationManager startUpdatingLocation];
    [videoCamera resumeCameraCapture];
    [videoCamera startCameraCapture];

    // [cameraView setInputRotation:kGPUImageNoRotation atIndex:0];
    
    buttonNo.hidden = YES;
    buttonYes.hidden = YES;
    buttonCapture.hidden = NO;
    buttonFlash.hidden = NO;
    buttonTimer.hidden = NO;
    buttonFlip.hidden = NO;
    buttonCrop.hidden = NO;
    imageAutoFocus.hidden = NO;
    buttonPick.hidden = NO;
    tapFocus.enabled = true;
    buttonChangeLens.hidden = YES;
    
    scrollEffect.hidden = false;
    buttonScroll.selected = YES;
    buttonPick.hidden = NO;
    buttonToggleFocus.hidden = YES;
    gesturePan.enabled = true;
    scrollCamera.scrollEnabled = NO;
    isEditing = NO;
    [self applyCurrentEffect];
}

- (void)switchEditImage {
    // Reset to normal lens
    currentLens = 0;
    
    scrollCamera.scrollEnabled = YES;
    isEditing = YES;
    buttonCapture.hidden = YES;
    buttonNo.hidden = NO;
    buttonYes.hidden = NO;
    buttonFlash.hidden = YES;
    buttonTimer.hidden = YES;
    buttonFlip.hidden = YES;
    buttonCrop.hidden = YES;
    buttonChangeLens.hidden = NO;
    buttonPick.hidden = YES;
    buttonToggleFocus.hidden = NO;

    imageAutoFocus.hidden = YES;
    viewTimer.hidden = YES;
    tapFocus.enabled = false;
    gesturePan.enabled = true;
    isSaved = FALSE;
    
    // Clear depth mask
    [viewDraw.drawImageView setImage:nil];
    viewDraw.currentColor = [UIColor redColor];
    viewDraw.isEmpty = YES;

    // Default Brush
    [self setUIMask:kMaskBlurNone];

    buttonToggleFocus.selected = false;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(NSDictionary *)info {
    if ([segue.identifier isEqualToString:@"Edit"]) {
        luxeysPicEditViewController *controllerPicEdit = segue.destinationViewController;
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

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (alertView.tag) {
        case 1: //Touch No
            if (buttonIndex == 1)
                [self switchCamera];
            break;
        case 2:
            if (buttonIndex == 1) {
                [self dismissViewControllerAnimated:NO completion:nil];
                luxeysAppDelegate* app = (luxeysAppDelegate*)[UIApplication sharedApplication].delegate;
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
    CGPoint translation = [sender translationInView:cameraView];
    CGPoint center = CGPointMake(sender.view.center.x + translation.x,
                                         sender.view.center.y + translation.y);
    center.x = center.x<0?0:(center.x>320?320:center.x);
    center.y = center.y<0?0:(center.y>cameraView.frame.size.height?cameraView.frame.size.height:center.y);
    sender.view.center = center;
    [sender setTranslation:CGPointMake(0, 0) inView:cameraView];
    
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
    [self applyCurrentEffect];
}

- (IBAction)toggleMaskNatual:(UIButton*)sender {
    sender.selected = !sender.selected;
    if (sender.selected) {
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
    }];

}

- (IBAction)touchOpenHelp:(id)sender {
    viewHelp.hidden = false;
    [UIView animateWithDuration:0.3 animations:^{
        viewHelp.alpha = 1.0;
    }];
}

- (IBAction)toggleGain:(UIButton*)sender {
    sender.selected = !sender.selected;
    if (sender.selected)
        filter.gain = 5.0;
    else
        filter.gain = 1.0;
    [self applyCurrentEffect];
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
            filter.maxblur = 5.0;
            buttonBlurWeak.enabled = false;
            break;
        case kMaskBlurNormal:
            buttonBlurNormal.enabled = false;
            filter.maxblur = 7.0;
            break;
        case kMaskBlurStrong:
            filter.maxblur = 15.0;
            buttonBlurStrong.enabled = false;
            break;
        default:
            break;
    }
}

- (IBAction)changeBlur:(UISlider*)sender {
    filter.maxblur = sender.value;
    [self applyCurrentEffect];
}

- (IBAction)changeHighlight:(UISlider*)sender {
    filter.gain = sender.value;
    [self applyCurrentEffect];
}

- (IBAction)changePen:(UISlider *)sender {
    viewDraw.lineWidth = sender.value;
    [viewDraw redraw];
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

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    if (scrollView.scrollEnabled)
        return viewCameraWraper;
    else
        return nil;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    UIView *subView = [scrollView.subviews objectAtIndex:0];
    
    CGFloat offsetX = (scrollView.bounds.size.width > scrollView.contentSize.width)?
    (scrollView.bounds.size.width - scrollView.contentSize.width) * 0.5 : 0.0;
    
    CGFloat offsetY = (scrollView.bounds.size.height > scrollView.contentSize.height)?
    (scrollView.bounds.size.height - scrollView.contentSize.height) * 0.5 : 0.0;
    

        subView.center = CGPointMake(scrollView.contentSize.width * 0.5 + offsetX,
                                     scrollView.contentSize.height * 0.5 + offsetY);
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
    filter.dof = mask;
    if (!buttonBlurNone.enabled) {
        [self setMask:buttonBlurNormal];
    }
    [self applyCurrentEffect];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}
@end
