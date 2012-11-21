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
@synthesize imageBackgroundMask;

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
        
        [viewDraw setPreviousPoint:CGPointZero];
        [viewDraw setPrePreviousPoint:CGPointZero];
        [viewDraw setLineWidth:1.0];
        viewDraw.isEmpty = YES;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
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
    }
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
        UILabel *labelEffect = [[UILabel alloc] initWithFrame:CGRectMake(14+60*i, 14, 20, 10)];
        labelEffect.backgroundColor = [UIColor clearColor];
        labelEffect.textColor = [UIColor whiteColor];
        labelEffect.font = [UIFont systemFontOfSize:9];
        UIButton *buttonEffect = [[UIButton alloc] initWithFrame:CGRectMake(10+60*i, 10, 50, 50)];
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
    scrollEffect.contentSize = CGSizeMake(16*60+10, 70);
    
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
    [self setImageBackgroundMask:nil];
    [super viewDidUnload];
}

- (UIImage*)dofMask {
    UIImage *bottomImage = imageBackgroundMask.image;
    UIImage *image = viewDraw.drawImageView.image;
    
    CGSize newSize = bottomImage.size;
    UIGraphicsBeginImageContextWithOptions(bottomImage.size, NO, 0);
    
    // Use existing opacity as is
    [bottomImage drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    // Apply supplied opacity
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height) blendMode:kCGBlendModeNormal alpha:1.0];
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return newImage;
}

- (void)applyCurrentEffect {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        if (isEditing) {
            if (!viewDraw.isEmpty) {
                filter.dof = [self dofMask];
            }
            else
                filter.dof = nil;
            [filter changeFiltertoLens:currentLens andEffect:currentEffect input:previewFilter output:cameraView isPicture:true];
            [previewFilter processImage];
        } else {
            [filter changeFiltertoLens:currentLens andEffect:currentEffect input:videoCamera output:cameraView isPicture:false];
        }
    });
}


- (IBAction)setEffect:(id)sender {
    UIButton* buttonEffect = (UIButton*)sender;
    currentEffect = buttonEffect.tag;
    [self applyCurrentEffect];
}


- (void)updateTargetPoint {
    CGPoint point = CGPointMake(imageAutoFocus.center.x/cameraView.frame.size.width, imageAutoFocus.center.y/cameraView.frame.size.height);
    
    if (isEditing) {
        filter.autofocus = true;
        filter.focus = point;
        [self applyCurrentEffect];
    } else {
        [self setFocusPoint:point];
        [self setMetteringPoint:point];
    }    
}

- (void)capturePhotoAsync {
    [videoCamera capturePhotoAsImageProcessedUpToFilterWithMeta:[filter getCrop]
                                          withCompletionHandler:^(UIImage *processedImage, NSMutableDictionary *meta, NSError *error) {
                                              [locationManager stopUpdatingLocation];
                                              [videoCamera stopCameraCapture];
                                              
                                              imageMeta = meta;
                                              
                                              NSInteger height = [luxeysUtils heightFromWidth:320.0 width:processedImage.size.width height:processedImage.size.height];
                                              
                                              picture = [[GPUImagePicture alloc] initWithImage:processedImage];
                                              imageOrientaion = processedImage.imageOrientation;
                                              filter.frameSize = processedImage.size;
                                              
                                              CGFloat scale = [[UIScreen mainScreen] scale];
                                              CGSize size;
                                              if (processedImage.imageOrientation == UIImageOrientationLeft || processedImage.imageOrientation == UIImageOrientationRight)
                                                  size = CGSizeMake(height*scale, 320.0*scale);
                                              else
                                                  size = CGSizeMake(320.0*scale, height*scale);
                                              
                                              UIImage *previewPic = [processedImage
                                                                     resizedImage: size
                                                                     interpolationQuality:kCGInterpolationHigh];
                                              previewPic = [previewPic fixOrientation];
                                              
                                              previewFilter = [[GPUImagePicture alloc] initWithImage:previewPic
                                                                                 smoothlyScaleOutput:YES];
                                              
                                              
                                              [self switchEditImage];
    }];
}

- (IBAction)cameraTouch:(UITapGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateRecognized) {
        CGPoint location = [sender locationInView:self.cameraView];
        
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
                               otherButtonTitles:@"普通", @"ぼけ", @"魚眼レンズ", nil];
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
            viewFocusControl.hidden = true;
            scrollEffect.hidden = !scrollEffect.hidden;
            buttonScroll.selected = !scrollEffect.hidden;
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
    CGRect screen = [[UIScreen mainScreen] bounds];

    
    CGRect frame = scrollCamera.frame;
    CGRect frame2 = viewCameraWraper.frame;
    
    if (screen.size.height > 480) {
        if (scrollEffect.hidden && viewFocusControl.hidden)
            frame.size.height = 568 - 40 - 50;
         else
            frame.size.height = 408;
    }

    CGFloat horizontalRatio = frame.size.width / frame2.size.width;
    CGFloat verticalRatio = frame.size.height / frame2.size.height;
    CGFloat ratio;
    ratio = MIN(horizontalRatio, verticalRatio);
    
    frame2.size = CGSizeMake(frame2.size.width*ratio, frame2.size.height*ratio);
    frame2.origin.x = (frame.size.width - frame2.size.width)/2;
    frame2.origin.y = (frame.size.height - frame2.size.height)/2;
    
    [UIView animateWithDuration:animation?0.3:0 animations:^{
        if (screen.size.height > 480) {
            scrollCamera.frame = frame;
        }
        viewCameraWraper.frame = frame2;
    }];
}

