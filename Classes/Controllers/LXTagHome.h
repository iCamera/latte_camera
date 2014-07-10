//
//  LXTagHome.h
//  Latte camera
//
//  Created by Bui Xuan Dung on 6/30/14.
//  Copyright (c) 2014 LUXEYS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LXTagHome : UIViewController

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *constraintHeight;
@property (strong, nonatomic) NSString *tag;
@property (strong, nonatomic) IBOutlet UIView *containerPhoto;
@property (strong, nonatomic) IBOutlet UIView *containerChat;
@property (strong, nonatomic) IBOutlet UILabel *labelSp;
@property (strong, nonatomic) IBOutlet UIButton *buttonFollow;

- (IBAction)panView:(UIPanGestureRecognizer *)sender;
- (IBAction)tapView:(id)sender;
- (IBAction)toggleFollow:(id)sender;


@end
