//
//  LXCellGrid.m
//  Latte camera
//
//  Created by Bui Xuan Dung on 3/13/13.
//  Copyright (c) 2013 LUXEYS. All rights reserved.
//

#import "LXCellGrid.h"
#import "Picture.h"
#import "UIButton+AsyncImage.h"

@implementation LXCellGrid

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setPictures:(NSArray *)pictures forRow:(NSInteger)row {
    for(UIView *subview in self.contentView.subviews) {
        [subview removeFromSuperview];
    }
    
    for (int i = 0; i < 3; ++i)
    {
        NSInteger index = row*3+i;
        
        Picture *pic;
        if (index >= pictures.count)
            break;
        pic = pictures[index];
        
        
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(6 + 104*i, 3, 100, 100)];
        
        [button loadBackground:pic.urlSquare];
        
        button.layer.masksToBounds = YES;
        button.layer.cornerRadius = 2;
        
        button.tag = index;
        [button addTarget:_viewController action:@selector(showPic:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:button];
    }
}

@end