- (void)showLensEffect {
    scrollEffect.hidden = true;
    viewFocusControl.hidden = !viewFocusControl.hidden;
    buttonToggleFocus.selected = !viewFocusControl.hidden;
    buttonScroll.selected = false;
}

- (void)saveImage {
    NSDictionary *location;
    if (bestEffortAtLocation != nil) {
        location = [luxeysUtils getGPSDictionaryForLocation:bestEffortAtLocation];
        [imageMeta setObject:location forKey:(NSString *)kCGImagePropertyGPSDictionary];
    }
    
    void (^saveImage)(ALAsset *) = ^(ALAsset *asset) {
        luxeysAppDelegate* app = (luxeysAppDelegate*)[UIApplication sharedApplication].delegate;
        
        if (app.currentUser != nil) {
            ALAssetRepresentation *rep = [asset defaultRepresentation];
            Byte *buffer = (Byte*)malloc(rep.size);
            NSUInteger buffered = [rep getBytes:buffer fromOffset:0.0 length:rep.size error:nil];
            NSData *uploadData = [NSData dataWithBytesNoCopy:buffer length:buffered freeWhenDone:YES];
            
            [delegate imagePickerController:self didFinishPickingMediaWithData:uploadData];
            
        } else {
            [self switchCamera];
        }
    };
    
    //[filter saveUIImage:picture withLocation:location withMeta:imageMeta onComplete:saveImage];
    [filter changeFiltertoLens:currentLens andEffect:currentEffect input:picture output:cameraView isPicture:YES];
    [picture processImage];
    [filter saveImage:location orientation:imageOrientaion withMeta:imageMeta onComplete:saveImage];
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
    // Change lens
    buttonToggleFocus.hidden = YES;
    viewFocusControl.hidden = YES;
    switch (buttonIndex) {
        case 1:
            buttonToggleFocus.hidden = NO;
            [self showLensEffect];
            break;
        case 3:
            return;
            break;
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
        imageOrientaion = tmp.imageOrientation;
        filter.frameSize = CGSizeMake(tmp.size.width*tmp.scale, tmp.size.height*tmp.scale);
        
        [imagePicker dismissViewControllerAnimated:NO completion:nil];
        
        [scrollCamera setZoomScale:1.0];
        NSInteger height = [luxeysUtils heightFromWidth:320.0 width:tmp.size.width height:tmp.size.height];
        viewCameraWraper.frame = CGRectMake(0.0, (scrollCamera.frame.size.height-height)/2, 320.0, height);
        [self resizeCameraViewWithAnimation:NO];
        
        UIImage *previewPic  = [UIImage imageWithCGImage:rep.fullScreenImage];
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
    isEditing = NO;
    
    // Clear memory
    picture = nil;
    previewFilter = nil;
    
    // Set to normal lens
    currentLens = 0;
    viewDraw.hidden = true;
    imageBackgroundMask.hidden = true;
    
    // Zoom to normal size
    [scrollCamera setZoomScale:1.0];
    viewCameraWraper.frame = CGRectMake(0, 0, 320, 425);
    scrollCamera.scrollEnabled = NO;

    [self resizeCameraViewWithAnimation:NO];
    
    [locationManager startUpdatingLocation];
    [videoCamera resumeCameraCapture];
    [videoCamera startCameraCapture];

    [self applyCurrentEffect];
//    [cameraView setInputRotation:kGPUImageNoRotation atIndex:0];
    
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
    buttonToggleFocus.hidden = YES;
    buttonChangeLens.hidden = YES;
    viewFocusControl.hidden = true;
    scrollEffect.hidden = false;
    buttonScroll.selected = YES;
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

    imageAutoFocus.hidden = YES;
    viewTimer.hidden = YES;
    tapFocus.enabled = false;
    buttonToggleFocus.hidden = YES;
    
    scrollCamera.maximumZoomScale=6.0;
    
    // Clear depth mask
    [viewDraw.drawImageView setImage:nil];
    viewDraw.currentColor = [UIColor redColor];
    viewDraw.isEmpty = YES;
    
    [self setFocusTab:kTouchZoom];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"Edit"]) {
        luxeysPicEditViewController *controllerPicEdit = segue.destinationViewController;
        [controllerPicEdit setData:sender];
    }
}

- (IBAction)touchNo:(id)sender {
    [self switchCamera];
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
    [self setFocusTab:sender.tag];
    sender.enabled = false;
}

