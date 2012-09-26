//
//  luxeysCameraViewController.m
//  Latte
//
//  Created by Xuan Dung Bui on 7/20/12.
//  Copyright (c) 2012 LUXEYS. All rights reserved.
//

#import "luxeysCameraViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "luxeysAppDelegate.h"

@interface luxeysCameraViewController () {
    GPUImageFilterPipeline *pipeFilter;
    UIImage *lastFrame;
    UIImageView *lastFrameView;
}

@end

@implementation luxeysCameraViewController
@synthesize scrollEffect;
@synthesize cameraView;
@synthesize viewTimer;
@synthesize imageBottom;
@synthesize sheet;
@synthesize buttonCapture;
@synthesize buttonYes;
@synthesize buttonNo;

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
    
    
	// Do any additional setup after loading the view.
    UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:imageBottom.bounds];
	imageBottom.layer.masksToBounds = NO;
	imageBottom.layer.shadowColor = [UIColor blackColor].CGColor;
	imageBottom.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
	imageBottom.layer.shadowOpacity = 1.0f;
	imageBottom.layer.shadowRadius = 2.5f;
	imageBottom.layer.shadowPath = shadowPath.CGPath;
    
    scrollEffect.contentSize=CGSizeMake(500,60);
    
    videoCamera = [[GPUImageStillCamera alloc] initWithSessionPreset:AVCaptureSessionPresetPhoto cameraPosition:AVCaptureDevicePositionBack];
    [videoCamera setOutputImageOrientation:UIInterfaceOrientationPortrait];
    
    AVCaptureDevice *currentCamera = videoCamera.inputCamera;

    NSError *error = nil;
    if ([currentCamera lockForConfiguration:&error]) {
        NSLog(@"Config");
        
        //currentCamera.focusMode = AVCaptureFocusModeContinuousAutoFocus;
        //currentCamera.exposureMode = AVCaptureExposureModeContinuousAutoExposure;
        currentCamera.whiteBalanceMode = AVCaptureWhiteBalanceModeLocked;
        //currentCamera.flashMode = AVCaptureFlashModeOn;
        //currentCamera.torchMode = AVCaptureTorchModeOn;
        
        [currentCamera unlockForConfiguration];
    }
    
       
    GPUImageCropFilter *lens = [[GPUImageCropFilter alloc] init];
    [lens setCropRegion: CGRectMake(0.0f, 0.125f, 1.0f, 0.75f)];
    
    // Basic filter:
    GPUImageSharpenFilter *filter = [[GPUImageSharpenFilter alloc]init];
    [filter setSharpness:0.5f];
    pipeFilter = [[GPUImageFilterPipeline alloc] initWithOrderedFilters:[NSArray arrayWithObjects: lens, filter, nil]
                                                                  input:videoCamera
                                                                 output:cameraView];
}

