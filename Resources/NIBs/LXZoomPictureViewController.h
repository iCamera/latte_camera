//
//  LXZoomPictureViewController.h
//  Latte camera
//
//  Created by Bui Xuan Dung on 2/26/13.
//  Copyright (c) 2013 LUXEYS. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Picture;
@interface LXZoomPictureViewController : UIViewController<UIScrollViewDelegate>
@property (strong, nonatomic) IBOutlet UIScrollView *scrollPicture;
@property (strong, nonatomic) Picture *picture;

@end
