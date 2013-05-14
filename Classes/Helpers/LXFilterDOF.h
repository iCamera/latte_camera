//
//  LXFilterDOF.h
//  Latte camera
//
//  Created by Xuan Dung Bui on 2012/12/20.
//  Copyright (c) 2012年 LUXEYS. All rights reserved.
//

#import "GPUImageTwoInputFilter.h"

@interface LXFilterDOF : GPUImageFilter

@property(readwrite, nonatomic) CGFloat bias;
@property(readwrite, nonatomic) CGFloat gain;
@property(readwrite, nonatomic) BOOL dofEnable;
@property(readwrite, nonatomic) UIImage* imageDOF;

@end
