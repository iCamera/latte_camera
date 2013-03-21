//
//  LXPicDetailTabViewController.h
//  Latte camera
//
//  Created by Bui Xuan Dung on 3/6/13.
//  Copyright (c) 2013 LUXEYS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LXPicCommentViewController.h"
#import "LXGalleryViewController.h"
#import "LXVoteViewController.h"

@class Picture, User;
@interface LXPicDetailTabViewController : UIViewController
@property (strong, nonatomic) IBOutlet UIScrollView *scrollTab;
@property (strong, nonatomic) LXPicCommentViewController *viewComment;
@property (strong, nonatomic) LXVoteViewController *viewVote;
@property (strong, nonatomic) LXGalleryViewController *parent;

@property (strong, nonatomic) Picture *picture;
@property (strong, nonatomic) NSDictionary *picDict;

@property (assign, nonatomic) NSInteger tab;


@end
