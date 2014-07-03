//
//  luxeysCellNotify.m
//  Latte
//
//  Created by Xuan Dung Bui on 2012/10/01.
//  Copyright (c) 2012年 LUXEYS. All rights reserved.
//

#import "LXCellNotify.h"
#import "UIButton+AFNetworking.h"
#import "UIImageView+AFNetworking.h"
#import "Comment.h"
#import "LatteAPIClient.h"
#import "LXGalleryViewController.h"
#import <MBProgressHUD/MBProgressHUD.h>

@implementation LXCellNotify

@synthesize labelNotify;
@synthesize labelDate;

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

- (IBAction)touchImage:(id)sender {
    NotifyTarget notifyTarget = [[_notify objectForKey:@"target_model"] integerValue];
    NSDictionary *target = [_notify objectForKey:@"target"];
    
    switch (notifyTarget) {
        case kNotifyTargetPicture: {
            Picture *pic = [Picture instanceFromDictionary:target];
            UIStoryboard *storyGallery = [UIStoryboard storyboardWithName:@"Gallery"
                                                                   bundle:nil];
            
            UINavigationController *navGalerry = [storyGallery instantiateInitialViewController];
            LXGalleryViewController *viewGallery = navGalerry.viewControllers[0];
            
            viewGallery.picture = pic;
            viewGallery.delegate = _parent;
            [_parent presentViewController:navGalerry animated:YES completion:nil];
        }
            
            break;
        default:
            break;
    }
}

- (void)setNotify:(NSDictionary *)notify {
    _notify = notify;
    
    NSDictionary *target = [notify objectForKey:@"target"];
    NSDate *updatedAt = [LXUtils dateFromJSON:[notify objectForKey:@"updated_at"]];
    [_buttonImage setBackgroundImage:[UIImage imageNamed:@"user.gif"] forState:UIControlStateNormal];

    labelDate.text = [LXUtils timeDeltaFromNow:updatedAt];
    labelNotify.text = [LXUtils stringFromNotify:notify];
    
    if (target) {
        NotifyTarget notifyTarget = [[notify objectForKey:@"target_model"] integerValue];
        switch (notifyTarget) {
            case kNotifyTargetPicture: {
                Picture *pic = [Picture instanceFromDictionary:target];
                [_buttonImage setBackgroundImageForState:UIControlStateNormal withURL:[NSURL URLWithString:pic.urlSquare] placeholderImage:[UIImage imageNamed:@"user.gif"]];
                _buttonImage.enabled = YES;
                break;
            }
            case kNotifyTargetUser: {
                User *user = [User instanceFromDictionary:target];
                [_buttonImage setBackgroundImageForState:UIControlStateNormal withURL:[NSURL URLWithString:user.profilePicture] placeholderImage:[UIImage imageNamed:@"user.gif"]];
                _buttonImage.enabled = NO;
                break;
            }
            case kNotifyTargetComment: {
                _buttonImage.enabled = NO;
                NSMutableArray *users = [User mutableArrayFromDictionary:notify withKey:@"users"];
                for (User *user in users) {
                    if (user.name != nil) {
                        [_buttonImage setBackgroundImageForState:UIControlStateNormal withURL:[NSURL URLWithString:user.profilePicture] placeholderImage:[UIImage imageNamed:@"user.gif"]];
                    }
                }
            }
                break;
            default:
                break;
        }
    }
    NSNumber *read = notify[@"read"];
    self.highlighted = ![read boolValue];
}

@end