- (void)viewWillAppear:(BOOL)animated {
    [videoCamera startCameraCapture];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillDisappear:(BOOL)animated
{
    [videoCamera stopCameraCapture];
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    [super viewWillDisappear:animated];
}

- (void)viewDidUnload {
    [self setCameraView:nil];
    [self setScrollEffect:nil];
    [self setImageAutoFocus:nil];
    [self setImageBottom:nil];
    [self setViewTimer:nil];
    [super viewDidUnload];
}

- (IBAction)setEffect:(id)sender {
    UIButton* buttonEffect = (UIButton*)sender;
    switch (buttonEffect.tag) {
        case 1:
            [self SetEffect1];
            break;
        case 2:
            [self SetEffect2];
            break;
        case 3:
            [self SetEffect3];
            break;
        case 4:
            [self SetEffect4];
            break;
        default:
            break;
    }
    
}

- (void)setLens:(NSInteger)lensIndex  {
    NSLog(@"Lens #%d", lensIndex);
    GPUImageCropFilter *crop = [[GPUImageCropFilter alloc] init];
    GPUImageFilterGroup *lens = [[GPUImageFilterGroup alloc] init];
    GPUImagePinchDistortionFilter *distord = [[GPUImagePinchDistortionFilter alloc]init];
    GPUImageTiltShiftFilter *tilt = [[GPUImageTiltShiftFilter alloc]init];
    
    [crop setCropRegion: CGRectMake(0.0f, 0.125f, 1.0f, 0.75f)];
    [lens setInitialFilters:[NSArray arrayWithObject:crop]];
    [lens addFilter:crop];
    
    switch (lensIndex) {
        case 0: {
            [lens setTerminalFilter:crop];
            break;
        }
            
        case 1: {
            [distord setScale:0.1f];
            
            [crop addTarget: distord];
            [distord addTarget: tilt];
            
            [lens addFilter:distord];
            [lens addFilter:tilt];
            
            [lens setTerminalFilter:tilt];
            break;
        }
            
        case 2: {
            GPUImageCropFilter *crop2 = [[GPUImageCropFilter alloc] init];
            [crop2 setCropRegion: CGRectMake(0.05, 0.05, 0.9, 0.9)];
            
            [distord setScale:-0.2f];
            [distord setRadius:0.75f];
            
            
            [crop addTarget: distord];
            [distord addTarget: crop2];
            
            [lens addFilter:distord];
            [lens addFilter:crop2];
            
            
            [lens setTerminalFilter:crop2];
            break;
        }
        default:
            break;
    }
    
    [pipeFilter replaceFilterAtIndex:0 withFilter:(id)lens];
}


- (IBAction)cameraTouch:(UITapGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateRecognized) {
        CGPoint location = [sender locationInView:self.cameraView];
        AVCaptureDevice *device = videoCamera.inputCamera;
        CGPoint pointOfInterest = CGPointMake(.5f, .5f);
        NSLog(@"taplocation x = %f y = %f", location.x, location.y);
        CGSize frameSize = [[self cameraView] frame].size;
        
        if ([videoCamera cameraPosition] == AVCaptureDevicePositionFront) {
            location.x = frameSize.width - location.x;
        }

        pointOfInterest = CGPointMake(location.y / frameSize.height + 0.125, 1.f - (location.x / frameSize.width));
        NSLog(@"pointofinterest x = %f y = %f", pointOfInterest.x, pointOfInterest.y);
        
        
        if ([device isFocusPointOfInterestSupported] && [device isFocusModeSupported:AVCaptureFocusModeAutoFocus]) {
            NSError *error;
            if ([device lockForConfiguration:&error]) {
                [device setFocusPointOfInterest:pointOfInterest];
                
                [device setFocusMode:AVCaptureFocusModeAutoFocus];
                
                if([device isExposurePointOfInterestSupported] && [device isExposureModeSupported:AVCaptureExposureModeContinuousAutoExposure])
                {
                    
                    [device setExposurePointOfInterest:pointOfInterest];
                    [device setExposureMode:AVCaptureExposureModeContinuousAutoExposure];
                    self.imageAutoFocus.center = location;
                }
                
                [device unlockForConfiguration];
                
                NSLog(@"FOCUS OK");
            } else {
                NSLog(@"ERROR = %@", error);
            }  
        }
    }
}

- (IBAction)openImagePicker:(id)sender {
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc]init];
    imagePicker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    [self presentViewController:imagePicker animated:YES completion:^{
        //
    }];
}

- (IBAction)close:(id)sender {
    luxeysAppDelegate* app = (luxeysAppDelegate*)[UIApplication sharedApplication].delegate;
    [UIView transitionWithView:app.window duration:0.5 options: UIViewAnimationOptionTransitionFlipFromLeft animations:^{
        app.window.rootViewController = app.storyMain;
    } completion:nil];
}

- (IBAction)capture:(id)sender {
    GPUImageFilter* lens = pipeFilter.filters[0];
    lastFrame = [lens imageFromCurrentlyProcessedOutput];
    lastFrameView = [[UIImageView alloc] initWithFrame:cameraView.frame];
    [lastFrameView setImage:lastFrame];
    [self.view addSubview:lastFrameView];
    
//    [videoCamera stopCameraCapture];
    
    cameraView.hidden = true;
    buttonCapture.hidden = true;
    buttonNo.hidden = false;
    buttonYes.hidden = false;
    
/*    [videoCamera capturePhotoAsJPEGProcessedUpToFilter:[pipeFilter.filters objectAtIndex:1] withCompletionHandler:^(NSData *processedJPEG, NSError *error){
        ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
        report_memory(@"After asset library creation");
        
        [library writeImageDataToSavedPhotosAlbum:processedJPEG metadata:nil completionBlock:^(NSURL *assetURL, NSError *error2)
         {
             report_memory(@"After writing to library");
             if (error2) {
                 NSLog(@"ERROR: the image failed to be written");
             }
             else {
                 NSLog(@"PHOTO SAVED - assetURL: %@", assetURL);
             }
			 
             runOnMainQueueWithoutDeadlocking(^{
                 report_memory(@"Operation completed");
                 //[photoCaptureButton setEnabled:YES];
             });
         }];
    }];*/
}

