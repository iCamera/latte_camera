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
@synthesize viewBlur;
@synthesize viewMask;
@synthesize viewFocal;
@synthesize buttonBackground;
@synthesize buttonFocal;
@synthesize buttonMove;
@synthesize buttonPaintMask;

@synthesize imageMaskCircle;
@synthesize imageMaskRect;

@synthesize buttonBackgroundRound;
@synthesize buttonBackgroundNatual;
@synthesize buttonBackgroundNone;

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
        isCrop = true;
        isReady = false;
        isFinishedProcessing = true;
        
        viewDraw.isEmpty = YES;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    isSaved = true;
    viewDraw.delegate = self;
    viewDraw.lineWidth = 10.0;
    [self setupCameraAspect];
    
    filter = [[FilterManager alloc] init];
    
	// Do any additional setup after loading the view.
    UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:imageBottom.bounds];
	imageBottom.layer.masksToBounds = NO;
	imageBottom.layer.shadowColor = [UIColor blackColor].CGColor;
	imageBottom.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
	imageBottom.layer.shadowOpacity = 1.0f;
	imageBottom.layer.shadowRadius = 2.5f;
	imageBottom.layer.shadowPath = shadowPath.CGPath;
    
    scrollCamera.maximumZoomScale=6.0;
    scrollCamera.minimumZoomScale=0.5;
    
    videoCamera = [[GPUImageStillCamera alloc] initWithSessionPreset:AVCaptureSessionPresetPhoto cameraPosition:AVCaptureDevicePositionBack];
    [videoCamera setOutputImageOrientation:UIInterfaceOrientationPortrait];
    
    imagePicker = [[UIImagePickerController alloc]init];
    [imagePicker.navigationBar setBackgroundImage:[UIImage imageNamed: @"bg_head.png"] forBarMetrics:UIBarMetricsDefault];
    imagePicker.delegate = (id)self;
    
    CGRect screen = [[UIScreen mainScreen] bounds];

    if (screen.size.height == 480) { // Tranditional iPhone
        CGRect frame = scrollCamera.frame;
        frame.size.height = 390.0;
        scrollCamera.frame = frame;
        buttonScroll.selected = false;
        scrollEffect.hidden = true;
        viewCameraWraper.frame = CGRectMake(14, 0, 292, 390);
    }
    else
        viewCameraWraper.frame = CGRectMake(3.5, 0, 313.5, 418);

    [self resizeCameraViewWithAnimation:NO];
    
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
        UILabel *labelEffect = [[UILabel alloc] initWithFrame:CGRectMake(9+55*i, 9, 20, 10)];
        labelEffect.backgroundColor = [UIColor clearColor];
        labelEffect.textColor = [UIColor whiteColor];
        labelEffect.font = [UIFont systemFontOfSize:9];
        UIButton *buttonEffect = [[UIButton alloc] initWithFrame:CGRectMake(5+55*i, 5, 50, 50)];
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
        labelEffect.text = [NSString stringWithFormat:@"%d", i+1];
        [scrollEffect addSubview:buttonEffect];
        [scrollEffect addSubview:labelEffect];
    }
    scrollEffect.contentSize = CGSizeMake(16*55+10, 60);
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        [videoCamera startCameraCapture];
        [self applyCurrentEffect];
    });
    
//    [self.view addSubview:[[LXDrawView alloc] initWithFrame:self.view.bounds]];
}

- (void)viewDidAppear:(BOOL)animated {    
    [super viewDidAppear:animated];
    
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    UIAccelerometer* a = [UIAccelerometer sharedAccelerometer];
    a.updateInterval = 1 / kAccelerometerFrequency;
    a.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated {
    self.navigationController.navigationBarHidden = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
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
    [self setViewMask:nil];
    [self setViewBlur:nil];
    [self setViewFocal:nil];
    [self setButtonMove:nil];
    [self setButtonPaintMask:nil];
    [self setButtonFocal:nil];
    [self setButtonBackground:nil];
    [self setButtonBackgroundRound:nil];
    [self setButtonBackgroundNatual:nil];
    [self setButtonBackgroundNone:nil];
    [self setImageMaskRect:nil];
    [self setImageMaskCircle:nil];
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
            filter.isDOF = (bokehMode == kBokehModeFull) && (!viewDraw.isEmpty);

            [filter changeFiltertoLens:currentLens andEffect:currentEffect input:previewFilter output:cameraView isPicture:true];
            [self showStillImage];
//            [previewFilter processImage];
        } else {
            filter.isDOF = false;
            [filter changeFiltertoLens:currentLens andEffect:currentEffect input:videoCamera output:cameraView isPicture:false];
        }
}


