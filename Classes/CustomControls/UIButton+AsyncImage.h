//
//  UIButton+AsyncImage.h
//  Latte
//
//  Created by Xuan Dung Bui on 2012/09/24.
//  Copyright (c) 2012年 LUXEYS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIButton (AsyncImage) 
- (void)loadBackground:(NSString*)url;
- (void)loadBackground:(NSString *)url placeholderImage:(NSString *)placeHolder;
- (void)loadBackground:(NSString *)url animated:(BOOL)animated;

@end
