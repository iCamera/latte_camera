//
//  UIButton+AsyncImage.m
//  Latte
//
//  Created by Xuan Dung Bui on 2012/09/24.
//  Copyright (c) 2012年 LUXEYS. All rights reserved.
//

#import "UIButton+AsyncImage.h"
#import "UIButton+AFNetworking.h"
#import "AFHTTPRequestOperation.h"

@interface UIButton (_AsyncImage)
@property (readwrite, nonatomic, strong, setter = af_setBackgroundImageRequestOperation:) AFHTTPRequestOperation *af_backgroundImageRequestOperation;
@end

@implementation UIButton (_AsyncImage)

@dynamic af_backgroundImageRequestOperation;

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
    
//    [operation setDownloadProgressBlock:^(NSUInteger bytesRead, NSInteger totalBytesRead, NSInteger totalBytesExpectedToRead) {
//    }];
    
    [operation start];
}

- (void)loadProgessBackground:(NSString *)url
                     forState:(UIControlState)state
               withCompletion:(void (^)(BOOL isCache))completionBlock
                     progress:(void (^)(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead))progress
             placeholderImage:(UIImage*)placeholderImage {
    [self setBackgroundImageForState:state withURL:[NSURL URLWithString:url] placeholderImage:placeholderImage];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    [request addValue:@"image/*" forHTTPHeaderField:@"Accept"];
    
    __weak __typeof(self)weakSelf = self;
    
    [self setBackgroundImageForState:state withURLRequest:request placeholderImage:placeholderImage success:^(NSHTTPURLResponse *response, UIImage *image) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        
        [strongSelf setBackgroundImage:image forState:state];
        if (response) {
            completionBlock(true);
        } else {
            completionBlock(false);
        }
        
    } failure:^(NSError *error) {
        completionBlock(false);
    }];
    
    [self.af_backgroundImageRequestOperation setDownloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
        progress(bytesRead, totalBytesRead, totalBytesExpectedToRead);
    }];
}


@end
