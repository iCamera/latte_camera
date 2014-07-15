//
//  LXPhotoGridCVC.h
//  Latte camera
//
//  Created by Bui Xuan Dung on 7/16/14.
//  Copyright (c) 2014 LUXEYS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LXGalleryViewController.h"

typedef enum {
    kPhotoGridUserTag,
    kPhotoGridPublicTag,
    kPhotoGridUserLiked,
} PhotoGridKind;

@interface LXPhotoGridCVC : UICollectionViewController<LXGalleryViewControllerDataSource>

@property (strong, nonatomic) NSString *keyword;
@property (assign, nonatomic) NSInteger *userId;

@property (assign, nonatomic) PhotoGridKind gridType;

@end
