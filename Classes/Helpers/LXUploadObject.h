//
//  LXUploadObject.h
//  Latte camera
//
//  Created by Xuan Dung Bui on 2013/03/16.
//  Copyright (c) 2013年 LUXEYS. All rights reserved.
//

#import <Foundation/Foundation.h>

@class  LXUploadObject;

@protocol LXUploadObjectDelegate <NSObject>

- (void)uploader:(LXUploadObject*)upload success:(id)responseObject;
- (void)uploader:(LXUploadObject*)upload fail:(NSError*)error;
- (void)uploader:(LXUploadObject*)upload progress:(float)percent;

@end

@interface LXUploadObject : NSObject

@property (strong, nonatomic) UIImage *imagePreview;
@property (strong, nonatomic) NSData *imageFile;
@property (strong, nonatomic) NSString *imageDescription;
@property (assign, nonatomic) BOOL showEXIF;
@property (assign, nonatomic) BOOL showGPS;
@property (assign, nonatomic) NSInteger status;
@property (readonly, nonatomic) float percent;

@property (weak, nonatomic) id<LXUploadObjectDelegate> delegate;

- (void)upload;

@end
