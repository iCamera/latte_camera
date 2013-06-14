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

@implementation LXImageCropViewController

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
    self.cropSize = CGSizeMake(280,280);
    self.minimumScale = 0.2;
    self.maximumScale = 10;
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
    [self setImageCropSize:nil];
    [super viewDidUnload];
}

- (void)startTransformHook {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    //Dealloc to save memory
}

- (void)endTransformHook {
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}

- (IBAction)setCropRatio:(UIButton*)sender {
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
        default:
            break;
    }
}

- (IBAction)doneAction:(id)sender
{
    self.view.userInteractionEnabled = NO;
    [self startTransformHook];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        CGFloat aspect = self.cropSize.height/self.cropSize.width;
        CGSize outputSize = CGSizeMake(self.sourceImage.size.width, self.sourceImage.size.width*aspect);
        
        CGSize scaledImageSizeToFitOnGPU = [GPUImageContext sizeThatFitsWithinATextureForSize:outputSize];
        if (!CGSizeEqualToSize(scaledImageSizeToFitOnGPU, outputSize))
        {
            outputSize = scaledImageSizeToFitOnGPU;
        }
        
        CGImageRef resultFull = [self newTransformedImage:self.imageView.transform
                                             sourceImage:self.sourceImage.CGImage
                                              sourceSize:self.sourceImage.size
                                       sourceOrientation:self.sourceImage.imageOrientation
                                             outputWidth:outputSize.width
                                                cropSize:self.cropSize
                                           imageViewSize:self.imageView.bounds.size];

        dispatch_async(dispatch_get_main_queue(), ^{
            UIImage *ret =  [UIImage imageWithCGImage:resultFull scale:1.0 orientation:UIImageOrientationUp];
            CGImageRelease(resultFull);
            self.view.userInteractionEnabled = YES;
            if(self.doneCallback) {
                self.doneCallback(ret, NO);
            }
            [self endTransformHook];
        });
    });
}

- (CGImageRef)newTransformedImage:(CGAffineTransform)transform
                      sourceImage:(CGImageRef)sourceImage
                       sourceSize:(CGSize)sourceSize
                sourceOrientation:(UIImageOrientation)sourceOrientation
                      outputWidth:(CGFloat)outputWidth
                         cropSize:(CGSize)cropSize
                    imageViewSize:(CGSize)imageViewSize
{
    
    CGFloat aspect = cropSize.height/cropSize.width;
    CGSize outputSize = CGSizeMake(outputWidth, outputWidth*aspect);
    
    CGContextRef context = CGBitmapContextCreate(NULL,
                                                 outputSize.width,
                                                 outputSize.height,
                                                 CGImageGetBitsPerComponent(sourceImage),
                                                 0,
                                                 CGImageGetColorSpace(sourceImage),
                                                 CGImageGetBitmapInfo(sourceImage));
    CGContextSetFillColorWithColor(context,  [[UIColor clearColor] CGColor]);
    CGContextFillRect(context, CGRectMake(0, 0, outputSize.width, outputSize.height));
    
    // Rotate
    CGFloat rotation = 0.0;
    
    switch(sourceOrientation)
    {
        case UIImageOrientationUp: {
            rotation = 0;
        } break;
        case UIImageOrientationDown: {
            rotation = M_PI;
        } break;
        case UIImageOrientationLeft:{
            rotation = -M_PI_2;
            imageViewSize = CGSizeMake(imageViewSize.height, imageViewSize.width);
        } break;
        case UIImageOrientationRight: {
            rotation = M_PI_2;
            imageViewSize = CGSizeMake(imageViewSize.height, imageViewSize.width);
        } break;
        default:
            break;
    }
    
    
    CGAffineTransform uiCoords = CGAffineTransformMakeScale(outputSize.width/cropSize.width,
                                                            outputSize.height/cropSize.height);
    uiCoords = CGAffineTransformTranslate(uiCoords, cropSize.width/2.0, cropSize.height/2.0);
    uiCoords = CGAffineTransformScale(uiCoords, 1.0, -1.0);
    CGContextConcatCTM(context, uiCoords);
    
    CGContextConcatCTM(context, transform);
    CGContextRotateCTM(context,rotation);
    CGContextScaleCTM(context, 1.0, -1.0);
    
    CGContextDrawImage(context, CGRectMake(-imageViewSize.width/2.0,
                                           -imageViewSize.height/2.0,
                                           imageViewSize.width,
                                           imageViewSize.height)
                       ,sourceImage);
    
    CGImageRef resultRef = CGBitmapContextCreateImage(context);
    CGContextRelease(context);
    return resultRef;
}

@end
