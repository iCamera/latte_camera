//
//  LXStreamBrickCell.h
//  Latte camera
//
//  Created by Bui Xuan Dung on 4/4/14.
//  Copyright (c) 2014 LUXEYS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Picture.h"
#import "User.h"
#import "LXGalleryViewController.h"

@interface LXStreamBrickCell : UICollectionViewCell

@property (weak, nonatomic) id <LXGalleryViewControllerDataSource> delegate;
@property (strong, nonatomic) Picture* picture;
@property (strong, nonatomic) User* user;
@property (strong, nonatomic) IBOutlet UIButton *buttonUser;
@property (strong, nonatomic) IBOutlet UILabel *labelUsername;
@property (strong, nonatomic) IBOutlet UILabel *labelView;
@property (strong, nonatomic) IBOutlet UIView *viewBg;

@property (strong, nonatomic) IBOutlet UIButton *buttonPicture;
- (IBAction)touchPicture:(UIButton *)sender;

@end
