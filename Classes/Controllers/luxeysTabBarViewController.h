//
//  luxeysTabBarViewController.h
//  Latte
//
//  Created by Xuan Dung Bui on 8/14/12.
//  Copyright (c) 2012 LUXEYS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "luxeysSideMenuViewController.h"
#import "luxeysLoginViewController.h"
#import "luxeysCameraViewController.h"

#define kAnimationDuration .3

@interface luxeysTabBarViewController : UITabBarController<LXImagePickerDelegate> {
    UIView *viewCamera;
    BOOL isFirst;
}

@property (nonatomic, getter=isTabBarHidden) BOOL tabBarHidden;

@end
