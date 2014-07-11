//
//  LXGalleryViewController.h
//  Latte camera
//
//  Created by Bui Xuan Dung on 2/26/13.
//  Copyright (c) 2013 LUXEYS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "STTweetLabel.h"

@class Picture, User, LXGalleryViewController;

@protocol LXGalleryViewControllerDataSource <NSObject>

@optional
- (NSDictionary*)pictureBeforePicture:(Picture *)picture;
- (NSDictionary*)pictureAfterPicture:(Picture *)picture;
@end


@interface LXGalleryViewController : UIViewController <UIPageViewControllerDataSource, UIPageViewControllerDelegate, UIActionSheetDelegate>

@property (weak, nonatomic) UIViewController<LXGalleryViewControllerDataSource> *delegate;
@property (strong, nonatomic) IBOutlet UIButton *buttonLike;
@property (strong, nonatomic) IBOutlet UIButton *buttonComment;
@property (strong, nonatomic) IBOutlet UIButton *buttonEdit;
@property (strong, nonatomic) IBOutlet UIButton *buttonUser;
@property (strong, nonatomic) IBOutlet UIView *viewTab;
@property (strong, nonatomic) IBOutlet UIView *viewInfoTop;
@property (strong, nonatomic) IBOutlet UILabel *labelNickname;
@property (strong, nonatomic) STTweetLabel *labelDesc;
@property (strong, nonatomic) IBOutlet UILabel *labelView;
@property (strong, nonatomic) IBOutlet UIImageView *imageNationality;
@property (strong, nonatomic) IBOutlet UIButton *buttonClose;

@property (strong, nonatomic) Picture* picture;
@property (strong, nonatomic) User* user;

- (IBAction)touchClose:(id)sender;
- (IBAction)toggleLike:(UIButton *)sender;
- (IBAction)touchUser:(UIButton *)sender;
- (IBAction)touchShare:(id)sender;


@end
