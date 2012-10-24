//
//  luxeysCellNotify.m
//  Latte
//
//  Created by Xuan Dung Bui on 2012/10/01.
//  Copyright (c) 2012年 LUXEYS. All rights reserved.
//

#import "luxeysCellNotify.h"
#import "UIImageView+AFNetworking.h"

@implementation luxeysCellNotify

@synthesize labelNotify;
@synthesize viewImage;

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
    labelNotify.text = @"";
    NSMutableArray *users = [User mutableArrayFromDictionary:notify withKey:@"users"];
    BOOL first = true;
    for (User *user in users) {
        if (first)
            first = true;
        else
            labelNotify.text = [labelNotify.text stringByAppendingString:@"と"];
            
        if (user.name != nil) {
            labelNotify.text = [labelNotify.text stringByAppendingString:user.name];
            labelNotify.text = [labelNotify.text stringByAppendingString:@"さん"];
        } else {
            labelNotify.text = [labelNotify.text stringByAppendingString:@"ゲスト"];
        }
    }
    
    switch ([[notify objectForKey:@"kind"] integerValue]) {
        case 1: // Comment
            labelNotify.text = [labelNotify.text stringByAppendingString:@"が、あなたの写真にコメントしました。"];
            break;
        case 2: // Vote
            labelNotify.text = [labelNotify.text stringByAppendingString:@"が、あなたの写真を「いいね！」と評価しました。"];
            break;
        case 10: // target update
            labelNotify.text = [labelNotify.text stringByAppendingString:@" target update"];
            break;
        default:
            break;
    }
    
    CGRect frame = labelNotify.frame;
    CGSize labelSize = [labelNotify.text sizeWithFont:[UIFont systemFontOfSize:11]
                                     constrainedToSize:CGSizeMake(200.0f, MAXFLOAT)
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
