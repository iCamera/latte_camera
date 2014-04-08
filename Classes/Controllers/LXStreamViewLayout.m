//
//  LXStreamViewLayout.m
//  Latte camera
//
//  Created by Bui Xuan Dung on 4/4/14.
//  Copyright (c) 2014 LUXEYS. All rights reserved.
//

#import "LXStreamViewLayout.h"

@implementation LXStreamViewLayout

- (id)init
{
    self = [super init];
    if (self) {
        [self setup];
    }
    
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        [self setup];
    }
    
    return self;
}

- (void)setup
{
    self.itemInsets = UIEdgeInsetsMake(6, 6, 6, 6);
    self.itemSize = CGSizeMake(152, 152);
    self.interItemSpacingY = 4;
    self.numberOfColumns = 2;
}

@end
