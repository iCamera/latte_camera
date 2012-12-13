//
//  luxeysCellNotify.m
//  Latte
//
//  Created by Xuan Dung Bui on 2012/10/01.
//  Copyright (c) 2012年 LUXEYS. All rights reserved.
//

#import "LXCellNotify.h"
#import "UIImageView+AFNetworking.h"

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
    labelDate.text = [LXUtils timeDeltaFromNow:updatedAt];
    labelNotify.text = [LXUtils stringFromNotify:notify];
    
    CGRect frame = labelNotify.frame;
    CGSize labelSize = [labelNotify.text sizeWithFont:[UIFont fontWithName:@"AvenirNextCondensed-Regular" size:11]
                                     constrainedToSize:CGSizeMake(180.0, MAXFLOAT)
                                         lineBreakMode:NSLineBreakByWordWrapping];
    frame.size.height = labelSize.height;
    labelNotify.frame = frame;
    if (target) {
        Picture *pic = [Picture instanceFromDictionary:target];
        [viewImage setImageWithURL:[NSURL URLWithString:pic.urlSquare]];
        // viewImage.layer.cornerRadius = 3;
        // viewImage.clipsToBounds = YES;
    }
    self.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bg_menu.png"]];
    [self setSelectedBackgroundView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bg_menu_on.png"]]];
}

@end
