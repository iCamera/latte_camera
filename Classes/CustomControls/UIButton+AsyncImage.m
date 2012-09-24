//
//  UIButton+AsyncImage.m
//  Latte
//
//  Created by Xuan Dung Bui on 2012/09/24.
//  Copyright (c) 2012年 LUXEYS. All rights reserved.
//

#import "UIButton+AsyncImage.h"
#import "UIImageView+AFNetworking.h"

@implementation UIButton (AsyncImage)

- (void)loadBackground:(NSString *)url {
    NSURLRequest *theRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:url]
                                                cachePolicy:NSURLRequestUseProtocolCachePolicy
                                            timeoutInterval:60.0];
    
    UIImageView* imageFirst = [[UIImageView alloc] init];
    [imageFirst setImageWithURLRequest:theRequest
                      placeholderImage:nil
                               success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                   [self setBackgroundImage:image forState:UIControlStateNormal];
                               }
                               failure:nil
     ];
}


@end
