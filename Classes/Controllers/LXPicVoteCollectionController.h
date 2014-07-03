//
//  LXPicVoteCollectionController.h
//  Latte camera
//
//  Created by Bui Xuan Dung on 5/30/14.
//  Copyright (c) 2014 LUXEYS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Picture.h"

@interface LXPicVoteCollectionController : UICollectionViewController

@property (strong, nonatomic) Picture *picture;
@property (assign, nonatomic) BOOL isModal;

@end
