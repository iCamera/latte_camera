//
//  LXCameraViewController.m
//  Latte camera
//
//  Created by Bui Xuan Dung on 4/25/13.
//  Copyright (c) 2013 LUXEYS. All rights reserved.
//

#import "LXCaptureViewController.h"
#import "LXUtils.h"
#import "MBProgressHUD.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "LXCanvasViewController.h"
#import "UIView+Genie.h"
#import "MBProgressHUD.h"
#import "UIImage+fixOrientation.h"
//#import "RBVolumeButtons.h"

#define kAccelerometerFrequency        10.0 //Hz

typedef enum {
    kTimerNone = 0,
    kTimer5s = 1,
    kTimer10s = 2,
    kTimerContinuous = 3,
} CameraTimer;

@interface LXCaptureViewController ()
- (CGPoint)convertToPointOfInterestFromViewCoordinates:(CGPoint)viewCoordinates;
- (void)tapToAutoFocus:(UIGestureRecognizer *)gestureRecognizer;
- (void)tapToContinouslyAutoFocus:(UIGestureRecognizer *)gestureRecognizer;
@end

@implementation LXCaptureViewController {
    NSTimer *timer;
    NSInteger timerCount;
    
    NSInteger currentTimer;
    
    CLLocationManager *locationManager;
    CLLocation *bestEffortAtLocation;
    UIImage *tmpImagePreview;
    
    LXCamCaptureManager *captureManager;
    AVCaptureVideoPreviewLayer *captureVideoPreviewLayer;
    float volumeLevel;
    BOOL isReady;
}

@synthesize viewCamera;
@synthesize viewTimer;
@synthesize buttonCapture;
@synthesize buttonFlash;
@synthesize buttonFlash35;

@synthesize imageAutoFocus;
@synthesize buttonPick;
@synthesize buttonSetNoTimer;
@synthesize buttonSetTimer5s;

@synthesize viewTopBar;
@synthesize viewTopBar35;
@synthesize viewCameraWraper;
@synthesize viewCanvas;
@synthesize imagePreview;
@synthesize viewFlash;

