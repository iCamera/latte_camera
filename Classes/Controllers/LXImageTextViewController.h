//
//  LXImageTextViewController.h
//  Latte camera
//
//  Created by Bui Xuan Dung on 5/2/13.
//  Copyright (c) 2013 LUXEYS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YIPopupTextView.h"

@protocol LXImageTextDelegate <NSObject>

- (void)newTextImage:(UIImage*)textImage;

@end

@interface LXImageTextViewController : UIViewController <YIPopupTextViewDelegate, UIGestureRecognizerDelegate, UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate>
@property (strong, nonatomic) IBOutlet UIScrollView *scrollTemplate;
@property (strong, nonatomic) IBOutlet UIPageControl *pageControl;
@property (strong, nonatomic) IBOutlet UIImageView *imagePreview;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollCanvas;
@property (strong, nonatomic) UIImage *image;
@property (strong, nonatomic) IBOutlet UIView *viewTextControl;
@property (weak, nonatomic) id<LXImageTextDelegate> delegate;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollColor;
@property (strong, nonatomic) IBOutlet UIButton *buttonDelete;
@property (strong, nonatomic) IBOutlet UIButton *buttonFinishEdit;
@property (strong, nonatomic) IBOutlet UIButton *buttonShadow;
@property (strong, nonatomic) IBOutlet UIView *viewFontControl;
@property (strong, nonatomic) IBOutlet UIButton *buttonCloseFont;
@property (strong, nonatomic) IBOutlet UISlider *slideSize;
@property (strong, nonatomic) IBOutlet UIButton *buttonRotate;


- (IBAction)touchClose:(id)sender;
- (IBAction)touchOK:(id)sender;
- (IBAction)touchEditText:(id)sender;
- (IBAction)touchDoneEdit:(id)sender;
- (IBAction)touchShadow:(id)sender;
- (IBAction)touchDelete:(id)sender;
- (IBAction)touchAddText:(id)sender;
- (IBAction)touchCloseFont:(id)sender;
- (IBAction)touchSelectFont:(id)sender;
- (IBAction)sizeChanged:(id)sender;
- (IBAction)touchResetRotate:(id)sender;
@end
