//
//  GPUImageFilter+saveToLibrary.m
//  Latte camera
//
//  Created by Bui Xuan Dung on 4/3/13.
//  Copyright (c) 2013 LUXEYS. All rights reserved.
//

#import "GPUImageFilter+saveToLibrary.h"
#import <AssetsLibrary/AssetsLibrary.h>

@implementation GPUImageFilter (saveToLibrary)

void dataProviderUnlockCallback (void *info, const void *data, size_t size)
{
    GPUImageFilter *filter = (__bridge_transfer GPUImageFilter*)info;
    
    CVPixelBufferUnlockBaseAddress([filter renderTarget], 0);
    if ([filter renderTarget]) {
        CFRelease([filter renderTarget]);
    }
    
    [filter destroyFilterFBO];
    
    filter.preventRendering = NO;
}

- (void)saveCurrentProcessedImageToLibrary {
    runSynchronouslyOnVideoProcessingQueue(^{
        [GPUImageOpenGLESContext useImageProcessingContext];
        
        CGSize currentFBOSize = [self sizeOfFBO];
        // It appears that the width of a texture must be padded out to be a multiple of 8 (32 bytes) if reading from it using a texture cache
        NSUInteger paddedWidthOfImage = CVPixelBufferGetBytesPerRow(renderTarget) / 4.0;
        NSUInteger paddedBytesForImage = paddedWidthOfImage * (int)currentFBOSize.height * 4;
        
        GLubyte *rawImagePixels;
        
        CGDataProviderRef dataProvider;
        
        glFinish();
        CFRetain(renderTarget); // I need to retain the pixel buffer here and release in the data source callback to prevent its bytes from being prematurely deallocated during a photo write operation
        CVPixelBufferLockBaseAddress(renderTarget, 0);
        self.preventRendering = YES; // Locks don't seem to work, so prevent any rendering to the filter which might overwrite the pixel buffer data until done processing
        rawImagePixels = (GLubyte *)CVPixelBufferGetBaseAddress(renderTarget);
        dataProvider = CGDataProviderCreateWithData((__bridge_retained void*)self, rawImagePixels, paddedBytesForImage, dataProviderUnlockCallback);
        
        ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
        [library writeImageToSavedPhotosAlbum:(CGImageRef)rawImagePixels metadata:nil completionBlock:^(NSURL *assetURL, NSError *error) {
            
        }];
        
        CGDataProviderRelease(dataProvider);
    });
}

@end