- (IBAction)changeLens:(id)sender {
    sheet = [[UIActionSheet alloc] initWithTitle:@"レンズ交換"
                                        delegate:self
                               cancelButtonTitle:@"キャンセル"
                          destructiveButtonTitle:nil
                               otherButtonTitles:@"Nomal", @"Tilt Shift", @"Fish Eye", nil];
    [sheet setTag:0];
    sheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
    [sheet showInView:self.view];
}

- (IBAction)changeTimer:(id)sender {
    sheet = [[UIActionSheet alloc] initWithTitle:@"タイマー"
                                        delegate:self
                               cancelButtonTitle:@"キャンセル"
                          destructiveButtonTitle:nil
                               otherButtonTitles:@"Single", @"10s", @"10s continuous", nil];
    [sheet setTag:1];
    sheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
    [sheet showInView:self.view];
}

- (IBAction)changeFlash:(id)sender {
}

- (IBAction)changeCamera:(id)sender {
}

- (IBAction)touchTimer:(id)sender {
    // wait for time before begin
    [viewTimer setHidden:!viewTimer.isHidden];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	NSLog(@"Sheet %d Button %d", actionSheet.tag, buttonIndex);
    switch (actionSheet.tag) {
        case 0:
            if (buttonIndex != actionSheet.cancelButtonIndex)
            {
                [self setLens:buttonIndex];
            }
            break;
            
        default:
            break;
    }
}

- (void)SetFilter:(GPUImageFilterGroup*)filter{
    [pipeFilter replaceFilterAtIndex:1 withFilter:(GPUImageFilter*)filter];
}

- (void)SetEffectOrg {
    NSLog(@"Change Effect ORG");
}

- (void)SetEffect1 {
    
    GPUImageExposureFilter *exposure = [[GPUImageExposureFilter alloc] init];
    GPUImageVignetteFilter *vignettefilter = [[GPUImageVignetteFilter alloc] init];
    GPUImageToneCurveFilter *tonecurve = [[GPUImageToneCurveFilter alloc] init];
    
    exposure.exposure = 0.1;
    vignettefilter.vignetteStart = 0.6;
    vignettefilter.vignetteEnd = 0.8;
    [tonecurve setRedControlPoints:[NSArray arrayWithObjects:
                                    [NSValue valueWithCGPoint:CGPointMake(0.0, 0.0)],
                                    [NSValue valueWithCGPoint:CGPointMake(102.0f/255.0f, 90.0f/255.0f)],
                                    [NSValue valueWithCGPoint:CGPointMake(111.0f/255.0f, 108.0f/255.0f)],
                                    [NSValue valueWithCGPoint:CGPointMake(1.0, 1.0)],
                                    nil]];
    [tonecurve setGreenControlPoints:[NSArray arrayWithObjects:
                                      [NSValue valueWithCGPoint:CGPointMake(0.0, 0.0)],
                                      [NSValue valueWithCGPoint:CGPointMake(83.0f/255.0f, 73.0f/255.0f)],
                                      [NSValue valueWithCGPoint:CGPointMake(93.0f/255.0f, 90.0f/255.0f)],
                                      [NSValue valueWithCGPoint:CGPointMake(1.0, 1.0)],
                                      nil]];
    
    [tonecurve setBlueControlPoints:[NSArray arrayWithObjects:
                                     [NSValue valueWithCGPoint:CGPointMake(0.0, 0.0)],
                                     [NSValue valueWithCGPoint:CGPointMake(86.0f/255.0f, 100.0f/255.0f)],
                                     [NSValue valueWithCGPoint:CGPointMake(121.0f/255.0f, 118.0f/255.0f)],
                                     [NSValue valueWithCGPoint:CGPointMake(1.0, 1.0)],
                                     nil]];
    
    [exposure addTarget:tonecurve];
    [tonecurve addTarget:vignettefilter];
    
    GPUImageFilterGroup *blueish = [[GPUImageFilterGroup alloc] init];
    
    [blueish addFilter:exposure];
    [blueish addFilter:tonecurve];
    
    [blueish addFilter:vignettefilter];
    
    [blueish setInitialFilters:[NSArray arrayWithObject:exposure]];
    [blueish setTerminalFilter:vignettefilter];
    
    [self SetFilter:blueish];
    NSLog(@"Change Effect1");
}

