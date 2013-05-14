//
//  LXGalleryViewController.h
//  Latte camera
//
//  Created by Bui Xuan Dung on 2/26/13.
//  Copyright (c) 2013 LUXEYS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "STTweetLabel.h"

typedef enum {
    kGalleryTabNone = 0,
    kGalleryTabVote = 1,
    kGalleryTabComment = 2,
    kGalleryTabInfo = 3,
} GalleryTab;

@class Picture, User;

@protocol LXGalleryViewControllerDataSource <NSObject>
@required
- (NSDictionary*)pictureBeforePicture:(Picture *)picture;
- (NSDictionary*)pictureAfterPicture:(Picture *)picture;
@end


@interface LXGalleryViewController : UIViewController <UIPageViewControllerDataSource, UIPageViewControllerDelegate, UIGestureRecognizerDelegate>

@property (weak, nonatomic) id <LXGalleryViewControllerDataSource> delegate;
@property (strong, nonatomic) IBOutlet UIButton *buttonLike;
@property (strong, nonatomic) IBOutlet UIButton *buttonComment;
@property (strong, nonatomic) IBOutlet UIButton *buttonMap;
@property (strong, nonatomic) IBOutlet UIButton *buttonEdit;
@property (strong, nonatomic) IBOutlet UIButton *buttonUser;
@property (strong, nonatomic) IBOutlet UIView *viewTab;
@property (strong, nonatomic) IBOutlet UIView *viewInfoTop;
@property (strong, nonatomic) IBOutlet UIScrollView *viewDesc;
@property (strong, nonatomic) IBOutlet UILabel *labelNickname;
@property (strong, nonatomic) STTweetLabel *labelDesc;
@property (strong, nonatomic) IBOutlet UILabel *labelView;
@property (strong, nonatomic) IBOutlet UILabel *labelLike;
@property (strong, nonatomic) IBOutlet UILabel *labelComment;
@property (strong, nonatomic) IBOutlet UIImageView *imageNationality;

@property (strong, nonatomic) Picture* picture;
@property (strong, nonatomic) User* user;

@property (assign, nonatomic) GalleryTab currentTab;;

- (IBAction)touchClose:(id)sender;
- (IBAction)toggleLike:(UIButton *)sender;
- (IBAction)switchTab:(UIButton *)sender;
- (IBAction)dragTab:(UIPanGestureRecognizer *)sender;
- (IBAction)touchUser:(UIButton *)sender;
- (IBAction)touchShare:(id)sender;


@end