@synthesize buttonQuick;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    captureManager = [[LXCamCaptureManager alloc] init];
    captureManager.delegate = self;
 
    if ([captureManager setupSession]) {
        // Create video preview layer and add it to the UI
        captureVideoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:[captureManager session]];
        UIView *view = [self viewCamera];
        CALayer *viewLayer = [view layer];
        [viewLayer setMasksToBounds:YES];
        
        CGRect bounds = [view bounds];
        [captureVideoPreviewLayer setFrame:bounds];
        
        [captureVideoPreviewLayer setVideoGravity:AVLayerVideoGravityResizeAspect];
        
        [viewLayer insertSublayer:captureVideoPreviewLayer below:[[viewLayer sublayers] objectAtIndex:0]];
        
        // Add a single tap gesture to focus on the point tapped, then lock focus
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapToAutoFocus:)];
        [singleTap setDelegate:self];
        [singleTap setNumberOfTapsRequired:1];
        [view addGestureRecognizer:singleTap];
        
        // Add a double tap gesture to reset the focus mode to continuous auto focus
        UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapToContinouslyAutoFocus:)];
        [doubleTap setDelegate:self];
        [doubleTap setNumberOfTapsRequired:2];
        [singleTap requireGestureRecognizerToFail:doubleTap];
        [view addGestureRecognizer:doubleTap];
    }
    
    CGRect screen = [[UIScreen mainScreen] bounds];
	// Do any additional setup after loading the view.
    
    if (screen.size.height > 480) {
        viewTopBar.hidden = false;
        viewTopBar35.hidden = true;
    }
    else {
        viewTopBar.hidden = true;
        viewTopBar35.hidden = false;
    }
    
    UIImage *imageCanvas = [[UIImage imageNamed:@"bg_canvas.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(8, 8, 8, 8)];
    viewCanvas.image = imageCanvas;
    
    CGRect frame;
    CGRect frameCanvas;
    if (screen.size.height > 480) {
        frame = CGRectMake(10, 79, 300, 400);
        frameCanvas = CGRectMake(0, 40, 320, 568-40-50);
    }
    else {
        frame = CGRectMake(10, 15, 300, 400);
        frameCanvas = CGRectMake(0, 0, 320, 430);
    }
    
    viewCanvas.frame = frameCanvas;
    viewCameraWraper.frame = frame;
    imagePreview.frame = frame;
    viewFlash.frame = frame;
    
    UIBezierPath *shadowPathCamera = [UIBezierPath bezierPathWithRect:viewCameraWraper.bounds];
    viewCameraWraper.layer.masksToBounds = NO;
    viewCameraWraper.layer.shadowColor = [UIColor blackColor].CGColor;
    viewCameraWraper.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
    viewCameraWraper.layer.shadowOpacity = 1.0;
    viewCameraWraper.layer.shadowRadius = 5.0;
    viewCameraWraper.layer.shadowPath = shadowPathCamera.CGPath;
//    [self enableVolumeSnap];
}

//- (void)enableVolumeSnap {
//    RBVolumeButtons *buttonStealer = [[RBVolumeButtons alloc] init];
//    
//    __weak LXCaptureViewController *weakSelf = self;
//    buttonStealer.upBlock = ^{
//        [weakSelf capturePhotoAsync];
//    };
//    buttonStealer.downBlock = ^{
//        [weakSelf capturePhotoAsync];
//    };
//}

- (void)viewWillAppear:(BOOL)animated {
    currentTimer = kTimerNone;
    
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [locationManager startUpdatingLocation];
    [self performSelector:@selector(stopUpdatingLocation:) withObject:nil afterDelay:45];
    
    [locationManager startUpdatingLocation];
    
    UIAccelerometer* a = [UIAccelerometer sharedAccelerometer];
    a.updateInterval = 1 / kAccelerometerFrequency;
    a.delegate = self;
    
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
    
//    UIApplication *app = [UIApplication sharedApplication];
//    [app setSystemVolumeHUDEnabled:NO];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self startCamera];
}

- (void)startCamera {
    // Start the session. This is done asychronously since -startRunning doesn't return until the session is running.
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[captureManager session] startRunning];
//        dispatch_async(dispatch_get_main_queue(), ^{
            buttonCapture.enabled = YES;
            isReady = YES;
//        });
//    });
}

- (void)stopCamera {
    isReady = NO;
    buttonCapture.enabled = NO;
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        [[captureManager session] stopRunning];
//    });
}

- (void)viewWillDisappear:(BOOL)animated {
    [locationManager stopUpdatingLocation];
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc removeObserver:self];
    
    UIAccelerometer* a = [UIAccelerometer sharedAccelerometer];
    a.delegate = nil;
    

//    UIApplication *app = [UIApplication sharedApplication];
//    [app setSystemVolumeHUDEnabled:YES];
    
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self stopCamera];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)flipCamera:(id)sender
{
    // Toggle between cameras when there is more than one
    [captureManager toggleCamera];
    
    // Do an initial focus
    [captureManager continuousFocusAtPoint:CGPointMake(.5f, .5f)];
}


- (void)capturePhotoAsync {
    if (!isReady) {
        return;
    }
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc removeObserver:self];
    // Capture a still image
    viewFlash.hidden = false;
    viewFlash.alpha = 1.0;
    
    [UIView animateWithDuration:0.3
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         viewFlash.alpha = 0;
                     } completion:^(BOOL finished) {
                         viewFlash.hidden = true;
                     }];
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    [ buttonCapture setEnabled:NO];
    [ captureManager getPreview];
    [ captureManager captureStillImage];
    
    // Save last GPS and Orientation
    [locationManager stopUpdatingLocation];

}

