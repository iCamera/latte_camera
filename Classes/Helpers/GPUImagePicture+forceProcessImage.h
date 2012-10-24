//
//  GPUImagePicture+forceProcessImage.h
//  Latte
//
//  Created by Xuan Dung Bui on 2012/10/22.
//  Copyright (c) 2012年 LUXEYS. All rights reserved.
//

#import "GPUImagePicture.h"

@interface GPUImagePicture (forceProcessImage)
- (void)updateOrientation:(UIDeviceOrientation)deviceOrientation cameraPosition:(NSInteger)position;
@end
