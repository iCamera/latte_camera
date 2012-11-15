//
//  UIImageView+loadProgress.m
//  Latte
//
//  Created by Xuan Dung Bui on 2012/11/09.
//  Copyright (c) 2012年 LUXEYS. All rights reserved.
//

#import "UIImageView+loadProgress.h"

@implementation UIImageView (loadProgress)
- (void)loadProgess:(NSString *)url {
    UIProgressView *progess = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
    progess.progressTintColor = [UIColor whiteColor];
    progess.trackTintColor = [UIColor darkGrayColor];
    CGRect frame = self.frame;
    frame.origin.x = 10;
    frame.origin.y = frame.size.height/2-3;
    frame.size.width -= 20;
    
    progess.frame = frame;
    progess.progress = 0;
    
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]
                                             cachePolicy:NSURLRequestUseProtocolCachePolicy
                                         timeoutInterval:60.0];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    void (^successDownload)(AFHTTPRequestOperation *, id) = ^(AFHTTPRequestOperation *operation, id responseObject) {
        [self setImage:[UIImage imageWithData:responseObject]];
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
