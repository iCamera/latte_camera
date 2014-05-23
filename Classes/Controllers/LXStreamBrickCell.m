//
//  LXStreamBrickCell.m
//  Latte camera
//
//  Created by Bui Xuan Dung on 4/4/14.
//  Copyright (c) 2014 LUXEYS. All rights reserved.
//

#import "LXStreamBrickCell.h"
#import "UIButton+AFNetworking.h"
#import "UIImageView+AFNetworking.h"
#import "Picture.h"

@implementation LXStreamBrickCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
    }
    
    return self;
}

- (void)awakeFromNib {
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = _viewBg.bounds;
    gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor clearColor] CGColor], (id)[[UIColor colorWithWhite:0 alpha:1] CGColor], nil];
    [_viewBg.layer insertSublayer:gradient atIndex:0];
    
    _buttonUser.layer.cornerRadius = 10;
    _buttonUser.layer.rasterizationScale = [[UIScreen mainScreen] scale];
    _buttonUser.layer.shouldRasterize = YES;
    
    _buttonPicture.imageView.contentMode = UIViewContentModeScaleAspectFill;
    
    self.layer.cornerRadius = 2;
    self.layer.masksToBounds = YES;
    self.layer.shouldRasterize = YES;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];

}

- (void)setFeed:(Feed *)feed {
    _feed = feed;
    Picture *picture = feed.targets[0];

    [_imagePicture setImageWithURL:[NSURL URLWithString:picture.urlSmall] placeholderImage:nil];
    [_buttonUser setBackgroundImageForState:UIControlStateNormal withURL:[NSURL URLWithString:feed.user.profilePicture] placeholderImage:[UIImage imageNamed:@"user.gif"]];
    _labelUsername.text = feed.user.name;
}


- (IBAction)touchPicture:(UIButton *)sender {
    Picture *picture = _feed.targets[0];
    
    UIStoryboard *storyGallery = [UIStoryboard storyboardWithName:@"Gallery"
                                                           bundle:nil];
    UINavigationController *navGalerry = [storyGallery instantiateInitialViewController];
    LXGalleryViewController *viewGallery = navGalerry.viewControllers[0];
    viewGallery.delegate = _delegate;
    viewGallery.picture = picture;
    
    [_delegate presentViewController:navGalerry animated:YES completion:nil];
}

- (void)applyLayoutAttributes:(UICollectionViewLayoutAttributes *)layoutAttributes {
    [UIView animateWithDuration:0.3 animations:^{
        [self layoutIfNeeded];
    }];
}

@end
