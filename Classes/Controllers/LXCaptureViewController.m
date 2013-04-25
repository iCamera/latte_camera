//
//  LXCameraViewController.m
//  Latte camera
//
//  Created by Bui Xuan Dung on 4/25/13.
//  Copyright (c) 2013 LUXEYS. All rights reserved.
//

#import "LXCaptureViewController.h"
#import "UIDeviceHardware.h"
#import "LXUtils.h"
#import <MediaPlayer/MediaPlayer.h>
#import "MBProgressHUD.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "LXCanvasViewController.h"

#define kAccelerometerFrequency        10.0 //Hz

typedef enum {
    kTimerNone = 0,
    kTimer5s = 1,
    kTimer10s = 2,
    kTimerContinuous = 3,
} CameraTimer;

@interface LXCaptureViewController ()

@end

@implementation LXCaptureViewController {
    GPUImageStillCamera *videoCamera;
    
    BOOL isBackCamera;
    
    NSTimer *timer;
    NSInteger timerCount;
    
    NSInteger currentTimer;
    
    CLLocationManager *locationManager;
    CLLocation *bestEffortAtLocation;
    UIInterfaceOrientation orientationLast;
    
    GPUImageFilter *dummy;
}

@synthesize viewCamera;
@synthesize viewTimer;
@synthesize buttonCapture;
@synthesize buttonFlash;
@synthesize buttonFlash35;
@synthesize buttonFlip;

@synthesize imageAutoFocus;
@synthesize buttonPick;
@synthesize buttonSetNoTimer;
@synthesize buttonSetTimer5s;
@synthesize tapFocus;

@synthesize viewTopBar;
@synthesize viewTopBar35;
@synthesize viewCameraWraper;
@synthesize viewCanvas;

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
    
    [LXUtils globalShadow:viewCameraWraper];
    
    viewCamera.fillMode = kGPUImageFillModeStretch;
    
    videoCamera = [[LXStillCamera alloc] initWithSessionPreset:AVCaptureSessionPresetPhoto cameraPosition:AVCaptureDevicePositionBack];
    [videoCamera setOutputImageOrientation:UIInterfaceOrientationPortrait];
    
    dummy = [[GPUImageFilter alloc] init];
    [videoCamera addTarget:dummy];
    [dummy addTarget:viewCamera];
}

- (void)viewWillAppear:(BOOL)animated {
    MPVolumeView *volumeView = [[MPVolumeView alloc] initWithFrame:CGRectMake(-100, 0, 10, 0)];
    [volumeView sizeToFit];
    [self.view addSubview:volumeView];
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(captureByVolume:)
     name:@"AVSystemController_SystemVolumeDidChangeNotification"
     object:nil];
    
    AudioSessionInitialize(NULL, NULL, NULL, NULL);
    AudioSessionSetActive(true);
    
    currentTimer = kTimerNone;
    orientationLast = UIInterfaceOrientationPortrait;
    
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [locationManager startUpdatingLocation];
    [self performSelector:@selector(stopUpdatingLocation:) withObject:nil afterDelay:45];
    
    [locationManager startUpdatingLocation];
    
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    UIAccelerometer* a = [UIAccelerometer sharedAccelerometer];
    a.updateInterval = 1 / kAccelerometerFrequency;
    a.delegate = self;
    
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
}

