//
//  LXShare.h
//  Latte camera
//
//  Created by Xuan Dung Bui on 2013/01/18.
//  Copyright (c) 2013年 LUXEYS. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <MessageUI/MFMailComposeViewController.h>
#import "FacebookSDK.h"

// MY OWN BLOCK
typedef void (^MyCompletionBlock)();

@interface LXShare : NSObject<MFMailComposeViewControllerDelegate, FBLoginViewDelegate, UIAlertViewDelegate> {
    id controller;
    NSString *title;
    NSString *text;
    NSData *imageData;
    UIImage *imagePreview;
    NSString *tweetCC;

}

// BLOCKS
- (void) setCompletionDone:(MyCompletionBlock)blockDone;
- (void) setCompletionCanceled:(MyCompletionBlock)blockCanceled;
- (void) setCompletionFailed:(MyCompletionBlock)blockFailed;
- (void) setCompletionSaved:(MyCompletionBlock)blockSaved;

@property (nonatomic, retain) id controller;
@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *text;
@property (nonatomic, retain) NSData *imageData;
@property (nonatomic, retain) UIImage *imagePreview;
@property (nonatomic, retain) NSString *tweetCC;

- (void)facebookPost;
- (void)emailIt;
- (void)tweet;

@end
