//
//  UIImageView+loadProgress.h
//  Latte
//
//  Created by Xuan Dung Bui on 2012/11/09.
//  Copyright (c) 2012年 LUXEYS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImageView (loadProgress)
- (void)loadProgess:(NSString *)url;
- (void)loadProgess:(NSString *)url placeholderImage:(UIImage*)placeholder;
@end
