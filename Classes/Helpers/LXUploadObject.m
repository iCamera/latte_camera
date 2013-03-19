//
//  LXUploadObject.m
//  Latte camera
//
//  Created by Xuan Dung Bui on 2013/03/16.
//  Copyright (c) 2013年 LUXEYS. All rights reserved.
//

#import "LXUploadObject.h"
#import "AFNetworking.h"
#import "LatteAPIClient.h"
#import "LXAppDelegate.h"

@implementation LXUploadObject

- (void)upload {
    void (^createForm)(id<AFMultipartFormData>) = ^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFileData:_imageFile
                                    name:@"file"
                                fileName:@"latte.jpg"
                                mimeType:@"image/jpeg"];
    };
    
    LXAppDelegate* app = (LXAppDelegate*)[UIApplication sharedApplication].delegate;
    
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            [app getToken], @"token",
                            _imageDescription, @"comment",
                            [NSNumber numberWithBool:_showEXIF], @"show_exif",
                            [NSNumber numberWithBool:_showGPS], @"show_gps",
                            [NSNumber numberWithInteger:_status], @"picture_status",
                            nil];

    
    NSURLRequest *request = [[LatteAPIClient sharedClient] multipartFormRequestWithMethod:@"POST"
                                                                                     path:@"picture/upload"
                                                                               parameters:params
                                                                constructingBodyWithBlock:createForm];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    void (^successUpload)(AFHTTPRequestOperation *, id) = ^(AFHTTPRequestOperation *operation, id responseObject) {
        [_delegate uploader:self success:responseObject];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"LXUploaderSuccess" object:self];
        _uploadState = kUploadStateSuccess;
    };
    
    void (^failUpload)(AFHTTPRequestOperation *, NSError *) = ^(AFHTTPRequestOperation *operation, NSError *error) {
        [_delegate uploader:self fail:error];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"LXUploaderFail" object:self];
        _uploadState = kUploadStateFail;
    };
    
    [operation setCompletionBlockWithSuccess: successUpload
                                     failure: failUpload];
    
    [operation setUploadProgressBlock:^(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite) {
        _percent = (float)totalBytesWritten/(float)totalBytesExpectedToWrite;
        [_delegate uploader:self progress:_percent];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"LXUploaderProgress" object:self];
        _uploadState = kUploadStateProgress;
    }];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"LXUploaderStart" object:self];
    [operation start];
}

@end
