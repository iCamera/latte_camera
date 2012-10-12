//
//  luxeysTabBarViewController.h
//  Latte
//
//  Created by Xuan Dung Bui on 8/14/12.
//  Copyright (c) 2012 LUXEYS. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface luxeysTabBarViewController : UITabBarController {
    UIView *viewCamera;
}

@property (nonatomic, getter=isTabBarHidden) BOOL tabBarHidden;

@end
