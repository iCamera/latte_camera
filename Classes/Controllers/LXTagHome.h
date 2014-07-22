//
//  LXTagHome.h
//  Latte camera
//
//  Created by Bui Xuan Dung on 6/30/14.
//  Copyright (c) 2014 LUXEYS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LXGalleryViewController.h"

@interface LXTagHome : UIViewController<UICollectionViewDataSource, UICollectionViewDelegate, LXGalleryViewControllerDataSource>

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *constraintHeight;
@property (strong, nonatomic) NSString *tag;
@property (strong, nonatomic) IBOutlet UIView *containerChat;
@property (strong, nonatomic) IBOutlet UIButton *buttonSp;
@property (strong, nonatomic) IBOutlet UIButton *buttonFollow;
@property (weak, nonatomic) IBOutlet UIButton *buttonGridPhoto;
@property (weak, nonatomic) IBOutlet UIButton *buttonGridFollower;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

- (IBAction)panView:(UIPanGestureRecognizer *)sender;
- (IBAction)tapView:(id)sender;
- (IBAction)toggleFollow:(id)sender;
- (IBAction)touchTab:(UIButton *)sender;
- (IBAction)touchTagInfo:(id)sender;
- (IBAction)toggleHeight:(id)sender;


@end