- (IBAction)setEffect:(id)sender {
    UIButton* buttonEffect = (UIButton*)sender;
    currentEffect = buttonEffect.tag;
    [self applyCurrentEffect];
}


- (void)updateTargetPoint {
    CGPoint point = CGPointMake(imageAutoFocus.center.x/cameraView.frame.size.width, imageAutoFocus.center.y/cameraView.frame.size.height);
    
    if (isEditing) {
        switch (imageOrientation) {
            case UIImageOrientationUp:
                filter.focus = point;
                break;
            case UIImageOrientationLeft:
                filter.focus = CGPointMake(1.0-point.y, point.x);
                break;
            case UIImageOrientationRight:
                filter.focus = CGPointMake(point.y, 1.0-point.x);
                break;
            case UIImageOrientationDown:
                filter.focus = CGPointMake(1.0-point.x, 1.0-point.y);
                break;
            default:
                filter.focus = point;
                break;
        }
        
        [self applyCurrentEffect];
    } else {
        [self setFocusPoint:point];
        [self setMetteringPoint:point];

        [UIView animateWithDuration:0.3
                          delay:1.5
                        options:UIViewAnimationOptionShowHideTransitionViews
                     animations:^{
                         imageAutoFocus.alpha = 0;
                     } completion:^(BOOL finished) {
                         if (finished) {
                             imageAutoFocus.hidden = true;
                         }
                     }];
    }
}

- (void)capturePhotoAsync {
    [videoCamera capturePhotoAsImageProcessedUpToFilterWithMeta:[filter getCrop]
                                          withCompletionHandler:^(UIImage *processedImage, NSMutableDictionary *meta, NSError *error) {
                                              [locationManager stopUpdatingLocation];
                                              [videoCamera stopCameraCapture];
                                              
                                              imageMeta = meta;

                                              CGFloat scale = [[UIScreen mainScreen] scale];
                                              CGFloat width = 320.0*scale;

                                              NSInteger height = [luxeysUtils heightFromWidth:width width:processedImage.size.width height:processedImage.size.height];
                                              
                                              picture = [[GPUImagePicture alloc] initWithImage:processedImage];
                                              imageOrientation = processedImage.imageOrientation;
                                              filter.frameSize = processedImage.size;
                                              
                                              
                                              CGSize size;
                                              CGRect screen = [[UIScreen mainScreen] bounds];
                                              
                                              if (imageOrientation == UIImageOrientationLeft || imageOrientation == UIImageOrientationRight) {
                                                  if (screen.size.height == 480)
                                                      size = CGSizeMake(height/2.0, width/2.0);
                                                  else
                                                      size = CGSizeMake(height*2.0, width*2.0);
                                                  viewCameraWraper.frame = CGRectMake(14, 0, 320, 240);
                                              }
                                              else {
                                                  if (screen.size.height == 480) {
                                                      viewCameraWraper.frame = CGRectMake(14, 0, 292, 390);
                                                      size = CGSizeMake(width/2.0, height/2.0);
                                                  }
                                                  else {
                                                      viewCameraWraper.frame = CGRectMake(3.5, 0, 313.5, 418);
                                                      size = CGSizeMake(width*2.0, height*2.0);
                                                  }
                                              }
                                              
                                              
                                              [self resizeCameraViewWithAnimation:NO];

                                              
                                              UIImage *previewPic = [processedImage
                                                                     resizedImage: size
                                                                     interpolationQuality:kCGInterpolationHigh];
                                              previewPic = [previewPic fixOrientation];
                                              
                                              previewFilter = [[GPUImagePicture alloc] initWithImage:previewPic
                                                                                 smoothlyScaleOutput:YES];
                                              
                                              
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
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alert"
                                                        message:@"You have not saved this photo, are you sure?"
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel"
                                              otherButtonTitles:@"OK", nil];
        alert.tag = 2;
        [alert show];
    } else
        [self dismissViewControllerAnimated:NO completion:nil];
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
    sheet = [[UIActionSheet alloc] initWithTitle:@"レンズ交換"
                                        delegate:self
                               cancelButtonTitle:@"キャンセル"
                          destructiveButtonTitle:nil
                               otherButtonTitles:@"普通", @"ワイド", @"魚眼レンズ", nil];
    [sheet setTag:0];
    sheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
    [sheet showInView:self.view];
}

