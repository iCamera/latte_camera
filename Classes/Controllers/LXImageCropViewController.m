//
//  LXImageCropViewController.m
//  Latte camera
//
//  Created by Bui Xuan Dung on 4/25/13.
//  Copyright (c) 2013 LUXEYS. All rights reserved.
//

#import "LXImageCropViewController.h"

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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)panSize:(UIPanGestureRecognizer *)sender {
    CGPoint translation = [sender translationInView:self.view];
    CGRect frame = imageCropSize.frame;
    frame.origin.x += translation.x;
    frame.origin.y += translation.y;
    CGSize size = self.cropSize;
    size.width += translation.x*2;
    size.height += translation.y*2;
    self.cropSize = size;
    imageCropSize.frame = frame;

    [sender setTranslation:CGPointMake(0, 0) inView:self.view];

}
- (void)viewDidUnload {
    [self setImageCropSize:nil];
    [super viewDidUnload];
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
@end
