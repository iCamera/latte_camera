//
//  LXZoomPictureViewController.h
//  Latte camera
//
//  Created by Bui Xuan Dung on 2/26/13.
//  Copyright (c) 2013 LUXEYS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UAProgressView.h"

@class Picture, User;
@interface LXZoomPictureViewController : UIViewController<UIScrollViewDelegate>

@property (strong, nonatomic) IBOutlet UIScrollView *scrollPicture;
@property (strong, nonatomic) IBOutlet UIImageView *imageZoom;
@property (strong, nonatomic) IBOutlet UIProgressView *progessLoad;
@property (weak, nonatomic) IBOutlet UAProgressView *progressCircle;

@property (strong, nonatomic) Picture *picture;
@property (strong, nonatomic) User *user;

- (IBAction)tapZoom:(UITapGestureRecognizer *)sender;

@end
