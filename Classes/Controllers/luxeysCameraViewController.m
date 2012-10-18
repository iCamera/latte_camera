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

@interface luxeysCameraViewController ()

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
@synthesize buttonTimer;
@synthesize buttonFlash;
@synthesize buttonFlip;
@synthesize buttonCrop;
@synthesize gesturePan;
@synthesize viewBottomBar;
@synthesize imageAutoFocus;
@synthesize buttonPick;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        isEditing = false;
        isCrop = true;
        isReady = false;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupCameraAspect];
    
	// Do any additional setup after loading the view.
    UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:imageBottom.bounds];
	imageBottom.layer.masksToBounds = NO;
	imageBottom.layer.shadowColor = [UIColor blackColor].CGColor;
	imageBottom.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
	imageBottom.layer.shadowOpacity = 1.0f;
	imageBottom.layer.shadowRadius = 2.5f;
	imageBottom.layer.shadowPath = shadowPath.CGPath;
    
    scrollEffect.contentSize=CGSizeMake(500,60);
    
    camera = [[AVCameraManager alloc] initWithView:cameraView];
    
    imagePicker = [[UIImagePickerController alloc]init];
    [imagePicker.navigationBar setBackgroundImage:[UIImage imageNamed: @"bg_head.png"] forBarMetrics:UIBarMetricsDefault];
    imagePicker.delegate = (id)self;
}

- (void)viewWillAppear:(BOOL)animated {
    self.navigationController.navigationBarHidden = YES;
    [self startCamera];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillDisappear:(BOOL)animated
{
    if (!isEditing) {
        [camera pauseCamera];
        [self stopCamera];
    }
    
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

- (void)applyCurrentEffect {
    switch (currentEffect) {
        case 1:
            [camera changeEffect:[FilterManager effect1]];
            break;
        case 2:
            [camera changeEffect:[FilterManager effect2]];
            break;
        case 3:
            [camera changeEffect:[FilterManager effect3]];
            break;
        case 4:
            [camera changeEffect:[FilterManager effect4]];
            break;
        case 5:
            [camera changeEffect:[FilterManager effect5]];
            break;
        default:
            break;
    }
    if (isEditing) {
        [self showStillImage];
    }
}

- (void)showStillImage {
//    imageProcessed = [camera processImage:imageOrg];
    [camera processImage:imageOrg];
}

- (IBAction)setEffect:(id)sender {
    UIButton* buttonEffect = (UIButton*)sender;
    currentEffect = buttonEffect.tag;
    [self applyCurrentEffect];
}


- (void)updateTargetPoint {
//    CGSize size = cameraView.frame.size;
    CGPoint point = CGPointMake(imageAutoFocus.center.x/320.0, (imageAutoFocus.center.y+60.0)/480.0);
    
    [camera setFocusPoint:point];
    [camera setMetteringPoint:point];
}

- (void)capturePhotoAsync {
    [camera.videoCamera capturePhotoAsImageProcessedUpToFilter:(id)camera.pipeline.filters[0] withCompletionHandler:^(UIImage *processedImage, NSError *error) {
        imageOrg = processedImage;
        [self switchEditImage];
        [self showStillImage];
    }];
}

- (void)saveToLibAsync {
//    UIImageWriteToSavedPhotosAlbum(imageProcessed, nil, nil, nil);
}


- (IBAction)cameraTouch:(UITapGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateRecognized) {
        CGPoint location = [sender locationInView:self.cameraView];
        self.imageAutoFocus.center = location;
        
        [self updateTargetPoint];
    }
}

- (IBAction)openImagePicker:(id)sender {
    [self presentViewController:imagePicker animated:NO completion:nil];
}

- (IBAction)close:(id)sender {
    luxeysAppDelegate* app = (luxeysAppDelegate*)[UIApplication sharedApplication].delegate;
    app.window.rootViewController = app.storyMain;
}

- (IBAction)capture:(id)sender {
    if (isReady) {
        buttonPick.hidden = true;
        [self capturePhotoAsync];
    }
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

- (IBAction)changeFlash:(id)sender {
}

- (IBAction)changeCamera:(id)sender {
}

- (IBAction)touchTimer:(id)sender {
    // wait for time before begin
    [viewTimer setHidden:!viewTimer.isHidden];
}

- (IBAction)touchSave:(id)sender {
    [self saveToLibAsync];
    [self performSegueWithIdentifier:@"Edit" sender:self];
}

- (IBAction)toggleCrop:(id)sender {
    isCrop = !isCrop;
    [self setupCameraAspect];
    [camera toggleCrop];
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
    switch (buttonIndex) {
        case 0:
            [camera changeLens:[FilterManager lensNormal]];
            break;
        case 1:
            [camera changeLens:[FilterManager lensTilt]];
            break;
        case 2:
            [camera changeLens:[FilterManager lensFish]];
            break;
            
        default:
            break;
    }
    
    [self applyCurrentEffect];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [imagePicker dismissViewControllerAnimated:NO completion:nil];
    UIImage *imageTmp = [info valueForKey:UIImagePickerControllerOriginalImage];
    imageOrg = [imageTmp fixOrientation];
    
    [self switchEditImage];
    [self applyCurrentEffect];
}

- (void)switchCamera {
    isEditing = NO;
    buttonNo.hidden = YES;
    buttonYes.hidden = YES;
    buttonCapture.hidden = NO;
    buttonFlash.hidden = NO;
    buttonTimer.hidden = NO;
    buttonFlip.hidden = NO;
    buttonCrop.hidden = NO;
    imageAutoFocus.hidden = NO;
    buttonPick.hidden = NO;
    
    if (isReady) {
        [camera resumeCamera];
    } else {
        [self startCamera];
    }

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
    
    if (isReady) {
        [camera pauseCamera];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"Edit"]) {
        luxeysPicEditViewController *controllerPicEdit = segue.destinationViewController;
    }
}

- (IBAction)touchNo:(id)sender {
    [self switchCamera];
}


- (IBAction)flipCamera:(id)sender {
    NSLog(@"Toggle Camera");
    [camera toggleCamera];
}

- (IBAction)panTarget:(UIPanGestureRecognizer *)sender {
    NSLog(@"Pan pan");
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

- (void)handleTap:(UITapGestureRecognizer *)sender {
    NSLog(@"Tapped");
}

- (void)startCamera {
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        [camera startCamera];
        isReady = true;
    });
}

- (void)stopCamera {
    isReady = false;
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        [camera stopCamera];
    });
}
@end