- (void)lattePreviewImageCaptured:(UIImage *)image {
    imagePreview.image = image;
    if (!buttonQuick.selected) {
        tmpImagePreview = image;
    }
}

- (void)latteStillImageCaptured:(UIImage *)image imageMeta:(NSMutableDictionary *)imageMeta {
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    CGRect screen = [[UIScreen mainScreen] bounds];
    [imagePreview genieInTransitionWithDuration:0.7
                                destinationRect:CGRectMake(10, screen.size.height-50, 50, 40)
                                destinationEdge:BCRectEdgeTop
                                     completion:nil];
    
    if (!buttonQuick.selected) {
        UIStoryboard *storyCamera = [UIStoryboard storyboardWithName:@"Camera" bundle:nil];
        LXCanvasViewController *controllerCanvas = [storyCamera instantiateViewControllerWithIdentifier:@"Canvas"];
        
        controllerCanvas.imageMeta = imageMeta;
        controllerCanvas.imageOriginalPreview = [tmpImagePreview fixOrientation];
        
        CGFloat height = [LXUtils heightFromWidth:70 width:tmpImagePreview.size.height height:tmpImagePreview.size.height];
        controllerCanvas.imageThumbnail = [LXUtils imageWithImage:tmpImagePreview scaledToSize:CGSizeMake(70, height)];
        tmpImagePreview = nil;
        controllerCanvas.delegate = _delegate;
        controllerCanvas.imageOriginal = image;
        [self.navigationController pushViewController:controllerCanvas animated:YES];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"Canvas"]) {
        
    }
}

- (void)captureByVolume:(NSNotification*)notification {
    [self capturePhotoAsync];
}

- (IBAction)capture:(id)sender {
    //buttonPick.enabled = true;
    buttonCapture.enabled = false;
    if (currentTimer == kTimerNone) {
        [self capturePhotoAsync];
    } else {
        timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(countDown:) userInfo:nil repeats:YES];
    }
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

- (IBAction)touchQuick:(UIButton *)sender {
    sender.selected = !sender.selected;
}

