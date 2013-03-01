//
//  LXGalleryViewController.h
//  Latte camera
//
//  Created by Bui Xuan Dung on 2/26/13.
//  Copyright (c) 2013 LUXEYS. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Picture;
@protocol LXGalleryViewControllerDataSource <NSObject>
@required
- (Picture *)pictureBeforePicture:(Picture *)picture;
- (Picture *)pictureAfterPicture:(Picture *)picture;

@end


@interface LXGalleryViewController : UIViewController <UIPageViewControllerDataSource, UIPageViewControllerDelegate>

@property (weak, nonatomic) id <LXGalleryViewControllerDataSource> delegate;
@property (strong, nonatomic) IBOutlet UIButton *buttonLike;
@property (strong, nonatomic) IBOutlet UIButton *buttonComment;
@property (strong, nonatomic) IBOutlet UIButton *buttonMap;

@property (strong, nonatomic) Picture* picture;

- (IBAction)touchClose:(id)sender;
- (IBAction)toggleLike:(UIButton *)sender;


@end
