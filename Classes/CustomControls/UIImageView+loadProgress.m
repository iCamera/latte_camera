//
//  UIImageView+loadProgress.m
//  Latte
//
//  Created by Xuan Dung Bui on 2012/11/09.
//  Copyright (c) 2012年 LUXEYS. All rights reserved.
//

#import "UIImageView+loadProgress.h"
#import <SDWebImage/UIImageView+WebCache.h>

@implementation UIImageView (loadProgress)
- (void)loadProgess:(NSString *)url {
    [self setImageWithURL:[NSURL URLWithString:url] placeholderImage:[[UIImage alloc] init] options:SDWebImageProgressiveDownload];
}
@end
