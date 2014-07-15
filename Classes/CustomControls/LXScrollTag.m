//
//  LXScrollTag.m
//  Latte camera
//
//  Created by Bui Xuan Dung on 7/15/14.
//  Copyright (c) 2014 LUXEYS. All rights reserved.
//

#import "LXScrollTag.h"

@implementation LXScrollTag

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setTags:(NSArray *)tags {
    CGSize size = CGSizeMake(6, 36);
    for (UIView *subview in self.subviews) {
        [subview removeFromSuperview];
    }
    
    NSInteger idx = 0;
    for (NSString *tag in tags) {
        UIFont *font = [UIFont fontWithName:@"HelveticaNeue-Light" size:12];
        
        CGSize textSize = [tag sizeWithAttributes:@{ NSFontAttributeName : font }];
        
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(size.width, 8, textSize.width + 12, 22)];
        button.titleLabel.font = font;
        [button setTitle:tag forState:UIControlStateNormal];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [button setBackgroundColor:[UIColor colorWithRed:105.0/255.0 green:205.0/255.0 blue:117.0/255.0 alpha:1]];
        button.layer.cornerRadius = 3;
        size.width += textSize.width + 20;
        
        [button addTarget:_parent action:@selector(showNormalTag:) forControlEvents:UIControlEventTouchUpInside];
        button.tag = idx;
        idx += 1;
        [self addSubview:button];
    }
    self.contentSize = size;
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
