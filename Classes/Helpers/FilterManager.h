//
//  FilterManager.h
//  Latte
//
//  Created by Xuan Dung Bui on 2012/10/15.
//  Copyright (c) 2012年 LUXEYS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GPUImage.h"
#import "GPUImageOutput.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <ImageIO/ImageIO.h>
#import "LXFilter.h"
#import "LXFilterBlur.h"
#import "LXFilterMono.h"
#import "LXEffect1.h"
#import "LXEffect2.h"
#import "LXEffect3.h"
#import "LXEffect5.h"

@interface FilterManager : NSObject {
//    GPUImageToneCurveFilter *tonecurve;
//    GPUImageRGBFilter *rgb;
//    LXFilterMono *filterMono;
}

+ (GPUImageFilter*)getEffect:(NSInteger)aEffect;

@end
