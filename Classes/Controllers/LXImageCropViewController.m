//
//  LXImageCropViewController.m
//  Latte camera
//
//  Created by Bui Xuan Dung on 4/25/13.
//  Copyright (c) 2013 LUXEYS. All rights reserved.
//

#import "LXImageCropViewController.h"
#import "MBProgressHUD.h"
#import "GPUImageOutput.h"

@interface LXImageCropViewController ()

@end

@implementation LXImageCropViewController {
    CGSize originalSize;
}

@synthesize imageCropSize;

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
    originalSize = CGSizeMake(300.0, 300.0*self.sourceImage.size.height/self.sourceImage.size.width);
    self.cropSize = originalSize;
    self.minimumScale = 0.2;
    self.maximumScale = 10;
    self.checkBounds = YES;
    
    [self reset:NO];
    [super viewWillAppear:YES];
}

- (void)viewWillAppear:(BOOL)animated {
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)panSize:(UIPanGestureRecognizer *)sender {
    _buttonCrop11.selected = NO;
    _buttonCrop34.selected = NO;
    _buttonCrop43.selected = NO;
    _buttonCropNo.selected = NO;
    
    CGPoint translation = [sender translationInView:self.view];
    CGSize size = self.cropSize;
    size.width += translation.x*2;
    size.height += translation.y*2;
    self.cropSize = size;
    
    [sender setTranslation:CGPointMake(0, 0) inView:self.view];

}

- (void)setCropSize:(CGSize)cropSize {
    [super setCropSize:cropSize];
    
    CGPoint center = CGPointMake(self.cropRect.origin.x + self.cropRect.size.width, self.cropRect.origin.y + self.cropRect.size.height);
    imageCropSize.center = center;
}

- (void)viewDidUnload {
    [super viewDidUnload];
}

- (void)startTransformHook {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
}

- (void)endTransformHook {
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}

- (IBAction)setCropRatio:(UIButton*)sender {
    _buttonCrop11.selected = NO;
    _buttonCrop34.selected = NO;
    _buttonCrop43.selected = NO;
    _buttonCropNo.selected = NO;
    sender.selected = YES;
    switch (sender.tag) {
        case 1:
            self.cropSize = CGSizeMake(280, 280);
            [self reset:YES];
            break;
        case 2:
            self.cropSize = CGSizeMake(280, 210);
            [self reset:YES];
            break;
        case 3:
            self.cropSize = CGSizeMake(300, 400);
            [self reset:YES];
            break;
        case 4: {
            self.cropSize = originalSize;
            [self reset:YES];
            break;
        }
        default:
            break;
    }
}

- (IBAction)noCrop:(id)sender {
    self.doneCallback(self.sourceImage, NO);
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}


@end
