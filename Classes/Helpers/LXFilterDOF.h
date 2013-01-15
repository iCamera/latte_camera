//
//  LXFilterDOF.h
//  Latte camera
//
//  Created by Xuan Dung Bui on 2012/12/20.
//  Copyright (c) 2012年 LUXEYS. All rights reserved.
//

#import "GPUImageTwoInputFilter.h"

@interface LXFilterDOF : GPUImageTwoInputFilter {
    GLint imageWidthFactorUniform, imageHeightFactorUniform;
    GLint aspectratioUniform;
    GLint biasUniform;
    GLint gainUniform;
}

@property(readwrite, nonatomic) CGFloat bias;
@property(readwrite, nonatomic) CGFloat gain;

@end
