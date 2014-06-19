//
//  LXTagDiscussionViewController.h
//  Latte camera
//
//  Created by Bui Xuan Dung on 6/10/14.
//  Copyright (c) 2014 LUXEYS. All rights reserved.
//

#import "JSQMessagesViewController.h"
#import "SocketIO.h"

@interface LXTagDiscussionViewController : JSQMessagesViewController<SocketIODelegate>

@property (strong, nonatomic) UIImageView *outgoingBubbleImageView;
@property (strong, nonatomic) UIImageView *incomingBubbleImageView;

@property (strong, nonatomic) NSString *tag;
@property (strong, nonatomic) NSString *conversationHash;

@end
