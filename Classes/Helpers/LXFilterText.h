//
//  LXFilterText.h
//  Latte camera
//
//  Created by Xuan Dung Bui on 2013/01/16.
//  Copyright (c) 2013年 LUXEYS. All rights reserved.
//

#import "GPUImageTwoInputFilter.h"

@interface LXFilterText : GPUImageTwoInputFilter {
    GLint aspectUniform;
    GLint positionUniform;
    GLint scaleUniform;
}

@property(readwrite, nonatomic) CGPoint position;
@property(readwrite, nonatomic) CGPoint aspect;
@property(readwrite, nonatomic) CGFloat scale;

@end
