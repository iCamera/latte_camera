//
//  LXFBOpenGraph.h
//  Latte camera
//
//  Created by Bui Xuan Dung on 4/22/13.
//  Copyright (c) 2013 LUXEYS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Facebook.h"

@protocol LXOGPhoto<FBGraphObject>

@property (retain, nonatomic) NSString *id;
@property (retain, nonatomic) UIImageView *image;

@end

@protocol LXOGActionUpload<FBOpenGraphAction>

@property (retain, nonatomic) id<LXOGPhoto> photo;

@end

@interface LXFBOpenGraph : NSObject

@end
