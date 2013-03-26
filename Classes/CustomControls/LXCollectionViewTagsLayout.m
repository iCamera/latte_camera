//
//  LXCollectionViewTagsLayout.m
//  Latte camera
//
//  Created by Bui Xuan Dung on 3/26/13.
//  Copyright (c) 2013 LUXEYS. All rights reserved.
//

#import "LXCollectionViewTagsLayout.h"

@implementation LXCollectionViewTagsLayout


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
    self.itemInsets = UIEdgeInsetsMake(22.0f, 22.0f, 13.0f, 22.0f);
    self.itemSize = CGSizeMake(125.0f, 125.0f);
    self.interItemSpacingY = 12.0f;
    self.numberOfColumns = 2;
}

@end
