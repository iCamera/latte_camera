//
//  luxeysLabelStats.m
//  Latte
//
//  Created by Xuan Dung Bui on 8/22/12.
//  Copyright (c) 2012 LUXEYS. All rights reserved.
//

#import "luxeysLabelStats.h"

@implementation luxeysLabelStats

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    UIImage* imageBg = [[UIImage imageNamed:@"bg_sum.png"] stretchableImageWithLeftCapWidth:10 topCapHeight:0];
    [imageBg drawInRect:rect];
    
    [super drawRect:rect];
}

- (void)drawTextInRect:(CGRect)rect
{
    return [super drawTextInRect:CGRectInset( rect , 10 , 0 )];
}

@end
