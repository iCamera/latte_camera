//
//  LXImageTextViewController.m
//  Latte camera
//
//  Created by Bui Xuan Dung on 5/2/13.
//  Copyright (c) 2013 LUXEYS. All rights reserved.
//

#import "LXImageTextViewController.h"
#import "LXUtils.h"
#import "UIColor+MLPFlatColors.h"
#import "LXCellFont.h"

@interface LXImageTextViewController ()

@end

@implementation LXImageTextViewController {
    UIViewController *template;
    UIView *editingObject;
    UIView *activeTemplate;
    NSMutableArray *fonts;
}

@synthesize scrollTemplate;
@synthesize pageControl;
@synthesize imagePreview;
@synthesize scrollCanvas;
@synthesize viewTextControl;
@synthesize scrollColor;
@synthesize buttonDelete;
@synthesize buttonShadow;
@synthesize viewFontControl;
@synthesize buttonCloseFont;
@synthesize buttonFinishEdit;
@synthesize buttonRotate;
@synthesize viewControlText;
@synthesize viewControlObject;
@synthesize slideSize;
@synthesize slideOpacity;
@synthesize tableFont;
@synthesize buttonFontList;
@synthesize buttonVertical;

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
    template =[ [UIViewController alloc] initWithNibName:@"TextTemplate" bundle:nil];
    template.view.backgroundColor = [UIColor clearColor];
    
    [self addChildViewController:template];
    [scrollTemplate insertSubview:template.view atIndex:0];
    [template didMoveToParentViewController:self];
    for (UIView *dummy in template.view.subviews) {
        for (UIView *viewObject in dummy.subviews) {
            if ([viewObject isKindOfClass:[UILabel class]]) {
                [self addGesture:viewObject];
            }
        }
    }
    activeTemplate = template.view.subviews[0];

    NSArray *colors = [NSArray arrayWithObjects:
                      [UIColor whiteColor],
                      [UIColor blackColor],
                       UIColorFromRGB(0xEEDDB6),
                      [UIColor flatRedColor],
                      [UIColor flatGreenColor],
                      [UIColor flatBlueColor],
                      [UIColor flatTealColor],
                      [UIColor flatPurpleColor],
                      [UIColor flatYellowColor],
                      [UIColor flatOrangeColor],
                      [UIColor flatGrayColor],
                      [UIColor flatWhiteColor],
                      [UIColor flatBlackColor],
                      [UIColor flatDarkRedColor],
                      [UIColor flatDarkGreenColor],
                      [UIColor flatDarkBlueColor],
                      [UIColor flatDarkTealColor],
                      [UIColor flatDarkPurpleColor],
                      [UIColor flatDarkYellowColor],
                      [UIColor flatDarkOrangeColor],
                      [UIColor flatDarkGrayColor],
                      [UIColor flatDarkWhiteColor],
                      [UIColor flatDarkBlackColor],
                      nil];
    for (NSInteger i = 0; i < colors.count; i++) {
        UIButton *buttonColor = [[UIButton alloc] initWithFrame:CGRectMake(i*40+5, 5, 30, 30)];
        buttonColor.backgroundColor = colors[i];
        buttonColor.layer.borderWidth = 2;
        buttonColor.layer.borderColor = [UIColor whiteColor].CGColor;
        buttonColor.layer.cornerRadius = 15;
        buttonColor.layer.masksToBounds = YES;
        buttonColor.showsTouchWhenHighlighted = YES;
        buttonColor.adjustsImageWhenHighlighted = NO;
        [buttonColor addTarget:self action:@selector(setTextColor:) forControlEvents:UIControlEventTouchUpInside];
        [scrollColor addSubview:buttonColor];
    }
    scrollColor.contentSize = CGSizeMake(40*colors.count+10, 44);
    
    [self toggleFontList:buttonFontList];
    
    UIPanGestureRecognizer *panRotate = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panRotateButton:)];
    [buttonRotate addGestureRecognizer:panRotate];
}

