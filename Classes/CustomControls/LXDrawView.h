//
//  LXDrawView.h
//  Latte
//
//  Created by Xuan Dung Bui on 2012/11/19.
//  Copyright (c) 2012年 LUXEYS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LXDrawView : UIView {
    BOOL isEraser;
    BOOL isEmpty;
}

@property (nonatomic,retain) IBOutlet UIImageView *drawImageView;
@property (nonatomic,retain) UIColor *currentColor;

@property (nonatomic) CGPoint lastPoint;
@property (nonatomic) CGPoint prePreviousPoint;
@property (nonatomic) CGPoint previousPoint;
@property (nonatomic) CGFloat lineWidth;
@property (nonatomic) BOOL isEraser;
@property (assign, nonatomic) BOOL isEmpty;

@end