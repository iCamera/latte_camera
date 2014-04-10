//
//  UIButton+AsyncImage.m
//  Latte
//
//  Created by Xuan Dung Bui on 2012/09/24.
//  Copyright (c) 2012年 LUXEYS. All rights reserved.
//

#import "UIButton+AsyncImage.h"
#import "AFNetworking.h"

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
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]
                                             cachePolicy:NSURLRequestUseProtocolCachePolicy
                                         timeoutInterval:60.0];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    void (^successDownload)(AFHTTPRequestOperation *, id) = ^(AFHTTPRequestOperation *operation, id responseObject) {
        UIImage *loadedImage = [UIImage imageWithData:responseObject];
        [self setBackgroundImage:loadedImage forState:UIControlStateNormal];
    };
    
    
    void (^failDownload)(AFHTTPRequestOperation *, NSError *) = ^(AFHTTPRequestOperation *operation, NSError *error) {
    };
    
    [operation setCompletionBlockWithSuccess: successDownload failure: failDownload];
    
    [operation setDownloadProgressBlock:^(NSUInteger bytesRead, NSInteger totalBytesRead, NSInteger totalBytesExpectedToRead) {
    }];
    
    [operation start];
}


@end
