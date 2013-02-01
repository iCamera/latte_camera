//
//  LXFilterScreenBlend.h
//  Latte camera
//
//  Created by Xuan Dung Bui on 2013/01/28.
//  Copyright (c) 2013年 LUXEYS. All rights reserved.
//

#import "GPUImageTwoInputFilter.h"

@interface LXFilterScreenBlend : GPUImageTwoInputFilter {
    GLint mixUniform;
}

@property(readwrite, nonatomic) CGFloat mix;

@end