- (IBAction)touchPick:(id)sender {    
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    [imagePicker.navigationBar setBackgroundImage:[UIImage imageNamed: @"bg_head.png"] forBarMetrics:UIBarMetricsDefault];
    imagePicker.delegate = self;
    [self presentViewController:imagePicker animated:NO completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {    
    ALAssetsLibraryAssetForURLResultBlock resultblock = ^(ALAsset *myasset)
    {
        UIStoryboard *storyCamera = [UIStoryboard storyboardWithName:@"Camera" bundle:nil];
        LXCanvasViewController *controllerCanvas = [storyCamera instantiateViewControllerWithIdentifier:@"Canvas"];
        
        UIImage *imageFullsize = [info objectForKey:UIImagePickerControllerOriginalImage];
        controllerCanvas.delegate = _delegate;
        controllerCanvas.imageOriginalPreview = [UIImage imageWithCGImage:myasset.defaultRepresentation.fullScreenImage];

        UIImage *thumbNail = [UIImage imageWithCGImage:myasset.thumbnail];
        CGFloat height = [LXUtils heightFromWidth:70 width:thumbNail.size.height height:thumbNail.size.height];
        controllerCanvas.imageThumbnail = [LXUtils imageWithImage:thumbNail scaledToSize:CGSizeMake(70, height)];
        
        controllerCanvas.imageMeta = [NSMutableDictionary dictionaryWithDictionary:myasset.defaultRepresentation.metadata];
        controllerCanvas.imageOriginal = imageFullsize;
        
        [picker pushViewController:controllerCanvas animated:YES];
    };
    
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

- (void)navigationController:(UINavigationController *)navigationController
      willShowViewController:(UIViewController *)viewController
                    animated:(BOOL)animated {
    
    if ([navigationController isKindOfClass:[UIImagePickerController class]] &&
        ((UIImagePickerController *)navigationController).sourceType == UIImagePickerControllerSourceTypePhotoLibrary) {
        [[UIApplication sharedApplication] setStatusBarHidden:YES];
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissModalViewControllerAnimated:NO];
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

- (void)stopUpdatingLocation:(id)sender {
    [locationManager stopUpdatingLocation];
    locationManager.delegate = nil;
}

- (void)setFlash:(BOOL)flash {
    AVCaptureDevice *device = [captureManager videoInput].device;
    
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
        DLog(@"ERROR = %@", error);
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
    if (acceleration.x >= 0.75) {
        captureManager.orientation = AVCaptureVideoOrientationLandscapeLeft;
    }
    else if (acceleration.x <= -0.75) {
        captureManager.orientation = AVCaptureVideoOrientationLandscapeRight;
    }
    else if (acceleration.y <= -0.75) {
        captureManager.orientation = AVCaptureVideoOrientationPortrait;
    }
    else if (acceleration.y >= 0.75) {
        captureManager.orientation = AVCaptureVideoOrientationPortraitUpsideDown;
    }
    else {
        captureManager.orientation = AVCaptureVideoOrientationPortrait;
        return;
    }
}
#pragma mark -

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    NSTimeInterval locationAge = -[newLocation.timestamp timeIntervalSinceNow];
    if (locationAge > 5.0) return;
    
    if (newLocation.horizontalAccuracy < 0) return;
    
    if (bestEffortAtLocation == nil || bestEffortAtLocation.horizontalAccuracy > newLocation.horizontalAccuracy) {
        bestEffortAtLocation = newLocation;
        captureManager.bestEffortAtLocation = bestEffortAtLocation;
        if (newLocation.horizontalAccuracy <= locationManager.desiredAccuracy) {
            [locationManager stopUpdatingLocation];
        }
    }
}

- (void)close:(id)sender {
    [self stopCamera];
    [self.navigationController dismissModalViewControllerAnimated:YES];
}

- (CGPoint)convertToPointOfInterestFromViewCoordinates:(CGPoint)viewCoordinates
{
    CGPoint pointOfInterest = CGPointMake(.5f, .5f);
    CGSize frameSize = [[self viewCamera] frame].size;
    
    if ( [[captureVideoPreviewLayer videoGravity] isEqualToString:AVLayerVideoGravityResize] ) {
		// Scale, switch x and y, and reverse x
        pointOfInterest = CGPointMake(viewCoordinates.y / frameSize.height, 1.f - (viewCoordinates.x / frameSize.width));
    } else {
        CGRect cleanAperture;
        for (AVCaptureInputPort *port in [[captureManager videoInput] ports]) {
            if ([port mediaType] == AVMediaTypeVideo) {
                cleanAperture = CMVideoFormatDescriptionGetCleanAperture([port formatDescription], YES);
                CGSize apertureSize = cleanAperture.size;
                CGPoint point = viewCoordinates;
                
                CGFloat apertureRatio = apertureSize.height / apertureSize.width;
                CGFloat viewRatio = frameSize.width / frameSize.height;
                CGFloat xc = .5f;
                CGFloat yc = .5f;
                
                if ( [[captureVideoPreviewLayer videoGravity] isEqualToString:AVLayerVideoGravityResizeAspect] ) {
                    if (viewRatio > apertureRatio) {
                        CGFloat y2 = frameSize.height;
                        CGFloat x2 = frameSize.height * apertureRatio;
                        CGFloat x1 = frameSize.width;
                        CGFloat blackBar = (x1 - x2) / 2;
						// If point is inside letterboxed area, do coordinate conversion; otherwise, don't change the default value returned (.5,.5)
                        if (point.x >= blackBar && point.x <= blackBar + x2) {
							// Scale (accounting for the letterboxing on the left and right of the video preview), switch x and y, and reverse x
                            xc = point.y / y2;
                            yc = 1.f - ((point.x - blackBar) / x2);
                        }
                    } else {
                        CGFloat y2 = frameSize.width / apertureRatio;
                        CGFloat y1 = frameSize.height;
                        CGFloat x2 = frameSize.width;
                        CGFloat blackBar = (y1 - y2) / 2;
						// If point is inside letterboxed area, do coordinate conversion. Otherwise, don't change the default value returned (.5,.5)
                        if (point.y >= blackBar && point.y <= blackBar + y2) {
							// Scale (accounting for the letterboxing on the top and bottom of the video preview), switch x and y, and reverse x
                            xc = ((point.y - blackBar) / y2);
                            yc = 1.f - (point.x / x2);
                        }
                    }
                } else if ([[captureVideoPreviewLayer videoGravity] isEqualToString:AVLayerVideoGravityResizeAspectFill]) {
					// Scale, switch x and y, and reverse x
                    if (viewRatio > apertureRatio) {
                        CGFloat y2 = apertureSize.width * (frameSize.width / apertureSize.height);
                        xc = (point.y + ((y2 - frameSize.height) / 2.f)) / y2; // Account for cropped height
                        yc = (frameSize.width - point.x) / frameSize.width;
                    } else {
                        CGFloat x2 = apertureSize.height * (frameSize.height / apertureSize.width);
                        yc = 1.f - ((point.x + ((x2 - frameSize.width) / 2)) / x2); // Account for cropped width
                        xc = point.y / frameSize.height;
                    }
                }
                
                pointOfInterest = CGPointMake(xc, yc);
                break;
            }
        }
    }
    
    return pointOfInterest;
}

// Auto focus at a particular point. The focus mode will change to locked once the auto focus happens.
- (void)tapToAutoFocus:(UIGestureRecognizer *)gestureRecognizer
{
    CGPoint tapPoint = [gestureRecognizer locationInView:[self viewCamera]];
    CGPoint convertedFocusPoint = [self convertToPointOfInterestFromViewCoordinates:tapPoint];
    
    if ([[[captureManager videoInput] device] isFocusPointOfInterestSupported]) {
        [captureManager autoFocusAtPoint:convertedFocusPoint];
    }
    
    if ([[[captureManager videoInput] device] isExposurePointOfInterestSupported]) {
        [captureManager meteringAtPoint:convertedFocusPoint];
    }
    
    imageAutoFocus.center = tapPoint;
    imageAutoFocus.alpha = 1;
    [UIView animateWithDuration:kGlobalAnimationSpeed
                          delay:1
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         imageAutoFocus.alpha = 0;
                     } completion:nil];
}

// Change to continuous auto focus. The camera will constantly focus at the point choosen.
- (void)tapToContinouslyAutoFocus:(UIGestureRecognizer *)gestureRecognizer
{
    if ([[[captureManager videoInput] device] isFocusPointOfInterestSupported])
        [captureManager continuousFocusAtPoint:CGPointMake(.5f, .5f)];
}


- (void)captureManager:(AVCamCaptureManager *)captureManager didFailWithError:(NSError *)error
{
    CFRunLoopPerformBlock(CFRunLoopGetMain(), kCFRunLoopCommonModes, ^(void) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[error localizedDescription]
                                                            message:[error localizedFailureReason]
                                                           delegate:nil
                                                  cancelButtonTitle:NSLocalizedString(@"OK", @"OK button title")
                                                  otherButtonTitles:nil];
        [alertView show];
    });
}

- (void)captureManagerStillImageCaptured:(AVCamCaptureManager *)captureManager
{
    CFRunLoopPerformBlock(CFRunLoopGetMain(), kCFRunLoopCommonModes, ^(void) {
        [[self buttonCapture] setEnabled:YES];
    });
}

- (void)viewDidUnload {
    [self setImagePreview:nil];
    [self setViewFlash:nil];
    [self setButtonQuick:nil];
    [super viewDidUnload];
}
@end
