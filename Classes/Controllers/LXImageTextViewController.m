//
//  LXImageTextViewController.m
//  Latte camera
//
//  Created by Bui Xuan Dung on 5/2/13.
//  Copyright (c) 2013 LUXEYS. All rights reserved.
//

#import "LXImageTextViewController.h"
#import "LXUtils.h"

@interface LXImageTextViewController ()

@end

@implementation LXImageTextViewController {
    UIViewController *template;
}

@synthesize scrollTemplate;
@synthesize pageControl;
@synthesize imagePreview;
@synthesize scrollCanvas;

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
    UIStoryboard *storyCamera = [UIStoryboard storyboardWithName:@"Camera" bundle:nil];
    template = [storyCamera instantiateViewControllerWithIdentifier:@"Template"];
    template.view.backgroundColor = [UIColor clearColor];
    [self addChildViewController:template];
    [scrollTemplate addSubview:template.view];
    [template didMoveToParentViewController:self];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    imagePreview.image = _image;
    CGSize imageSize = _image.size;
    CGRect frame = imagePreview.frame;
    CGFloat frameHeight = [LXUtils heightFromWidth:320 width:imageSize.width height:imageSize.height];
    frame.size.height = frameHeight;
    template.view.frame = CGRectMake(0, 0, 960, frameHeight);
    imagePreview.frame = frame;
    scrollTemplate.frame = frame;
    scrollTemplate.contentSize = template.view.bounds.size;
    scrollCanvas.contentSize = frame.size;
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(keyboardWillShow:) name: UIKeyboardWillShowNotification object:nil];
    [nc addObserver:self selector:@selector(keyboardWillHide:) name: UIKeyboardWillHideNotification object:nil];
    
    [self relayout];
}

- (void)relayout {    
    for (UIView* subView in scrollCanvas.subviews) {
        CGFloat offsetX = (scrollCanvas.bounds.size.width > scrollCanvas.contentSize.width)?
        (scrollCanvas.bounds.size.width - scrollCanvas.contentSize.width) * 0.5 : 0.0;
        
        CGFloat offsetY = (scrollCanvas.bounds.size.height > scrollCanvas.contentSize.height)?
        (scrollCanvas.bounds.size.height - scrollCanvas.contentSize.height) * 0.5 : 0.0;
        
        subView.center = CGPointMake(scrollCanvas.contentSize.width * 0.5 + offsetX,
                                     scrollCanvas.contentSize.height * 0.5 + offsetY);
    }
    
}

- (void)viewWillDisappear:(BOOL)animated {
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [nc removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    
    [super viewWillDisappear:animated];
}

- (void)keyboardWillShow:(NSNotification *)notification
{
    scrollTemplate.scrollEnabled = false;
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGRect frameCanvas = CGRectMake(0, 0, 320, screenRect.size.height - keyboardSize.height);
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationCurve:[[[notification userInfo] objectForKey:UIKeyboardAnimationCurveUserInfoKey] intValue]];
    [UIView setAnimationDuration:[[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue]];
    
    scrollCanvas.frame = frameCanvas;
    [self relayout];
    
    [UIView commitAnimations];
    
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    scrollTemplate.scrollEnabled = true;
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGRect frameCanvas = CGRectMake(0, 0, 320, screenRect.size.height - 50);
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationCurve:[[[notification userInfo] objectForKey:UIKeyboardAnimationCurveUserInfoKey] intValue]];
    [UIView setAnimationDuration:[[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue]];
    
    scrollCanvas.frame = frameCanvas;
    [self relayout];
    
    [UIView commitAnimations];
    
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    int page = scrollView.contentOffset.x/scrollView.frame.size.width;
    pageControl.currentPage=page;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)touchClose:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)touchOK:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
    [_delegate newTextImage:[self exportText]];
}

- (void)viewDidUnload {
    [self setScrollTemplate:nil];
    [self setPageControl:nil];
    [self setImagePreview:nil];
    [self setScrollCanvas:nil];
    [super viewDidUnload];
}
- (IBAction)touchDone:(id)sender {
    [self.view endEditing:YES];
}

- (UIImage*)snapShot:(UIView*)snapView
{
//    [self changeScaleforView:snapView scale:10];
    
    UIGraphicsBeginImageContextWithOptions(snapView.bounds.size, snapView.opaque, 0);
    [snapView.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
//    [self changeScaleforView:snapView scale:1];
    return img;
}

- (void)changeScaleforView:(UIView *)aView scale:(CGFloat)scale
{
    [aView.subviews enumerateObjectsUsingBlock:^void(UIView *v, NSUInteger idx, BOOL *stop)
     {
         if([v isKindOfClass:[UILabel class]]) {
             v.layer.contentsScale = scale;
         } else if([v isKindOfClass:[UITextView class]]) {
             v.layer.contentsScale = scale;
         } else if([v isKindOfClass:[UIImageView class]]) {
             // labels and images
             // v.layer.contentsScale = scale; won't work
             
             // if the image is not "@2x", you could subclass UIImageView and set the name of the @2x
             // on it as a property, then here you would set this imageNamed as the image, then undo it later
         } else
             if([v isMemberOfClass:[UIView class]]) {
                 // container view
                 [self changeScaleforView:v scale:scale];
             }
     } ];
}
- (UIImage *)exportText
{
    return [self snapShot:scrollTemplate];
}
@end
