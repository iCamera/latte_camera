//
//  UIImageView+loadProgress.m
//  Latte
//
//  Created by Xuan Dung Bui on 2012/11/09.
//  Copyright (c) 2012年 LUXEYS. All rights reserved.
//

#import "UIImageView+loadProgress.h"
#import "UIImageView+AFNetworking.h"
#import "AFNetworking.h"

@interface UIImageView (_loadProgress)
@property (readwrite, nonatomic, strong, setter = af_setImageRequestOperation:) AFHTTPRequestOperation *af_imageRequestOperation;
@end

@implementation UIImageView (_loadProgress)

@dynamic af_imageRequestOperation;

- (void)loadProgess:(NSString *)url {
    [self loadProgess:url placeholderImage:nil];
}

- (void)loadProgess:(NSString *)url placeholderImage:(UIImage*)placeholder {
    UIProgressView *progess = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
    progess.progressTintColor = [UIColor whiteColor];
    progess.trackTintColor = [UIColor darkGrayColor];
    CGRect frame = self.frame;
    frame.origin.x = 10;
    frame.origin.y = frame.size.height/2-3;
    frame.size.width -= 20;
    
    progess.frame = frame;
    progess.progress = 0;
    [self addSubview:progess];
    
    [self loadProgess:url withCompletion:^{
        [progess removeFromSuperview];
    } progress:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
        progess.progress = (float)totalBytesRead/(float)totalBytesExpectedToRead;
    } placeholderImage:placeholder];
}

- (void)loadProgess:(NSString *)url
     withCompletion:(void (^)(void))completionBlock
           progress:(void (^)(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead))progress {
    [self loadProgess:url withCompletion:completionBlock progress:progress placeholderImage:nil];
}

- (void)loadProgess:(NSString *)url
     withCompletion:(void (^)(void))completionBlock
           progress:(void (^)(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead))progress
   placeholderImage:(UIImage*)placeholderImage {
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    [request addValue:@"image/*" forHTTPHeaderField:@"Accept"];

    __weak __typeof(self)weakSelf = self;
    [self setImageWithURLRequest:request placeholderImage:placeholderImage success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        
        strongSelf.image = image;
        
        completionBlock();
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
        completionBlock();
    }];
    
    [self.af_imageRequestOperation setDownloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
        progress(bytesRead, totalBytesRead, totalBytesExpectedToRead);
    }];
}

@end
