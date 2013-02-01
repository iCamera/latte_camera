//
//  GPUImagePicture+updateImage.h
//  Latte camera
//
//  Created by Xuan Dung Bui on 2013/01/28.
//  Copyright (c) 2013年 LUXEYS. All rights reserved.
//

#import "GPUImagePicture.h"

@interface GPUImagePicture (updateImage)
-(void)updateImage:(CGImageRef)newImageSource smoothlyScaleOutput:(BOOL)smoothlyScaleOutput;
@end