- (IBAction)setMask:(UIButton*)sender {
    switch (sender.tag) {
        case 1:
            viewDraw.lineWidth = 5.0;
            break;
        case 2:
            viewDraw.lineWidth = 15.0;
            break;
        case 3:
            viewDraw.lineWidth = 23.0;
            break;
        case 4:
            viewDraw.isEraser = false;
            break;
        case 5:
            viewDraw.isEraser = true;
            break;
        case 6: // Background none
            [imageBackgroundMask setImage:nil];
            break;
        case 7: // Background Round
            [imageBackgroundMask setImage:[self imageRadialGradient]];
            break;
        case 8: // Background Gradient
            [imageBackgroundMask setImage:[self imageLinearGradient]];
            break;

            
        default:
            break;
    }
}

- (UIImage*)imageRadialGradient {
    UIGraphicsBeginImageContextWithOptions(imageBackgroundMask.frame.size, NO, 0);
    CGContextRef currentContext = UIGraphicsGetCurrentContext();
    
    CGGradientRef glossGradient;
    CGColorSpaceRef rgbColorspace;
    size_t num_locations = 2;
    CGFloat locations[2] = { 0.0, 1.0 };
    CGFloat components[8] = { 1.0, 0.0, 0.0, 0.9,  // Start color
        1.0, 0.0, 0.0, 0.0 }; // End color
    
    rgbColorspace = CGColorSpaceCreateDeviceRGB();
    glossGradient = CGGradientCreateWithColorComponents(rgbColorspace, components, locations, num_locations);
    
    CGRect currentBounds = imageBackgroundMask.bounds;
    CGPoint topCenter = CGPointMake(CGRectGetMidX(currentBounds), 0.0f);
    CGPoint midCenter = CGPointMake(CGRectGetMidX(currentBounds), CGRectGetMidY(currentBounds));
    CGContextDrawRadialGradient(currentContext, glossGradient, midCenter, 0, midCenter, imageBackgroundMask.frame.size.width, kCGGradientDrawsBeforeStartLocation);
    
    CGGradientRelease(glossGradient);
    CGColorSpaceRelease(rgbColorspace);
    
    // make image out of bitmap context
	UIImage *retImage = UIGraphicsGetImageFromCurrentImageContext();
    
	// free the context
	UIGraphicsEndImageContext();
    
	return retImage;
}

- (UIImage*)imageLinearGradient {
    UIGraphicsBeginImageContextWithOptions(imageBackgroundMask.frame.size, NO, 0);
    CGContextRef currentContext = UIGraphicsGetCurrentContext();
    
    CGGradientRef glossGradient;
    CGColorSpaceRef rgbColorspace;
    size_t num_locations = 2;
    CGFloat locations[2] = { 0.0, 1.0 };
    CGFloat components[8] = { 1.0, 0.0, 0.0, 0.0,  // Start color
        1.0, 0.0, 0.0, 0.9 }; // End color
    
    rgbColorspace = CGColorSpaceCreateDeviceRGB();
    glossGradient = CGGradientCreateWithColorComponents(rgbColorspace, components, locations, num_locations);
    
    CGRect currentBounds = imageBackgroundMask.bounds;
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

- (IBAction)changeFocalDepth:(UISlider *)sender {
    filter.autofocus = false;
    filter.focalDepth = sender.value;
    [self applyCurrentEffect];
}

- (void)setFocusTab:(int)mode {
    scrollCamera.scrollEnabled = false;
    tapFocus.enabled = false;
    
    imageAutoFocus.hidden = true;
    viewDraw.hidden = true;
    imageBackgroundMask.hidden = true;
    viewBlur.hidden = true;
    viewMask.hidden = true;
    viewFocal.hidden = true;
    
    buttonMove.enabled = true;
    buttonPaintMask.enabled = true;
    buttonFocal.enabled = true;
    buttonBackground.enabled = true;
    
    switch (mode) {
        case 0: // Move mode
            scrollCamera.scrollEnabled = true;
            
            // Change to preview
            currentLens = 1;
            break;
        case 1:  // Focus
            [scrollCamera setZoomScale:1.0 animated:YES];
            imageAutoFocus.hidden = false;
            tapFocus.enabled = true;
            viewFocal.hidden = false;
            
            // Change to preview
            currentLens = 1;
            break;
        case 2:  // Mask mode
            currentLens = 0; // Normal lens
            viewDraw.hidden = false;
            imageBackgroundMask.hidden = false;
            viewMask.hidden = false;
            break;
        case 3: // Background mode
            viewBlur.hidden = false;
            
            // Change to preview
            currentLens = 1;
            break;
    }
    [self applyCurrentEffect];
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
    
    NSLog(@"Focus at %f %f", pointOfInterest.x, pointOfInterest.y);
    
    NSError *error;
    if ([device lockForConfiguration:&error]) {
        if ([device isFocusPointOfInterestSupported] && [device isFocusModeSupported:AVCaptureFocusModeAutoFocus]) {
            [device setFocusPointOfInterest:pointOfInterest];
            [device setFocusMode:AVCaptureFocusModeAutoFocus];
            [device unlockForConfiguration];
            NSLog(@"FOCUS OK");
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
    return viewCameraWraper;
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

@end
