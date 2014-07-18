//
//  LXUploadObject.m
//  Latte camera
//
//  Created by Xuan Dung Bui on 2013/03/16.
//  Copyright (c) 2013年 LUXEYS. All rights reserved.
//

#import "LXUploadObject.h"
#import "AFNetworking.h"
#import "LatteAPIv2Client.h"
#import "LXAppDelegate.h"

@implementation LXUploadObject {
    Picture *picture;
}

- (void)uploadTwitter:(ACAccount*)account {
    // Build a twitter request
    
    SLRequestHandler requestHandler =
    ^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
        if (responseData) {
            NSInteger statusCode = urlResponse.statusCode;
            if (statusCode >= 200 && statusCode < 300) {
                NSDictionary *postResponseData =
                [NSJSONSerialization JSONObjectWithData:responseData
                                                options:NSJSONReadingMutableContainers
                                                  error:NULL];
                NSLog(@"[SUCCESS!] Created Tweet with ID: %@", postResponseData[@"id_str"]);
                [self finishedUpload];
            }
            else {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"LXUploaderFail" object:self];
                _uploadState = kUploadStateFail;
                NSLog(@"[ERROR] Server responded: status code %d %@", statusCode,
                      [NSHTTPURLResponse localizedStringForStatusCode:statusCode]);
            }
        }
        else {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"LXUploaderFail" object:self];
            _uploadState = kUploadStateFail;
            NSLog(@"[ERROR] An error occurred while posting: %@", [error localizedDescription]);
        }
    };
    
    
    NSURL *url = [NSURL URLWithString:@"https://api.twitter.com"
                  @"/1.1/statuses/update_with_media.json"];
    NSDictionary *params = @{@"status" : _imageDescription};
    SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeTwitter
                                            requestMethod:SLRequestMethodPOST
                                                      URL:url
                                               parameters:params];
    
    [request addMultipartData:_imageFile
                     withName:@"media[]"
                         type:@"image/jpeg"
                     filename:@"image.jpg"];
    [request setAccount:account];
    
    // Block handler to manage the response
    [[NSNotificationCenter defaultCenter] postNotificationName:@"LXUploaderStart" object:self];
    [request performRequestWithHandler:requestHandler];
    
}

- (void)uploadLatte {
    void (^createForm)(id<AFMultipartFormData>) = ^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFileData:_imageFile
                                    name:@"file"
                                fileName:@"latte.jpg"
                                mimeType:@"image/jpeg"];
    };
    
    LXAppDelegate* app = (LXAppDelegate*)[UIApplication sharedApplication].delegate;
    
    NSMutableArray *tagsPolish = [[NSMutableArray alloc] init];
    for (NSString *tag in _tags)
        if (tag.length > 0)
            [tagsPolish addObject:tag];
    
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            [app getToken], @"token",
                            _imageDescription, @"comment",
                            [NSNumber numberWithInteger:_showEXIF], @"show_exif",
                            [NSNumber numberWithInteger:_showGPS], @"show_gps",
                            [NSNumber numberWithInteger:_showTakenAt], @"show_taken_at",
                            [NSNumber numberWithInteger:_showLarge], @"show_large",
                            [NSNumber numberWithInteger:_status], @"picture_status",
                            [tagsPolish componentsJoinedByString:@","], @"tags",
                            nil];
    
    LatteAPIv2Client *api = [LatteAPIv2Client sharedClient];
    NSURLRequest *request = [api.requestSerializer multipartFormRequestWithMethod:@"POST"
                                                                        URLString:[[NSURL URLWithString:@"picture" relativeToURL:api.baseURL] absoluteString]
                                                                       parameters:params
                                                        constructingBodyWithBlock:createForm
                                                                            error:nil];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    void (^successUpload)(AFHTTPRequestOperation *, id) = ^(AFHTTPRequestOperation *operation, NSData *data) {
        [self finishedUpload];
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

- (void)upload {
    [self uploadLatte];
}

- (void)finishedUpload {
    LXAppDelegate* app = [LXAppDelegate currentDelegate];
    [app.uploader removeObject:self];
    
    [_delegate uploader:self success:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"LXUploaderSuccess" object:self];
    _uploadState = kUploadStateSuccess;
}

@end
