//
//  LXPicDetailTabViewController.h
//  Latte camera
//
//  Created by Bui Xuan Dung on 3/6/13.
//  Copyright (c) 2013 LUXEYS. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Picture, User;
@interface LXPicDetailTabViewController : UIViewController

@property (strong, nonatomic) IBOutlet UIButton *buttonLike;
@property (strong, nonatomic) IBOutlet UILabel *labelComment;
@property (strong, nonatomic) IBOutlet UILabel *labelLike;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *constraintTab;
@property (assign, nonatomic) NSInteger tab;

- (IBAction)toggleLike:(id)sender;
- (IBAction)touchComment:(id)sender;
- (IBAction)touchInfo:(id)sender;
- (IBAction)closeModal:(id)sender;

@property (strong, nonatomic) Picture *picture;

@end