- (void)panRotateButton:(UIPanGestureRecognizer*)gesture {
    float adjacent = buttonRotate.transform.tx - editingObject.transform.tx;
    float opposite = buttonRotate.transform.ty - editingObject.transform.ty;
    float distance1 = sqrt(adjacent*adjacent+opposite*opposite);
    
    // Get the location of our touch, this time in the context of the superview.
    CGPoint t = [gesture translationInView:buttonRotate];
    buttonRotate.transform = CGAffineTransformTranslate(buttonRotate.transform, t.x, t.y);
    [gesture setTranslation:CGPointZero inView:buttonRotate];
    
    
    // Set the center to that exact point, We don't need complicated original point translations anymore because we have changed the anchor point.
    //[editingObject setCenter:CGPointMake(location.x, location.y)];
    
    // Rotate our view by the calculated angle around our new anchor point.
    adjacent = buttonRotate.transform.tx - editingObject.transform.tx;
    opposite = buttonRotate.transform.ty - editingObject.transform.ty;
    float distance2 = sqrt(adjacent*adjacent+opposite*opposite);
    
    float angle = atan2f(adjacent, opposite);
    
    CGFloat radians = atan2f(editingObject.transform.b, editingObject.transform.a);
    
//    CGAffineTransform transform = CGAffineTransformMakeTranslation(editingObject.transform.tx, editingObject.transform.ty);
//    transform = CGAffineTransformRotate(transform, -angle);
    editingObject.transform = CGAffineTransformRotate(editingObject.transform, -angle-radians);
    
    if ([editingObject isKindOfClass:[UILabel class]]) {
        CGFloat fontSize = ((UILabel*)editingObject).font.pointSize + (distance2 - distance1);
        if (fontSize > 10) {
            ((UILabel*)editingObject).font = [UIFont fontWithName:((UILabel*)editingObject).font.fontName size:fontSize];
            [self refreshLabel];
        }
    } else {
        CGFloat scale = distance2/distance1;
        editingObject.transform = CGAffineTransformScale(editingObject.transform, scale, scale);
    }

    [self updateControlButtonPosition];
}


- (void)addGesture:(UIView*)view {
    view.userInteractionEnabled = YES;
    view.clipsToBounds = NO;
    
    UITapGestureRecognizer *tapText = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapText:)];
    
    UIPanGestureRecognizer *panText = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panText:)];
    UIPinchGestureRecognizer *pinchText = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchText:)];
    UIRotationGestureRecognizer *rotateText = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(rotateText:)];
    
    panText.delegate = self;
    rotateText.delegate = self;
    pinchText.delegate = self;
    
    [view sizeToFit];
    
    [view addGestureRecognizer:tapText];
    [view addGestureRecognizer:panText];
    [view addGestureRecognizer:rotateText];
    [view addGestureRecognizer:pinchText];
    
    if ([view isKindOfClass:[UILabel class]]) {
        UITapGestureRecognizer *doubleTapText = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTapText:)];
        doubleTapText.numberOfTapsRequired = 2;
        [view addGestureRecognizer:doubleTapText];
        
        ((UILabel*)view).numberOfLines = 0;
        ((UILabel*)view).lineBreakMode = NSLineBreakByCharWrapping;
    }
    
    panText.enabled = NO;
    rotateText.enabled = NO;
    pinchText.enabled = NO;
}

