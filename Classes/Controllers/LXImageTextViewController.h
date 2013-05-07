//
//  LXImageTextViewController.h
//  Latte camera
//
//  Created by Bui Xuan Dung on 5/2/13.
//  Copyright (c) 2013 LUXEYS. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LXImageTextDelegate <NSObject>

- (void)newTextImage:(UIImage*)textImage;

@end

@interface LXImageTextViewController : UIViewController
@property (strong, nonatomic) IBOutlet UIScrollView *scrollTemplate;
@property (strong, nonatomic) IBOutlet UIPageControl *pageControl;
@property (strong, nonatomic) IBOutlet UIImageView *imagePreview;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollCanvas;
@property (strong, nonatomic) UIImage *image;
@property (weak, nonatomic) id<LXImageTextDelegate> delegate;
- (IBAction)touchDone:(id)sender;
- (IBAction)touchClose:(id)sender;
- (IBAction)touchOK:(id)sender;
@end
