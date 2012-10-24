//
//  UINavigationController+autoRotate.h
//  Latte
//
//  Created by Xuan Dung Bui on 2012/10/22.
//  Copyright (c) 2012年 LUXEYS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UINavigationController (autoRotate)
-(BOOL)shouldAutorotate;
- (NSUInteger)supportedInterfaceOrientations;

@end
