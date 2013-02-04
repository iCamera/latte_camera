//
//  LXFilterPipe.m
//  Latte camera
//
//  Created by Xuan Dung Bui on 2013/02/04.
//  Copyright (c) 2013年 LUXEYS. All rights reserved.
//

#import "LXFilterPipe.h"

@implementation LXFilterPipe

- (void)_refreshFilters {
    
    id prevFilter = self.input;
    GPUImageFilter *theFilter = nil;
    
    for (int i = 0; i < [self.filters count]; i++) {
        theFilter = [self.filters objectAtIndex:i];
        [prevFilter removeAllTargets];
        [prevFilter addTarget:theFilter atTextureLocation:0];
        prevFilter = theFilter;
    }
    
    [prevFilter removeAllTargets];
    
    if (self.output != nil) {
        [prevFilter addTarget:self.output];
    }
}

@end
