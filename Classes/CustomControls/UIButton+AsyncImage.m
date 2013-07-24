//
//  UIButton+AsyncImage.m
//  Latte
//
//  Created by Xuan Dung Bui on 2012/09/24.
//  Copyright (c) 2012年 LUXEYS. All rights reserved.
//

#import "UIButton+AsyncImage.h"
#import <SDWebImage/UIButton+WebCache.h>

@implementation UIButton (AsyncImage)

- (void)loadBackground:(NSString *)url animated:(BOOL)animated {
    [self loadBackground:url placeholderImage:nil];
}

- (void)loadBackground:(NSString *)url {
    [self loadBackground:url placeholderImage:nil];
}

- (void)loadBackground:(NSString *)url placeholderImage:(NSString *)placeHolder {
    if (placeHolder != nil) {
        [self setBackgroundImage:[UIImage imageNamed:placeHolder] forState:UIControlStateNormal];
    } else {
        [self setBackgroundImage:nil forState:UIControlStateNormal];
        [self setBackgroundColor:[UIColor grayColor]];
    }
    
    [self setImageWithURL:[NSURL URLWithString:url] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:placeHolder] options:SDWebImageProgressiveDownload];
}


@end
