//
//  UIButton+AsyncImage.m
//  Latte
//
//  Created by Xuan Dung Bui on 2012/09/24.
//  Copyright (c) 2012年 LUXEYS. All rights reserved.
//

#import "UIButton+AsyncImage.h"

@implementation UIButton (AsyncImage)

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
    
    UIProgressView *progess = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
    progess.progressTintColor = [UIColor whiteColor];
    progess.trackTintColor = [UIColor darkGrayColor];
    CGRect frame = self.frame;
    frame.origin.x = 10;
    frame.origin.y = frame.size.height/2-3;
    frame.size.width -= 20;
    
    progess.frame = frame;
    progess.progress = 0;

    if (placeHolder == nil) {
        [self addSubview: progess];
    }

    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]
                                                cachePolicy:NSURLRequestUseProtocolCachePolicy
                                            timeoutInterval:60.0];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    void (^successDownload)(AFHTTPRequestOperation *, id) = ^(AFHTTPRequestOperation *operation, id responseObject) {
        [self setBackgroundImage:[UIImage imageWithData:responseObject] forState:UIControlStateNormal];
        [progess removeFromSuperview];
    };
    
    void (^failDownload)(AFHTTPRequestOperation *, NSError *) = ^(AFHTTPRequestOperation *operation, NSError *error) {
        [progess removeFromSuperview];
    };
    
    [operation setCompletionBlockWithSuccess: successDownload failure: failDownload];
    
    [operation setDownloadProgressBlock:^(NSInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
        progess.progress = (float)totalBytesRead/(float)totalBytesExpectedToRead;
    }];
    
    
    [operation start];
}


@end
