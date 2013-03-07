//
//  LXZoomPictureViewController.m
//  Latte camera
//
//  Created by Bui Xuan Dung on 2/26/13.
//  Copyright (c) 2013 LUXEYS. All rights reserved.
//

#import "LXZoomPictureViewController.h"
#import "UIImageView+loadProgress.h"
#import "UIButton+AsyncImage.h"
#import "Picture.h"

@interface LXZoomPictureViewController ()

@end

@implementation LXZoomPictureViewController

@synthesize scrollPicture;
@synthesize labelNickname;
@synthesize imageZoom;
@synthesize buttonUser;

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
    CGRect frame = imageZoom.frame;
    frame.size = [LXUtils newSizeOfPicture:_picture withWidth:320];
    imageZoom.frame = frame;
    imageZoom.center = self.view.center;
    scrollPicture.contentSize = frame.size;
    scrollPicture.maximumZoomScale = 3.0;
    [imageZoom loadProgess:_picture.urlMedium];
    
    labelNickname.text = _user.name;
    [buttonUser loadBackground:_user.profilePicture placeholderImage:@"user.gif"];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
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
    return imageZoom;
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
- (IBAction)tapZoom:(UITapGestureRecognizer *)sender {
    if(scrollPicture.zoomScale > scrollPicture.minimumZoomScale)
        [scrollPicture setZoomScale:scrollPicture.minimumZoomScale animated:YES];
    else
        [self zoomToPoint:[sender locationInView:scrollPicture] withScale:scrollPicture.maximumZoomScale animated:YES];
}

- (void)zoomToPoint:(CGPoint)zoomPoint withScale: (CGFloat)scale animated: (BOOL)animated
{
    //Normalize current content size back to content scale of 1.0f
    CGSize contentSize;
    contentSize.width = (scrollPicture.contentSize.width / scrollPicture.zoomScale);
    contentSize.height = (scrollPicture.contentSize.height / scrollPicture.zoomScale);
    
    //translate the zoom point to relative to the content rect
    zoomPoint.x = (zoomPoint.x / scrollPicture.bounds.size.width) * contentSize.width;
    zoomPoint.y = (zoomPoint.y / scrollPicture.bounds.size.height) * contentSize.height;
    
    //derive the size of the region to zoom to
    CGSize zoomSize;
    zoomSize.width = scrollPicture.bounds.size.width / scale;
    zoomSize.height = scrollPicture.bounds.size.height / scale;
    
    //offset the zoom rect so the actual zoom point is in the middle of the rectangle
    CGRect zoomRect;
    zoomRect.origin.x = zoomPoint.x - zoomSize.width / 2.0f;
    zoomRect.origin.y = zoomPoint.y - zoomSize.height / 2.0f;
    zoomRect.size.width = zoomSize.width;
    zoomRect.size.height = zoomSize.height;
    
    //apply the resize
    [scrollPicture zoomToRect: zoomRect animated: animated];
}



@end
