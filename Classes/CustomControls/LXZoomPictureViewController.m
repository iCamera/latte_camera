//
//  LXZoomPictureViewController.m
//  Latte camera
//
//  Created by Bui Xuan Dung on 2/26/13.
//  Copyright (c) 2013 LUXEYS. All rights reserved.
//

#import "LXZoomPictureViewController.h"
#import "UIImageView+loadProgress.h"

#import "AFNetworking.h"
#import "Picture.h"

@interface LXZoomPictureViewController ()

@end

@implementation LXZoomPictureViewController {
    NSMutableArray* zoomLevel;
    
    BOOL loadedOrg;
    BOOL loadedLarge;
    CGFloat actualScale;
    NSInteger currentZoom;
}

@synthesize scrollPicture;
@synthesize imageZoom;


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
    
    CGFloat orgWidth = [_picture.width floatValue];
    CGFloat orgHeight = [_picture.height floatValue];
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
    
    actualScale = MAX(orgWidth/screenWidth, orgHeight/screenHeight)*2.0;

    _progressCircle.progress = 0;
    _progressCircle.hidden = NO;
    [imageZoom loadProgess:_picture.urlMedium withCompletion:^{
        _progressCircle.hidden = YES;
    } progress:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
        _progressCircle.progress = (float)totalBytesRead/(float)totalBytesExpectedToRead;
    }];

    zoomLevel = [[NSMutableArray alloc]init];
    
    [zoomLevel addObject:[NSNumber numberWithFloat:1.0]];
    [zoomLevel addObject:[NSNumber numberWithFloat:2.0]];
    scrollPicture.maximumZoomScale = 4.0;
    if (actualScale > 2.0 && _picture.urlOrg != nil) {
        [zoomLevel addObject:[NSNumber numberWithFloat:actualScale]];
        scrollPicture.maximumZoomScale = actualScale*2.0;
    }
    
    loadedLarge = false;
    loadedOrg = false;
    currentZoom = 0;
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
    
    
    if (scrollView.zoomScale >= 2.0 && !loadedLarge) {
        loadedLarge = true;
        [self loadProgess:_picture.urlLarge];
    } else if (scrollView.zoomScale >= 4.0 && !loadedOrg && actualScale >= 4.0) {
        loadedOrg = true;
        if (_picture.urlOrg) {
            [self loadProgess:_picture.urlOrg];
        }
    }
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
    currentZoom += 1;
    if (currentZoom == zoomLevel.count) {
        currentZoom = 0;
    }
    CGFloat scale = [(NSNumber *)zoomLevel[currentZoom] floatValue];
    [self zoomToPoint:[sender locationInView:imageZoom] withScale:scale animated:YES];
    
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


- (void)loadProgess:(NSString *)url {
    _progessLoad.progress = 0;
    _progessLoad.hidden = NO;
    
    [imageZoom loadProgess:url withCompletion:^(void){
        _progessLoad.hidden = YES;
    } progress:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
        _progessLoad.progress = (float)totalBytesRead/(float)totalBytesExpectedToRead;
    }];
}

@end
