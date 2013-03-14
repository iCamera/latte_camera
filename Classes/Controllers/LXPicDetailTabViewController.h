//
//  LXPicDetailTabViewController.h
//  Latte camera
//
//  Created by Bui Xuan Dung on 3/6/13.
//  Copyright (c) 2013 LUXEYS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LXPicCommentViewController.h"

@class Picture, User;
@interface LXPicDetailTabViewController : UIViewController
@property (strong, nonatomic) IBOutlet UIScrollView *scrollTab;
@property (strong, nonatomic) LXPicCommentViewController *viewComment;

@property (strong, nonatomic) Picture *picture;
@property (strong, nonatomic) NSDictionary *picDict;
@property (strong, nonatomic) NSMutableArray *comments;

@property (assign, nonatomic) NSInteger tab;

- (void)updateContent;

@end
