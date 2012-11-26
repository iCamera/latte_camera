//
//  LXDrawView.h
//  Latte
//
//  Created by Xuan Dung Bui on 2012/11/19.
//  Copyright (c) 2012年 LUXEYS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GPUImage.h"

@protocol LXDrawViewDelegate <NSObject>

- (void)newMask:(UIImage*)mask;

@end
@interface LXDrawView : UIView {
    BOOL isEmpty;
    UIBezierPath *aPath;
    id<LXDrawViewDelegate>  __unsafe_unretained delegate;
    UIImage *mask;
}

@property (unsafe_unretained) id <LXDrawViewDelegate> delegate;

@property (nonatomic,retain) IBOutlet UIImageView *drawImageView;
@property (nonatomic,retain) UIColor *currentColor;

@property (assign, nonatomic) BOOL isEmpty;
@property (nonatomic) CGFloat lineWidth;

- (void)redraw;

@end