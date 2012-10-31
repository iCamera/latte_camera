//
//  luxeysCameraViewController.m
//  Latte
//
//  Created by Xuan Dung Bui on 7/20/12.
//  Copyright (c) 2012 LUXEYS. All rights reserved.
//

#import "luxeysCameraViewController.h"
#import "luxeysAppDelegate.h"

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
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setupCameraAspect];
    
    filter = [[FilterManager alloc] init];
    timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(countDown:) userInfo:nil repeats:YES];
    
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
    imageOrientation = UIImageOrientationUp;
    
    imagePicker = [[UIImagePickerController alloc]init];
    [imagePicker.navigationBar setBackgroundImage:[UIImage imageNamed: @"bg_head.png"] forBarMetrics:UIBarMetricsDefault];
    imagePicker.delegate = (id)self;
    
    CGRect screen = [[UIScreen mainScreen] bounds];
    
    if (screen.size.height == 480) {
        CGRect frame = cameraView.frame;
        frame.origin.y = 0;
        cameraView.frame = frame;
    }
    
    // GPS Info
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [locationManager startUpdatingLocation];
    [self performSelector:@selector(stopUpdatingLocation:) withObject:nil afterDelay:45];
    
    currentEffect = 0;
    currentLens = 0;
    currentTimer = kTimerNone;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        [videoCamera startCameraCapture];
        [self applyCurrentEffect];
    });
}

- (void)viewDidAppear:(BOOL)animated {
    [scrollEffect setContentSize:CGSizeMake(400.0, 70)];
    
    [super viewDidAppear:animated];
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
    [videoCamera stopCameraCapture];
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
    
    [super viewDidUnload];
}

- (void)applyCurrentEffect {
    if (isEditing) {
        [filter changeFiltertoLens:currentLens andEffect:currentEffect input:picture output:cameraView isPicture:true];
        [self showStillImage];
    } else {
        [filter changeFiltertoLens:currentLens andEffect:currentEffect input:videoCamera output:cameraView isPicture:false];
    }
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
    
    [picture processImage];
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
}

- (void)capturePhotoAsync {
    [videoCamera capturePhotoAsImageProcessedUpToFilterWithMeta:[filter getCrop] withCompletionHandler:^(UIImage *processedImage, NSMutableDictionary *meta, NSError *error) {
        [videoCamera stopCameraCapture];
        
        imageMeta = meta;
        imageOrientation = processedImage.imageOrientation;
        picture = [[GPUImagePicture alloc] initWithImage:processedImage];
        
        [self switchEditImage];
        [self applyCurrentEffect];
        
    }];
}

- (IBAction)cameraTouch:(UITapGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateRecognized) {
        CGPoint location = [sender locationInView:self.cameraView];
        self.imageAutoFocus.center = location;
        
        [self updateTargetPoint];
    }
}

- (IBAction)openImagePicker:(id)sender {
    if (!isEditing) {
        [videoCamera stopCameraCapture];
        [filter clearTargetWithCamera:videoCamera andPicture:picture];
    }
    
    [self presentViewController:imagePicker animated:NO completion:nil];
}

- (IBAction)close:(id)sender {
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (IBAction)capture:(id)sender {
    buttonPick.hidden = true;
    [self capturePhotoAsync];
}

- (IBAction)changeLens:(id)sender {
    sheet = [[UIActionSheet alloc] initWithTitle:@"レンズ交換"
                                        delegate:self
                               cancelButtonTitle:@"キャンセル"
                          destructiveButtonTitle:nil
                               otherButtonTitles:@"普通", @"チルトシフト", @"魚眼レンズ", nil];
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

- (IBAction)toggleEffect:(id)sender {
    scrollEffect.hidden = !scrollEffect.hidden;
    buttonScroll.selected = !scrollEffect.hidden;
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
            [self performSegueWithIdentifier:@"Edit" sender:uploadData];
        } else {
            [self switchCamera];
        }
    };
    
    [picture processImage];
    [filter saveImage:location orientation:imageOrientation withMeta:imageMeta onComplete:saveImage];
}

- (void)setupCameraAspect {
    [cameraView removeConstraint:cameraAspect];
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
    
    cameraAspect.priority = 400;
    [cameraView addConstraint:cameraAspect];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 3)
        return;
    
    currentLens = buttonIndex;

    [self applyCurrentEffect];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    imageMeta = [NSMutableDictionary dictionaryWithDictionary:[info valueForKey:UIImagePickerControllerMediaMetadata]];
    UIImage *image = [info valueForKey:UIImagePickerControllerOriginalImage];
    imageOrientation = image.imageOrientation;
    
    picture = [[GPUImagePicture alloc] initWithImage:image];
    [imagePicker dismissViewControllerAnimated:NO completion:nil];
    
    [self switchEditImage];
    [self applyCurrentEffect];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:NO completion:nil];
    [self switchCamera];
}

- (void)switchCamera {
    isEditing = NO;
    
    picture = nil;
    [videoCamera startCameraCapture];
    imageOrientation = UIImageOrientationUp;
    [self applyCurrentEffect];
    [cameraView setInputRotation:kGPUImageNoRotation atIndex:0];
    
    buttonNo.hidden = YES;
    buttonYes.hidden = YES;
    buttonCapture.hidden = NO;
    buttonFlash.hidden = NO;
    buttonTimer.hidden = NO;
    buttonFlip.hidden = NO;
    buttonCrop.hidden = NO;
    imageAutoFocus.hidden = NO;
    buttonPick.hidden = NO;
}

- (void)switchEditImage {
    isEditing = YES;
    buttonCapture.hidden = YES;
    buttonNo.hidden = NO;
    buttonYes.hidden = NO;
    buttonFlash.hidden = YES;
    buttonTimer.hidden = YES;
    buttonFlip.hidden = YES;
    buttonCrop.hidden = YES;
    imageAutoFocus.hidden = YES;
    viewTimer.hidden = YES;
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
        [timer invalidate];
        [self capturePhotoAsync];
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

@end
