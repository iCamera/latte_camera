//
//  LXTagDiscussionViewController.h
//  Latte camera
//
//  Created by Bui Xuan Dung on 6/10/14.
//  Copyright (c) 2014 LUXEYS. All rights reserved.
//

#import "JSQMessagesViewController.h"

@interface LXTagDiscussionViewController : JSQMessagesViewController<UIActionSheetDelegate>

@property (strong, nonatomic) UIImageView *outgoingBubbleImageView;
@property (strong, nonatomic) UIImageView *incomingBubbleImageView;

@property (strong, nonatomic) NSString *tag;
@property (strong, nonatomic) NSString *conversationHash;

@property (strong, nonatomic) NSMutableArray *messages;
- (IBAction)touchPhoto:(id)sender;

@end
