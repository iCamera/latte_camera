//
//  LXZoomPictureViewController.m
//  Latte camera
//
//  Created by Bui Xuan Dung on 2/26/13.
//  Copyright (c) 2013 LUXEYS. All rights reserved.
//

#import "LXZoomPictureViewController.h"
#import "UIImageView+loadProgress.h"
#import "Picture.h"

@interface LXZoomPictureViewController ()

@end

@implementation LXZoomPictureViewController {
    UIImageView *image;
}

@synthesize scrollPicture;

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
    CGRect frame;
    frame.origin = CGPointMake(0, 0);
    frame.size = [LXUtils newSizeOfPicture:_picture withWidth:320];
    image = [[UIImageView alloc]initWithFrame:frame];
    [image loadProgess:_picture.urlMedium];
    [scrollPicture addSubview:image];
    scrollPicture.maximumZoomScale = 5.0;
    scrollPicture.contentSize = frame.size;
    // Do any additional setup after loading the view from its nib.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    image.center = scrollPicture.center;
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

-(UIView *) viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return image;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setScrollPicture:nil];
    [super viewDidUnload];
}
@end
