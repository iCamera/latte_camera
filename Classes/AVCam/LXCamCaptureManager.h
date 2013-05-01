//
//  LXCamCaptureManager.h
//  Latte camera
//
//  Created by Bui Xuan Dung on 4/26/13.
//  Copyright (c) 2013 LUXEYS. All rights reserved.
//

#import "AVCamCaptureManager.h"
#import <AssetsLibrary/AssetsLibrary.h>

@protocol LXCamCaptureManagerDelegate <AVCamCaptureManagerDelegate>
@required
- (void) lattePreviewImageCaptured:(UIImage *)image;
- (void) latteStillImageCaptured:(UIImage*)image imageMeta:(NSMutableDictionary*)imageMeta;
@end

@interface LXCamCaptureManager : AVCamCaptureManager<AVCaptureVideoDataOutputSampleBufferDelegate>
@property (nonatomic, weak) id<LXCamCaptureManagerDelegate> delegate;
@property (nonatomic, weak) CLLocation *bestEffortAtLocation;
@end