- (void)setTextColor:(UIButton*)button {
    if ([editingObject isKindOfClass:[UILabel class]]) {
        ((UILabel*)editingObject).textColor = button.backgroundColor;
    } else {
        editingObject.backgroundColor = button.backgroundColor;
    }
    
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

- (void)pinchText:(UIPinchGestureRecognizer*)gestureRecognizer {
    static CGFloat lastScale;
    
    if ([gestureRecognizer.view isKindOfClass:[UILabel class]]) {
        if([gestureRecognizer state] == UIGestureRecognizerStateBegan) {
            // Reset the last scale, necessary if there are multiple objects with different scales
            [gestureRecognizer setScale:((UILabel*)editingObject).font.pointSize];
            lastScale = [gestureRecognizer scale];
        }
        
        if ([gestureRecognizer state] == UIGestureRecognizerStateBegan ||
            [gestureRecognizer state] == UIGestureRecognizerStateChanged) {
            
            if ([gestureRecognizer scale] > 9) {
                lastScale = [gestureRecognizer scale];  // Store the previous scale factor for the next pinch gesture call
                UIFont *font = [UIFont fontWithName:((UILabel*)editingObject).font.fontName size:lastScale];
                ((UILabel*)editingObject).font = font;
                
                [self refreshLabel];
                
                [self updateControlButtonPosition];
            }
        }
    } else {
        if([gestureRecognizer state] == UIGestureRecognizerStateBegan) {
            lastScale = [gestureRecognizer scale];
        }
        
        if ([gestureRecognizer state] == UIGestureRecognizerStateBegan ||
            [gestureRecognizer state] == UIGestureRecognizerStateChanged) {
            lastScale = [gestureRecognizer scale];
            
            editingObject.transform = CGAffineTransformScale(editingObject.transform, lastScale, lastScale);
            
            [gestureRecognizer setScale:1];
            [self updateControlButtonPosition];
        }
    }
}

- (void)rotateText:(UIRotationGestureRecognizer*)gestureRecognizer {
    //[self adjustAnchorPointForGestureRecognizer:gestureRecognizer];
    UIView *target = gestureRecognizer.view;
    [self selectView:target];
    if ([gestureRecognizer state] == UIGestureRecognizerStateBegan || [gestureRecognizer state] == UIGestureRecognizerStateChanged) {
        target.transform = CGAffineTransformRotate([target transform], [gestureRecognizer rotation]);
        
        [self updateControlButtonPosition];
        [gestureRecognizer setRotation:0];
    }
}

- (void)updateControlButtonPosition {
    CGAffineTransform t = editingObject.transform;
    
    CGFloat x = (editingObject.bounds.size.width+20)/2.0 * sqrt(t.a * t.a + t.c * t.c);
    CGFloat y = (editingObject.bounds.size.height+20)/2.0 * sqrt(t.b * t.b + t.d * t.d);
    
    CGFloat a = atan2f(editingObject.transform.b, editingObject.transform.a);
    
    CGAffineTransform transformDelete = CGAffineTransformMakeTranslation(-x*cos(a)+y*sin(a), -x*sin(a)-y*cos(a));
    CGAffineTransform transformFinish = CGAffineTransformMakeTranslation(x*cos(a)+y*sin(a), x*sin(a)-y*cos(a));
    CGAffineTransform transformRotate = CGAffineTransformMakeTranslation(-y*sin(a), y*cos(a));
    
    CGFloat basex = editingObject.transform.tx;
    CGFloat basey = editingObject.transform.ty;
    
    buttonDelete.transform = CGAffineTransformTranslate(transformDelete, basex, basey);
    buttonFinishEdit.transform = CGAffineTransformTranslate(transformFinish, basex, basey);
    buttonRotate.transform = CGAffineTransformTranslate(transformRotate, basex, basey);
}

- (void)panText:(UIPanGestureRecognizer*)gestureRecognizer {
    UIView *target = gestureRecognizer.view;
    [self selectView:target];
    CGPoint t = [gestureRecognizer translationInView:target];
    [gestureRecognizer setTranslation:CGPointZero inView:target];
    target.transform = CGAffineTransformTranslate([target transform], t.x, t.y);
    
    [self updateCanvasContentOffset];
    
    [self updateControlButtonPosition];
}

- (void)updateCanvasContentOffset {
    CGRect frame = editingObject.frame;
    CGFloat bottom = frame.origin.y + frame.size.height;
    CGFloat top = frame.origin.y;
    if (top < scrollCanvas.contentOffset.y && scrollCanvas.contentOffset.y >= 0) {
        [scrollCanvas setContentOffset:CGPointMake(0, top) animated:NO];
    }
    
    if (bottom - scrollCanvas.contentOffset.y > scrollCanvas.bounds.size.height && scrollCanvas.contentOffset.y + scrollCanvas.bounds.size.height <= scrollCanvas.contentSize.height) {
        [scrollCanvas setContentOffset:CGPointMake(0, bottom - scrollCanvas.bounds.size.height) animated:NO];
    }
}

- (void)tapText:(UITapGestureRecognizer*)gestureRecognizer {
    [self selectView:gestureRecognizer.view];
}

- (void)doubleTapText:(UITapGestureRecognizer*)gestureRecognizer {
    if ([gestureRecognizer.view isKindOfClass:[UILabel class]]) {
        [self selectView:gestureRecognizer.view];
        [self openEditText];
    }
    
}

- (void)selectView:(UIView*)view {
    if (editingObject != view) {
        if (editingObject) {
            editingObject.layer.borderColor = [UIColor whiteColor].CGColor;
            editingObject.layer.borderWidth = 0;
        }
        
        editingObject = view;
    } else
        return;
    
    editingObject.layer.borderColor = [UIColor whiteColor].CGColor;
    editingObject.layer.borderWidth = 1;
    
    
    [buttonDelete removeFromSuperview];
    [buttonFinishEdit removeFromSuperview];
    [buttonRotate removeFromSuperview];
    
    [activeTemplate addSubview:buttonDelete];
    [activeTemplate addSubview:buttonFinishEdit];
    [activeTemplate addSubview:buttonRotate];
    
    buttonDelete.center = editingObject.center;
    buttonFinishEdit.center = editingObject.center;
    buttonRotate.center = editingObject.center;
    
    [self updateControlButtonPosition];
    
    scrollCanvas.scrollEnabled = NO;
    scrollTemplate.scrollEnabled = NO;
    
    buttonDelete.hidden = NO;
    buttonFinishEdit.hidden = NO;
    buttonRotate.hidden = NO;
    
    buttonShadow.selected = editingObject.layer.shadowOpacity == 1.0;
    
    for (UIView* viewSub in activeTemplate.subviews) {
        for (UIGestureRecognizer* gesture in viewSub.gestureRecognizers) {
            gesture.enabled = YES;
        }
    }
    
    if ([editingObject isKindOfClass:[UILabel class]]) {
        slideSize.value = ((UILabel*)editingObject).font.pointSize;
        viewControlText.hidden = NO;
        viewControlObject.hidden = YES;
        buttonVertical.selected = ((UILabel*)editingObject).tag==1;
    } else {
        viewControlText.hidden = YES;
        viewControlObject.hidden = NO;
        slideOpacity.value = editingObject.alpha;
    }
    
    CGRect screen = [[UIScreen mainScreen] bounds];
    CGRect frameControl = viewTextControl.frame;
    frameControl.origin.y = screen.size.height - 150;
    
    CGRect frameCanvas = scrollCanvas.frame;
    frameCanvas.size.height = screen.size.height - 150;
    
    [UIView animateWithDuration:kGlobalAnimationSpeed animations:^{
        viewTextControl.frame = frameControl;
        scrollCanvas.frame = frameCanvas;
        [self relayout];
        [self updateCanvasContentOffset];
    }];
    
}

- (void)popupTextView:(YIPopupTextView*)textView didDismissWithText:(NSString*)text cancelled:(BOOL)cancelled {
    if (!cancelled) {
        if (text.length == 0) {
            return;
        }
        [((UILabel*)editingObject) setText:text];
        [((UILabel*)editingObject) setTextAlignment:textView.textAlignment];
        [self refreshLabel];
        [self updateControlButtonPosition];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [self relayout];
}

- (void)relayout {
    imagePreview.image = _image;
    CGSize imageSize = _image.size;
    CGRect frame = imagePreview.frame;
    CGFloat frameHeight = [LXUtils heightFromWidth:320 width:imageSize.width height:imageSize.height];
    frame.size.height = frameHeight;
    template.view.frame = CGRectMake(0, 0, 320*8, frameHeight);
    imagePreview.frame = frame;
    scrollTemplate.frame = frame;
    scrollTemplate.contentSize = template.view.bounds.size;
    scrollCanvas.contentSize = frame.size;
    
    for (UIView* subView in scrollCanvas.subviews) {
        CGFloat offsetX = (scrollCanvas.bounds.size.width > scrollCanvas.contentSize.width)?
        (scrollCanvas.bounds.size.width - scrollCanvas.contentSize.width) * 0.5 : 0.0;
        
        CGFloat offsetY = (scrollCanvas.bounds.size.height > scrollCanvas.contentSize.height)?
        (scrollCanvas.bounds.size.height - scrollCanvas.contentSize.height) * 0.5 : 0.0;
        
        subView.center = CGPointMake(scrollCanvas.contentSize.width * 0.5 + offsetX,
                                     scrollCanvas.contentSize.height * 0.5 + offsetY);
    }
    
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    int page = scrollView.contentOffset.x/scrollView.frame.size.width;
    pageControl.currentPage=page;
    activeTemplate = template.view.subviews[page];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)touchClose:(id)sender {
    [self resignAllFocus];
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)touchOK:(id)sender {
    [self resignAllFocus];
    [self dismissModalViewControllerAnimated:YES];
    [_delegate newTextImage:[self exportText]];
}

- (IBAction)touchEditText:(id)sender {
    [self openEditText];
}

- (void)openEditText {
    YIPopupTextView* popupTextView = [[YIPopupTextView alloc] initWithPlaceHolder:@"Sample Text"
                                                                         maxCount:1000
                                                                      buttonStyle:YIPopupTextViewButtonStyleLeftCancelRightDone
                                                                  tintsDoneButton:NO];
    popupTextView.delegate = self;
    popupTextView.textAlignment = ((UILabel*)editingObject).textAlignment;
    popupTextView.font = ((UILabel*)editingObject).font;
    //popupTextView.caretShiftGestureEnabled = YES;   // default = NO
    popupTextView.placeholder = @"Sample Text";
    popupTextView.text = [((UILabel*)editingObject) text];
    //popupTextView.editable = NO;                  // set editable=NO to show without keyboard
    [popupTextView showInView:self.view];
}

- (IBAction)touchDoneEdit:(id)sender {
    [self resignAllFocus];
}

- (IBAction)touchDelete:(id)sender {
    [editingObject removeFromSuperview];
    [self resignAllFocus];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
}

- (IBAction)touchAddText:(id)sender {
    UILabel *newLabel = [[UILabel alloc] init];
    newLabel.font = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:25];
    newLabel.text = @"Sample Text";
    newLabel.layer.shadowOpacity = 1;
    newLabel.center = CGPointMake(activeTemplate.bounds.size.width/2, activeTemplate.bounds.size.height/2);
    newLabel.backgroundColor = [UIColor clearColor];
    newLabel.textColor = [UIColor whiteColor];

    [activeTemplate addSubview:newLabel];
    [self addGesture:newLabel];
    [self selectView:newLabel];
}

- (IBAction)touchCloseFont:(id)sender {
    CGRect frame = viewFontControl.frame;
    frame.origin.x = -frame.size.width;

    [UIView animateWithDuration:kGlobalAnimationSpeed animations:^{
        viewFontControl.frame = frame;
    }];
}

- (IBAction)touchSelectFont:(id)sender {
    slideSize.value = ((UILabel*)editingObject).font.pointSize;
    CGRect frame = viewFontControl.frame;
    frame.origin.x = 0;
    [tableFont reloadData];
    
    [UIView animateWithDuration:kGlobalAnimationSpeed animations:^{
        viewFontControl.frame = frame;
    }];
}

- (IBAction)sizeChanged:(id)sender {
    ((UILabel*)editingObject).font = [UIFont fontWithName:((UILabel*)editingObject).font.fontName size:slideSize.value];
    [self refreshLabel];
    [self updateControlButtonPosition];
}

- (IBAction)touchResetRotate:(id)sender {
    editingObject.transform = CGAffineTransformMakeTranslation(editingObject.transform.tx, editingObject.transform.ty);
    [self updateControlButtonPosition];
}

- (IBAction)opacityChanged:(UISlider*)sender {
    editingObject.alpha = sender.value;
}

- (IBAction)pageChanged:(UIPageControl *)sender {
    [self resignAllFocus];
    activeTemplate = template.view.subviews[sender.currentPage];
    [scrollTemplate setContentOffset:CGPointMake(sender.currentPage*320, 0) animated:YES];
}

- (IBAction)toggleFontList:(UIButton *)sender {
    sender.selected = !sender.selected;
    
    if (sender.selected) {
        fonts = [[NSMutableArray alloc] init];        
        NSArray *fontFamilyNames = [UIFont familyNames];

        for (NSString *familyName in fontFamilyNames)
        {
            NSArray *names = [UIFont fontNamesForFamilyName:familyName];
            for (NSString *name in names) {
                NSDictionary *fontDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                          name, @"title",
                                          name, @"font",
                                          nil];
                [fonts addObject:fontDict];
            }
        
        }
    } else {
        fonts = [[NSMutableArray alloc] init];
        
        
        NSString *path = [[NSBundle mainBundle] pathForResource:@"fonts" ofType:@"plist"];
        NSArray *arrayFonts = [NSArray arrayWithContentsOfFile:path];
        
        for (NSString *fontName in arrayFonts) {
            [fonts addObject:fontName];
        }
    }
    
    [tableFont reloadData];
}

