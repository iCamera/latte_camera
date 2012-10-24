//
//  UINavigationController+autoRotate.m
//  Latte
//
//  Created by Xuan Dung Bui on 2012/10/22.
//  Copyright (c) 2012年 LUXEYS. All rights reserved.
//

#import "UINavigationController+autoRotate.h"

@implementation UINavigationController (autoRotate)
-(BOOL)shouldAutorotate {
    return NO;
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}
@end
