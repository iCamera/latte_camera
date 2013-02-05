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
    for (UIView* subview in self.subviews) {
        [subview removeFromSuperview];
    }
    
    UIImageView *image = [[UIImageView alloc] initWithFrame:self.bounds];
    image.userInteractionEnabled = NO;
    image.exclusiveTouch = NO;
    
    UIActivityIndicatorView *activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    activity.hidesWhenStopped = true;

    CGRect frame = self.frame;
    [activity setCenter:CGPointMake(frame.size.width/2,frame.size.height/2)];
    [activity setContentMode:UIViewContentModeCenter];
    [activity startAnimating];

    if (placeHolder != nil) {
        [image setImage:[UIImage imageNamed:placeHolder]];
    } else {
        [image setBackgroundColor:[UIColor grayColor]];
    }
    [self addSubview:image];
    
    if (placeHolder == nil) {
        [self addSubview: activity];
    }

    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]
                                                cachePolicy:NSURLRequestUseProtocolCachePolicy
                                            timeoutInterval:60.0];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    void (^successDownload)(AFHTTPRequestOperation *, id) = ^(AFHTTPRequestOperation *operation, id responseObject) {
        UIImage *loadedImage = [UIImage imageWithData:responseObject];
        [image setImage:loadedImage];
        image.alpha = 0.0;
        [UIView animateWithDuration:0.3
                         animations:^{
                             image.alpha = 1.0;
                             activity.alpha = 0.0;
                         } completion:^(BOOL finished) {
                         }];
    };

    
    void (^failDownload)(AFHTTPRequestOperation *, NSError *) = ^(AFHTTPRequestOperation *operation, NSError *error) {
        [activity removeFromSuperview];
    };
    
    [operation setCompletionBlockWithSuccess: successDownload failure: failDownload];
    
    [operation setDownloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
    }];
    
    
    [operation start];
}


@end