- (IBAction)toggleVertical:(id)sender {
    editingObject.tag = editingObject.tag==0?1:0;
    buttonVertical.selected = !buttonVertical.selected;
    
    [self refreshLabel];
    [self updateControlButtonPosition];
}

- (IBAction)touchShadow:(id)sender {
    editingObject.layer.shadowColor = [UIColor blackColor].CGColor;
    editingObject.layer.shadowOffset = CGSizeZero;
    editingObject.layer.shadowRadius = 2;
    editingObject.layer.shadowOpacity = !editingObject.layer.shadowOpacity;
    buttonShadow.selected = !buttonShadow.selected;
}

- (void)viewDidUnload {
    [self setScrollTemplate:nil];
    [self setPageControl:nil];
    [self setImagePreview:nil];
    [self setScrollCanvas:nil];
    [self setViewTextControl:nil];
    [self setScrollColor:nil];
    [self setButtonDelete:nil];
    [self setButtonShadow:nil];
    [self setViewFontControl:nil];
    [self setButtonCloseFont:nil];
    [self setButtonFinishEdit:nil];
    [self setSlideSize:nil];
    [self setButtonRotate:nil];
    [self setViewControlText:nil];
    [self setViewControlObject:nil];
    [self setSlideOpacity:nil];
    [self setButtonFontList:nil];
    [self setTableFont:nil];
    [self setButtonVertical:nil];
    [super viewDidUnload];
}

