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
#import  "LatteAPIClient.h"

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

- (void)setFeed:(Feed *)feed {
    _feed = feed;
    Picture *picture = feed.targets[0];

    _imagePicture.image = nil;
    [_imagePicture setImageWithURL:[NSURL URLWithString:picture.urlSmall]];
    [_buttonUser setBackgroundImageForState:UIControlStateNormal withURL:[NSURL URLWithString:feed.user.profilePicture] placeholderImage:[UIImage imageNamed:@"user.gif"]];
    _labelUsername.text = feed.user.name;
    
    NSString *urlCounter = [NSString stringWithFormat:@"picture/counter/%ld/%ld",
                            [picture.pictureId longValue],
                            [picture.userId longValue]];
    
    [[LatteAPIClient sharedClient] GET:urlCounter parameters:nil success:nil failure:nil];
}


- (IBAction)touchPicture:(UIButton *)sender {
    Picture *picture = _feed.targets[0];
    
    UIStoryboard *storyGallery = [UIStoryboard storyboardWithName:@"Gallery"
                                                           bundle:nil];
    UINavigationController *navGalerry = [storyGallery instantiateInitialViewController];
    navGalerry.modalPresentationStyle = UIModalPresentationFullScreen;
    navGalerry.modalPresentationCapturesStatusBarAppearance = YES;
    
    LXGalleryViewController *viewGallery = navGalerry.viewControllers[0];
    viewGallery.delegate = _delegate;
    viewGallery.picture = picture;
    viewGallery.user = _feed.user;
    
    [_delegate presentViewController:navGalerry animated:YES completion:nil];
}

- (IBAction)touchUser:(id)sender {
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"MainStoryboard"
                                                             bundle:nil];
    LXUserPageViewController *viewUserPage = [mainStoryboard instantiateViewControllerWithIdentifier:@"UserPage"];
    
    viewUserPage.user = _feed.user;
    
    [_delegate.navigationController pushViewController:viewUserPage animated:YES];
}

- (void)applyLayoutAttributes:(UICollectionViewLayoutAttributes *)layoutAttributes {
    [UIView animateWithDuration:0.3 animations:^{
        [self layoutIfNeeded];
    }];
}

@end
