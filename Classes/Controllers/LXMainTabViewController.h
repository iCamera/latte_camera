//
//  luxeysTabBarViewController.h
//  Latte
//
//  Created by Xuan Dung Bui on 8/14/12.
//  Copyright (c) 2012 LUXEYS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LXLoginViewController.h"
#import "LXCameraViewController.h"
#import "User.h"
#import "Picture.h"

#define kAnimationDuration .3

@interface LXMainTabViewController : UITabBarController<LXImagePickerDelegate>

@property (strong, nonatomic) NSMutableArray *notifies;

@end