- (void)viewDidAppear:(BOOL)animated {
    [videoCamera resumeCameraCapture];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        [videoCamera startCameraCapture];
    });
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    
    [locationManager stopUpdatingLocation];
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc removeObserver:self];
    
    UIAccelerometer* a = [UIAccelerometer sharedAccelerometer];
    a.delegate = nil;
    [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
    
    [super viewWillDisappear:animated];
    
    AudioSessionSetActive(false);
    
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    // Save last GPS and Orientation
    [locationManager stopUpdatingLocation];
    UIStoryboard *storyCamera = [UIStoryboard storyboardWithName:@"Camera" bundle:nil];
    
    UIImage *previewPic = [dummy imageFromCurrentlyProcessedOutputWithOrientation:[self imageOrientationFromUI:orientationLast]];

    LXCanvasViewController *controllerCanvas = [storyCamera instantiateViewControllerWithIdentifier:@"Canvas"];
    controllerCanvas.imagePreview = previewPic;
    controllerCanvas.imageSize = previewPic.size;

    
    [videoCamera capturePhotoAsImageProcessedUpToFilter:dummy withCompletionHandler:^(UIImage *processedImage, NSError *error) {
//        [videoCamera pauseCameraCapture];
        [videoCamera stopCameraCapture];
        NSMutableDictionary *imageMeta = [NSMutableDictionary dictionaryWithDictionary:videoCamera.currentCaptureMetadata];
        
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
        
        // Save GPS & Correct orientation
        NSDictionary *location;
        if (bestEffortAtLocation != nil) {
            location = [LXUtils getGPSDictionaryForLocation:bestEffortAtLocation];
            [imageMeta setObject:location forKey:(NSString *)kCGImagePropertyGPSDictionary];
        }
        [dictForTIFF setObject:[NSNumber numberWithInteger:[self exifOrientationFromImage:previewPic.imageOrientation]] forKey:(NSString *)kCGImagePropertyTIFFOrientation];
        [imageMeta setObject:[NSNumber numberWithInteger:[self exifOrientationFromImage:previewPic.imageOrientation]] forKey:(NSString *)kCGImagePropertyOrientation];
        
        // Hardware Name
        UIDeviceHardware *hardware = [[UIDeviceHardware alloc] init];
        [dictForEXIF setObject:stringDate forKey:(NSString *)kCGImagePropertyExifDateTimeDigitized];
        [dictForEXIF setObject:stringDate forKey:(NSString *)kCGImagePropertyExifDateTimeOriginal];
        [dictForTIFF setObject:stringDate forKey:(NSString *)kCGImagePropertyTIFFDateTime];
        [dictForTIFF setObject:@"Apple" forKey:(NSString *)kCGImagePropertyTIFFMake];
        [dictForTIFF setObject:hardware.platformString forKey:(NSString *)kCGImagePropertyTIFFModel];
        
        [imageMeta setObject:dictForEXIF forKey:(NSString *)kCGImagePropertyExifDictionary];
        [imageMeta setObject:dictForTIFF forKey:(NSString *)kCGImagePropertyTIFFDictionary];
        
        processedImage = [UIImage imageWithCGImage:processedImage.CGImage scale:1.0 orientation:previewPic.imageOrientation];
        controllerCanvas.imageFullsize = processedImage;
        controllerCanvas.imageSize = processedImage.size;
        controllerCanvas.imageMeta = imageMeta;
        
        ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
        [library writeImageToSavedPhotosAlbum:processedImage.CGImage metadata:imageMeta completionBlock:^(NSURL *assetURL, NSError *error) {
        }];
    }];
    
    [self.navigationController pushViewController:controllerCanvas animated:NO];
}

- (UIImageOrientation)imageOrientationFromUI:(UIInterfaceOrientation)ui {
    switch (ui) {
        case UIInterfaceOrientationPortrait:
            return UIImageOrientationUp;
        case UIInterfaceOrientationLandscapeLeft:
            return UIImageOrientationRight;
        case UIInterfaceOrientationLandscapeRight:
            return UIImageOrientationLeft;
        case UIInterfaceOrientationPortraitUpsideDown:
            return UIImageOrientationDown;
        default:
            return UIImageOrientationUp;
    }
}

- (NSInteger)exifOrientationFromImage:(UIImageOrientation)orientation {
    switch (orientation) {
        case UIImageOrientationDown:
            return 3;
        case UIImageOrientationUp:
            return 1;
        case UIImageOrientationLeft:
            return 8;
        case UIImageOrientationRight:
            return 6;
        default:
            return 1;
    }
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

- (void)captureByVolume:(id)sender {
    [self capturePhotoAsync];
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

- (IBAction)changeFlash:(id)sender {
    buttonFlash.selected = !buttonFlash.selected;
    buttonFlash35.selected = !buttonFlash35.selected;
    [self setFlash:buttonFlash.selected];
}

- (IBAction)touchTimer:(id)sender {
    // wait for time before begin
    [viewTimer setHidden:!viewTimer.isHidden];
}

- (IBAction)flipCamera:(id)sender {
    isBackCamera = !isBackCamera;
    [videoCamera rotateCamera];
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

- (void)close:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
