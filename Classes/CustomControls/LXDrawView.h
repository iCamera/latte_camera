//
//  LXDrawView.h
//  Latte
//
//  Created by Xuan Dung Bui on 2012/11/19.
//  Copyright (c) 2012年 LUXEYS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GPUImage.h"

#define kBackgroundNone 0
#define kBackgroundNatual 1
#define kBackgroundRadial 2

@protocol LXDrawViewDelegate <NSObject>

- (void)newMask:(UIImage*)mask;

@end
@interface LXDrawView : UIView {
    BOOL isEmpty;
    UIBezierPath *aPath;
    id<LXDrawViewDelegate>  __unsafe_unretained delegate;
    UIImage *mask;
    NSInteger backgroundType;
}

@property (unsafe_unretained) id <LXDrawViewDelegate> delegate;

@property (nonatomic,retain) IBOutlet UIImageView *drawImageView;
@property (nonatomic,retain) UIColor *currentColor;

@property (assign, nonatomic) BOOL isEmpty;
@property (assign, nonatomic) CGFloat lineWidth;
@property (assign, nonatomic) NSInteger backgroundType;

- (void)redraw;

@end