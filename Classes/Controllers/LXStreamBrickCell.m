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
#import "LXUserPageViewController.h"
#import "Picture.h"
#import "LatteAPIClient.h"

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
    _buttonUser.layer.cornerRadius = 15;
    _buttonUser.layer.rasterizationScale = [[UIScreen mainScreen] scale];
    _buttonUser.layer.shouldRasterize = YES;
    
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

- (void)setPicture:(Picture *)picture {
    _picture = picture;
    
    _imagePicture.image = nil;
    [_imagePicture setImageWithURL:[NSURL URLWithString:picture.urlSmall]];
    
    NSString *urlCounter = [NSString stringWithFormat:@"picture/counter/%ld/%ld",
                            [picture.pictureId longValue],
                            [picture.userId longValue]];
    
    [[LatteAPIClient sharedClient] GET:urlCounter parameters:nil success:nil failure:nil];
}

- (void)setUser:(User *)user {
    _user = user;
    
    [_buttonUser setBackgroundImageForState:UIControlStateNormal withURL:[NSURL URLWithString:user.profilePicture] placeholderImage:[UIImage imageNamed:@"user.gif"]];
    _labelUsername.text = user.name;

}


- (IBAction)touchPicture:(UIButton *)sender {
    UIStoryboard *storyGallery = [UIStoryboard storyboardWithName:@"Gallery"
                                                           bundle:nil];
    LXGalleryViewController *viewGallery = [storyGallery instantiateInitialViewController];
    viewGallery.delegate = _delegate;
    viewGallery.picture = _picture;
    viewGallery.user = _user;
    [_delegate.navigationController pushViewController:viewGallery animated:YES];
}

- (IBAction)touchUser:(id)sender {
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"MainStoryboard"
                                                             bundle:nil];
    LXUserPageViewController *viewUserPage = [mainStoryboard instantiateViewControllerWithIdentifier:@"UserPage"];
    
    viewUserPage.user = _user;
    
    [_delegate.navigationController pushViewController:viewUserPage animated:YES];
}

- (void)applyLayoutAttributes:(UICollectionViewLayoutAttributes *)layoutAttributes {
    if (self.bounds.size.width == 100) {
        _buttonUser.userInteractionEnabled = NO;
    } else {
        _buttonUser.userInteractionEnabled = YES;
    }
    
    [UIView animateWithDuration:0.3 animations:^{
        if (self.bounds.size.width == 100) {
            _buttonUser.alpha = 0;
            _viewBg.alpha = 0;
            _labelUsername.alpha = 0;
        } else {
            _buttonUser.alpha = 1;
            _viewBg.alpha = 1;
            _labelUsername.alpha = 1;
        }
        [self layoutIfNeeded];
    }];
}

@end
