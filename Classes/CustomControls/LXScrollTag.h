//
//  LXScrollTag.h
//  Latte camera
//
//  Created by Bui Xuan Dung on 7/15/14.
//  Copyright (c) 2014 LUXEYS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LXScrollTag : UIScrollView

@property (strong, nonatomic) NSArray* followingTags;
@property (strong, nonatomic) NSArray* tags;
@property (weak, nonatomic) id parent;

@end