- (void)SetEffect4 {
    
    GPUImageExposureFilter *exposure = [[GPUImageExposureFilter alloc] init];
    GPUImageVignetteFilter *vignettefilter = [[GPUImageVignetteFilter alloc] init];
    GPUImageToneCurveFilter *tonecurve = [[GPUImageToneCurveFilter alloc] init];
    
    exposure.exposure = 0.1;
    vignettefilter.vignetteStart = 0.6;
    vignettefilter.vignetteEnd = 0.8;
    [tonecurve setRedControlPoints:[NSArray arrayWithObjects:
                                    [NSValue valueWithCGPoint:CGPointMake(0.0, 0.0)],
                                    [NSValue valueWithCGPoint:CGPointMake(69.0f/255.0f, 69.0f/255.0f)],
                                    [NSValue valueWithCGPoint:CGPointMake(213.0f/255.0f, 218.0f/255.0f)],
                                    [NSValue valueWithCGPoint:CGPointMake(1.0, 1.0)],
                                    nil]];
    [tonecurve setGreenControlPoints:[NSArray arrayWithObjects:
                                      [NSValue valueWithCGPoint:CGPointMake(0.0, 0.0)],
                                      [NSValue valueWithCGPoint:CGPointMake(52.0f/255.0f, 47.0f/255.0f)],
                                      [NSValue valueWithCGPoint:CGPointMake(189.0f/255.0f, 196.0f/255.0f)],
                                      [NSValue valueWithCGPoint:CGPointMake(1.0, 1.0)],
                                      nil]];
    
    [tonecurve setBlueControlPoints:[NSArray arrayWithObjects:
                                     [NSValue valueWithCGPoint:CGPointMake(0.0, 0.0)],
                                     [NSValue valueWithCGPoint:CGPointMake(41.0f/255.0f, 46.0f/255.0f)],
                                     [NSValue valueWithCGPoint:CGPointMake(231.0f/255.0f, 228.0f/255.0f)],
                                     [NSValue valueWithCGPoint:CGPointMake(1.0, 1.0)],
                                     nil]];
    [tonecurve setRGBControlPoints:[NSArray arrayWithObjects:
                                    [NSValue valueWithCGPoint:CGPointMake(0.0, 0.0)],
                                    [NSValue valueWithCGPoint:CGPointMake(23.0f/255.0f, 20.0f/255.0f)],
                                    [NSValue valueWithCGPoint:CGPointMake(157.0f/255.0f, 173.0f/255.0f)],
                                    [NSValue valueWithCGPoint:CGPointMake(1.0, 1.0)],
                                    nil]];
    
    [exposure addTarget:tonecurve];
    [tonecurve addTarget:vignettefilter];
    
    GPUImageFilterGroup *blueish = [[GPUImageFilterGroup alloc] init];
    
    [blueish addFilter:exposure];
    [blueish addFilter:tonecurve];
    
    [blueish addFilter:vignettefilter];
    
    [blueish setInitialFilters:[NSArray arrayWithObject:exposure]];
    [blueish setTerminalFilter:vignettefilter];
    
    [self SetFilter:blueish];
    NSLog(@"Change Effect1");
}

- (void)SetEffect2 {
    GPUImageGrayscaleFilter *gray = [[GPUImageGrayscaleFilter alloc] init];
    
    GPUImageFilterGroup *mono = [[GPUImageFilterGroup alloc] init];
    [mono setInitialFilters:[NSArray arrayWithObject:gray]];
    [mono setTerminalFilter:gray];
    
    [self SetFilter:mono];
    NSLog(@"Change Effect2");
}

- (void)SetEffect3 {
    GPUImageSepiaFilter *sepia = [[GPUImageSepiaFilter alloc] init];
    
    GPUImageFilterGroup *mono = [[GPUImageFilterGroup alloc] init];
    [mono setInitialFilters:[NSArray arrayWithObject:sepia]];
    [mono setTerminalFilter:sepia];

    [self SetFilter:mono];
    NSLog(@"Change Effect3");
}


- (IBAction)touchNo:(id)sender {
    cameraView.hidden = false;
    lastFrameView.hidden = YES;
    buttonNo.hidden = true;
    buttonYes.hidden = true;
    buttonCapture.hidden = false;
}

- (IBAction)touchYes:(id)sender {
}
@end
