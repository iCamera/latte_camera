//
//  luxeysCellNotify.m
//  Latte
//
//  Created by Xuan Dung Bui on 2012/10/01.
//  Copyright (c) 2012年 LUXEYS. All rights reserved.
//

#import "LXCellNotify.h"
#import "UIImageView+AFNetworking.h"
#import "UIImageView+loadProgress.h"

@implementation LXCellNotify

@synthesize labelNotify;
@synthesize viewImage;
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

- (void)setNotify:(NSDictionary *)notify {
    NSDictionary *target = [notify objectForKey:@"target"];
    NSDate *updatedAt = [LXUtils dateFromJSON:[notify objectForKey:@"updated_at"]];
    viewImage.image = [UIImage imageNamed:@"user.gif"];
    labelDate.text = [LXUtils timeDeltaFromNow:updatedAt];
    labelNotify.text = [LXUtils stringFromNotify:notify];
    
    CGRect frame = labelNotify.frame;
    CGSize labelSize = [labelNotify.text sizeWithFont:labelNotify.font
                                     constrainedToSize:CGSizeMake(215.0, MAXFLOAT)
                                         lineBreakMode:NSLineBreakByWordWrapping];
    frame.size.height = labelSize.height;
    labelNotify.frame = frame;
    
    if (target) {
        NotifyTarget notifyTarget = [[notify objectForKey:@"target_model"] integerValue];
        switch (notifyTarget) {
            case kNotifyTargetPicture: {
                Picture *pic = [Picture instanceFromDictionary:target];
                [viewImage setImageWithURL:[NSURL URLWithString:pic.urlSquare]];
                break;
            }
            case kNotifyTargetUser: {
                User *user = [User instanceFromDictionary:target];
                [viewImage setImageWithURL:[NSURL URLWithString:user.profilePicture] placeholderImage:[UIImage imageNamed:@"user.gif"]];
                break;
            }
            case kNotifyTargetComment: {
                NSMutableArray *users = [User mutableArrayFromDictionary:notify withKey:@"users"];
                for (User *user in users) {
                    if (user.name != nil) {
                        [viewImage setImageWithURL:[NSURL URLWithString:user.profilePicture] placeholderImage:[UIImage imageNamed:@"user.gif"]];
                    }
                }
            }
                break;
            default:
                break;
        }
    }
    self.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bg_menu.png"]];
    [self setSelectedBackgroundView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bg_menu_on.png"]]];
}

- (void)drawRect:(CGRect)rect {
    viewImage.layer.cornerRadius = 3;
    viewImage.clipsToBounds = YES;
    
    [super drawRect:rect];
}

@end
