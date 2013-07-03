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

@implementation LXUploadObject {
    Picture *picture;
}

- (void)uploadTwitter {
    ACAccountStore *account = [[ACAccountStore alloc] init];
    ACAccountType *accountType = [account accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    
    // Request access from the user to access their Twitter account
    [account requestAccessToAccountsWithType:accountType withCompletionHandler:^(BOOL granted, NSError *error)
     {
         // Did user allow us access?
         if (granted == YES)
         {
             // Populate array with all available Twitter accounts
             NSArray *arrayOfAccounts = [account accountsWithAccountType:accountType];
             
             // Sanity check
             if ([arrayOfAccounts count] > 0)
             {
                 // Keep it simple, use the first account available
                 ACAccount *acct = [arrayOfAccounts objectAtIndex:0];
                 
                 // Build a twitter request
                 TWRequest *postRequest = [[TWRequest alloc] initWithURL:[NSURL URLWithString:@"https://upload.twitter.com/1/statuses/update_with_media.json"] parameters:nil requestMethod:TWRequestMethodPOST];
                 [postRequest addMultiPartData:_imageFile withName:@"media" type:@"image/jpeg"];
                 if (_imageDescription) {
                     [postRequest addMultiPartData:[_imageDescription dataUsingEncoding:NSUTF8StringEncoding] withName:@"status" type:@"text/plain"];
                 }
                 
                 // Post the request
                 [postRequest setAccount:acct];
                 
                 // Block handler to manage the response
                 [[NSNotificationCenter defaultCenter] postNotificationName:@"LXUploaderStart" object:self];
                 
                 [postRequest performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error)
                  {
                      if (error) {
                          [[NSNotificationCenter defaultCenter] postNotificationName:@"LXUploaderFail" object:self];
                          _uploadState = kUploadStateFail;
                      } else {
                          [self finishedUpload];
                      }
                      NSLog(@"Twitter response, HTTP response: %i", [urlResponse statusCode]);
                  }];
             }
         }
     }];
}

- (void)uploadFacebook {
    if (picture.status == PictureStatusPublic) {
        NSMutableDictionary<FBGraphObject> *action = [FBGraphObject graphObject];
        action[@"photo"] = picture.urlWeb;
        action[@"image[0][url]"] = picture.urlLarge;
        action[@"image[0][user_generated]"] = @"true";
        action[@"fb:explicitly_shared"] = @"true";
        if (_imageDescription) {
            action[@"message"] = _imageDescription;
        }
        
        [FBRequestConnection startForPostWithGraphPath:@"me/latte_prod:upload"
                                           graphObject:action
                                     completionHandler:^(FBRequestConnection *connection,
                                                         id result,
                                                         NSError *error) {
                                         if (error) {
                                             [_delegate uploader:self fail:error];
                                             [[NSNotificationCenter defaultCenter] postNotificationName:@"LXUploaderFail" object:self];
                                             _uploadState = kUploadStateFail;
                                             UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"error", @"")
                                                                                             message:error.localizedDescription
                                                                                            delegate:nil cancelButtonTitle:NSLocalizedString(@"close", @"")
                                                                                   otherButtonTitles:nil];
                                             [alert show];
                                         }
                                         else {
                                             [self finishedUpload];
                                         }
                                     }];
    } else {
        NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
        [params setObject:_imageFile forKey:@"picture"];
        if (_imageDescription) {
            [params setObject:_imageDescription forKey:@"message"];
        }
        
        [FBRequestConnection startWithGraphPath:@"me/photos"
                                     parameters:params
                                     HTTPMethod:@"POST"
                              completionHandler:^(FBRequestConnection *connection,
                                                  id result,
                                                  NSError *error) {
                                  if (error) {
                                      [_delegate uploader:self fail:error];
                                      [[NSNotificationCenter defaultCenter] postNotificationName:@"LXUploaderFail" object:self];
                                      _uploadState = kUploadStateFail;
                                      UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"error", @"")
                                                                                      message:error.localizedDescription
                                                                                     delegate:nil cancelButtonTitle:NSLocalizedString(@"close", @"")
                                                                            otherButtonTitles:nil];
                                      [alert show];
                                  }
                                  else {
                                      [self finishedUpload];
                                  }
                              }];
        
    }
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
                            [NSNumber numberWithBool:_showEXIF], @"show_exif",
                            [NSNumber numberWithBool:_showGPS], @"show_gps",
                            [NSNumber numberWithBool:_showTakenAt], @"show_taken_at",
                            [NSNumber numberWithInteger:_status], @"picture_status",
                            [tagsPolish componentsJoinedByString:@","], @"tags",
                            nil];
    
    NSURLRequest *request = [[LatteAPIClient sharedClient] multipartFormRequestWithMethod:@"POST"
                                                                                     path:@"picture/upload"
                                                                               parameters:params
                                                                constructingBodyWithBlock:createForm];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    void (^successUpload)(AFHTTPRequestOperation *, id) = ^(AFHTTPRequestOperation *operation, NSData *data) {
        if (_facebook) {
            NSError *error;
            NSDictionary *JSON = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
            picture = [Picture instanceFromDictionary:JSON[@"pic"]];
            [self uploadFacebook];
        } else {
            [self finishedUpload];
        }
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
    if (_facebook && picture && _uploadState == kUploadStateFail ) {
        [self uploadFacebook];
    } else
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
