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
    NSArray *users = [notify objectForKey:@"users"];
    labelNotify.text = @"";
    for (NSDictionary *user in users) {
        labelNotify.text = [labelNotify.text stringByAppendingString:[user objectForKey:@"name"]];
    }
    
    switch ([[notify objectForKey:@"kind"] integerValue]) {
        case 1: // Comment
            labelNotify.text = [labelNotify.text stringByAppendingString:@" comment"];
            break;
        case 2: // Vote
            labelNotify.text = [labelNotify.text stringByAppendingString:@" vote"];
            break;
        case 10: // target update
            labelNotify.text = [labelNotify.text stringByAppendingString:@" target update"];
            break;
        default:
            break;
    }
    if (target) {
        [viewImage setImageWithURL:[NSURL URLWithString:[target objectForKey:@"url_square"]]];
    }
}

@end
