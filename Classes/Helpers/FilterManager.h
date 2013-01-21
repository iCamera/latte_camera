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

@interface FilterManager : NSObject {
    NSMutableArray *filters;

    GPUImageToneCurveFilter *tonecurve;
    GPUImageRGBFilter *rgb;
    LXFilter *filter;
    LXFilterMono *filterMono;
}

- (GPUImageFilter*)getEffect:(NSInteger)aEffect;

@end