- (IBAction)changeFlash:(id)sender {
    buttonFlash.selected = !buttonFlash.selected;
    [self setFlash:buttonFlash.selected];
}

- (IBAction)changeCamera:(id)sender {
}

- (IBAction)touchTimer:(id)sender {
    // wait for time before begin
    [viewTimer setHidden:!viewTimer.isHidden];
}

- (IBAction)touchSave:(id)sender {
    [self saveImage];
}

- (IBAction)toggleCrop:(id)sender {
    isCrop = !isCrop;
    [self setupCameraAspect];
//    [self toggleCrop];
}

- (IBAction)toggleEffect:(UIButton*)sender {
    switch (sender.tag) {
        case 1:
            scrollEffect.hidden = !scrollEffect.hidden;
            buttonScroll.selected = !scrollEffect.hidden;
            if (scrollEffect.hidden) {
                viewFocusControl.hidden = !(bokehMode != kBokehModeDisable);
                if (!viewFocusControl.hidden) {
                    [self setFocusTab:currentFocusTab];
                }
            }
            else {
                viewFocusControl.hidden = true;
                viewDraw.hidden = true;
            }
            break;
        case 2:
            [self showLensEffect];
            break;
        default:
            break;
    }
    [self resizeCameraViewWithAnimation:YES];
}