- (IBAction)touchDone:(id)sender {
    [self.view endEditing:YES];
}

- (UIImage*)snapShot:(UIView*)snapView
{
//    [self changeScaleforView:snapView scale:10];
    
    UIGraphicsBeginImageContextWithOptions(snapView.bounds.size, NO, 0);
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

- (void)refreshLabel {
    if (editingObject.tag == 0) {
        CGSize textSize = [((UILabel*)editingObject).text
                           sizeWithFont:((UILabel*)editingObject).font
                           constrainedToSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)];
        CGRect frame = editingObject.bounds;
        frame.size = textSize;
        editingObject.bounds = frame;
    } else {
        UILabel *label = (UILabel*)editingObject;
        CGFloat maxWidth = 0;
        for (NSInteger i = 0; i < label.text.length; i++) {
            NSString* chr = [label.text substringWithRange:NSMakeRange(i, 1)];
            CGSize size = [chr sizeWithFont:label.font];
            maxWidth = MAX(maxWidth, size.width);
        }
        label.textAlignment = NSTextAlignmentCenter;
        
        CGSize textSize = [((UILabel*)editingObject).text
                           sizeWithFont:((UILabel*)editingObject).font
                           constrainedToSize:CGSizeMake(maxWidth, CGFLOAT_MAX)
                           lineBreakMode:NSLineBreakByCharWrapping];
        
//        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
//        paragraphStyle.lineHeightMultiple = 1.0;
//        paragraphStyle.lineBreakMode = label.lineBreakMode;
//        paragraphStyle.alignment = label.textAlignment;
//        
//        NSDictionary *attrs = [NSDictionary dictionaryWithObjectsAndKeys:paragraphStyle, NSParagraphStyleAttributeName, nil];
//        
//        NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:label.text attributes:attrs];
//        
//        [label setAttributedText:attributedText];
        
        CGRect frame = editingObject.bounds;
        frame.size = textSize;
        editingObject.bounds = frame;
    }
}

