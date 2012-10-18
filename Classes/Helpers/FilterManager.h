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

@interface FilterManager : NSObject {
    NSMutableArray *filters;
    /*
     0: crop
     1: lens
     2: filter
     */
}

+ (GPUImageFilterGroup *)lensNormal;
+ (GPUImageFilterGroup *)lensTilt;
+ (GPUImageFilterGroup *)lensFish;
+ (GPUImageFilterGroup *)effect1;
+ (GPUImageFilterGroup *)effect2;
+ (GPUImageFilterGroup *)effect3;
+ (GPUImageFilterGroup *)effect4;
+ (GPUImageFilterGroup *)effect5;

@end