- (void)resizeCameraViewWithAnimation:(BOOL)animation {
    [scrollCamera setZoomScale:1.0 animated:NO];
    CGRect screen = [[UIScreen mainScreen] bounds];

    
    CGRect frame = scrollCamera.frame;
    CGRect frame2 = viewCameraWraper.frame;
    
    if (screen.size.height > 480) {
        if (scrollEffect.hidden && viewFocusControl.hidden)
            frame.size.height = 568 - 40 - 50;
        else if (!scrollEffect.hidden)
            frame.size.height = 418;
        else {
            switch (bokehMode) {
                case kBokehModeDisable:
                    frame.size.height = 568 - 40 - 50;
                    break;
                case kBokehModeFull:
                    frame.size.height = 568 - 40 - 50 - 90;
                    break;
            }
        }
    } else {
        if (scrollEffect.hidden)
            switch (bokehMode) {
                case kBokehModeDisable:
                    frame.size.height = 480 - 40 - 50;
                    break;
                case kBokehModeFull:
                    frame.size.height = 480 - 40 - 50 - 90;
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
    
    // [UIView animateWithDuration:animation?0.3:0 animations:^{
        
    //     // viewCameraWraper.frame = frame2;
    // }];
    scrollCamera.frame = frame;
    [scrollCamera setZoomScale:ratio];
    [self scrollViewDidZoom:scrollCamera];
}

- (void)showLensEffect {
    if (!viewFocusControl.hidden) {
        switch (bokehMode) {
            case kBokehModeDisable:
                bokehMode = kBokehModeFull;
                break;
            case kBokehModeFull:
                bokehMode = kBokehModeDisable;
                break;
        }
        [self applyCurrentEffect];
    } else {
        if (bokehMode == kBokehModeDisable)
            bokehMode = kBokehModeFull;
    }

    switch (bokehMode) {
        case kBokehModeFull:
            viewDraw.hidden = false;
            buttonToggleFocus.selected = true;
            viewFocusControl.hidden = false;
            [self setFocusTab:currentFocusTab];
            break;
        case kBokehModeDisable:
            viewDraw.hidden = true;
            buttonToggleFocus.selected = false;
            viewFocusControl.hidden = true;
            break;
    }

    scrollEffect.hidden = true;
    buttonScroll.selected = false;
}

- (void)saveImage {
    NSDictionary *location;
    if (bestEffortAtLocation != nil) {
        location = [luxeysUtils getGPSDictionaryForLocation:bestEffortAtLocation];
        [imageMeta setObject:location forKey:(NSString *)kCGImagePropertyGPSDictionary];
    }
    
    void (^saveImage)(ALAsset *, UIImage *) = ^(ALAsset *asset, UIImage *preview) {
        isSaved = true;
        luxeysAppDelegate* app = (luxeysAppDelegate*)[UIApplication sharedApplication].delegate;
        
        if (app.currentUser != nil) {
            ALAssetRepresentation *rep = [asset defaultRepresentation];
            Byte *buffer = (Byte*)malloc(rep.size);
            NSUInteger buffered = [rep getBytes:buffer fromOffset:0.0 length:rep.size error:nil];
            NSData *uploadData = [NSData dataWithBytesNoCopy:buffer length:buffered freeWhenDone:YES];
            
            NSDictionary *info = [[NSDictionary alloc] initWithObjectsAndKeys:
                                  uploadData, @"data",
                                  preview, @"preview",
                                  nil];
            
            [delegate imagePickerController:self didFinishPickingMediaWithData:info];
            
        } else {
            [self switchCamera];
        }
    };
    
    [filter changeFiltertoLens:currentLens andEffect:currentEffect input:picture output:nil isPicture:YES];
    [picture processImage];
    [filter saveImage:location orientation:imageOrientation withMeta:imageMeta onComplete:saveImage];
}

- (void)setupCameraAspect {
    if (isCrop) {
        cameraAspect = [NSLayoutConstraint constraintWithItem:cameraView
                                                    attribute:NSLayoutAttributeHeight
                                                    relatedBy:NSLayoutRelationEqual
                                                       toItem:cameraView
                                                    attribute:NSLayoutAttributeWidth
                                                   multiplier:1.0
                                                     constant:0.0];
    } else {
        cameraAspect = [NSLayoutConstraint constraintWithItem:cameraView
                                                    attribute:NSLayoutAttributeHeight
                                                    relatedBy:NSLayoutRelationEqual
                                                       toItem:cameraView
                                                    attribute:NSLayoutAttributeWidth
                                                   multiplier:4.0/3.0
                                                     constant:0.0];
    }
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
                size = CGSizeMake(height*scale*2.0, 320.0*scale*2.0);
            filter.frameSize = CGSizeMake(tmp.size.height*tmp.scale, tmp.size.width*tmp.scale);
        }
        else {
            if (screen.size.height == 480)
                size = CGSizeMake(320.0, height);
            else
                size = CGSizeMake(320.0*scale*2.0, height*scale*2.0);
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
        NSLog(@"booya, cant get image - %@",[myerror localizedDescription]);
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
    picture = nil;
    previewFilter = nil;
    
    // Set to normal lens
    currentLens = 0;
    viewDraw.hidden = true;
    viewDraw.isEmpty = true;
    
    // Zoom to normal size
    [scrollCamera setZoomScale:1.0 animated:NO];
    
    CGRect screen = [[UIScreen mainScreen] bounds];
    if (screen.size.height == 480)
        viewCameraWraper.frame = CGRectMake(14, 0, 292, 390);
    else
        viewCameraWraper.frame = CGRectMake(3.5, 0, 313.5, 418);
    scrollCamera.contentSize = viewCameraWraper.frame.size;
    
    bokehMode = kBokehModeDisable;
    [self resizeCameraViewWithAnimation:NO];
    
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
    viewFocusControl.hidden = true;
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
    [self setUIMask:kMaskBackgroundNone];

    currentFocusTab = kBokehTabMask;
    bokehMode = kBokehModeDisable;
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
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alert"
                                                        message:@"You have not saved this photo, are you sure?"
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel"
                                              otherButtonTitles:@"OK", nil];
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
            if (buttonIndex == 1)
                [self dismissViewControllerAnimated:NO completion:nil];
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

- (IBAction)touchFocusTab:(UIButton*)sender {
    currentFocusTab = sender.tag;
    [self setFocusTab:sender.tag];
}

- (IBAction)setMask:(UIButton*)sender {
    [self setUIMask:sender.tag];
}

- (void)setUIMask:(NSInteger)tag {
    switch (tag) {
        case kMaskBackgroundNone: // Background none
            buttonBackgroundNone.enabled = false;
            buttonBackgroundRound.enabled = true;
            buttonBackgroundNatual.enabled = true;
            viewDraw.backgroundType = kBackgroundNone;
            break;
        case kMaskBackgroundRound: // Background Round
            buttonBackgroundNone.enabled = true;
            buttonBackgroundRound.enabled = false;
            buttonBackgroundNatual.enabled = true;
            viewDraw.backgroundType = kBackgroundRadial;
            break;
        case kMaskBackgroundNatual: // Background Gradient
            buttonBackgroundNone.enabled = true;
            buttonBackgroundRound.enabled = true;
            buttonBackgroundNatual.enabled = false;
            viewDraw.backgroundType = kBackgroundNatual;
            break;
            
        default:
            break;
    }
}

- (UIImage*)imageRadialGradient {
    UIGraphicsBeginImageContextWithOptions(cameraView.frame.size, NO, 0);
    CGContextRef currentContext = UIGraphicsGetCurrentContext();
    
    CGGradientRef glossGradient;
    CGColorSpaceRef rgbColorspace;
    size_t num_locations = 2;
    CGFloat locations[2] = { 0.0, 1.0 };
    CGFloat components[8] = { 1.0, 0.0, 0.0, 0.9,  // Start color
        1.0, 0.0, 0.0, 0.0 }; // End color
    
    rgbColorspace = CGColorSpaceCreateDeviceRGB();
    glossGradient = CGGradientCreateWithColorComponents(rgbColorspace, components, locations, num_locations);
    
    CGRect currentBounds = cameraView.bounds;
    CGPoint midCenter = CGPointMake(CGRectGetMidX(currentBounds), CGRectGetMidY(currentBounds));
    CGContextDrawRadialGradient(currentContext, glossGradient, midCenter, 0, midCenter, cameraView.frame.size.width, kCGGradientDrawsBeforeStartLocation);
    
    CGGradientRelease(glossGradient);
    CGColorSpaceRelease(rgbColorspace);
    
    // make image out of bitmap context
	UIImage *retImage = UIGraphicsGetImageFromCurrentImageContext();
    
	// free the context
	UIGraphicsEndImageContext();
    
	return retImage;
}

- (UIImage*)imageLinearGradient {
    UIGraphicsBeginImageContextWithOptions(cameraView.frame.size, NO, 0);
    CGContextRef currentContext = UIGraphicsGetCurrentContext();
    
    CGGradientRef glossGradient;
    CGColorSpaceRef rgbColorspace;
    size_t num_locations = 2;
    CGFloat locations[2] = { 0.0, 1.0 };
    CGFloat components[8] = { 1.0, 0.0, 0.0, 0.0,  // Start color
        1.0, 0.0, 0.0, 0.9 }; // End color
    
    rgbColorspace = CGColorSpaceCreateDeviceRGB();
    glossGradient = CGGradientCreateWithColorComponents(rgbColorspace, components, locations, num_locations);
    
    CGRect currentBounds = cameraView.bounds;
    CGPoint topCenter = CGPointMake(CGRectGetMidX(currentBounds), 0.0f);
    CGPoint bottomCenter = CGPointMake(CGRectGetMidX(currentBounds), currentBounds.size.height);
    CGContextDrawLinearGradient(currentContext, glossGradient, topCenter, bottomCenter, 0);
    
    CGGradientRelease(glossGradient);
    CGColorSpaceRelease(rgbColorspace);
    
    // make image out of bitmap context
	UIImage *retImage = UIGraphicsGetImageFromCurrentImageContext();
    
	// free the context
	UIGraphicsEndImageContext();
    
	return retImage;
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

- (IBAction)pinchMask:(UIPinchGestureRecognizer *)sender {
    imageMaskRect.transform = CGAffineTransformScale(imageMaskRect.transform, sender.scale, sender.scale);
    sender.scale = 1;
    NSLog(@"Pinched");
}

- (IBAction)rotateMask:(UIRotationGestureRecognizer *)sender {
    imageMaskRect.transform = CGAffineTransformRotate(imageMaskRect.transform, sender.rotation);
    sender.rotation = 0;
    NSLog(@"Rotate");
}

- (IBAction)panMask:(UIPanGestureRecognizer *)sender {
    CGPoint translation = [sender translationInView:viewDraw];
    imageMaskRect.center = CGPointMake(imageMaskRect.center.x,
                                         imageMaskRect.center.y + translation.y);
    [sender setTranslation:CGPointMake(0, 0) inView:viewDraw];
}

- (void)setFocusTab:(int)mode {
    tapFocus.enabled = false;
    
    imageAutoFocus.hidden = true;
    viewDraw.hidden = true;
    viewBlur.hidden = true;
    viewMask.hidden = true;
    viewFocal.hidden = true;
    
    buttonMove.enabled = true;
    buttonPaintMask.enabled = true;
    buttonFocal.enabled = true;
    buttonBackground.enabled = true;
    
    switch (mode) {
        case kBokehTabMask:
            currentLens = 0; // Normal lens
            viewDraw.hidden = false;
            viewMask.hidden = false;
            buttonPaintMask.enabled = false;
            tapFocus.enabled = false;
            imageAutoFocus.hidden = true;
            [self resizeCameraViewWithAnimation:NO];
            scrollCamera.scrollEnabled = false;
            break;
        case kBokehTabBlur: // Blur mode
            scrollCamera.scrollEnabled = true;
            viewBlur.hidden = false;
            buttonBackground.enabled = false;
            imageAutoFocus.hidden = false;
            tapFocus.enabled = true;
            imageAutoFocus.hidden = false;
            scrollCamera.scrollEnabled = true;
            // Change to preview
            break;
    }
}

- (IBAction)focusControl:(id)sender {
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

- (void)handleTap:(UITapGestureRecognizer *)sender {
    
}


- (void)didProcessImage {
    isFinishedProcessing = true;
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
            NSLog(@"Set flash");
        }
    } else {
        NSLog(@"ERROR = %@", error);
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
        NSLog(@"ERROR = %@", error);
    }
}


- (void)setMetteringPoint:(CGPoint)point {
    AVCaptureDevice *device = videoCamera.inputCamera;
    
    CGPoint pointOfInterest;
    //    if (isCrop)
    //        pointOfInterest = CGPointMake(point.y + 0.125, 1.0 - point.x);
    //    else
    pointOfInterest = CGPointMake(point.y, 1.0 - point.x);
    NSLog(@"Mettering at %f %f", pointOfInterest.x, pointOfInterest.y);
    
    NSError *error;
    if ([device lockForConfiguration:&error]) {;
        if([device isExposurePointOfInterestSupported] && [device isExposureModeSupported:AVCaptureExposureModeContinuousAutoExposure])
        {
            [device setExposurePointOfInterest:pointOfInterest];
            [device setExposureMode:AVCaptureExposureModeContinuousAutoExposure];
            NSLog(@"Mettering OK");
        }
        [device unlockForConfiguration];
    } else {
        NSLog(@"ERROR = %@", error);
    }
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    if (scrollView.scrollEnabled)
        return viewCameraWraper;
    else
        return nil;
}

- (CGRect)zoomRectForScrollView:(UIScrollView *)scrollView withScale:(float)scale withCenter:(CGPoint)center {
    
    CGRect zoomRect;
    
    // The zoom rect is in the content view's coordinates.
    // At a zoom scale of 1.0, it would be the size of the
    // imageScrollView's bounds.
    // As the zoom scale decreases, so more content is visible,
    // the size of the rect grows.
    zoomRect.size.height = scrollView.frame.size.height / scale;
    zoomRect.size.width  = scrollView.frame.size.width  / scale;
    
    // choose an origin so as to get the right center.
    zoomRect.origin.x = center.x - (zoomRect.size.width  / 2.0);
    zoomRect.origin.y = center.y - (zoomRect.size.height / 2.0);
    
    return zoomRect;
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

- (void)resizeZoomFactor {
    CGFloat horizontalRatio = scrollCamera.frame.size.width / scrollCamera.contentSize.width;
    CGFloat verticalRatio = scrollCamera.frame.size.height / scrollCamera.contentSize.height;
    CGFloat ratio;
    ratio = MIN(horizontalRatio, verticalRatio);
    [scrollCamera setZoomScale:ratio animated:YES];
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
        NSLog(@"Going from %@ to %@!", [[self class] orientationToText:orientationLast], [[self class] orientationToText:orientationNew]);
    #endif
    orientationLast = orientationNew;
}
#pragma mark -

- (void)newMask:(UIImage *)mask {
    filter.dof = [mask rotateOrientation:imageOrientation];
    
    [self applyCurrentEffect];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}
@end