- (void)resignAllFocus {
    buttonDelete.hidden = YES;
    buttonFinishEdit.hidden = YES;
    buttonRotate.hidden = YES;
    
    if (editingObject) {
        editingObject.layer.borderWidth = 0;
    }
    
    for (UIView *viewSub in activeTemplate.subviews) {
        viewSub.layer.borderWidth = 0;
        
        for (UIGestureRecognizer* gesture in viewSub.gestureRecognizers) {
            if (![gesture isKindOfClass:[UITapGestureRecognizer class]]) {
                gesture.enabled = NO;
            }
        }
    }
    
    scrollTemplate.scrollEnabled = YES;
    scrollCanvas.scrollEnabled = YES;
    
    CGRect screen = [[UIScreen mainScreen] bounds];
    CGRect frameControl = viewTextControl.frame;
    frameControl.origin.y = screen.size.height - 50;
    CGRect frameCanvas = scrollCanvas.frame;
    frameCanvas.size.height = screen.size.height - 50;
    
    [UIView animateWithDuration:kGlobalAnimationSpeed animations:^{
        viewTextControl.frame = frameControl;
        scrollCanvas.frame = frameCanvas;
        [self relayout];
    }];
    
//    if (scrollTemplate.bounds.size.height < scrollCanvas.bounds.size.height) {
//        [scrollCanvas setContentOffset:CGPointZero animated:YES];
//    } else
//    if (scrollCanvas.contentOffset.y + scrollCanvas.bounds.size.height > scrollCanvas.contentSize.height) {
//        CGFloat scrollTo = scrollCanvas.contentSize.height - scrollCanvas.bounds.size.height;
//        [scrollCanvas setContentOffset:CGPointMake(0, scrollTo) animated:YES];
//    }
    
    CGRect frame = viewFontControl.frame;
    frame.origin.x = -frame.size.width;
    
    [UIView animateWithDuration:kGlobalAnimationSpeed animations:^{
        viewFontControl.frame = frame;
    }];
    
    editingObject = nil;
}

- (UIImage *)exportText
{
    return [self snapShot:activeTemplate];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return fonts.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Font";
    LXCellFont *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    //cell.labelSample.text =
    cell.labelSample.font = [UIFont fontWithName:fonts[indexPath.row][@"font"] size:22];
    if (fonts[indexPath.row][@"title2"]) {
        cell.labelSample.text = fonts[indexPath.row][@"title2"];
    } else
        cell.labelSample.text = fonts[indexPath.row][@"title"];
    cell.labelFontName.text = fonts[indexPath.row][@"title"];
    if ([((UILabel*)editingObject).font.fontName isEqualToString:fonts[indexPath.row][@"font"]]) {
        [tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
    }
    
    return cell;
}
#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat fontSize = ((UILabel*)editingObject).font.pointSize;
    ((UILabel*)editingObject).font = [UIFont fontWithName:fonts[indexPath.row][@"font"] size:fontSize];
    
    [self refreshLabel];
    [self updateControlButtonPosition];
}

@end
