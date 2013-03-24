//
//  LXShare.h
//  Latte camera
//
//  Created by Xuan Dung Bui on 2013/01/18.
//  Copyright (c) 2013年 LUXEYS. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <MessageUI/MFMailComposeViewController.h>
#import "REComposeViewController.h"
#import "FacebookSDK.h"

// MY OWN BLOCK
typedef void (^MyCompletionBlock)();

@interface LXShare : NSObject<MFMailComposeViewControllerDelegate, FBLoginViewDelegate, UIAlertViewDelegate, REComposeViewControllerDelegate> 

// BLOCKS
- (void) setCompletionDone:(MyCompletionBlock)blockDone;
- (void) setCompletionCanceled:(MyCompletionBlock)blockCanceled;
- (void) setCompletionFailed:(MyCompletionBlock)blockFailed;
- (void) setCompletionSaved:(MyCompletionBlock)blockSaved;

@property (nonatomic, weak) id controller;

@property (nonatomic, strong) NSString *text;
@property (nonatomic, strong) NSString *url;
@property (nonatomic, strong) NSData *imageData;
@property (nonatomic, strong) UIImage *imagePreview;
@property (nonatomic, strong) NSString *tweetCC;

- (void)facebookPost;
- (void)emailIt;
- (void)tweet;
- (void)inviteFriend;

@end
