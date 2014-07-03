//
//  LXGradientView.m
//  Latte camera
//
//  Created by Bui Xuan Dung on 7/1/14.
//  Copyright (c) 2014 LUXEYS. All rights reserved.
//

#import "LXGradientView.h"

@implementation LXGradientView

+ (Class)layerClass {
    return [CAGradientLayer class];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
    }
    return self;
}

- (void)awakeFromNib {
    self.layer.colors = [NSArray arrayWithObjects:(id)[[UIColor clearColor] CGColor], (id)[[UIColor colorWithWhite:0 alpha:0.5] CGColor], nil];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
